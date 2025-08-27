/**
 * Focused test for TOP_PRODUCTS_BY_AE_SCORE with UKI OU
 * This should show aggregated product-level insights with average AE scores
 */
System.debug('=== Testing TOP_PRODUCTS_BY_AE_SCORE with UKI OU ===');

try {
    // Test 1: TOP_PRODUCTS_BY_AE_SCORE with UKI OU
    System.debug('--- Test 1: TOP_PRODUCTS_BY_AE_SCORE with UKI OU ---');
    String result1 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                     // ouName (UKI OU exists!)
        '',                        // workLocationCountry (no filter)
        'PRODUCT',                 // groupBy (must be PRODUCT for this analysis)
        '',                        // filterCriteria
        '',                        // restrictInValuesCsv
        false,                     // perAENormalize
        5,                         // limitN (top 5)
        'SUM',                     // aggregationType
        'TOP_PRODUCTS_BY_AE_SCORE' // analysisType (new!)
    );
    
    System.debug('Result 1:');
    System.debug(result1);
    
    // Test 2: Check if we can filter by stage to get Stage 5 data
    System.debug('--- Test 2: TOP_PRODUCTS_BY_AE_SCORE with UKI OU and Stage 5 filter ---');
    String result2 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                     // ouName
        '',                        // workLocationCountry
        'PRODUCT',                 // groupBy
        'stage=\'05 - Negotiating $$ & Mutual Plan\'', // filterCriteria (Stage 5)
        '',                        // restrictInValuesCsv
        false,                     // perAENormalize
        5,                         // limitN
        'SUM',                     // aggregationType
        'TOP_PRODUCTS_BY_AE_SCORE' // analysisType
    );
    
    System.debug('Result 2:');
    System.debug(result2);
    
    // Test 3: Compare with PRODUCT_PERFORMANCE to see the difference
    System.debug('--- Test 3: PRODUCT_PERFORMANCE with UKI OU for comparison ---');
    String result3 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                     // ouName
        '',                        // workLocationCountry
        'PRODUCT',                 // groupBy
        '',                        // filterCriteria
        '',                        // restrictInValuesCsv
        false,                     // perAENormalize
        5,                         // limitN
        'SUM',                     // aggregationType
        'PRODUCT_PERFORMANCE'      // analysisType (for comparison)
    );
    
    System.debug('Result 3:');
    System.debug(result3);
    
    System.debug('=== Tests Completed ===');
    
} catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'Test failed with error: ' + e.getMessage());
    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
}
