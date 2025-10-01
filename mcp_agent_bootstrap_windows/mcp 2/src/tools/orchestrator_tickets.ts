/**
 * orchestrator_tickets.ts converts ticket Markdown into automation: ticketsCollect indexes local files,
 * planningFanout/ticketsFanout orchestrate plan resumes, scaffolding, deploys, tests, and optional agent
 * runs (invoking sf CLI adapters as needed), and auditActionLayerFanout batches local handler audits.
 */import * as path from 'path';
import pLimit from 'p-limit';
import YAML from 'yaml';
import fg from 'fast-glob';
import { resolveProject } from '../lib/resolver.js';
import { ensureDir, writeJson, readJson } from '../lib/fsx.js';
import { planningResume } from './entrypoints.js';
import { actionlayerScaffold } from './scaffold.js';
import { agentDocSync } from './agent.js';
import { deploySafe } from './deploy_release.js';
import { testsApex } from './tests.js';
import { orgAssignPermissionSet, orgSoql, orgAgentTest } from './dx.js';

type TicketPipeline = {
  permissionSets: string[];
  fixtures: string[];
  agent?: {
    agentApiName?: string;
    utterances?: string[];
    capture?: string[];
    mode?: string;
    scope?: string;
    maxTurns?: number;
  };
};

type TicketIndex = {
  id: string;
  path: string;
  title: string;
  priority?: string;
  area?: string;
  objectApiName?: string;
  allowDestructive?: boolean;
  suite?: string[];
  allowlist?: string[];
  runAgent?: boolean;
  pipeline?: TicketPipeline;
};

function parseFrontmatter(text: string): Record<string, any> {
  const match = text.match(/^---\s*([\s\S]*?)\s*---/);
  if (match) {
    try { return YAML.parse(match[1]) || {}; } catch { return {}; }
  }
  return {};
}

function parseLegacyKeyValues(text: string): Record<string, any> {
  const res: Record<string, any> = {};
  const re = /^\s*-\s*([A-Za-z0-9_.-]+):\s*(.+)$/gm;
  let m: RegExpExecArray | null;
  while ((m = re.exec(text)) !== null) {
    const k = m[1].trim();
    const v = m[2].trim();
    if (v.startsWith('[') && v.endsWith(']')) {
      try { res[k] = JSON.parse(v); } catch { res[k] = v; }
    } else if (/^(true|false)$/i.test(v)) {
      res[k] = String(v).toLowerCase() === 'true';
    } else {
      res[k] = v;
    }
  }
  return res;
}

function extractPipeline(text: string): TicketPipeline {
  const body = text.replace(/^---[\s\S]*?---/, '');
  const permissionSets = Array.from(body.matchAll(/`assign_permission_set\s*:?\s*([^`]+)`/gi)).map((m) => m[1].trim());
  const fixtureBlocks = Array.from(body.matchAll(/`run_soql_query`[^\n]*\n?[^`]*`([^`]+)`/gi)).map((m) => m[1].trim());
  const fixtureFallback = Array.from(body.matchAll(/run_soql_query[^\n]*\n([^\n]+)/gi)).map((m) => m[1].trim());
  const fixtures = fixtureBlocks.length ? fixtureBlocks : fixtureFallback;

  const agentApiName = body.match(/`agentApiName`\s*:\s*`?([^`\n]+)`?/i)?.[1]?.trim();
  const utterancesRaw = body.match(/`utterances`\s*:\s*`([^`]+)`/i)?.[1];
  let utterances: string[] | undefined;
  if (utterancesRaw) {
    try {
      const parsed = JSON.parse(utterancesRaw.trim());
      if (Array.isArray(parsed)) utterances = parsed.map((u) => String(u));
    } catch {
      utterances = [utterancesRaw.trim()];
    }
  }
  const captureRaw = body.match(/`capture`\s*:\s*`([^`]+)`/i)?.[1];
  let capture: string[] | undefined;
  if (captureRaw) {
    try {
      const parsed = JSON.parse(captureRaw.trim());
      if (Array.isArray(parsed)) capture = parsed.map((c) => String(c));
    } catch {
      capture = captureRaw.split(',').map((c) => c.trim()).filter(Boolean);
    }
  }
  const mode = body.match(/`mode`\s*:\s*`?([^`\n]+)`?/i)?.[1]?.trim();
  const scope = body.match(/`scope`\s*:\s*`?([^`\n]+)`?/i)?.[1]?.trim();
  const maxTurns = Number(body.match(/`maxTurns`\s*:\s*`?([0-9]+)`?/i)?.[1] ?? NaN);

  const agent = (agentApiName || utterances || capture || mode || scope || Number.isFinite(maxTurns))
    ? { agentApiName, utterances, capture, mode, scope, maxTurns: Number.isFinite(maxTurns) ? maxTurns : undefined }
    : undefined;

  return { permissionSets, fixtures, agent };
}

function mergeMetadata(primary: Record<string, any>, fallback: Record<string, any>): Record<string, any> {
  return { ...fallback, ...primary };
}

