#!/bin/bash

# 🎯 Deploy Ramp Status Analysis Fix
# This script deploys the updated ANAGENTKPIAnalysisServiceV5 class
# to fix the issue where "slow rampers in LATAM" was calling the wrong Apex class

echo "🚀 Starting Ramp Status Analysis Fix Deployment..."
echo "=================================================="

# Set timestamp for deployment
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
echo "⏰ Deployment timestamp: $TIMESTAMP"

# Create deployment directory
DEPLOY_DIR="temp-deploy-ramp-status-fix-$TIMESTAMP"
mkdir -p "$DEPLOY_DIR"
echo "📁 Created deployment directory: $DEPLOY_DIR"

# Copy the updated class files
echo "📋 Copying updated class files..."

# Copy the main service class
cp "force-app/main/default/classes/ANAGENTKPIAnalysisServiceV5.cls" "$DEPLOY_DIR/"
cp "force-app/main/default/classes/ANAGENTKPIAnalysisServiceV5.cls-meta.xml" "$DEPLOY_DIR/"

# Copy the handler class (if it needs updates)
cp "force-app/main/default/classes/ANAGENTKPIAnalysisHandlerV5.cls" "$DEPLOY_DIR/"
cp "force-app/main/default/classes/ANAGENTKPIAnalysisHandlerV5.cls-meta.xml" "$DEPLOY_DIR/"

echo "✅ Class files copied to deployment directory"

# Deploy using SFDX
echo "🚀 Deploying to Salesforce org..."
echo "📤 Deploying from: $DEPLOY_DIR"

# Deploy the classes using modern SF CLI
sf project deploy start --source-dir "$DEPLOY_DIR" --target-org "$1" --verbose

# Check deployment status
if [ $? -eq 0 ]; then
    echo "🎉 SUCCESS: Ramp Status Analysis Fix deployed successfully!"
    echo ""
    echo "📊 What was fixed:"
    echo "   - ANAGENTKPIAnalysisServiceV5.cls now has comprehensive ramp status context"
    echo "   - Clear examples for 'slow rampers in LATAM' queries"
    echo "   - Proper action selection guidance for agents"
    echo "   - Field mapping documentation for ramp status analysis"
    echo ""
    echo "🔧 Next steps:"
    echo "   1. Test the fix with: 'show me slow rampers in LATAM'"
    echo "   2. Verify KPI Analysis V5 is called instead of OpenPipe Analysis"
    echo "   3. Check that proper ramp status analysis results are returned"
    echo ""
    echo "📚 Documentation created:"
    echo "   - agent-instructions-ramp-status-analysis.md"
    echo "   - agent-instructions-comprehensive-action-selection.md"
    echo ""
else
    echo "❌ ERROR: Deployment failed!"
    echo "Please check the error messages above and try again."
    exit 1
fi

# Clean up deployment directory
echo "🧹 Cleaning up deployment directory..."
rm -rf "$DEPLOY_DIR"
echo "✅ Cleanup complete"

echo ""
echo "🎯 Ramp Status Analysis Fix Deployment Complete!"
echo "================================================"
echo ""
echo "The system should now properly call ANAGENT KPI Analysis V5"
echo "for ramp status queries instead of the wrong OpenPipe Analysis."
echo ""
echo "Test with: 'show me slow rampers in LATAM'"
