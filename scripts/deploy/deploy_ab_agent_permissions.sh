#!/bin/bash

# Deployment Script for AB Agent Permission Set Update
# This script deploys the updated AEAE_AN_Agents_CRUD permission set with AB Agent classes

echo "🚀 Starting Deployment of AB Agent Permission Set Update"
echo "========================================================"

# Set variables
ORG_ALIAS="your-org-alias"  # Change this to your org alias
VALIDATE_ONLY=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --validate-only)
            VALIDATE_ONLY=true
            shift
            ;;
        --org)
            ORG_ALIAS="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--validate-only] [--org ORG_ALIAS]"
            echo "  --validate-only: Only validate, don't deploy"
            echo "  --org ORG_ALIAS: Specify org alias (default: your-org-alias)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "📋 Deployment Configuration:"
echo "  Org Alias: $ORG_ALIAS"
echo "  Validate Only: $VALIDATE_ONLY"
echo ""

# Check if Salesforce CLI is installed
if ! command -v sf &> /dev/null; then
    echo "❌ Error: Salesforce CLI is not installed or not in PATH"
    echo "Please install Salesforce CLI first: https://developer.salesforce.com/tools/sfdxcli"
    exit 1
fi

# Check if org is authorized
echo "🔐 Checking org authorization..."
if ! sf org display --target-org=$ORG_ALIAS &> /dev/null; then
    echo "❌ Error: Org $ORG_ALIAS is not authorized"
    echo "Please authorize the org first: sf org login web --target-org=$ORG_ALIAS"
    exit 1
fi

echo "✅ Org $ORG_ALIAS is authorized"
echo ""

# Create deployment package
echo "📦 Creating deployment package..."
DEPLOY_DIR="temp-deploy-ab-permissions-$(date +%Y%m%d-%H%M%S)"
mkdir -p $DEPLOY_DIR

# Copy required files
echo "  Copying permission set..."
cp force-app/main/default/permissionsets/AEAE_AN_Agents_CRUD.permissionset-meta.xml $DEPLOY_DIR/

# Create package.xml
cat > $DEPLOY_DIR/package.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>AEAE_AN_Agents_CRUD</members>
        <name>PermissionSet</name>
    </types>
    <version>58.0</version>
</Package>
EOF

echo "✅ Deployment package created in $DEPLOY_DIR"
echo ""

# Deploy or validate
if [ "$VALIDATE_ONLY" = true ]; then
    echo "🔍 Validating deployment package..."
    sf project deploy start --source-dir=$DEPLOY_DIR --target-org=$ORG_ALIAS --dry-run
    
    if [ $? -eq 0 ]; then
        echo "✅ Validation successful! No deployment issues found."
    else
        echo "❌ Validation failed! Please check the errors above."
        exit 1
    fi
else
    echo "🚀 Deploying permission set update..."
    sf project deploy start --source-dir=$DEPLOY_DIR --target-org=$ORG_ALIAS
    
    if [ $? -eq 0 ]; then
        echo "✅ Deployment successful!"
        echo ""
        echo "🎉 AB Agent Permission Set has been updated successfully!"
        echo "The following components are now included:"
        echo "  - ABAgentCrossSellAnalysisHandler"
        echo "  - ABAgentCrossSellAnalysisService"
        echo "  - ABAgentRenewalsAnalysisHandler"
        echo "  - ABAgentRenewalsAnalysisService"
        echo "  - ABAgentUpsellAnalysisHandler"
        echo "  - ABAgentUpsellAnalysisService"
        echo "  - Agent_Renewals__c object access"
        echo "  - Agent_Cross_Sell__c object access"
        echo "  - Agent_Upsell__c object access"
        echo ""
        echo "🔧 Next steps:"
        echo "  1. Test the renewals analysis: 'show me slow rampers in LATAM'"
        echo "  2. Verify the agent works when activated"
        echo "  3. Test other AB Agent functionality as needed"
    else
        echo "❌ Deployment failed! Please check the errors above."
        exit 1
    fi
fi

# Cleanup
echo ""
echo "🧹 Cleaning up deployment files..."
rm -rf $DEPLOY_DIR
echo "✅ Cleanup complete"

echo ""
echo "🏁 Deployment process completed!"
