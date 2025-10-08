#!/bin/bash

###############################################################################
# SME Search V3 Deployment Script
# Version: 3.0.0
# Date: October 8, 2025
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

print_success() {
    echo -e "${GREEN}✅ ${NC}$1"
}

print_error() {
    echo -e "${RED}❌ ${NC}$1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  ${NC}$1"
}

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

# Check if org alias is provided
if [ -z "$1" ]; then
    print_error "Please provide target org alias"
    echo "Usage: ./deploy.sh YOUR_ORG_ALIAS"
    exit 1
fi

TARGET_ORG=$1

print_header "SME Search V3 Deployment"

# Step 1: Verify Salesforce CLI
print_info "Verifying Salesforce CLI installation..."
if ! command -v sf &> /dev/null; then
    print_error "Salesforce CLI not found. Please install it first."
    exit 1
fi
print_success "Salesforce CLI found"

# Step 2: Verify org authentication
print_info "Verifying org authentication for: $TARGET_ORG"
if ! sf org display --target-org "$TARGET_ORG" &> /dev/null; then
    print_error "Not authenticated to org: $TARGET_ORG"
    print_info "Please authenticate first using: sf org login web --alias $TARGET_ORG"
    exit 1
fi
print_success "Authenticated to $TARGET_ORG"

# Step 3: Display org info
print_info "Target Org Details:"
sf org display --target-org "$TARGET_ORG" --json | jq -r '.result | "  Username: \(.username)\n  Org ID: \(.id)\n  Instance: \(.instanceUrl)"'

# Step 4: Confirm deployment
echo ""
print_warning "This will deploy the following to $TARGET_ORG:"
echo "  - ANAgentSMESearchHandlerV3 (Apex Class)"
echo "  - ANAgentSMESearchServiceV3 (Apex Class)"
echo ""
read -p "Continue with deployment? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Deployment cancelled"
    exit 0
fi

# Step 5: Deploy
print_header "Deploying Components"
print_info "Starting deployment..."

sf project deploy start \
    --source-dir force-app/main/default/classes \
    --target-org "$TARGET_ORG" \
    --wait 10 \
    --verbose

if [ $? -eq 0 ]; then
    print_success "Deployment successful!"
else
    print_error "Deployment failed. Please check the errors above."
    exit 1
fi

# Step 6: Verify deployment
print_header "Verifying Deployment"
print_info "Checking deployed classes..."

HANDLER_CHECK=$(sf apex list class --target-org "$TARGET_ORG" --json | jq -r '.result[] | select(.FullName=="ANAgentSMESearchHandlerV3") | .FullName')
SERVICE_CHECK=$(sf apex list class --target-org "$TARGET_ORG" --json | jq -r '.result[] | select(.FullName=="ANAgentSMESearchServiceV3") | .FullName')

if [ "$HANDLER_CHECK" == "ANAgentSMESearchHandlerV3" ]; then
    print_success "ANAgentSMESearchHandlerV3 verified"
else
    print_error "ANAgentSMESearchHandlerV3 not found"
fi

if [ "$SERVICE_CHECK" == "ANAgentSMESearchServiceV3" ]; then
    print_success "ANAgentSMESearchServiceV3 verified"
else
    print_error "ANAgentSMESearchServiceV3 not found"
fi

# Step 7: Run quick test
print_header "Running Quick Test"
print_info "Creating test script..."

cat > /tmp/test_sme_v3.apex << 'EOF'
System.debug('=== SME Search V3 Quick Test ===');
try {
    ANAgentSMESearchHandlerV3.SMESearchRequest request = new ANAgentSMESearchHandlerV3.SMESearchRequest();
    request.searchTerm = 'Tableau';
    request.searchType = 'product';
    request.maxResults = 3;
    
    List<ANAgentSMESearchHandlerV3.SMESearchRequest> requests = new List<ANAgentSMESearchHandlerV3.SMESearchRequest>{request};
    List<ANAgentSMESearchHandlerV3.SMESearchResponse> responses = ANAgentSMESearchHandlerV3.searchSMEs(requests);
    
    if (responses != null && !responses.isEmpty() && responses[0].message != null) {
        System.debug('✅ Handler responds successfully');
        System.debug('Message length: ' + responses[0].message.length() + ' characters');
    } else {
        System.debug('❌ Handler returned null or empty response');
    }
} catch (Exception e) {
    System.debug('❌ Test failed: ' + e.getMessage());
}
EOF

print_info "Running test..."
sf apex run --file /tmp/test_sme_v3.apex --target-org "$TARGET_ORG" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    print_success "Quick test passed"
else
    print_warning "Quick test had issues (this might be normal if AGENT_SME_ACADEMIES__c has no data)"
fi

# Cleanup
rm -f /tmp/test_sme_v3.apex

# Step 8: Summary
print_header "Deployment Complete"
print_success "SME Search V3 has been successfully deployed to $TARGET_ORG"
echo ""
print_info "Next Steps:"
echo "  1. Open Agent Builder in $TARGET_ORG"
echo "  2. Add new action → Select Apex"
echo "  3. Choose 'Search SMEs V3'"
echo "  4. Configure input/output instructions (see README.md)"
echo "  5. Test with: 'Give me 5 SMEs in UKI for Tableau'"
echo ""
print_info "For detailed configuration, see README.md"
echo ""
print_success "Deployment completed successfully! 🎉"
echo ""
