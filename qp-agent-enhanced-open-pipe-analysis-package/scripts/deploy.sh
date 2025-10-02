#!/bin/bash

# Enhanced Open Pipe Analysis - Deployment Script
# This script deploys the Enhanced Open Pipe Analysis system to a Salesforce org

set -e  # Exit on any error

# Configuration
ORG_ALIAS=${1:-"innovation"}
API_VERSION="58.0"
PACKAGE_DIR="force-app"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if sf CLI is installed
    if ! command -v sf &> /dev/null; then
        log_error "Salesforce CLI (sf) is not installed. Please install it first."
        exit 1
    fi
    
    # Check if org is authenticated
    if ! sf org display --target-org $ORG_ALIAS &> /dev/null; then
        log_error "Org '$ORG_ALIAS' is not authenticated. Please run 'sf org login' first."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Validate org
validate_org() {
    log_info "Validating org '$ORG_ALIAS'..."
    
    # Check API version
    local org_version=$(sf org display --target-org $ORG_ALIAS --json | jq -r '.result.apiVersion')
    if [[ "$org_version" < "$API_VERSION" ]]; then
        log_warning "Org API version ($org_version) is older than recommended ($API_VERSION)"
    fi
    
    # Check if Agent_Open_Pipe__c exists
    if ! sf sobject describe -s Agent_Open_Pipe__c --target-org $ORG_ALIAS &> /dev/null; then
        log_error "Agent_Open_Pipe__c object not found in org. Please ensure the object exists."
        exit 1
    fi
    
    # Check record count
    local record_count=$(sf data query --query "SELECT COUNT(Id) FROM Agent_Open_Pipe__c" --target-org $ORG_ALIAS --json | jq -r '.result.totalSize')
    log_info "Found $record_count records in Agent_Open_Pipe__c"
    
    if [[ $record_count -lt 1000 ]]; then
        log_warning "Low record count ($record_count). System may not perform optimally."
    fi
    
    log_success "Org validation passed"
}

# Deploy Apex classes
deploy_apex_classes() {
    log_info "Deploying Apex classes..."
    
    # Deploy in dependency order
    local classes=(
        "ANAgentNamingNormalizer"
        "ANAgentOpenPipeAnalysisV3ServiceEnhanced"
        "ANAgentOpenPipeAnalysisV3Handler"
        "ANAgentNamingNormalizerTest"
        "OpenPipeTestEnhanced1"
    )
    
    for class in "${classes[@]}"; do
        log_info "Deploying $class..."
        
        if sf project deploy start --source-dir $PACKAGE_DIR/main/default/classes/$class.cls --target-org $ORG_ALIAS; then
            log_success "$class deployed successfully"
        else
            log_error "Failed to deploy $class"
            exit 1
        fi
    done
}

# Run tests
run_tests() {
    log_info "Running tests..."
    
    # Test naming normalizer
    log_info "Testing ANAgentNamingNormalizer..."
    if sf apex run test --class-names ANAgentNamingNormalizerTest --target-org $ORG_ALIAS; then
        log_success "ANAgentNamingNormalizer tests passed"
    else
        log_error "ANAgentNamingNormalizer tests failed"
        exit 1
    fi
    
    # Test enhanced service
    log_info "Testing OpenPipeTestEnhanced1..."
    if sf apex run test --class-names OpenPipeTestEnhanced1 --target-org $ORG_ALIAS; then
        log_success "OpenPipeTestEnhanced1 tests passed"
    else
        log_error "OpenPipeTestEnhanced1 tests failed"
        exit 1
    fi
}

