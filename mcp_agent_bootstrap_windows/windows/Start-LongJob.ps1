param(
  [Parameter(Mandatory = $true)][string]$Cmd,
  [string]$Log = 'logs\longjob.log'
)

$ErrorActionPreference = 'Stop'
$logPath = [System.IO.Path]::GetFullPath($Log)
$logDir = Split-Path -Parent $logPath
if ($logDir) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$escapedCmd = $Cmd.Replace('"', '""')
$redirected = "pwsh -NoLogo -NoProfile -Command \"$escapedCmd\" >> \"$logPath\" 2>>&1"
Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', $redirected -WindowStyle Hidden | Out-Null
