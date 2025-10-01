import { createHash } from 'crypto';
import path from 'path';
import fs from 'fs-extra';
import { resolveProject } from '../lib/resolver.js';
import { dataQuery, toolingQuery, assignPermissionSet, runAgentTest } from '../lib/sf.js';

function makeStableId(input: string, fallback: string) {
  const trimmed = (input || '').trim();
  if (trimmed) {
    return trimmed.replace(/[^A-Za-z0-9_-]/g, '_');
  }
  return fallback;
}

export async function orgSoql(repoDir: string, orgAlias: string, soql: string) {
  const cfg = await resolveProject(repoDir);
  const { records, raw } = await dataQuery(repoDir, orgAlias, soql);
  const hash = createHash('sha1').update(soql).digest('hex').slice(0, 12);
  const outDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'dx', 'soql');
  await fs.ensureDir(outDir);
  const outPath = path.join(outDir, `${hash}.json`);
  await fs.writeJson(outPath, {
    generatedAt: new Date().toISOString(),
    orgAlias,
    soql,
    rowCount: records.length,
    records,
    raw,
  }, { spaces: 2 });
  return { ok: true, outPath, rowCount: records.length };
}

export async function orgToolingSoql(repoDir: string, orgAlias: string, soql: string) {
  const cfg = await resolveProject(repoDir);
  const { records, raw } = await toolingQuery(repoDir, orgAlias, soql);
  const hash = createHash('sha1').update(soql).digest('hex').slice(0, 12);
  const outDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'dx', 'tooling');
  await fs.ensureDir(outDir);
  const outPath = path.join(outDir, `${hash}.json`);
  await fs.writeJson(outPath, {
    generatedAt: new Date().toISOString(),
    orgAlias,
    soql,
    rowCount: records.length,
    records,
    raw,
  }, { spaces: 2 });
  return { ok: true, outPath, rowCount: records.length };
}

export async function orgAssignPermissionSet(repoDir: string, orgAlias: string, permissionSetName: string) {
  const cfg = await resolveProject(repoDir);
  const raw = await assignPermissionSet(repoDir, orgAlias, permissionSetName);
  let parsed: any;
  try {
    parsed = JSON.parse(raw);
  } catch (err) {
    parsed = { raw };
  }
  const outDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'dx', 'permset');
  await fs.ensureDir(outDir);
  const safe = makeStableId(permissionSetName, 'permset');
  const outPath = path.join(outDir, `${safe}.json`);
  await fs.writeJson(outPath, {
    generatedAt: new Date().toISOString(),
    orgAlias,
    permissionSetName,
    result: parsed,
  }, { spaces: 2 });
  return { ok: true, outPath };
}

type AgentArgs = {
  repoDir: string;
  orgAlias: string;
  ticketId?: string;
  packPath?: string;
  agentApiName?: string;
  context?: Record<string, any>;
  capture?: string[];
  utterances?: string[];
  mode?: string;
  scope?: string;
  maxTurns?: number;
  waitMinutes?: number;
};

export async function orgAgentTest({
  repoDir,
  orgAlias,
  ticketId,
  packPath,
  agentApiName,
  context,
  capture,
  utterances,
  mode,
  scope,
  maxTurns,
  waitMinutes,
}: AgentArgs) {
  const cfg = await resolveProject(repoDir);
  const safeTicket = makeStableId(ticketId || agentApiName || 'agent', `agent-${Date.now()}`);
  const result = await runAgentTest(repoDir, orgAlias, {
    packPath,
    agentApiName,
    utterances,
    context,
    capture,
    mode,
    scope,
    maxTurns,
    waitMinutes,
    ticketId: safeTicket,
  });

  let parsed: any;
  try {
    parsed = JSON.parse(result.raw);
  } catch (err) {
    parsed = undefined;
  }

  const outDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'agent');
  await fs.ensureDir(outDir);
  const outPath = path.join(outDir, `${safeTicket}.json`);
  await fs.writeJson(outPath, {
    ticketId: ticketId || safeTicket,
    generatedAt: new Date().toISOString(),
    agentApiName,
    orgAlias,
    packPath: result.packPath,
    response: parsed || { raw: result.raw },
  }, { spaces: 2 });

  return { ok: true, outPath, packPath: result.packPath };
}
