/**
 * agentTestFromUtterances automates Salesforce agent test lifecycle end-to-end:
 *   1. Builds a YAML suite locally (using repo metadata for sensible defaults).
 *   2. Shells to \"sf agent test create/run\" to push + execute in the target org.
 *   3. Captures CLI inputs/outputs so future runs are traceable under .artifacts/agent.
 */import * as path from 'path';
import { promises as fsp } from 'fs';
import { trySh } from '../lib/exec.js';
import fs from 'fs-extra';
import { ensureDir, writeText, writeJson } from '../lib/fsx.js';

function yamlEscape(s: string): string {
  return '"' + String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"';
}

async function writeSpecYaml(
  repoDir: string,
  agentApiName: string,
  testApiName: string,
  utterances: string[],
  nonDestructive: boolean
): Promise<string> {
  const outDir = path.join(repoDir, '.artifacts', 'agent', 'specs');
  await ensureDir(outDir);
  const fpath = path.join(outDir, `${testApiName}.yaml`);

  // Try to derive defaults from local GenAiPlannerBundle
  let defaultTopic = '';
  let defaultActions: string[] = [];
  try {
    const plannerPath = path.join(
      repoDir,
      'force-app',
      'main',
      'default',
      'genAiPlannerBundles',
      agentApiName,
      `${agentApiName}.genAiPlannerBundle`
    );
    const xml = await fs.readFile(plannerPath, 'utf8');
    const topicMatch = xml.match(/<genAiPluginName>([^<]+)<\/genAiPluginName>/);
    if (topicMatch) defaultTopic = topicMatch[1];
    const fnMatches = Array.from(xml.matchAll(/<genAiFunctionName>([^<]+)<\/genAiFunctionName>/g));
    defaultActions = fnMatches.map((m) => m[1]).filter(Boolean);
  } catch {}

  const lines: string[] = [];
  lines.push('version: 1');
  lines.push('subject:');
  lines.push('  type: AGENT');
  lines.push(`  apiName: ${agentApiName}`);
  lines.push('suite:');
  lines.push('  name: ' + testApiName);
  lines.push('  description: "Auto-generated from utterances"');
  lines.push('config:');
  lines.push(`  nonDestructive: ${nonDestructive ? 'true' : 'false'}`);
  lines.push('tests:');
  utterances.forEach((utt, i) => {
    lines.push(`  - name: "u${i + 1}"`);
    lines.push('    utterance: ' + yamlEscape(utt));
    lines.push('    expectedTopic: ' + yamlEscape(defaultTopic));
    lines.push('    expectedActions: [' + (defaultActions.length ? defaultActions.map(yamlEscape).join(', ') : '') + ']');
    lines.push('    expectedOutcome: ""');
    lines.push('    customEvaluations: []');
    lines.push('    conversationHistory: []');
  });

  await writeText(fpath, lines.join('\n'));
  return fpath;
}

export async function agentTestFromUtterances(
  repoDir: string,
  orgAlias: string,
  agentApiName: string,
  testApiName: string,
  utterances: string[],
  waitMinutes: number = 5,
  nonDestructive: boolean = true
) {
  if (!agentApiName) throw new Error('agentApiName is required');
  if (!testApiName) throw new Error('testApiName is required');
  if (!utterances || !utterances.length) throw new Error('utterances must be a non-empty array');

  const specPath = await writeSpecYaml(repoDir, agentApiName, testApiName, utterances, nonDestructive);

  const artifactsDir = path.join(repoDir, '.artifacts', 'agent');
  await ensureDir(artifactsDir);

  // 1) Create or overwrite the test in org
  const createArgs = [
    'agent', 'test', 'create',
    '--target-org', orgAlias,
    '--api-name', testApiName,
    '--spec', specPath,
    '--force-overwrite',
    '--json',
  ];
  const createOut = await trySh('sf', createArgs, repoDir);
  const createLog = path.join(artifactsDir, `${testApiName}.create.log.json`);
  await writeJson(createLog, { args: createArgs, out: createOut });

  // 2) Run the test
  const runArgs = [
    'agent', 'test', 'run',
    '--target-org', orgAlias,
    '--api-name', testApiName,
    '--wait', String(waitMinutes),
    '--result-format', 'json',
    '--output-dir', artifactsDir,
  ];
  const runOut = await trySh('sf', runArgs, repoDir);
  const runLog = path.join(artifactsDir, `${testApiName}.run.log.json`);
  await writeJson(runLog, { args: runArgs, out: runOut });

  // 3) Find latest test result JSON in artifactsDir
  let resultFile: string | null = null;
  try {
    const list = await fsp.readdir(artifactsDir);
    const cands = list.filter((n) => n.toLowerCase().includes('test-result') && n.endsWith('.json'));
    if (cands.length) {
      let latestName = cands[0];
      let latestTime = 0;
      for (const n of cands) {
        const st = await fsp.stat(path.join(artifactsDir, n));
        if (st.mtimeMs > latestTime) { latestTime = st.mtimeMs; latestName = n; }
      }
      resultFile = path.join(artifactsDir, latestName);
    }
  } catch {}

  return {
    ok: true,
    specPath,
    createLog,
    runLog,
    resultFile,
    note: resultFile ? 'Agent test executed; inspect resultFile for transcript/metrics' : 'Run completed; no result file detected',
  };
}

