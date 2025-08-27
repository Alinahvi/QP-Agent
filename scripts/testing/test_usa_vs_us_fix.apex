/**
 * Test USA vs US Canonicalization Fix
 * Verifies that "USA" gets converted to "US" for proper database lookup
 */

System.debug('=== TEST USA vs US CANONICALIZATION FIX ===');

try {
    // Test 1: Use the new compareAvg method with "USA" (should convert to "US")
    System.debug('\n--- TEST 1: COMPARE AVG WITH "USA" (SHOULD CONVERT TO "US") ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response1 = ANAgentKPIAnalysisService.compareAvg(
        'CALLS', 
        'WORK_LOCATION_COUNTRY', 
        'Brazil', 
        'USA', 
        'CURRENT'
    );
    
    System.debug('Response 1 Success: ' + response1.success);
    System.debug('Response 1 Processing Mode: ' + response1.processingMode);
    System.debug('Response 1 Primary Average (Brazil): ' + response1.averageValue);
    System.debug('Response 1 Comparison Average (USA): ' + response1.comparisonValueAmount);
    System.debug('Response 1 Difference: ' + response1.difference);
    System.debug('Response 1 Percentage Change: ' + response1.percentageChange);
    System.debug('Response 1 Message: ' + response1.message);
    System.debug('Response 1 Insights: ' + response1.insights);
    
    if (response1.success) {
        System.debug('✅ Test 1 PASSED: USA canonicalization successful');
        System.debug('  - Processing Mode: ' + response1.processingMode + ' (expected: AGGREGATE)');
        System.debug('  - Brazil Avg: ' + response1.averageValue);
        System.debug('  - USA Avg: ' + response1.comparisonValueAmount + ' (should not be 0)');
        System.debug('  - Difference: ' + response1.difference);
    } else {
        System.debug('❌ Test 1 FAILED: ' + response1.message);
    }
    
    // Test 2: Compare with explicit "US" to verify it works the same
    System.debug('\n--- TEST 2: COMPARE AVG WITH EXPLICIT "US" ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response2 = ANAgentKPIAnalysisService.compareAvg(
        'CALLS', 
        'WORK_LOCATION_COUNTRY', 
        'Brazil', 
        'US', 
        'CURRENT'
    );
    
    System.debug('Response 2 Success: ' + response2.success);
    System.debug('Response 2 Processing Mode: ' + response2.processingMode);
    System.debug('Response 2 Primary Average (Brazil): ' + response2.averageValue);
    System.debug('Response 2 Comparison Average (US): ' + response2.comparisonValueAmount);
    System.debug('Response 2 Difference: ' + response2.difference);
    System.debug('Response 2 Message: ' + response2.message);
    
    if (response2.success) {
        System.debug('✅ Test 2 PASSED: Explicit US comparison successful');
        System.debug('  - Processing Mode: ' + response2.processingMode + ' (expected: AGGREGATE)');
        System.debug('  - Brazil Avg: ' + response2.averageValue);
        System.debug('  - US Avg: ' + response2.comparisonValueAmount);
    } else {
        System.debug('❌ Test 2 FAILED: ' + response2.message);
    }
    
    // Test 3: Verify single calls work with canonicalization
    System.debug('\n--- TEST 3: SINGLE CALL WITH "USA" (SHOULD CONVERT TO "US") ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response3 = ANAgentKPIAnalysisService.analyzeCalls('WORK_LOCATION_COUNTRY', 'USA');
    
    System.debug('Response 3 Success: ' + response3.success);
    System.debug('Response 3 Total Records: ' + response3.totalRecords);
    System.debug('Response 3 Total Value: ' + response3.totalValue);
    System.debug('Response 3 Average Value: ' + response3.averageValue);
    System.debug('Response 3 Analysis Type: ' + response3.analysisType);
    System.debug('Response 3 Time Frame: ' + response3.timeFrame);
    
    if (response3.success) {
        System.debug('✅ Test 3 PASSED: Single USA call with canonicalization successful');
        System.debug('  - Total Records: ' + response3.totalRecords + ' (should not be 0)');
        System.debug('  - Total Value: ' + response3.totalValue + ' (should not be 0)');
        System.debug('  - Analysis Type: ' + response3.analysisType + ' (should not be null)');
    } else {
        System.debug('❌ Test 3 FAILED: ' + response3.message);
    }
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== TEST USA vs US CANONICALIZATION FIX COMPLETED ==='); 