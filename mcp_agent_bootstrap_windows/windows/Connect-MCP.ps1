$ErrorActionPreference = 'Stop'
if (-not $env:MCP_WS_URL) { $env:MCP_WS_URL = 'ws://localhost:5173' }
Write-Host "Connecting to MCP at $env:MCP_WS_URL"
Write-Host "Client config: bootstrap\mcp\client.config.json"