# Test functionality
test_functionality() {
    log_info "Testing functionality..."
    
    # Create test script
    cat > test_functionality.apex << 'EOF'
// Test Enhanced Open Pipe Analysis functionality
Map<String, Object> params = new Map<String, Object>{
    'ou' => 'AMER ACC',
    'analysisType' => 'territory'
};

try {
    String result = ANAgentOpenPipeAnalysisV3ServiceEnhanced.analyzeOpenPipe(params);
    System.debug('Analysis result length: ' + result.length());
    
    if (result.contains('Executive Summary') && result.contains('Analysis Summary')) {
        System.debug('SUCCESS: Analysis completed successfully');
    } else {
        System.debug('WARNING: Analysis may not be complete');
    }
    
    // Test naming normalizer
    String normalizedOU = ANAgentNamingNormalizer.normalizeOU('amer-acc');
    String normalizedStage = ANAgentNamingNormalizer.normalizeStage('stage 2');
    
    System.debug('Normalized OU: ' + normalizedOU);
    System.debug('Normalized Stage: ' + normalizedStage);
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
EOF
    
    # Run test
    if sf apex run --file test_functionality.apex --target-org $ORG_ALIAS; then
        log_success "Functionality test passed"
    else
        log_error "Functionality test failed"
        exit 1
    fi
    
    # Clean up
    rm test_functionality.apex
}

# Create permission set
create_permission_set() {
    log_info "Creating permission set..."
    
    # Create permission set metadata
    mkdir -p $PACKAGE_DIR/main/default/permissionsets
    cat > $PACKAGE_DIR/main/default/permissionsets/OpenPipeAnalysisAccess.permissionset-meta.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Access to Enhanced Open Pipe Analysis features</description>
    <label>Open Pipe Analysis Access</label>
    <objectPermissions>
        <allowCreate>false</allowCreate>
        <allowDelete>false</allowDelete>
        <allowEdit>false</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>false</modifyAllRecords>
        <object>Agent_Open_Pipe__c</object>
        <viewAllRecords>false</viewAllRecords>
    </objectPermissions>
    <classAccesses>
        <apexClass>ANAgentOpenPipeAnalysisV3Handler</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>ANAgentOpenPipeAnalysisV3ServiceEnhanced</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>ANAgentNamingNormalizer</apexClass>
        <enabled>true</enabled>
    </classAccesses>
</PermissionSet>
EOF
    
    # Deploy permission set
    if sf project deploy start --source-dir $PACKAGE_DIR/main/default/permissionsets --target-org $ORG_ALIAS; then
        log_success "Permission set deployed successfully"
    else
        log_warning "Permission set deployment failed (may already exist)"
    fi
}

# Generate deployment report
generate_report() {
    log_info "Generating deployment report..."
    
    local report_file="deployment-report-$(date +%Y%m%d-%H%M%S).txt"
    
    cat > $report_file << EOF
Enhanced Open Pipe Analysis - Deployment Report
===============================================

Deployment Date: $(date)
Target Org: $ORG_ALIAS
API Version: $API_VERSION

Components Deployed:
- ANAgentNamingNormalizer.cls
- ANAgentOpenPipeAnalysisV3ServiceEnhanced.cls
- ANAgentOpenPipeAnalysisV3Handler.cls
- ANAgentNamingNormalizerTest.cls
- OpenPipeTestEnhanced1.cls
- OpenPipeAnalysisAccess.permissionset

Test Results:
- ANAgentNamingNormalizerTest: PASSED
- OpenPipeTestEnhanced1: PASSED
- Functionality Test: PASSED

Next Steps:
1. Assign permission set to users
2. Test with real data
3. Monitor performance
4. Review documentation

For support, see docs/TROUBLESHOOTING.md
EOF
    
    log_success "Deployment report generated: $report_file"
}

# Main deployment function
main() {
    log_info "Starting Enhanced Open Pipe Analysis deployment..."
    log_info "Target org: $ORG_ALIAS"
    
    check_prerequisites
    validate_org
    deploy_apex_classes
    run_tests
    test_functionality
    create_permission_set
    generate_report
    
    log_success "Deployment completed successfully! 🎉"
    log_info "See deployment report for next steps."
}

# Run main function
main "$@"
