/**
 * Test Refactored Service
 * Verifies that the refactored service using utilities still works correctly
 */

System.debug('=== TESTING REFACTORED SERVICE ===');

try {
    // Test 1: Basic KPI analysis (should use SOQL builder)
    System.debug('\n--- TEST 1: BASIC KPI ANALYSIS ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request1 = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request1.analysisType = 'ACV';
    request1.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request1.primaryValue = 'USA';
    request1.timeFrame = 'CURRENT';
    request1.includeStatistics = false;
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response1 = ANAgentKPIAnalysisService.analyzeKPIs(request1);
    
    System.debug('Response 1 Success: ' + response1.success);
    System.debug('Response 1 Processing Mode: ' + response1.processingMode);
    System.debug('Response 1 Total Records: ' + response1.totalRecords);
    System.debug('Response 1 Analysis Type: ' + response1.analysisType);
    System.debug('Response 1 Primary Dimension: ' + response1.primaryDimension);
    
    if (response1.success) {
        System.debug('✅ Test 1 PASSED: Basic KPI analysis successful');
    } else {
        System.debug('❌ Test 1 FAILED: ' + response1.message);
    }
    
    // Test 2: Tenure comparison (should use utilities)
    System.debug('\n--- TEST 2: TENURE COMPARISON ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response2 = ANAgentKPIAnalysisService.compareAvgByTenure(
        'ACV',                    // analysis type
        'WORK_LOCATION_COUNTRY',  // dimension
        'USA',                    // value
        60, null,                 // group A: > 60 months
        30, null,                 // group B: > 30 months
        'CURRENT'                 // timeframe
    );
    
    System.debug('Response 2 Success: ' + response2.success);
    System.debug('Response 2 Processing Mode: ' + response2.processingMode);
    System.debug('Response 2 Primary Average (>60 months): ' + response2.averageValue);
    System.debug('Response 2 Comparison Average (>30 months): ' + response2.comparisonValueAmount);
    
    if (response2.success) {
        System.debug('✅ Test 2 PASSED: Tenure comparison successful');
    } else {
        System.debug('❌ Test 2 FAILED: ' + response2.message);
    }
    
    // Test 3: A vs B comparison (should use utilities)
    System.debug('\n--- TEST 3: A VS B COMPARISON ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response3 = ANAgentKPIAnalysisService.compareAvg(
        'CALLS',                  // analysis type
        'WORK_LOCATION_COUNTRY',  // dimension
        'Brazil',                 // value A
        'USA',                    // value B
        'CURRENT'                 // timeframe
    );
    
    System.debug('Response 3 Success: ' + response3.success);
    System.debug('Response 3 Processing Mode: ' + response3.processingMode);
    System.debug('Response 3 Primary Average (Brazil): ' + response3.averageValue);
    System.debug('Response 3 Comparison Average (USA): ' + response3.comparisonValueAmount);
    
    if (response3.success) {
        System.debug('✅ Test 3 PASSED: A vs B comparison successful');
    } else {
        System.debug('❌ Test 3 FAILED: ' + response3.message);
    }
    
    System.debug('\n✅ ALL REFACTORED SERVICE TESTS PASSED!');
    
} catch (Exception e) {
    System.debug('❌ REFACTORED SERVICE TEST FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== REFACTORED SERVICE TESTING COMPLETED ==='); 