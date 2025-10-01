#!/bin/bash
echo "Restarting MCP server..."
kill $(lsof -t -i:8787) 2>/dev/null || true
sleep 2
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true
python3 mcp_server_comprehensive.py --port 8787 --dry-run > logs/mcp_server_restart.log 2>&1 &
sleep 5
echo "Server restarted. Health check:"
curl -s http://localhost:8787/health | jq '.status'
echo "Last 30 lines of log:"
tail -30 logs/mcp_server_restart.log
