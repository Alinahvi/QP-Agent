AGENTS Guide — MCP Planning & Discovery (No‑Git)
- You may override via tool `--repoDir` or set `artifactsDir` in `.mcp.project.json`.
- Artifacts default to `.artifacts/` under the repo. The server auto‑detects the project root when `repoDir` is missing so artifacts aren’t written to the user profile.

Fanout & Tickets

- Fanout:  `discovery:fromProject`, `discovery:fanout`, `planning:fanout` 
- Tickets:  `tickets:collect`, `tickets:fanout` 

- You may override via tool `--repoDir` or set `artifactsDir` in `.mcp.project.json`.
AGENTS Guide — MCP Planning & Discovery (No‑Git)

Scope

This repo implements a robust, no‑git MCP server for Salesforce projects. It provides Discovery (org + repo), a Planning subsystem (Intake → Propose → Ticketize → Verify), and no‑git orchestrators. This guide documents conventions, how to surface tools in Cursor, and best practices so future agents build on existing work.

Environment

- Node 18+ and TypeScript.
- sf CLI installed and authenticated (org alias set in .mcp.project.json or SF_TARGET_ORG/SFDX_DEFAULTUSERNAME).
- No git dependency: do not call git in tools/orchestrators.

Cursor Integration

- Use McpServer (or registerTool via McpServer) with Zod schemas. Each tool must have: name, title, description, and a Zod input schema. Avoid empty {} schemas.
- Launch server via:
  - node dist/server.js (recommended), or
  - npx -y tsx src/server.ts (dev).
- ESM hygiene: import fs from 'fs-extra' (not import * as fs) and keep esModuleInterop: true.

Key Tools

- Discovery:
  - org:discover_object — Writes .artifacts/discovery/<obj>/object.json (label, fields w/ picklists+relationships, VRs, recordTypes, triggers). Uses org Tooling/Data API with local fallback.
  - org:discover_usage — Writes usage.json (apex/flows/lwcs) combining org queries (ApexClass/Flow markup/LWC Source) and repo scans. Flow entries include element-level actions and fields.
  - org:discover_permissions — Writes permissions.json (crud, fieldPermissions, recordTypeVisibility, customPermissions). Org-first with repo fallback.
  - discovery:plan — Generates plan.json (V1) and plan.v2.json (validated). Also writes a brief.
  - discovery:brief — docs/discovery/<obj>.DiscoveryBrief.md (no git section).
  - discovery:run — Orchestrates object/usage/permissions/plan/brief, writes diagnostics.json.

