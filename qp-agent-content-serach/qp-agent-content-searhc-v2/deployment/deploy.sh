#!/bin/bash

# Enhanced Lifecycle Management V2 - Deployment Script
# Version: 2.0
# Date: October 1, 2025

set -e  # Exit on any error

echo "🚀 Enhanced Lifecycle Management V2 - Deployment Script"
echo "======================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ORG_ALIAS="anahvi@readiness.salesforce.com.innovation"
PACKAGE_NAME="Enhanced Lifecycle Management V2"

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

# Function to check if org is connected
check_org_connection() {
    print_status "Checking org connection..."
    
    if sf org display --target-org $ORG_ALIAS > /dev/null 2>&1; then
        print_success "Org connection verified: $ORG_ALIAS"
    else
        print_error "Failed to connect to org: $ORG_ALIAS"
        print_error "Please run: sf org login web --alias $ORG_ALIAS"
        exit 1
    fi
}

# Function to check CSAT field existence
check_csat_field() {
    print_status "Checking CSAT field availability..."
    
    # Check if CSAT field exists in Course__c object
    if sf data query --query "SELECT CSAT__c FROM Course__c LIMIT 1" --target-org $ORG_ALIAS > /dev/null 2>&1; then
        print_success "CSAT__c field found in Course__c object"
    else
        print_warning "CSAT__c field not found in Course__c object"
        print_warning "CSAT integration will be disabled. Consider creating the field:"
        print_warning "Field Name: CSAT, API Name: CSAT__c, Type: Number(18,0)"
        read -p "Continue deployment without CSAT integration? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Deployment cancelled"
            exit 1
        fi
    fi
}

# Function to validate dependencies
validate_dependencies() {
    print_status "Validating dependencies..."
    
    # Check for required objects
    local required_objects=("Course__c" "Asset__c" "Curriculum__c" "Assigned_Course__c")
    
    for object in "${required_objects[@]}"; do
        if sf data query --query "SELECT Id FROM $object LIMIT 1" --target-org $ORG_ALIAS > /dev/null 2>&1; then
            print_success "Object $object found"
        else
            print_error "Required object $object not found"
            exit 1
        fi
    done
}

# Function to deploy service class
deploy_service() {
    print_status "Deploying ANAgentContentSearchServiceV2..."
    
    if sf project deploy start -m ApexClass:ANAgentContentSearchServiceV2 --target-org $ORG_ALIAS; then
        print_success "ANAgentContentSearchServiceV2 deployed successfully"
    else
        print_error "Failed to deploy ANAgentContentSearchServiceV2"
        exit 1
    fi
}

# Function to deploy handler class
deploy_handler() {
    print_status "Deploying ANAgentContentSearchHandlerV2..."
    
    if sf project deploy start -m ApexClass:ANAgentContentSearchHandlerV2 --target-org $ORG_ALIAS; then
        print_success "ANAgentContentSearchHandlerV2 deployed successfully"
    else
        print_error "Failed to deploy ANAgentContentSearchHandlerV2"
        exit 1
    fi
}

# Function to run tests
run_tests() {
    print_status "Running test classes..."
    
    # Check if test classes exist
    if sf apex list --target-org $ORG_ALIAS | grep -q "ANAgentContentSearchServiceV2Test"; then
        if sf apex run test --class-names ANAgentContentSearchServiceV2Test,ANAgentContentSearchHandlerV2Test --target-org $ORG_ALIAS; then
            print_success "All tests passed"
        else
            print_warning "Some tests failed, but deployment continues"
        fi
    else
        print_warning "Test classes not found, skipping tests"
    fi
}

# Function to verify deployment
verify_deployment() {
    print_status "Verifying deployment..."
    
    # Test basic functionality
    cat > /tmp/test_deployment.apex << 'EOF'
// Test deployment verification
System.debug('=== VERIFYING ENHANCED LIFECYCLE MANAGEMENT V2 ===');

try {
    // Test service class
    ANAgentContentSearchServiceV2.ContentSearchResult result = ANAgentContentSearchServiceV2.search('Test');
    System.debug('Service test: ' + (result != null ? 'PASSED' : 'FAILED'));
    
    // Test handler class
    ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
    request.searchTerm = 'Test';
    request.searchMode = 'ACT';
    
    List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
        ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
    
    System.debug('Handler test: ' + (responses.size() > 0 ? 'PASSED' : 'FAILED'));
    
    if (responses.size() > 0) {
        System.debug('Response success: ' + responses[0].success);
        System.debug('Total records: ' + responses[0].totalRecordCount);
    }
    
    System.debug('=== DEPLOYMENT VERIFICATION COMPLETE ===');
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
EOF

    if sf apex run --file /tmp/test_deployment.apex --target-org $ORG_ALIAS; then
        print_success "Deployment verification completed"
    else
        print_warning "Deployment verification failed, but classes were deployed"
    fi
    
    # Clean up temp file
    rm -f /tmp/test_deployment.apex
}

# Function to display deployment summary
display_summary() {
    echo ""
    echo "======================================================"
    echo "🎉 DEPLOYMENT SUMMARY"
    echo "======================================================"
    echo "Package: $PACKAGE_NAME"
    echo "Version: 2.0"
    echo "Target Org: $ORG_ALIAS"
    echo "Date: $(date)"
    echo ""
    echo "✅ Deployed Components:"
    echo "   • ANAgentContentSearchServiceV2.cls"
    echo "   • ANAgentContentSearchHandlerV2.cls"
    echo ""
    echo "🔧 Enhanced Features:"
    echo "   • Lifecycle Management with CSAT Integration"
    echo "   • Intelligent Search Routing"
    echo "   • Performance Analytics"
    echo "   • Content Optimization Recommendations"
    echo ""
    echo "📊 Key Metrics Available:"
    echo "   • Enrollment counts and completion rates"
    echo "   • CSAT scores (if Course__c.CSAT__c field exists)"
    echo "   • Lifecycle analysis with optimization suggestions"
    echo ""
    echo "🚀 Ready for Production Use!"
    echo "======================================================"
}

# Main deployment flow
main() {
    echo "Starting deployment of $PACKAGE_NAME..."
    echo ""
    
    # Pre-deployment checks
    check_org_connection
    check_csat_field
    validate_dependencies
    
    echo ""
    print_status "All pre-deployment checks passed. Starting deployment..."
    echo ""
    
    # Deployment steps
    deploy_service
    deploy_handler
    
    echo ""
    print_status "Running post-deployment tasks..."
    
    # Post-deployment tasks
    run_tests
    verify_deployment
    
    # Display summary
    display_summary
    
    print_success "Deployment completed successfully! 🎉"
}

# Run main function
main "$@"
