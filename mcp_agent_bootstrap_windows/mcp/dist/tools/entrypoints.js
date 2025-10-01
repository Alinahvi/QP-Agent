import * as path from 'path';
import { readJson } from '../lib/fsx.js';
import { resolveProject } from '../lib/resolver.js';
import { orgDiscoverObject, orgDiscoverUsage, orgDiscoverPermissions, discoveryPlan } from './discovery.js';
import { discoveryBrief } from './brief.js';
function hoursAgo(h) { return Date.now() - h * 3600 * 1000; }
async function fileMtimeMs(p) {
    try {
        const { promises: fsp } = await import('fs');
        const st = await fsp.stat(p);
        return st.mtimeMs;
    }
    catch {
        return undefined;
    }
}
export async function docsScan(repoDir) {
    const planDir = path.join(repoDir, '.artifacts', 'plan');
    const docsDir = path.join(repoDir, 'docs');
    const sessionLog = path.join(docsDir, 'Session_Log.md');
    const actionPlan = path.join(docsDir, 'ActionPlan.md');
    const exists = async (p) => { try {
        const { promises: fsp } = await import('fs');
        await fsp.access(p);
        return true;
    }
    catch {
        return false;
    } };
    const out = {
        actionPlan: (await exists(actionPlan)) ? { path: actionPlan, mtimeMs: await fileMtimeMs(actionPlan) } : null,
        sessionLog: (await exists(sessionLog)) ? { path: sessionLog, mtimeMs: await fileMtimeMs(sessionLog) } : null,
        planDir: (await exists(planDir)) ? { path: planDir } : null,
    };
    return out;
}
export async function planningStatus(repoDir, objectApiName, staleHours) {
    const cfg = await resolveProject(repoDir);
    const ttl = (staleHours ?? cfg?.planning?.staleHours ?? 24);
    const discDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'discovery', objectApiName);
    const planPath = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'plan', `${objectApiName}.plan.json`);
    const objP = path.join(discDir, 'object.json');
    const usageP = path.join(discDir, 'usage.json');
    const permsP = path.join(discDir, 'permissions.json');
    const [objM, usageM, permsM, planM] = await Promise.all([
        fileMtimeMs(objP), fileMtimeMs(usageP), fileMtimeMs(permsP), fileMtimeMs(planPath)
    ]);
    const latestDisc = Math.max(objM || 0, usageM || 0, permsM || 0);
    const hasDiscovery = !!latestDisc;
    const hasPlan = !!planM;
    const cutoff = hoursAgo(ttl);
    const discoveryStale = !hasDiscovery || latestDisc < cutoff;
    const planStale = !hasPlan || planM < cutoff;
    return {
        objectApiName,
        hasDiscovery, hasPlan,
        discoveryUpdatedAt: hasDiscovery ? new Date(latestDisc).toISOString() : undefined,
        planUpdatedAt: hasPlan ? new Date(planM).toISOString() : undefined,
        discoveryStale, planStale,
        notes: []
    };
}
export async function startFromObject(repoDir, orgAlias, objectApiName, staleHours) {
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
export async function startFromLwc(repoDir, orgAlias, componentName, staleHours) {
    const idxPath = path.join(repoDir, '.artifacts', 'schema', 'schema_index.json');
    let candidates = [];
    try {
        const idx = await readJson(idxPath);
        const rec = idx?.components?.[componentName];
        if (rec && Array.isArray(rec.objects))
            candidates = rec.objects;
    }
    catch { }
    if (!candidates.length) {
        // Fallback: quick scan of the component bundle
        const compDir = path.join(repoDir, 'force-app', 'main', 'default', 'lwc', componentName);
        const { promises: fsp } = await import('fs');
        let files = [];
        try {
            files = (await fsp.readdir(compDir)).filter(f => f.endsWith('.js') || f.endsWith('.ts') || f.endsWith('.html'));
        }
        catch { }
        let src = '';
        for (const f of files) {
            try {
                src += '\n' + await fsp.readFile(path.join(compDir, f), 'utf8');
            }
            catch { }
        }
        const objects = new Set();
        const re = /@salesforce\/schema\/([A-Za-z0-9_]+(?:__c)?)(?:\.[A-Za-z0-9_]+(?:__c)?)?/g;
        let m;
        while ((m = re.exec(src)) !== null) {
            objects.add(m[1]);
        }
        candidates = Array.from(objects);
    }
    if (!candidates.length) {
        return { ok: false, reason: 'No schema imports found in component/index', componentName };
    }
    const results = [];
    for (const obj of candidates) {
        results.push(await startFromObject(repoDir, orgAlias, obj, staleHours));
    }
    return { ok: true, componentName, candidates, results };
}
export async function planningResume(repoDir, orgAlias, objectApiName, staleHours) {
    const status = await planningStatus(repoDir, objectApiName, staleHours);
    const cfg = await resolveProject(repoDir);
    const planPath = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'plan', `${objectApiName}.plan.json`);
    if (!status.hasPlan || status.planStale) {
        await discoveryPlan(repoDir, objectApiName);
    }
    await startFromObject(repoDir, orgAlias, objectApiName, staleHours);
    return { ok: true, planPath };
}
