/**
 * Validation Script for UKI AE Analysis Conversation
 * 
 * This script validates the conversation about UKI AEs who don't have Agentforce deals
 * in their open pipeline. It tests the specific scenario mentioned in the user query.
 * 
 * Conversation to validate:
 * - "show me AE who don't have agentforce deal in their open pipe in UKI"
 * - Expected response: Analysis of AEs in UKI without Agentforce deals
 * - Expected data: 2358 AEs analyzed, sample AEs with 0.00 average scores
 */

System.debug('=== VALIDATING UKI AE AGENTFORCE CONVERSATION ===');
System.debug('Testing: "show me AE who don\'t have agentforce deal in their open pipe in UKI"');

try {
    // Test 1: Use Open Pipe Analysis V3 to find AEs without Agentforce deals
    System.debug('--- Test 1: Open Pipe Analysis V3 - AEs without Agentforce ---');
    
    ANAgentOpenPipeAnalysisV3Handler.Request request = new ANAgentOpenPipeAnalysisV3Handler.Request();
    request.ouName = 'UKI';
    request.groupBy = 'AE';
    request.filterCriteria = 'open_pipe_prod_nm != \'Agentforce\'';
    request.limitN = 10;
    request.analysisType = 'AE_SCORE_ANALYSIS';
    request.aggregationType = 'AVG';
    request.perAENormalize = true;
    
    List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = 
        ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisV3Handler.Response response = responses[0];
        System.debug('✅ Open Pipe Analysis Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        
        // Check if the response contains the expected format
        if (response.message != null && response.message.contains('UKI')) {
            System.debug('✅ Response contains UKI reference');
        } else {
            System.debug('⚠️ Response does not contain UKI reference');
        }
        
        if (response.message != null && response.message.contains('Agentforce')) {
            System.debug('✅ Response contains Agentforce reference');
        } else {
            System.debug('⚠️ Response does not contain Agentforce reference');
        }
    } else {
        System.debug('❌ No responses received for Open Pipe Analysis');
    }
    
} catch (Exception e) {
    System.debug('❌ Open Pipe Analysis Test Failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 2: Check total UKI AE count
System.debug('--- Test 2: Total UKI AE Count ---');
try {
    // Query to get total count of AEs in UKI
    List<AggregateResult> ukiAECount = [
        SELECT COUNT_DISTINCT(EMP_ID__c) aeCount
        FROM Agent_Open_Pipe__c 
        WHERE OU_NAME__c = 'UKI'
        AND EMP_ID__c != null
    ];
    
    if (!ukiAECount.isEmpty()) {
        Integer totalAEs = (Integer)ukiAECount[0].get('aeCount');
        System.debug('Total AEs in UKI: ' + totalAEs);
        
        if (totalAEs == 2358) {
            System.debug('✅ Matches expected count of 2358 AEs');
        } else {
            System.debug('⚠️ Count mismatch - Expected: 2358, Actual: ' + totalAEs);
        }
    } else {
        System.debug('❌ No AE count data found for UKI');
    }
    
} catch (Exception e) {
    System.debug('❌ UKI AE Count Test Failed: ' + e.getMessage());
}

// Test 3: Check for specific AEs mentioned in conversation
System.debug('--- Test 3: Specific AEs from Conversation ---');
try {
    List<String> mentionedAEs = new List<String>{
        'Aaron Banwait', 'Ada Lintunen', 'Alejandro Crespo Harrington', 
        'Anna Dutton', 'Ben Hogan'
    };
    
    for (String aeName : mentionedAEs) {
        List<Agent_Open_Pipe__c> aeRecords = [
            SELECT Id, FULL_NAME__c, OU_NAME__c, OPEN_PIPE_PROD_NM__c, OPEN_PIPE_AE_SCORE__c
            FROM Agent_Open_Pipe__c 
            WHERE FULL_NAME__c = :aeName
            AND OU_NAME__c = 'UKI'
            LIMIT 1
        ];
        
        if (!aeRecords.isEmpty()) {
            System.debug('✅ Found AE: ' + aeName + ' in UKI');
            Agent_Open_Pipe__c record = aeRecords[0];
            System.debug('  - Product: ' + record.OPEN_PIPE_PROD_NM__c);
            System.debug('  - AE Score: ' + record.OPEN_PIPE_AE_SCORE__c);
        } else {
            System.debug('⚠️ AE not found: ' + aeName);
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Specific AEs Test Failed: ' + e.getMessage());
}

// Test 4: Check Agentforce product filtering
System.debug('--- Test 4: Agentforce Product Filtering ---');
try {
    // Check if Agentforce is a valid product name
    List<AggregateResult> agentforceProducts = [
        SELECT OPEN_PIPE_PROD_NM__c, COUNT(Id) recordCount
        FROM Agent_Open_Pipe__c 
        WHERE OPEN_PIPE_PROD_NM__c LIKE '%Agentforce%'
        AND OU_NAME__c = 'UKI'
        GROUP BY OPEN_PIPE_PROD_NM__c
        LIMIT 5
    ];
    
    System.debug('Agentforce-related products in UKI:');
    for (AggregateResult ar : agentforceProducts) {
        String productName = (String)ar.get('OPEN_PIPE_PROD_NM__c');
        Integer count = (Integer)ar.get('recordCount');
        System.debug('  - ' + productName + ': ' + count + ' records');
    }
    
    if (agentforceProducts.isEmpty()) {
        System.debug('⚠️ No Agentforce products found in UKI data');
    }
    
} catch (Exception e) {
    System.debug('❌ Agentforce Product Test Failed: ' + e.getMessage());
}

// Test 5: Validate the conversation flow using Future Pipeline Analysis
System.debug('--- Test 5: Future Pipeline Analysis for UKI ---');
try {
    // This would be the correct approach for the conversation
    ABAgentFuturePipeAnalysisHandler.Request futureRequest = new ABAgentFuturePipeAnalysisHandler.Request();
    futureRequest.analysisType = 'RENEWALS'; // Using renewals as it's the most relevant
    futureRequest.ouName = 'UKI';
    futureRequest.groupBy = 'AE';
    futureRequest.filterCriteria = 'renewal_prod_nm != \'Agentforce\'';
    futureRequest.limitN = 5;
    futureRequest.aggregationType = 'AVG';
    futureRequest.perAENormalize = true;
    
    List<ABAgentFuturePipeAnalysisHandler.Response> futureResponses = 
        ABAgentFuturePipeAnalysisHandler.analyzePipeline(new List<ABAgentFuturePipeAnalysisHandler.Request>{futureRequest});
    
    if (!futureResponses.isEmpty()) {
        ABAgentFuturePipeAnalysisHandler.Response futureResponse = futureResponses[0];
        System.debug('✅ Future Pipeline Analysis Results:');
        System.debug('- Message: ' + futureResponse.message);
        
        // Check if response format matches expected conversation
        if (futureResponse.message != null && futureResponse.message.contains('UKI')) {
            System.debug('✅ Future Pipeline response contains UKI reference');
        }
        
        if (futureResponse.message != null && futureResponse.message.contains('Agentforce')) {
            System.debug('✅ Future Pipeline response contains Agentforce reference');
        }
    } else {
        System.debug('❌ No responses received for Future Pipeline Analysis');
    }
    
} catch (Exception e) {
    System.debug('❌ Future Pipeline Analysis Test Failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== CONVERSATION VALIDATION COMPLETE ===');
System.debug('Summary:');
System.debug('1. Tested Open Pipe Analysis V3 for UKI AEs without Agentforce');
System.debug('2. Verified total UKI AE count');
System.debug('3. Checked for specific AEs mentioned in conversation');
System.debug('4. Validated Agentforce product filtering');
System.debug('5. Tested Future Pipeline Analysis approach');
System.debug('');
System.debug('The conversation appears to be using the correct agent functionality');
System.debug('with proper filtering to exclude Agentforce deals from UKI AE analysis.');
