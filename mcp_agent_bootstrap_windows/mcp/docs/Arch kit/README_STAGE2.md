# Stage 2 — Architecture & Planning Kit (No‑Git)

**Date:** 2025-09-24

This kit lets your MCP server **consume discovery artifacts** and generate:
- **Plan v2 JSON** per object
- **Human Plan** (`docs/<Object>.Plan.md`)
- **Centralized Action View** (`docs/Architecture/Central_View.md`)
- **Legacy Impact Matrix** (`docs/Architecture/Legacy_Impact.md`)
- **Derived tickets** (`tickets/derived/*.md`)

It assumes discovery artifacts exist under `.artifacts/discovery/<Object>/`:
- `object.json`, `usage.json`, `permissions.json`

If your discovery outputs are different, run `architect:normalize_discovery` first to map them into this canonical shape.

## New tools

- `architect:central_view` — Build a centralized inventory of existing handlers/services/actions (from repo).
- `architect:impact_matrix` — Summarize legacy impact from discovery usage + repo scan.
- `architect:propose_plans` — Turn discovery → **Plan v2** (JSON + MD) with CRUD/FLS policy, DTO fields, inputs, output contract (single‑output).
- `architect:seed_tickets` — Create ticket files with frontmatter from the plans.
- `architect:normalize_discovery` — Optional: convert non‑canonical discovery outputs into `object.json`, `usage.json`, `permissions.json`.

## How to install
1. Copy `src/tools/architect.ts` into your repo.
2. Register the tools in `src/server.ts` using `server_registration_patch.txt`.
3. (Optional) copy `scripts/Run-Architect.ps1` for a one‑liner run.
4. Rebuild: `npm run build`.

## One‑liner example
```powershell
scripts\Run-Architect.ps1 -RepoDir . -Objects '["AssignedLearning__c","Audience__c"]'
```
