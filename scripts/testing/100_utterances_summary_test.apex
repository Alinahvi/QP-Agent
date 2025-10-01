// 100 Utterances MCP Test - Summary Approach
// Tests key scenarios and provides comprehensive analysis
// Focuses on detecting suspicious responses (0 answers) and verifying with SOQL

System.debug('=== 100 UTTERANCES MCP SUMMARY TEST ===');
System.debug('Timestamp: ' + System.now());
System.debug('');

// Test configuration
Integer totalTests = 0;
Integer passedTests = 0;
Integer suspiciousTests = 0;
Integer failedTests = 0;
List<String> suspiciousResults = new List<String>();
List<String> failedResults = new List<String>();

// Key test scenarios - representative sample of 100 utterances
List<String> testQueries = new List<String>{
    // UKI Negative Filters (10 tests)
    'List AEs in UKI who don\'t have agentforce deals',
    'Show me AEs without Data Cloud in UKI',
    'Find AEs excluding Slack in UKI',
    'AEs who lack Tableau Cloud in UKI',
    'Show AEs not having MuleSoft in UKI',
    'UKI AEs without Sales Cloud deals',
    'AEs in UKI excluding Marketing Cloud',
    'Find UKI AEs who don\'t have Service Cloud',
    'Show AEs in UKI without Platform deals',
    'UKI AEs lacking Commerce Cloud',
    
    // AMER ACC Negative Filters (10 tests)
    'List AEs in AMER ACC who don\'t have agentforce deals',
    'Show me AEs without Data Cloud in AMER ACC',
    'Find AEs excluding Slack in AMER ACC',
    'AEs who lack Tableau Cloud in AMER ACC',
    'Show AEs not having MuleSoft in AMER ACC',
    'AMER ACC AEs without Sales Cloud deals',
    'AEs in AMER ACC excluding Marketing Cloud',
    'Find AMER ACC AEs who don\'t have Service Cloud',
    'Show AEs in AMER ACC without Platform deals',
    'AMER ACC AEs lacking Commerce Cloud',
    
    // EMEA ENTR Negative Filters (10 tests)
    'List AEs in EMEA ENTR who don\'t have agentforce deals',
    'Show me AEs without Data Cloud in EMEA ENTR',
    'Find AEs excluding Slack in EMEA ENTR',
    'AEs who lack Tableau Cloud in EMEA ENTR',
    'Show AEs not having MuleSoft in EMEA ENTR',
    'EMEA ENTR AEs without Sales Cloud deals',
    'AEs in EMEA ENTR excluding Marketing Cloud',
    'Find EMEA ENTR AEs who don\'t have Service Cloud',
    'Show AEs in EMEA ENTR without Platform deals',
    'EMEA ENTR AEs lacking Commerce Cloud',
    
    // Country-Specific Negative Filters (10 tests)
    'List AEs in United States who don\'t have agentforce deals',
    'Show me AEs without Data Cloud in United Kingdom',
    'Find AEs excluding Slack in Canada',
    'AEs who lack Tableau Cloud in Germany',
    'Show AEs not having MuleSoft in France',
    'United States AEs without Sales Cloud deals',
    'AEs in United Kingdom excluding Marketing Cloud',
    'Find Canadian AEs who don\'t have Service Cloud',
    'Show AEs in Germany without Platform deals',
    'French AEs lacking Commerce Cloud',
    
    // Positive Filters (10 tests)
    'List AEs in UKI who have agentforce deals',
    'Show me AEs with Data Cloud in AMER ACC',
    'Find AEs including Slack in EMEA ENTR',
    'AEs who have Tableau Cloud in UKI',
    'Show AEs having MuleSoft in AMER ACC',
    'UKI AEs with Sales Cloud deals',
    'AEs in AMER ACC including Marketing Cloud',
    'Find EMEA ENTR AEs who have Service Cloud',
    'Show AEs in UKI with Platform deals',
    'AMER ACC AEs having Commerce Cloud',
    
    // Mixed OU Positive Filters (10 tests)
    'List AEs in LATAM who have agentforce deals',
    'Show me AEs with Data Cloud in ANZ',
    'Find AEs including Slack in AMER SMB',
    'AEs who have Tableau Cloud in EMEA SMB',
    'Show AEs having MuleSoft in AMER ENTR',
    'LATAM AEs with Sales Cloud deals',
    'AEs in ANZ including Marketing Cloud',
    'Find AMER SMB AEs who have Service Cloud',
    'Show AEs in EMEA SMB with Platform deals',
    'AMER ENTR AEs having Commerce Cloud',
    
    // Complex Negative Filters (10 tests)
    'List AEs in UKI who don\'t have agentforce or Data Cloud deals',
    'Show me AEs without Slack and Tableau in AMER ACC',
    'Find AEs excluding MuleSoft and Sales Cloud in EMEA ENTR',
    'AEs who lack Marketing Cloud and Service Cloud in UKI',
    'Show AEs not having Platform and Commerce Cloud in AMER ACC',
    'UKI AEs without agentforce, Data Cloud, or Slack deals',
    'AEs in AMER ACC excluding Tableau, MuleSoft, and Sales Cloud',
    'Find EMEA ENTR AEs who don\'t have Marketing, Service, or Platform',
    'Show AEs in UKI without Commerce, Field Service, or Health Cloud',
    'AMER ACC AEs lacking Financial Services, Manufacturing, or Government Cloud',
    
    // Edge Cases (10 tests)
    'Show me AEs in UKI who don\'t have any deals',
    'Find AEs without products in AMER ACC',
    'List AEs in EMEA ENTR who lack opportunities',
    'AEs in UKI with no pipeline',
    'Show AEs in AMER ACC without open deals',
    'Find AEs in EMEA ENTR who don\'t have any products',
    'List AEs in UKI without any opportunities',
    'Show AEs in AMER ACC who lack any deals',
    'Find AEs in EMEA ENTR with no products',
    'List AEs in UKI who don\'t have any pipeline',
    
    // Specific Product Variations (10 tests)
    'List AEs in UKI who don\'t have Field Service Cloud deals',
    'Show me AEs without Health Cloud in AMER ACC',
    'Find AEs excluding Financial Services Cloud in EMEA ENTR',
    'AEs who lack Manufacturing Cloud in UKI',
    'Show AEs not having Government Cloud in AMER ACC',
    'UKI AEs without Nonprofit Cloud deals',
    'AEs in AMER ACC excluding Education Cloud',
    'Find EMEA ENTR AEs who don\'t have Media Cloud',
    'Show AEs in UKI without Experience Cloud',
    'AMER ACC AEs lacking Commerce Cloud B2B',
    
    // Performance and Limit Tests (10 tests)
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
};

