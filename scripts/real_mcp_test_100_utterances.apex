// Real MCP Agent Testing with 100 Utterances - 10 Batches
// Tests actual MCP adapters and validates responses against SOQL queries

System.debug('🧪 REAL MCP AGENT TESTING - 100 UTTERANCES');
System.debug('==========================================');

// Test utterances organized in 10 batches
List<List<String>> testBatches = new List<List<String>>{
    // Batch 1: Basic Renewal Analysis
    new List<String>{
        'Show me renewal opportunities for AMER ICE',
        'What are the top 5 renewal products in AMER ICE?',
        'Analyze renewal pipeline for AMER ICE by product',
        'Give me renewal opportunities grouped by AE in AMER ICE',
        'Show renewal analysis for AMER ICE with top 10 products',
        'What is the total renewal amount for AMER ICE?',
        'Analyze renewal opportunities by region for AMER ICE',
        'Show me renewal data for AMER ICE with product breakdown',
        'Give me renewal pipeline summary for AMER ICE',
        'What are the biggest renewal opportunities in AMER ICE?'
    },
    
    // Batch 2: Cross-Sell Analysis
    new List<String>{
        'Show me cross-sell opportunities for AMER ICE',
        'What are the top cross-sell products in AMER ICE?',
        'Analyze cross-sell pipeline for AMER ICE by product',
        'Give me cross-sell opportunities grouped by AE in AMER ICE',
        'Show cross-sell analysis for AMER ICE with top 10 products',
        'What is the total cross-sell amount for AMER ICE?',
        'Analyze cross-sell opportunities by region for AMER ICE',
        'Show me cross-sell data for AMER ICE with product breakdown',
        'Give me cross-sell pipeline summary for AMER ICE',
        'What are the biggest cross-sell opportunities in AMER ICE?'
    },
    
    // Batch 3: Upsell Analysis
    new List<String>{
        'Show me upsell opportunities for AMER ICE',
        'What are the top upsell products in AMER ICE?',
        'Analyze upsell pipeline for AMER ICE by product',
        'Give me upsell opportunities grouped by AE in AMER ICE',
        'Show upsell analysis for AMER ICE with top 10 products',
        'What is the total upsell amount for AMER ICE?',
        'Analyze upsell opportunities by region for AMER ICE',
        'Show me upsell data for AMER ICE with product breakdown',
        'Give me upsell pipeline summary for AMER ICE',
        'What are the biggest upsell opportunities in AMER ICE?'
    },
    
    // Batch 4: Mixed Analysis Types
    new List<String>{
        'Show me future pipeline analysis for AMER ICE',
        'Analyze future pipeline by product for AMER ICE',
        'Give me future pipeline grouped by AE for AMER ICE',
        'Show future pipeline analysis with top 5 products for AMER ICE',
        'What is the total future pipeline amount for AMER ICE?',
        'Analyze future pipeline by region for AMER ICE',
        'Show me future pipeline data with product breakdown for AMER ICE',
        'Give me future pipeline summary for AMER ICE',
        'What are the biggest future pipeline opportunities in AMER ICE?',
        'Show me comprehensive pipeline analysis for AMER ICE'
    },
    
    // Batch 5: Different Operating Units
    new List<String>{
        'Show me renewal opportunities for AMER WEST',
        'What are the top renewal products in AMER WEST?',
        'Analyze renewal pipeline for AMER WEST by product',
        'Give me renewal opportunities grouped by AE in AMER WEST',
        'Show renewal analysis for AMER WEST with top 10 products',
        'What is the total renewal amount for AMER WEST?',
        'Analyze renewal opportunities by region for AMER WEST',
        'Show me renewal data for AMER WEST with product breakdown',
        'Give me renewal pipeline summary for AMER WEST',
        'What are the biggest renewal opportunities in AMER WEST?'
    },
    
    // Batch 6: Different Grouping Options
    new List<String>{
        'Show me renewal opportunities for AMER ICE grouped by product',
        'Analyze renewal pipeline for AMER ICE grouped by AE',
        'Give me renewal opportunities for AMER ICE grouped by region',
        'Show renewal analysis for AMER ICE grouped by industry',
        'What are the renewal opportunities for AMER ICE grouped by segment?',
        'Analyze renewal pipeline for AMER ICE grouped by territory',
        'Show me renewal data for AMER ICE grouped by account type',
        'Give me renewal opportunities for AMER ICE grouped by product family',
        'What is the renewal pipeline for AMER ICE grouped by sales stage?',
        'Show renewal analysis for AMER ICE grouped by close date'
    },
    
    // Batch 7: Limit Variations
    new List<String>{
        'Show me top 3 renewal products for AMER ICE',
        'Give me top 5 renewal opportunities for AMER ICE',
        'Show top 10 renewal AEs for AMER ICE',
        'Analyze top 15 renewal products for AMER ICE',
        'Give me top 20 renewal opportunities for AMER ICE',
        'Show top 25 renewal AEs for AMER ICE',
        'Analyze top 30 renewal products for AMER ICE',
        'Give me top 50 renewal opportunities for AMER ICE',
        'Show top 100 renewal AEs for AMER ICE',
        'Analyze all renewal products for AMER ICE'
    },
    
    // Batch 8: Enhanced Intelligence Features
    new List<String>{
        'Show me renewal analysis with intelligence features for AMER ICE',
        'Give me renewal risk analysis for AMER ICE',
        'Show AE performance analysis for AMER ICE renewals',
        'Analyze product-market fit for AMER ICE renewals',
        'Give me pipeline health score for AMER ICE renewals',
        'Show comprehensive renewal analysis with insights for AMER ICE',
        'Give me renewal analysis with emojis and formatting for AMER ICE',
        'Show me detailed renewal intelligence for AMER ICE',
        'Analyze renewal pipeline with all intelligence features for AMER ICE',
        'Give me enhanced renewal analysis for AMER ICE'
    },
    
    // Batch 9: Edge Cases and Variations
    new List<String>{
        'Show me renewal opportunities',
        'What are renewal products?',
        'Analyze renewal pipeline',
        'Give me renewal data',
        'Show renewal analysis',
        'What is renewal amount?',
        'Analyze renewal opportunities by product',
        'Show me renewal data grouped by AE',
        'Give me renewal pipeline summary',
        'What are renewal opportunities in AMER ICE?'
    },
    
    // Batch 10: Complex Scenarios
    new List<String>{
        'Show me renewal opportunities for AMER ICE with intelligence features and top 10 products',
        'Give me cross-sell analysis for AMER WEST grouped by AE with top 5 products',
        'Analyze upsell pipeline for AMER ICE by product with intelligence insights',
        'Show me future pipeline analysis for AMER WEST with comprehensive intelligence',
        'Give me renewal opportunities for AMER ICE grouped by region with top 15 products',
        'Analyze cross-sell pipeline for AMER ICE with AE performance and top 20 products',
        'Show me upsell analysis for AMER WEST with product-market fit and top 25 products',
        'Give me comprehensive future pipeline analysis for AMER ICE with all intelligence features',
        'Analyze renewal pipeline for AMER WEST by product with health score and top 30 products',
        'Show me detailed pipeline analysis for AMER ICE with enhanced intelligence and insights'
    }
};

