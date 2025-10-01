#!/bin/bash

# ANAgentSMESearchHandler Deployment Script
# This script deploys the complete SME Search system to Salesforce

echo "🚀 Starting ANAgentSMESearchHandler Deployment..."

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

# Run tests
echo "🧪 Running test classes..."
if sfdx force:apex:test:run -n ANAgentSMESearchHandler,ANAgentSMESearchHandlerSimple -u "$ORG_ALIAS" --wait 10 --resultformat human; then
    echo "✅ Tests passed successfully"
else
    echo "❌ Tests failed"
    exit 1
fi

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Next Steps:"
echo "   1. Verify custom objects exist: AGENT_SME_ACADEMIES__c, AGENT_OU_PIPELINE_V2__c, Learner_Profile__c"
echo "   2. Ensure required fields are present (see DEPLOYMENT_MANIFEST.md)"
echo "   3. Test the handlers with sample data"
echo "   4. Configure MCP integration if needed"
echo "   5. Review the complete documentation for advanced features"
echo ""
echo "📚 Documentation:"
echo "   - Complete Guide: ANAGENT_SME_SEARCH_COMPLETE_DOCUMENTATION.md"
echo "   - Deployment Details: DEPLOYMENT_MANIFEST.md"
echo "   - Implementation Guide: README_SME_SEARCH.md"
echo "   - Data Quality Analysis: sme_data_audit.md"
echo ""
echo "🔧 Quick Test:"
echo "   Run the following in Developer Console:"
echo "   ANAgentSMESearchHandler.SMESearchRequest request = new ANAgentSMESearchHandler.SMESearchRequest();"
echo "   request.searchTerm = 'Sales Cloud';"
echo "   request.searchType = 'PRODUCT';"
echo "   List<ANAgentSMESearchHandler.SMESearchResponse> responses = ANAgentSMESearchHandler.searchSMEs(new List<ANAgentSMESearchHandler.SMESearchRequest>{request});"
echo ""
echo "✨ Your ANAgentSMESearchHandler is ready to use!"
