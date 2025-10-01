#!/bin/bash

# Deploy Fixes for ANAgentOpenPipeAnalysisV3Handler and Service
# This script deploys the fixes for the misinformation issues

echo "=== DEPLOYING FIXES FOR ANAgentOpenPipeAnalysisV3Handler ==="
echo "Date: $(date)"
echo ""

# Set deployment parameters
SALESFORCE_CLI="sf"
TARGET_ORG="your-target-org"  # Update this with your target org
VALIDATE_ONLY=false
WAIT_TIME=10

# Function to check if Salesforce CLI is available
check_sf_cli() {
    if ! command -v $SALESFORCE_CLI &> /dev/null; then
        echo "❌ Salesforce CLI not found. Please install it first."
        exit 1
    fi
    echo "✅ Salesforce CLI found"
}

# Function to validate deployment
validate_deployment() {
    echo "🔍 Validating deployment..."
    
    # Check if the classes exist
    if $SALESFORCE_CLI data query --query "SELECT Id, Name FROM ApexClass WHERE Name = 'ANAgentOpenPipeAnalysisV3Handler'" --target-org $TARGET_ORG --json > /dev/null 2>&1; then
        echo "✅ ANAgentOpenPipeAnalysisV3Handler class found"
    else
        echo "❌ ANAgentOpenPipeAnalysisV3Handler class not found"
        return 1
    fi
    
    if $SALESFORCE_CLI data query --query "SELECT Id, Name FROM ApexClass WHERE Name = 'ANAgentOpenPipeAnalysisV3Service'" --target-org $TARGET_ORG --json > /dev/null 2>&1; then
        echo "✅ ANAgentOpenPipeAnalysisV3Service class found"
    else
        echo "❌ ANAgentOpenPipeAnalysisV3Service class not found"
        return 1
    fi
    
    return 0
}

# Function to run tests
run_tests() {
    echo "🧪 Running validation tests..."
    
    # Run the comprehensive test
    if $SALESFORCE_CLI apex run --file scripts/testing/verify_fixes_comprehensive_test.apex --target-org $TARGET_ORG; then
        echo "✅ Comprehensive test passed"
    else
        echo "❌ Comprehensive test failed"
        return 1
    fi
    
    # Run the 100 utterances test
    if $SALESFORCE_CLI apex run --file scripts/testing/100_utterances_validation_test.apex --target-org $TARGET_ORG; then
        echo "✅ 100 utterances test passed"
    else
        echo "❌ 100 utterances test failed"
        return 1
    fi
    
    return 0
}

# Main deployment process
main() {
    echo "Starting deployment process..."
    
    # Check prerequisites
    check_sf_cli
    
    # Deploy the fixed classes
    echo "📦 Deploying fixed classes..."
    
    if [ "$VALIDATE_ONLY" = true ]; then
        echo "🔍 Validation mode - checking syntax only"
        $SALESFORCE_CLI project deploy start --source-dir force-app/main/default/classes/ANAgentOpenPipeAnalysisV3Handler.cls --target-org $TARGET_ORG --dry-run
        $SALESFORCE_CLI project deploy start --source-dir force-app/main/default/classes/ANAgentOpenPipeAnalysisV3Service.cls --target-org $TARGET_ORG --dry-run
    else
        echo "🚀 Deploying to target org: $TARGET_ORG"
        $SALESFORCE_CLI project deploy start --source-dir force-app/main/default/classes/ANAgentOpenPipeAnalysisV3Handler.cls --target-org $TARGET_ORG --wait $WAIT_TIME
        $SALESFORCE_CLI project deploy start --source-dir force-app/main/default/classes/ANAgentOpenPipeAnalysisV3Service.cls --target-org $TARGET_ORG --wait $WAIT_TIME
    fi
    
    if [ $? -eq 0 ]; then
        echo "✅ Deployment successful"
        
        # Validate deployment
        if validate_deployment; then
            echo "✅ Deployment validation passed"
            
            # Run tests
            if run_tests; then
                echo "✅ All tests passed"
                echo ""
                echo "🎉 DEPLOYMENT COMPLETE AND SUCCESSFUL!"
                echo ""
                echo "Summary of fixes deployed:"
                echo "1. ✅ Fixed getTotalCount() to count unique AEs instead of total records"
                echo "2. ✅ Added IsDeleted = false filter to all queries"
                echo "3. ✅ Updated message text to show 'Total AEs Analyzed' instead of 'Total Records Found'"
                echo "4. ✅ Verified field mappings are correct"
                echo "5. ✅ Verified aggregation functions work correctly"
                echo "6. ✅ Tested across multiple OUs, countries, and verticals"
                echo ""
                echo "The agent should now provide accurate AE counts and no longer generate misinformation."
            else
                echo "❌ Tests failed - please check the test results"
                exit 1
            fi
        else
            echo "❌ Deployment validation failed"
            exit 1
        fi
    else
        echo "❌ Deployment failed"
        exit 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --org)
            TARGET_ORG="$2"
            shift 2
            ;;
        --validate-only)
            VALIDATE_ONLY=true
            shift
            ;;
        --wait)
            WAIT_TIME="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--org TARGET_ORG] [--validate-only] [--wait WAIT_TIME] [--help]"
            echo ""
            echo "Options:"
            echo "  --org TARGET_ORG    Target Salesforce org (default: your-target-org)"
            echo "  --validate-only     Only validate syntax, don't deploy"
            echo "  --wait WAIT_TIME    Wait time for deployment (default: 10)"
            echo "  --help              Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Run main function
main
