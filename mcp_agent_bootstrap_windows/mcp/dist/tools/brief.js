import * as path from 'path';
import { resolveProject } from '../lib/resolver.js';
import { renderToFileWithFallback } from '../lib/templates.js';
import { readJson } from '../lib/fsx.js';
export async function discoveryBrief(repoDir, objectApiName, branchRef = 'origin/main') {
    const cfg = await resolveProject(repoDir);
    const discDir = path.join(repoDir, cfg.artifactsDir, 'discovery', objectApiName);
    const planPath = path.join(repoDir, cfg.artifactsDir, 'plan', `${objectApiName}.plan.json`);
    const tplPath = path.join(repoDir, 'templates', 'brief', 'DiscoveryBrief.md.tmpl');
    const outPath = path.join(repoDir, 'docs', 'discovery', `${objectApiName}.DiscoveryBrief.md`);
    const obj = await readJson(path.join(discDir, 'object.json'));
    const usage = await readJson(path.join(discDir, 'usage.json'));
    const perms = await readJson(path.join(discDir, 'permissions.json'));
    const plan = await readJson(planPath);
    const branch = '';
    const head = '';
    const view = {
        objectApiName, objectLabel: obj.label || objectApiName,
        recordTypes: (obj.recordTypes || []).map((r) => r.apiName).join(', ') || '-',
        keyFields: (plan.dto?.detailFields || []).join(', ') || '-',
        validationRules: obj.validationRules || [],
        triggers: (obj.triggers || []).map((t) => t.name).join(', ') || '-',
        crud: plan.guards?.objectCrud || perms.crud || {},
        fieldUpdateWhitelist: (plan.guards?.fieldUpdateWhitelist || []).join(', ') || '-',
        fieldReadWhitelist: (plan.guards?.fieldReadWhitelist || []).join(', ') || '-',
        whatToAdd: (plan.todo?.whatToAdd || []).map((s) => ({ item: s })),
        niceToHaves: (plan.todo?.niceToHaves || []).map((s) => ({ item: s })),
        impacted: (plan.todo?.impacted || []).map((s) => ({ item: s })),
        rollout: (plan.todo?.rollout || []).map((s) => ({ item: s })),
        tests: (plan.todo?.tests || []).map((s) => ({ item: s })),
        risks: (plan.todo?.risks || []).map((s) => ({ item: s })),
        usageApex: (usage.apex || []).map((a) => a.name),
        usageFlows: (usage.flows || []).map((f) => f.fullName || f.label),
        usageLwc: (usage.lwcs || []).map((l) => l.component || l.resource),
        includeGit: true, branchRef, branch, head,
        generatedAt: new Date().toISOString()
    };
    const fallbackTpl = `# Discovery Brief — {{objectLabel}} ({{objectApiName}})

Generated: {{generatedAt}}

## Object
- Record Types: {{recordTypes}}
- Key Fields: {{keyFields}}
- Triggers: {{triggers}}
- CRUD: {{&crudJson}}

## Field Access
- Read whitelist: {{fieldReadWhitelist}}
- Update whitelist: {{fieldUpdateWhitelist}}

## Validation Rules
{{#validationRules}}
- {{fullName}} — {{#active}}Active{{/active}}{{^active}}Inactive{{/active}}: {{errorMessage}}
{{/validationRules}}
{{^validationRules}}
(none)
{{/validationRules}}

## Usage
- Apex ({{usageApex.length}}):
{{#usageApex}}  - {{.}}
{{/usageApex}}{{^usageApex}}  (none)
{{/usageApex}}
- Flows ({{usageFlows.length}}):
{{#usageFlows}}  - {{.}}
{{/usageFlows}}{{^usageFlows}}  (none)
{{/usageFlows}}
- LWCs ({{usageLwc.length}}):
{{#usageLwc}}  - {{.}}
{{/usageLwc}}{{^usageLwc}}  (none)
{{/usageLwc}}

## Plan Notes
- What to add:
{{#whatToAdd}}  - {{item}}
{{/whatToAdd}}{{^whatToAdd}}  (none)
{{/whatToAdd}}
- Nice to haves:
{{#niceToHaves}}  - {{item}}
{{/niceToHaves}}{{^niceToHaves}}  (none)
{{/niceToHaves}}
- Impacted:
{{#impacted}}  - {{item}}
{{/impacted}}{{^impacted}}  (none)
{{/impacted}}
- Rollout:
{{#rollout}}  - {{item}}
{{/rollout}}{{^rollout}}  (none)
{{/rollout}}
- Tests:
{{#tests}}  - {{item}}
{{/tests}}{{^tests}}  (none)
{{/tests}}
- Risks:
{{#risks}}  - {{item}}
{{/risks}}{{^risks}}  (none)
{{/risks}}
`;
    // Enrich view with pre-rendered JSON for CRUD to keep template simple
    view.crudJson = JSON.stringify(view.crud || {}, null, 0);
    await renderToFileWithFallback(tplPath, fallbackTpl, view, outPath);
    return outPath;
}
