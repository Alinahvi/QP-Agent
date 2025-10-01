import * as path from 'path';
import { promises as fsp } from 'fs';
import pLimit from 'p-limit';
import { resolveProject } from '../lib/resolver.js';
import { ensureDir, readJson, writeJson, writeText } from '../lib/fsx.js';

/** Canonical discovery layout we expect */
function discDir(repoDir: string, artifactsDir: string, obj: string) {
  return path.join(repoDir, artifactsDir || '.artifacts', 'discovery', obj);
}

async function exists(p: string) { try { await fsp.access(p); return true; } catch { return false; } }

/** architect:central_view — inventory existing handlers/services/actions */
export async function centralView(repoDir: string) {
  const cfg = await resolveProject(repoDir);
  const roots = cfg.searchRoots || ['force-app/main/default/classes'];
  const inv: any = { handlers: [], services: [], invocable: [] };

  for (const r of roots) {
    const base = path.join(repoDir, r);
    let files: string[] = [];
    try { files = (await fsp.readdir(base)).filter(f=>f.endsWith('.cls')); } catch { continue; }
    for (const f of files) {
      const p = path.join(base, f);
      let src = ''; try { src = await fsp.readFile(p,'utf8'); } catch {}
      const isHandler = /class\s+\w+Handler\b/.test(src);
      const isService = /class\s+\w+Service\b/.test(src);
      if (isHandler) inv.handlers.push({ file: p });
      if (isService) inv.services.push({ file: p });
      if (/@InvocableMethod\b/.test(src)) {
        // Attempt to extract label/description
        const label = (src.match(/@InvocableMethod\(label='([^']+)'/i) || [])[1] || null;
        const desc  = (src.match(/@InvocableMethod\([^)]*description='([^']+)'/i) || [])[1] || null;
        inv.invocable.push({ file: p, label, description: desc });
      }
    }
  }

  const out = path.join(repoDir, 'docs','Architecture','Central_View.md');
  await ensureDir(path.dirname(out));
  const lines = ['# Centralized Action View', '', '## Handlers', ...inv.handlers.map((h:any)=>`- ${h.file}`),
                 '', '## Services', ...inv.services.map((s:any)=>`- ${s.file}`),
                 '', '## Invocable Methods', ...inv.invocable.map((i:any)=>`- ${i.label||'(no label)'} — ${i.file}`)];
  await writeText(out, lines.join('\n'));
  return { ok: true, out };
}

/** architect:impact_matrix — summarize legacy impact from discovery + repo */
export async function impactMatrix(repoDir: string, objects?: string[]) {
  const cfg = await resolveProject(repoDir);
  // infer objects by scanning discovery folder
  const base = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'discovery');
  let objs: string[] = [];
  try {
    objs = objects && objects.length ? objects : (await fsp.readdir(base)).filter(n=>!n.startsWith('.'));
  } catch { objs = objects || []; }

  const rows: any[] = [];
  for (const obj of objs) {
    const ddir = discDir(repoDir, cfg.artifactsDir!, obj);
    const usageP = path.join(ddir,'usage.json');
    const objP = path.join(ddir,'object.json');
    const permsP = path.join(ddir,'permissions.json');
    let usage: any = {}, meta: any = {}, perms: any = {};
    try { usage = await readJson(usageP); } catch {}
    try { meta = await readJson(objP); } catch {}
    try { perms = await readJson(permsP); } catch {}
    rows.push({
      object: obj,
      apexRefs: (usage.apex || []).length || 0,
      flows: (usage.flows || []).length || 0,
      lwcs: (usage.lwcs || []).length || 0,
      triggers: (meta.triggers || []).length || 0,
      vrules: (meta.validationRules || []).length || 0,
      crud: perms.crud || perms.CRUD || {}
    });
  }

  const out = path.join(repoDir, 'docs','Architecture','Legacy_Impact.md');
  await ensureDir(path.dirname(out));
  const md = ['# Legacy Impact Matrix','','| Object | Apex | Flows | LWCs | Triggers | VRules | CRUD |','|---|---:|---:|---:|---:|---:|---|',
    *[ `| ${r.object} | ${r.apexRefs} | ${r.flows} | ${r.lwcs} | ${r.triggers} | ${r.vrules} | ${JSON.stringify(r.crud)} |` for (r of rows as any[]) ]
  ].join('\n');
  await writeText(out, md);
  return { ok: true, out, count: rows.length };
}

