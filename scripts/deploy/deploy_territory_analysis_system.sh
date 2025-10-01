#!/bin/bash

# ========================================
# AE Territory Analysis System Deployment Script
# Deploys all Apex classes and metadata for the territory analysis system
# ========================================

echo "🚀 Starting deployment of AE Territory Analysis System..."

# Set error handling
set -e

# Check if we're in the right directory
if [ ! -f "sfdx-project.json" ]; then
    echo "❌ Error: Must run from Salesforce DX project root directory"
    exit 1
fi

# ========================================
# DEPLOYMENT PHASE 1: APEX CLASSES
# ========================================
echo "\n📦 Phase 1: Deploying Apex Classes..."

echo "Deploying ANAgentAETerritoryAnalysisService..."
sf project deploy start --source-dir force-app/main/default/classes/ANAgentAETerritoryAnalysisService.cls

echo "Deploying ANAgentAETerritoryAnalysisHandler..."
sf project deploy start --source-dir force-app/main/default/classes/ANAgentAETerritoryAnalysisHandler.cls

echo "Deploying ANAgentAETerritoryAnalysisBatch..."
sf project deploy start --source-dir force-app/main/default/classes/ANAgentAETerritoryAnalysisBatch.cls

# ========================================
# DEPLOYMENT PHASE 2: METADATA FILES
# ========================================
echo "\n📋 Phase 2: Deploying Metadata Files..."

echo "Deploying Service metadata..."
sf project deploy start --source-dir force-app/main/default/classes/ANAgentAETerritoryAnalysisService.cls-meta.xml

echo "Deploying Handler metadata..."
sf project deploy start --source-dir force-app/main/default/classes/ANAgentAETerritoryAnalysisHandler.cls-meta.xml

echo "Deploying Batch metadata..."
sf project deploy start --source-dir force-app/main/default/classes/ANAgentAETerritoryAnalysisBatch.cls-meta.xml

# ========================================
# DEPLOYMENT PHASE 3: VERIFICATION
# ========================================
echo "\n✅ Phase 3: Verifying Deployment..."

echo "Checking deployment status..."
sf project deploy report

echo "Verifying class compilation..."
sf apex run --file scripts/testing/test_territory_analysis_system.apex

# ========================================
# DEPLOYMENT COMPLETE
# ========================================
echo "\n🎉 AE Territory Analysis System Deployment Complete!"
echo "\n📊 System Components Deployed:"
echo "  ✅ ANAgentAETerritoryAnalysisService.cls"
echo "  ✅ ANAgentAETerritoryAnalysisHandler.cls"
echo "  ✅ ANAgentAETerritoryAnalysisBatch.cls"
echo "  ✅ All metadata files"
echo "\n🔧 Next Steps:"
echo "  1. Add ANAgentAETerritoryAnalysisHandler to your QP-Agent topic"
echo "  2. Configure the topic with the provided instructions"
echo "  3. Test with sample queries"
echo "\n📚 Documentation:"
echo "  - Check the test script output for verification"
echo "  - Review class documentation for usage examples"
echo "  - Use getAvailableAnalysisTypes() for supported analysis types"
echo "\n🚀 Ready for production use!" 