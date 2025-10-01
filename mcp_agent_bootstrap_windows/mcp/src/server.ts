// src/server.ts - MCP server (Cursor-friendly via McpServer) + CLI fallback
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

// Tool implementations
import { centralView, impactMatrix, proposePlans, seedTickets, normalizeDiscovery } from './tools/architect.js';
import { orgDiscoverObject, orgDiscoverUsage, orgDiscoverPermissions, discoveryPlan, discoveryRun } from './tools/discovery.js';
import { discoveryBrief } from './tools/brief.js';
import { actionlayerScaffold, phase2RequirementsStub, scaffoldPhase2ForObject } from './tools/scaffold.js';
import { testsApex } from './tools/tests.js';
import { agentDocSync, testsAgent } from './tools/agent.js';
import { deploySafe, releaseBranch, releaseWithPlanning } from './tools/deploy_release.js';
import { auditActionLayer, resumeContext } from './tools/audit_resume.js';
import { planningIntake, planningPropose, planningTicketize, planningVerify } from './tools/planning.js';
import { planningStatus, planningResume, startFromObject, startFromLwc, docsScan } from './tools/entrypoints.js';
import { schemaIndex } from './tools/schema_index.js';
import { repoToolsCatalog, repoSyncToolDocs } from './tools/repo_tools.js';
import { discoveryFanout, discoveryFromProject } from './tools/orchestrator.js';
import { planningFanout, ticketsCollect, ticketsFanout, auditActionLayerFanout } from './tools/orchestrator_tickets.js';
import { requirementsValidate, requirementsGapcheck, requirementsIngestDocs, requirementsDissect, requirementsAssemble } from './tools/requirements.js';
import { utteranceSeed, utteranceRun, utteranceAnalyze } from './tools/utterance.js';
import { orgSoql, orgToolingSoql, orgAssignPermissionSet, orgAgentTest } from './tools/dx.js';
import { agentTestFromUtterances } from './tools/agenttest_from_utterances.js';
import { agentPreview } from './tools/agent_preview.js';

type ToolHandler = (args: any) => Promise<any>;
type ToolDef = {
  name: string;
  title: string;
  description: string;
  schema: any; // z.ZodObject
  handler: ToolHandler;
};

