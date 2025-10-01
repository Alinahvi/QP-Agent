/**
 * Agent tooling lives entirely as local wrappers that either log sync work or call the Salesforce CLI via lib/sf.
 * - agentDocSync writes a local artifact (no org IO) placeholder until a concrete sync path is implemented.
 * - testsAgent shells to sf agent:test via agentRun and parks the raw response under the configured artifacts dir.
 */
import * as path from 'path';
import fs from 'fs-extra';
import { resolveProject } from '../lib/resolver.js';
import { agentRun } from '../lib/sf.js';

export async function agentDocSync(repoDir: string, orgAlias: string, objectApiName: string) {
  // Placeholder: in practice read handler annotations and write genAiFunctions/Plugins metadata
  const logPath = path.join(repoDir, '.artifacts','review', `${objectApiName}.docsync.log`);
  await fs.ensureDir(path.dirname(logPath));
  await fs.writeFile(logPath, `Synced docs for ${objectApiName} at ${new Date().toISOString()}`, 'utf8');
  return logPath;
}

export async function testsAgent(repoDir: string, orgAlias: string, waitMinutes=15) {
  const out = await agentRun(repoDir, orgAlias, undefined, waitMinutes);
  const cfg = await resolveProject(repoDir);
  const dir = path.join(repoDir, cfg.agent?.artifactDir || '.artifacts/agent');
  await fs.ensureDir(dir);
  await fs.writeFile(path.join(dir,'agent_run.json'), out, 'utf8');
  return { ok: true };
}
