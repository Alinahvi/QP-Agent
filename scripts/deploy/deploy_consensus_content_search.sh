#!/bin/bash

# Deploy Consensus Content Search System
# This script deploys the new Consensus content search functionality

echo "=== Deploying Consensus Content Search System ==="
echo "Timestamp: $(date)"
echo ""

# Set deployment directory
DEPLOY_DIR="temp-deploy-consensus-content-search-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DEPLOY_DIR"

echo "Created deployment directory: $DEPLOY_DIR"
echo ""

# Copy files to deployment directory
echo "Copying files to deployment directory..."

# Copy the new classes
cp "force-app/main/default/classes/ANAgentConsensusContentSearchService.cls" "$DEPLOY_DIR/"
cp "force-app/main/default/classes/ANAgentConsensusContentSearchService.cls-meta.xml" "$DEPLOY_DIR/"
cp "force-app/main/default/classes/ANAgentConsensusContentSearchHandler.cls" "$DEPLOY_DIR/"
cp "force-app/main/default/classes/ANAgentConsensusContentSearchHandler.cls-meta.xml" "$DEPLOY_DIR/"

echo "✓ Copied Consensus Content Search classes"
echo ""

# Deploy using SF
echo "Deploying to Salesforce..."
echo ""

if sf project deploy start --source-dir "$DEPLOY_DIR" --target-org "$1" --verbose; then
    echo ""
    echo "✅ SUCCESS: Consensus Content Search System deployed successfully!"
    echo ""
    echo "Deployed components:"
    echo "  - ANAgentConsensusContentSearchService.cls"
    echo "  - ANAgentConsensusContentSearchHandler.cls"
    echo ""
    echo "Next steps:"
    echo "  1. Add classes to Agent Integration User permission set"
    echo "  2. Refresh action schema in Agent Builder"
    echo "  3. Test with sample utterances"
    echo ""
else
    echo ""
    echo "❌ FAILED: Deployment failed!"
    echo "Check the error messages above and fix any issues."
    echo ""
    exit 1
fi

# Clean up deployment directory
echo "Cleaning up deployment directory..."
rm -rf "$DEPLOY_DIR"
echo "✓ Cleanup complete"

echo ""
echo "=== Deployment Complete ==="
echo "Timestamp: $(date)"