- Planning:
  - planning:intake — Ingests docs/ActionPlan.md and tickets/* into intake.json.
  - planning:propose — Produces plan.v2.json + docs/plan/<obj>.Plan.md; derives inputs from object fields; seeds tests from usage; validates; updates Plan_Ledger and Session_Log.
  - planning:ticketize — Creates tickets/derived/* from Plan V2.
  - planning:verify — Verifies Plan vs Discovery (CRUD/FLS/required fields) into verify.json.
  - planning:status — Reports freshness of discovery/plan with configurable TTL.
  - planning:resume — If missing/stale, runs intake→propose→ticketize; refreshes discovery & brief.

- Entry Points:
  - discovery:start_from_object — Ensures discovery and a plan exist for an object; refreshes brief.
  - discovery:start_from_lwc — Infers object candidates from LWC @salesforce/schema imports; runs discovery.
  - docs:scan — Reports ActionPlan/Session_Log/plan directory presence and timestamps.

- Orchestrator:
  - release:branch+plan — planning:verify → discovery → brief → scaffold (apply) → agent:doc-sync → deploy:safe → tests (apex + optional agent). Supports dryRun and force.

Utilities:
- schema:index - Precompute `.artifacts/schema/schema_index.json` from LWC `@salesforce/schema` imports (TTL via `staleHours`).
- tests:apex - Run project-scoped Apex tests (modes: `git-diff`, `suite`, `allowlist`).
- tests:agent - Run non-destructive agent utterance tests.
- agent:doc-sync - Sync `@Invocable` descriptions into Agent actions.
- deploy:safe - Deploy with `NoTestRun` (safe path for metadata moves).
- actionlayer:scaffold - Generate/refresh single-output Handler/Service/DTO from plan.
- audit:actionlayer - Audit/repair single-output handler.
- resume:context - Write next-steps (resume) note.

Artifacts

- Discovery: .artifacts/discovery/<obj>/{object.json,usage.json,permissions.json,validation-*.json,diagnostics.json}
- Planning: .artifacts/plan/<obj>.plan.json, <obj>.plan.v2.json (+ validation), docs/plan/<obj>.Plan.md, docs/Plan_Ledger.md, docs/Session_Log.md

Coding Conventions

- Keep functions pure and idempotent; tools should be re‑runnable.
- Validate outputs (Ajv) and write validation reports.
- Prefer org-first discovery with clean fallbacks to local metadata.
- No Network/Git surprises: Only call sf CLI or read local files.
- Return MCP content results as JSON strings (or structuredContent as needed); errors should set isError and explain next steps.

Extending Discovery

- Flow parsing: include conditions/assignments for element‑level accuracy.
- Apex analysis: optionally use SymbolTable (when permitted) for type‑level references.
- Permissions mapping: link CustomPermissions to policy graph (naming conventions → action keys).

Extending Planning

- Derive input variable types and options (picklist values, lookup targets) and add typed DTOs to Plan V2.
- Add ADR‑style entries to Plan_Ledger.md per decision.
- Generate regression checklists and rollout guidance inside the plan doc.

Troubleshooting

- Tools not visible in Cursor: ensure Zod schemas are provided; don’t pass {}. Confirm server launched via node dist/server.js or npx tsx src/server.ts.
- fs-extra ESM: use default import; set esModuleInterop: true in tsconfig.
- sf CLI errors: retry logic exists; check org alias and auth; discovery falls back to local metadata.



Schema Index

- Use schema:index to precompute a map of LWC components → referenced objects/fields (from @salesforce/schema).
- TTL (staleHours, default 12) avoids rescanning big repos. The entrypoint discovery:start_from_lwc consults the index and falls back to ad-hoc scanning if missing.
- Store index at .artifacts/schema/schema_index.json and keep it updated in daily loops or preflight scripts.

Fanout Notes

- Parallelize org-bound work with care; recommended --maxConcurrency 3–5; local-only steps can be higher.
- Prefer TTL-aware fanout (staleHours) to skip fresh artifacts.

Archive and Legacy

- Archived kits live under `docs/_archive/` and should be treated as reference only (`mcp_entrypoints_no_git`, `mcp_fanout_kit`, and planning upgrade deltas/tickets).
- Live implementations are in `src/tools/*` and registered in `src/server.ts`. Do not modify archived kits to change runtime behavior.

Artifacts Location

- Artifacts default to `.artifacts/` under the repo. The server auto‑detects the project root when `repoDir` is missing so artifacts aren’t written to the user profile.
- You may override via tool `--repoDir` or set `artifactsDir` in `.mcp.project.json`.

## MCP Tools
<!-- mcp-tools:start -->
- org:discover_object — Discover Object
  Describe object (fields/rules/triggers).
  inputs: repoDir, orgAlias, objectApiName

- schema:index — Schema Index
  Scan LWC bundles for @salesforce/schema imports; write schema index.
  inputs: repoDir, staleHours

- planning:status — Planning Status
  Report freshness of Discovery + Plan for an object.
  inputs: repoDir, objectApiName, staleHours

- planning:resume — Planning Resume
  Auto-run intake→propose→ticketize only if missing/stale, then refresh discovery & brief.
  inputs: repoDir, orgAlias, objectApiName, staleHours

- discovery:start_from_object — Start From Object
  Run/refresh discovery and ensure a plan/brief exists for an object.
  inputs: repoDir, orgAlias, objectApiName, staleHours

- discovery:start_from_lwc — Start From LWC
  Infer object(s) from LWC schema imports, then run discovery.
  inputs: repoDir, orgAlias, componentName, staleHours

- docs:scan — Scan Docs
  Locate ActionPlan, Session_Log, and plan dir; return metadata.
  inputs: repoDir

- discovery:run — Discovery Orchestrator
  Run object, usage, permissions, plan, and brief in one step.
  inputs: repoDir, orgAlias, objectApiName, branchRef

- repo:tools_catalog — Tools Catalog
  Write .artifacts/catalog/tools.json with current tool list.
  inputs: repoDir, writeFile

- repo:sync_tool_docs — Sync Tool Docs
  Update README.md, AGENTS.md, and .mcp.project.json with tool list.
  inputs: repoDir, readmePath, agentsPath, mcpConfigPath, sectionTitle, dryRun

- planning:intake — Planning Intake
  Parse requirements docs/tickets into structured intake.
  inputs: repoDir, objectApiName, requirementsPath

- planning:propose — Planning Propose
  Generate Plan v2 and human plan doc from Discovery + Intake.
  inputs: repoDir, objectApiName

- planning:ticketize — Planning Ticketize
  Create derived tickets from Plan v2.
  inputs: repoDir, objectApiName

- planning:verify — Planning Verify
  Check Plan v2 consistency against Discovery.
  inputs: repoDir, objectApiName

- architect:central_view — Central View
  Inventory existing handlers/services/invocable methods from repo.
  inputs: repoDir

- architect:impact_matrix — Legacy Impact Matrix
  Summarize legacy impact from discovery + repo.
  inputs: repoDir, objects

- architect:propose_plans — Propose Plans
  Generate Plan v2 JSON + Plan doc per object from discovery.
  inputs: repoDir, objects

- architect:seed_tickets — Seed Tickets
  Create derived tickets from Plan v2.
  inputs: repoDir

- architect:normalize_discovery — Normalize Discovery
  Map non-canonical discovery outputs into canonical object/usage/permissions.
  inputs: repoDir, sourceDir

- org:discover_usage — Discover Usage
  Find Apex/Flows/LWCs referencing the object.
  inputs: repoDir, orgAlias, objectApiName

- org:discover_permissions — Discover Permissions
  Snapshot object/field permissions.
  inputs: repoDir, orgAlias, objectApiName

- discovery:plan — Discovery Plan
  Merge discovery into a build plan.
  inputs: repoDir, objectApiName

- discovery:brief — Discovery Brief
  Render human Discovery Brief (Markdown).
  inputs: repoDir, objectApiName, branchRef

- actionlayer:scaffold — Action Layer Scaffold
  Generate/refresh Handler/Service/DTO from templates (generated|phase2).
  inputs: repoDir, planPath, mode, templateSet, requirementsPath

- actionlayer:requirements_stub — Phase 2 Requirements Stub
  Create a YAML requirements stub for Phase 2 scaffold.
  inputs: repoDir, objectApiName, outPath

- actionlayer:scaffold_phase2 — Scaffold Phase 2 (by Object)
  Generate Handler/Service/Tests for an object using Audience-based templates; auto-create requirements stub if missing.
  inputs: repoDir, objectApiName, mode, planPath, requirementsPath

- tests:apex — Tests: Apex
  Run project-scoped Apex tests.
  inputs: repoDir, orgAlias, mode, fromRef, suiteNames, allowlist, waitSeconds

- tests:agent — Tests: Agent
  Run non-destructive Agent utterance tests.
  inputs: repoDir, orgAlias, waitMinutes

- agent:doc-sync — Agent Doc Sync
  Sync @Invocable descriptions into Agent actions.
  inputs: repoDir, orgAlias, objectApiName

- deploy:safe — Deploy (Safe)
  Deploy with NoTestRun (safe).
  inputs: repoDir, orgAlias, manifestPath

- release:branch — Release Branch
  Deploy + tests (Apex + Agent) orchestrator.
  inputs: repoDir, orgAlias, runAgentTests, apexShards, maxAttempts

- release:branch+plan — Release Branch (with Planning)
  Runs planning verify, discovery, brief, scaffold, doc-sync, deploy, tests.
  inputs: repoDir, orgAlias, objectApiName, runAgentTests, force, dryRun

- audit:actionlayer — Audit Action Layer
  Audit/repair to single-output handler.
  inputs: repoDir, objectApiName, apply

- resume:context — Resume Context
  Write next-steps (resume) note.
  inputs: repoDir, objectApiName

<!-- mcp-tools:end -->
