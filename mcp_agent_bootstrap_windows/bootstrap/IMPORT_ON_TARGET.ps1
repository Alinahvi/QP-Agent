$ErrorActionPreference = 'Stop'
Write-Host '=== MCP Agent Bootstrap ==='
Write-Host 'Ensure the ZIP contents live in the Salesforce project root before running this script.'

$env:CI = 'true'
$env:SFDX_USE_PROGRESS_BAR = 'false'
if (-not $env:MCP_WS_URL) { $env:MCP_WS_URL = 'ws://localhost:5173' }
Write-Host "Environment defaults applied: CI=$env:CI, SFDX_USE_PROGRESS_BAR=$env:SFDX_USE_PROGRESS_BAR, MCP_WS_URL=$env:MCP_WS_URL"

& scripts/windows/Connect-MCP.ps1
if ($LASTEXITCODE -ne 0) {
  Write-Error 'Connect-MCP.ps1 failed. ACTION NEEDED.'
  exit $LASTEXITCODE
}

& scripts/windows/Deploy-NonInteractive.ps1
if ($LASTEXITCODE -ne 0) {
  Write-Error 'Deploy-NonInteractive.ps1 failed. ACTION NEEDED.'
  exit $LASTEXITCODE
}

& scripts/windows/Run-Tests.ps1
if ($LASTEXITCODE -ne 0) {
  Write-Error 'Run-Tests.ps1 failed. ACTION NEEDED.'
  exit $LASTEXITCODE
}

Write-Host 'Bootstrap complete. Review logs and test-results for outputs.'
