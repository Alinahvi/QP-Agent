// Test script to verify negative intent routing and MCP adapter integration
System.debug('=== Testing Negative Intent Routing ===');

// Test 1: Test MCP Adapter directly with negative intent
System.debug('\\n--- Test 1: MCP Adapter Direct Test ---');
String testArgsJson = JSON.serialize(new Map<String, Object>{
    'ouName' => 'UKI',
    'excludeProducts' => 'Agentforce',
    'negativeIntent' => true,
    'limit' => '10',
    'correlationId' => 'test-negative-001'
});

try {
    List<AN_OpenPipeV3_FromMCP.Result> results = AN_OpenPipeV3_FromMCP.run(new List<String>{testArgsJson});
    
    if (!results.isEmpty()) {
        AN_OpenPipeV3_FromMCP.Result result = results[0];
        System.debug('✅ MCP Adapter Test: SUCCESS');
        System.debug('Success: ' + result.success);
        System.debug('Message Length: ' + (result.message != null ? result.message.length() : 0));
        System.debug('Contains "Negative Filter": ' + (result.message != null && result.message.contains('Negative Filter')));
        System.debug('Contains "AEs": ' + (result.message != null && result.message.contains('AEs')));
        System.debug('Contains "UKI": ' + (result.message != null && result.message.contains('UKI')));
        System.debug('Contains "Agentforce": ' + (result.message != null && result.message.contains('Agentforce')));
    } else {
        System.debug('❌ MCP Adapter Test: FAILED - No results');
    }
} catch (Exception e) {
    System.debug('❌ MCP Adapter Test: ERROR - ' + e.getMessage());
}

// Test 2: Test different negative intent patterns
System.debug('\\n--- Test 2: Different Negative Intent Patterns ---');

List<String> testQueries = new List<String>{
    'List AEs in UKI who don\'t have agentforce deals',
    'Show me AEs without Data Cloud in AMER ACC',
    'Find AEs excluding Slack in UKI',
    'AEs who lack Tableau Cloud in AMER ENTR',
    'Show AEs not having MuleSoft in AMER SMB'
};

for (String query : testQueries) {
    System.debug('\\nTesting query: ' + query);
    
    // Simulate MCP server routing
    String testArgs = JSON.serialize(new Map<String, Object>{
        'ouName' => query.contains('UKI') ? 'UKI' : (query.contains('AMER') ? 'AMER ACC' : 'UKI'),
        'excludeProducts' => query.contains('agentforce') ? 'Agentforce' : 
                           (query.contains('Data Cloud') ? 'Data Cloud' : 
                           (query.contains('Slack') ? 'Slack' : 
                           (query.contains('Tableau') ? 'Tableau Cloud' : 'MuleSoft'))),
        'negativeIntent' => true,
        'limit' => '10',
        'correlationId' => 'test-pattern-' + Math.random().intValue()
    });
    
    try {
        List<AN_OpenPipeV3_FromMCP.Result> patternResults = AN_OpenPipeV3_FromMCP.run(new List<String>{testArgs});
        
        if (!patternResults.isEmpty()) {
            AN_OpenPipeV3_FromMCP.Result patternResult = patternResults[0];
            System.debug('✅ Pattern Test: SUCCESS');
            System.debug('Success: ' + patternResult.success);
            System.debug('Message Length: ' + (patternResult.message != null ? patternResult.message.length() : 0));
        } else {
            System.debug('❌ Pattern Test: FAILED - No results');
        }
    } catch (Exception e) {
        System.debug('❌ Pattern Test: ERROR - ' + e.getMessage());
    }
}

// Test 3: Test agent action directly (simulating what the agent should do)
System.debug('\\n--- Test 3: Agent Action Simulation ---');

try {
    // Simulate the agent calling the handler directly with negative intent
    ANAgentOpenPipeAnalysisV3Handler.Request handlerRequest = new ANAgentOpenPipeAnalysisV3Handler.Request();
    handlerRequest.ouName = 'UKI';
    handlerRequest.excludeProductListCsv = 'Agentforce';
    handlerRequest.negativeIntent = true;
    handlerRequest.limitN = 10;
    handlerRequest.groupBy = 'AE';
    handlerRequest.analysisType = 'AE_SCORE_ANALYSIS';
    handlerRequest.aggregationType = 'COUNT';
    handlerRequest.perAENormalize = true;
    
    List<ANAgentOpenPipeAnalysisV3Handler.Request> requests = new List<ANAgentOpenPipeAnalysisV3Handler.Request>{handlerRequest};
    List<ANAgentOpenPipeAnalysisV3Handler.Response> responses = ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(requests);
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisV3Handler.Response response = responses[0];
        System.debug('✅ Agent Action Test: SUCCESS');
        System.debug('Message Length: ' + (response.message != null ? response.message.length() : 0));
        System.debug('Contains "Negative Filter": ' + (response.message != null && response.message.contains('Negative Filter')));
        System.debug('Contains "AEs": ' + (response.message != null && response.message.contains('AEs')));
        System.debug('Contains "UKI": ' + (response.message != null && response.message.contains('UKI')));
        System.debug('Contains "Agentforce": ' + (response.message != null && response.message.contains('Agentforce')));
    } else {
        System.debug('❌ Agent Action Test: FAILED - No results');
    }
} catch (Exception e) {
    System.debug('❌ Agent Action Test: ERROR - ' + e.getMessage());
}

System.debug('\\n=== Test Complete ===');
System.debug('\\n🎯 SUMMARY:');
System.debug('1. MCP Adapter: Tested negative intent routing');
System.debug('2. Pattern Matching: Tested different negative intent phrases');
System.debug('3. Agent Action: Tested direct handler call with negative intent');
System.debug('\\n✅ All tests completed. Check results above for success/failure status.');
