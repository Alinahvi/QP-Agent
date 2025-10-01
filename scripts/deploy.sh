#!/bin/bash

# Salesforce MCP Integration Deployment Script
# Usage: ./scripts/deploy.sh

set -e  # Exit on any error

echo "🚀 Starting Salesforce MCP Integration Deployment"
echo "=================================================="

# Configuration
SFDX_ALIAS="MySandbox"
USERNAME_PLACEHOLDER="your-username@example.com"

# Check if sfdx is installed
if ! command -v sfdx &> /dev/null; then
    echo "❌ Error: sfdx CLI not found. Please install Salesforce CLI."
    exit 1
fi

# Check if authenticated
echo "🔐 Checking authentication..."
if ! sfdx force:org:display -u $SFDX_ALIAS &> /dev/null; then
    echo "⚠️  Not authenticated to $SFDX_ALIAS"
    echo "Please run one of these commands first:"
    echo ""
    echo "For web login:"
    echo "  sfdx auth:web:login -a $SFDX_ALIAS -r https://test.salesforce.com"
    echo ""
    echo "For JWT:"
    echo "  sfdx auth:jwt:grant -i <clientId> -f <server.key> -u <username> -r https://test.salesforce.com -a $SFDX_ALIAS"
    echo ""
    read -p "Press Enter after authentication, or Ctrl+C to exit..."
fi

echo "✅ Authenticated to $SFDX_ALIAS"

# Deploy source
echo ""
echo "📦 Deploying source to $SFDX_ALIAS..."
sfdx force:source:deploy -u $SFDX_ALIAS -p force-app

if [ $? -eq 0 ]; then
    echo "✅ Source deployment successful"
else
    echo "❌ Source deployment failed"
    exit 1
fi

# Run tests
echo ""
echo "🧪 Running tests..."
sfdx force:apex:test:run -u $SFDX_ALIAS -r human -w 20 -c -t ANAgentOpenPipeViaMCPV1Test

if [ $? -eq 0 ]; then
    echo "✅ Tests passed"
else
    echo "❌ Tests failed"
    exit 1
fi

# Assign permission set
echo ""
echo "🔑 Assigning permission set..."
echo "Note: You may need to update the username in this command"
echo "Current command: sfdx force:user:permset:assign -u $SFDX_ALIAS -n MCP_OpenPipe_Analysis"
echo ""

# Try to assign permission set
sfdx force:user:permset:assign -u $SFDX_ALIAS -n MCP_OpenPipe_Analysis || {
    echo "⚠️  Permission set assignment failed. You may need to:"
    echo "1. Update the username in the command above"
    echo "2. Assign the permission set manually in Setup"
    echo "3. Or run: sfdx force:user:permset:assign -u $SFDX_ALIAS -n MCP_OpenPipe_Analysis --onbehalfof $USERNAME_PLACEHOLDER"
}

echo ""
echo "🎉 Deployment Complete!"
echo "======================="
echo ""
echo "Next steps:"
echo "1. Start your MCP server: python3 mcp_server.py --port 8787 --live"
echo "2. Start ngrok: ngrok http 8787"
echo "3. Update the URL: sfdx force:apex:execute -u $SFDX_ALIAS -f scripts/postdeploy_set_url.apex"
echo "4. Run smoke tests: sfdx force:apex:execute -u $SFDX_ALIAS -f scripts/smoke_tests.apex"
echo ""
echo "For detailed instructions, see: README_DEPLOY_UAT.md"
