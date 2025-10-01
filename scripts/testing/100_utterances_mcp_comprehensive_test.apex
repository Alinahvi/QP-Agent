// Comprehensive 100 Utterance Test for MCP Agent Integration
// Tests various scenarios including negative filters, different OUs, products, and countries
// Verifies results against actual SOQL queries to detect suspicious responses

System.debug('=== 100 UTTERANCES MCP COMPREHENSIVE TEST ===');
System.debug('Timestamp: ' + System.now());
System.debug('');

// Test configuration
Integer totalTests = 0;
Integer passedTests = 0;
Integer suspiciousTests = 0;
Integer failedTests = 0;
List<String> suspiciousResults = new List<String>();
List<String> failedResults = new List<String>();

// Helper method to verify SOQL results
Map<String, Object> verifyWithSOQL(String ouName, String country, String product, Boolean isNegative) {
    Map<String, Object> result = new Map<String, Object>();
    
    try {
        if (isNegative) {
            // For negative queries, count AEs without the specified product
            List<AggregateResult> allAEs = [
                SELECT COUNT_DISTINCT(emp_id__c) uniqueAEs
                FROM Agent_Open_Pipe__c 
                WHERE OU_NAME__c = :ouName
                AND IsDeleted = false
                AND (WORK_LOCATION_COUNTRY__c = :country OR :country = null)
            ];
            
            List<AggregateResult> withProduct = [
                SELECT COUNT_DISTINCT(emp_id__c) uniqueAEs
                FROM Agent_Open_Pipe__c 
                WHERE OU_NAME__c = :ouName
                AND IsDeleted = false
                AND (WORK_LOCATION_COUNTRY__c = :country OR :country = null)
                AND open_pipe_prod_nm__c = :product
            ];
            
            Integer totalCount = allAEs.isEmpty() ? 0 : (Integer)allAEs[0].get('uniqueAEs');
            Integer withProductCount = withProduct.isEmpty() ? 0 : (Integer)withProduct[0].get('uniqueAEs');
            Integer withoutProductCount = totalCount - withProductCount;
            
            result.put('totalAEs', totalCount);
            result.put('withProduct', withProductCount);
            result.put('withoutProduct', withoutProductCount);
            result.put('expectedCount', withoutProductCount);
        } else {
            // For positive queries, count AEs with the specified product
            List<AggregateResult> withProduct = [
                SELECT COUNT_DISTINCT(emp_id__c) uniqueAEs
                FROM Agent_Open_Pipe__c 
                WHERE OU_NAME__c = :ouName
                AND IsDeleted = false
                AND (WORK_LOCATION_COUNTRY__c = :country OR :country = null)
                AND open_pipe_prod_nm__c = :product
            ];
            
            Integer withProductCount = withProduct.isEmpty() ? 0 : (Integer)withProduct[0].get('uniqueAEs');
            result.put('expectedCount', withProductCount);
        }
        
        result.put('success', true);
    } catch (Exception e) {
        result.put('success', false);
        result.put('error', e.getMessage());
    }
    
    return result;
}

// Helper method to test MCP adapter
Map<String, Object> testMCPAdapter(String query, String ouName, String country, String product, Boolean isNegative) {
    Map<String, Object> result = new Map<String, Object>();
    
    try {
        Map<String, Object> args = new Map<String, Object>{
            'ouName' => ouName,
            'limit' => '10',
            'correlationId' => 'test-' + Math.random().intValue()
        };
        
        if (String.isNotBlank(country)) {
            args.put('country', country);
        }
        
        if (isNegative) {
            args.put('excludeProducts', product);
            args.put('negativeIntent', true);
        } else {
            args.put('product', product);
        }
        
        String argsJson = JSON.serialize(args);
        List<AN_OpenPipeV3_FromMCP.Result> mcpResults = AN_OpenPipeV3_FromMCP.run(new List<String>{argsJson});
        
        if (!mcpResults.isEmpty()) {
            AN_OpenPipeV3_FromMCP.Result mcpResult = mcpResults[0];
            result.put('success', mcpResult.success);
            result.put('message', mcpResult.message);
            result.put('messageLength', mcpResult.message != null ? mcpResult.message.length() : 0);
            
            // Extract count from message (look for patterns like "Total AEs: X" or "X AEs")
            if (mcpResult.message != null) {
                Pattern countPattern = Pattern.compile('(?:Total AEs|AEs|Found|Analyzed).*?(\\d+)');
                Matcher matcher = countPattern.matcher(mcpResult.message);
                if (matcher.find()) {
                    result.put('reportedCount', Integer.valueOf(matcher.group(1)));
                } else {
                    result.put('reportedCount', null);
                }
            }
        } else {
            result.put('success', false);
            result.put('error', 'No MCP results returned');
        }
    } catch (Exception e) {
        result.put('success', false);
        result.put('error', e.getMessage());
    }
    
    return result;
}

