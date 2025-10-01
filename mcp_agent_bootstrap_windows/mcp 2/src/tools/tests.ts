/**
 * tests.ts decides which Apex tests to run and shells to sf apex run test; results are dropped under
 * .artifacts/apex so other steps can read coverage/status without re-querying the org.
 */import * as path from 'path';
import fs from 'fs-extra';
import { resolveProject } from '../lib/resolver.js';
import { apexRunSpecified, apexRunSuites } from '../lib/sf.js';

export async function testsApex(
  repoDir: string,
  orgAlias: string,
  mode: 'git-diff'|'suite'|'allowlist',
  fromRef: string,
  suiteNames: string | string[],
  allowlist: string | string[],
  waitSeconds=2400
) {
  const cfg = await resolveProject(repoDir);

  let classes: string[] = [];
  const suiteList = Array.isArray(suiteNames)
    ? suiteNames
    : (typeof suiteNames === 'string' && suiteNames.length ? suiteNames.split(',').map(s => s.trim()).filter(Boolean) : []);
  const allowList = Array.isArray(allowlist)
    ? allowlist
    : (typeof allowlist === 'string' && allowlist.length ? allowlist.split(',').map(s => s.trim()).filter(Boolean) : []);

  let ranSuites: string[] = [];
  let ranClasses: string[] = [];
  let out: string;

  if (mode === 'suite' && suiteList.length) {
    ranSuites = suiteList;
    out = await apexRunSuites(repoDir, orgAlias, suiteList, waitSeconds);
  } else {
    if (mode === 'allowlist' && allowList.length) {
      classes = allowList;
    } else if (mode === 'suite' && !suiteList.length) {
      classes = ['FR_Smoke'];
    } else if (!classes.length) {
      classes = ['FR_Smoke'];
    }
    ranClasses = classes;
    const toRun = classes.length ? classes : ['FR_Smoke'];
    out = await apexRunSpecified(repoDir, orgAlias, toRun, waitSeconds);
  }

  const artDir = path.join(repoDir, cfg.artifactsDir!, 'apex');
  await fs.ensureDir(artDir);
  await fs.writeFile(path.join(artDir,'apex_run.json'), out, 'utf8');
  return { ok: true, ran: ranSuites.length ? ranSuites : ranClasses, mode: ranSuites.length ? 'suite' : 'tests' };
}





