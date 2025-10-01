async function main() {
  const { Client } = await import('/Users/anahvi/Public/Salesforce-vscode/salesforce-dx-project/node_modules/@modelcontextprotocol/sdk/dist/client/index.js');
  const { StdioClientTransport } = await import('/Users/anahvi/Public/Salesforce-vscode/salesforce-dx-project/node_modules/@modelcontextprotocol/sdk/dist/client/stdio.js');

  const client = new Client({
    name: 'mcp-test-client',
    version: '1.0.0',
  }, { capabilities: { sampling: {} } });

  const transport = new StdioClientTransport({
    command: 'node',
    args: ['/Users/anahvi/Public/Salesforce-vscode/salesforce-dx-project/mcp_agent_bootstrap_windows/mcp/dist/server.js'],
  });

  await client.connect(transport);

  console.log('Connected to server');

  const result = await client.callTool({
    name: 'org:soql',
    arguments: {
      repoDir: '/Users/anahvi/Public/Salesforce-vscode/salesforce-dx-project/mcp_agent_bootstrap_windows',
      orgAlias: 'MySandboxAlias',
      soql: 'SELECT Id, Name FROM Account LIMIT 5',
    },
  });

  console.log(JSON.stringify(result, null, 2));

  await client.close();
}

main().catch(console.error);