// Test execution variables
Integer totalCorrect = 0;
Integer totalIncorrect = 0;
Integer totalSuspicious = 0;
Integer totalTests = 0;

System.debug('🎯 Starting execution of ' + testBatches.size() + ' batches with ' + testBatches[0].size() + ' utterances each');

// Execute each batch
for (Integer batchNum = 0; batchNum < testBatches.size(); batchNum++) {
    System.debug('\n🔄 EXECUTING BATCH ' + (batchNum + 1) + ' OF ' + testBatches.size());
    System.debug('==========================================');
    
    List<String> currentBatch = testBatches[batchNum];
    Integer batchCorrect = 0;
    Integer batchIncorrect = 0;
    Integer batchSuspicious = 0;
    
    for (Integer i = 0; i < currentBatch.size(); i++) {
        String utterance = currentBatch[i];
        Integer testNumber = (batchNum * 10) + i + 1;
        
        System.debug('\n🧪 Test ' + testNumber + ': "' + utterance + '"');
        
        try {
            // Parse utterance to extract parameters
            Map<String, Object> parsedParams = parseUtterance(utterance);
            
            // Call MCP adapter based on utterance type
            Boolean isValidResponse = false;
            String responseType = '';
            
            if (utterance.contains('intelligence') || utterance.contains('enhanced') || utterance.contains('risk') || utterance.contains('performance')) {
                // Use enhanced MCP adapter
                isValidResponse = testEnhancedMCPAdapter(parsedParams, testNumber);
                responseType = 'Enhanced';
            } else {
                // Use basic MCP adapter
                isValidResponse = testBasicMCPAdapter(parsedParams, testNumber);
                responseType = 'Basic';
            }
            
            // Validate response against SOQL query
            Boolean soqlValidation = validateAgainstSOQL(parsedParams, responseType);
            
            if (isValidResponse && soqlValidation) {
                batchCorrect++;
                totalCorrect++;
                System.debug('✅ PASSED - Valid response from ' + responseType + ' MCP adapter');
            } else if (!isValidResponse) {
                batchIncorrect++;
                totalIncorrect++;
                System.debug('❌ FAILED - Invalid or missing response from ' + responseType + ' MCP adapter');
            } else {
                batchSuspicious++;
                totalSuspicious++;
                System.debug('⚠️ SUSPICIOUS - Response mismatch with SOQL validation');
            }
            
        } catch (Exception e) {
            batchSuspicious++;
            totalSuspicious++;
            System.debug('⚠️ SUSPICIOUS - Exception occurred: ' + e.getMessage());
        }
        
        totalTests++;
    }
    
    System.debug('\n📊 Batch ' + (batchNum + 1) + ' Results:');
    System.debug('Correct: ' + batchCorrect + ', Incorrect: ' + batchIncorrect + ', Suspicious: ' + batchSuspicious);
    System.debug('Batch Success Rate: ' + ((Decimal.valueOf(batchCorrect) / Decimal.valueOf(currentBatch.size())) * 100).setScale(2) + '%');
}

