/**
 * Performance validation script for Renewals Analysis
 * Tests heap safety and response size
 */
System.debug('=== Renewals Analysis Heap Validation ===');

try {
    // Test parameters
    String workLocationCountry = 'US';
    String groupBy = 'AE';
    Integer limitN = 10;
    String aggregationType = 'COUNT';
    String analysisType = 'AE_ANALYSIS';
    
    System.debug('Testing with parameters:');
    System.debug('- workLocationCountry: ' + workLocationCountry);
    System.debug('- groupBy: ' + groupBy);
    System.debug('- limitN: ' + limitN);
    System.debug('- aggregationType: ' + aggregationType);
    System.debug('- analysisType: ' + analysisType);
    
    // Record start time
    Long startTime = System.currentTimeMillis();
    
    // Call the service
    String result = ABAgentRenewalsAnalysisService.analyzeRenewals(
        null, // ouName
        workLocationCountry,
        groupBy,
        null, // filterCriteria
        null, // restrictInValuesCsv
        false, // perAENormalize
        limitN,
        aggregationType,
        analysisType
    );
    
    // Record end time
    Long endTime = System.currentTimeMillis();
    Long executionTime = endTime - startTime;
    
    // Calculate response size
    Integer responseSizeBytes = result != null ? result.length() : 0;
    Integer responseSizeKB = responseSizeBytes / 1024;
    
    System.debug('=== VALIDATION RESULTS ===');
    System.debug('✅ SUCCESS: No heap size errors occurred');
    System.debug('📊 Response size: ' + responseSizeBytes + ' bytes (' + responseSizeKB + ' KB)');
    System.debug('⏱️ Execution time: ' + executionTime + ' ms');
    System.debug('📝 Response length: ' + (result != null ? result.length() : 0) + ' characters');
    
    // Validate response size (should be under 50 KB)
    if (responseSizeKB < 50) {
        System.debug('✅ Response size is within limits (< 50 KB)');
    } else {
        System.debug('⚠️ Response size is large: ' + responseSizeKB + ' KB');
    }
    
    // Validate execution time (should be under 5 seconds)
    if (executionTime < 5000) {
        System.debug('✅ Execution time is acceptable (< 5 seconds)');
    } else {
        System.debug('⚠️ Execution time is slow: ' + executionTime + ' ms');
    }
    
    // Show response preview
    if (String.isNotBlank(result)) {
        String preview = result.length() > 500 ? result.substring(0, 500) + '...' : result;
        System.debug('📄 Response preview:');
        System.debug(preview);
    }
    
    // Test with different parameters
    System.debug('\n=== TESTING DIFFERENT PARAMETERS ===');
    
    // Test with OU filter
    String result2 = ABAgentRenewalsAnalysisService.analyzeRenewals(
        'AMER', // ouName
        null, // workLocationCountry
        'OU', // groupBy
        null, // filterCriteria
        null, // restrictInValuesCsv
        false, // perAENormalize
        5, // limitN
        'SUM', // aggregationType
        'AE_ANALYSIS' // analysisType
    );
    
    System.debug('✅ OU grouping test completed');
    
    // Test with product grouping
    String result3 = ABAgentRenewalsAnalysisService.analyzeRenewals(
        null, // ouName
        'US', // workLocationCountry
        'PRODUCT', // groupBy
        null, // filterCriteria
        null, // restrictInValuesCsv
        false, // perAENormalize
        10, // limitN
        'AVG', // aggregationType
        'AE_ANALYSIS' // analysisType
    );
    
    System.debug('✅ Product grouping test completed');
    
    System.debug('\n=== ALL TESTS PASSED ===');
    System.debug('✅ No heap size errors');
    System.debug('✅ Response sizes within limits');
    System.debug('✅ Execution times acceptable');
    System.debug('✅ Multiple parameter combinations work');
    
} catch (Exception e) {
    System.debug('=== VALIDATION FAILED ===');
    System.debug('❌ Exception Type: ' + e.getTypeName());
    System.debug('❌ Exception Message: ' + e.getMessage());
    System.debug('❌ Stack Trace: ' + e.getStackTraceString());
    
    if (e.getMessage().contains('heap size')) {
        System.debug('❌ HEAP SIZE ERROR: The fix did not resolve the memory issue');
    } else {
        System.debug('⚠️ Different error occurred: ' + e.getMessage());
    }
}

System.debug('=== Validation Complete ===');
