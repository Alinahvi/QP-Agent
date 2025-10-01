import * as path from 'path';
import { trySh } from '../lib/exec.js';
import { ensureDir, writeJson } from '../lib/fsx.js';

export async function agentPreview(
  repoDir: string,
  orgAlias: string,
  agentApiName: string,
  clientApp: string,
  outputDir?: string,
  apexDebug?: boolean
) {
  if (!agentApiName) throw new Error('agentApiName is required');
  if (!clientApp) throw new Error('clientApp is required');

  const args = [
    'agent', 'preview',
    '--target-org', orgAlias,
    '--api-name', agentApiName,
    '--client-app', clientApp,
  ];
  const outDir = outputDir || path.join(repoDir, '.artifacts', 'agent', 'preview');
  args.push('--output-dir', outDir);
  if (apexDebug) args.push('--apex-debug');

  const out = await trySh('sf', args, repoDir);
  await ensureDir(outDir);
  const logPath = path.join(outDir, `preview-${Date.now()}.log.json`);
  await writeJson(logPath, { args, out });
  return { ok: true, outputDir: outDir, logPath };
}