// Test data - 100 utterances across 10 batches
List<List<String>> testBatches = new List<List<String>>{
    // Batch 1: UKI Negative Filters
    new List<String>{
        'List AEs in UKI who don\'t have agentforce deals',
        'Show me AEs without Data Cloud in UKI',
        'Find AEs excluding Slack in UKI',
        'AEs who lack Tableau Cloud in UKI',
        'Show AEs not having MuleSoft in UKI',
        'UKI AEs without Sales Cloud deals',
        'AEs in UKI excluding Marketing Cloud',
        'Find UKI AEs who don\'t have Service Cloud',
        'Show AEs in UKI without Platform deals',
        'UKI AEs lacking Commerce Cloud'
    },
    
    // Batch 2: AMER ACC Negative Filters
    new List<String>{
        'List AEs in AMER ACC who don\'t have agentforce deals',
        'Show me AEs without Data Cloud in AMER ACC',
        'Find AEs excluding Slack in AMER ACC',
        'AEs who lack Tableau Cloud in AMER ACC',
        'Show AEs not having MuleSoft in AMER ACC',
        'AMER ACC AEs without Sales Cloud deals',
        'AEs in AMER ACC excluding Marketing Cloud',
        'Find AMER ACC AEs who don\'t have Service Cloud',
        'Show AEs in AMER ACC without Platform deals',
        'AMER ACC AEs lacking Commerce Cloud'
    },
    
    // Batch 3: EMEA ENTR Negative Filters
    new List<String>{
        'List AEs in EMEA ENTR who don\'t have agentforce deals',
        'Show me AEs without Data Cloud in EMEA ENTR',
        'Find AEs excluding Slack in EMEA ENTR',
        'AEs who lack Tableau Cloud in EMEA ENTR',
        'Show AEs not having MuleSoft in EMEA ENTR',
        'EMEA ENTR AEs without Sales Cloud deals',
        'AEs in EMEA ENTR excluding Marketing Cloud',
        'Find EMEA ENTR AEs who don\'t have Service Cloud',
        'Show AEs in EMEA ENTR without Platform deals',
        'EMEA ENTR AEs lacking Commerce Cloud'
    },
    
    // Batch 4: Country-Specific Negative Filters
    new List<String>{
        'List AEs in United States who don\'t have agentforce deals',
        'Show me AEs without Data Cloud in United Kingdom',
        'Find AEs excluding Slack in Canada',
        'AEs who lack Tableau Cloud in Germany',
        'Show AEs not having MuleSoft in France',
        'United States AEs without Sales Cloud deals',
        'AEs in United Kingdom excluding Marketing Cloud',
        'Find Canadian AEs who don\'t have Service Cloud',
        'Show AEs in Germany without Platform deals',
        'French AEs lacking Commerce Cloud'
    },
    
    // Batch 5: Positive Filters (AEs WITH products)
    new List<String>{
        'List AEs in UKI who have agentforce deals',
        'Show me AEs with Data Cloud in AMER ACC',
        'Find AEs including Slack in EMEA ENTR',
        'AEs who have Tableau Cloud in UKI',
        'Show AEs having MuleSoft in AMER ACC',
        'UKI AEs with Sales Cloud deals',
        'AEs in AMER ACC including Marketing Cloud',
        'Find EMEA ENTR AEs who have Service Cloud',
        'Show AEs in UKI with Platform deals',
        'AMER ACC AEs having Commerce Cloud'
    },
    
    // Batch 6: Mixed OU Positive Filters
    new List<String>{
        'List AEs in LATAM who have agentforce deals',
        'Show me AEs with Data Cloud in ANZ',
        'Find AEs including Slack in AMER SMB',
        'AEs who have Tableau Cloud in EMEA SMB',
        'Show AEs having MuleSoft in AMER ENTR',
        'LATAM AEs with Sales Cloud deals',
        'AEs in ANZ including Marketing Cloud',
        'Find AMER SMB AEs who have Service Cloud',
        'Show AEs in EMEA SMB with Platform deals',
        'AMER ENTR AEs having Commerce Cloud'
    },
    
    // Batch 7: Complex Negative Filters
    new List<String>{
        'List AEs in UKI who don\'t have agentforce or Data Cloud deals',
        'Show me AEs without Slack and Tableau in AMER ACC',
        'Find AEs excluding MuleSoft and Sales Cloud in EMEA ENTR',
        'AEs who lack Marketing Cloud and Service Cloud in UKI',
        'Show AEs not having Platform and Commerce Cloud in AMER ACC',
        'UKI AEs without agentforce, Data Cloud, or Slack deals',
        'AEs in AMER ACC excluding Tableau, MuleSoft, and Sales Cloud',
        'Find EMEA ENTR AEs who don\'t have Marketing, Service, or Platform',
        'Show AEs in UKI without Commerce, Field Service, or Health Cloud',
        'AMER ACC AEs lacking Financial Services, Manufacturing, or Government Cloud'
    },
    
    // Batch 8: Edge Cases and Variations
    new List<String>{
        'Show me AEs in UKI who don\'t have any deals',
        'Find AEs without products in AMER ACC',
        'List AEs in EMEA ENTR who lack opportunities',
        'AEs in UKI with no pipeline',
        'Show AEs in AMER ACC without open deals',
        'Find AEs in EMEA ENTR who don\'t have any products',
        'List AEs in UKI without any opportunities',
        'Show AEs in AMER ACC who lack any deals',
        'Find AEs in EMEA ENTR with no products',
        'List AEs in UKI who don\'t have any pipeline'
    },
    
    // Batch 9: Specific Product Variations
    new List<String>{
        'List AEs in UKI who don\'t have Field Service Cloud deals',
        'Show me AEs without Health Cloud in AMER ACC',
        'Find AEs excluding Financial Services Cloud in EMEA ENTR',
        'AEs who lack Manufacturing Cloud in UKI',
        'Show AEs not having Government Cloud in AMER ACC',
        'UKI AEs without Nonprofit Cloud deals',
        'AEs in AMER ACC excluding Education Cloud',
        'Find EMEA ENTR AEs who don\'t have Media Cloud',
        'Show AEs in UKI without Experience Cloud',
        'AMER ACC AEs lacking Commerce Cloud B2B'
    },
    
    // Batch 10: Performance and Limit Tests
    new List<String>{
        'List top 5 AEs in UKI who don\'t have agentforce deals',
        'Show me first 10 AEs without Data Cloud in AMER ACC',
        'Find top 3 AEs excluding Slack in EMEA ENTR',
        'AEs who lack Tableau Cloud in UKI - limit 15',
        'Show AEs not having MuleSoft in AMER ACC - max 20',
        'UKI AEs without Sales Cloud deals - top 25',
        'AEs in AMER ACC excluding Marketing Cloud - first 30',
        'Find EMEA ENTR AEs who don\'t have Service Cloud - limit 35',
        'Show AEs in UKI without Platform deals - max 40',
        'AMER ACC AEs lacking Commerce Cloud - top 50'
    }
};

