/**
 * Test script for ANAgentOpenPipeAnalysisV3Service using real data values
 * This tests the new TOP_PRODUCTS_BY_AE_SCORE functionality with actual OU and country values
 */
System.debug('=== Testing ANAgentOpenPipeAnalysisV3Service with Real Data ===');

try {
    // Test 1: TOP_PRODUCTS_BY_AE_SCORE with actual OU from the data
    System.debug('--- Test 1: TOP_PRODUCTS_BY_AE_SCORE with SMB - AMER SMB OU ---');
    String result1 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'SMB - AMER SMB',           // ouName (actual OU from the data)
        '',                         // workLocationCountry (no filter)
        'PRODUCT',                  // groupBy (must be PRODUCT for this analysis)
        '',                         // filterCriteria
        '',                         // restrictInValuesCsv
        false,                      // perAENormalize
        5,                          // limitN (top 5)
        'SUM',                      // aggregationType
        'TOP_PRODUCTS_BY_AE_SCORE' // analysisType (new!)
    );
    
    System.debug('Result 1:');
    System.debug(result1);
    
    // Test 2: TOP_PRODUCTS_BY_AE_SCORE with limit 3
    System.debug('--- Test 2: TOP_PRODUCTS_BY_AE_SCORE with limit 3 ---');
    String result2 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'SMB - AMER SMB',           // ouName
        '',                         // workLocationCountry
        'PRODUCT',                  // groupBy
        '',                         // filterCriteria
        '',                         // restrictInValuesCsv
        false,                      // perAENormalize
        3,                          // limitN (top 3)
        'SUM',                      // aggregationType
        'TOP_PRODUCTS_BY_AE_SCORE' // analysisType
    );
    
    System.debug('Result 2:');
    System.debug(result2);
    
    // Test 3: Enhanced PRODUCT_PERFORMANCE (should now include AE scores)
    System.debug('--- Test 3: Enhanced PRODUCT_PERFORMANCE with AE scores ---');
    String result3 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'SMB - AMER SMB',           // ouName
        '',                         // workLocationCountry
        'PRODUCT',                  // groupBy
        '',                         // filterCriteria
        '',                         // restrictInValuesCsv
        false,                      // perAENormalize
        5,                          // limitN
        'SUM',                      // aggregationType
        'PRODUCT_PERFORMANCE'       // analysisType (enhanced)
    );
    
    System.debug('Result 3:');
    System.debug(result3);
    
    // Test 4: Test with country filter to see if we can find UKI data
    System.debug('--- Test 4: TOP_PRODUCTS_BY_AE_SCORE with UK country filter ---');
    String result4 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'SMB - AMER SMB',           // ouName
        'UK',                       // workLocationCountry (try UK)
        'PRODUCT',                  // groupBy
        '',                         // filterCriteria
        '',                         // restrictInValuesCsv
        false,                      // perAENormalize
        5,                          // limitN
        'SUM',                      // aggregationType
        'TOP_PRODUCTS_BY_AE_SCORE' // analysisType
    );
    
    System.debug('Result 4:');
    System.debug(result4);
    
    // Test 5: Test with different OU to see if filtering works
    System.debug('--- Test 5: TOP_PRODUCTS_BY_AE_SCORE with different OU ---');
    String result5 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'AMER',                     // ouName (try different OU)
        '',                         // workLocationCountry
        'PRODUCT',                  // groupBy
        '',                         // filterCriteria
        '',                         // restrictInValuesCsv
        false,                      // perAENormalize
        5,                          // limitN
        'SUM',                      // aggregationType
        'TOP_PRODUCTS_BY_AE_SCORE' // analysisType
    );
    
    System.debug('Result 5:');
    System.debug(result5);
    
    System.debug('=== All tests completed successfully ===');
    
} catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'Test failed with error: ' + e.getMessage());
    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
}
