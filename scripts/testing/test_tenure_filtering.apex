/**
 * Test Tenure Filtering Implementation
 * Verifies that different tenure ranges return different averages
 */

System.debug('=== TEST TENURE FILTERING IMPLEMENTATION ===');

try {
    // Test 1: Compare AEs > 60 months vs > 30 months in USA (should be different)
    System.debug('\n--- TEST 1: TENURE COMPARISON (>60 vs >30 months in USA) ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response1 = ANAgentKPIAnalysisService.compareAvgByTenure(
        'ACV',                    // analysis type
        'WORK_LOCATION_COUNTRY',  // dimension
        'USA',                    // value
        60, null,                 // group A: > 60 months
        30, null,                 // group B: > 30 months
        'CURRENT'                 // timeframe
    );
    
    System.debug('Response 1 Success: ' + response1.success);
    System.debug('Response 1 Processing Mode: ' + response1.processingMode);
    System.debug('Response 1 Primary Average (>60 months): ' + response1.averageValue);
    System.debug('Response 1 Comparison Average (>30 months): ' + response1.comparisonValueAmount);
    System.debug('Response 1 Difference: ' + response1.difference);
    System.debug('Response 1 Percentage Change: ' + response1.percentageChange);
    System.debug('Response 1 Message: ' + response1.message);
    
    if (response1.success) {
        System.debug('✅ Test 1 PASSED: Tenure comparison successful');
        System.debug('  - Processing Mode: ' + response1.processingMode + ' (expected: TWO_QUERY)');
        System.debug('  - >60 months Avg: ' + response1.averageValue);
        System.debug('  - >30 months Avg: ' + response1.comparisonValueAmount);
        
        // Check if the values are actually different
        if (response1.averageValue != response1.comparisonValueAmount) {
            System.debug('  ✅ SUCCESS: Different tenure ranges return different averages!');
        } else {
            System.debug('  ⚠️ WARNING: Same averages - may need to check data or tenure ranges');
        }
    } else {
        System.debug('❌ Test 1 FAILED: ' + response1.message);
    }
    
    // Test 2: Single tenure filter (> 60 months in USA)
    System.debug('\n--- TEST 2: SINGLE TENURE FILTER (>60 months in USA) ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request2 = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request2.analysisType = 'ACV';
    request2.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request2.primaryValue = 'USA';
    request2.minTenureMonths = 60;
    request2.timeFrame = 'CURRENT';
    request2.includeStatistics = false;
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response2 = ANAgentKPIAnalysisService.analyzeKPIs(request2);
    
    System.debug('Response 2 Success: ' + response2.success);
    System.debug('Response 2 Processing Mode: ' + response2.processingMode);
    System.debug('Response 2 Total Records: ' + response2.totalRecords);
    System.debug('Response 2 Total Value: ' + response2.totalValue);
    System.debug('Response 2 Average Value: ' + response2.averageValue);
    System.debug('Response 2 Analysis Type: ' + response2.analysisType);
    System.debug('Response 2 Time Frame: ' + response2.timeFrame);
    
    if (response2.success) {
        System.debug('✅ Test 2 PASSED: Single tenure filter successful');
        System.debug('  - Processing Mode: ' + response2.processingMode + ' (expected: STANDARD)');
        System.debug('  - Total Records: ' + response2.totalRecords);
        System.debug('  - Average Value: ' + response2.averageValue);
        System.debug('  - Analysis Type: ' + response2.analysisType + ' (should not be null)');
    } else {
        System.debug('❌ Test 2 FAILED: ' + response2.message);
    }
    
    // Test 3: Compare with different tenure ranges (6-12 months vs 49+ months)
    System.debug('\n--- TEST 3: TENURE RANGE COMPARISON (6-12 vs 49+ months in USA) ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response3 = ANAgentKPIAnalysisService.compareAvgByTenure(
        'PIPELINE',               // analysis type
        'WORK_LOCATION_COUNTRY',  // dimension
        'USA',                    // value
        6, 12,                    // group A: 6-12 months
        49, null,                 // group B: 49+ months
        'CURRENT'                 // timeframe
    );
    
    System.debug('Response 3 Success: ' + response3.success);
    System.debug('Response 3 Processing Mode: ' + response3.processingMode);
    System.debug('Response 3 Primary Average (6-12 months): ' + response3.averageValue);
    System.debug('Response 3 Comparison Average (49+ months): ' + response3.comparisonValueAmount);
    System.debug('Response 3 Difference: ' + response3.difference);
    System.debug('Response 3 Message: ' + response3.message);
    
    if (response3.success) {
        System.debug('✅ Test 3 PASSED: Tenure range comparison successful');
        System.debug('  - Processing Mode: ' + response3.processingMode + ' (expected: TWO_QUERY)');
        System.debug('  - 6-12 months Avg: ' + response3.averageValue);
        System.debug('  - 49+ months Avg: ' + response3.comparisonValueAmount);
    } else {
        System.debug('❌ Test 3 FAILED: ' + response3.message);
    }
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== TEST TENURE FILTERING IMPLEMENTATION COMPLETED ==='); 