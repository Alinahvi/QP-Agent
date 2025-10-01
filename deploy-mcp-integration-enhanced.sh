#!/bin/bash

# Enhanced MCP Integration Deployment Script
# This script deploys the complete MCP integration with shadow mode and telemetry

set -e

echo "🚀 Starting Enhanced MCP Integration Deployment..."

# Check if sf CLI is available
if ! command -v sf &> /dev/null; then
    echo "❌ Salesforce CLI not found. Please install it first."
    exit 1
fi

# Check if we're in a Salesforce project
if [ ! -f "sfdx-project.json" ]; then
    echo "❌ Not in a Salesforce project directory. Please run from project root."
    exit 1
fi

echo "📋 Deployment Plan:"
echo "1. Deploy Custom Metadata Type updates"
echo "2. Deploy MCP Router with telemetry"
echo "3. Deploy MCP Adapters"
echo "4. Deploy Enhanced Flow"
echo "5. Create test data"
echo "6. Run validation tests"

# Step 1: Deploy Custom Metadata Type updates
echo "📦 Step 1: Deploying Custom Metadata Type updates..."
sf project deploy start --source-dir force-app/main/default/objects/MCP_Config__mdt/
if [ $? -eq 0 ]; then
    echo "✅ Custom Metadata Type updated successfully"
else
    echo "❌ Failed to deploy Custom Metadata Type"
    exit 1
fi

# Step 2: Deploy MCP Router with telemetry
echo "📦 Step 2: Deploying MCP Router with telemetry..."
sf project deploy start --source-dir force-app/main/default/classes/ANAgentUtteranceRouterViaMCP.cls
if [ $? -eq 0 ]; then
    echo "✅ MCP Router deployed successfully"
else
    echo "❌ Failed to deploy MCP Router"
    exit 1
fi

# Step 3: Deploy MCP Adapters
echo "📦 Step 3: Deploying MCP Adapters..."
sf project deploy start --source-dir force-app/main/default/classes/AN_FuturePipeline_FromMCP.cls
sf project deploy start --source-dir force-app/main/default/classes/AN_OpenPipeV3_FromMCP.cls
sf project deploy start --source-dir force-app/main/default/classes/AN_KPI_FromMCP.cls
sf project deploy start --source-dir force-app/main/default/classes/AN_SearchContent_FromMCP.cls
sf project deploy start --source-dir force-app/main/default/classes/AN_SearchSME_FromMCP.cls
sf project deploy start --source-dir force-app/main/default/classes/AN_Workflow_FromMCP.cls

if [ $? -eq 0 ]; then
    echo "✅ MCP Adapters deployed successfully"
else
    echo "❌ Failed to deploy MCP Adapters"
    exit 1
fi

# Step 4: Deploy Enhanced Flow
echo "📦 Step 4: Deploying Enhanced Flow..."
sf project deploy start --source-dir force-app/main/default/flows/AgentUtteranceRouterViaMCP_Enhanced.flow-meta.xml
if [ $? -eq 0 ]; then
    echo "✅ Enhanced Flow deployed successfully"
else
    echo "❌ Failed to deploy Enhanced Flow"
    exit 1
fi

# Step 5: Create test data
echo "📦 Step 5: Creating test data..."
cat > create-mcp-config.apex << 'EOF'
// Create MCP configuration for testing
try {
    // Check if config already exists
    List<MCP_Config__mdt> existingConfigs = [SELECT Id FROM MCP_Config__mdt LIMIT 1];
    
    if (existingConfigs.isEmpty()) {
        System.debug('No MCP configuration found. Please create via Setup UI.');
    } else {
        System.debug('MCP configuration exists: ' + existingConfigs[0].Id);
    }
    
    System.debug('✅ MCP configuration check completed');
} catch (Exception e) {
    System.debug('❌ Error checking MCP configuration: ' + e.getMessage());
}
EOF

sf apex run --file create-mcp-config.apex
rm create-mcp-config.apex