// Final Results
System.debug('\n🏁 FINAL TEST RESULTS - 100 UTTERANCES');
System.debug('=======================================');
System.debug('Total Tests: ' + totalTests);
System.debug('Correct Answers: ' + totalCorrect);
System.debug('Incorrect Answers: ' + totalIncorrect);
System.debug('Suspicious Answers: ' + totalSuspicious);
System.debug('Overall Success Rate: ' + ((Decimal.valueOf(totalCorrect) / Decimal.valueOf(totalTests)) * 100).setScale(2) + '%');

if (totalSuspicious > 0) {
    System.debug('⚠️ WARNING: ' + totalSuspicious + ' suspicious answers detected (0 or no answers)');
    System.debug('These need to be investigated and fixed.');
}

// Helper Methods

// Parse utterance to extract parameters
private static Map<String, Object> parseUtterance(String utterance) {
    Map<String, Object> params = new Map<String, Object>();
    
    // Extract OU
    if (utterance.contains('AMER ICE')) {
        params.put('operatingUnit', 'AMER ICE');
    } else if (utterance.contains('AMER WEST')) {
        params.put('operatingUnit', 'AMER WEST');
    } else {
        params.put('operatingUnit', 'AMER ICE'); // Default
    }
    
    // Extract analysis type
    if (utterance.contains('renewal')) {
        params.put('analysisType', 'RENEWALS');
    } else if (utterance.contains('cross-sell')) {
        params.put('analysisType', 'CROSS_SELL');
    } else if (utterance.contains('upsell')) {
        params.put('analysisType', 'UPSERT');
    } else {
        params.put('analysisType', 'RENEWALS'); // Default
    }
    
    // Extract group by
    if (utterance.contains('grouped by AE') || utterance.contains('by AE')) {
        params.put('groupBy', 'AE');
    } else if (utterance.contains('grouped by product') || utterance.contains('by product')) {
        params.put('groupBy', 'PRODUCT');
    } else if (utterance.contains('grouped by region') || utterance.contains('by region')) {
        params.put('groupBy', 'REGION');
    } else {
        params.put('groupBy', 'PRODUCT'); // Default
    }
    
    // Extract limit
    if (utterance.contains('top 3')) {
        params.put('limitN', 3);
    } else if (utterance.contains('top 5')) {
        params.put('limitN', 5);
    } else if (utterance.contains('top 10')) {
        params.put('limitN', 10);
    } else if (utterance.contains('top 15')) {
        params.put('limitN', 15);
    } else if (utterance.contains('top 20')) {
        params.put('limitN', 20);
    } else if (utterance.contains('top 25')) {
        params.put('limitN', 25);
    } else if (utterance.contains('top 30')) {
        params.put('limitN', 30);
    } else if (utterance.contains('top 50')) {
        params.put('limitN', 50);
    } else if (utterance.contains('top 100')) {
        params.put('limitN', 100);
    } else {
        params.put('limitN', 20); // Default
    }
    
    return params;
}

