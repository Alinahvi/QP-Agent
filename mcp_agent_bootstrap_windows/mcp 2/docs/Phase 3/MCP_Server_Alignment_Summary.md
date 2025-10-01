# MCP Server Alignment Summary — Goals & Ticket Plan
*Date:* 2025-09-26 · *Target:* Bring current MCP server inline with the standardized, **requirements‑driven**, CLI‑first flow.

---

## 1) What you have right now (high level)
**Registered tools (from `src/server.ts`):**
```
actionlayer:requirements_stub, actionlayer:scaffold, actionlayer:scaffold_phase2, agent:doc-sync, architect:central_view, architect:impact_matrix, architect:normalize_discovery, architect:propose_plans, architect:seed_tickets, audit:actionlayer, deploy:safe, discovery:brief, discovery:plan, discovery:run, discovery:start_from_lwc, discovery:start_from_object, docs:scan, org:discover_object, org:discover_permissions, org:discover_usage, planning:intake, planning:propose, planning:resume, planning:status, planning:ticketize, planning:verify, release:branch, release:branch+plan, repo:sync_tool_docs, repo:tools_catalog, resume:context, schema:index, sf-codex, tests:agent, tests:apex
```

**Implemented but *not* registered (in code under `src/tools/orchestrator*.ts`):**
```
discovery:fromProject, discovery:fanout, planning:fanout, tickets:collect, tickets:fanout, audit:actionlayer:fanout
```

**Observations**
- You already have strong coverage for **discovery**, **planning v2**, **scaffolding**, **Apex tests**, **agent tests**, **deploy**, and an **action‑layer audit**.
- Orchestrator/fanout surfaces (**discovery/tickets/planning fanout**) exist but are not exposed as MCP tools.
- Requirements‑stage and Virtual‑UAT tooling are **not** present yet (validation, gapcheck, doc→req ingestion; utterance run/analyze).
- DX convenience wrappers (e.g., raw **SOQL** calls, **assign_permission_set**) are not exposed as tools.

---

## 2) Goals (what “aligned” looks like)
1. **Single requirements file in; everything else out.** Phase‑gated: validate → discovery → plan → ticketize → scaffold → deploy/tests → audit → virtual UAT.
2. **Output‑driven action design** so agent chains inputs↔outputs deterministically (single JSON envelope per handler).
3. **Org‑safe fanout** with 3–5 concurrency on org‑bound steps; higher for local tasks.
4. **Deterministic testing**: repo‑scoped suites/allowlists; *AgentCore → Service → Handler* order.
5. **Virtual UAT** (utterance replay) tied to expected envelopes; safe dummy‑scope for destructive tests.
6. **Permissions model** aligned to **View / Edit / Full** tiers; only Edit/Admin can execute compound actions; PSG/ActionKey gates enforced in Services.
7. **No‑git operating model**: tools never assume branches; humans commit curated outputs.

---

## 3) Delta → Tickets (prioritized, with acceptance criteria)

### A. Orchestrator registration (unlock fanout) — *P0*
- **MCP‑TOOL‑01** — *Register* `discovery:fromProject` → `discoveryFromProject()`  
  **AC:** Tool listed by `repo:tools_catalog`; CLI works; writes `.artifacts/discovery/fanout_report.json`.
- **MCP‑TOOL‑02** — *Register* `discovery:fanout` → `discoveryFanout()`  
  **AC:** Takes `objects[]`, `lwcComponents[]`, `staleHours`, `maxConcurrency`; honors 3–5 default.
- **MCP‑TOOL‑03** — *Register* `planning:fanout` → `planningFanout()`  
  **AC:** Runs `planning:resume` across many objects; writes `.artifacts/planning/fanout.json`.
- **MCP‑TOOL‑04** — *Register* `tickets:collect` → `ticketsCollect()`  
  **AC:** Index created at `.artifacts/tickets/index.json` from `tickets/**` and `tickets/derived/**`.
- **MCP‑TOOL‑05** — *Register* `tickets:fanout` → `ticketsFanout()`  
  **AC:** For each ticket: optional scaffold→deploy→apex; obeys ticket frontmatter `suite/allowlist/runAgent`.
- **MCP‑TOOL‑06** — *Register* `audit:actionlayer:fanout` → `auditActionLayerFanout()`  
  **AC:** Batch audit writes `.artifacts/review/audit_fanout.json`; single‑output and AgentCore usage checks present.

