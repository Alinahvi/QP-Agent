/**
 * entrypoints.ts provides high-level orchestration primitives built on discovery/planning helpers. These
 * functions evaluate file timestamps locally and invoke discovery/planning routines (which may call sf CLI)
 * only when artifacts are stale, keeping the workflow idempotent.
 */import * as path from 'path';
import { ensureDir, readJson, writeJson } from '../lib/fsx.js';
import { resolveProject } from '../lib/resolver.js';
import { orgDiscoverObject, orgDiscoverUsage, orgDiscoverPermissions, discoveryPlan } from './discovery.js';
import { discoveryBrief } from './brief.js';

function hoursAgo(h: number) { return Date.now() - h*3600*1000; }

export type Status = {
  objectApiName: string;
  hasDiscovery: boolean;
  hasPlan: boolean;
  discoveryUpdatedAt?: string;
  planUpdatedAt?: string;
  discoveryStale: boolean;
  planStale: boolean;
  notes?: string[];
};

async function fileMtimeMs(p: string): Promise<number|undefined> {
  try { const { promises: fsp } = await import('fs'); const st = await fsp.stat(p); return st.mtimeMs; } catch { return undefined; }
}

export async function docsScan(repoDir: string) {
  const planDir = path.join(repoDir, '.artifacts','plan');
  const docsDir = path.join(repoDir, 'docs');
  const sessionLog = path.join(docsDir, 'Session_Log.md');
  const actionPlan = path.join(docsDir, 'ActionPlan.md');
  const exists = async (p: string) => { try { const { promises: fsp } = await import('fs'); await fsp.access(p); return true; } catch { return false; } };
  const out = {
    actionPlan: (await exists(actionPlan)) ? { path: actionPlan, mtimeMs: await fileMtimeMs(actionPlan) } : null,
    sessionLog: (await exists(sessionLog)) ? { path: sessionLog, mtimeMs: await fileMtimeMs(sessionLog) } : null,
    planDir: (await exists(planDir)) ? { path: planDir } : null,
  };
  return out;
}

export async function planningStatus(repoDir: string, objectApiName: string, staleHours?: number): Promise<Status> {
  const cfg = await resolveProject(repoDir);
  const ttl = (staleHours ?? (cfg as any)?.planning?.staleHours ?? 24);
  const discDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'discovery', objectApiName);
  const planPath = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'plan', `${objectApiName}.plan.json`);
  const objP = path.join(discDir, 'object.json');
  const usageP = path.join(discDir, 'usage.json');
  const permsP = path.join(discDir, 'permissions.json');
  const [objM, usageM, permsM, planM] = await Promise.all([
    fileMtimeMs(objP), fileMtimeMs(usageP), fileMtimeMs(permsP), fileMtimeMs(planPath)
  ]);
  const latestDisc = Math.max(objM||0, usageM||0, permsM||0);
  const hasDiscovery = !!latestDisc;
  const hasPlan = !!planM;
  const cutoff = hoursAgo(ttl);
  const discoveryStale = !hasDiscovery || latestDisc < cutoff;
  const planStale = !hasPlan || planM! < cutoff;
  return {
    objectApiName,
    hasDiscovery, hasPlan,
    discoveryUpdatedAt: hasDiscovery ? new Date(latestDisc).toISOString() : undefined,
    planUpdatedAt: hasPlan ? new Date(planM!).toISOString() : undefined,
    discoveryStale, planStale,
    notes: []
  };
}

export async function startFromObject(repoDir: string, orgAlias: string, objectApiName: string, staleHours?: number) {
  const status = await planningStatus(repoDir, objectApiName, staleHours);
  if (status.discoveryStale) {
    await orgDiscoverObject(repoDir, orgAlias, objectApiName);
    await orgDiscoverUsage(repoDir, orgAlias, objectApiName);
    await orgDiscoverPermissions(repoDir, orgAlias, objectApiName);
  }
  if (!status.hasPlan) {
    await discoveryPlan(repoDir, objectApiName);
  }
  await discoveryBrief(repoDir, objectApiName);
  return { ok: true, refreshedDiscovery: status.discoveryStale, hadPlan: status.hasPlan };
}

export async function startFromLwc(repoDir: string, orgAlias: string, componentName: string, staleHours?: number) {
  const idxPath = path.join(repoDir, '.artifacts','schema','schema_index.json');
  let candidates: string[] = [];
  try {
    const idx = await readJson<any>(idxPath);
    const rec = idx?.components?.[componentName];
    if (rec && Array.isArray(rec.objects)) candidates = rec.objects;
  } catch {}
  if (!candidates.length) {
    // Fallback: quick scan of the component bundle
    const compDir = path.join(repoDir, 'force-app','main','default','lwc', componentName);
    const { promises: fsp } = await import('fs');
    let files: string[] = [];
    try { files = (await fsp.readdir(compDir)).filter(f=>f.endsWith('.js')||f.endsWith('.ts')||f.endsWith('.html')); } catch {}
    let src = '';
    for (const f of files) { try { src += '\n' + await fsp.readFile(path.join(compDir, f), 'utf8'); } catch {} }
    const objects = new Set<string>();
    const re = /@salesforce\/schema\/([A-Za-z0-9_]+(?:__c)?)(?:\.[A-Za-z0-9_]+(?:__c)?)?/g;
    let m: RegExpExecArray|null;
    while ((m = re.exec(src)) !== null) { objects.add(m[1]); }
    candidates = Array.from(objects);
  }
  if (!candidates.length) { return { ok: false, reason: 'No schema imports found in component/index', componentName }; }
  const results = [] as any[];
  for (const obj of candidates) { results.push(await startFromObject(repoDir, orgAlias, obj, staleHours)); }
  return { ok: true, componentName, candidates, results };
}

export async function planningResume(repoDir: string, orgAlias: string, objectApiName: string, staleHours?: number) {
  const status = await planningStatus(repoDir, objectApiName, staleHours);
  const cfg = await resolveProject(repoDir);
  const planPath = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'plan', `${objectApiName}.plan.json`);
  if (!status.hasPlan || status.planStale) {
    await discoveryPlan(repoDir, objectApiName);
  }
  await startFromObject(repoDir, orgAlias, objectApiName, staleHours);
  return { ok: true, planPath };
}

