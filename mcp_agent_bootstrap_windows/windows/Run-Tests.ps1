$ErrorActionPreference = 'Stop'
$resultsDir = [System.IO.Path]::GetFullPath('test-results')
New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null
$arguments = @(
  'apex','run','test',
  '--result-format','human',
  '--output-dir',$resultsDir,
  '--code-coverage',
  '--json','--quiet'
)
$raw = & sf @arguments
$code = $LASTEXITCODE
if ($code -ne 0) {
  Write-Error "sf apex run test failed with exit code $code"
  exit $code
}
Write-Output $raw
