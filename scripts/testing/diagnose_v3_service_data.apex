/**
 * Diagnostic script to check what data is available in the org
 * and identify the correct OU and country values for testing
 */
System.debug('=== Diagnosing ANAgentOpenPipeAnalysisV3Service Data ===');

try {
    // Check 1: What OUs are available in the org?
    System.debug('--- Check 1: Available OUs ---');
    List<AggregateResult> ouResults = [
        SELECT ou_name__c, COUNT(Id) recordCount 
        FROM Agent_Open_Pipe__c 
        WHERE ou_name__c != null 
        GROUP BY ou_name__c 
        ORDER BY COUNT(Id) DESC
    ];
    
    System.debug('Available OUs:');
    for (AggregateResult ar : ouResults) {
        System.debug('OU: ' + ar.get('ou_name__c') + ' - Records: ' + ar.get('recordCount'));
    }
    
    // Check 2: What countries are available?
    System.debug('--- Check 2: Available Countries ---');
    List<AggregateResult> countryResults = [
        SELECT work_location_country__c, COUNT(Id) recordCount 
        FROM Agent_Open_Pipe__c 
        WHERE work_location_country__c != null 
        GROUP BY work_location_country__c 
        ORDER BY COUNT(Id) DESC
    ];
    
    System.debug('Available Countries:');
    for (AggregateResult ar : countryResults) {
        System.debug('Country: ' + ar.get('work_location_country__c') + ' - Records: ' + ar.get('recordCount'));
    }
    
    // Check 3: What products are available?
    System.debug('--- Check 3: Available Products ---');
    List<AggregateResult> productResults = [
        SELECT open_pipe_prod_nm__c, COUNT(Id) recordCount 
        FROM Agent_Open_Pipe__c 
        WHERE open_pipe_prod_nm__c != null 
        GROUP BY open_pipe_prod_nm__c 
        ORDER BY COUNT(Id) DESC
        LIMIT 10
    ];
    
    System.debug('Top 10 Products:');
    for (AggregateResult ar : productResults) {
        System.debug('Product: ' + ar.get('open_pipe_prod_nm__c') + ' - Records: ' + ar.get('recordCount'));
    }
    
    // Check 4: What AE scores are available?
    System.debug('--- Check 4: AE Score Distribution ---');
    List<Agent_Open_Pipe__c> scoreRecords = [
        SELECT open_pipe_ae_score__c 
        FROM Agent_Open_Pipe__c 
        WHERE open_pipe_ae_score__c != null 
        ORDER BY open_pipe_ae_score__c DESC
        LIMIT 10
    ];
    
    System.debug('Top 10 AE Scores:');
    for (Agent_Open_Pipe__c record : scoreRecords) {
        System.debug('Score: ' + record.open_pipe_ae_score__c);
    }
    
    // Check 5: Total record count
    System.debug('--- Check 5: Total Record Count ---');
    Integer totalCount = [SELECT COUNT() FROM Agent_Open_Pipe__c];
    System.debug('Total records in Agent_Open_Pipe__c: ' + totalCount);
    
    // Check 6: Sample record with all fields
    System.debug('--- Check 6: Sample Record ---');
    List<Agent_Open_Pipe__c> sampleRecords = [
        SELECT Id, ou_name__c, work_location_country__c, open_pipe_prod_nm__c, 
               open_pipe_ae_score__c, open_pipe_original_openpipe_alloc_amt__c,
               open_pipe_opty_nm__c, open_pipe_opty_stg_nm__c
        FROM Agent_Open_Pipe__c 
        LIMIT 1
    ];
    
    if (!sampleRecords.isEmpty()) {
        Agent_Open_Pipe__c sample = sampleRecords[0];
        System.debug('Sample Record:');
        System.debug('  ID: ' + sample.Id);
        System.debug('  OU: ' + sample.ou_name__c);
        System.debug('  Country: ' + sample.work_location_country__c);
        System.debug('  Product: ' + sample.open_pipe_prod_nm__c);
        System.debug('  AE Score: ' + sample.open_pipe_ae_score__c);
        System.debug('  Amount: ' + sample.open_pipe_original_openpipe_alloc_amt__c);
        System.debug('  Opportunity: ' + sample.open_pipe_opty_nm__c);
        System.debug('  Stage: ' + sample.open_pipe_opty_stg_nm__c);
    } else {
        System.debug('No sample records found');
    }
    
    // Check 7: Test with actual OU and country values from the data
    if (!ouResults.isEmpty() && !countryResults.isEmpty()) {
        String testOU = (String)ouResults[0].get('ou_name__c');
        String testCountry = (String)countryResults[0].get('work_location_country__c');
        
        System.debug('--- Check 7: Test with Real Data Values ---');
        System.debug('Testing with OU: ' + testOU + ', Country: ' + testCountry);
        
        String testResult = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
            testOU,                     // ouName (from actual data)
            testCountry,                // workLocationCountry (from actual data)
            'PRODUCT',                  // groupBy
            '',                         // filterCriteria
            '',                         // restrictInValuesCsv
            false,                      // perAENormalize
            5,                          // limitN
            'SUM',                      // aggregationType
            'TOP_PRODUCTS_BY_AE_SCORE'  // analysisType
        );
        
        System.debug('Test Result:');
        System.debug(testResult);
    }
    
    System.debug('=== Diagnosis completed ===');
    
} catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'Diagnosis failed with error: ' + e.getMessage());
    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
}
