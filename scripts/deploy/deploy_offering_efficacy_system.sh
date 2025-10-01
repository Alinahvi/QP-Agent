#!/bin/bash

# Deployment Script for Offering Efficacy System
# This script deploys all components of the ANAgent Offering Efficacy system

echo "🚀 Starting Deployment of ANAgent Offering Efficacy System"
echo "========================================================"

# Set variables
ORG_ALIAS="your-org-alias"  # Change this to your org alias
PACKAGE_NAME="OfferingEfficacySystem"
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

# Check if SFDX is installed
if ! command -v sfdx &> /dev/null; then
    echo "❌ Error: SFDX CLI is not installed or not in PATH"
    echo "Please install SFDX CLI first: https://developer.salesforce.com/tools/sfdxcli"
    exit 1
fi

# Check if org is authorized
echo "🔐 Checking org authorization..."
if ! sfdx force:org:display --targetusername=$ORG_ALIAS &> /dev/null; then
    echo "❌ Error: Org $ORG_ALIAS is not authorized"
    echo "Please authorize the org first: sfdx force:auth:web:login --targetusername=$ORG_ALIAS"
    exit 1
fi

echo "✅ Org $ORG_ALIAS is authorized"
echo ""

# Create deployment package
echo "📦 Creating deployment package..."
DEPLOY_DIR="temp-deploy-$(date +%Y%m%d-%H%M%S)"
mkdir -p $DEPLOY_DIR

# Copy required files
echo "  Copying Apex classes..."
cp force-app/main/default/classes/ANAgentOfferingEfficacyHandler.cls $DEPLOY_DIR/
cp force-app/main/default/classes/ANAgentOfferingEfficacyHandler.cls-meta.xml $DEPLOY_DIR/
cp force-app/main/default/classes/ANAgentOfferingEfficacyService.cls $DEPLOY_DIR/
cp force-app/main/default/classes/ANAgentOfferingEfficacyService.cls-meta.xml $DEPLOY_DIR/
cp force-app/main/default/classes/ANAgentOfferingEfficacyBatchService.cls $DEPLOY_DIR/
cp force-app/main/default/classes/ANAgentOfferingEfficacyBatchService.cls-meta.xml $DEPLOY_DIR/

# Create package.xml
cat > $DEPLOY_DIR/package.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>ANAgentOfferingEfficacyHandler</members>
        <members>ANAgentOfferingEfficacyService</members>
        <members>ANAgentOfferingEfficacyBatchService</members>
        <name>ApexClass</name>
    </types>
    <version>58.0</version>
</Package>
EOF

echo "✅ Deployment package created in $DEPLOY_DIR"
echo ""

# Deploy or validate
if [ "$VALIDATE_ONLY" = true ]; then
    echo "🔍 Validating deployment package..."
    sfdx force:source:deploy --sourcepath=$DEPLOY_DIR --targetusername=$ORG_ALIAS --checkonly
    
    if [ $? -eq 0 ]; then
        echo "✅ Validation successful! No deployment issues found."
    else
        echo "❌ Validation failed! Please fix the issues before deploying."
        exit 1
    fi
else
    echo "🚀 Deploying to org $ORG_ALIAS..."
    sfdx force:source:deploy --sourcepath=$DEPLOY_DIR --targetusername=$ORG_ALIAS
    
    if [ $? -eq 0 ]; then
        echo "✅ Deployment successful!"
        
        # Run post-deployment tests
        echo ""
        echo "🧪 Running post-deployment tests..."
        sfdx force:apex:test:run --classnames="ANAgentOfferingEfficacyHandlerTest,ANAgentOfferingEfficacyServiceTest,ANAgentOfferingEfficacyBatchServiceTest" --targetusername=$ORG_ALIAS --wait=10
        
        if [ $? -eq 0 ]; then
            echo "✅ All tests passed!"
        else
            echo "⚠️  Some tests failed. Check the results for details."
        fi
    else
        echo "❌ Deployment failed! Please check the error messages."
        exit 1
    fi
fi

# Cleanup
echo ""
echo "🧹 Cleaning up temporary files..."
rm -rf $DEPLOY_DIR

echo ""
echo "🎉 Deployment process completed!"
echo ""
echo "📋 Next Steps:"
echo "  1. Run comprehensive testing scripts"
echo "  2. Verify object relationships"
echo "  3. Test batch processing with large datasets"
echo "  4. Validate course linking functionality"
echo ""
echo "📚 Documentation:"
echo "  - Offering-Efficacy-Agent-Guide.md"
echo "  - Offering-Efficacy-Batch-Guide.md"
echo "  - ANAgent-Comprehensive-Summary.md" 