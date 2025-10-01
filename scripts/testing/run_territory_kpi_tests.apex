// Run Territory KPI Analysis Tests
System.debug('🧪 Running Territory KPI Analysis Tests...');

// Test 1: ACB QoQ Difference
System.debug('=== TEST 1: ACB QoQ Difference ===');
try {
    ANAgentTerritoryKPIAnalysisTest.test_Acb_QoQ_Difference();
    System.debug('✅ ACB QoQ Difference Test PASSED');
} catch (Exception e) {
    System.debug('❌ ACB QoQ Difference Test FAILED: ' + e.getMessage());
}

// Test 2: All QoQ KPIs Difference
System.debug('=== TEST 2: All QoQ KPIs Difference ===');
try {
    ANAgentTerritoryKPIAnalysisTest.test_AllQoQKPIs_Difference();
    System.debug('✅ All QoQ KPIs Difference Test PASSED');
} catch (Exception e) {
    System.debug('❌ All QoQ KPIs Difference Test FAILED: ' + e.getMessage());
}

// Test 3: Current-Only KPIs (No Previous Quarter)
System.debug('=== TEST 3: Current-Only KPIs (No Previous Quarter) ===');
try {
    ANAgentTerritoryKPIAnalysisTest.test_CurrentOnlyKpi_NoPreviousQuarter_AiCallsMentioned();
    System.debug('✅ Current-Only KPIs Test PASSED');
} catch (Exception e) {
    System.debug('❌ Current-Only KPIs Test FAILED: ' + e.getMessage());
}

// Test 4: OU-to-OU KPI Comparison (AMER ICE vs UKI)
System.debug('=== TEST 4: OU-to-OU KPI Comparison (AMER ICE vs UKI) ===');
try {
    ANAgentTerritoryKPIAnalysisTest.test_OUtoOU_KPI_Comparison_Meetings_AmerEyes_vs_UKI();
    System.debug('✅ OU-to-OU KPI Comparison Test PASSED');
} catch (Exception e) {
    System.debug('❌ OU-to-OU KPI Comparison Test FAILED: ' + e.getMessage());
}

// Test 5: Generic OU-to-OU KPI Comparison
System.debug('=== TEST 5: Generic OU-to-OU KPI Comparison ===');
try {
    ANAgentTerritoryKPIAnalysisTest.test_Generic_OUtoOU_KPI_Comparison();
    System.debug('✅ Generic OU-to-OU KPI Comparison Test PASSED');
} catch (Exception e) {
    System.debug('❌ Generic OU-to-OU KPI Comparison Test FAILED: ' + e.getMessage());
}

System.debug('🎯 All Territory KPI Analysis Tests Completed!'); 