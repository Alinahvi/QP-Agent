import * as path from 'path';
import fs from 'fs-extra';
import pLimit from 'p-limit';
import { resolveProject } from '../lib/resolver.js';
import { deployManifest } from '../lib/sf.js';
import { testsApex } from './tests.js';
import { testsAgent } from './agent.js';
import { planningVerify } from './planning.js';
import { orgDiscoverObject, orgDiscoverUsage, orgDiscoverPermissions, discoveryPlan } from './discovery.js';
import { discoveryBrief } from './brief.js';
import { actionlayerScaffold } from './scaffold.js';
import { agentDocSync } from './agent.js';

type ApexResult  = { ok: boolean; ran: string[] };
type AgentResult = { ok: boolean; ran: string[] };
type ReleaseResult = {
  deploy: { ok: boolean; details: unknown },
  apex: ApexResult,
  agent: AgentResult,
  planning?: { ok: boolean; verifyPath?: string; halted?: boolean; reason?: string },
  steps?: string[]
};

export async function deploySafe(repoDir: string, orgAlias: string, manifestPath: string) {
  const out = await deployManifest(repoDir, orgAlias, manifestPath);
  return { ok: true, details: out };
}

export async function releaseBranch(
  repoDir: string,
  orgAlias: string,
  runAgentTests = false,
  apexShards = 2,
  maxAttempts = 1
): Promise<ReleaseResult> {
  const cfg = await resolveProject(repoDir);

  // 1) Deploy (exclusive org lock handled outside this function)
  const manifest = cfg.deploy?.manifest || 'manifest/package.xml';
  const dep = await deploySafe(repoDir, orgAlias, manifest);

  // 2) Parallel: Apex tests (smoke/suite) and optional Agent tests
  const lim = pLimit(3);

  const tasks: Array<Promise<ApexResult | AgentResult>> = [
    lim(() =>
      testsApex(
        repoDir,
        orgAlias,
        'suite',
        cfg.apex?.fromRef || 'origin/main',
        cfg.apex?.suiteNames || ['FR_Smoke'],
        [],
        2400
      )
    ) as Promise<ApexResult>
  ];

  if (runAgentTests) {
    tasks.push(lim(() => testsAgent(repoDir, orgAlias, 15)) as Promise<AgentResult>);
  }

  const results = await Promise.all(tasks);
  const apexRes  = results[0] as ApexResult;
  const agentRes = runAgentTests ? (results[1] as AgentResult) : ({ ok: true, ran: [] } as AgentResult);

  return { deploy: dep, apex: apexRes, agent: agentRes };
}

export async function releaseWithPlanning(
  repoDir: string,
  orgAlias: string,
  objectApiName: string,
  options: { runAgentTests?: boolean; apexShards?: number; maxAttempts?: number; force?: boolean; dryRun?: boolean } = {}
): Promise<ReleaseResult> {
  const runAgent = options.runAgentTests ?? false;
  const steps: string[] = [];
  const resumePath = await (await import('./audit_resume.js')).resumeContext(repoDir, objectApiName);
  steps.push('resume:context');

  const verify = await planningVerify(repoDir, objectApiName);
  steps.push('planning:verify');
  if (!verify.ok && !options.force) {
    return {
      deploy: { ok: false, details: 'Planning verification failed; aborting orchestrator.' },
      apex: { ok: false, ran: [] },
      agent: { ok: true, ran: [] } as any,
      planning: { ok: false, verifyPath: verify.verifyPath, halted: true, reason: 'Plan/Discovery mismatch' },
      steps,
    } as any;
  }

  if (options.dryRun) {
    steps.push('org:discover_* (skipped - dry-run)');
    steps.push('discovery:brief (skipped - dry-run)');
    steps.push('actionlayer:scaffold --mode apply (skipped - dry-run)');
    steps.push('agent:doc-sync (skipped - dry-run)');
    steps.push('deploy:safe (skipped - dry-run)');
    steps.push('tests:apex (skipped - dry-run)');
    return { deploy: { ok: true, details: 'dry-run' }, apex: { ok: true, ran: [] }, agent: { ok: true, ran: [] } as any, planning: { ok: verify.ok, verifyPath: verify.verifyPath }, steps } as any;
  }

  await orgDiscoverObject(repoDir, orgAlias, objectApiName);
  steps.push('org:discover_object');
  await orgDiscoverUsage(repoDir, orgAlias, objectApiName);
  steps.push('org:discover_usage');
  await orgDiscoverPermissions(repoDir, orgAlias, objectApiName);
  steps.push('org:discover_permissions');
  await discoveryPlan(repoDir, objectApiName);
  steps.push('discovery:plan');
  await discoveryBrief(repoDir, objectApiName, 'origin/main');
  steps.push('discovery:brief');

  await actionlayerScaffold(repoDir, path.join(repoDir, '.artifacts','plan', `${objectApiName}.plan.json`), 'apply' as any);
  steps.push('actionlayer:scaffold --mode apply');
  await agentDocSync(repoDir, orgAlias, objectApiName);
  steps.push('agent:doc-sync');

  const manifest = (await resolveProject(repoDir)).deploy?.manifest || 'manifest/package.xml';
  const dep = await deploySafe(repoDir, orgAlias, manifest);
  steps.push('deploy:safe');

  const apexRes = await testsApex(repoDir, orgAlias, 'suite', 'origin/main', ['FR_Smoke'], [], 2400) as any;
  steps.push('tests:apex');
  const agentRes = runAgent ? await testsAgent(repoDir, orgAlias, 15) as any : ({ ok: true, ran: [] } as any);
  if (runAgent) steps.push('tests:agent');

  return { deploy: dep, apex: apexRes, agent: agentRes, planning: { ok: verify.ok, verifyPath: verify.verifyPath }, steps } as any;
}
