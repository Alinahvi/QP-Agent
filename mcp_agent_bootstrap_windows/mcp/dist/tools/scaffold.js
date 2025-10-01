import * as path from 'path';
import fs from 'fs-extra';
import Mustache from 'mustache';
import YAML from 'yaml';
import { resolveProject } from '../lib/resolver.js';
import * as fsp from 'fs/promises';
function ensureMetaXmlContent(apiVersion = '59.0') {
    return `<?xml version="1.0" encoding="UTF-8"?>\n<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">\n  <apiVersion>${apiVersion}</apiVersion>\n  <status>Active</status>\n</ApexClass>\n`;
}
function toObjectKey(objectApiName) {
    return String(objectApiName || '').replace('__c', '');
}
function classBase(objectApiName) {
    return `FRAGENT${toObjectKey(objectApiName)}`; // e.g., Audience__c -> FRAGENTAudience
}
function replaceAll(haystack, needle, replacement) {
    return haystack.split(needle).join(replacement);
}
function applyPhase2Replacements(src, objectApiName, req) {
    const objKey = toObjectKey(objectApiName); // e.g., Audience
    const base = classBase(objectApiName); // e.g., FRAGENTAudience
    // Handler/Service class renames
    src = replaceAll(src, 'FRAGENTAudienceHandler', `${base}Handler`);
    src = replaceAll(src, 'FRAGENTAudienceService', `${base}Service`);
    // SObject replacement
    src = replaceAll(src, 'Audience__c', objectApiName);
    // Permission keys replacement (AgentCore_ActionKeys.Audience.*)
    src = src.replace(/AgentCore_ActionKeys\.Audience\b/g, `AgentCore_ActionKeys.${objKey}`);
    // Action labels / output contract name if provided
    const contractName = req?.actionLayer?.invocableMethod?.singleOutputEnvelope?.contractName || `${objKey}Result`;
    src = replaceAll(src, 'AudienceResult', contractName);
    // Optionally map related objects if present in requirements
    const memberObj = req?.related?.member?.objectApiName || 'Audience_Member__c';
    const memberParentField = req?.related?.member?.parentFieldApiName || 'Audience__c';
    const memberRelName = req?.related?.member?.relationshipNameOnParent || 'Audience_Members__r';
    src = replaceAll(src, 'Audience_Member__c', memberObj);
    src = replaceAll(src, 'Audience_Members__r', memberRelName);
    // Parent field names in SOQL and field access
    src = replaceAll(src, 'Audience__c = :audienceId', `${memberParentField} = :audienceId`);
    src = replaceAll(src, 'WHERE Audience__c IN :aIds', `WHERE ${memberParentField} IN :aIds`);
    src = replaceAll(src, 'containsKey(am.Audience__c)', `containsKey(am.${memberParentField})`);
    src = src.replace(/am\.Audience__c\b/g, `am.${memberParentField}`);
    // Checklist / Assigned Learning object names found in comments; no functional code replacement unless provided
    const checklistObj = req?.related?.checklist?.objectApiName;
    if (checklistObj) {
        src = replaceAll(src, 'Audience_Checklist__c', checklistObj);
    }
    const assignedObj = req?.related?.assignedLearning?.objectApiName;
    if (assignedObj) {
        src = replaceAll(src, 'Assigned_Learning__c', assignedObj);
    }
    // RecordType developer name used by create path
    const createRtDev = req?.recordTypes?.create?.developerName;
    if (createRtDev) {
        src = replaceAll(src, "'Cohort'", `'${createRtDev}'`);
    }
    return src;
}
export async function actionlayerScaffold(repoDir, planPath, mode, templateSet = 'generated', requirementsPath) {
    await fs.ensureDir(path.dirname(planPath));
    const cfg = await resolveProject(repoDir);
    const plan = await fs.readJson(planPath);
    const objectApiName = plan.objectApiName;
    const obj = toObjectKey(objectApiName);
    // Optional requirements (YAML) to refine generation
    let req;
    if (requirementsPath) {
        try {
            const ytxt = await fs.readFile(requirementsPath, 'utf8');
            req = YAML.parse(ytxt);
        }
        catch { }
    }
    if (templateSet === 'phase2') {
        // Clone from Audience examples and parameterize
        const baseExamples = path.join(repoDir, 'docs', 'phase 2', 'Apex Examples');
        const handlerSrc = await fs.readFile(path.join(baseExamples, 'FRAGENTAudienceHandler.cls'), 'utf8');
        const serviceSrc = await fs.readFile(path.join(baseExamples, 'FRAGENTAudienceService.cls'), 'utf8');
        const handlerTestSrc = await fs.readFile(path.join(baseExamples, 'FRAGENTAudienceHandler_Test.cls'), 'utf8');
        const serviceTestSrc = await fs.readFile(path.join(baseExamples, 'FRAGENTAudienceService_Test.cls'), 'utf8');
        const outBase = path.join(repoDir, 'force-app', 'main', 'default', 'classes', 'fragent');
        await fs.ensureDir(outBase);
        const rendered = [
            { name: `${classBase(objectApiName)}Handler.cls`, text: applyPhase2Replacements(handlerSrc, objectApiName, req) },
            { name: `${classBase(objectApiName)}Service.cls`, text: applyPhase2Replacements(serviceSrc, objectApiName, req) },
            { name: `${classBase(objectApiName)}Handler_Test.cls`, text: applyPhase2Replacements(handlerTestSrc, objectApiName, req) },
            { name: `${classBase(objectApiName)}Service_Test.cls`, text: applyPhase2Replacements(serviceTestSrc, objectApiName, req) },
        ];
        const written = [];
        for (const f of rendered) {
            const out = path.join(outBase, f.name);
            if (mode === 'apply') {
                await fs.writeFile(out, f.text, 'utf8');
                // Write meta.xml
                await fs.writeFile(out.replace(/\.cls$/, '.cls-meta.xml'), ensureMetaXmlContent(), 'utf8');
            }
            written.push(out);
        }
        return { written, mode, templateSet };
    }
    // Default: original lightweight generated templates
    const view = {
        ObjectApiName: objectApiName,
        Object: obj,
        methodLabel: `Manage ${objectApiName}`,
        outputContractName: `${obj}Result`,
        outputContractVersion: '1.0',
        methodDesc: `Performs create/retrieve/update/search for ${objectApiName}. Single-output JSON 'message' contains result code+data.`,
        outputContractDesc: `JSON envelope { contractName, version, code, message, data }. Downstream actions can read 'code' and 'data'.`
    };
    const outBase = path.join(repoDir, 'force-app', 'main', 'default', 'classes', 'generated');
    await fs.ensureDir(outBase);
    const tplDir = path.join(repoDir, 'templates', 'apex');
    const files = [
        { tpl: 'Generated_Handler_SingleOutput.cls.tmpl', out: `Generated_FRAGENT_${obj}_Handler.cls` },
        { tpl: 'Generated_Service_Dispatch.cls.tmpl', out: `Generated_FRAGENT_${obj}_Service.cls` },
        { tpl: 'Generated_DTO.cls.tmpl', out: `Generated_FRAGENT_${obj}_DTO.cls` },
        { tpl: 'FR_Smoke.cls.tmpl', out: `FR_Smoke.cls` }
    ];
    const written = [];
    for (const f of files) {
        const tpl = await fs.readFile(path.join(tplDir, f.tpl), 'utf8');
        const txt = Mustache.render(tpl, view);
        const out = path.join(outBase, f.out);
        if (mode === 'apply') {
            await fs.writeFile(out, txt, 'utf8');
            if (out.endsWith('.cls')) {
                await fs.writeFile(out.replace(/\.cls$/, '.cls-meta.xml'), ensureMetaXmlContent(), 'utf8');
            }
        }
        written.push(out);
    }
    return { written, mode, templateSet };
}
async function pathExists(p) { try {
    await fsp.access(p);
    return true;
}
catch {
    return false;
} }
export async function phase2RequirementsStub(repoDir, objectApiName, outPath) {
    const cfg = await resolveProject(repoDir);
    const objKey = toObjectKey(objectApiName);
    const docsDir = path.join(repoDir, 'docs', 'phase 2');
    await fs.ensureDir(docsDir);
    const out = outPath || path.join(docsDir, `${objectApiName}.requirements.yaml`);
    // Try to infer record type developer name and label from discovery if available
    let rtDev;
    let rtLabel;
    const discObjPath = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'discovery', objectApiName, 'object.json');
    try {
        const meta = await fs.readJson(discObjPath);
        const rts = Array.isArray(meta?.recordTypes) ? meta.recordTypes : [];
        const manual = rts.find((r) => /manual/i.test(r?.label || '')) || rts[0];
        if (manual) {
            rtDev = manual.apiName || manual.developerName;
            rtLabel = manual.label;
        }
    }
    catch { }
    const yamlObj = {
        scope: { primaryObject: objectApiName, objects: [objectApiName] },
        actionLayer: {
            invocableMethod: {
                className: `${classBase(objectApiName)}Handler`,
                methodLabel: `FRAGENT Manage ${objKey}`,
                methodName: `manage${objKey}${/[sxz]$|ch$|sh$/i.test(objKey) ? 'es' : 's'}`,
                singleOutputEnvelope: { contractName: `${objKey}Result`, version: '1.0' }
            }
        },
        related: {
            member: {
                objectApiName: `${objKey}_Member__c`,
                parentFieldApiName: objectApiName,
                relationshipNameOnParent: `${objKey}_Members__r`
            },
            checklist: { objectApiName: `${objKey}_Checklist__c` },
            assignedLearning: { objectApiName: `Assigned_Learning__c` }
        },
        recordTypes: { create: { developerName: rtDev || 'Cohort', label: rtLabel || 'Manual' } },
        dependencies: {
            apexLibs: ['AgentCore_Permissions', 'AgentCore_SafeQuery', 'AgentCore_Dedupe', 'AgentCore_TestFactory'],
            permissionSets: ['Checklist Manager', 'Agent Retrieve', 'Agent CRU', 'Agent CRUD']
        }
    };
    const ytxt = YAML.stringify(yamlObj);
    await fs.writeFile(out, ytxt, 'utf8');
    return { out };
}
export async function scaffoldPhase2ForObject(repoDir, objectApiName, mode = 'apply', planPath, requirementsPath) {
    const cfg = await resolveProject(repoDir);
    const obj = objectApiName;
    const defaultPlanCandidates = [
        planPath,
        path.join(repoDir, cfg.artifactsDir || '.artifacts', 'plan', `${obj}.plan.v2.json`),
        path.join(repoDir, 'docs', 'phase 2', `${obj}.plan.v2.enhanced.json`),
        path.join(repoDir, cfg.artifactsDir || '.artifacts', 'plan', `${obj}.plan.json`)
    ].filter(Boolean);
    let chosenPlan;
    for (const p of defaultPlanCandidates) {
        if (await pathExists(p)) {
            chosenPlan = p;
            break;
        }
    }
    if (!chosenPlan)
        throw new Error(`Plan file not found for ${obj}. Provide --planPath or generate plan.v2 first.`);
    let reqPath = requirementsPath || path.join(repoDir, 'docs', 'phase 2', `${obj}.requirements.yaml`);
    if (!(await pathExists(reqPath))) {
        await phase2RequirementsStub(repoDir, objectApiName, reqPath);
    }
    return actionlayerScaffold(repoDir, chosenPlan, mode, 'phase2', reqPath);
}