### B. Requirements stage (doc → YAML) — *P0*
- **REQ‑01** — Add `requirements:validate` (schema Ajv)  
  **AC:** Validates `docs/requirements/*.yaml` → `.artifacts/planning/<topic>/validation.json` with 0 P0 errors.
- **REQ‑02** — Add `requirements:gapcheck`  
  **AC:** Produces `docs/requirements/<topic>.gap_questions.md` with P0/P1 lists.
- **REQ‑03** — Add doc‑ingestion triplet:  
  - `requirements:ingest_docs` (parse PDFs/MD) → `.artifacts/planning/<topic>/ingest/*.json`  
  - `requirements:dissect` (map to template sections) → `dissect.json`  
  - `requirements:assemble` (emit final YAML) → `docs/requirements/<topic>.yaml`  
  **AC:** CLI runbook works; outputs deterministic.

### C. Virtual UAT — *P0*
- **UAT‑01** — `utterance:seed` (from actions/use cases) → `docs/utterances/<topic>.yaml`  
- **UAT‑02** — `utterance:run --mode live --scope dummy` (N× replay) → `.artifacts/utterance/results.json`  
- **UAT‑03** — `utterance:analyze` (diff vs expected; create tickets)  
  **AC:** Pass‑rate threshold supported; destructive ops scoped to dummy sets.

### D. DX wrappers (org I/O convenience) — *P1*
- **DX‑01** — `org:soql` & `org:tooling_soql` (thin wrappers over existing `dataQuery`/`toolingQuery`)  
  **AC:** Return JSON rows; logged in `.artifacts/dx/soql/*.json`.
- **DX‑02** — `org:assign_permission_set`  
  **AC:** Assigns PSG from requirements; logs success/failure.
- **DX‑03** — Alias `deploy_metadata` → `deploy:safe`  
  **AC:** Back‑compat CLI alias exists.

### E. Naming/aliases & docs — *P1*
- **DOC‑01** — Alias `scaffold:apex` → `actionlayer:scaffold`; update README examples.  
- **DOC‑02** — Expand `README.md` with **phase gates** and the end‑to‑end CLI playbook.  
- **DOC‑03** — Ensure `repo:tools_catalog` + `repo:sync_tool_docs` generate a human‑readable tools table.

### F. Concurrency & TTL guardrails — *P1*
- **OPS‑01** — Default org‑bound concurrency **3–5**; local tasks can go higher.  
- **OPS‑02** — Planning TTL **24h** (already present) — document & expose via `--staleHours` on fanouts.

---

## 4) Ready‑to‑run CLI (after tickets A+B are done)
```bash
# Phase 0 — Validate single requirements file
npx tsx src/server.ts run requirements:validate --file docs/requirements/<topic>.yaml
npx tsx src/server.ts run requirements:gapcheck  --topic <topic>

# Phase 1 — Discovery
npx tsx src/server.ts run discovery:fromProject --repoDir . --orgAlias <alias> --maxConcurrency 4 --doPlan true --doBrief true

# Phase 2 — Plan & tickets
npx tsx src/server.ts run planning:fanout --repoDir . --orgAlias <alias> --objects '["A__c","B__c"]'
npx tsx src/server.ts run tickets:collect --repoDir .
npx tsx src/server.ts run tickets:fanout  --repoDir . --orgAlias <alias> --runScaffold true --runDeploy true --runApex true

# Phase 3 — Virtual UAT
npx tsx src/server.ts run utterance:run    --pack docs/utterances/<topic>.yaml --mode live --scope dummy
npx tsx src/server.ts run utterance:analyze --pack docs/utterances/<topic>.yaml

# Phase 4 — Batch audit
npx tsx src/server.ts run audit:actionlayer:fanout --repoDir . --objects '["A__c","B__c"]' --maxConcurrency 4 --apply false
```

---

## 5) Effort & owners (blunt estimate)
- **P0 (register fanouts + requirements + UAT):** 2–3 engineer days.
- **P1 (DX wrappers, aliases, docs, guardrails):** 1–2 days.
- **Risk:** low. Most code already exists; it’s tool **registration**, **light wrappers**, and **doc glue**.

---

## 6) Links to update after merge
- `README.md` — quickstart and fanout examples
- `.mcp.project.json` — ensure artifactsDir and toolCatalog path are correct
- `.artifacts/catalog/tools.json` — refresh via `repo:tools_catalog`
