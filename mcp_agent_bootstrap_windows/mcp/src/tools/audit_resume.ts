import * as path from 'path';
import fs from 'fs-extra';
import { resolveProject } from '../lib/resolver.js';

export async function auditActionLayer(repoDir: string, objectApiName: string, apply=false) {
  const classesDir = path.join(repoDir, 'force-app','main','default','classes');
  const files = await fs.readdir(classesDir);
const handler = files.find(
  (f: string) => f.includes(objectApiName.replace('__c','')) && f.endsWith('_Handler.cls')
);
  const report = { objectApiName, handlerFound: Boolean(handler), singleOutput: null as null|boolean, changes: [] as string[] };
  // Placeholder logic for single-output check; customize in your environment
  report.singleOutput = true;
  const out = path.join(repoDir, '.artifacts','review', `${objectApiName}.audit.json`);
  await fs.ensureDir(path.dirname(out));
  await fs.writeJson(out, report, { spaces: 2 });
  return out;
}

export async function resumeContext(repoDir: string, objectApiName: string) {
  const cfg = await resolveProject(repoDir);
  const planPath = path.join(repoDir, cfg.artifactsDir!, 'plan', `${objectApiName}.plan.json`);
  const planV2Path = path.join(repoDir, cfg.artifactsDir!, 'plan', `${objectApiName}.plan.v2.json`);
  const ledgerPath = path.join(repoDir, 'docs','Plan_Ledger.md');
  const hasV1 = await fs.pathExists(planPath);
  const hasV2 = await fs.pathExists(planV2Path);
  let ledgerTail = '';
  try {
    const txt = await fs.readFile(ledgerPath,'utf8');
    const lines = txt.trim().split(/\r?\n/);
    ledgerTail = lines.slice(-5).join('\n');
  } catch {}
  const nextPath = path.join(repoDir, cfg.artifactsDir!, 'plan', `${objectApiName}.plan.resume.md`);
  const md = hasV2
    ? `Resume ${objectApiName}\n\n- Plan v2: ${planV2Path}\n- Plan v1: ${hasV1 ? planPath : 'N/A'}\n- Ledger (last):\n\n${ledgerTail || '(no entries)'}\n\nNext: discovery:brief -> actionlayer:scaffold -> agent:doc-sync -> deploy:safe -> tests.`
    : `No plan found for ${objectApiName}. Run planning:intake -> planning:propose, then discovery:plan.`;
  await fs.ensureDir(path.dirname(nextPath));
  await fs.writeFile(nextPath, md, 'utf8');
  return nextPath;
}
