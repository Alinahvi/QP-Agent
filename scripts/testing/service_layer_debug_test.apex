/**
 * SERVICE LAYER DEBUG TEST
 * 
 * This script specifically debugs the ABAgentFuturePipeAnalysisService
 * to identify where the misinformation is coming from.
 * 
 * Focus: Step-by-step debugging of the service layer logic
 */

System.debug('=== SERVICE LAYER DEBUG TEST ===');
System.debug('Debugging ABAgentFuturePipeAnalysisService for misinformation sources...');

// Test 1: Debug the queryTopPipeline method directly
System.debug('--- Test 1: Direct QueryTopPipeline Debug ---');
try {
    // Create a PipelineQueryRequest for UKI Renewals
    ABAgentFuturePipeAnalysisService.PipelineQueryRequest req = new ABAgentFuturePipeAnalysisService.PipelineQueryRequest(
        'RENEWALS',           // analysisType
        'UKI',                // ouName
        null,                 // workLocationCountry
        'AE',                 // groupBy
        'renewal_prod_nm != \'Agentforce\'', // filterCriteria
        null,                 // restrictInValuesCsv
        false,                // perAENormalize
        5,                    // limitN
        'COUNT',              // aggregationType
        'RENEWALS_ANALYSIS',  // analysisTypeDetail
        null,                 // startDate
        null                  // endDate
    );
    
    System.debug('PipelineQueryRequest created:');
    System.debug('- Analysis Type: ' + req.analysisType);
    System.debug('- OU Name: ' + req.ouName);
    System.debug('- Group By: ' + req.groupBy);
    System.debug('- Filter Criteria: ' + req.filterCriteria);
    System.debug('- Limit N: ' + req.limitN);
    System.debug('- Aggregation Type: ' + req.aggregationType);
    
    // Call queryTopPipeline directly
    List<ABAgentFuturePipeAnalysisService.PipelineRowDTO> results = 
        ABAgentFuturePipeAnalysisService.queryTopPipeline(req);
    
    System.debug('QueryTopPipeline Results:');
    System.debug('- Number of results: ' + results.size());
    
    for (Integer i = 0; i < Math.min(3, results.size()); i++) {
        ABAgentFuturePipeAnalysisService.PipelineRowDTO dto = results[i];
        System.debug('  Result ' + (i+1) + ':');
        System.debug('    - Key: ' + dto.key);
        System.debug('    - Count: ' + dto.count);
        System.debug('    - Amount: ' + dto.amount);
        System.debug('    - Avg Amount: ' + dto.avgAmount);
    }
    
} catch (Exception e) {
    System.debug('❌ Direct QueryTopPipeline Debug Failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 2: Debug the buildAnalysisMessage method
System.debug('--- Test 2: BuildAnalysisMessage Debug ---');
try {
    // Create sample results to test message building
    List<ABAgentFuturePipeAnalysisService.PipelineRowDTO> sampleResults = new List<ABAgentFuturePipeAnalysisService.PipelineRowDTO>();
    
    // Add sample DTOs
    ABAgentFuturePipeAnalysisService.PipelineRowDTO dto1 = new ABAgentFuturePipeAnalysisService.PipelineRowDTO();
    dto1.key = 'John Doe';
    dto1.count = 5;
    dto1.amount = 100000;
    dto1.avgAmount = 20000;
    sampleResults.add(dto1);
    
    ABAgentFuturePipeAnalysisService.PipelineRowDTO dto2 = new ABAgentFuturePipeAnalysisService.PipelineRowDTO();
    dto2.key = 'Jane Smith';
    dto2.count = 3;
    dto2.amount = 75000;
    dto2.avgAmount = 25000;
    sampleResults.add(dto2);
    
    // Create request
    ABAgentFuturePipeAnalysisService.PipelineQueryRequest req = new ABAgentFuturePipeAnalysisService.PipelineQueryRequest(
        'RENEWALS', 'UKI', null, 'AE', 'renewal_prod_nm != \'Agentforce\'', 
        null, false, 5, 'COUNT', 'RENEWALS_ANALYSIS', null, null
    );
    
    // Test the private method by calling the public method that uses it
    String analysisMessage = ABAgentFuturePipeAnalysisService.analyzePipeline(
        'RENEWALS', 'UKI', null, 'AE', 'renewal_prod_nm != \'Agentforce\'', 
        null, false, 5, 'COUNT', 'RENEWALS_ANALYSIS', null, null
    );
    
    System.debug('Analysis Message Generated:');
    System.debug('- Length: ' + analysisMessage.length() + ' characters');
    System.debug('- Contains "Total AEs Analyzed": ' + analysisMessage.contains('Total AEs Analyzed'));
    System.debug('- Contains "2358": ' + analysisMessage.contains('2358'));
    System.debug('- Contains "UKI": ' + analysisMessage.contains('UKI'));
    System.debug('- Contains "Agentforce": ' + analysisMessage.contains('Agentforce'));
    
    // Check for the specific problematic phrase
    if (analysisMessage.contains('Total AEs Analyzed: 2358')) {
        System.debug('🚨 FOUND THE EXACT PROBLEMATIC PHRASE IN ANALYSIS MESSAGE');
    }
    
    // Show first 500 characters of the message
    System.debug('First 500 characters of message:');
    System.debug(analysisMessage.substring(0, Math.min(500, analysisMessage.length())));
    
} catch (Exception e) {
    System.debug('❌ BuildAnalysisMessage Debug Failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 3: Check the actual SOQL query being generated
System.debug('--- Test 3: SOQL Query Generation Debug ---');
try {
    // We can't directly access the private method, but we can infer from the error messages
    // or by looking at the service implementation
    
    // Test with a simple request to see what query is generated
    String result = ABAgentFuturePipeAnalysisService.analyzePipeline(
        'RENEWALS', 'UKI', null, 'AE', null, null, false, 1, 'COUNT', 'RENEWALS_ANALYSIS', null, null
    );
    
    System.debug('Simple UKI Renewals Result:');
    System.debug('- Length: ' + result.length() + ' characters');
    System.debug('- Contains "Total AEs Analyzed": ' + result.contains('Total AEs Analyzed'));
    System.debug('- Contains "2358": ' + result.contains('2358'));
    
    if (result.contains('Total AEs Analyzed: 2358')) {
        System.debug('🚨 FOUND INFLATED NUMBER IN SIMPLE QUERY');
    }
    
} catch (Exception e) {
    System.debug('❌ SOQL Query Generation Debug Failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 4: Check field mapping and validation
System.debug('--- Test 4: Field Mapping and Validation Debug ---');
try {
    // Test the parseFilterCriteria method
    String filterCriteria = 'renewal_prod_nm != \'Agentforce\'';
    String parsedFilter = ABAgentFuturePipeAnalysisService.parseFilterCriteria(filterCriteria, 'RENEWALS');
    
    System.debug('Filter Criteria Parsing:');
    System.debug('- Original: ' + filterCriteria);
    System.debug('- Parsed: ' + parsedFilter);
    
    // Test field suggestions
    String suggestions = ABAgentFuturePipeAnalysisService.getFieldSuggestions('UKI AEs without Agentforce', 'RENEWALS');
    System.debug('Field Suggestions:');
    System.debug('- Length: ' + suggestions.length() + ' characters');
    System.debug('- Contains "2358": ' + suggestions.contains('2358'));
    
    if (suggestions.contains('2358')) {
        System.debug('🚨 FOUND INFLATED NUMBER IN FIELD SUGGESTIONS');
    }
    
} catch (Exception e) {
    System.debug('❌ Field Mapping and Validation Debug Failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 5: Check for hardcoded values in the service
System.debug('--- Test 5: Hardcoded Values Check ---');
try {
    // Test with different OUs to see if the 2358 number appears consistently
    List<String> testOUs = new List<String>{'UKI', 'AMER ACC', 'LATAM', 'EMEA'};
    
    for (String ou : testOUs) {
        String result = ABAgentFuturePipeAnalysisService.analyzePipeline(
            'RENEWALS', ou, null, 'AE', null, null, false, 1, 'COUNT', 'RENEWALS_ANALYSIS', null, null
        );
        
        System.debug('OU ' + ou + ' Result:');
        System.debug('- Contains "Total AEs Analyzed": ' + result.contains('Total AEs Analyzed'));
        System.debug('- Contains "2358": ' + result.contains('2358'));
        
        if (result.contains('2358')) {
            System.debug('🚨 FOUND 2358 IN ' + ou + ' RESULT');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Hardcoded Values Check Failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 6: Check the actual data being queried
System.debug('--- Test 6: Actual Data Query Check ---');
try {
    // Query the actual data to see what's really there
    List<AggregateResult> actualData = [
        SELECT full_name__c, COUNT(Id) recordCount
        FROM Agent_Renewals__c 
        WHERE ou_name__c = 'UKI'
        AND IsDeleted = false
        GROUP BY full_name__c
        ORDER BY COUNT(Id) DESC
        LIMIT 5
    ];
    
    System.debug('Actual UKI Renewals Data:');
    System.debug('- Number of AEs found: ' + actualData.size());
    
    for (AggregateResult ar : actualData) {
        String aeName = (String)ar.get('full_name__c');
        Integer count = (Integer)ar.get('recordCount');
        System.debug('  - ' + aeName + ': ' + count + ' records');
    }
    
    // Check total count
    List<AggregateResult> totalCount = [
        SELECT COUNT_DISTINCT(full_name__c) uniqueAEs
        FROM Agent_Renewals__c 
        WHERE ou_name__c = 'UKI'
        AND IsDeleted = false
    ];
    
    if (!totalCount.isEmpty()) {
        Integer uniqueAEs = (Integer)totalCount[0].get('uniqueAEs');
        System.debug('Total unique AEs in UKI Renewals: ' + uniqueAEs);
        
        if (uniqueAEs == 2358) {
            System.debug('✅ ACTUAL DATA CONTAINS 2358 AEs - NOT MISINFORMATION');
        } else {
            System.debug('⚠️ ACTUAL DATA HAS ' + uniqueAEs + ' AEs, NOT 2358');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Actual Data Query Check Failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== SERVICE LAYER DEBUG TEST COMPLETE ===');
System.debug('');
System.debug('Key Findings:');
System.debug('1. Checked direct queryTopPipeline method');
System.debug('2. Debugged buildAnalysisMessage method');
System.debug('3. Verified SOQL query generation');
System.debug('4. Tested field mapping and validation');
System.debug('5. Checked for hardcoded values');
System.debug('6. Verified actual data being queried');
System.debug('');
System.debug('Look for 🚨 markers to identify sources of misinformation.');
System.debug('The 2358 number should either be accurate data or a bug in the service layer.');