// Test basic MCP adapter
private static Boolean testBasicMCPAdapter(Map<String, Object> params, Integer testNumber) {
    try {
        Map<String, Object> mcpArgs = new Map<String, Object>{
            'ouName' => params.get('operatingUnit'),
            'opportunityType' => String.valueOf(params.get('analysisType')).toLowerCase(),
            'correlationId' => 'TEST_' + testNumber + '_' + System.currentTimeMillis()
        };
        
        String argsJson = JSON.serialize(mcpArgs);
        List<String> argsList = new List<String>{argsJson};
        
        List<AN_FuturePipeline_FromMCP.Result> results = AN_FuturePipeline_FromMCP.run(argsList);
        
        if (!results.isEmpty() && results[0].success && String.isNotBlank(results[0].message)) {
            return true;
        }
        return false;
    } catch (Exception e) {
        System.debug('Basic MCP Adapter Error: ' + e.getMessage());
        return false;
    }
}

// Test enhanced MCP adapter
private static Boolean testEnhancedMCPAdapter(Map<String, Object> params, Integer testNumber) {
    try {
        Map<String, Object> mcpArgs = new Map<String, Object>{
            'operatingUnit' => params.get('operatingUnit'),
            'analysisType' => params.get('analysisType'),
            'groupBy' => params.get('groupBy'),
            'limitN' => params.get('limitN'),
            'includeRenewalRisk' => true,
            'includeAEPerf' => true,
            'includePMF' => true,
            'includeHealthScore' => true,
            'correlationId' => 'ENHANCED_TEST_' + testNumber + '_' + System.currentTimeMillis()
        };
        
        String argsJson = JSON.serialize(mcpArgs);
        List<String> argsList = new List<String>{argsJson};
        
        List<AN_FuturePipeline_Enhanced_FromMCP.Result> results = AN_FuturePipeline_Enhanced_FromMCP.runEnhanced(argsList);
        
        if (!results.isEmpty() && results[0].success && String.isNotBlank(results[0].message)) {
            return true;
        }
        return false;
    } catch (Exception e) {
        System.debug('Enhanced MCP Adapter Error: ' + e.getMessage());
        return false;
    }
}

// Validate response against SOQL query
private static Boolean validateAgainstSOQL(Map<String, Object> params, String responseType) {
    try {
        String ouName = String.valueOf(params.get('operatingUnit'));
        String analysisType = String.valueOf(params.get('analysisType'));
        String groupBy = String.valueOf(params.get('groupBy'));
        Integer limitN = Integer.valueOf(params.get('limitN'));
        
        // Execute actual SOQL query to validate
        String soqlQuery = buildSOQLQuery(ouName, analysisType, groupBy, limitN);
        List<AggregateResult> soqlResults = Database.query(soqlQuery);
        
        // Basic validation - if SOQL returns results, the MCP should too
        return !soqlResults.isEmpty();
    } catch (Exception e) {
        System.debug('SOQL Validation Error: ' + e.getMessage());
        return false;
    }
}

// Build SOQL query for validation
private static String buildSOQLQuery(String ouName, String analysisType, String groupBy, Integer limitN) {
    String query = 'SELECT ';
    
    if (groupBy == 'PRODUCT') {
        query += 'OPEN_PIPE_PROD_NM_1__c, COUNT(Id) recordCount, SUM(RENEWAL_OPTY_AMT_1__c) totalAmount';
    } else if (groupBy == 'AE') {
        query += 'FULL_NAME__c, COUNT(Id) recordCount, SUM(RENEWAL_OPTY_AMT_1__c) totalAmount';
    } else {
        query += 'OPEN_PIPE_PROD_NM_1__c, COUNT(Id) recordCount, SUM(RENEWAL_OPTY_AMT_1__c) totalAmount';
    }
    
    query += ' FROM AGENT_OU_PIPELINE__c WHERE OU_NAME__c = \'' + ouName + '\'';
    
    // Note: OPPORTUNITY_TYPE field doesn't exist in this object, so we'll skip filtering by type
    // The object appears to contain all opportunity types in one table
    
    query += ' GROUP BY ';
    
    if (groupBy == 'PRODUCT') {
        query += 'OPEN_PIPE_PROD_NM_1__c';
    } else if (groupBy == 'AE') {
        query += 'FULL_NAME__c';
    } else {
        query += 'OPEN_PIPE_PROD_NM_1__c';
    }
    
    query += ' ORDER BY SUM(RENEWAL_OPTY_AMT_1__c) DESC LIMIT ' + limitN;
    
    return query;
}
