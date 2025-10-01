import { sh, trySh } from './exec.js';
/**
 * Return current branch, cleanliness, and ahead/behind vs upstream.
 */
export async function status(repoDir) {
    const branchOut = await sh('git', ['rev-parse', '--abbrev-ref', 'HEAD'], repoDir);
    const branch = branchOut.trim();
    const porcelain = (await sh('git', ['status', '--porcelain=v1'], repoDir)).trim();
    const clean = porcelain.length === 0;
    let ahead = 0;
    let behind = 0;
    try {
        // "<behind>\t<ahead>"
        const counts = (await sh('git', ['rev-list', '--left-right', '--count', '@{u}...HEAD'], repoDir))
            .trim()
            .split('\t');
        behind = parseInt(counts[0] || '0', 10);
        ahead = parseInt(counts[1] || '0', 10);
    }
    catch {
        // no upstream; leave ahead/behind at 0
    }
    return { branch, clean, ahead, behind };
}
/**
 * List changed paths between two refs (default HEAD), optionally empty if no diff.
 */
export async function diffPaths(repoDir, fromRef, toRef = 'HEAD') {
    const out = await trySh('git', ['diff', '--name-only', `${fromRef}..${toRef}`], repoDir);
    return out
        .split('\n')
        .map((s) => s.trim())
        .filter(Boolean);
}
