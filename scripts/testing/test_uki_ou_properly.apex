/**
 * Test script to properly test UKI OU with correct country value
 * This should give us the top 5 products in UKI with highest AE scores
 */
System.debug('=== Testing UKI OU Properly ===');

try {
    // Test 1: TOP_PRODUCTS_BY_AE_SCORE with UKI OU and United Kingdom country
    System.debug('--- Test 1: TOP_PRODUCTS_BY_AE_SCORE with UKI OU and United Kingdom ---');
    String result1 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                     // ouName (UKI OU exists!)
        'United Kingdom',          // workLocationCountry (correct country value)
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
    
    // Test 2: TOP_PRODUCTS_BY_AE_SCORE with UKI OU only (no country filter)
    System.debug('--- Test 2: TOP_PRODUCTS_BY_AE_SCORE with UKI OU only (no country filter) ---');
    String result2 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                     // ouName
        '',                        // workLocationCountry (no filter)
        'PRODUCT',                 // groupBy
        '',                        // filterCriteria
        '',                        // restrictInValuesCsv
        false,                     // perAENormalize
        5,                         // limitN
        'SUM',                     // aggregationType
        'TOP_PRODUCTS_BY_AE_SCORE' // analysisType
    );
    
    System.debug('Result 2:');
    System.debug(result2);
    
    // Test 3: Enhanced PRODUCT_PERFORMANCE with UKI OU
    System.debug('--- Test 3: Enhanced PRODUCT_PERFORMANCE with UKI OU ---');
    String result3 = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                     // ouName
        '',                        // workLocationCountry
        'PRODUCT',                 // groupBy
        '',                        // filterCriteria
        '',                        // restrictInValuesCsv
        false,                     // perAENormalize
        5,                         // limitN
        'SUM',                     // aggregationType
        'PRODUCT_PERFORMANCE'      // analysisType (enhanced)
    );
    
    System.debug('Result 3:');
    System.debug(result3);
    
    // Test 4: Check what countries exist in UKI OU
    System.debug('--- Test 4: Check Countries in UKI OU ---');
    List<AggregateResult> ukiCountries = [
        SELECT work_location_country__c, COUNT(Id) recordCount 
        FROM Agent_Open_Pipe__c 
        WHERE ou_name__c = 'UKI' 
        GROUP BY work_location_country__c 
        ORDER BY COUNT(Id) DESC
    ];
    
    System.debug('Countries in UKI OU:');
    for (AggregateResult ar : ukiCountries) {
        String country = (String)ar.get('work_location_country__c');
        Integer count = (Integer)ar.get('recordCount');
        System.debug('Country: "' + country + '" - Records: ' + count);
    }
    
    System.debug('=== UKI OU Tests Completed ===');
    
} catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'Test failed with error: ' + e.getMessage());
    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
}
