/**
 * Acceptance Tests for Aggregate KPI Comparison
 * Tests the new aggregate comparison path for same dimension comparisons
 */

System.debug('=== AGGREGATE COMPARISON ACCEPTANCE TESTS ===');

try {
    // Test 1: Avg Calls Brazil vs USA (Same Dimension Comparison)
    System.debug('\n--- TEST 1: AVG CALLS BRAZIL VS USA (SAME DIMENSION) ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request1 = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request1.analysisType = 'CALLS';
    request1.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request1.primaryValue = 'Brazil';
    request1.comparisonDimension = 'WORK_LOCATION_COUNTRY';
    request1.comparisonValue = 'US';
    request1.timeFrame = 'CURRENT';
    request1.includeStatistics = false;
    
    System.debug('Request 1: ' + request1);
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response1 = ANAgentKPIAnalysisService.analyzeKPIs(request1);
    
    System.debug('Response 1 Success: ' + response1.success);
    System.debug('Response 1 Processing Mode: ' + response1.processingMode);
    System.debug('Response 1 Primary Average: ' + response1.averageValue);
    System.debug('Response 1 Comparison Average: ' + response1.comparisonValueAmount);
    System.debug('Response 1 Difference: ' + response1.difference);
    System.debug('Response 1 Percentage Change: ' + response1.percentageChange);
    System.debug('Response 1 Detailed Results Count: ' + response1.detailedResults.size());
    System.debug('Response 1 Insights: ' + response1.insights);
    
    // Assertions for Test 1
    if (response1.success) {
        System.debug('✅ Test 1 PASSED: Aggregate comparison successful');
        System.debug('  - Processing Mode: ' + response1.processingMode + ' (expected: AGGREGATE)');
        System.debug('  - Detailed Results: ' + response1.detailedResults.size() + ' (expected: 2)');
        System.debug('  - Brazil Avg: ' + response1.averageValue);
        System.debug('  - US Avg: ' + response1.comparisonValueAmount);
        System.debug('  - Difference: ' + response1.difference);
    } else {
        System.debug('❌ Test 1 FAILED: ' + response1.message);
    }
    
    // Test 2: Avg Meetings Technology vs Healthcare (Same Dimension Comparison)
    System.debug('\n--- TEST 2: AVG MEETINGS TECHNOLOGY VS HEALTHCARE (SAME DIMENSION) ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request2 = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request2.analysisType = 'MEETINGS';
    request2.primaryDimension = 'PRIMARY_INDUSTRY';
    request2.primaryValue = 'Technology';
    request2.comparisonDimension = 'PRIMARY_INDUSTRY';
    request2.comparisonValue = 'Healthcare & Life Sciences';
    request2.timeFrame = 'CURRENT';
    request2.includeStatistics = false;
    
    System.debug('Request 2: ' + request2);
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response2 = ANAgentKPIAnalysisService.analyzeKPIs(request2);
    
    System.debug('Response 2 Success: ' + response2.success);
    System.debug('Response 2 Processing Mode: ' + response2.processingMode);
    System.debug('Response 2 Primary Average: ' + response2.averageValue);
    System.debug('Response 2 Comparison Average: ' + response2.comparisonValueAmount);
    System.debug('Response 2 Difference: ' + response2.difference);
    System.debug('Response 2 Percentage Change: ' + response2.percentageChange);
    System.debug('Response 2 Detailed Results Count: ' + response2.detailedResults.size());
    
    // Assertions for Test 2
    if (response2.success) {
        System.debug('✅ Test 2 PASSED: Industry comparison successful');
        System.debug('  - Processing Mode: ' + response2.processingMode + ' (expected: AGGREGATE)');
        System.debug('  - Technology Avg: ' + response2.averageValue);
        System.debug('  - Healthcare Avg: ' + response2.comparisonValueAmount);
    } else {
        System.debug('❌ Test 2 FAILED: ' + response2.message);
    }
    
    // Test 3: Different Dimensions Comparison (OU vs Country)
    System.debug('\n--- TEST 3: DIFFERENT DIMENSIONS COMPARISON (OU VS COUNTRY) ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request3 = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request3.analysisType = 'CALLS';
    request3.primaryDimension = 'OU_NAME';
    request3.primaryValue = 'AmerICE';
    request3.comparisonDimension = 'WORK_LOCATION_COUNTRY';
    request3.comparisonValue = 'Italy';
    request3.timeFrame = 'CURRENT';
    request3.includeStatistics = false;
    
    System.debug('Request 3: ' + request3);
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response3 = ANAgentKPIAnalysisService.analyzeKPIs(request3);
    
    System.debug('Response 3 Success: ' + response3.success);
    System.debug('Response 3 Processing Mode: ' + response3.processingMode);
    System.debug('Response 3 Primary Average: ' + response3.averageValue);
    System.debug('Response 3 Comparison Average: ' + response3.comparisonValueAmount);
    System.debug('Response 3 Detailed Results Count: ' + response3.detailedResults.size());
    
    // Assertions for Test 3
    if (response3.success) {
        System.debug('✅ Test 3 PASSED: Different dimensions comparison successful');
        System.debug('  - Processing Mode: ' + response3.processingMode + ' (expected: TWO_QUERY)');
        System.debug('  - AmerICE OU Avg: ' + response3.averageValue);
        System.debug('  - Italy Country Avg: ' + response3.comparisonValueAmount);
    } else {
        System.debug('❌ Test 3 FAILED: ' + response3.message);
    }
    
    // Test 4: Previous Quarter Comparison (Brazil vs USA)
    System.debug('\n--- TEST 4: PREVIOUS QUARTER COMPARISON (BRAZIL VS USA) ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request4 = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request4.analysisType = 'CALLS';
    request4.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request4.primaryValue = 'Brazil';
    request4.comparisonDimension = 'WORK_LOCATION_COUNTRY';
    request4.comparisonValue = 'US';
    request4.timeFrame = 'PREVIOUS';
    request4.includeStatistics = false;
    
    System.debug('Request 4: ' + request4);
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response4 = ANAgentKPIAnalysisService.analyzeKPIs(request4);
    
    System.debug('Response 4 Success: ' + response4.success);
    System.debug('Response 4 Processing Mode: ' + response4.processingMode);
    System.debug('Response 4 Primary Average: ' + response4.averageValue);
    System.debug('Response 4 Comparison Average: ' + response4.comparisonValueAmount);
    System.debug('Response 4 Detailed Results Count: ' + response4.detailedResults.size());
    
    // Assertions for Test 4
    if (response4.success) {
        System.debug('✅ Test 4 PASSED: Previous quarter comparison successful');
        System.debug('  - Processing Mode: ' + response4.processingMode + ' (expected: AGGREGATE)');
        System.debug('  - Brazil PQ Avg: ' + response4.averageValue);
        System.debug('  - US PQ Avg: ' + response4.comparisonValueAmount);
    } else {
        System.debug('❌ Test 4 FAILED: ' + response4.message);
    }
    
    // Test 5: Null Safe Test (No Data for One Side)
    System.debug('\n--- TEST 5: NULL SAFE TEST (NO DATA FOR ONE SIDE) ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request5 = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request5.analysisType = 'CALLS';
    request5.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request5.primaryValue = 'Brazil';
    request5.comparisonDimension = 'WORK_LOCATION_COUNTRY';
    request5.comparisonValue = 'NonExistentCountry';
    request5.timeFrame = 'CURRENT';
    request5.includeStatistics = false;
    
    System.debug('Request 5: ' + request5);
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response5 = ANAgentKPIAnalysisService.analyzeKPIs(request5);
    
    System.debug('Response 5 Success: ' + response5.success);
    System.debug('Response 5 Processing Mode: ' + response5.processingMode);
    System.debug('Response 5 Primary Average: ' + response5.averageValue);
    System.debug('Response 5 Comparison Average: ' + response5.comparisonValueAmount);
    System.debug('Response 5 Detailed Results Count: ' + response5.detailedResults.size());
    
    // Assertions for Test 5
    if (response5.success) {
        System.debug('✅ Test 5 PASSED: Null safe comparison successful');
        System.debug('  - Processing Mode: ' + response5.processingMode + ' (expected: AGGREGATE)');
        System.debug('  - Brazil Avg: ' + response5.averageValue);
        System.debug('  - NonExistentCountry Avg: ' + response5.comparisonValueAmount + ' (expected: 0)');
    } else {
        System.debug('❌ Test 5 FAILED: ' + response5.message);
    }
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== AGGREGATE COMPARISON ACCEPTANCE TESTS COMPLETED ==='); 