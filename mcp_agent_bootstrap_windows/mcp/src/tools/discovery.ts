import * as path from 'path';
import fg from 'fast-glob';
import { resolveProject } from '../lib/resolver.js';
import { renderToFile } from '../lib/templates.js';
import { ensureDir, writeJson, writeText, readJson, readText, exists } from '../lib/fsx.js';
import { dataQuery, toolingQuery, sfAvailable } from '../lib/sf.js';
import { validateJsonAgainstSchema, writeValidationReport } from '../lib/validate.js';

export async function orgDiscoverObject(repoDir: string, orgAlias: string, objectApiName: string) {
  const cfg = await resolveProject(repoDir);
  const outDir = path.join(repoDir, cfg.artifactsDir!, 'discovery', objectApiName);
  await ensureDir(outDir);

  // Helpers
  const getTag = (xml: string, tag: string) => {
    const m = xml.match(new RegExp(`<${tag}>\\s*([\\s\\S]*?)\\s*<\\/${tag}>`, 'i'));
    return m ? m[1].trim() : '';
  };
  const getTags = (xml: string, tag: string) => Array.from(xml.matchAll(new RegExp(`<${tag}>\\s*([\\s\\S]*?)\\s*<\\/${tag}>`, 'gi'))).map(m=>m[1].trim());
  // Prefer ORG (Tooling/Data API) discovery; fall back to local metadata if needed.
  let label = objectApiName.replace('__c','');
  let fields: any[] = [];
  let validationRules: any[] = [];
  let recordTypes: any[] = [];
  let triggers: any[] = [];

  try {
    if (!(await sfAvailable(repoDir))) { throw new Error('sf CLI not available'); }
    // EntityDefinition -> label
    const ent = await toolingQuery(repoDir, orgAlias, `SELECT QualifiedApiName, Label FROM EntityDefinition WHERE QualifiedApiName = '${objectApiName}' LIMIT 1`);
    if (ent.records?.length) label = ent.records[0].Label || label;

    // FieldDefinition -> fields
    const fldRes = await toolingQuery(
      repoDir,
      orgAlias,
      `SELECT QualifiedApiName, DataType, Label, Length, Precision, Scale, IsCalculated, IsNillable, IsUnique, IsExternalId, RelationshipName, ReferenceTargetField, ReferenceTargetEntity 
       FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = '${objectApiName}'`
    );
    fields = (fldRes.records || []).map((r:any) => ({
      fullName: r.QualifiedApiName,
      label: r.Label,
      type: r.DataType,
      required: r.IsNillable === false,
      unique: !!r.IsUnique,
      externalId: !!r.IsExternalId,
      formula: r.IsCalculated ? 'CALCULATED' : '',
      length: r.Length ?? undefined,
      precision: r.Precision ?? undefined,
      scale: r.Scale ?? undefined,
      referenceTo: r.ReferenceTargetEntity ? [r.ReferenceTargetEntity] : [],
      relationshipName: r.RelationshipName || undefined,
    }));

    // ValidationRule (Tooling)
    const vrRes = await toolingQuery(
      repoDir,
      orgAlias,
      `SELECT Active, Description, ErrorConditionFormula, ErrorDisplayField, ErrorMessage, ValidationName, EntityDefinition.QualifiedApiName 
       FROM ValidationRule WHERE EntityDefinition.QualifiedApiName = '${objectApiName}'`
    );
    validationRules = (vrRes.records || []).map((r:any)=>({
      fullName: r.ValidationName,
      active: !!r.Active,
      errorDisplayField: r.ErrorDisplayField || '',
      errorMessage: r.ErrorMessage || '',
      errorConditionFormula: r.ErrorConditionFormula || '',
    }));

    // RecordType (Data API)
    const rtRes = await dataQuery(
      repoDir,
      orgAlias,
      `SELECT DeveloperName, Name, IsActive FROM RecordType WHERE SObjectType = '${objectApiName}'`
    );
    recordTypes = (rtRes.records || []).map((r:any)=>({ apiName: r.DeveloperName, label: r.Name, active: !!r.IsActive }));

    // ApexTrigger (Tooling)
    const trgRes = await toolingQuery(
      repoDir,
      orgAlias,
      `SELECT Name, Status FROM ApexTrigger WHERE TableEnumOrId = '${objectApiName}'`
    );
    triggers = (trgRes.records || []).map((r:any)=>({ name: r.Name, status: r.Status || 'Active' }));
  } catch {
    // ignore org errors; fallback to local metadata is below
  }

  // Fallback to local metadata if any sections are empty
  if (!fields.length || !validationRules.length || !recordTypes.length) {
    const objDir = path.join(repoDir, 'force-app','main','default','objects', objectApiName);
    const objMeta = path.join(objDir, `${objectApiName}.object-meta.xml`);
    if (await exists(objMeta)) {
      const xml = await readText(objMeta).catch(()=> '');
      const lbl = xml ? getTag(xml, 'label') : '';
      if (lbl) label = lbl;
    }
    // Fields
    if (!fields.length) {
      const fieldsDir = path.join(objDir, 'fields');
      const fieldFiles = await fg(path.join(fieldsDir,'*.field-meta.xml').replace(/\\/g,'/'), { onlyFiles: true });
      for (const file of fieldFiles) {
        const xml = await readText(file).catch(()=> '');
        if (!xml) continue;
        const fullName = getTag(xml, 'fullName') || path.basename(file).replace('.field-meta.xml','');
        // picklist values (if any)
        const picks: Array<{ fullName: string; label: string; default?: boolean }> = [];
        const vsBlock = xml.match(/<valueSet>[\s\S]*?<\/valueSet>/i)?.[0] || '';
        const defBlock = vsBlock.match(/<valueSetDefinition>[\s\S]*?<\/valueSetDefinition>/i)?.[0] || '';
        for (const vm of defBlock.matchAll(/<value>[\s\S]*?<\/value>/gi)) {
          const b = vm[0];
          picks.push({
            fullName: getTag(b, 'fullName') || '',
            label: getTag(b, 'label') || '',
            default: /<default>\s*true\s*<\/default>/i.test(b) || undefined,
          });
        }
        const ftype = getTag(xml, 'type') || '';
        const relType = /masterdetail/i.test(ftype) ? 'MasterDetail' : (/lookup/i.test(ftype) ? 'Lookup' : undefined);
        fields.push({
          fullName,
          label: getTag(xml, 'label') || fullName,
          type: ftype,
          required: /<required>\s*true\s*<\/required>/i.test(xml),
          unique: /<unique>\s*true\s*<\/unique>/i.test(xml),
          externalId: /<externalId>\s*true\s*<\/externalId>/i.test(xml),
          formula: getTag(xml, 'formula') || '',
          length: Number(getTag(xml, 'length') || '0') || undefined,
          precision: Number(getTag(xml, 'precision') || '0') || undefined,
          scale: Number(getTag(xml, 'scale') || '0') || undefined,
          referenceTo: getTags(xml, 'referenceTo'),
          relationshipName: getTag(xml, 'relationshipName') || undefined,
          relationshipType: relType,
          picklistValues: picks.length ? picks : undefined,
        });
      }
    }
    // Validation Rules
    if (!validationRules.length) {
      const vrDir = path.join(objDir, 'validationRules');
      const vrFiles = await fg(path.join(vrDir,'*.validationRule-meta.xml').replace(/\\/g,'/'), { onlyFiles: true });
      for (const file of vrFiles) {
        const xml = await readText(file).catch(()=> '');
        if (!xml) continue;
        validationRules.push({
          fullName: getTag(xml, 'fullName') || path.basename(file).replace('.validationRule-meta.xml',''),
          active: /<active>\s*true\s*<\/active>/i.test(xml),
          errorDisplayField: getTag(xml, 'errorDisplayField') || '',
          errorMessage: getTag(xml, 'errorMessage') || '',
          errorConditionFormula: getTag(xml, 'errorConditionFormula') || '',
        });
      }
    }
    // Record Types
    if (!recordTypes.length) {
      const rtDir = path.join(objDir, 'recordTypes');
      const rtFiles = await fg(path.join(rtDir,'*.recordType-meta.xml').replace(/\\/g,'/'), { onlyFiles: true });
      for (const file of rtFiles) {
        const xml = await readText(file).catch(()=> '');
        if (!xml) continue;
        recordTypes.push({
          apiName: getTag(xml, 'fullName') || path.basename(file).replace('.recordType-meta.xml',''),
          label: getTag(xml, 'label') || '',
          active: /<active>\s*true\s*<\/active>/i.test(xml),
        });
      }
    }
    // Triggers (local)
    if (!triggers.length) {
      const trgDir = path.join(repoDir, 'force-app','main','default','triggers');
      const trgFiles = await fg(path.join(trgDir,'*.trigger-meta.xml').replace(/\\/g,'/'), { onlyFiles: true });
      for (const file of trgFiles) {
        const xml = await readText(file).catch(()=> '');
        if (!xml) continue;
        const sobj = getTag(xml, 'sobjectType');
        if (sobj === objectApiName) {
          const name = path.basename(file).replace('.trigger-meta.xml','');
          const status = getTag(xml, 'status') || 'Active';
          triggers.push({ name, status });
        }
      }
    }
  }

  const objectJson = { objectApiName, label, recordTypes, fields, validationRules, triggers, crud: { create:true, read:true, update:true, delete:true } };
  await writeJson(path.join(outDir,'object.json'), objectJson);
  // Validate against schema if present
  const schemaObj = path.join(repoDir, 'mcp_planning_upgrade','specs','discovery.object.schema.json');
  if (await exists(schemaObj)) {
    const res = await validateJsonAgainstSchema(path.join(outDir,'object.json'), schemaObj);
    await writeValidationReport(outDir, 'object', res);
  }
  return objectJson;
}

