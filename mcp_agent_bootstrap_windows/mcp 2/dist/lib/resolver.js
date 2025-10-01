import * as path from 'path';
import { readJson } from './fsx.js';
export async function resolveProject(repoDir) {
    // precedence: .mcp.project.json -> sfdx-project.json partials -> defaults
    const cfgPath = path.join(repoDir, '.mcp.project.json');
    let cfg = {};
    try {
        cfg = await readJson(cfgPath);
    }
    catch { }
    if (!cfg.artifactsDir)
        cfg.artifactsDir = '.artifacts';
    if (!cfg.searchRoots)
        cfg.searchRoots = ['force-app/main/default/classes', 'force-app/main/default/triggers'];
    if (!cfg.apex)
        cfg.apex = { strategy: 'suite', fromRef: undefined, suiteNames: ['FR_Smoke'], allowlist: [] };
    if (!cfg.agent)
        cfg.agent = { enabled: false, resultFormat: 'junit', artifactDir: '.artifacts/agent' };
    return cfg;
}
