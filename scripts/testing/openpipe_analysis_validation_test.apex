/**
 * OPEN PIPE ANALYSIS VALIDATION TEST
 * 
 * This script performs end-to-end testing of ANAgentOpenPipeAnalysisV3Handler
 * and ANAgentOpenPipeAnalysisV3Service to identify sources of misinformation.
 * 
 * Action: ANAGENT_Open_Pipe_Analysis_V3_2
 * 
 * Tests across:
 * - Multiple OUs (UKI, AMER ACC, LATAM, EMEA, etc.)
 * - Multiple countries (US, UK, Canada, Brazil, etc.)
 * - Multiple segments (CMRCL, ESMB, ENTR, etc.)
 * - Multiple verticals (FINS, HLS, Technology, etc.)
 * 
 * Goal: Ensure agent doesn't generate misinformation about AE counts, data availability, etc.
 */

System.debug('=== OPEN PIPE ANALYSIS VALIDATION TEST ===');
System.debug('Testing ANAgentOpenPipeAnalysisV3Handler for data accuracy...');

// Test Configuration
Map<String, List<String>> testConfig = new Map<String, List<String>>{
    'OUs' => new List<String>{'UKI', 'AMER ACC', 'LATAM', 'EMEA', 'SMB - AMER SMB', 'North Asia'},
    'Countries' => new List<String>{'US', 'United Kingdom', 'Canada', 'Brazil', 'Germany', 'Japan'},
    'Segments' => new List<String>{'CMRCL', 'ESMB', 'ENTR', 'PUBLIC'},
    'Verticals' => new List<String>{'FINS', 'HLS', 'Technology', 'Manufacturing', 'Retail & CG'}
};

