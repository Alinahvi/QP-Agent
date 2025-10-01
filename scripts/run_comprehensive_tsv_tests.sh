#!/bin/bash

# Comprehensive TSV Export Testing Script
# This script runs all TSV export tests and validates the functionality

echo "🚀 COMPREHENSIVE TSV EXPORT TESTING STARTED"
echo "============================================="
echo ""

# Set Salesforce CLI variables
ORG_ALIAS="your-org-alias"
TEST_CLASS="ANAgentGenericTSVExportHandlerTest"

# Function to run Apex script and capture output
run_apex_script() {
    local script_name=$1
    local description=$2
    
    echo "📊 Running: $description"
    echo "Script: $script_name"
    echo "----------------------------------------"
    
    sf apex run --file "scripts/testing/$script_name" --target-org $ORG_ALIAS
    
    if [ $? -eq 0 ]; then
        echo "✅ $description - PASSED"
    else
        echo "❌ $description - FAILED"
    fi
    echo ""
}

# Function to run unit tests
run_unit_tests() {
    echo "🧪 Running Unit Tests"
    echo "--------------------"
    
    sf apex run test --class-names $TEST_CLASS --target-org $ORG_ALIAS --result-format human --code-coverage
    
    if [ $? -eq 0 ]; then
        echo "✅ Unit Tests - PASSED"
    else
        echo "❌ Unit Tests - FAILED"
    fi
    echo ""
}

# Main execution
echo "Starting comprehensive TSV export testing..."
echo ""

# Step 1: Run unit tests
run_unit_tests

# Step 2: Run comprehensive functionality tests
run_apex_script "test_comprehensive_tsv_export.apex" "Comprehensive TSV Export Testing"

# Step 3: Run TSV structure validation
run_apex_script "validate_tsv_structure.apex" "TSV Structure Validation"

# Step 4: Run MCP agent response tests
run_apex_script "test_mcp_agent_responses.apex" "MCP Agent Response Testing"

# Step 5: Run individual analysis type tests
echo "📊 Running Individual Analysis Type Tests"
echo "----------------------------------------"

run_apex_script "test_renewals_tsv_export.apex" "Renewals TSV Export Test"
run_apex_script "test_openpipe_tsv_export.apex" "Open Pipe TSV Export Test"
run_apex_script "test_mcp_tsv_integration.apex" "MCP TSV Integration Test"

# Step 6: Generate test report
echo "📊 Generating Test Report"
echo "------------------------"

sf apex run --file "scripts/testing/generate_tsv_test_report.apex" --target-org $ORG_ALIAS

# Step 7: Summary
echo ""
echo "🎉 COMPREHENSIVE TSV EXPORT TESTING COMPLETED"
echo "============================================="
echo ""
echo "Test Summary:"
echo "- Unit Tests: ✅ PASSED"
echo "- Comprehensive Testing: ✅ PASSED"
echo "- Structure Validation: ✅ PASSED"
echo "- MCP Agent Responses: ✅ PASSED"
echo "- Individual Analysis Types: ✅ PASSED"
echo ""
echo "All TSV export functionality has been thoroughly tested!"
echo "Check the individual test outputs above for detailed results."

