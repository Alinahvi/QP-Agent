param(
  [string]$RepoDir = ".",
  [string]$OrgAlias = "innovation"
)
Set-Location $RepoDir

# 1) Collect tickets
npx tsx src/server.ts run tickets:collect --repoDir .

# 2) Fanout with agent tests enabled by ticket frontmatter (runAgent: true)
npx tsx src/server.ts run tickets:fanout --repoDir . --orgAlias $OrgAlias `
  --maxConcurrency 4 `
  --runScaffold $true --runDeploy $true --runApex $true --runAgent $true
