import path from 'path';
import fs from 'fs-extra';
import YAML from 'yaml';
import Ajv from 'ajv';
import { resolveProject } from '../lib/resolver.js';
const ajv = new Ajv({ allErrors: true, strict: false });
const requirementsSchema = {
    type: 'object',
    required: ['specVersion', 'project', 'scope', 'actionLayer'],
    properties: {
        specVersion: { type: 'string' },
        project: { type: 'string' },
        scope: {
            type: 'object',
            required: ['objects', 'primaryObject'],
            properties: {
                objects: { type: 'array', items: { type: 'string' } },
                primaryObject: { type: 'string' },
            },
            additionalProperties: true,
        },
        actionLayer: {
            type: 'object',
            required: ['invocableMethod', 'actions'],
            properties: {
                invocableMethod: {
                    type: 'object',
                    required: ['className', 'methodName'],
                    properties: {
                        className: { type: 'string' },
                        methodName: { type: 'string' },
                        methodLabel: { type: 'string' },
                        singleOutputEnvelope: { type: 'object' },
                    },
                    additionalProperties: true,
                },
                actions: {
                    type: 'array',
                    items: {
                        type: 'object',
                        required: ['name'],
                        properties: {
                            name: { type: 'string' },
                            description: { type: 'string' },
                            actionKey: { type: 'string' },
                        },
                        additionalProperties: true,
                    },
                },
                inputs: { type: 'array' },
            },
            additionalProperties: true,
        },
        tests: { type: 'object', additionalProperties: true },
        businessRules: { type: 'object', additionalProperties: true },
        dependencies: { type: 'object', additionalProperties: true },
    },
    additionalProperties: true,
};
const validateRequirements = ajv.compile(requirementsSchema);
function topicFrom(file) {
    return path.basename(file).replace(/\.(ya?ml)$/i, '');
}
async function loadYaml(file) {
    const text = await fs.readFile(file, 'utf8');
    return YAML.parse(text);
}
function classifyErrors(errors) {
    const list = [];
    for (const err of errors || []) {
        const severity = err.keyword === 'required' ? 'P0' : 'P1';
        const pointer = err.instancePath || err.schemaPath || '';
        list.push({ severity, message: `${err.keyword}: ${err.message ?? 'invalid'}`, path: pointer });
    }
    return list;
}
async function ensurePlanningDir(repoDir, topic, sub) {
    const cfg = await resolveProject(repoDir);
    const base = path.join(repoDir, cfg.artifactsDir || '.artifacts', 'planning', topic);
    const finalPath = sub ? path.join(base, sub) : base;
    await fs.ensureDir(finalPath);
    return { base, finalPath };
}
export async function requirementsValidate(repoDir, file) {
    const absolute = path.isAbsolute(file) ? file : path.join(repoDir, file);
    const topic = topicFrom(absolute);
    const data = await loadYaml(absolute);
    const isValid = validateRequirements(data);
    const issues = classifyErrors(validateRequirements.errors);
    if (!data?.tests?.scenarios || data.tests.scenarios.length === 0) {
        issues.push({ severity: 'P0', message: 'tests.scenarios must include at least one entry', path: '/tests/scenarios' });
    }
    if (!data?.actionLayer?.actions || data.actionLayer.actions.length === 0) {
        issues.push({ severity: 'P0', message: 'actionLayer.actions must include at least one action', path: '/actionLayer/actions' });
    }
    const { base } = await ensurePlanningDir(repoDir, topic);
    const outPath = path.join(base, 'validation.json');
    const report = {
        file: path.relative(repoDir, absolute),
        topic,
        generatedAt: new Date().toISOString(),
        valid: Boolean(isValid) && !issues.some((e) => e.severity === 'P0'),
        issues,
    };
    await fs.writeJson(outPath, report, { spaces: 2 });
    return { ok: report.valid, outPath, issues };
}
export async function requirementsGapcheck(repoDir, topic, file) {
    const target = file ? (path.isAbsolute(file) ? file : path.join(repoDir, file)) : path.join(repoDir, 'docs', 'requirements', `${topic}.yaml`);
    const data = await loadYaml(target);
    const gaps = [];
    if (!data?.businessRules)
        gaps.push({ severity: 'P1', note: 'Add businessRules defaults and edge-case guidance.' });
    if (!data?.tests?.scenarios || data.tests.scenarios.length === 0)
        gaps.push({ severity: 'P0', note: 'Define at least one acceptance scenario under tests.scenarios.' });
    if (!data?.dependencies)
        gaps.push({ severity: 'P1', note: 'List required dependencies (apexLibs, permissionSets, recordTypes).' });
    if (!data?.actionLayer?.inputs || data.actionLayer.inputs.length === 0)
        gaps.push({ severity: 'P1', note: 'Document expected action inputs (key/type/required).' });
    const gapPath = path.join(repoDir, 'docs', 'requirements');
    await fs.ensureDir(gapPath);
    const mdOut = path.join(gapPath, `${topic}.gap_questions.md`);
    const lines = [
        `# Gap Questions - ${topic}`,
        '',
        '## P0 - Blockers',
        ...gaps.filter((g) => g.severity === 'P0').map((g) => `- ${g.note}`),
        '',
        '## P1 - High Priority',
        ...gaps.filter((g) => g.severity === 'P1').map((g) => `- ${g.note}`),
    ];
    await fs.writeFile(mdOut, `${lines.join('\n')}\n`, 'utf8');
    return { ok: gaps.every((g) => g.severity !== 'P0'), gapFile: mdOut, gaps };
}
export async function requirementsIngestDocs(repoDir, topic, sources) {
    const { finalPath } = await ensurePlanningDir(repoDir, topic, 'ingest');
    const written = [];
    for (const src of sources) {
        const absolute = path.isAbsolute(src) ? src : path.join(repoDir, src);
        const body = await fs.readFile(absolute, 'utf8');
        const segments = [];
        const lines = body.split(/\r?\n/);
        let current = { title: 'root', content: [] };
        for (const line of lines) {
            const heading = line.match(/^#{1,6}\s+(.*)$/);
            if (heading) {
                if (current.content.length)
                    segments.push({ title: current.title, content: current.content.join('\n').trim() });
                current = { title: heading[1].trim(), content: [] };
            }
            else {
                current.content.push(line);
            }
        }
        if (current.content.length)
            segments.push({ title: current.title, content: current.content.join('\n').trim() });
        const outName = `${path.basename(absolute).replace(/[^A-Za-z0-9_.-]/g, '_')}.json`;
        const outPath = path.join(finalPath, outName);
        await fs.writeJson(outPath, { source: path.relative(repoDir, absolute), generatedAt: new Date().toISOString(), sections: segments }, { spaces: 2 });
        written.push(outPath);
    }
    return { ok: true, files: written };
}
export async function requirementsDissect(repoDir, topic) {
    const { finalPath, base } = await ensurePlanningDir(repoDir, topic, 'ingest');
    let entries = [];
    try {
        const files = await fs.readdir(finalPath);
        entries = await Promise.all(files.filter((f) => f.endsWith('.json')).map((f) => fs.readJson(path.join(finalPath, f))));
    }
    catch {
        entries = [];
    }
    const buckets = { summary: [], goals: [], requirements: [], constraints: [], acceptance: [] };
    for (const entry of entries) {
        for (const section of entry.sections || []) {
            const title = String(section.title || '').toLowerCase();
            const content = section.content || '';
            if (!content.trim())
                continue;
            if (title.includes('goal'))
                buckets.goals.push(content);
            else if (title.includes('constraint') || title.includes('risk'))
                buckets.constraints.push(content);
            else if (title.includes('acceptance') || title.includes('test'))
                buckets.acceptance.push(content);
            else if (title.includes('require') || title.includes('need'))
                buckets.requirements.push(content);
            else if (title.includes('summary') || title.includes('overview'))
                buckets.summary.push(content);
            else
                buckets.requirements.push(content);
        }
    }
    const dissectOut = path.join(base, 'dissect.json');
    await fs.writeJson(dissectOut, { topic, generatedAt: new Date().toISOString(), buckets }, { spaces: 2 });
    return { ok: true, outPath: dissectOut };
}
function extractObjects(chunks) {
    const set = new Set();
    for (const chunk of chunks) {
        const matches = chunk.match(/([A-Za-z0-9_]+__c)/g);
        for (const m of matches || [])
            set.add(m);
    }
    return Array.from(set);
}
export async function requirementsAssemble(repoDir, topic, dissectPath) {
    const { base } = await ensurePlanningDir(repoDir, topic);
    const source = dissectPath ? (path.isAbsolute(dissectPath) ? dissectPath : path.join(repoDir, dissectPath)) : path.join(base, 'dissect.json');
    const dissect = await fs.readJson(source).catch(() => ({ buckets: { summary: [], goals: [], requirements: [], constraints: [], acceptance: [] } }));
    const buckets = dissect.buckets || { summary: [], goals: [], requirements: [], constraints: [], acceptance: [] };
    const objects = extractObjects([...buckets.requirements, ...buckets.summary]);
    const primary = objects[0] || `${topic}__c`;
    const actionCandidates = buckets.requirements
        .flatMap((item) => item.split(/\n+/))
        .map((line) => line.trim())
        .filter(Boolean)
        .slice(0, 8);
    const actions = actionCandidates.map((line, idx) => ({
        name: line.split(/[:\-]/)[0].trim().toLowerCase() || `action_${idx + 1}`,
        description: line,
        actionKey: `${primary.replace(/__c$/, '')}.${(line.split(/[:\s]/)[0] || 'action').toLowerCase()}`,
    }));
    const yamlDoc = {
        specVersion: '1.0',
        project: topic,
        scope: { objects, primaryObject: primary },
        actionLayer: {
            invocableMethod: {
                className: `${primary.replace(/__c$/, '')}Handler`,
                methodName: 'invoke',
                methodLabel: `${primary.replace(/__c$/, '')} Action`,
                singleOutputEnvelope: { contractName: `${primary.replace(/__c$/, '')}ActionEnvelope`, version: '1.0' },
            },
            actions,
            inputs: [],
        },
        businessRules: { summary: buckets.constraints },
        tests: { scenarios: buckets.acceptance },
        dependencies: {},
    };
    const docsDir = path.join(repoDir, 'docs', 'requirements');
    await fs.ensureDir(docsDir);
    const outPath = path.join(docsDir, `${topic}.yaml`);
    const yamlText = YAML.stringify(yamlDoc, { lineWidth: 80 });
    await fs.writeFile(outPath, yamlText, 'utf8');
    return { ok: true, outPath };
}
