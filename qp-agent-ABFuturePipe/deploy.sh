#!/bin/bash

# ABAgentFuturePipeAnalysisHandler Deployment Script
# This script deploys the complete Future Pipeline Analysis system to Salesforce

echo "🚀 Starting ABAgentFuturePipeAnalysisHandler Deployment..."

# Check if sfdx is installed
if ! command -v sfdx &> /dev/null; then
    echo "❌ Salesforce CLI (sfdx) is not installed. Please install it first."
    echo "   Visit: https://developer.salesforce.com/tools/sfdxcli"
    exit 1
fi

# Get org alias from user
echo "📋 Please enter your Salesforce org alias:"
read -r ORG_ALIAS

if [ -z "$ORG_ALIAS" ]; then
    echo "❌ Org alias is required. Exiting."
    exit 1
fi

echo "🔍 Verifying org connection..."
if ! sfdx force:org:display -u "$ORG_ALIAS" &> /dev/null; then
    echo "❌ Cannot connect to org '$ORG_ALIAS'. Please check your authentication."
    echo "   Run: sfdx force:auth:web:login -a $ORG_ALIAS"
    exit 1
fi

echo "✅ Connected to org: $ORG_ALIAS"

# Deploy classes
echo "📦 Deploying Apex classes..."
if sfdx force:source:deploy -p force-app/main/default/classes -u "$ORG_ALIAS" --wait 10; then
    echo "✅ Classes deployed successfully"
else
    echo "❌ Class deployment failed"
    exit 1
fi

# Deploy permission sets
echo "🔐 Deploying permission sets..."
if sfdx force:source:deploy -p force-app/main/default/permissionsets -u "$ORG_ALIAS" --wait 10; then
    echo "✅ Permission sets deployed successfully"
else
    echo "❌ Permission set deployment failed"
    exit 1
fi

# Assign permission set
echo "👤 Assigning permission set to current user..."
if sfdx force:user:permset:assign -n QP_Agent_Pilot_Perms -u "$ORG_ALIAS"; then
    echo "✅ Permission set assigned successfully"
else
    echo "❌ Permission set assignment failed"
    exit 1
fi

# Run tests
echo "🧪 Running test classes..."
if sfdx force:apex:test:run -n TestEnhancedFuturePipelineAnalysis,ABAgentFuturePipeAnalysisServiceEnhanced_Test -u "$ORG_ALIAS" --wait 10 --resultformat human; then
    echo "✅ Tests passed successfully"
else
    echo "❌ Tests failed"
    exit 1
fi

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Next Steps:"
echo "   1. Verify custom objects exist: Agent_Renewals__c, Agent_Cross_Sell__c, Agent_Upsell__c"
echo "   2. Ensure required fields are present (see DEPLOYMENT_MANIFEST.md)"
echo "   3. Test the handlers with sample data"
echo "   4. Review the complete documentation for advanced features"
echo ""
echo "📚 Documentation:"
echo "   - Complete Guide: ABAGENT_FUTURE_PIPE_ANALYSIS_COMPLETE_DOCUMENTATION.md"
echo "   - Deployment Details: DEPLOYMENT_MANIFEST.md"
echo ""
echo "🔧 Quick Test:"
echo "   Run the test classes in Developer Console or use the provided test scripts"
echo ""
echo "✨ Your ABAgentFuturePipeAnalysisHandler is ready to use!"
