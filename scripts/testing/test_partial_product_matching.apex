/**
 * Test script for partial product matching functionality
 * Tests both positive and negative product filtering with LIKE operators
 */
System.debug('=== Testing Partial Product Matching Functionality ===');

// Test 1: Positive product filtering with partial matching
System.debug('\n--- Test 1: Positive Product Filtering (Include Tableau) ---');
try {
    ANAgentOpenPipeAnalysisV3Handler.Request req1 = new ANAgentOpenPipeAnalysisV3Handler.Request();
    req1.ouName = 'UKI';
    req1.includeProductListCsv = 'Tableau';
    req1.groupBy = 'AE';
    req1.limitN = 5;
    
    List<ANAgentOpenPipeAnalysisV3Handler.Response> responses1 = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req1});
    
    if (!responses1.isEmpty()) {
        System.debug('✅ Positive filtering response received');
        System.debug('Response length: ' + responses1[0].message.length());
        System.debug('First 500 chars: ' + responses1[0].message.substring(0, Math.min(500, responses1[0].message.length())));
    } else {
        System.debug('❌ No response received for positive filtering');
    }
} catch (Exception e) {
    System.debug('❌ Error in positive filtering test: ' + e.getMessage());
}

// Test 2: Negative product filtering with partial matching
System.debug('\n--- Test 2: Negative Product Filtering (Exclude Agentforce) ---');
try {
    ANAgentOpenPipeAnalysisV3Handler.Request req2 = new ANAgentOpenPipeAnalysisV3Handler.Request();
    req2.ouName = 'UKI';
    req2.excludeProductListCsv = 'Agentforce';
    req2.groupBy = 'AE';
    req2.limitN = 5;
    
    List<ANAgentOpenPipeAnalysisV3Handler.Response> responses2 = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisV3Handler.Request>{req2});
    
    if (!responses2.isEmpty()) {
        System.debug('✅ Negative filtering response received');
        System.debug('Response length: ' + responses2[0].message.length());
        System.debug('First 500 chars: ' + responses2[0].message.substring(0, Math.min(500, responses2[0].message.length())));
    } else {
        System.debug('❌ No response received for negative filtering');
    }
} catch (Exception e) {
    System.debug('❌ Error in negative filtering test: ' + e.getMessage());
}

// Test 3: MCP Adapter test with includeProducts
System.debug('\n--- Test 3: MCP Adapter with Include Products ---');
try {
    Map<String, Object> mcpArgs = new Map<String, Object>();
    mcpArgs.put('ouName', 'UKI');
    mcpArgs.put('includeProducts', 'Tableau');
    mcpArgs.put('groupBy', 'AE');
    mcpArgs.put('limit', '3');
    
    String argsJson = JSON.serialize(mcpArgs);
    List<AN_OpenPipeV3_FromMCP.Result> mcpResults = AN_OpenPipeV3_FromMCP.run(new List<String>{argsJson});
    
    if (!mcpResults.isEmpty() && mcpResults[0].success) {
        System.debug('✅ MCP adapter with includeProducts successful');
        System.debug('Response length: ' + mcpResults[0].message.length());
        System.debug('First 500 chars: ' + mcpResults[0].message.substring(0, Math.min(500, mcpResults[0].message.length())));
    } else {
        System.debug('❌ MCP adapter with includeProducts failed');
        if (!mcpResults.isEmpty()) {
            System.debug('Error: ' + mcpResults[0].message);
        }
    }
} catch (Exception e) {
    System.debug('❌ Error in MCP adapter test: ' + e.getMessage());
}

// Test 4: MCP Adapter test with excludeProducts
System.debug('\n--- Test 4: MCP Adapter with Exclude Products ---');
try {
    Map<String, Object> mcpArgs2 = new Map<String, Object>();
    mcpArgs2.put('ouName', 'UKI');
    mcpArgs2.put('excludeProducts', 'Agentforce');
    mcpArgs2.put('groupBy', 'AE');
    mcpArgs2.put('limit', '3');
    
    String argsJson2 = JSON.serialize(mcpArgs2);
    List<AN_OpenPipeV3_FromMCP.Result> mcpResults2 = AN_OpenPipeV3_FromMCP.run(new List<String>{argsJson2});
    
    if (!mcpResults2.isEmpty() && mcpResults2[0].success) {
        System.debug('✅ MCP adapter with excludeProducts successful');
        System.debug('Response length: ' + mcpResults2[0].message.length());
        System.debug('First 500 chars: ' + mcpResults2[0].message.substring(0, Math.min(500, mcpResults2[0].message.length())));
    } else {
        System.debug('❌ MCP adapter with excludeProducts failed');
        if (!mcpResults2.isEmpty()) {
            System.debug('Error: ' + mcpResults2[0].message);
        }
    }
} catch (Exception e) {
    System.debug('❌ Error in MCP adapter test: ' + e.getMessage());
}

// Test 5: Verify SOQL queries use LIKE operators
System.debug('\n--- Test 5: Verify SOQL Query Generation ---');
try {
    // Test the service method directly to see the generated query
    String testQuery = ANAgentOpenPipeAnalysisV3Service.buildPositiveQuery('UKI', null, new List<String>{'Tableau'}, null);
    System.debug('Generated positive query: ' + testQuery);
    
    if (testQuery.contains('LIKE')) {
        System.debug('✅ Query contains LIKE operator for partial matching');
    } else {
        System.debug('❌ Query does not contain LIKE operator');
    }
    
    String testQuery2 = ANAgentOpenPipeAnalysisV3Service.buildNegativeQuery('UKI', null, new List<String>{'Agentforce'}, null);
    System.debug('Generated negative query: ' + testQuery2);
    
    if (testQuery2.contains('NOT') && testQuery2.contains('LIKE')) {
        System.debug('✅ Negative query contains NOT LIKE operator for partial matching');
    } else {
        System.debug('❌ Negative query does not contain NOT LIKE operator');
    }
    
} catch (Exception e) {
    System.debug('❌ Error in SOQL query verification: ' + e.getMessage());
}

System.debug('\n=== Partial Product Matching Test Complete ===');
