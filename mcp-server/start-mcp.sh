#!/bin/bash
# MCP Server Startup Script

echo "Starting MCP Server for Salesforce Development..."
echo "Org Alias: innovation"
echo "Server URL: ws://localhost:5173"
echo ""
echo "To connect from Cursor:"
echo "1. Open Cursor settings"
echo "2. Add MCP server with URL: ws://localhost:5173"
echo "3. Or use the client config at bootstrap/mcp/client.config.json"
echo ""

# Set environment variables
export SF_TARGET_ORG="innovation"
export MCP_WS_URL="ws://localhost:5173"

# Start the server
echo "Starting server..."
npm run dev
