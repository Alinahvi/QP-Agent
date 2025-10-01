/**
 * Architecture utilities operate purely on local artifacts (no Salesforce calls) to translate discovery
 * outputs into human planning aids: centralView inventories Apex classes, impactMatrix summarizes discovery
 * metrics, proposePlans seeds Plan V2 JSON/Markdown, seedTickets emits follow-on tickets, and
 * normalizeDiscovery exists for migration hooks.
 */import * as path from 'path';
import { promises as fsp } from 'fs';
import { resolveProject } from '../lib/resolver.js';
import { ensureDir, readJson, writeJson, writeText } from '../lib/fsx.js';
import { validateJsonAgainstSchema, writeValidationReport } from '../lib/validate.js';

function discDir(repoDir: string, artifactsDir: string, obj: string) {
  return path.join(repoDir, artifactsDir || '.artifacts', 'discovery', obj);
}

async function exists(p: string) { try { await fsp.access(p); return true; } catch { return false; } }

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
      if (isHandler) inv.handlers.push({ file: p.replace(repoDir + path.sep, '') });
      if (isService) inv.services.push({ file: p.replace(repoDir + path.sep, '') });
      if (/@InvocableMethod\b/.test(src)) {
        const label = (src.match(/@InvocableMethod\(label='([^']+)'/i) || [])[1] || null;
        const desc  = (src.match(/@InvocableMethod\([^)]*description='([^']+)'/i) || [])[1] || null;
        inv.invocable.push({ file: p.replace(repoDir + path.sep, ''), label, description: desc });
      }
    }
  }
  const out = path.join(repoDir, 'docs','Architecture','Central_View.md');
  await ensureDir(path.dirname(out));
  const lines = ['# Centralized Action View','',
    '## Handlers', ...(inv.handlers.length ? inv.handlers.map((h:any)=>`- ${h.file}`) : ['(none)']),
    '', '## Services', ...(inv.services.length ? inv.services.map((s:any)=>`- ${s.file}`) : ['(none)']),
    '', '## Invocable Methods', ...(inv.invocable.length ? inv.invocable.map((i:any)=>`- ${i.label||'(no label)'} - ${i.file}`) : ['(none)'])];
  await writeText(out, lines.join('\n'));
  return { ok: true, out };
}

