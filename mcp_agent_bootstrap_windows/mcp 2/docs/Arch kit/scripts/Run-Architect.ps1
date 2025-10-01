param(
  [string]$RepoDir = ".",
  [string]$Objects = "[]"
)
Set-Location $RepoDir

# Centralized view of existing code
npx tsx src/server.ts run architect:central_view --repoDir .

# Impact matrix (pass explicit objects or [] to infer)
npx tsx src/server.ts run architect:impact_matrix --repoDir . --objects $Objects

# Propose plans + seed tickets
npx tsx src/server.ts run architect:propose_plans --repoDir . --objects $Objects
npx tsx src/server.ts run architect:seed_tickets  --repoDir .
