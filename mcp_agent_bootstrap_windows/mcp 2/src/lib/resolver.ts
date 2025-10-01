import * as path from 'path';
import { readJson } from './fsx.js';

export type ProjectConfig = {
  projectId?: string;
  defaultOrgAlias?: string;
  searchRoots?: string[];
  artifactsDir?: string;
  deploy?: { manifest?: string };
  apex?: { strategy?: 'git-diff'|'suite'|'allowlist', fromRef?: string, suiteNames?: string[], allowlist?: string[] };
  agent?: { enabled?: boolean, definitionApiName?: string, specPath?: string, resultFormat?: 'junit'|'json'|'tap', artifactDir?: string };
}

export async function resolveProject(repoDir: string): Promise<ProjectConfig> {
  // precedence: .mcp.project.json -> sfdx-project.json partials -> defaults
  const cfgPath = path.join(repoDir, '.mcp.project.json');
  let cfg: ProjectConfig = {};
  try { cfg = await readJson(cfgPath); } catch {}
  if (!cfg.artifactsDir) cfg.artifactsDir = '.artifacts';
  if (!cfg.searchRoots) cfg.searchRoots = ['force-app/main/default/classes','force-app/main/default/triggers'];
  if (!cfg.apex) cfg.apex = { strategy: 'suite', fromRef: undefined as any, suiteNames: ['FR_Smoke'], allowlist: [] } as any;
  if (!cfg.agent) cfg.agent = { enabled: false, resultFormat: 'junit', artifactDir: '.artifacts/agent' };
  return cfg;
}
