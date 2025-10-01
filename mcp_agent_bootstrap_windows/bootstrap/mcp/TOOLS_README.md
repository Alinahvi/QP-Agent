# MCP Tools

## Endpoints
- ws://localhost:5173 (probe failed: Received network error or non-101 status code)
- ws://127.0.0.1:5173 (probe failed: Received network error or non-101 status code)

## Capabilities & Auth
- Capabilities: unavailable (websocket handshake failed; server defaults documented in src/server.ts)
- Auth: none required (MCP server runs locally over stdio or websocket bridge)

## Tool Catalog
- 45 registered tools captured via node mcp/dist/server.js list noop --json. See registry.json for structured list.

## Adapters
- No file/http/shell adapters are registered in mcp/src/server.ts.