function toolDefs(): ToolDef[] {
  return [
    // Discovery
    { name: 'org:discover_object', title: 'Discover Object', description: 'Describe object (fields/rules/triggers).', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), objectApiName: z.string() }), handler: async ({ repoDir, orgAlias, objectApiName }) => orgDiscoverObject(repoDir, orgAlias, objectApiName) },
    { name: 'org:discover_usage', title: 'Discover Usage', description: 'Find Apex/Flows/LWCs referencing the object.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), objectApiName: z.string() }), handler: async ({ repoDir, orgAlias, objectApiName }) => orgDiscoverUsage(repoDir, orgAlias, objectApiName) },
    { name: 'org:discover_permissions', title: 'Discover Permissions', description: 'Snapshot object/field permissions.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), objectApiName: z.string() }), handler: async ({ repoDir, orgAlias, objectApiName }) => orgDiscoverPermissions(repoDir, orgAlias, objectApiName) },
    { name: 'discovery:plan', title: 'Discovery Plan', description: 'Merge discovery into a build plan.', schema: z.object({ repoDir: z.string().default('.'), objectApiName: z.string() }), handler: async ({ repoDir, objectApiName }) => discoveryPlan(repoDir, objectApiName) },
    { name: 'discovery:brief', title: 'Discovery Brief', description: 'Render human Discovery Brief (Markdown).', schema: z.object({ repoDir: z.string().default('.'), objectApiName: z.string(), branchRef: z.string().default('origin/main') }), handler: async ({ repoDir, objectApiName, branchRef }) => discoveryBrief(repoDir, objectApiName, branchRef) },
    { name: 'discovery:run', title: 'Discovery Orchestrator', description: 'Run object, usage, permissions, plan, and brief in one step.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), objectApiName: z.string(), branchRef: z.string().default('origin/main') }), handler: async ({ repoDir, orgAlias, objectApiName, branchRef }) => discoveryRun(repoDir, orgAlias, objectApiName, branchRef) },
    { name: 'discovery:fanout', title: 'Discovery Fanout', description: 'Run discovery across object and LWC lists.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), objects: z.array(z.string()).optional(), lwcComponents: z.array(z.string()).optional(), staleHours: z.number().int().positive().optional(), maxConcurrency: z.number().int().positive().optional(), doPlan: z.boolean().default(false), doBrief: z.boolean().default(false) }), handler: async ({ repoDir, orgAlias, objects, lwcComponents, staleHours, maxConcurrency, doPlan, doBrief }) => discoveryFanout(repoDir, orgAlias, { objects, lwcComponents, staleHours, maxConcurrency, doPlan, doBrief }) },
    { name: 'discovery:fromProject', title: 'Discovery From Project', description: 'Scan repo for objects/LWCs then run discovery fanout.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), staleHours: z.number().int().positive().optional(), maxConcurrency: z.number().int().positive().optional(), doPlan: z.boolean().default(false), doBrief: z.boolean().default(false) }), handler: async ({ repoDir, orgAlias, staleHours, maxConcurrency, doPlan, doBrief }) => discoveryFromProject(repoDir, orgAlias, staleHours, maxConcurrency, doPlan, doBrief) },

    // Entrypoints & planning
    { name: 'docs:scan', title: 'Scan Docs', description: 'Locate ActionPlan, Session_Log, and plan dir; return metadata.', schema: z.object({ repoDir: z.string().default('.') }), handler: async ({ repoDir }) => docsScan(repoDir) },
    { name: 'schema:index', title: 'Schema Index', description: 'Scan LWC bundles for @salesforce/schema imports; write schema index.', schema: z.object({ repoDir: z.string().default('.'), staleHours: z.number().int().positive().default(12) }), handler: async ({ repoDir, staleHours }) => schemaIndex(repoDir, staleHours) },
    { name: 'planning:status', title: 'Planning Status', description: 'Report freshness of Discovery + Plan for an object.', schema: z.object({ repoDir: z.string().default('.'), objectApiName: z.string(), staleHours: z.number().int().positive().optional() }), handler: async ({ repoDir, objectApiName, staleHours }) => planningStatus(repoDir, objectApiName, staleHours) },
    { name: 'planning:resume', title: 'Planning Resume', description: 'Auto-run intake->propose->ticketize only if missing/stale, then refresh discovery & brief.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), objectApiName: z.string(), staleHours: z.number().int().positive().optional() }), handler: async ({ repoDir, orgAlias, objectApiName, staleHours }) => planningResume(repoDir, orgAlias, objectApiName, staleHours) },
    { name: 'discovery:start_from_object', title: 'Start From Object', description: 'Run/refresh discovery and ensure a plan/brief exists for an object.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), objectApiName: z.string(), staleHours: z.number().int().positive().optional() }), handler: async ({ repoDir, orgAlias, objectApiName, staleHours }) => startFromObject(repoDir, orgAlias, objectApiName, staleHours) },
    { name: 'discovery:start_from_lwc', title: 'Start From LWC', description: 'Infer object(s) from LWC schema imports, then run discovery.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), componentName: z.string(), staleHours: z.number().int().positive().optional() }), handler: async ({ repoDir, orgAlias, componentName, staleHours }) => startFromLwc(repoDir, orgAlias, componentName, staleHours) },
    { name: 'planning:intake', title: 'Planning Intake', description: 'Parse requirements docs/tickets into structured intake.', schema: z.object({ repoDir: z.string().default('.'), objectApiName: z.string(), requirementsPath: z.string().optional() }), handler: async ({ repoDir, objectApiName, requirementsPath }) => planningIntake(repoDir, objectApiName, requirementsPath) },
    { name: 'planning:propose', title: 'Planning Propose', description: 'Generate Plan v2 and human plan doc from Discovery + Intake.', schema: z.object({ repoDir: z.string().default('.'), objectApiName: z.string() }), handler: async ({ repoDir, objectApiName }) => planningPropose(repoDir, objectApiName) },
    { name: 'planning:ticketize', title: 'Planning Ticketize', description: 'Create derived tickets from Plan v2.', schema: z.object({ repoDir: z.string().default('.'), objectApiName: z.string() }), handler: async ({ repoDir, objectApiName }) => planningTicketize(repoDir, objectApiName) },
    { name: 'planning:verify', title: 'Planning Verify', description: 'Check Plan v2 consistency against Discovery.', schema: z.object({ repoDir: z.string().default('.'), objectApiName: z.string() }), handler: async ({ repoDir, objectApiName }) => planningVerify(repoDir, objectApiName) },
    { name: 'planning:fanout', title: 'Planning Fanout', description: 'Resume planning across many objects.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), objects: z.array(z.string()), staleHours: z.number().int().positive().optional(), maxConcurrency: z.number().int().positive().optional() }), handler: async ({ repoDir, orgAlias, objects, staleHours, maxConcurrency }) => planningFanout(repoDir, orgAlias, { objects, staleHours, maxConcurrency }) },

    // Action layer & tests
    { name: 'actionlayer:scaffold', title: 'Action Layer Scaffold', description: 'Generate/refresh Handler/Service/DTO from templates (generated|phase2).', schema: z.object({ repoDir: z.string().default('.'), planPath: z.string(), mode: z.enum(['apply', 'dry-run']).default('dry-run'), templateSet: z.enum(['generated', 'phase2']).default('generated'), requirementsPath: z.string().optional() }), handler: async ({ repoDir, planPath, mode, templateSet, requirementsPath }) => actionlayerScaffold(repoDir, planPath, mode, templateSet, requirementsPath) },
    { name: 'actionlayer:requirements_stub', title: 'Phase 2 Requirements Stub', description: 'Create a YAML requirements stub for Phase 2 scaffold.', schema: z.object({ repoDir: z.string().default('.'), objectApiName: z.string(), outPath: z.string().optional() }), handler: async ({ repoDir, objectApiName, outPath }) => phase2RequirementsStub(repoDir, objectApiName, outPath) },
    { name: 'actionlayer:scaffold_phase2', title: 'Scaffold Phase 2 (by Object)', description: 'Generate Handler/Service/Tests for an object using Audience-based templates; auto-create requirements stub if missing.', schema: z.object({ repoDir: z.string().default('.'), objectApiName: z.string(), mode: z.enum(['apply', 'dry-run']).default('apply'), planPath: z.string().optional(), requirementsPath: z.string().optional() }), handler: async ({ repoDir, objectApiName, mode, planPath, requirementsPath }) => scaffoldPhase2ForObject(repoDir, objectApiName, mode, planPath, requirementsPath) },
    { name: 'tests:apex', title: 'Tests: Apex', description: 'Run project-scoped Apex tests.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), mode: z.enum(['git-diff', 'suite', 'allowlist']).default('suite'), fromRef: z.string().optional(), suiteNames: z.array(z.string()).optional(), allowlist: z.array(z.string()).optional(), waitSeconds: z.number().int().positive().default(2400) }), handler: async ({ repoDir, orgAlias, mode, fromRef, suiteNames, allowlist, waitSeconds }) => testsApex(repoDir, orgAlias, mode, fromRef, suiteNames ?? [], allowlist ?? [], waitSeconds) },
    { name: 'tests:agent', title: 'Tests: Agent', description: 'Run non-destructive Agent utterance tests.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), waitMinutes: z.number().int().positive().default(15) }), handler: async ({ repoDir, orgAlias, waitMinutes }) => testsAgent(repoDir, orgAlias, waitMinutes) },
    { name: 'agent:doc-sync', title: 'Agent Doc Sync', description: 'Sync @Invocable descriptions into Agent actions.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), objectApiName: z.string() }), handler: async ({ repoDir, orgAlias, objectApiName }) => agentDocSync(repoDir, orgAlias, objectApiName) },
    { name: 'requirements:validate', title: 'Requirements Validate', description: 'Validate requirements YAML against schema.', schema: z.object({ repoDir: z.string().default('.'), file: z.string() }), handler: async ({ repoDir, file }) => requirementsValidate(repoDir, file) },
    { name: 'requirements:gapcheck', title: 'Requirements Gapcheck', description: 'Generate gap questions for a requirements topic.', schema: z.object({ repoDir: z.string().default('.'), topic: z.string(), file: z.string().optional() }), handler: async ({ repoDir, topic, file }) => requirementsGapcheck(repoDir, topic, file) },
    { name: 'requirements:ingest_docs', title: 'Requirements Ingest Docs', description: 'Parse source docs into structured ingestion JSON.', schema: z.object({ repoDir: z.string().default('.'), topic: z.string(), sources: z.array(z.string()) }), handler: async ({ repoDir, topic, sources }) => requirementsIngestDocs(repoDir, topic, sources) },
    { name: 'requirements:dissect', title: 'Requirements Dissect', description: 'Map ingested notes into template buckets.', schema: z.object({ repoDir: z.string().default('.'), topic: z.string() }), handler: async ({ repoDir, topic }) => requirementsDissect(repoDir, topic) },
    { name: 'requirements:assemble', title: 'Requirements Assemble', description: 'Produce canonical requirements YAML from dissect output.', schema: z.object({ repoDir: z.string().default('.'), topic: z.string(), dissectPath: z.string().optional() }), handler: async ({ repoDir, topic, dissectPath }) => requirementsAssemble(repoDir, topic, dissectPath) },
    { name: 'utterance:seed', title: 'Utterance Seed', description: 'Generate an utterance pack from Plan data.', schema: z.object({ repoDir: z.string().default('.'), objectApiName: z.string(), planPath: z.string().optional(), outPath: z.string().optional() }), handler: async ({ repoDir, objectApiName, planPath, outPath }) => utteranceSeed(repoDir, objectApiName, planPath, outPath) },
    { name: 'utterance:run', title: 'Utterance Run', description: 'Execute a non-destructive utterance pack.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), pack: z.string(), mode: z.string().optional(), scope: z.string().optional(), waitMinutes: z.number().int().positive().optional(), ticketId: z.string().optional() }), handler: async ({ repoDir, orgAlias, pack, mode, scope, waitMinutes, ticketId }) => utteranceRun({ repoDir, orgAlias, pack, mode, scope, waitMinutes, ticketId }) },
    { name: 'utterance:analyze', title: 'Utterance Analyze', description: 'Compare utterance results against expectations.', schema: z.object({ repoDir: z.string().default('.'), pack: z.string(), resultPath: z.string().optional() }), handler: async ({ repoDir, pack, resultPath }) => utteranceAnalyze(repoDir, pack, resultPath) },

    // Deployment & release
    { name: 'deploy:safe', title: 'Deploy (Safe)', description: 'Deploy with NoTestRun (safe).', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), manifestPath: z.string() }), handler: async ({ repoDir, orgAlias, manifestPath }) => deploySafe(repoDir, orgAlias, manifestPath) },
    { name: 'deploy_metadata', title: 'Deploy Metadata', description: 'Alias for deploy:safe (NoTestRun).', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), manifestPath: z.string() }), handler: async ({ repoDir, orgAlias, manifestPath }) => deploySafe(repoDir, orgAlias, manifestPath) },
    { name: 'release:branch', title: 'Release Branch', description: 'Deploy + tests (Apex + Agent) orchestrator.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), runAgentTests: z.boolean().default(false), apexShards: z.number().int().positive().default(2), maxAttempts: z.number().int().positive().default(1) }), handler: async ({ repoDir, orgAlias, runAgentTests, apexShards, maxAttempts }) => releaseBranch(repoDir, orgAlias, runAgentTests, apexShards, maxAttempts) },
    { name: 'release:branch+plan', title: 'Release Branch (with Planning)', description: 'Runs planning verify, discovery, brief, scaffold, doc-sync, deploy, tests.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), objectApiName: z.string(), runAgentTests: z.boolean().default(false), force: z.boolean().default(false), dryRun: z.boolean().default(false) }), handler: async ({ repoDir, orgAlias, objectApiName, runAgentTests, force, dryRun }) => releaseWithPlanning(repoDir, orgAlias, objectApiName, { runAgentTests, force, dryRun }) },

    // Audit & resume
    { name: 'audit:actionlayer', title: 'Audit Action Layer', description: 'Audit/repair to single-output handler.', schema: z.object({ repoDir: z.string().default('.'), objectApiName: z.string(), apply: z.boolean().default(false) }), handler: async ({ repoDir, objectApiName, apply }) => auditActionLayer(repoDir, objectApiName, apply) },
    { name: 'audit:actionlayer:fanout', title: 'Audit Action Layer Fanout', description: 'Batch audit action-layer handlers.', schema: z.object({ repoDir: z.string().default('.'), objects: z.array(z.string()), maxConcurrency: z.number().int().positive().optional(), apply: z.boolean().default(false) }), handler: async ({ repoDir, objects, maxConcurrency, apply }) => auditActionLayerFanout(repoDir, { objects, maxConcurrency, apply }) },
    { name: 'resume:context', title: 'Resume Context', description: 'Write next-steps (resume) note.', schema: z.object({ repoDir: z.string().default('.'), objectApiName: z.string() }), handler: async ({ repoDir, objectApiName }) => resumeContext(repoDir, objectApiName) },

    // Repo docs & catalog
    { name: 'repo:tools_catalog', title: 'Tools Catalog', description: 'Write .artifacts/catalog/tools.json with current tool list.', schema: z.object({ repoDir: z.string().default('.'), writeFile: z.boolean().default(true) }), handler: async ({ repoDir, writeFile }) => repoToolsCatalog(repoDir, writeFile) },
    { name: 'repo:sync_tool_docs', title: 'Sync Tool Docs', description: 'Update README.md, AGENTS.md, and .mcp.project.json with tool list.', schema: z.object({ repoDir: z.string().default('.'), readmePath: z.string().optional(), agentsPath: z.string().optional(), mcpConfigPath: z.string().optional(), sectionTitle: z.string().default('MCP Tools'), dryRun: z.boolean().default(false) }), handler: async ({ repoDir, readmePath, agentsPath, mcpConfigPath, sectionTitle, dryRun }) => repoSyncToolDocs({ repoDir, readmePath, agentsPath, mcpConfigPath, sectionTitle, dryRun }) },
    { name: 'tickets:collect', title: 'Tickets Collect', description: 'Index tickets and derived tickets into .artifacts.', schema: z.object({ repoDir: z.string().default('.'), includeBacklog: z.boolean().optional(), includeDerived: z.boolean().optional(), glob: z.string().optional() }), handler: async ({ repoDir, includeBacklog, includeDerived, glob }) => ticketsCollect(repoDir, { includeBacklog, includeDerived, glob }) },
    { name: 'tickets:fanout', title: 'Tickets Fanout', description: 'Execute scaffold/deploy/tests/agent per ticket.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), maxConcurrency: z.number().int().positive().optional(), runScaffold: z.boolean().default(false), runDeploy: z.boolean().default(false), runApex: z.boolean().default(false), runAgent: z.boolean().default(false) }), handler: async ({ repoDir, orgAlias, maxConcurrency, runScaffold, runDeploy, runApex, runAgent }) => ticketsFanout(repoDir, orgAlias, { maxConcurrency, runScaffold, runDeploy, runApex, runAgent }) },
    { name: 'org:soql', title: 'Org SOQL', description: 'Run SOQL via sf data query and capture artifact.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), soql: z.string() }), handler: async ({ repoDir, orgAlias, soql }) => orgSoql(repoDir, orgAlias, soql) },
    { name: 'org:tooling_soql', title: 'Org Tooling SOQL', description: 'Run Tooling API query and capture artifact.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), soql: z.string() }), handler: async ({ repoDir, orgAlias, soql }) => orgToolingSoql(repoDir, orgAlias, soql) },
    { name: 'org:assign_permission_set', title: 'Org Assign Permission Set', description: 'Assign a permission set via sf CLI.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), permissionSetName: z.string() }), handler: async ({ repoDir, orgAlias, permissionSetName }) => orgAssignPermissionSet(repoDir, orgAlias, permissionSetName) },
    { name: 'org:agent_test', title: 'Org Agent Test', description: 'Run agent utterance test via sf CLI bridge.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), ticketId: z.string().optional(), agentApiName: z.string().optional(), utterances: z.array(z.string()).optional(), capture: z.array(z.string()).optional(), mode: z.string().optional(), scope: z.string().optional(), maxTurns: z.number().int().positive().optional(), waitMinutes: z.number().int().positive().optional() }), handler: async ({ repoDir, orgAlias, ticketId, agentApiName, utterances, capture, mode, scope, maxTurns, waitMinutes }) => orgAgentTest({ repoDir, orgAlias, ticketId, agentApiName, utterances, capture, mode, scope, maxTurns, waitMinutes }) },
    { name: 'agenttest:from_utterances', title: 'Agent Test From Utterances', description: 'Create an Agent Test from utterances and run it.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), agentApiName: z.string(), testApiName: z.string(), utterances: z.array(z.string()), waitMinutes: z.number().int().positive().default(5), nonDestructive: z.boolean().default(true) }), handler: async ({ repoDir, orgAlias, agentApiName, testApiName, utterances, waitMinutes, nonDestructive }) => agentTestFromUtterances(repoDir, orgAlias, agentApiName, testApiName, utterances, waitMinutes, nonDestructive) },
    { name: 'agent:preview', title: 'Agent Preview', description: 'Start an interactive preview session and save transcripts.', schema: z.object({ repoDir: z.string().default('.'), orgAlias: z.string(), agentApiName: z.string(), clientApp: z.string(), outputDir: z.string().optional(), apexDebug: z.boolean().optional() }), handler: async ({ repoDir, orgAlias, agentApiName, clientApp, outputDir, apexDebug }) => agentPreview(repoDir, orgAlias, agentApiName, clientApp, outputDir, apexDebug) },
    { name: 'scaffold:apex', title: 'Scaffold Apex', description: 'Alias for actionlayer:scaffold.', schema: z.object({ repoDir: z.string().default('.'), planPath: z.string(), mode: z.enum(['apply', 'dry-run']).default('dry-run'), templateSet: z.enum(['generated','phase2']).default('generated'), requirementsPath: z.string().optional() }), handler: async ({ repoDir, planPath, mode, templateSet, requirementsPath }) => actionlayerScaffold(repoDir, planPath, mode, templateSet, requirementsPath) },
  ];
}

// =====================  Start as an MCP server (Cursor-friendly)  =====================
async function startMcp(): Promise<void> {
  const server = new McpServer({ name: 'sf-codex', version: '0.1.0' });
  const defaultRepoDir = (): string => {
    try {
      const here = path.dirname(fileURLToPath(import.meta.url)); // dist folder
      const project = path.resolve(here, '..');
      const root = path.resolve(project, '..');
      const pkg = path.join(root, 'package.json');
      if (fs.existsSync(pkg)) return root;
    } catch {}
    return process.cwd();
  };
  const defs = toolDefs();
  for (const t of defs) {
    server.tool(
      t.name,
      t.description,
      t.schema,
      { title: t.title },
      async (args: any) => {
        const repoDir = args?.repoDir || defaultRepoDir();
        return await t.handler({ ...(args ?? {}), repoDir });
      }
    );
  }
  await server.connect(new StdioServerTransport());
}

// =====================  CLI fallback  =====================
/**
 * node dist/server.js list [--json]
 * node dist/server.js run <tool> --key value ...
 * npx tsx src/server.ts run <tool> --key value ...
 */
async function startCli(): Promise<void> {
  const [, , cmd, toolName, ...rest] = process.argv;
  if (!cmd || (cmd !== 'run' && cmd !== 'list')) {
    console.log('Usage:\\n  node dist/server.js list [--json]\\n  node dist/server.js run <tool> --key value ...');
    process.exit(1);
  }

  // Forgiving argv parser
  const args: Record<string, any> = {};
  for (let i = 0; i < rest.length; i++) {
    const tok = rest[i];
    if (!tok?.startsWith('--')) continue;
    const key = tok.replace(/^--/, '');
    const next = rest[i + 1];
    if (!next || String(next).startsWith('--')) {
      args[key] = key === 'repoDir' ? '.' : true;
    } else {
      let val = next;
      // Collect bracketed JSON arrays seamlessly across spaces
      if (val.startsWith('[')) {
        let j = i + 1;
        while (j + 1 < rest.length && !rest[j].endsWith(']')) {
          j++;
          val += ' ' + rest[j];
        }
        i = j;
      } else {
        i++;
      }
      // Try to coerce values to appropriate types
      let parsed: any = val;
      const trimmed = String(val).trim();
      try {
        if ((trimmed.startsWith('[') && trimmed.endsWith(']')) || (trimmed.startsWith('{') && trimmed.endsWith('}')))
          parsed = JSON.parse(trimmed);
        else if (/^(true|false)$/i.test(trimmed)) parsed = /^true$/i.test(trimmed);
        else if (!Number.isNaN(Number(trimmed)) && trimmed !== '') parsed = Number(trimmed);
      } catch {
        // Fallback for bracketed arrays without proper quoting: [a b] or [a,b]
        if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
          const inner = trimmed.slice(1, -1).trim();
          if (inner.length) {
            parsed = inner
              .split(/[\s,]+/)
              .map((p: string) => p.trim())
              .filter(Boolean)
              .map((p: string) => p.replace(/^['"]|['"]$/g, ''));
          } else {
            parsed = [];
          }
        }
      }
      args[key] = parsed;
    }
  }

  const defs = toolDefs();
  if (cmd === 'list') {
    const minimal = defs.map((d) => ({
      name: d.name,
      title: d.title,
      description: d.description,
      inputs: Object.keys((d.schema?.shape as any) || {}),
    }));
    const asJson = Object.keys(args).some((k) => k === 'json');
    const out = asJson
      ? JSON.stringify(minimal, null, 2)
      : minimal
          .map((t) => `- ${t.name} — ${t.title}\\n  ${t.description}\\n  inputs: ${t.inputs.join(', ') || '(none)'}\\n`)
          .join('\\n');
    process.stdout.write(out + '\\n');
    return;
  }

  const fn = Object.fromEntries(defs.map((d) => [d.name, d.handler]))[toolName];
  if (!fn) {
    console.error(`Unknown tool ${toolName}`);
    process.exit(2);
  }
  if (!args.repoDir) args.repoDir = '.';

  try {
    const result = await fn(args);
    const out = typeof result === 'string' ? result : JSON.stringify(result, null, 2);
    process.stdout.write(out + '\\n');
  } catch (e: any) {
    console.error(e?.stack || e?.message || String(e));
    process.exit(1);
  }
}

// Entrypoint
const isCli = process.argv[2] === 'run' || process.argv[2] === 'list';
if (isCli) {
  startCli();
} else {
  startMcp().catch((e) => {
    console.error('MCP server failed:', e);
    process.exit(1);
  });
}
