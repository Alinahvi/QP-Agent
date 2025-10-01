---
id: ORG-AGENT-INT-01
priority: P0
object: Global
area: Salesforce MCP
suite:
  - FR_Smoke
allowlist: []
runAgent: true
allowDestructive: false
owner: Platform
created: 2025-09-26
---

# Enable MCP Server to Communicate with Org-Side Agents (Detailed)

## Goal
Wire our MCP workflow to **invoke org-side Agents** and **validate utterance/response** end-to-end. Use the **Salesforce DX MCP GA** tools for stable org I/O and mirror results into `.artifacts/**` so planning/tickets can consume them.

## Background (current state)
- Stage‑1 **Discovery** and Stage‑2 **Planning**/Architecture run locally with org reads.
- We now need the **execution** loop to **round‑trip into the org**:
  - Send utterances to Agents and parse **single‑output JSON envelopes**.
  - Gate changes with **Apex tests** (suite/allowlist; smoke fallback).
  - Seed **permission set** scenarios for positive/negative/partial tests.
- We operate **no‑git**; humans control Git merges.

---

## Design Overview

### Option A — Dual-MCP Orchestration (**Preferred**)
Let the orchestrating client (Cursor/Codex) call the **Salesforce DX MCP** tools directly alongside our **sf‑codex** tools. No bridging code needed.

**Mappings (logical → Salesforce MCP)**
- `org:soql` → `run_soql_query` (GA)
- `org:deploy` → `deploy_metadata` (GA)
- `org:apexTest` → `run_apex_test` (GA)
- `org:agentTest` → `run_agent_test` (GA)
- `org:permsetAssign` → `assign_permission_set` (GA)

> The *names* above are logical intents used in tickets and plans. The agent maps them to the Salesforce MCP tools.

### Option B — Local Proxy Wrappers (optional)
Add thin `org:*` wrappers in **sf‑codex** that shell to `sf` where possible (SOQL, deploy, Apex tests) and **delegate agent tests** to the Salesforce MCP tool. Use only if the orchestrator can’t call both servers natively.

---

## Scope of Work

### A. Tickets & Contracts
1. **Adopt frontmatter** fields in tickets (already in use):
   - `object`, `suite`, `allowlist`, `runAgent`, `allowDestructive`.
2. **Extend tickets:fanout** logic:
   - If `runAgent: true`, enqueue an **agent test** step after deploy + Apex tests.
   - Enforce **non-destructive** default unless `allowDestructive: true`.

### B. Tool Calls (Salesforce MCP)
- **Utterance**
  ```json
  {
    "tool": "run_agent_test",
    "arguments": {
      "orgAlias": "innovation",
      "agentApiName": "Field_Readiness_Agent",
      "utterances": ["Show assignments for learner LP-00123"],
      "context": { "EndUserLanguage": "en-US" },
      "maxTurns": 1,
      "mode": "non_destructive",
      "capture": ["transcript","actions","metrics"]
    }
  }
  ```

- **Apex tests**
  ```json
  {
    "tool": "run_apex_test",
    "arguments": {
      "orgAlias": "innovation",
      "testLevel": "RunSpecifiedTests",
      "classNames": ["FRAGENTAssignedLearningService_Test","FRAGENTAssignedLearningHandler_Test"],
      "format": "json",
      "wait": 60
    }
  }
  ```

- **SOQL (fixtures & pre-checks)**
  ```json
  {
    "tool": "run_soql_query",
    "arguments": {
      "orgAlias": "innovation",
      "soql": "SELECT Id, Name FROM LearnerProfile__c WHERE External_Id__c = 'LP-00123' LIMIT 1"
    }
  }
  ```

- **Permission seeding**
  ```json
  {
    "tool": "assign_permission_set",
    "arguments": {
      "orgAlias": "innovation",
      "permissionSetName": "ACT_Test_Agent_ReadOnly"
    }
  }
  ```

### C. Single‑Output Contract (what the Agent returns)
Handlers return **one** string (the Agent reply) that is a **JSON envelope**:
```json
{
  "contractName": "<Object>ActionEnvelope",
  "version": "1.0",
  "code": "OK | ERROR | DENY",
  "message": "human summary",
  "data": { "records": [ ... ] }
}
```
**Parse steps**
1) From the `transcript`, take the last `role: "agent"` turn → parse `text` as JSON.  
2) Assert `code` and expected action/topic in `actions[]`.  
3) Pull IDs/fields from `data.records` for follow‑ups.

