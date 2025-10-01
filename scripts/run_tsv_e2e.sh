#!/bin/bash

# TSV Export End-to-End Test Script
# This script tests the complete TSV export functionality

echo "🚀 Starting TSV Export E2E Tests..."

# Set Salesforce CLI variables
ORG_ALIAS="your-org-alias"
TEST_CLASS="ANAgentGenericTSVExportHandlerTest"

echo "📋 Running unit tests..."
sf apex run test --class-names $TEST_CLASS --target-org $ORG_ALIAS --result-format human --code-coverage

echo "🧪 Running UAT scenarios..."

# Test 1: Renewals Analysis Export
echo "Test 1: Renewals Analysis Export"
sf apex run --file scripts/testing/test_renewals_tsv_export.apex --target-org $ORG_ALIAS

# Test 2: Open Pipe Analysis Export  
echo "Test 2: Open Pipe Analysis Export"
sf apex run --file scripts/testing/test_openpipe_tsv_export.apex --target-org $ORG_ALIAS

# Test 3: KPI Analysis Export
echo "Test 3: KPI Analysis Export"
sf apex run --file scripts/testing/test_kpi_tsv_export.apex --target-org $ORG_ALIAS

# Test 4: MCP Integration Test
echo "Test 4: MCP Integration Test"
sf apex run --file scripts/testing/test_mcp_tsv_integration.apex --target-org $ORG_ALIAS

echo "✅ E2E Tests completed!"

# Generate test report
echo "📊 Generating test report..."
sf apex run --file scripts/testing/generate_tsv_test_report.apex --target-org $ORG_ALIAS

echo "🎉 All tests completed successfully!"

