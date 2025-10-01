const { spawn } = require('child_process');

async function main() {
  const { Client } = await import('/Users/anahvi/Public/Salesforce-vscode/salesforce-dx-project/node_modules/@modelcontextprotocol/sdk/dist/client/index.js');
  const { StdioClientTransport } = await import('/Users/anahvi/Public/Salesforce-vscode/salesforce-dx-project/node_modules/@modelcontextprotocol/sdk/dist/client/stdio.js');

  const serverProcess = spawn('node', ['/Users/anahvi/Public/Salesforce-vscode/salesforce-dx-project/mcp-salesforce-test-service.js'], { stdio: ['pipe', 'pipe', 'inherit'] });

  const client = new Client({
    name: 'mcp-test-client-2',
    version: '1.0.0',
  }, { capabilities: { sampling: {} } });

  const transport = new StdioClientTransport({
    process: serverProcess,
  });

  await client.connect(transport);

  console.log('Connected to server with second client');

  // Example: Query accounts
  const result = await client.callTool({
    name: 'query_soql',
    arguments: {
      query: 'SELECT Id, Name, Industry FROM Account',
      limit: 3
    },
  });

  console.log(JSON.stringify(result, null, 2));

  await client.close();
}

main().catch(console.error);


