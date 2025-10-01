// Focused 10 Utterance Test for MCP Agent Integration
// Tests key scenarios with SOQL verification to detect suspicious responses

System.debug('=== 10 UTTERANCES MCP FOCUSED TEST ===');
System.debug('Timestamp: ' + System.now());
System.debug('');

// Test configuration
Integer totalTests = 0;
Integer passedTests = 0;
Integer suspiciousTests = 0;
Integer failedTests = 0;
List<String> suspiciousResults = new List<String>();
List<String> failedResults = new List<String>();

// Focused test data - 10 key scenarios
List<String> testQueries = new List<String>{
    'List AEs in UKI who don\'t have agentforce deals',
    'Show me AEs without Data Cloud in AMER ACC',
    'Find AEs excluding Slack in EMEA ENTR',
    'AEs who lack Tableau Cloud in UKI',
    'Show AEs not having MuleSoft in AMER ACC',
    'List AEs in UKI who have agentforce deals',
    'Show me AEs with Data Cloud in AMER ACC',
    'Find AEs including Slack in EMEA ENTR',
    'AEs who have Tableau Cloud in UKI',
    'Show AEs having MuleSoft in AMER ACC'
};

// Process each test
for (String query : testQueries) {
    totalTests++;
    
    System.debug('\\n--- Test ' + totalTests + ': ' + query + ' ---');
    
    // Parse query to extract parameters
    String ouName = 'UKI'; // default
    String product = 'agentforce'; // default
    Boolean isNegative = true; // default
    
    // Extract OU
    if (query.contains('UKI')) ouName = 'UKI';
    else if (query.contains('AMER ACC')) ouName = 'AMER ACC';
    else if (query.contains('EMEA ENTR')) ouName = 'EMEA ENTR';
    
    // Extract product
    if (query.contains('agentforce')) product = 'agentforce';
    else if (query.contains('Data Cloud')) product = 'Data Cloud';
    else if (query.contains('Slack')) product = 'Slack';
    else if (query.contains('Tableau')) product = 'Tableau Cloud';
    else if (query.contains('MuleSoft')) product = 'MuleSoft';
    
    // Determine if negative or positive
    isNegative = query.contains('don\'t have') || query.contains('without') || 
                query.contains('excluding') || query.contains('lack') || 
                query.contains('not having');
    
    try {
        // Test MCP adapter
        Map<String, Object> args = new Map<String, Object>{
            'ouName' => ouName,
            'limit' => '10',
            'correlationId' => 'test-' + Math.random().intValue()
        };
        
        if (isNegative) {
            args.put('excludeProducts', product);
            args.put('negativeIntent', true);
        } else {
            args.put('product', product);
        }
        
        String argsJson = JSON.serialize(args);
        List<AN_OpenPipeV3_FromMCP.Result> mcpResults = AN_OpenPipeV3_FromMCP.run(new List<String>{argsJson});
        
        // Verify with SOQL (simplified)
        Integer expectedCount = 0;
        try {
            if (isNegative) {
                // For negative queries, count AEs without the specified product
                List<AggregateResult> allAEs = [
                    SELECT COUNT_DISTINCT(emp_id__c) uniqueAEs
                    FROM Agent_Open_Pipe__c 
                    WHERE OU_NAME__c = :ouName
                    AND IsDeleted = false
                ];
                
                List<AggregateResult> withProduct = [
                    SELECT COUNT_DISTINCT(emp_id__c) uniqueAEs
                    FROM Agent_Open_Pipe__c 
                    WHERE OU_NAME__c = :ouName
                    AND IsDeleted = false
                    AND open_pipe_prod_nm__c = :product
                ];
                
                Integer totalCount = allAEs.isEmpty() ? 0 : (Integer)allAEs[0].get('uniqueAEs');
                Integer withProductCount = withProduct.isEmpty() ? 0 : (Integer)withProduct[0].get('uniqueAEs');
                expectedCount = totalCount - withProductCount;
            } else {
                // For positive queries, count AEs with the specified product
                List<AggregateResult> withProduct = [
                    SELECT COUNT_DISTINCT(emp_id__c) uniqueAEs
                    FROM Agent_Open_Pipe__c 
                    WHERE OU_NAME__c = :ouName
                    AND IsDeleted = false
                    AND open_pipe_prod_nm__c = :product
                ];
                
                expectedCount = withProduct.isEmpty() ? 0 : (Integer)withProduct[0].get('uniqueAEs');
            }
        } catch (Exception soqlError) {
            System.debug('SOQL Error: ' + soqlError.getMessage());
            expectedCount = -1; // Mark as unable to verify
        }
        
        // Analyze MCP results
        if (!mcpResults.isEmpty()) {
            AN_OpenPipeV3_FromMCP.Result mcpResult = mcpResults[0];
            
            if (mcpResult.success) {
                // Extract count from message
                Integer reportedCount = null;
                if (mcpResult.message != null) {
                    Pattern countPattern = Pattern.compile('(?:Total AEs|AEs|Found|Analyzed).*?(\\d+)');
                    Matcher matcher = countPattern.matcher(mcpResult.message);
                    if (matcher.find()) {
                        reportedCount = Integer.valueOf(matcher.group(1));
                    }
                }
                
                if (reportedCount != null) {
                    if (expectedCount == -1) {
                        // Could not verify with SOQL
                        System.debug('⚠️ UNVERIFIED: Got ' + reportedCount + ' (SOQL verification failed)');
                    } else if (reportedCount == expectedCount) {
                        passedTests++;
                        System.debug('✅ PASS: Expected ' + expectedCount + ', Got ' + reportedCount);
                    } else if (reportedCount == 0) {
                        suspiciousTests++;
                        suspiciousResults.add('Test ' + totalTests + ': Expected ' + expectedCount + ', Got 0 (SUSPICIOUS)');
                        System.debug('⚠️ SUSPICIOUS: Expected ' + expectedCount + ', Got 0');
                    } else {
                        failedTests++;
                        failedResults.add('Test ' + totalTests + ': Expected ' + expectedCount + ', Got ' + reportedCount);
                        System.debug('❌ FAIL: Expected ' + expectedCount + ', Got ' + reportedCount);
                    }
                } else {
                    suspiciousTests++;
                    suspiciousResults.add('Test ' + totalTests + ': Could not extract count from response');
                    System.debug('⚠️ SUSPICIOUS: Could not extract count from response');
                }
            } else {
                failedTests++;
                failedResults.add('Test ' + totalTests + ': MCP adapter failed');
                System.debug('❌ FAIL: MCP adapter failed');
            }
        } else {
            failedTests++;
            failedResults.add('Test ' + totalTests + ': No MCP results returned');
            System.debug('❌ FAIL: No MCP results returned');
        }
    } catch (Exception e) {
        failedTests++;
        failedResults.add('Test ' + totalTests + ': Exception - ' + e.getMessage());
        System.debug('❌ FAIL: Exception - ' + e.getMessage());
    }
}

// Final results
System.debug('\\n=== FINAL RESULTS ===');
System.debug('Total Tests: ' + totalTests);
System.debug('Passed: ' + passedTests + ' (' + (passedTests * 100 / totalTests) + '%)');
System.debug('Suspicious: ' + suspiciousTests + ' (' + (suspiciousTests * 100 / totalTests) + '%)');
System.debug('Failed: ' + failedTests + ' (' + (failedTests * 100 / totalTests) + '%)');

if (!suspiciousResults.isEmpty()) {
    System.debug('\\n=== SUSPICIOUS RESULTS ===');
    for (String result : suspiciousResults) {
        System.debug(result);
    }
}

if (!failedResults.isEmpty()) {
    System.debug('\\n=== FAILED RESULTS ===');
    for (String result : failedResults) {
        System.debug(result);
    }
}

System.debug('\\n=== TEST COMPLETE ===');
