#!/bin/bash

# MCP Agent Integration Deployment Script
# This script deploys all MCP integration components to Salesforce

echo "🚀 Starting MCP Agent Integration Deployment..."

# Check if sfdx is installed
if ! command -v sfdx &> /dev/null; then
    echo "❌ Error: sfdx CLI is not installed. Please install it first."
    exit 1
fi

# Check if we're authenticated
echo "🔐 Checking authentication..."
if ! sfdx force:org:display &> /dev/null; then
    echo "❌ Error: Not authenticated to Salesforce. Please run 'sfdx force:auth:web:login' first."
    exit 1
fi

# Get current org info
echo "📋 Current org information:"
sfdx force:org:display

# Deploy metadata
echo "📦 Deploying metadata..."
sfdx force:source:deploy -p force-app/main/default

if [ $? -eq 0 ]; then
    echo "✅ Metadata deployment successful!"
else
    echo "❌ Metadata deployment failed!"
    exit 1
fi

# Run tests
echo "🧪 Running tests..."
sfdx force:apex:test:run -n ANAgentUtteranceRouterViaMCPTest,ANAgentUtteranceLoggerTest,AN_EBPUATRunnerTest,AN_OpenPipeV3_FromMCPTest --wait 10

if [ $? -eq 0 ]; then
    echo "✅ Tests passed!"
else
    echo "❌ Tests failed!"
    exit 1
fi

# Create MCP configuration records
echo "⚙️  Creating MCP configuration records..."
sfdx force:data:record:create -s MCP_Config__mdt -v "DeveloperName=DEV_Config MasterLabel='DEV Config' IsActive__c=true Mode__c=BOTH AuthHeaderName__c='X-MCP-Token' Timeout__c=15 RetryCount__c=2"

if [ $? -eq 0 ]; then
    echo "✅ DEV configuration created!"
else
    echo "⚠️  Warning: Could not create DEV configuration. You may need to create it manually."
fi

# Create static resources
echo "📚 Creating static resources..."
sfdx force:data:record:create -s StaticResource -v "Name=uat_open_pipe_utterances Body=@force-app/main/default/staticresources/uat_open_pipe_utterances.json ContentType=application/json"

if [ $? -eq 0 ]; then
    echo "✅ Static resources created!"
else
    echo "⚠️  Warning: Could not create static resources. You may need to create them manually."
fi

# Display next steps
echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Update the Named Credential 'MCP_Core' with your MCP server URL"
echo "2. Configure MCP_Config__mdt records for your environments"
echo "3. Set up your MCP server with the required endpoints (/route and /analyze)"
echo "4. Test the integration with sample utterances"
echo "5. Wire the Flow 'AgentUtteranceRouterViaMCP' to your agent interface"
echo ""
echo "📖 For detailed setup instructions, see README_MCP_AGENT_INTEGRATION.md"
echo ""
echo "🔧 To test the integration, run:"
echo "sfdx force:apex:execute -f test-mcp-integration.apex"
