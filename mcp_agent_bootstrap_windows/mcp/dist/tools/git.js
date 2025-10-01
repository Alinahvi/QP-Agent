import { status, diffPaths } from '../lib/git.js';
import * as path from 'path';
import fs from 'fs-extra';
export async function gitPreflight(repoDir) {
    try {
        const s = await status(repoDir);
        const ok = s.clean && !['main'].includes(s.branch);
        return { ok, branch: s.branch, clean: s.clean, ahead: s.ahead, behind: s.behind };
    }
    catch {
        return { ok: true, branch: 'unknown', clean: true, ahead: 0, behind: 0 };
    }
}
export async function gitDiffPlan(repoDir, fromRef, toRef = 'HEAD', filterRoots = []) {
    const paths = await diffPaths(repoDir, fromRef, toRef);
    const roots = Array.isArray(filterRoots)
        ? filterRoots
        : (typeof filterRoots === 'string' && filterRoots.length
            ? String(filterRoots).split(',').map(s => s.trim()).filter(Boolean)
            : []);
    const filtered = roots.length
        ? paths.filter((p) => roots.some((fr) => p.startsWith(fr)))
        : paths;
    const out = { fromRef, toRef, filtered };
    const outPath = path.join(repoDir, '.artifacts', 'git', 'diff_plan.json');
    await fs.ensureDir(path.dirname(outPath));
    await fs.writeJson(outPath, out, { spaces: 2 });
    return outPath;
}
