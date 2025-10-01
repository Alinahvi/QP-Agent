param(
  [string]$Src = "force-app"
)

$ErrorActionPreference = 'Stop'
$arguments = @(
  'project','deploy','start',
  '--source-dir', $Src,
  '--ignore-conflicts',
  '--test-level','RunLocalTests',
  '--json','--quiet'
)
$raw = & sf @arguments
$code = $LASTEXITCODE
if ($code -ne 0) {
  Write-Error "sf project deploy start failed with exit code $code"
  exit $code
}
Write-Output $raw
