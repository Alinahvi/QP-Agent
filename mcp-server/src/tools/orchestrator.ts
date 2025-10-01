/**
 * orchestrator.ts batches discovery work: discoveryFanout/startFromObject call into discovery.ts functions
 * (and thus sf CLI when needed) with bounded concurrency, while discoveryFromProject auto-detects object
 * candidates from the local repo before fanning out.
 */import * as path from 'path';
import pLimit from 'p-limit';
import { resolveProject } from '../lib/resolver.js';
import { ensureDir, writeJson } from '../lib/fsx.js';
import { planningStatus, startFromObject, startFromLwc } from './entrypoints.js';

async function scanProjectForCandidates(repoDir: string, searchRoots: string[]) {
  const { promises: fsp } = await import('fs');
  const setObjects = new Set<string>();
  const setLwc = new Set<string>();
  const lwcRoot = path.join(repoDir, 'force-app', 'main', 'default', 'lwc');
  try {
    const comps = await fsp.readdir(lwcRoot);
    for (const comp of comps) setLwc.add(comp);
  } catch {}
  for (const root of searchRoots) {
    const base = path.join(repoDir, root);
    try {
      const files = await fsp.readdir(base);
      for (const f of files) {
        // Heuristic: collect *_Controller.cls and *_Service.cls to derive object names
        if (f.endsWith('.cls') && f.includes('__c')) {
          const m = f.match(/([A-Za-z0-9_]+__c)/);
          if (m) setObjects.add(m[1]);
        }
      }
    } catch {}
  }
  return { objects: Array.from(setObjects), lwcComponents: Array.from(setLwc) };
}

export async function discoveryFanout(repoDir: string, orgAlias: string, opts: { objects?: string[]; lwcComponents?: string[]; staleHours?: number; maxConcurrency?: number; doPlan?: boolean; doBrief?: boolean }) {
  const cfg = await resolveProject(repoDir);
  const maxC = Math.min(5, Math.max(1, opts.maxConcurrency ?? 4));
  const lim = pLimit(maxC);
  const startedAt = new Date().toISOString();
  const results: any[] = [];

  const runForObject = async (obj: string) => {
    const r: any = { objectApiName: obj, startedAt: new Date().toISOString() };
    try {
      await startFromObject(repoDir, orgAlias, obj, opts.staleHours);
      if (opts.doPlan) {
        // startFromObject ensures plan v1; brief refresh is controlled by doBrief
      }
      if (opts.doBrief) {
        const { discoveryBrief } = await import('./brief.js');
        await discoveryBrief(repoDir, obj);
      }
      r.ok = true;
    } catch (e: any) {
      r.ok = false; r.error = String(e?.message || e);
    }
    r.finishedAt = new Date().toISOString();
    results.push(r);
  };

  const runForLwc = async (comp: string) => {
    const r: any = { lwc: comp, startedAt: new Date().toISOString() };
    try {
      await startFromLwc(repoDir, orgAlias, comp, opts.staleHours);
      r.ok = true;
    } catch (e: any) {
      r.ok = false; r.error = String(e?.message || e);
    }
    r.finishedAt = new Date().toISOString();
    results.push(r);
  };

  const tasks: Array<Promise<any>> = [];
  for (const o of opts.objects || []) tasks.push(lim(() => runForObject(o)));
  for (const c of opts.lwcComponents || []) tasks.push(lim(() => runForLwc(c)));
  await Promise.all(tasks);

  const outDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'discovery');
  await ensureDir(outDir);
  const outPath = path.join(outDir, 'fanout_report.json');
  await writeJson(outPath, { startedAt, maxConcurrency: maxC, results });
  return { ok: true, outPath, total: results.length };
}

export async function discoveryFromProject(repoDir: string, orgAlias: string, staleHours?: number, maxConcurrency?: number, doPlan?: boolean, doBrief?: boolean) {
  const cfg = await resolveProject(repoDir);
  const { objects, lwcComponents } = await scanProjectForCandidates(repoDir, cfg.searchRoots || []);
  return discoveryFanout(repoDir, orgAlias, { objects, lwcComponents, staleHours, maxConcurrency, doPlan, doBrief });
}


