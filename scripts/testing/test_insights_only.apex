/**
 * Direct test of buildTopProductsByAEScoreInsights method
 * This bypasses the full analysis flow to test just the insights generation
 */
System.debug('=== Testing buildTopProductsByAEScoreInsights Directly ===');

try {
    // First, get some sample records from UKI OU
    List<Agent_Open_Pipe__c> sampleRecords = [
        SELECT Id, ou_name__c, work_location_country__c, open_pipe_prod_nm__c, 
               open_pipe_ae_score__c, open_pipe_original_openpipe_alloc_amt__c,
               open_pipe_opty_nm__c, open_pipe_opty_stg_nm__c, open_pipe_apm_l2__c
        FROM Agent_Open_Pipe__c 
        WHERE ou_name__c = 'UKI' 
        AND open_pipe_prod_nm__c != null
        AND open_pipe_ae_score__c != null
        LIMIT 50
    ];
    
    System.debug('Found ' + sampleRecords.size() + ' sample records');
    
    if (!sampleRecords.isEmpty()) {
        // Test the method directly
        System.debug('--- Direct Method Test ---');
        
        // Since the method is private, we need to call it through the public analyzeOpenPipe method
        // But let's first check what products we have
        Set<String> products = new Set<String>();
        for (Agent_Open_Pipe__c record : sampleRecords) {
            if (String.isNotBlank(record.open_pipe_prod_nm__c)) {
                products.add(record.open_pipe_prod_nm__c);
            }
        }
        
        System.debug('Products found: ' + products);
        
        // Now let's test with a small subset and see what happens
        String result = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
            'UKI',                     // ouName
            '',                        // workLocationCountry
            'PRODUCT',                 // groupBy
            '',                        // filterCriteria
            '',                        // restrictInValuesCsv
            false,                     // perAENormalize
            3,                         // limitN (small number)
            'SUM',                     // aggregationType
            'TOP_PRODUCTS_BY_AE_SCORE' // analysisType
        );
        
        // Parse the result to extract just the insights section
        String[] sections = result.split('## ');
        for (String section : sections) {
            if (section.startsWith('Insights')) {
                System.debug('=== INSIGHTS SECTION ===');
                System.debug(section);
                System.debug('=== END INSIGHTS SECTION ===');
                break;
            }
        }
        
        System.debug('Full result length: ' + result.length());
        
    } else {
        System.debug('No sample records found');
    }
    
    System.debug('=== Direct test completed ===');
    
} catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'Direct test failed with error: ' + e.getMessage());
    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
}