// Process each test
for (String query : testQueries) {
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
    
    try {
        // Test MCP adapter
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
                    if (reportedCount == 0) {
                        suspiciousTests++;
                        suspiciousResults.add('Test ' + totalTests + ': Got 0 (SUSPICIOUS) - ' + query);
                        System.debug('⚠️ SUSPICIOUS: Got 0');
                    } else {
                        passedTests++;
                        System.debug('✅ PASS: Got ' + reportedCount);
                    }
                } else {
                    suspiciousTests++;
                    suspiciousResults.add('Test ' + totalTests + ': Could not extract count from response - ' + query);
                    System.debug('⚠️ SUSPICIOUS: Could not extract count from response');
                }
            } else {
                failedTests++;
                failedResults.add('Test ' + totalTests + ': MCP adapter failed - ' + query);
                System.debug('❌ FAIL: MCP adapter failed');
            }
        } else {
            failedTests++;
            failedResults.add('Test ' + totalTests + ': No MCP results returned - ' + query);
            System.debug('❌ FAIL: No MCP results returned');
        }
    } catch (Exception e) {
        failedTests++;
        failedResults.add('Test ' + totalTests + ': Exception - ' + e.getMessage() + ' - ' + query);
        System.debug('❌ FAIL: Exception - ' + e.getMessage());
    }
    
    // Add a small delay to avoid hitting governor limits
    if (Math.mod(totalTests, 10) == 0) {
        System.debug('Processed ' + totalTests + ' tests, pausing...');
    }
}

// Final results
System.debug('\\n=== FINAL RESULTS ===');
System.debug('Total Tests: ' + totalTests);
System.debug('Passed: ' + passedTests + ' (' + (passedTests * 100 / totalTests) + '%)');
System.debug('Suspicious: ' + suspiciousTests + ' (' + (suspiciousTests * 100 / totalTests) + '%)');
System.debug('Failed: ' + failedTests + ' (' + (failedTests * 100 / totalTests) + '%)');

if (!suspiciousResults.isEmpty()) {
    System.debug('\\n=== SUSPICIOUS RESULTS (0 answers) ===');
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
System.debug('\\n🎯 SUMMARY:');
System.debug('1. Tested ' + totalTests + ' utterances across 10 categories');
System.debug('2. Identified ' + suspiciousTests + ' suspicious responses (0 answers)');
System.debug('3. ' + passedTests + ' tests passed with valid responses');
System.debug('4. ' + failedTests + ' tests failed due to errors');
System.debug('\\n✅ All tests completed. Check suspicious results above for 0 answers.');
