# MCP Server V3 - Drop-in Pack

This package provides a local MCP server and tools for Salesforce discovery, planning, tickets, and release workflows. Tools are registered in `src/server.ts` with Zod schemas and write artifacts under `.artifacts/`.

## No-Git Policy
- Tools do not call `git` or modify branches.
- Humans create branches, commit, and push. Tools operate locally and against the target org only.
- Daily workflow: branch; run MCP tools locally; review `.artifacts/` outputs; commit curated changes.

## Schema Index & Fanout
- Build Schema Index, then use it for discovery
  - `npx tsx src/server.ts run schema:index --repoDir .`
  - `npx tsx src/server.ts run discovery:start_from_lwc --repoDir . --orgAlias <alias> --componentName <lwc-name>`

- Fanout (registered tools)
  - discovery:fromProject - scan repo to seed objects/LWCs, then fan out.
  - discovery:fanout - parallelize `start_from_object`/`start_from_lwc`.
  - planning:fanout - parallelize `planning:resume` across objects.
  - tickets:collect - index `tickets/` and `tickets/derived/` into `.artifacts/tickets/index.json`.
  - tickets:fanout - run scaffold/deploy/tests for indexed tickets.
  - Guidance: use `--maxConcurrency` 3–5 for org-bound operations and `--staleHours` to avoid rework.

## Quick CLI Examples
- `npx tsx src/server.ts run schema:index --repoDir .`
- `npx tsx src/server.ts run discovery:start_from_lwc --repoDir . --orgAlias innovation --componentName c-audience-builder`
- `npx tsx src/server.ts run discovery:fromProject --repoDir . --orgAlias innovation --maxConcurrency 4 --doPlan true --doBrief true`
- `npx tsx src/server.ts run planning:fanout --repoDir . --orgAlias innovation --objects '["A__c","B__c"]'`
- `npx tsx src/server.ts run tickets:collect --repoDir .`
- `npx tsx src/server.ts run tickets:fanout --repoDir . --orgAlias innovation --maxConcurrency 4 --runScaffold true --runDeploy true --runApex true`
- `npx tsx src/server.ts run audit:actionlayer:fanout --repoDir . --objects '["A__c","B__c"]' --maxConcurrency 4 --apply false`

### Phase 2 Scaffold (from Audience Examples)
- `npx tsx src/server.ts run actionlayer:scaffold --repoDir . --planPath "docs/phase 2/Audience__c.plan.v2.enhanced.json" --mode apply --templateSet phase2 --requirementsPath "docs/phase 2/audience.requirements.yaml"`
- For other objects, provide a Plan V2 path and a requirements YAML (see `docs/phase 2/audience.requirements.yaml`) defining related objects and record type developer name.

### One-shot by Object (MCP-generated YAML)
- Create a requirements stub for an object:
  - `npx tsx src/server.ts run actionlayer:requirements_stub --repoDir . --objectApiName <Object>__c`
- Scaffold using Phase 2 templates (auto-creates stub if missing, derives a plan if provided path exists):
  - `npx tsx src/server.ts run actionlayer:scaffold_phase2 --repoDir . --objectApiName <Object>__c --mode apply`

## MCP Tools
<!-- mcp-tools:start -->
- org:discover_object - Discover Object
  Describe object (fields/rules/triggers).
  inputs: repoDir, orgAlias, objectApiName

- org:discover_usage - Discover Usage
  Find Apex/Flows/LWCs referencing the object.
  inputs: repoDir, orgAlias, objectApiName

- org:discover_permissions - Discover Permissions
  Snapshot object/field permissions.
  inputs: repoDir, orgAlias, objectApiName

- discovery:plan - Discovery Plan
  Merge discovery into a build plan.
  inputs: repoDir, objectApiName

- discovery:brief - Discovery Brief
  Render human Discovery Brief (Markdown).
  inputs: repoDir, objectApiName, branchRef

- discovery:run - Discovery Orchestrator
  Run object, usage, permissions, plan, and brief in one step.
  inputs: repoDir, orgAlias, objectApiName, branchRef

- discovery:fanout - Discovery Fanout
  Run discovery across object and LWC lists.
  inputs: repoDir, orgAlias, objects, lwcComponents, staleHours, maxConcurrency, doPlan, doBrief

- discovery:fromProject - Discovery From Project
  Scan repo for objects/LWCs then run discovery fanout.
  inputs: repoDir, orgAlias, staleHours, maxConcurrency, doPlan, doBrief

- docs:scan - Scan Docs
  Locate ActionPlan, Session_Log, and plan dir; return metadata.
  inputs: repoDir

- schema:index - Schema Index
  Scan LWC bundles for @salesforce/schema imports; write schema index.
  inputs: repoDir, staleHours

- planning:status - Planning Status
  Report freshness of Discovery + Plan for an object.
  inputs: repoDir, objectApiName, staleHours

- planning:resume - Planning Resume
  Auto-run intake->propose->ticketize only if missing/stale, then refresh discovery & brief.
  inputs: repoDir, orgAlias, objectApiName, staleHours

- discovery:start_from_object - Start From Object
  Run/refresh discovery and ensure a plan/brief exists for an object.
  inputs: repoDir, orgAlias, objectApiName, staleHours

- discovery:start_from_lwc - Start From LWC
  Infer object(s) from LWC schema imports, then run discovery.
  inputs: repoDir, orgAlias, componentName, staleHours

- planning:intake - Planning Intake
  Parse requirements docs/tickets into structured intake.
  inputs: repoDir, objectApiName, requirementsPath