export async function orgDiscoverUsage(repoDir: string, orgAlias: string, objectApiName: string) {
  const cfg = await resolveProject(repoDir);
  const outDir = path.join(repoDir, cfg.artifactsDir!, 'discovery', objectApiName);
  await ensureDir(outDir);

  // Org-level usage (best-effort, with fallback)
  const orgApex: Array<{ name: string; status?: string; apiVersion?: number }> = [];
  const orgFlows: Array<{ fullName: string; version?: number; elements?: Array<{ element: string; action: string; fields: string[] }> }> = [];
  const orgLwcs: Array<{ filePath: string; format?: string }> = [];
  const parseFlowMarkupForObject = (xml: string): Array<{ element: string; action: string; fields: string[] }> => {
    const out: Array<{ element: string; action: string; fields: string[] }> = [];
    if (!xml) return out;
    const add = (block: string, element: string, action: string) => {
      const fields = Array.from(block.matchAll(/<field>\s*([^<]+)\s*<\/field>/gi)).map(m=>m[1].trim());
      out.push({ element, action, fields });
    };
    const hasObj = (block: string) => new RegExp(`<sobject>\s*${objectApiName}\s*<\/sobject>|<object>\s*${objectApiName}\s*<\/object>`, 'i').test(block);
    for (const m of xml.matchAll(/<recordCreates>[\s\S]*?<\/recordCreates>/gi)) { const b=m[0]; if (hasObj(b)) add(b,'recordCreates','create'); }
    for (const m of xml.matchAll(/<recordUpdates>[\s\S]*?<\/recordUpdates>/gi)) { const b=m[0]; if (hasObj(b)) add(b,'recordUpdates','update'); }
    for (const m of xml.matchAll(/<recordLookups>[\s\S]*?<\/recordLookups>/gi)) { const b=m[0]; if (hasObj(b)) add(b,'recordLookups','lookup'); }
    for (const m of xml.matchAll(/<recordDeletes>[\s\S]*?<\/recordDeletes>/gi)) { const b=m[0]; if (hasObj(b)) add(b,'recordDeletes','delete'); }
    // generic element blocks
    for (const m of xml.matchAll(/<elements>[\s\S]*?<\/elements>/gi)) { const b=m[0]; if (hasObj(b)) add(b,'elements','unknown'); }
    return out;
  };

  try {
    if (await sfAvailable(repoDir)) {
      // Apex classes referencing the object in body
      const like = objectApiName.replace(/'/g, "\\'");
      const ac = await toolingQuery(
        repoDir,
        orgAlias,
        `SELECT Name, Status, ApiVersion FROM ApexClass WHERE Body LIKE '%${like}%'`
      );
      for (const r of ac.records || []) {
        orgApex.push({ name: r.Name, status: r.Status, apiVersion: r.ApiVersion });
      }
      // Flows with markup referencing the object
      const fl = await toolingQuery(
        repoDir,
        orgAlias,
        `SELECT FullName, ActiveVersion.VersionNumber, Markup FROM Flow WHERE Markup LIKE '%${like}%'`
      );
      for (const r of fl.records || []) {
        const elements = parseFlowMarkupForObject(r.Markup || '');
        orgFlows.push({ fullName: r.FullName, version: r?.ActiveVersion?.VersionNumber, elements });
      }
      // LWC resources with source referencing the object
      const lw = await toolingQuery(
        repoDir,
        orgAlias,
        `SELECT FilePath, Format FROM LightningComponentResource WHERE Source LIKE '%${like}%'`
      );
      for (const r of lw.records || []) {
        orgLwcs.push({ filePath: r.FilePath, format: r.Format });
      }
    }
  } catch {
    // ignore org usage errors; fallback to repo scan below
  }

  // Local scan for references under searchRoots (Apex)
  const searchRoots = cfg.searchRoots || ['force-app/main/default/classes','force-app/main/default/triggers'];
  const apexGlobs = searchRoots.map((r) => path.join(repoDir, r, '**/*.cls').replace(/\\/g,'/'));
  const apexFiles = await fg(apexGlobs, { dot: false, onlyFiles: true });
  const apexMatches: Array<{ name: string; path: string; hits: number }>=[];
  const apexRe = new RegExp(`\\b${objectApiName}\\b|\\bSchema\\.SObjectType\\.${objectApiName}\\b|FROM\\s+${objectApiName}\\b|INSERT\\s+${objectApiName}\\b|UPDATE\\s+${objectApiName}\\b`, 'gi');
  for (const file of apexFiles) {
    const src = await readText(file).catch(()=> '');
    if (!src) continue;
    const hits = (src.match(apexRe) || []).length + (src.match(new RegExp(`\\bList<\\s*${objectApiName}\\s*>`,'gi'))||[]).length;
    if (hits>0) {
      apexMatches.push({ name: path.basename(file), path: path.relative(repoDir, file).replace(/\\/g,'/'), hits });
    }
  }

  // Flow scan
  const flowDir = path.join(repoDir, 'force-app','main','default','flows');
  const flowFiles = await fg(path.join(flowDir,'**/*.flow-meta.xml').replace(/\\/g,'/'), { onlyFiles: true });
  const flowMatches: Array<{ name: string; path: string; elements?: Array<{ element: string; action: string; fields: string[] }> }>=[];
  for (const file of flowFiles) {
    const xml = await readText(file).catch(()=> '');
    if (!xml) continue;
    const elements = parseFlowMarkupForObject(xml);
    if (xml.includes(`<object>${objectApiName}</object>`) || xml.includes(`<sobject>${objectApiName}</sobject>`) || xml.includes(objectApiName) || elements.length) {
      flowMatches.push({ name: path.basename(file), path: path.relative(repoDir, file).replace(/\\/g,'/'), elements });
    }
  }

  // LWC scan (js/html)
  const lwcDir = path.join(repoDir, 'force-app','main','default','lwc');
  const lwcFiles = await fg([
    path.join(lwcDir,'**/*.{js,ts,html,xml}').replace(/\\/g,'/'),
  ], { onlyFiles: true });
  const lwcMatches: Array<{ name: string; path: string }>=[];
  for (const file of lwcFiles) {
    const txt = await readText(file).catch(()=> '');
    if (!txt) continue;
    if (txt.includes(objectApiName)) {
      lwcMatches.push({ name: path.basename(file), path: path.relative(repoDir, file).replace(/\\/g,'/') });
    }
  }

  // Merge org + repo indicators
  const usage = {
    objectApiName,
    apex: [...apexMatches, ...orgApex.map(a => ({ name: a.name, path: `(org)`, hits: 1 }))],
    flows: [...flowMatches, ...orgFlows.map(f => ({ name: f.fullName, path: `(org)`, version: f.version, elements: f.elements }))],
    lwcs: [...lwcMatches, ...orgLwcs.map(l => ({ name: path.basename(l.filePath), path: `(org) ${l.filePath}` }))]
  } as any;
  await writeJson(path.join(outDir,'usage.json'), usage);
  const schemaUsage = path.join(repoDir, 'mcp_planning_upgrade','specs','discovery.usage.schema.json');
  if (await exists(schemaUsage)) {
    const res = await validateJsonAgainstSchema(path.join(outDir,'usage.json'), schemaUsage);
    await writeValidationReport(outDir, 'usage', res);
  }
  return usage;
}

export async function orgDiscoverPermissions(repoDir: string, orgAlias: string, objectApiName: string) {
  const cfg = await resolveProject(repoDir);
  const outDir = path.join(repoDir, cfg.artifactsDir!, 'discovery', objectApiName);
  await ensureDir(outDir);

  // First try org-level ObjectPermissions / FieldPermissions aggregation
  type ObjCrud = { create:boolean; read:boolean; update:boolean; delete:boolean };
  const crud: ObjCrud = { create:false, read:false, update:false, delete:false };
  const fieldPermissions: Record<string,{readable:boolean; editable:boolean}> = {};
  const recordTypeVisibility: Array<{ profile: string; recordType: string; visible: boolean }> = [];
  const customPermissions: string[] = [];
  const sources = { profiles: [] as string[], permissionSets: [] as string[] };

  try {
    const opq = await dataQuery(
      repoDir,
      orgAlias,
      `SELECT SObjectType, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete, ParentId FROM ObjectPermissions WHERE SObjectType = '${objectApiName}'`
    );
    for (const r of opq.records || []) {
      crud.create = crud.create || !!r.PermissionsCreate;
      crud.read   = crud.read   || !!r.PermissionsRead;
      crud.update = crud.update || !!r.PermissionsEdit;
      crud.delete = crud.delete || !!r.PermissionsDelete;
    }

    const fpq = await dataQuery(
      repoDir,
      orgAlias,
      `SELECT Field, PermissionsRead, PermissionsEdit, ParentId FROM FieldPermissions WHERE Field LIKE '${objectApiName}.%'`
    );
    for (const r of fpq.records || []) {
      const full: string = r.Field;
      const api = full.split('.')[1];
      const cur = fieldPermissions[api] || { readable:false, editable:false };
      fieldPermissions[api] = { readable: cur.readable || !!r.PermissionsRead, editable: cur.editable || !!r.PermissionsEdit };
    }
    // RecordType visibility by profile (best-effort)
    const rtv = await dataQuery(
      repoDir,
      orgAlias,
      `SELECT Profile.Name, RecordType.DeveloperName, Visible FROM ProfileRecordTypeVisibility WHERE RecordType.SObjectType = '${objectApiName}'`
    );
    for (const r of rtv.records || []) {
      recordTypeVisibility.push({ profile: r['Profile']?.Name || r['Profile.Name'] || 'Unknown', recordType: r['RecordType']?.DeveloperName || r['RecordType.DeveloperName'] || '', visible: !!r.Visible });
    }

    // CustomPermissions related to object (heuristic)
    const objBase = objectApiName.replace(/__c$/,'');
    const cp = await dataQuery(
      repoDir,
      orgAlias,
      `SELECT DeveloperName, Label FROM CustomPermission WHERE DeveloperName LIKE '%${objBase}%' OR Label LIKE '%${objBase}%'`
    );
    for (const r of cp.records || []) {
      const name = r.DeveloperName || r.Label;
      if (name && !customPermissions.includes(name)) customPermissions.push(name);
    }
  } catch {
    // Ignore org errors; fall back to local metadata below
  }

  // Fallback to local metadata if org not available
  if (!crud.read && !crud.create && !crud.update && !crud.delete && Object.keys(fieldPermissions).length === 0) {
    const profRoot = path.join(repoDir, 'force-app','main','default','profiles');
    const psRoot   = path.join(repoDir, 'force-app','main','default','permissionsets');
    const profFiles = await fg(path.join(profRoot,'**/*.profile-meta.xml').replace(/\\/g,'/'), { onlyFiles: true });
    const psFiles   = await fg(path.join(psRoot,'**/*.permissionset-meta.xml').replace(/\\/g,'/'), { onlyFiles: true });
    const allFiles = [...profFiles, ...psFiles];
    for (const file of allFiles) {
      const xml = await readText(file).catch(()=> '');
      if (!xml) continue;
      const isProfile = file.endsWith('.profile-meta.xml');
      if (isProfile) sources.profiles.push(path.basename(file)); else sources.permissionSets.push(path.basename(file));
      const types = Array.from(xml.matchAll(/<objectPermissions>[\s\S]*?<\/objectPermissions>/g)).map(m=>m[0]);
      for (const block of types) {
        const objMatch = block.match(/<object>\s*([^<]+)\s*<\/object>/);
        if (!objMatch) continue;
        if (objMatch[1].trim() !== objectApiName) continue;
        const flag = (tag:string)=> new RegExp(`<allow${tag}>\\s*true\\s*<\\/allow${tag}>`,'i').test(block);
        crud.create = crud.create || flag('Create');
        crud.read   = crud.read   || flag('Read');
        crud.update = crud.update || flag('Edit');
        crud.delete = crud.delete || flag('Delete');
      }
      const fblocks = Array.from(xml.matchAll(/<fieldPermissions>[\s\S]*?<\/fieldPermissions>/g)).map(m=>m[0]);
      for (const block of fblocks) {
        const fieldMatch = block.match(/<field>\s*([^<]+)\s*<\/field>/);
        if (!fieldMatch) continue;
        const full = fieldMatch[1].trim();
        if (!full.startsWith(objectApiName + '.')) continue;
        const fieldApi = full.split('.')[1];
        const readable = /<readable>\s*true\s*<\/readable>/i.test(block) || /<PermissionsRead>\s*true\s*<\/PermissionsRead>/i.test(block);
        const editable = /<editable>\s*true\s*<\/editable>/i.test(block) || /<PermissionsEdit>\s*true\s*<\/PermissionsEdit>/i.test(block);
        const cur = fieldPermissions[fieldApi] || { readable:false, editable:false };
        fieldPermissions[fieldApi] = { readable: cur.readable || readable, editable: cur.editable || editable };
      }

      // recordTypeVisibilities blocks
      const rblocks = Array.from(xml.matchAll(/<recordTypeVisibilities>[\s\S]*?<\/recordTypeVisibilities>/g)).map(m=>m[0]);
      for (const block of rblocks) {
        const rt = (block.match(/<recordType>\s*([^<]+)\s*<\/recordType>/i)?.[1] || '').trim(); // e.g. Object__c.Cohort
        if (!rt.startsWith(objectApiName + '.')) continue;
        const dev = rt.split('.')[1];
        const vis = /<visible>\s*true\s*<\/visible>/i.test(block);
        const prof = path.basename(file).replace(/\.profile-meta\.xml$/,'');
        recordTypeVisibility.push({ profile: prof, recordType: dev, visible: vis });
      }
    }
  }

  const perms = { objectApiName, crud, fieldPermissions, recordTypeVisibility, sources, customPermissions };
  await writeJson(path.join(outDir,'permissions.json'), perms);
  const schemaPerm = path.join(repoDir, 'mcp_planning_upgrade','specs','discovery.permissions.schema.json');
  if (await exists(schemaPerm)) {
    const res = await validateJsonAgainstSchema(path.join(outDir,'permissions.json'), schemaPerm);
    await writeValidationReport(outDir, 'permissions', res);
  }
  return perms;
}

export async function discoveryRun(repoDir: string, orgAlias: string, objectApiName: string, branchRef='origin/main') {
  const cfg = await resolveProject(repoDir);
  const outDir = path.join(repoDir, cfg.artifactsDir!, 'discovery', objectApiName);
  await ensureDir(outDir);
  const startedAt = new Date().toISOString();
  const orgOk = await sfAvailable(repoDir);
  const obj = await orgDiscoverObject(repoDir, orgAlias, objectApiName);
  const usage = await orgDiscoverUsage(repoDir, orgAlias, objectApiName);
  const perms = await orgDiscoverPermissions(repoDir, orgAlias, objectApiName);
  const plan = await discoveryPlan(repoDir, objectApiName);
  const briefPath = await (async () => {
    try { return await (await import('./brief.js')).discoveryBrief(repoDir, objectApiName, branchRef); } catch { return ''; }
  })();
  const diagnostics = {
    objectApiName,
    startedAt,
    finishedAt: new Date().toISOString(),
    orgCliAvailable: orgOk,
    counts: {
      fields: obj?.fields?.length || 0,
      recordTypes: obj?.recordTypes?.length || 0,
      validationRules: obj?.validationRules?.length || 0,
      triggers: obj?.triggers?.length || 0,
      usageApex: usage?.apex?.length || 0,
      usageFlows: usage?.flows?.length || 0,
      usageLwcs: usage?.lwcs?.length || 0,
      permsFields: Object.keys(perms?.fieldPermissions || {}).length,
    },
    outputs: {
      object: path.join(outDir,'object.json'),
      usage: path.join(outDir,'usage.json'),
      permissions: path.join(outDir,'permissions.json'),
      planV1: path.join(repoDir, cfg.artifactsDir!, 'plan', `${objectApiName}.plan.json`),
      planV2: path.join(repoDir, cfg.artifactsDir!, 'plan', `${objectApiName}.plan.v2.json`),
      brief: briefPath,
    }
  };
  await writeJson(path.join(outDir,'diagnostics.json'), diagnostics);
  return diagnostics;
}

export async function discoveryPlan(repoDir: string, objectApiName: string) {
  const cfg = await resolveProject(repoDir);
  const discDir = path.join(repoDir, cfg.artifactsDir!, 'discovery', objectApiName);
  const planDir = path.join(repoDir, cfg.artifactsDir!, 'plan');
  await ensureDir(planDir);

  const objPath = path.join(discDir,'object.json');
  const usagePath = path.join(discDir,'usage.json');
  const permsPath = path.join(discDir,'permissions.json');
  const obj = (await exists(objPath)) ? await readJson(objPath) : { objectApiName, label: objectApiName, recordTypes: [], fields: [], validationRules: [], triggers: [], crud: { create:true, read:true, update:true, delete:true } };
  const usage = (await exists(usagePath)) ? await readJson(usagePath) : { objectApiName, apex: [], flows: [], lwcs: [] };
  const perms = (await exists(permsPath)) ? await readJson(permsPath) : { objectApiName, crud: { create:false, read:false, update:false, delete:false }, fields: {}, recordTypeVisibility: [], sources: { profiles: [], permissionSets: [] } };

  const plan = {
    objectApiName,
    summary: `Action layer plan for ${objectApiName}`,
    generation: { create: true, retrieve: true, update: true, delete: false, search: true },
    guards: {
      objectCrud: perms.crud,
      fieldUpdateWhitelist: [],
      fieldReadWhitelist: [],
      requireFilterForSearch: true
    },
    dto: {
      upsertFields: [],
      detailFields: [],
      search: { queryFields: [], defaultOrderBy: 'CreatedDate DESC', limit: 200 }
    },
    businessLogic: [],
    agentBindings: { topicApiName: objectApiName.replace('__c',''), actions: [] },
    todo: {
      whatToAdd: [], niceToHaves: [], impacted: [], rollout: [], tests: [], risks: []
    }
  };
  await writeJson(path.join(planDir, `${objectApiName}.plan.json`), plan);
  // Markdown summary
  const md = `# Plan - ${objectApiName}\n\n- CRUD: ${JSON.stringify(perms.crud)}\n- Generate: create/retrieve/update/search\n`;
  await writeText(path.join(planDir, `${objectApiName}.plan.md`), md);

  // Plan V2 per mcp_planning_upgrade/specs/plan.schema.json
  const v2 = {
    objectApiName,
    architecture: {
      templates: ['Generated_Handler_SingleOutput','Generated_Service_Dispatch','Generated_DTO'],
      outputContract: {
        name: `${(obj.label||objectApiName).replace(/__c$/,'')}Result`, version: '1.0'
      },
      inputs: [],
      helpers: ['AgentCore_Permissions','AgentCore_SafeQuery','DTO','Errors'],
      businessLogic: [],
    },
    policy: {
      crud: perms.crud || {},
      fls: perms.fieldPermissions || {},
      customPermissions: [],
      testBypass: true,
    },
    tests: {
      apex: ['FR_Smoke'],
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

  const schemaPlan = path.join(repoDir, 'mcp_planning_upgrade','specs','plan.schema.json');
  if (await exists(schemaPlan)) {
    const res = await validateJsonAgainstSchema(v2Path, schemaPlan);
    await writeValidationReport(planDir, 'plan.v2', res);
  }
  return plan;
}