export async function ticketsCollect(repoDir: string, opts: { includeBacklog?: boolean; includeDerived?: boolean; glob?: string }) {
  const cfg = await resolveProject(repoDir);
  const roots = [
    path.join(repoDir, 'tickets'),
    path.join(repoDir, 'mcp_planning_upgrade', 'tickets'),
    path.join(repoDir, 'docs', 'Phase 3', 'tickets'),
  ];

  const includeBacklog = opts.includeBacklog ?? true;
  const includeDerived = opts.includeDerived ?? true;

  // Gather Markdown files recursively, honoring optional glob
  const fileSet = new Set<string>();
  if (opts.glob) {
    const hits = await fg(opts.glob, { cwd: repoDir, onlyFiles: true, absolute: true });
    hits.forEach((p) => fileSet.add(path.resolve(p)));
  } else {
    for (const root of roots) {
      let hits: string[] = [];
      try {
        hits = await fg('**/*.md', { cwd: root, onlyFiles: true, absolute: true });
      } catch {
        continue;
      }
      hits.forEach((p) => fileSet.add(path.resolve(p)));
    }
  }

  const items: TicketIndex[] = [];
  for (const abs of Array.from(fileSet)) {
    const relPath = path.relative(repoDir, abs).replace(/\\/g, '/');
    const isDerived = /\/derived\//i.test(relPath);
    if (!includeDerived && isDerived) continue;
    if (!includeBacklog && !isDerived) continue;

    let text = '';
    try { text = await (await import('fs')).promises.readFile(abs, 'utf8'); } catch { continue; }
    const file = path.basename(abs);
    const fm = mergeMetadata(parseFrontmatter(text), parseLegacyKeyValues(text));
    const title = (text.split('\n')[0] || '').replace(/^#\s*/, '') || file;
    const id = fm.id || file.replace(/\.md$/i, '');
    const objectApiName = fm.object || fm.objectApiName;
    const pipeline = extractPipeline(text);
    const ticket: TicketIndex = {
      id,
      path: relPath,
      title,
      priority: fm.priority,
      area: fm.area,
      objectApiName,
      allowDestructive: Boolean(fm.allowDestructive || fm.destructive),
      suite: Array.isArray(fm.suite) ? fm.suite : undefined,
      allowlist: Array.isArray(fm.allowlist) ? fm.allowlist : undefined,
      runAgent: Boolean(fm.runAgent),
      pipeline,
    };
    items.push(ticket);
  }

  const outDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'tickets');
  await ensureDir(outDir);
  const outPath = path.join(outDir, 'index.json');
  await writeJson(outPath, { generatedAt: new Date().toISOString(), count: items.length, items });
  return { ok: true, outPath, count: items.length };
}

export async function planningFanout(repoDir: string, orgAlias: string, opts: { objects: string[]; staleHours?: number; maxConcurrency?: number }) {
  const cfg = await resolveProject(repoDir);
  const maxC = Math.min(5, Math.max(1, opts.maxConcurrency ?? 4));
  const lim = pLimit(maxC);
  const results: any[] = [];
  const stale = opts.staleHours ?? (cfg as any)?.planning?.staleHours ?? 24;
  await Promise.all((opts.objects || []).map((objectApiName) => lim(async () => {
    const run: any = { objectApiName, startedAt: new Date().toISOString() };
    try {
      const pr = await planningResume(repoDir, orgAlias, objectApiName, stale);
      run.ok = true;
      run.planPath = pr.planPath;
    } catch (err: any) {
      run.ok = false;
      run.error = String(err?.message || err);
    }
    run.finishedAt = new Date().toISOString();
    results.push(run);
  })));
  const outDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'plan');
  await ensureDir(outDir);
  const outPath = path.join(outDir, 'fanout_plan_report.json');
  await writeJson(outPath, { startedAt: new Date().toISOString(), results });
  return { ok: true, outPath, count: results.length };
}

function fallbackAgentName(objectApiName?: string) {
  if (!objectApiName) return 'Agent';
  return `${objectApiName.replace(/__c$/, '')}Agent`;
}

