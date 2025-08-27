/**
 * Focused test script for ANAgentOpenPipeAnalysisV3Service
 * This tests the new TOP_PRODUCTS_BY_AE_SCORE functionality with smaller limits
 */
System.debug('=== Testing ANAgentOpenPipeAnalysisV3Service - Focused Test ===');

try {
    // Test 1: TOP_PRODUCTS_BY_AE_SCORE with small limit to avoid heap issues
    System.debug('--- Test 1: TOP_PRODUCTS_BY_AE_SCORE with limit 2 ---');
    String result1 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'SMB - AMER SMB',           // ouName (actual OU from the data)
        '',                         // workLocationCountry (no filter)
        'PRODUCT',                  // groupBy (must be PRODUCT for this analysis)
        '',                         // filterCriteria
        '',                         // restrictInValuesCsv
        false,                      // perAENormalize
        2,                          // limitN (top 2 to avoid heap issues)
        'SUM',                      // aggregationType
        'TOP_PRODUCTS_BY_AE_SCORE' // analysisType (new!)
    );
    
    System.debug('Result 1:');
    System.debug(result1);
    
    // Test 2: Enhanced PRODUCT_PERFORMANCE with small limit
    System.debug('--- Test 2: Enhanced PRODUCT_PERFORMANCE with AE scores (limit 2) ---');
    String result2 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'SMB - AMER SMB',           // ouName
        '',                         // workLocationCountry
        'PRODUCT',                  // groupBy
        '',                         // filterCriteria
        '',                         // restrictInValuesCsv
        false,                      // perAENormalize
        2,                          // limitN (small limit)
        'SUM',                      // aggregationType
        'PRODUCT_PERFORMANCE'       // analysisType (enhanced)
    );
    
    System.debug('Result 2:');
    System.debug(result2);
    
    System.debug('=== Focused tests completed successfully ===');
    
} catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'Test failed with error: ' + e.getMessage());
    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
}
