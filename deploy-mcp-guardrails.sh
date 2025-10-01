#!/bin/bash

# MCP Guardrails + Full Deployment Script
# Deploys all MCP integration components with safety toggles

echo "🚀 Deploying MCP Integration with Guardrails..."

# 1. Deploy Custom Metadata Type
echo "📋 Deploying MCP_Config__mdt..."
sf project deploy start --source-dir force-app/main/default/objects/MCP_Config__mdt

# 2. Deploy Custom Object
echo "📊 Deploying Agent_Utterance_Log__c..."
sf project deploy start --source-dir force-app/main/default/objects/Agent_Utterance_Log__c

# 3. Deploy Permission Set
echo "🔐 Deploying MCP_Integration Permission Set..."
sf project deploy start --source-dir force-app/main/default/permissionsets/MCP_Integration.permissionset-meta.xml

# 4. Deploy Named Credential
echo "🔑 Deploying MCP_Core Named Credential..."
sf project deploy start --source-dir force-app/main/default/namedCredentials/MCP_Core.namedCredential-meta.xml

# 5. Deploy MCP Router
echo "🧭 Deploying ANAgentUtteranceRouterViaMCP..."
sf project deploy start --source-dir force-app/main/default/classes/ANAgentUtteranceRouterViaMCP.cls

# 6. Deploy MCP Adapters
echo "🔌 Deploying MCP Adapters..."
sf project deploy start --source-dir force-app/main/default/classes/AN_FuturePipeline_FromMCP.cls
sf project deploy start --source-dir force-app/main/default/classes/AN_OpenPipeV3_FromMCP.cls
sf project deploy start --source-dir force-app/main/default/classes/AN_KPI_FromMCP.cls
sf project deploy start --source-dir force-app/main/default/classes/AN_SearchContent_FromMCP.cls
sf project deploy start --source-dir force-app/main/default/classes/AN_SearchSME_FromMCP.cls
sf project deploy start --source-dir force-app/main/default/classes/AN_Workflow_FromMCP.cls

# 7. Deploy UAT Runner
echo "🧪 Deploying AN_EBPUATRunner..."
sf project deploy start --source-dir force-app/main/default/classes/AN_EBPUATRunner.cls

# 8. Deploy Flows
echo "🌊 Deploying Flows..."
sf project deploy start --source-dir force-app/main/default/flows/AgentUtteranceRouterViaMCP_ShadowMode.flow-meta.xml
sf project deploy start --source-dir force-app/main/default/flows/ShadowModeExecution.flow-meta.xml
sf project deploy start --source-dir force-app/main/default/flows/ANAgentUtteranceLogger.flow-meta.xml

# 9. Deploy Static Resources
echo "📚 Deploying Static Resources..."
sf project deploy start --source-dir force-app/main/default/staticresources/SR_UAT_FuturePipeline.json
sf project deploy start --source-dir force-app/main/default/staticresources/SR_UAT_OpenPipeV3.json
sf project deploy start --source-dir force-app/main/default/staticresources/SR_UAT_KPI.json
sf project deploy start --source-dir force-app/main/default/staticresources/SR_UAT_Workflow.json
sf project deploy start --source-dir force-app/main/default/staticresources/SR_UAT_Content.json
sf project deploy start --source-dir force-app/main/default/staticresources/SR_UAT_SME.json

echo "✅ MCP Integration Deployment Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Configure MCP_Config__mdt with your MCP server URL"
echo "2. Set IsActive__c = true, ShadowMode__c = true for testing"
echo "3. Run UAT suite to validate parity"
echo "4. Monitor logs for any issues"
echo "5. Gradually roll out to pilot users"
echo ""
echo "🔧 Configuration Commands:"
echo "sf data create record -s MCP_Config__mdt -v \"DeveloperName=DEV_Config IsActive__c=true ShadowMode__c=true Mode__c=ROUTE BaseUrl__c=https://your-mcp-server.com Timeout__c=10 RetryCount__c=2\""
echo ""
echo "🧪 UAT Commands:"
echo "sf apex run --file uat-future-pipeline-comprehensive.apex"
echo ""
echo "📖 Documentation:"
echo "- ROLLBACK_MCP.md for rollback procedures"
echo "- UAT_FROM_AGENT_UI.md for testing guide"