// Test 1: Validate Data Source and Counts
System.debug('--- Test 1: Agent_Open_Pipe__c Data Validation ---');
try {
    // Check total records and unique AEs
    List<AggregateResult> openPipeCount = [
        SELECT COUNT(Id) totalRecords, COUNT_DISTINCT(EMP_ID__c) uniqueAEs
        FROM Agent_Open_Pipe__c 
        WHERE IsDeleted = false
    ];
    
    if (!openPipeCount.isEmpty()) {
        Integer totalRecords = (Integer)openPipeCount[0].get('totalRecords');
        Integer uniqueAEs = (Integer)openPipeCount[0].get('uniqueAEs');
        System.debug('Agent_Open_Pipe__c: ' + totalRecords + ' records, ' + uniqueAEs + ' unique AEs');
    }
    
    // Check UKI specifically
    List<AggregateResult> ukiCount = [
        SELECT COUNT(Id) totalRecords, COUNT_DISTINCT(EMP_ID__c) uniqueAEs
        FROM Agent_Open_Pipe__c 
        WHERE OU_NAME__c = 'UKI'
        AND IsDeleted = false
    ];
    
    if (!ukiCount.isEmpty()) {
        Integer totalRecords = (Integer)ukiCount[0].get('totalRecords');
        Integer uniqueAEs = (Integer)ukiCount[0].get('uniqueAEs');
        System.debug('UKI Open Pipe: ' + totalRecords + ' records, ' + uniqueAEs + ' unique AEs');
        
        if (uniqueAEs == 2358) {
            System.debug('✅ UKI actually has 2358 unique AEs in Agent_Open_Pipe__c');
        } else {
            System.debug('⚠️ UKI has ' + uniqueAEs + ' unique AEs, NOT 2358');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Data Source Validation Failed: ' + e.getMessage());
}

// Test 2: UKI Specific Validation (The Problem Case)
System.debug('--- Test 2: UKI Specific Validation ---');
try {
    // Test the exact scenario from the conversation
    ANAgentOpenPipeAnalysisV3Handler.Request ukiRequest = new ANAgentOpenPipeAnalysisV3Handler.Request();
    ukiRequest.ouName = 'UKI';
    ukiRequest.groupBy = 'AE';
    ukiRequest.filterCriteria = 'open_pipe_prod_nm != \'Agentforce\'';
    ukiRequest.limitN = 10;
    ukiRequest.analysisType = 'AE_SCORE_ANALYSIS';
    ukiRequest.aggregationType = 'AVG';
    ukiRequest.perAENormalize = true;
    
    List<ANAgentOpenPipeAnalysisV3Handler.Response> ukiResponses = 
        ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{ukiRequest});
    
    if (!ukiResponses.isEmpty()) {
        ANAgentOpenPipeAnalysisV3Handler.Response response = ukiResponses[0];
        System.debug('UKI Open Pipe Response:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message Length: ' + (response.message != null ? response.message.length() : 0) + ' characters');
        
        if (response.message != null) {
            System.debug('- Contains "Total AEs Analyzed": ' + response.message.contains('Total AEs Analyzed'));
            System.debug('- Contains "2358": ' + response.message.contains('2358'));
            System.debug('- Contains "UKI": ' + response.message.contains('UKI'));
            System.debug('- Contains "Agentforce": ' + response.message.contains('Agentforce'));
            
            // Check for the specific problematic phrase
            if (response.message.contains('Total AEs Analyzed: 2358')) {
                System.debug('🚨 FOUND THE EXACT PROBLEMATIC PHRASE: "Total AEs Analyzed: 2358"');
            }
            
            // Show first 500 characters
            System.debug('First 500 characters of response:');
            System.debug(response.message.substring(0, Math.min(500, response.message.length())));
        }
    }
    
} catch (Exception e) {
    System.debug('❌ UKI Specific Validation Failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 3: Cross-OU Validation
System.debug('--- Test 3: Cross-OU Validation ---');
try {
    for (String ou : testConfig.get('OUs')) {
        System.debug('Testing OU: ' + ou);
        
        ANAgentOpenPipeAnalysisV3Handler.Request request = new ANAgentOpenPipeAnalysisV3Handler.Request();
        request.ouName = ou;
        request.groupBy = 'AE';
        request.limitN = 3;
        request.analysisType = 'AE_SCORE_ANALYSIS';
        request.aggregationType = 'AVG';
        request.perAENormalize = true;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
            ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{request});
        
        if (!responses.isEmpty()) {
            ANAgentOpenPipeAnalysisV3Handler.Response response = responses[0];
            System.debug('  ' + ou + ' Response: ' + (response.message != null ? response.message.length() + ' chars' : 'null'));
            
            // Check for suspiciously high numbers
            if (response.message != null && response.message.contains('Total AEs Analyzed:')) {
                System.debug('  🚨 FOUND "Total AEs Analyzed" PHRASE IN ' + ou);
            }
            if (response.message != null && response.message.contains('2358')) {
                System.debug('  🚨 FOUND "2358" IN ' + ou + ' RESPONSE');
            }
        }
    }
} catch (Exception e) {
    System.debug('❌ Cross-OU Validation Failed: ' + e.getMessage());
}

// Test 4: Country-Based Validation
System.debug('--- Test 4: Country-Based Validation ---');
try {
    for (String country : testConfig.get('Countries')) {
        System.debug('Testing Country: ' + country);
        
        ANAgentOpenPipeAnalysisV3Handler.Request request = new ANAgentOpenPipeAnalysisV3Handler.Request();
        request.workLocationCountry = country;
        request.groupBy = 'AE';
        request.limitN = 3;
        request.analysisType = 'AE_SCORE_ANALYSIS';
        request.aggregationType = 'AVG';
        request.perAENormalize = true;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
            ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{request});
        
        if (!responses.isEmpty()) {
            ANAgentOpenPipeAnalysisV3Handler.Response response = responses[0];
            System.debug('  ' + country + ' Response: ' + (response.message != null ? response.message.length() + ' chars' : 'null'));
        }
    }
} catch (Exception e) {
    System.debug('❌ Country-Based Validation Failed: ' + e.getMessage());
}

// Test 5: Service Layer Direct Testing
System.debug('--- Test 5: Service Layer Direct Testing ---');
try {
    // Test the service layer directly
    String serviceResult = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
        'UKI',                // ouName
        null,                 // workLocationCountry
        'AE',                 // groupBy
        'open_pipe_prod_nm != \'Agentforce\'', // filterCriteria
        null,                 // restrictInValuesCsv
        true,                 // perAENormalize
        5,                    // limitN
        'AVG',                // aggregationType
        'AE_SCORE_ANALYSIS',  // analysisType
        false,                // includeClosureProb
        false,                // includeStageBottlenecks
        false,                // includePMF
        false,                // includeAEBenchmarks
        false                 // includeHealthScore
    );
    
    System.debug('Direct Service Result:');
    System.debug('- Length: ' + serviceResult.length() + ' characters');
    System.debug('- Contains "Total AEs Analyzed": ' + serviceResult.contains('Total AEs Analyzed'));
    System.debug('- Contains "2358": ' + serviceResult.contains('2358'));
    System.debug('- Contains "UKI": ' + serviceResult.contains('UKI'));
    System.debug('- Contains "Agentforce": ' + serviceResult.contains('Agentforce'));
    
    if (serviceResult.contains('Total AEs Analyzed: 2358')) {
        System.debug('🚨 FOUND INFLATED NUMBER IN DIRECT SERVICE CALL');
    }
    
    // Show first 500 characters
    System.debug('First 500 characters of service result:');
    System.debug(serviceResult.substring(0, Math.min(500, serviceResult.length())));
    
} catch (Exception e) {
    System.debug('❌ Service Layer Direct Testing Failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 6: Check for hardcoded values in the service
System.debug('--- Test 6: Hardcoded Values Check ---');
try {
    // Search for any hardcoded "2358" or "Total AEs Analyzed" in the service
    // We'll test with different parameters to see if the number appears consistently
    
    List<String> testOUs = new List<String>{'UKI', 'AMER ACC', 'LATAM', 'EMEA'};
    
    for (String ou : testOUs) {
        String result = ANAgentOpenPipeAnalysisV3Service.analyzeOpenPipe(
            ou, null, 'AE', null, null, true, 1, 'AVG', 'AE_SCORE_ANALYSIS', 
            false, false, false, false, false
        );
        
        System.debug('OU ' + ou + ' Service Result:');
        System.debug('- Contains "Total AEs Analyzed": ' + result.contains('Total AEs Analyzed'));
        System.debug('- Contains "2358": ' + result.contains('2358'));
        
        if (result.contains('2358')) {
            System.debug('🚨 FOUND 2358 IN ' + ou + ' SERVICE RESULT');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Hardcoded Values Check Failed: ' + e.getMessage());
}

// Test 7: Check the actual data being queried
System.debug('--- Test 7: Actual Data Query Check ---');
try {
    // Query the actual data to see what's really there
    List<AggregateResult> actualData = [
        SELECT FULL_NAME__c, COUNT(Id) recordCount, AVG(OPEN_PIPE_AE_SCORE__c) avgScore
        FROM Agent_Open_Pipe__c 
        WHERE OU_NAME__c = 'UKI'
        AND IsDeleted = false
        AND open_pipe_prod_nm__c != 'Agentforce'
        GROUP BY FULL_NAME__c
        ORDER BY COUNT(Id) DESC
        LIMIT 5
    ];
    
    System.debug('Actual UKI Open Pipe Data (excluding Agentforce):');
    System.debug('- Number of AEs found: ' + actualData.size());
    
    for (AggregateResult ar : actualData) {
        String aeName = (String)ar.get('FULL_NAME__c');
        Integer count = (Integer)ar.get('recordCount');
        Decimal avgScore = (Decimal)ar.get('avgScore');
        System.debug('  - ' + aeName + ': ' + count + ' records, avg score: ' + avgScore);
    }
    
    // Check total count
    List<AggregateResult> totalCount = [
        SELECT COUNT_DISTINCT(FULL_NAME__c) uniqueAEs
        FROM Agent_Open_Pipe__c 
        WHERE OU_NAME__c = 'UKI'
        AND IsDeleted = false
        AND open_pipe_prod_nm__c != 'Agentforce'
    ];
    
    if (!totalCount.isEmpty()) {
        Integer uniqueAEs = (Integer)totalCount[0].get('uniqueAEs');
        System.debug('Total unique AEs in UKI (excluding Agentforce): ' + uniqueAEs);
        
        if (uniqueAEs == 2358) {
            System.debug('✅ ACTUAL DATA CONTAINS 2358 AEs - NOT MISINFORMATION');
        } else {
            System.debug('⚠️ ACTUAL DATA HAS ' + uniqueAEs + ' AEs, NOT 2358');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Actual Data Query Check Failed: ' + e.getMessage());
}

// Test 8: Check buildAnalysisMessage method for hardcoded text
System.debug('--- Test 8: BuildAnalysisMessage Method Check ---');
try {
    // We can't directly access the private method, but we can check if the response
    // contains any hardcoded text by testing different scenarios
    
    // Test with empty results
    ANAgentOpenPipeAnalysisV3Handler.Request emptyRequest = new ANAgentOpenPipeAnalysisV3Handler.Request();
    emptyRequest.ouName = 'NON_EXISTENT_OU';
    emptyRequest.groupBy = 'AE';
    emptyRequest.limitN = 5;
    emptyRequest.analysisType = 'AE_SCORE_ANALYSIS';
    
    List<ANAgentOpenPipeAnalysisV3Handler.Response> emptyResponses = 
        ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{emptyRequest});
    
    if (!emptyResponses.isEmpty()) {
        ANAgentOpenPipeAnalysisV3Handler.Response response = emptyResponses[0];
        System.debug('Empty Results Response:');
        System.debug('- Contains "Total AEs Analyzed": ' + (response.message != null && response.message.contains('Total AEs Analyzed')));
        System.debug('- Contains "2358": ' + (response.message != null && response.message.contains('2358')));
        
        if (response.message != null && response.message.contains('2358')) {
            System.debug('🚨 FOUND 2358 IN EMPTY RESULTS RESPONSE - HARDCODED TEXT DETECTED');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ BuildAnalysisMessage Method Check Failed: ' + e.getMessage());
}

System.debug('=== OPEN PIPE ANALYSIS VALIDATION TEST COMPLETE ===');
System.debug('');
System.debug('Summary of Tests:');
System.debug('1. ✅ Data Source Validation');
System.debug('2. ✅ UKI Specific Validation');
System.debug('3. ✅ Cross-OU Validation');
System.debug('4. ✅ Country-Based Validation');
System.debug('5. ✅ Service Layer Direct Testing');
System.debug('6. ✅ Hardcoded Values Check');
System.debug('7. ✅ Actual Data Query Check');
System.debug('8. ✅ BuildAnalysisMessage Method Check');
System.debug('');
System.debug('Look for 🚨 markers above to identify sources of misinformation.');
System.debug('The agent should not generate inflated numbers like "Total AEs Analyzed: 2358".');
System.debug('If 2358 is found in actual data, then it\'s accurate. If not, it\'s misinformation.');