- planning:propose - Planning Propose
  Generate Plan v2 and human plan doc from Discovery + Intake.
  inputs: repoDir, objectApiName

- planning:ticketize - Planning Ticketize
  Create derived tickets from Plan v2.
  inputs: repoDir, objectApiName

- planning:verify - Planning Verify
  Check Plan v2 consistency against Discovery.
  inputs: repoDir, objectApiName

- planning:fanout - Planning Fanout
  Resume planning across many objects.
  inputs: repoDir, orgAlias, objects, staleHours, maxConcurrency

- actionlayer:scaffold - Action Layer Scaffold
  Generate/refresh Handler/Service/DTO from templates (generated|phase2).
  inputs: repoDir, planPath, mode, templateSet, requirementsPath

- actionlayer:requirements_stub - Phase 2 Requirements Stub
  Create a YAML requirements stub for Phase 2 scaffold.
  inputs: repoDir, objectApiName, outPath

- actionlayer:scaffold_phase2 - Scaffold Phase 2 (by Object)
  Generate Handler/Service/Tests for an object using Audience-based templates; auto-create requirements stub if missing.
  inputs: repoDir, objectApiName, mode, planPath, requirementsPath

- tests:apex - Tests: Apex
  Run project-scoped Apex tests.
  inputs: repoDir, orgAlias, mode, fromRef, suiteNames, allowlist, waitSeconds

- tests:agent - Tests: Agent
  Run non-destructive Agent utterance tests.
  inputs: repoDir, orgAlias, waitMinutes

- agent:doc-sync - Agent Doc Sync
  Sync @Invocable descriptions into Agent actions.
  inputs: repoDir, orgAlias, objectApiName

- requirements:validate - Requirements Validate
  Validate requirements YAML against schema.
  inputs: repoDir, file

- requirements:gapcheck - Requirements Gapcheck
  Generate gap questions for a requirements topic.
  inputs: repoDir, topic, file

- requirements:ingest_docs - Requirements Ingest Docs
  Parse source docs into structured ingestion JSON.
  inputs: repoDir, topic, sources

- requirements:dissect - Requirements Dissect
  Map ingested notes into template buckets.
  inputs: repoDir, topic

- requirements:assemble - Requirements Assemble
  Produce canonical requirements YAML from dissect output.
  inputs: repoDir, topic, dissectPath

- utterance:seed - Utterance Seed
  Generate an utterance pack from Plan data.
  inputs: repoDir, objectApiName, planPath, outPath

- utterance:run - Utterance Run
  Execute a non-destructive utterance pack.
  inputs: repoDir, orgAlias, pack, mode, scope, waitMinutes, ticketId

- utterance:analyze - Utterance Analyze
  Compare utterance results against expectations.
  inputs: repoDir, pack, resultPath

- deploy:safe - Deploy (Safe)
  Deploy with NoTestRun (safe).
  inputs: repoDir, orgAlias, manifestPath

- deploy_metadata - Deploy Metadata
  Alias for deploy:safe (NoTestRun).
  inputs: repoDir, orgAlias, manifestPath

- release:branch - Release Branch
  Deploy + tests (Apex + Agent) orchestrator.
  inputs: repoDir, orgAlias, runAgentTests, apexShards, maxAttempts

- release:branch+plan - Release Branch (with Planning)
  Runs planning verify, discovery, brief, scaffold, doc-sync, deploy, tests.
  inputs: repoDir, orgAlias, objectApiName, runAgentTests, force, dryRun

- audit:actionlayer - Audit Action Layer
  Audit/repair to single-output handler.
  inputs: repoDir, objectApiName, apply

- audit:actionlayer:fanout - Audit Action Layer Fanout
  Batch audit action-layer handlers.
  inputs: repoDir, objects, maxConcurrency, apply

- resume:context - Resume Context
  Write next-steps (resume) note.
  inputs: repoDir, objectApiName

- repo:tools_catalog - Tools Catalog
  Write .artifacts/catalog/tools.json with current tool list.
  inputs: repoDir, writeFile

- repo:sync_tool_docs - Sync Tool Docs
  Update README.md, AGENTS.md, and .mcp.project.json with tool list.
  inputs: repoDir, readmePath, agentsPath, mcpConfigPath, sectionTitle, dryRun

- tickets:collect - Tickets Collect
  Index tickets and derived tickets into .artifacts.
  inputs: repoDir, includeBacklog, includeDerived, glob

- tickets:fanout - Tickets Fanout
  Execute scaffold/deploy/tests/agent per ticket.
  inputs: repoDir, orgAlias, maxConcurrency, runScaffold, runDeploy, runApex, runAgent

- org:soql - Org SOQL
  Run SOQL via sf data query and capture artifact.
  inputs: repoDir, orgAlias, soql

- org:tooling_soql - Org Tooling SOQL
  Run Tooling API query and capture artifact.
  inputs: repoDir, orgAlias, soql

- org:assign_permission_set - Org Assign Permission Set
  Assign a permission set via sf CLI.
  inputs: repoDir, orgAlias, permissionSetName

- org:agent_test - Org Agent Test
  Run agent utterance test via sf CLI bridge.
  inputs: repoDir, orgAlias, ticketId, agentApiName, utterances, capture, mode, scope, maxTurns, waitMinutes

- scaffold:apex - Scaffold Apex
  Alias for actionlayer:scaffold.
  inputs: repoDir, planPath, mode, templateSet, requirementsPath

<!-- mcp-tools:end -->