// Execute tests
for (Integer batchNum = 0; batchNum < testBatches.size(); batchNum++) {
    List<String> batch = testBatches[batchNum];
    System.debug('\\n=== BATCH ' + (batchNum + 1) + ' ===');
    
    for (Integer i = 0; i < batch.size(); i++) {
        String query = batch[i];
        totalTests++;
        
        System.debug('\\n--- Test ' + totalTests + ': ' + query + ' ---');
        
        // Parse query to extract parameters
        String ouName = 'UKI'; // default
        String country = null;
        String product = 'agentforce'; // default
        Boolean isNegative = true; // default
        
        // Extract OU
        if (query.contains('UKI')) ouName = 'UKI';
        else if (query.contains('AMER ACC')) ouName = 'AMER ACC';
        else if (query.contains('EMEA ENTR')) ouName = 'EMEA ENTR';
        else if (query.contains('LATAM')) ouName = 'LATAM';
        else if (query.contains('ANZ')) ouName = 'ANZ';
        else if (query.contains('AMER SMB')) ouName = 'AMER SMB';
        else if (query.contains('EMEA SMB')) ouName = 'EMEA SMB';
        else if (query.contains('AMER ENTR')) ouName = 'AMER ENTR';
        
        // Extract country
        if (query.contains('United States')) country = 'United States';
        else if (query.contains('United Kingdom')) country = 'United Kingdom';
        else if (query.contains('Canada')) country = 'Canada';
        else if (query.contains('Germany')) country = 'Germany';
        else if (query.contains('France')) country = 'France';
        
        // Extract product
        if (query.contains('agentforce')) product = 'agentforce';
        else if (query.contains('Data Cloud')) product = 'Data Cloud';
        else if (query.contains('Slack')) product = 'Slack';
        else if (query.contains('Tableau')) product = 'Tableau Cloud';
        else if (query.contains('MuleSoft')) product = 'MuleSoft';
        else if (query.contains('Sales Cloud')) product = 'Sales Cloud';
        else if (query.contains('Marketing Cloud')) product = 'Marketing Cloud';
        else if (query.contains('Service Cloud')) product = 'Service Cloud';
        else if (query.contains('Platform')) product = 'Platform';
        else if (query.contains('Commerce Cloud')) product = 'Commerce Cloud';
        else if (query.contains('Field Service')) product = 'Field Service Cloud';
        else if (query.contains('Health Cloud')) product = 'Health Cloud';
        else if (query.contains('Financial Services')) product = 'Financial Services Cloud';
        else if (query.contains('Manufacturing')) product = 'Manufacturing Cloud';
        else if (query.contains('Government')) product = 'Government Cloud';
        else if (query.contains('Nonprofit')) product = 'Nonprofit Cloud';
        else if (query.contains('Education')) product = 'Education Cloud';
        else if (query.contains('Media')) product = 'Media Cloud';
        else if (query.contains('Experience')) product = 'Experience Cloud';
        
        // Determine if negative or positive
        isNegative = query.contains('don\'t have') || query.contains('without') || 
                    query.contains('excluding') || query.contains('lack') || 
                    query.contains('not having') || query.contains('no ') ||
                    query.contains('any deals') || query.contains('any products') ||
                    query.contains('any opportunities') || query.contains('any pipeline');
        
        // Test MCP adapter
        Map<String, Object> mcpResult = testMCPAdapter(query, ouName, country, product, isNegative);
        
        // Verify with SOQL
        Map<String, Object> soqlResult = verifyWithSOQL(ouName, country, product, isNegative);
        
        // Analyze results
        if (mcpResult.get('success') == true && soqlResult.get('success') == true) {
            Integer expectedCount = (Integer)soqlResult.get('expectedCount');
            Integer reportedCount = (Integer)mcpResult.get('reportedCount');
            
            if (reportedCount != null) {
                if (reportedCount == expectedCount) {
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
            String error = 'MCP Error: ' + mcpResult.get('error') + ' | SOQL Error: ' + soqlResult.get('error');
            failedResults.add('Test ' + totalTests + ': ' + error);
            System.debug('❌ FAIL: ' + error);
        }
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
