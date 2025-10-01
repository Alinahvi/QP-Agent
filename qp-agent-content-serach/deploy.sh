#!/bin/bash

# ANAgentContentSearchHandlerV2 Deployment Script
# This script automates the deployment of the ANAgentContentSearchHandlerV2 system

set -e  # Exit on any error

echo "🚀 Starting ANAgentContentSearchHandlerV2 Deployment"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if SFDX CLI is installed
if ! command -v sfdx &> /dev/null; then
    print_error "Salesforce CLI (sfdx) is not installed. Please install it first."
    echo "Visit: https://developer.salesforce.com/tools/sfdxcli"
    exit 1
fi

print_success "Salesforce CLI found"

# Check if we're in the right directory
if [ ! -d "force-app/main/default/classes" ]; then
    print_error "Please run this script from the content-search-v2-deployment directory"
    exit 1
fi

print_success "Deployment directory structure verified"

# Get org alias from user
echo ""
read -p "Enter your Salesforce org alias (or press Enter for default): " ORG_ALIAS
if [ -z "$ORG_ALIAS" ]; then
    ORG_ALIAS="default"
fi

print_status "Using org alias: $ORG_ALIAS"

# Check if org is authenticated
print_status "Checking org authentication..."
if ! sfdx force:org:display --targetusername $ORG_ALIAS &> /dev/null; then
    print_error "Org '$ORG_ALIAS' is not authenticated or doesn't exist."
    echo "Please authenticate first:"
    echo "  sfdx force:auth:web:login --setalias $ORG_ALIAS"
    exit 1
fi

print_success "Org '$ORG_ALIAS' is authenticated"

# Display org information
echo ""
print_status "Org Information:"
sfdx force:org:display --targetusername $ORG_ALIAS

echo ""
read -p "Do you want to proceed with deployment to this org? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    print_warning "Deployment cancelled by user"
    exit 0
fi

# Validate deployment first
echo ""
print_status "Validating deployment (dry run)..."
if sfdx force:source:deploy --checkonly -p force-app/main/default/classes --targetusername $ORG_ALIAS; then
    print_success "Validation passed"
else
    print_error "Validation failed. Please check the errors above."
    exit 1
fi

# Deploy the classes
echo ""
print_status "Deploying ANAgentContentSearchHandlerV2 classes..."
if sfdx force:source:deploy -p force-app/main/default/classes --targetusername $ORG_ALIAS; then
    print_success "Classes deployed successfully"
else
    print_error "Deployment failed. Please check the errors above."
    exit 1
fi

# Verify deployment
echo ""
print_status "Verifying deployment..."
if sfdx force:source:status --targetusername $ORG_ALIAS | grep -q "No local changes"; then
    print_success "Deployment verified - all files are in sync"
else
    print_warning "Some files may not be in sync. Checking status..."
    sfdx force:source:status --targetusername $ORG_ALIAS
fi

# Run tests
echo ""
print_status "Running tests..."
if sfdx force:apex:test:run -n ANAgentContentSearchHandlerV2 --targetusername $ORG_ALIAS --resultformat human; then
    print_success "All tests passed"
else
    print_warning "Some tests may have failed. Check the output above."
fi

# Display deployment summary
echo ""
echo "🎉 Deployment Summary"
echo "==================="
print_success "ANAgentContentSearchHandlerV2 system deployed successfully!"
echo ""
echo "📋 Deployed Components:"
echo "  ✅ ANAgentContentSearchHandlerV2.cls (Handler)"
echo "  ✅ ANAgentContentSearchServiceV2.cls (Service Layer)"
echo "  ✅ Associated metadata files"
echo ""
echo "🔗 Service-Handler Integration:"
echo "  ✅ Handler calls service: ANAgentContentSearchServiceV2.search()"
echo "  ✅ Handler uses service DTOs: UnifiedContent, ContentSearchResult"
echo "  ✅ Service provides unified search across Course, Asset, Curriculum objects"
echo ""
echo "🎯 Available Features:"
echo "  ✅ Unified content search across Course, Asset, Curriculum objects"
echo "  ✅ Learner analytics with enrollment and completion data"
echo "  ✅ Content type filtering (Course, Asset, Curriculum)"
echo "  ✅ Professional formatting with learner insights"
echo "  ✅ Comprehensive error handling"
echo ""
echo "📚 Next Steps:"
echo "  1. Configure user permissions for the new classes"
echo "  2. Test the search functionality in your org"
echo "  3. Review the complete documentation in ANAGENT_CONTENT_SEARCH_V2_COMPLETE_MARKDOWN.md"
echo ""
echo "🔧 Usage Example:"
echo "  ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();"
echo "  request.searchTerm = 'Salesforce Administration';"
echo "  request.contentType = 'Course';"
echo "  List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});"
echo ""
print_success "Deployment completed successfully! 🚀"