/** architect:propose_plans — turn discovery → Plan v2 artifacts */
export async function proposePlans(repoDir: string, objects?: string[]) {
  const cfg = await resolveProject(repoDir);
  const base = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'discovery');
  let objs: string[] = [];
  try {
    objs = objects && objects.length ? objects : (await fsp.readdir(base)).filter(n=>!n.startsWith('.'));
  } catch { objs = objects || []; }

  const plansDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'plan');
  await ensureDir(plansDir);
  const docsDir = path.join(repoDir, 'docs');

  function pickFields(fields: any[], count=8): string[] {
    const names: string[] = [];
    const by: Record<string,any> = {};
    for (const f of fields||[]) {
      const k = f.fullName || f.QualifiedApiName || f.apiName || f.name || '';
      if (k) by[k] = f;
    }
    const add = (n: string) => { if (by[n] && !names.includes(n)) names.push(n); };
    add('Name'); ['CreatedDate','CreatedById','LastModifiedDate','LastModifiedById','OwnerId','RecordTypeId'].forEach(add);
    for (const k of Object.keys(by)) { if (names.length>=count) break; if (!names.includes(k)) names.push(k); }
    return names.slice(0,count);
  }

  const results: any[] = [];
  for (const obj of objs) {
    const ddir = discDir(repoDir, cfg.artifactsDir!, obj);
    const objP = path.join(ddir,'object.json');
    const permsP = path.join(ddir,'permissions.json');
    let meta: any = {}; let perms: any = {};
    try { meta = await readJson(objP); } catch {}
    try { perms = await readJson(permsP); } catch {}

    const fields = meta.fields || [];
    const detail = pickFields(fields, 10);
    const upsert = detail.filter((f:string)=>!['Id','CreatedDate','CreatedById','LastModifiedDate','LastModifiedById'].includes(f));

    const plan = {
      objectApiName: obj,
      architecture: {
        templates: ['HandlerInvocableSingleOutput','Service','DTO'],
        outputContract: { contractName: `${obj}ActionEnvelope`, version: '1.0' },
        inputs: [
          { name:'action', type:'string', required:true, label:'Action', description:'Create|Retrieve|Update|Delete|Search' },
          { name:'recordId', type:'Id', required:false, label:'Record Id', description:'For Retrieve/Update/Delete' },
          { name:'fieldsJson', type:'string', required:false, label:'Fields (JSON)', description:'Create/Update payload; only whitelisted fields applied' },
          { name:'searchQuery', type:'string', required:false, label:'Search Query', description:`Keyword(s) to search ${obj}` }
        ],
        helpers: ['AgentCore_Permissions','AgentCore_QueryBuilder','AgentCore_DTO','AgentCore_Errors'],
        businessLogic: []
      },
      policy: {
        crud: perms.crud || { create:true, read:true, update:true, delete:false },
        fls: { readWhitelist: detail, updateWhitelist: upsert.filter((f:string)=>f!=='Id') },
        customPermissions: [],
        testBypass: false
      },
      dto: {
        detailFields: detail,
        upsertFields: upsert.filter((f:string)=>f!=='Id'),
        search: { queryFields: detail.filter((f:string)=>!['Id','RecordTypeId'].includes(f)), defaultOrderBy:'CreatedDate DESC', limit:200 }
      },
      tests: { apex: [], agent: ['Non-destructive retrieve/search'], smoke: ['FR_Smoke'] },
      meta: { generatedAt: new Date().toISOString() }
    };

    const planJson = path.join(plansDir, `${obj}.plan.v2.json`);
    await writeJson(planJson, plan);

    const planMd = [
      `# Plan — ${obj}`, '',
      `- Output: ${plan.architecture.outputContract.contractName} v1.0 (single-string JSON)`,
      `- Inputs: action, recordId, fieldsJson, searchQuery`,
      `- CRUD: ${JSON.stringify(plan.policy.crud)}`,
      `- DTO detail fields: ${plan.dto.detailFields.join(', ')}`,
      ''
    ].join('\n');
    await ensureDir(docsDir);
    await writeText(path.join(docsDir, `${obj}.Plan.md`), planMd);

    results.push({ object: obj, planJson });
  }
  return { ok: true, count: results.length, results };
}

/** architect:seed_tickets — create derived tickets from Plan v2 */
export async function seedTickets(repoDir: string) {
  const cfg = await resolveProject(repoDir);
  const plansDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'plan');
  const outDir = path.join(repoDir, 'tickets','derived');
  await ensureDir(outDir);

  let files: string[] = [];
  try { files = (await fsp.readdir(plansDir)).filter(f=>f.endsWith('.plan.v2.json')); } catch { files = []; }

  const mk = (obj: string, id: string, title: string, runAgent=false) => `---\nid: ${obj}-${id}\npriority: P1\nobject: ${obj}\nsuite:\n  - FR_Smoke\nallowlist: []\nrunAgent: ${str(runAgent).lower()}\n---\n# ${title}\n\n**DoD**\n- Plan v2 present\n- Brief refreshed\n- CRUD/FLS enforced\n- Tests green\n`;

  const results: any[] = [];
  for (const f of files) {
    const obj = f.replace('.plan.v2.json','');
    const t1 = path.join(outDir, f'{obj}-SCF-01.md');
    const t2 = path.join(outDir, f'{obj}-PERM-02.md');
    const t3 = path.join(outDir, f'{obj}-TEST-03.md');
    await writeText(t1, mk(obj, 'SCF-01','Scaffold handler/service/DTO'));
    await writeText(t2, mk(obj, 'PERM-02','Wire CRUD/FLS gates'));
    await writeText(t3, mk(obj, 'TEST-03','Apex + agent (non-destructive) tests', True));
    results.push({ object: obj, tickets: [t1,t2,t3] });
  }
  return { ok: true, count: results.length, results };
}

/** architect:normalize_discovery — map non-canonical outputs into object/usage/permissions */
export async function normalizeDiscovery(repoDir: string, sourceDir?: string) {
  // Stub: copy/transform into .artifacts/discovery/<obj>/*.json if your prior discovery differed.
  // You can add custom mappers here later.
  return { ok: true, note: 'No-op: supply a mapper if your discovery layout is not canonical.' };
}
