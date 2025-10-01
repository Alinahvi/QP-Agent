/**
 * Test Two-Query Comparison Fix
 * Verifies that the null pointer issue is resolved
 */

System.debug('=== TEST TWO-QUERY COMPARISON FIX ===');

try {
    // Test: Different Dimensions Comparison (OU vs Country)
    System.debug('\n--- TEST: DIFFERENT DIMENSIONS COMPARISON (OU VS COUNTRY) ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request.analysisType = 'CALLS';
    request.primaryDimension = 'OU_NAME';
    request.primaryValue = 'AmerICE';
    request.comparisonDimension = 'WORK_LOCATION_COUNTRY';
    request.comparisonValue = 'Italy';
    request.timeFrame = 'CURRENT';
    request.includeStatistics = false;
    
    System.debug('Request: ' + request);
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response = ANAgentKPIAnalysisService.analyzeKPIs(request);
    
    System.debug('Response Success: ' + response.success);
    System.debug('Response Processing Mode: ' + response.processingMode);
    System.debug('Response Primary Average: ' + response.averageValue);
    System.debug('Response Comparison Average: ' + response.comparisonValueAmount);
    System.debug('Response Difference: ' + response.difference);
    System.debug('Response Detailed Results Count: ' + response.detailedResults.size());
    System.debug('Response Message: ' + response.message);
    
    if (response.success) {
        System.debug('✅ Test PASSED: Two-query comparison successful');
        System.debug('  - Processing Mode: ' + response.processingMode + ' (expected: TWO_QUERY)');
        System.debug('  - AmerICE OU Avg: ' + response.averageValue);
        System.debug('  - Italy Country Avg: ' + response.comparisonValueAmount);
        System.debug('  - Difference: ' + response.difference);
    } else {
        System.debug('❌ Test FAILED: ' + response.message);
    }
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== TEST TWO-QUERY COMPARISON FIX COMPLETED ==='); 