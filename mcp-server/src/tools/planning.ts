/**
 * planning.ts turns discovery artifacts (local JSON) into structured planning deliverables: intake parses
 * requirements docs, propose builds Plan V2 + docs + ADR/ledger notes, ticketize emits derived work items,
 * and verify cross-checks plan CRUD/FLS against discovery findings.
 */import * as path from 'path';
import fs from 'fs-extra';
import { ensureDir, writeJson, readJson, writeText, exists } from '../lib/fsx.js';
import { validateJsonAgainstSchema, writeValidationReport } from '../lib/validate.js';

type Intake = {
  objectApiName: string;
  goals: string[];
  constraints: string[];
  requirements: string[];
  notes?: string[];
};

export async function planningIntake(repoDir: string, objectApiName: string, requirementsPath?: string) {
  const outDir = path.join(repoDir, '.artifacts', 'planning', objectApiName);
  await ensureDir(outDir);
  const sources: string[] = [];
  const lines: string[] = [];
  const candidates = requirementsPath
    ? [requirementsPath]
    : [
        path.join(repoDir, 'docs', 'ActionPlan.md'),
        path.join(repoDir, 'tickets'),
      ];
  for (const c of candidates) {
    try {
      const stat = await fs.stat(c).catch(()=>null);
      if (!stat) continue;
      if (stat.isDirectory()) {
        const files = await fs.readdir(c);
        for (const f of files) {
          if (!/\.md$/i.test(f)) continue;
          const p = path.join(c, f);
          const txt = await fs.readFile(p, 'utf8');
          sources.push(p); lines.push(txt);
        }
      } else {
        const txt = await fs.readFile(c, 'utf8');
        sources.push(c); lines.push(txt);
      }
    } catch {}
  }
  const body = lines.join('\n');
  const pick = (re: RegExp) => Array.from(body.matchAll(re)).map(m => (m[1] || m[0]).trim());
  const goals = pick(/^\s*-\s*(?:Goal:)?\s*(.+)$/gmi).slice(0, 20);
  const constraints = pick(/^\s*-\s*(?:Constraint:)?\s*(.+)$/gmi).slice(0, 20);
  const requirements = pick(/^\s*-\s*(?:Requirement:)?\s*(.+)$/gmi).slice(0, 50);
  const intake: Intake = { objectApiName, goals, constraints, requirements };
  const outPath = path.join(outDir, 'intake.json');
  await writeJson(outPath, intake);
  return { intakePath: outPath, sources };
}