function normalizeObjectsArg(arg?: any): string[] | undefined {
  if (!arg) return undefined;
  if (Array.isArray(arg)) return arg.map((s:any)=>String(s).replace(/^['"]|['"]$/g,''));
  if (typeof arg === 'string') {
    const s = arg.trim();
    try { const arr = JSON.parse(s); if (Array.isArray(arr)) return arr.map((v:any)=>String(v).replace(/^['"]|['"]$/g,'')); } catch {}
    if (s.startsWith('[') && s.endsWith(']')) {
      const inner = s.slice(1, -1);
      const parts = inner
        .split(/[\s,]+/)
        .map(p => p.trim())
        .filter(Boolean)
        .map(p => p.replace(/^['"]|['"]$/g,''));
      if (parts.length) return parts;
    }
    if (s.includes(',')) {
      const parts = s.split(',').map(p => p.trim()).filter(Boolean).map(p => p.replace(/^['"]|['"]$/g,''));
      if (parts.length) return parts;
    }
    return [s.replace(/^['"]|['"]$/g,'')];
  }
  return undefined;
}

export async function impactMatrix(repoDir: string, objects?: string[]) {
  const cfg = await resolveProject(repoDir);
  const base = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'discovery');
  const normalized = normalizeObjectsArg(objects);
  let objs: string[] = [];
  try { objs = normalized && normalized.length ? normalized : (await fsp.readdir(base)).filter(n=>!n.startsWith('.')); } catch { objs = normalized || []; }
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
      activeVRs: (meta.validationRules || []).filter((v:any)=>v.active).length || 0,
      crud: perms.crud || {},
    });
  }
  const out = path.join(repoDir, 'docs','Architecture','Legacy_Impact.md');
  await ensureDir(path.dirname(out));
  const md = ['# Legacy Impact Matrix','',
    '| Object | Apex | Flows | LWCs | Triggers | Active VRs | CRUD |',
    '|---|---:|---:|---:|---:|---:|---|',
    ...rows.map(r=>`| ${r.object} | ${r.apexRefs} | ${r.flows} | ${r.lwcs} | ${r.triggers} | ${r.activeVRs} | ${JSON.stringify(r.crud)} |`)
  ].join('\n');
  await writeText(out, md);
  return { ok: true, out, count: rows.length };
}

export async function proposePlans(repoDir: string, objects?: string[]) {
  const cfg = await resolveProject(repoDir);
  const plansDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'plan');
  const docsDir = path.join(repoDir, 'docs','plan');
  await ensureDir(plansDir); await ensureDir(docsDir);
  const base = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'discovery');
  const normalized = normalizeObjectsArg(objects);
  let objs: string[] = [];
  try { objs = normalized && normalized.length ? normalized : (await fsp.readdir(base)).filter(n=>!n.startsWith('.')); } catch { objs = normalized || []; }
  const results: any[] = [];
  for (const obj of objs) {
    const ddir = discDir(repoDir, cfg.artifactsDir!, obj);
    const objP = path.join(ddir,'object.json');
    const permsP = path.join(ddir,'permissions.json');
    let meta: any = {}; let perms:any = {};
    try { meta = await readJson(objP); } catch {}
    try { perms = await readJson(permsP); } catch {}
    const allFields: string[] = Array.isArray(meta.fields) ? meta.fields.map((f:any)=>f.fullName||f.name||'').filter(Boolean) : [];
    const detail = allFields.filter(f=>!['Id','OwnerId','RecordTypeId','CreatedDate','CreatedById','LastModifiedDate','LastModifiedById','SystemModstamp'].includes(f));
    const upsert = detail;
    const plan = {
      objectApiName: obj,
      architecture: {
        templates: ['Generated_Handler_SingleOutput','Generated_Service_Dispatch','Generated_DTO'],
        outputContract: { name: `${(meta.label||obj).toString().replace(/__c$/,'')}Result`, version: '1.0' },
        inputs: [
          { key:'action', label:'Action', type:'string', required:true, description:'Create|Retrieve|Update|Delete|Search' },
          { key:'recordId', label:'Record Id', type:'Id', required:false, description:'For Retrieve/Update/Delete' },
          { key:'fieldsJson', label:'Fields (JSON)', type:'string', required:false, description:'Create/Update payload; only whitelisted fields applied' },
          { key:'searchQuery', label:'Search Query', type:'string', required:false, description:`Keyword(s) to search ${obj}` }
        ],
        helpers: ['AgentCore_Permissions','AgentCore_SafeQuery','DTO','Errors'],
        businessLogic: []
      },
      policy: {
        crud: perms.crud || { create:true, read:true, update:true, delete:false },
        fls: perms.fieldPermissions || {},
        customPermissions: perms.customPermissions || [],
        testBypass: true
      },
      dto: {
        detailFields: detail,
        upsertFields: upsert,
        search: { queryFields: detail.filter((f:string)=>!['Id','RecordTypeId'].includes(f)), defaultOrderBy:'CreatedDate DESC', limit:200 }
      },
      tests: { apex: ['FR_Smoke'], agent: [], smoke: ['FR_Smoke'] },
      meta: { generatedAt: new Date().toISOString() }
    };
    const planJson = path.join(plansDir, `${obj}.plan.v2.json`);
    await writeJson(planJson, plan);
    // Validate against Plan V2 schema if present
    const schemaPath = path.join(repoDir, 'mcp_planning_upgrade','specs','plan.schema.json');
    try {
      const res = await validateJsonAgainstSchema(planJson, schemaPath);
      await writeValidationReport(plansDir, `${obj}.plan.v2`, res);
    } catch {}
    const planMd = [
      `# Plan - ${obj}`,'',
      `- Output: ${plan.architecture.outputContract.name} v${plan.architecture.outputContract.version} (single-string JSON)`,
      `- Inputs: action, recordId, fieldsJson, searchQuery`,
      `- CRUD: ${JSON.stringify(plan.policy.crud)}`,
      `- DTO detail fields: ${plan.dto.detailFields.join(', ')}`,''].join('\n');
    await writeText(path.join(docsDir, `${obj}.Plan.md`), planMd);
    results.push({ object: obj, planJson });
  }
  return { ok: true, count: results.length, results };
}

export async function seedTickets(repoDir: string) {
  const cfg = await resolveProject(repoDir);
  const plansDir = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'plan');
  const outDir = path.join(repoDir, 'tickets','derived');
  await ensureDir(outDir);
  let files: string[] = [];
  try {
    const reObj = /^[A-Za-z][A-Za-z0-9_]*(__c)?\.plan\.v2\.json$/;
    files = (await fsp.readdir(plansDir))
      .filter(f => f.endsWith('.plan.v2.json') && !f.startsWith('validation-'))
      .filter(f => reObj.test(f));
  } catch { files = []; }
  const mk = (obj: string, id: string, title: string, runAgent=false) => `---\nid: ${obj}-${id}\npriority: P1\nobject: ${obj}\nsuite:\n  - FR_Smoke\nallowlist: []\nrunAgent: ${runAgent}\n---\n# ${title}\n\n**DoD**\n- Plan v2 present\n- Brief refreshed\n- CRUD/FLS enforced\n- Tests green\n`;
  const results: any[] = [];
  for (const f of files) {
    const obj = f.replace('.plan.v2.json','');
    const t1 = path.join(outDir, `${obj}-SCF-01.md`);
    const t2 = path.join(outDir, `${obj}-PERM-02.md`);
    const t3 = path.join(outDir, `${obj}-TEST-03.md`);
    await writeText(t1, mk(obj, 'SCF-01','Scaffold handler/service/DTO'));
    await writeText(t2, mk(obj, 'PERM-02','Wire CRUD/FLS gates'));
    await writeText(t3, mk(obj, 'TEST-03','Apex + agent (non-destructive) tests', true));
    results.push({ object: obj, tickets: [t1,t2,t3] });
  }
  return { ok: true, count: results.length, results };
}

export async function normalizeDiscovery(repoDir: string, sourceDir?: string) {
  return { ok: true, note: 'No-op: discovery already canonical. Add mappers if migrating from another layout.' };
}

