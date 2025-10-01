param(
  [string]$RepoDir = ".",
  [string]$OrgAlias = "innovation",
  [string]$ObjectApiName = ""
)

if ([string]::IsNullOrWhiteSpace($ObjectApiName)) {
  Write-Host "Usage: scripts\Run-MCP-Plan.ps1 -RepoDir . -OrgAlias innovation -ObjectApiName <Object>" -ForegroundColor Yellow
  exit 1
}

Set-Location $RepoDir

# Discovery
npx tsx src/server.ts run org:discover_object      --repoDir . --orgAlias $OrgAlias --objectApiName $ObjectApiName
npx tsx src/server.ts run org:discover_usage       --repoDir . --orgAlias $OrgAlias --objectApiName $ObjectApiName
npx tsx src/server.ts run org:discover_permissions --repoDir . --orgAlias $OrgAlias --objectApiName $ObjectApiName

# Planning
npx tsx src/server.ts run planning:intake          --repoDir . --objectApiName $ObjectApiName
npx tsx src/server.ts run planning:propose         --repoDir . --objectApiName $ObjectApiName
npx tsx src/server.ts run planning:ticketize       --repoDir . --objectApiName $ObjectApiName