export async function planningPropose(repoDir: string, objectApiName: string) {
  const discDir = path.join(repoDir, '.artifacts', 'discovery', objectApiName);
  const planDir = path.join(repoDir, '.artifacts', 'plan');
  await ensureDir(planDir);
  const objPath = path.join(discDir, 'object.json');
  const usagePath = path.join(discDir, 'usage.json');
  const permsPath = path.join(discDir, 'permissions.json');
  const obj = (await exists(objPath)) ? await readJson<any>(objPath) : { objectApiName, label: objectApiName };
  const usage = (await exists(usagePath)) ? await readJson<any>(usagePath) : { apex:[], flows:[], lwcs:[] };
  const perms = (await exists(permsPath)) ? await readJson<any>(permsPath) : { crud:{}, fieldPermissions:{} };

  // Load intake if exists
  const intakePath = path.join(repoDir, '.artifacts','planning', objectApiName, 'intake.json');
  const intake = (await exists(intakePath)) ? await readJson<Intake>(intakePath) : { objectApiName, goals:[], constraints:[], requirements:[] };

  const impactedApex = (usage.apex || []).map((a:any) => a.name).filter((v:string)=>!!v).slice(0,25);
  // derive inputs from fields & VRs
  const deriveInputs = () => {
    const inputs: any[] = [];
    inputs.push({ key: 'recordId', label: 'Record Id', type: 'Id', description: 'Target record Id for retrieve/update/delete.' });
    const fields: any[] = Array.isArray(obj.fields) ? obj.fields : [];
    const required = fields.filter(f => f && f.required && !/^(AutoNumber|Formula)$/i.test(String(f.type||'')));
    for (const f of required.slice(0, 30)) {
      inputs.push({ key: f.fullName, label: f.label || f.fullName, type: f.type || 'Text', required: true, description: `Required field for ${objectApiName}` });
    }
    // search inputs
    inputs.push({ key: 'searchQuery', label: 'Search Query', type: 'String', description: `Filter ${objectApiName} by keyword` });
    return inputs;
  };
  const v2 = {
    objectApiName,
    architecture: {
      templates: ['Generated_Handler_SingleOutput','Generated_Service_Dispatch','Generated_DTO'],
      outputContract: { name: `${(obj.label||objectApiName).replace(/__c$/,'')}Result`, version: '1.0' },
      inputs: deriveInputs(),
      helpers: ['AgentCore_Permissions','AgentCore_SafeQuery','DTO','Errors'],
      businessLogic: intake.requirements.slice(0,10),
    },
    policy: {
      crud: perms.crud || {},
      fls: perms.fieldPermissions || {},
      customPermissions: perms.customPermissions || [],
      testBypass: true,
    },
    tests: {
      apex: impactedApex.length ? impactedApex : ['FR_Smoke'],
      agent: [],
      smoke: ['FR_Smoke']
    },
    tickets: [
      { key: 'DISCOVERY', title: `Review discovery for ${objectApiName}`, status: 'OPEN' },
      { key: 'SCAFFOLD', title: `Scaffold action layer for ${objectApiName}`, status: 'OPEN' }
    ]
  } as any;
  const v2Path = path.join(planDir, `${objectApiName}.plan.v2.json`);
  await writeJson(v2Path, v2);

  // Validate against schema
  const schemaPlan = path.join(repoDir, 'mcp_planning_upgrade','specs','plan.schema.json');
  if (await exists(schemaPlan)) {
    const res = await validateJsonAgainstSchema(v2Path, schemaPlan);
    await writeValidationReport(planDir, 'plan.v2', res);
  }

  // Render human doc
  const tplPath = path.join(repoDir, 'mcp_planning_upgrade','docs','Architecture','Plan_Template.md');
  const planDocDir = path.join(repoDir, 'docs','plan');
  await ensureDir(planDocDir);
  const docOut = path.join(planDocDir, `${objectApiName}.Plan.md`);
  let tpl = '';
  try { tpl = await fs.readFile(tplPath, 'utf8'); } catch {}
  const checklist = [
    'planning:verify is OK (CRUD/FLS aligned)',
    'Apex compile & LWC/Flow bundle integrity OK',
    'Org prerequisites: custom perms, record types visible, user seeds',
    'Smoke CRUD via handler returns stable codes (OK/INVALID_INPUT/PERMISSION_DENIED/FLS_DENIED)',
    'Permission gates deny as expected; TEST_BYPASS positive path OK',
    'RecordType rules & picklists validated',
    'Flow elements (create/update/lookup/delete) succeed; no unhandled faults',
    'Related triggers/LWCs show no errors in logs/UI sanity',
    'Non-functional: time budgets/governor headroom OK',
    'Logging includes traceIds and action keys',
    'Rollback/recovery plan documented',
  ];
  const md = `${tpl || '# Plan'}\n\n`+
    `Object: ${objectApiName} (${obj.label||objectApiName})\n\n`+
    `- Goals: ${intake.goals.join('; ') || '-'}\n`+
    `- Constraints: ${intake.constraints.join('; ') || '-'}\n`+
    `- CRUD: ${JSON.stringify(v2.policy.crud)}\n`+
    `- Fields: ${(obj.fields||[]).length}\n`+
    `- VRs: ${(obj.validationRules||[]).length}\n\n`+
    `## Regression Checklist\n`+
    checklist.map(i=>`- [ ] ${i}`).join('\n') + '\n';
  await writeText(docOut, md);

  // Update ledger
  const ledger = path.join(repoDir, 'docs','Plan_Ledger.md');
  const stamp = new Date().toISOString();
  await fs.ensureFile(ledger);
  const prev = await fs.readFile(ledger, 'utf8').catch(()=> '# Plan Ledger\n');
  // Create ADR entry
  const adrsDir = path.join(repoDir, 'docs','ADRs');
  await ensureDir(adrsDir);
  const { promises: fsp } = await import('fs');
  let nextAdr = 1;
  try {
    const files = await fsp.readdir(adrsDir);
    const nums = files.map(f => (f.match(/^ADR-(\d+)\b/)||[])[1]).filter(Boolean).map(n=>parseInt(n,10));
    if (nums.length) nextAdr = Math.max(...nums)+1;
  } catch {}
  const pad = (n:number)=> String(n).padStart(3,'0');
  const adrTitle = `ADR-${pad(nextAdr)}: Plan V2 updated for ${objectApiName}`;
  const adrFile = path.join(adrsDir, `ADR-${pad(nextAdr)}-${objectApiName}.md`);
  const briefRel = path.join('docs','discovery', `${objectApiName}.DiscoveryBrief.md`).replace(/\\/g,'/');
  const adrMd = `# ${adrTitle}\n\nStatus: Accepted\n\nDate: ${stamp}\n\n## Context\nPlan V2 updated for ${objectApiName} using no-git orchestrators. Inputs derived from required fields; tests seeded from usage.\n\n## Decision\nAdopt Plan V2 per schema; document regression checklist; continue no-git planning/execute loop.\n\n## Consequences\n- Portable runs (local + org only)\n- Stable artifacts (validated)\n- Human-friendly brief and plan docs\n\n## Links\n- Plan V2: ${path.relative(repoDir, v2Path).replace(/\\/g,'/')}\n- Plan Doc: ${path.relative(repoDir, docOut).replace(/\\/g,'/')}\n- Brief: ${briefRel}\n`;
  await writeText(adrFile, adrMd);
  const line = `- ${stamp} ${adrTitle} — plan: ${path.relative(repoDir, v2Path).replace(/\\/g,'/')}`;
  await writeText(ledger, prev.trim() + '\n' + line + '\n');

  // Session log
  const sessionLog = path.join(repoDir, 'docs','Session_Log.md');
  const logLine = `- ${stamp} planning:propose for ${objectApiName} -> ${path.relative(repoDir, v2Path).replace(/\\/g,'/')}`;
  const old = await fs.readFile(sessionLog,'utf8').catch(()=> '# Session Log\n');
  await writeText(sessionLog, old.trim() + '\n' + logLine + '\n');

  return { planV2: v2Path, doc: docOut, ledger };
}

