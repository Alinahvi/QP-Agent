/**
 * RUN AGENT ACTION TEST
 * 
 * This script runs the actual ANAGENT_Open_Pipe_Analysis_V3_2 action
 * to see what response is generated and identify the source of misinformation.
 */

System.debug('=== RUN AGENT ACTION TEST ===');
System.debug('Testing ANAGENT_Open_Pipe_Analysis_V3_2 action...');

// Test 1: Run the exact scenario from the conversation
System.debug('--- Test 1: UKI AEs without Agentforce (Original Problem) ---');
try {
    ANAgentOpenPipeAnalysisV3Handler.Request request = new ANAgentOpenPipeAnalysisV3Handler.Request();
    request.ouName = 'UKI';
    request.groupBy = 'AE';
    request.filterCriteria = 'open_pipe_prod_nm != \'Agentforce\'';
    request.limitN = 10;
    request.analysisType = 'AE_SCORE_ANALYSIS';
    request.aggregationType = 'AVG';
    request.perAENormalize = true;
    
    System.debug('Request Parameters:');
    System.debug('- OU Name: ' + request.ouName);
    System.debug('- Group By: ' + request.groupBy);
    System.debug('- Filter Criteria: ' + request.filterCriteria);
    System.debug('- Limit N: ' + request.limitN);
    System.debug('- Analysis Type: ' + request.analysisType);
    System.debug('- Aggregation Type: ' + request.aggregationType);
    System.debug('- Per-AE Normalized: ' + request.perAENormalize);
    
    List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
        ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisV3Handler.Response response = responses[0];
        System.debug('Response Generated:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message Length: ' + (response.message != null ? response.message.length() : 0) + ' characters');
        
        if (response.message != null) {
            System.debug('Full Response Message:');
            System.debug('==========================================');
            System.debug(response.message);
            System.debug('==========================================');
            
            // Check for specific problematic phrases
            System.debug('Response Analysis:');
            System.debug('- Contains "Total AEs Analyzed": ' + response.message.contains('Total AEs Analyzed'));
            System.debug('- Contains "2358": ' + response.message.contains('2358'));
            System.debug('- Contains "UKI": ' + response.message.contains('UKI'));
            System.debug('- Contains "Agentforce": ' + response.message.contains('Agentforce'));
            System.debug('- Contains "Average Score": ' + response.message.contains('Average Score'));
            System.debug('- Contains "0.00": ' + response.message.contains('0.00'));
            
            // Look for the exact problematic phrase
            if (response.message.contains('Total AEs Analyzed: 2358')) {
                System.debug('🚨 FOUND THE EXACT PROBLEMATIC PHRASE: "Total AEs Analyzed: 2358"');
            }
            
            // Check if it contains the sample AEs mentioned in the conversation
            List<String> mentionedAEs = new List<String>{
                'Aaron Banwait', 'Ada Lintunen', 'Alejandro Crespo Harrington', 
                'Anna Dutton', 'Ben Hogan'
            };
            
            for (String aeName : mentionedAEs) {
                if (response.message.contains(aeName)) {
                    System.debug('✅ Found mentioned AE: ' + aeName);
                }
            }
        }
    } else {
        System.debug('❌ No responses received');
    }
    
} catch (Exception e) {
    System.debug('❌ UKI AEs without Agentforce Test Failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 2: Run with different analysis types to see if the issue is specific to AE_SCORE_ANALYSIS
System.debug('--- Test 2: Different Analysis Types ---');
try {
    List<String> analysisTypes = new List<String>{
        'STAGE_COUNT', 'PRODUCT_PERFORMANCE', 'AE_SCORE_ANALYSIS', 
        'DAYS_IN_STAGE', 'OPPORTUNITY_DETAILS'
    };
    
    for (String analysisType : analysisTypes) {
        System.debug('Testing Analysis Type: ' + analysisType);
        
        ANAgentOpenPipeAnalysisV3Handler.Request request = new ANAgentOpenPipeAnalysisV3Handler.Request();
        request.ouName = 'UKI';
        request.groupBy = 'AE';
        request.filterCriteria = 'open_pipe_prod_nm != \'Agentforce\'';
        request.limitN = 3;
        request.analysisType = analysisType;
        request.aggregationType = 'AVG';
        request.perAENormalize = true;
        
        List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
            ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{request});
        
        if (!responses.isEmpty()) {
            ANAgentOpenPipeAnalysisV3Handler.Response response = responses[0];
            System.debug('  ' + analysisType + ' Response:');
            System.debug('    - Length: ' + (response.message != null ? response.message.length() : 0) + ' chars');
            System.debug('    - Contains "Total AEs Analyzed": ' + (response.message != null && response.message.contains('Total AEs Analyzed')));
            System.debug('    - Contains "2358": ' + (response.message != null && response.message.contains('2358')));
            
            if (response.message != null && response.message.contains('2358')) {
                System.debug('    🚨 FOUND 2358 IN ' + analysisType + ' RESPONSE');
            }
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Different Analysis Types Test Failed: ' + e.getMessage());
}

// Test 3: Run with different OUs to see if the issue is UKI-specific
System.debug('--- Test 3: Different OUs ---');
try {
    List<String> testOUs = new List<String>{'UKI', 'AMER ACC', 'LATAM', 'EMEA'};
    
    for (String ou : testOUs) {
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
            System.debug('  ' + ou + ' Response:');
            System.debug('    - Length: ' + (response.message != null ? response.message.length() : 0) + ' chars');
            System.debug('    - Contains "Total AEs Analyzed": ' + (response.message != null && response.message.contains('Total AEs Analyzed')));
            System.debug('    - Contains "2358": ' + (response.message != null && response.message.contains('2358')));
            
            if (response.message != null && response.message.contains('2358')) {
                System.debug('    🚨 FOUND 2358 IN ' + ou + ' RESPONSE');
            }
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Different OUs Test Failed: ' + e.getMessage());
}

// Test 4: Check if the issue is in the service layer by calling it directly
System.debug('--- Test 4: Direct Service Layer Call ---');
try {
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
    
    // Show first 1000 characters
    System.debug('First 1000 characters of service result:');
    System.debug(serviceResult.substring(0, Math.min(1000, serviceResult.length())));
    
} catch (Exception e) {
    System.debug('❌ Direct Service Layer Call Failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 5: Check the actual data to see if 2358 is accurate
System.debug('--- Test 5: Actual Data Verification ---');
try {
    // Check total unique AEs in UKI
    List<AggregateResult> totalUKIAEs = [
        SELECT COUNT_DISTINCT(EMP_ID__c) uniqueAEs
        FROM Agent_Open_Pipe__c 
        WHERE OU_NAME__c = 'UKI'
        AND IsDeleted = false
    ];
    
    if (!totalUKIAEs.isEmpty()) {
        Integer totalAEs = (Integer)totalUKIAEs[0].get('uniqueAEs');
        System.debug('Total unique AEs in UKI: ' + totalAEs);
        
        if (totalAEs == 2358) {
            System.debug('✅ ACTUAL DATA CONTAINS 2358 AEs - NOT MISINFORMATION');
        } else {
            System.debug('⚠️ ACTUAL DATA HAS ' + totalAEs + ' AEs, NOT 2358');
        }
    }
    
    // Check AEs without Agentforce
    List<AggregateResult> ukiWithoutAgentforce = [
        SELECT COUNT_DISTINCT(EMP_ID__c) uniqueAEs
        FROM Agent_Open_Pipe__c 
        WHERE OU_NAME__c = 'UKI'
        AND IsDeleted = false
        AND open_pipe_prod_nm__c != 'Agentforce'
    ];
    
    if (!ukiWithoutAgentforce.isEmpty()) {
        Integer uniqueAEs = (Integer)ukiWithoutAgentforce[0].get('uniqueAEs');
        System.debug('UKI AEs without Agentforce: ' + uniqueAEs);
    }
    
} catch (Exception e) {
    System.debug('❌ Actual Data Verification Failed: ' + e.getMessage());
}

System.debug('=== RUN AGENT ACTION TEST COMPLETE ===');
System.debug('');
System.debug('Key Findings:');
System.debug('1. ✅ Tested original UKI scenario');
System.debug('2. ✅ Tested different analysis types');
System.debug('3. ✅ Tested different OUs');
System.debug('4. ✅ Tested direct service layer call');
System.debug('5. ✅ Verified actual data');
System.debug('');
System.debug('Look for 🚨 markers to identify sources of misinformation.');
System.debug('If 2358 appears in responses but not in actual data, it\'s misinformation.');
System.debug('If 2358 appears in actual data, then the agent is reporting accurate information.');
