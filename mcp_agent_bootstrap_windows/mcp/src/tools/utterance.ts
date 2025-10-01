import path from 'path';
import fs from 'fs-extra';
import YAML from 'yaml';
import { resolveProject } from '../lib/resolver.js';
import { orgAgentTest } from './dx.js';

function ensureAbsolute(repoDir: string, p: string) {
  return path.isAbsolute(p) ? p : path.join(repoDir, p);
}

function fallbackAgentName(objectApiName: string) {
  return `${objectApiName.replace(/__c$/, '')}Agent`;
}

export async function utteranceSeed(repoDir: string, objectApiName: string, planPath?: string, outPath?: string) {
  const cfg = await resolveProject(repoDir);
  const planCandidate = planPath
    ? ensureAbsolute(repoDir, planPath)
    : path.join(repoDir, cfg.artifactsDir || '.artifacts', 'plan', `${objectApiName}.plan.v2.json`);
  let plan: any = {};
  try {
    plan = await fs.readJson(planCandidate);
  } catch (err) {
    plan = {};
  }
  const actions = plan?.architecture?.actions || plan?.architecture?.businessLogic || [];
  const actionNames = Array.isArray(actions)
    ? actions.map((a: any) => (typeof a === 'string' ? a : a?.name)).filter(Boolean)
    : [];
  const prompts = actionNames.length ? actionNames : ['retrieve'];
  const utterances = prompts.map((name: string, idx: number) => ({
    id: `${objectApiName}-${idx + 1}`,
    prompt: `${name} ${objectApiName.replace(/__c$/, '').replace(/_/g, ' ')}`.trim(),
    expected: {
      code: 'OK',
      action: name,
    },
    mode: 'non_destructive',
  }));

  const pack = {
    specVersion: '1.0',
    objectApiName,
    agentApiName: fallbackAgentName(objectApiName),
    utterances,
  };

  const docsDir = path.join(repoDir, 'docs', 'utterances');
  await fs.ensureDir(docsDir);
  const finalPath = outPath ? ensureAbsolute(repoDir, outPath) : path.join(docsDir, `${objectApiName}.yaml`);
  await fs.writeFile(finalPath, YAML.stringify(pack), 'utf8');
  return { ok: true, packPath: finalPath };
}

export async function utteranceRun(args: {
  repoDir: string;
  orgAlias: string;
  pack: string;
  mode?: string;
  scope?: string;
  waitMinutes?: number;
  ticketId?: string;
}) {
  const { repoDir, orgAlias, pack, mode, scope, waitMinutes, ticketId } = args;
  const absolutePack = ensureAbsolute(repoDir, pack);
  const packDoc = YAML.parse(await fs.readFile(absolutePack, 'utf8'));
  const utterances = (packDoc?.utterances || []).map((u: any) => String(u?.prompt || u));
  const capture = packDoc?.capture || ['transcript', 'actions', 'metrics'];
  const agentApiName = packDoc?.agentApiName || fallbackAgentName(packDoc?.objectApiName || 'Agent');
  const response = await orgAgentTest({
    repoDir,
    orgAlias,
    ticketId: ticketId || packDoc?.id || packDoc?.objectApiName,
    agentApiName,
    utterances,
    capture,
    mode: mode || packDoc?.mode || 'non_destructive',
    scope: scope || packDoc?.scope,
    waitMinutes: waitMinutes ?? 5,
  });
  const cfg = await resolveProject(repoDir);
  const outDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'utterance');
  await fs.ensureDir(outDir);
  const outPath = path.join(outDir, 'results.json');
  const payload = {
    pack: path.relative(repoDir, absolutePack),
    generatedAt: new Date().toISOString(),
    response,
  };
  await fs.writeJson(outPath, payload, { spaces: 2 });
  return { ok: true, outPath };
}

export async function utteranceAnalyze(repoDir: string, pack: string, resultPath?: string) {
  const absolutePack = ensureAbsolute(repoDir, pack);
  const packDoc = YAML.parse(await fs.readFile(absolutePack, 'utf8'));
  const cfg = await resolveProject(repoDir);
  const resultsFile = resultPath
    ? ensureAbsolute(repoDir, resultPath)
    : path.join(repoDir, cfg.artifactsDir || '.artifacts', 'utterance', 'results.json');
  const resultJson = await fs.readJson(resultsFile).catch(() => ({ response: {} }));
  const agentResponse = resultJson?.response || {};
  const envelope = agentResponse?.response?.envelope || agentResponse?.response;
  const utterances = packDoc?.utterances || [];
  const summary = utterances.map((u: any) => {
    const expectedCode = u?.expected?.code || 'OK';
    const actualCode = envelope?.code || envelope?.status || 'UNKNOWN';
    const pass = String(actualCode).toUpperCase() === String(expectedCode).toUpperCase();
    return {
      id: u?.id,
      expectedCode,
      actualCode,
      pass,
    };
  });
  const analysis = {
    pack: path.relative(repoDir, absolutePack),
    resultFile: path.relative(repoDir, resultsFile),
    generatedAt: new Date().toISOString(),
    outcomes: summary,
    passRate: summary.length ? summary.filter((s: any) => s.pass).length / summary.length : 0,
  };
  const outDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'utterance');
  await fs.ensureDir(outDir);
  const outPath = path.join(outDir, 'analysis.json');
  await fs.writeJson(outPath, analysis, { spaces: 2 });
  return { ok: true, outPath, passRate: analysis.passRate };
}
