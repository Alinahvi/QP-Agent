/**
 * Test script for ANAgentOpenPipeAnalysisV3Service TOP_PRODUCTS_BY_AE_SCORE functionality
 * This tests the new analysis type that sorts products by highest average AE score
 */
System.debug('=== Testing ANAgentOpenPipeAnalysisV3Service TOP_PRODUCTS_BY_AE_SCORE ===');

try {
    // Test 1: Basic TOP_PRODUCTS_BY_AE_SCORE analysis
    System.debug('--- Test 1: TOP_PRODUCTS_BY_AE_SCORE with PRODUCT grouping ---');
    String result1 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                    // ouName (use actual OU name from your org)
        'UKI',                    // workLocationCountry 
        'PRODUCT',                // groupBy (must be PRODUCT for this analysis)
        '',                       // filterCriteria
        '',                       // restrictInValuesCsv
        false,                    // perAENormalize
        5,                        // limitN (top 5)
        'SUM',                    // aggregationType
        'TOP_PRODUCTS_BY_AE_SCORE' // analysisType (new!)
    );
    
    System.debug('Result 1:');
    System.debug(result1);
    
    // Test 2: Test with different limit
    System.debug('--- Test 2: TOP_PRODUCTS_BY_AE_SCORE with limit 3 ---');
    String result2 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                    // ouName
        'UKI',                    // workLocationCountry 
        'PRODUCT',                // groupBy
        '',                       // filterCriteria
        '',                       // restrictInValuesCsv
        false,                    // perAENormalize
        3,                        // limitN (top 3)
        'SUM',                    // aggregationType
        'TOP_PRODUCTS_BY_AE_SCORE' // analysisType
    );
    
    System.debug('Result 2:');
    System.debug(result2);
    
    // Test 3: Test with wrong grouping (should show warning)
    System.debug('--- Test 3: TOP_PRODUCTS_BY_AE_SCORE with STAGE grouping (should show warning) ---');
    String result3 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                    // ouName
        'UKI',                    // workLocationCountry 
        'STAGE',                  // groupBy (wrong grouping for this analysis)
        '',                       // filterCriteria
        '',                       // restrictInValuesCsv
        false,                    // perAENormalize
        5,                        // limitN
        'SUM',                    // aggregationType
        'TOP_PRODUCTS_BY_AE_SCORE' // analysisType
    );
    
    System.debug('Result 3:');
    System.debug(result3);
    
    // Test 4: Test enhanced PRODUCT_PERFORMANCE (should now include AE scores)
    System.debug('--- Test 4: Enhanced PRODUCT_PERFORMANCE with AE scores ---');
    String result4 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                    // ouName
        'UKI',                    // workLocationCountry 
        'PRODUCT',                // groupBy
        '',                       // filterCriteria
        '',                       // restrictInValuesCsv
        false,                    // perAENormalize
        5,                        // limitN
        'SUM',                    // aggregationType
        'PRODUCT_PERFORMANCE'     // analysisType (enhanced)
    );
    
    System.debug('Result 4:');
    System.debug(result4);
    
    // Test 5: Test with different OU to see if filtering works
    System.debug('--- Test 5: TOP_PRODUCTS_BY_AE_SCORE with different OU ---');
    String result5 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'AMER',                   // ouName (different OU)
        'USA',                    // workLocationCountry 
        'PRODUCT',                // groupBy
        '',                       // filterCriteria
        '',                       // restrictInValuesCsv
        false,                    // perAENormalize
        5,                        // limitN
        'SUM',                    // aggregationType
        'TOP_PRODUCTS_BY_AE_SCORE' // analysisType
    );
    
    System.debug('Result 5:');
    System.debug(result5);
    
    System.debug('=== All tests completed successfully ===');
    
} catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'Test failed with error: ' + e.getMessage());
    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
}