### D. Artifacts (must write)
- `.artifacts/agent/<ticketId>.json`  
  Shape:
  ```json
  {
    "ticketId": "<ID>",
    "input": { "utterance": "..." },
    "response": { "envelope": {}, "actions": [], "metrics": {} },
    "timestamps": { "startedAt": "...", "finishedAt": "..." }
  }
  ```
- `.artifacts/apex/…` — keep JUnit/JSON results (existing standard).
- `.artifacts/deploy/…` — optional deploy logs.

### E. Non‑Destructive Guard
- Default all utterances to `mode: "non_destructive"`.
- Block write/delete intents unless ticket frontmatter sets `allowDestructive: true` **and** the ticket explicitly describes the rollback plan.
- Provide *dry‑run* phrasing for destructive cases (e.g., “Show what you would delete” pattern).

### F. Concurrency & Safety
- Cap **org‑bound** parallelism to **3–5** in fanout.  
- Run **fixtures** check (SOQL) before calling `run_agent_test` so utterances reference **real records**.
- Use **permission set seeding** to flip between positive/negative/partial scenarios.

---

## Implementation Tasks

1. **(Option A) Dual‑MCP usage**
   - Document in `docs/ActionPlan.md` that tickets refer to logical intents and the orchestrator calls Salesforce MCP tools.

2. **(Option B) Optional wrappers** (if needed)
   - Add `org:*` tools in `src/server.ts` (sf‑codex) to call Salesforce MCP counterparts (or `sf` CLI where applicable).
   - Ensure they write the artifacts specified above.

3. **tickets:fanout**
   - Insert steps: perm seeding → fixtures → deploy → Apex tests → **agent tests** (conditional on `runAgent`).  
   - Respect `allowDestructive` and **short‑circuit** to non‑destructive plan if absent.

4. **Schema + Validation**
   - Validate the Agent envelope (code/message/data) and fail with a clear error if not JSON‑parsable.

5. **Docs**
   - Add usage examples to `README` and `AGENTS.md`.  
   - Include the example ticket (below) and a runnable PS script.

---

## Acceptance Criteria (verifiable)

- ✅ **End‑to‑end sample**: `ORG-UTT-01` runs via `tickets:fanout`:
  - `assign_permission_set` applied for read‑only user.
  - `run_soql_query` confirms `LP-00123` exists.
  - `deploy_metadata` (NoTestRun ok).
  - `run_apex_test` passes for allowlist/suites.
  - `run_agent_test` returns `code = "OK"`, expected action/topic, `coherence ≥ 0.75`, `adherence ≥ 0.8`, `latencyMs ≤ 3000`.
  - Artifacts captured under `.artifacts/agent/ORG-UTT-01.json` with transcript + metrics.
- ✅ **Non‑destructive enforced** by default; destructive tests require `allowDestructive: true`.
- ✅ **Concurrency cap** applied; no org throttling observed at default settings.
- ✅ **Documentation updated** with examples.

---

## Example: Server registration (optional proxy wrappers)

```ts
// src/server.ts (sf‑codex), using your adapter.registerTool style + zod

import { z } from 'zod';
// (Assumes orchestrator can also call Salesforce MCP directly; these are optional local intents)

adapter.registerTool(
  'org:agentTest',
  { repoDir: z.string().default('.'), orgAlias: z.string(), agentApiName: z.string(),
    utterances: z.array(z.string()), maxTurns: z.number().int().positive().default(1),
    mode: z.enum(['non_destructive','destructive']).default('non_destructive'),
    capture: z.array(z.enum(['transcript','actions','metrics','artifacts'])).default(['transcript','actions','metrics']),
    context: z.record(z.any()).optional(), ticketId: z.string().optional() },
  async (args) => { /* delegate to Salesforce MCP run_agent_test or write a thin bridge */ }
);
```

---

## Runbook (human)

1. Ensure both MCP servers are registered in Cursor/Codex (sf‑codex + Salesforce DX MCP).
2. Run `tickets:collect` → `tickets:fanout --maxConcurrency 4`.
3. Inspect `.artifacts/agent/<ticketId>.json` output.
4. If an utterance fails, confirm fixtures and permissions; re‑run only the failed ticket.

---

## Out of scope
- True end‑to‑end destructive workflows by default (must be explicitly allowed per ticket with rollback).
- Git automation (humans handle merges).
