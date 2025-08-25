#!/bin/bash

# Deploy GitHub Integration to Salesforce
# This script deploys the GitHub integration classes to your Salesforce org

echo "=== Deploying GitHub Integration to Salesforce ==="

# Check if SFDX CLI is installed
if ! command -v sfdx &> /dev/null; then
    echo "Error: SFDX CLI is not installed. Please install it first."
    echo "Visit: https://developer.salesforce.com/tools/sfdxcli"
    exit 1
fi

# Check if we're in a Salesforce DX project
if [ ! -f "sfdx-project.json" ]; then
    echo "Error: Not in a Salesforce DX project directory."
    echo "Please run this script from your project root."
    exit 1
fi

# Deploy the GitHub integration classes
echo "Deploying GitHub Integration classes..."
sfdx force:source:deploy -p force-app/main/default/classes/GitHubIntegrationService.cls
sfdx force:source:deploy -p force-app/main/default/classes/GitHubIntegrationService.cls-meta.xml
sfdx force:source:deploy -p force-app/main/default/classes/GitHubIntegrationServiceTest.cls
sfdx force:source:deploy -p force-app/main/default/classes/GitHubIntegrationServiceTest.cls-meta.xml

echo "=== Deployment Complete ==="
echo ""
echo "Next steps:"
echo "1. Open Salesforce Setup"
echo "2. Go to Apex Classes"
echo "3. Find 'GitHubIntegrationService'"
echo "4. Open the class and add your GitHub token to line 108:"
echo "   request.setHeader('Authorization', 'token YOUR_GITHUB_TOKEN');"
echo "5. Save the class"
echo "6. Test the connection by running:"
echo "   GitHubIntegrationService.testConnection();"
echo ""
echo "Note: Remember to revoke the token you shared earlier and generate a new one!"
