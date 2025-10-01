/**
 * schemaIndex scans the local LWC tree for @salesforce/schema imports, caching the mapping under
 * .artifacts/schema so discovery:start_from_lwc can infer object candidates without hitting the org.
 */ import * as path from 'path';
import fg from 'fast-glob';
import { ensureDir, writeJson, readJson } from '../lib/fsx.js';
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
export async function schemaIndex(repoDir, staleHours = 12) {
    const outDir = path.join(repoDir, '.artifacts', 'schema');
    const outPath = path.join(outDir, 'schema_index.json');
    // TTL: if index exists and newer than TTL, return it
    const idxMtime = await fileMtimeMs(outPath);
    const ttlCutoff = Date.now() - staleHours * 3600 * 1000;
    if (idxMtime && idxMtime > ttlCutoff) {
        const idx = await readJson(outPath).catch(() => null);
        if (idx)
            return { outPath, objectsCount: Object.keys(idx.objects || {}).length, componentsCount: Object.keys(idx.components || {}).length, cached: true };
    }
    const lwcRoot = path.join(repoDir, 'force-app', 'main', 'default', 'lwc');
    const compDirs = await fg('*/', { cwd: lwcRoot, onlyDirectories: true }).catch(() => []);
    const components = {};
    const objects = {};
    for (const comp of compDirs) {
        const compPath = path.join(lwcRoot, comp);
        const files = await fg(['**/*.js', '**/*.ts', '**/*.html'], { cwd: compPath, onlyFiles: true }).catch(() => []);
        const objSet = new Set();
        const fieldsByObject = {};
        for (const rel of files) {
            const abs = path.join(compPath, rel);
            const { promises: fsp } = await import('fs');
            let src = '';
            try {
                src = await fsp.readFile(abs, 'utf8');
            }
            catch {
                continue;
            }
            // Match @salesforce/schema/Object__c and @salesforce/schema/Object__c.Field__c
            const re = /@salesforce\/schema\/([A-Za-z0-9_]+(?:__c)?)(?:\.([A-Za-z0-9_]+(?:__c)?))?/g;
            let m;
            while ((m = re.exec(src)) !== null) {
                const obj = m[1];
                const field = m[2];
                objSet.add(obj);
                if (field) {
                    const arr = (fieldsByObject[obj] ||= []);
                    if (!arr.includes(field))
                        arr.push(field);
                }
            }
        }
        const objectsArr = Array.from(objSet);
        components[comp.replace(/\/$/, '')] = {
            files: files.map(f => path.join('force-app', 'main', 'default', 'lwc', comp, f).replace(/\\/g, '/')),
            objects: objectsArr,
            fieldsByObject,
        };
        for (const obj of objectsArr) {
            const entry = (objects[obj] ||= { components: [], fields: [], count: 0 });
            entry.count++;
            if (!entry.components.includes(comp.replace(/\/$/, '')))
                entry.components.push(comp.replace(/\/$/, ''));
            const fields = fieldsByObject[obj] || [];
            for (const f of fields)
                if (!entry.fields.includes(f))
                    entry.fields.push(f);
        }
    }
    await ensureDir(outDir);
    const index = { generatedAt: new Date().toISOString(), components, objects };
    await writeJson(outPath, index);
    return { outPath, objectsCount: Object.keys(objects).length, componentsCount: Object.keys(components).length, cached: false };
}
