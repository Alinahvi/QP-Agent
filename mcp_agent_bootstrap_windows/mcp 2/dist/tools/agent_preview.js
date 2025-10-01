/**
 * agentPreview is a thin Salesforce CLI wrapper: it shells to 'sf agent preview' and logs both the
 * request and response under .artifacts/agent/preview so follow-on agents can inspect reproduction details.
 */
import * as path from 'path';
import { trySh } from '../lib/exec.js';
import { ensureDir, writeJson } from '../lib/fsx.js';
export async function agentPreview(repoDir, orgAlias, agentApiName, clientApp, outputDir, apexDebug) {
    if (!agentApiName)
        throw new Error('agentApiName is required');
    if (!clientApp)
        throw new Error('clientApp is required');
    const args = [
        'agent', 'preview',
        '--target-org', orgAlias,
        '--api-name', agentApiName,
        '--client-app', clientApp,
    ];
    const outDir = outputDir || path.join(repoDir, '.artifacts', 'agent', 'preview');
    args.push('--output-dir', outDir);
    if (apexDebug)
        args.push('--apex-debug');
    const out = await trySh('sf', args, repoDir);
    await ensureDir(outDir);
    const logPath = path.join(outDir, `preview-${Date.now()}.log.json`);
    await writeJson(logPath, { args, out });
    return { ok: true, outputDir: outDir, logPath };
}