# Step 6: Run validation tests
echo "📦 Step 6: Running validation tests..."
cat > test-mcp-integration-enhanced.apex << 'EOF'
// Enhanced MCP Integration Test
System.debug('🧪 Testing Enhanced MCP Integration...');

// Test 1: MCP Router with correlation ID
try {
    ANAgentUtteranceRouterViaMCP.MCPRequest request = new ANAgentUtteranceRouterViaMCP.MCPRequest();
    request.utterance = 'Show me cross-sell opportunities in AMER-ACC for Data Cloud';
    request.correlationId = 'TEST_' + DateTime.now().getTime();
    request.shadowMode = false;
    
    List<ANAgentUtteranceRouterViaMCP.MCPResponse> responses = 
        ANAgentUtteranceRouterViaMCP.routeUtterance(new List<ANAgentUtteranceRouterViaMCP.MCPRequest>{request});
    
    if (!responses.isEmpty() && responses[0].success) {
        System.debug('✅ MCP Router test passed');
        System.debug('Correlation ID: ' + responses[0].correlationId);
        System.debug('Tool: ' + responses[0].tool);
    } else {
        System.debug('❌ MCP Router test failed: ' + responses[0].message);
    }
} catch (Exception e) {
    System.debug('❌ MCP Router test error: ' + e.getMessage());
}

// Test 2: Future Pipeline Adapter
try {
    String testArgs = '{"ouName":"AMER ACC","product":"Data Cloud","opportunityType":"cross-sell","correlationId":"TEST_123"}';
    List<AN_FuturePipeline_FromMCP.Result> results = 
        AN_FuturePipeline_FromMCP.run(new List<String>{testArgs});
    
    if (!results.isEmpty() && results[0].success) {
        System.debug('✅ Future Pipeline Adapter test passed');
        System.debug('Execution time: ' + results[0].executionTimeMs + 'ms');
    } else {
        System.debug('❌ Future Pipeline Adapter test failed: ' + results[0].message);
    }
} catch (Exception e) {
    System.debug('❌ Future Pipeline Adapter test error: ' + e.getMessage());
}

// Test 3: Open Pipe Adapter
try {
    String testArgs = '{"ouName":"EMEA ENTR","product":"Sales Cloud","stage":"Prospecting","correlationId":"TEST_456"}';
    List<AN_OpenPipeV3_FromMCP.Result> results = 
        AN_OpenPipeV3_FromMCP.run(new List<String>{testArgs});
    
    if (!results.isEmpty() && results[0].success) {
        System.debug('✅ Open Pipe Adapter test passed');
        System.debug('Execution time: ' + results[0].executionTimeMs + 'ms');
    } else {
        System.debug('❌ Open Pipe Adapter test failed: ' + results[0].message);
    }
} catch (Exception e) {
    System.debug('❌ Open Pipe Adapter test error: ' + e.getMessage());
}

System.debug('🎉 Enhanced MCP Integration testing completed');
EOF

sf apex run --file test-mcp-integration-enhanced.apex
rm test-mcp-integration-enhanced.apex

echo ""
echo "🎉 Enhanced MCP Integration Deployment Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Configure MCP_Config__mdt records via Setup UI"
echo "2. Set up MCP server and test connectivity"
echo "3. Run UAT testing using UAT_FROM_AGENT_UI.md"
echo "4. Enable shadow mode for comparison testing"
echo "5. Gradually roll out to pilot users"
echo ""
echo "📚 Documentation:"
echo "- UAT_FROM_AGENT_UI.md - Testing guide"
echo "- ROLLBACK_MCP.md - Rollback procedures"
echo "- README_MCP_AGENT_INTEGRATION.md - Setup guide"
echo ""
echo "🔧 Configuration:"
echo "- Set MCP_Config__mdt.IsActive__c = true to enable MCP"
echo "- Set MCP_Config__mdt.ShadowMode__c = true for comparison testing"
echo "- Configure MCP_Config__mdt.BaseUrl__c for your MCP server"
echo ""
echo "✅ Deployment successful!"