export async function planningTicketize(repoDir: string, objectApiName: string) {
  const v2Path = path.join(repoDir, '.artifacts','plan', `${objectApiName}.plan.v2.json`);
  const plan = await readJson<any>(v2Path);
  const outDir = path.join(repoDir, 'tickets','derived');
  await ensureDir(outDir);
  const written: string[] = [];
  (plan.tickets || []).forEach((t:any, idx:number) => {
    const slug = (t.key || `T${idx+1}`) + '-' + (t.title || 'item').replace(/[^A-Za-z0-9]+/g,'-').slice(0,40);
    const p = path.join(outDir, `${objectApiName}-${slug}.md`);
    const md = `# ${t.title || 'Work Item'}\n\nObject: ${objectApiName}\n\nStatus: ${t.status || 'OPEN'}\n\nDoD/AC:\n- [ ] Implement\n- [ ] Validate\n`;
    written.push(p);
    fs.writeFileSync(p, md, 'utf8');
  });
  return { written };
}

export async function planningVerify(repoDir: string, objectApiName: string) {
  const planV2Path = path.join(repoDir, '.artifacts','plan', `${objectApiName}.plan.v2.json`);
  const discDir = path.join(repoDir, '.artifacts','discovery', objectApiName);
  const verifyPath = path.join(repoDir, '.artifacts','plan', `${objectApiName}.verify.json`);
  const result = { ok: true, mismatches: [] as string[], details: {} as any };
  try {
    const plan = await readJson<any>(planV2Path);
    const obj = await readJson<any>(path.join(discDir,'object.json'));
    const perms = await readJson<any>(path.join(discDir,'permissions.json'));
    if (!obj.fields || obj.fields.length === 0) {
      result.ok = false; result.mismatches.push('No fields found in discovery object.json');
    }
    if (JSON.stringify((plan.policy?.crud)||{}) !== JSON.stringify((perms.crud)||{})) {
      result.ok = false; result.mismatches.push('Plan policy.crud differs from discovery permissions.crud');
    }
    // required fields must be readable; report any missing FLS
    const req = (obj.fields || []).filter((f:any)=> f.required);
    const missingFls = req.filter((f:any)=> !(perms.fieldPermissions||{})[f.fullName]?.readable);
    if (missingFls.length) {
      result.ok = false; result.mismatches.push(`Required fields without readable FLS: ${missingFls.map((f:any)=>f.fullName).join(', ')}`);
    }
    result.details = {
      fields: obj.fields?.length || 0,
      recordTypes: obj.recordTypes?.length || 0,
      vrCount: obj.validationRules?.length || 0,
      flsEntries: Object.keys(perms.fieldPermissions||{}).length,
    };
  } catch (e:any) {
    result.ok = false; result.mismatches.push('Missing plan or discovery artifacts');
  }
  await writeJson(verifyPath, result);
  return { verifyPath, ok: result.ok };
}