export async function ticketsFanout(repoDir: string, orgAlias: string, opts: {
  maxConcurrency?: number;
  runScaffold?: boolean;
  runDeploy?: boolean;
  runApex?: boolean;
  runAgent?: boolean;
}) {
  const cfg = await resolveProject(repoDir);
  const idxPath = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'tickets', 'index.json');
  const idx = await readJson(idxPath);
  const items: TicketIndex[] = idx.items || [];
  const maxC = Math.min(5, Math.max(1, opts.maxConcurrency ?? 4));
  const lim = pLimit(maxC);
  const results: any[] = [];

  const runOne = async (ticket: TicketIndex) => {
    const startedAt = new Date().toISOString();
    const steps: any[] = [];
    const record: any = { id: ticket.id, path: ticket.path, object: ticket.objectApiName, startedAt, steps };
    try {
      if (ticket.objectApiName) {
        steps.push({ name: 'planning:resume', status: 'running' });
        const pr = await planningResume(repoDir, orgAlias, ticket.objectApiName, (cfg as any)?.planning?.staleHours ?? 24);
        steps[steps.length - 1] = { name: 'planning:resume', status: 'ok', planPath: pr.planPath };
        record.planPath = pr.planPath;
      }
      if (opts.runScaffold && ticket.objectApiName && record.planPath) {
        steps.push({ name: 'actionlayer:scaffold', status: 'running' });
        await actionlayerScaffold(repoDir, record.planPath, 'apply');
        await agentDocSync(repoDir, orgAlias, ticket.objectApiName);
        steps[steps.length - 1] = { name: 'actionlayer:scaffold', status: 'ok' };
      }
      if (opts.runDeploy) {
        steps.push({ name: 'deploy:safe', status: 'running' });
        await deploySafe(repoDir, orgAlias, cfg.deploy?.manifest || 'package.xml');
        steps[steps.length - 1] = { name: 'deploy:safe', status: 'ok' };
      }
      if (opts.runApex) {
        const suite = ticket.suite && ticket.suite.length ? ticket.suite : (cfg.apex?.suiteNames || ['FR_Smoke']);
        steps.push({ name: 'tests:apex', status: 'running', suite, allowlist: ticket.allowlist || [] });
        await testsApex(repoDir, orgAlias, 'suite', 'origin/main', suite, ticket.allowlist || [], 2400);
        steps[steps.length - 1] = { name: 'tests:apex', status: 'ok' };
      }
      if (opts.runAgent && ticket.runAgent) {
        const pipeline = ticket.pipeline || { permissionSets: [], fixtures: [], agent: undefined };
        for (const perm of pipeline.permissionSets || []) {
          steps.push({ name: 'org:assign_permission_set', status: 'running', permissionSet: perm });
          await orgAssignPermissionSet(repoDir, orgAlias, perm);
          steps[steps.length - 1] = { name: 'org:assign_permission_set', status: 'ok', permissionSet: perm };
        }
        for (const soql of pipeline.fixtures || []) {
          steps.push({ name: 'org:soql', status: 'running', soql });
          await orgSoql(repoDir, orgAlias, soql);
          steps[steps.length - 1] = { name: 'org:soql', status: 'ok', soql };
        }
        const agentCfg = pipeline.agent || {};
        const requestedMode = agentCfg.mode || 'non_destructive';
        const finalMode = requestedMode === 'destructive' && !ticket.allowDestructive ? 'non_destructive' : requestedMode;
        steps.push({ name: 'org:agent_test', status: 'running', mode: finalMode });
        const agentResult = await orgAgentTest({
          repoDir,
          orgAlias,
          ticketId: ticket.id,
          agentApiName: agentCfg.agentApiName || fallbackAgentName(ticket.objectApiName),
          utterances: agentCfg.utterances && agentCfg.utterances.length ? agentCfg.utterances : [`${ticket.title}`],
          capture: agentCfg.capture,
          mode: finalMode,
          scope: agentCfg.scope,
          maxTurns: agentCfg.maxTurns,
        });
        steps[steps.length - 1] = { name: 'org:agent_test', status: 'ok', artifact: agentResult.outPath };
        record.agent = agentResult;
      }
      record.ok = true;
    } catch (err: any) {
      record.ok = false;
      record.error = String(err?.message || err);
      const current = steps[steps.length - 1];
      if (current && current.status === 'running') current.status = 'error';
    }
    record.finishedAt = new Date().toISOString();
    const outDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'tickets', 'results');
    await ensureDir(outDir);
    const outPath = path.join(outDir, `${ticket.id}.json`);
    record.outputPath = outPath;
    await writeJson(outPath, record);
    results.push(record);
    return record;
  };

  await Promise.all(items.map((ticket) => lim(() => runOne(ticket))));
  const reportPath = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'tickets', 'fanout_report.json');
  await writeJson(reportPath, { startedAt: new Date().toISOString(), count: items.length, maxConcurrency: maxC, results });
  return { ok: true, reportPath, total: items.length };
}

export async function auditActionLayerFanout(repoDir: string, opts: { objects: string[]; maxConcurrency?: number; apply?: boolean }) {
  const { auditActionLayer } = await import('./audit_resume.js');
  const cfg = await resolveProject(repoDir);
  const maxC = Math.min(5, Math.max(1, opts.maxConcurrency ?? 4));
  const lim = pLimit(maxC);
  const results: any[] = [];
  await Promise.all((opts.objects || []).map((objectApiName) => lim(async () => {
    try {
      const out = await auditActionLayer(repoDir, objectApiName, !!opts.apply);
      results.push({ object: objectApiName, ok: true, out });
    } catch (err: any) {
      results.push({ object: objectApiName, ok: false, error: String(err?.message || err) });
    }
  })));
  const outDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'review');
  await ensureDir(outDir);
  const outPath = path.join(outDir, 'audit_fanout.json');
  await writeJson(outPath, { startedAt: new Date().toISOString(), results });
  return { ok: true, outPath, count: (opts.objects || []).length };
}

