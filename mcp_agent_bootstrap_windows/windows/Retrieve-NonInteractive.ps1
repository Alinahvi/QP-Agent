$ErrorActionPreference = 'Stop'
$arguments = @(
  'project','retrieve','start',
  '--metadata','ApexClass,ApexTrigger',
  '--json','--quiet'
)
$raw = & sf @arguments
$code = $LASTEXITCODE
if ($code -ne 0) {
  Write-Error "sf project retrieve start failed with exit code $code"
  exit $code
}
Write-Output $raw
