#!/bin/bash
# V3 Deployment Script
# ANAgent Search Content V3 - FR-Style Best Practices

set -e  # Exit on error

echo "=============================================="
echo "  ANAgent Search Content V3 Deployment"
echo "  Version: 3.0"
echo "  Date: $(date +%Y-%m-%d)"
echo "=============================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if SF CLI is installed
if ! command -v sf &> /dev/null; then
    echo -e "${RED}❌ SF CLI not found. Please install Salesforce CLI.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ SF CLI found${NC}"

# Check org connection
echo ""
echo "Checking org connection..."
if ! sf org display &> /dev/null; then
    echo -e "${RED}❌ Not connected to Salesforce org. Please authenticate first.${NC}"
    echo "Run: sf org login web"
    exit 1
fi

echo -e "${GREEN}✅ Org connection verified${NC}"

# Display target org
TARGET_ORG=$(sf config get target-org --json | grep -o '"value":"[^"]*"' | cut -d'"' -f4)
echo -e "${YELLOW}Target Org: ${TARGET_ORG}${NC}"
echo ""

# Confirm deployment
read -p "Deploy to this org? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo "Step 1: Deploying Service (ANAgentContentSearchServiceV3)..."
echo "------------------------------------------------------------"
if sf project deploy start --metadata ApexClass:ANAgentContentSearchServiceV3 --test-level NoTestRun --wait 10; then
    echo -e "${GREEN}✅ Service deployed successfully${NC}"
else
    echo -e "${RED}❌ Service deployment failed${NC}"
    exit 1
fi

echo ""
echo "Step 2: Deploying Handler (ANAgentContentSearchHandlerV3)..."
echo "------------------------------------------------------------"
if sf project deploy start --metadata ApexClass:ANAgentContentSearchHandlerV3 --test-level NoTestRun --wait 10; then
    echo -e "${GREEN}✅ Handler deployed successfully${NC}"
else
    echo -e "${RED}❌ Handler deployment failed${NC}"
    exit 1
fi

echo ""
echo "Step 3: Verifying deployment..."
echo "------------------------------------------------------------"
DEPLOYED=$(sf data query --query "SELECT Name FROM ApexClass WHERE Name LIKE '%ContentSearch%V3'" --json | grep -c "ANAgentContentSearchServiceV3\|ANAgentContentSearchHandlerV3" || echo "0")

if [ "$DEPLOYED" -ge "2" ]; then
    echo -e "${GREEN}✅ Both classes verified in org${NC}"
else
    echo -e "${YELLOW}⚠️  Verification incomplete - check manually${NC}"
fi

echo ""
echo "=============================================="
echo -e "${GREEN}✅ DEPLOYMENT COMPLETE!${NC}"
echo "=============================================="
echo ""
echo "Next Steps:"
echo "1. Test with: sf apex run --file test_v3_comprehensive.apex"
echo "2. Update Agent Builder:"
echo "   - Remove old V2 action"
echo "   - Add 'ANAgent Search Content V3' action"
echo "3. Test in agent chat"
echo ""
echo "Documentation: See README.md and docs/ folder"
echo ""

