// Test script to verify MCP adapter handles negative filters correctly
// This simulates the exact query from the agent interface

System.debug('=== Testing MCP Adapter for Negative Filters ===');

// Test the exact scenario from the agent interface
String testArgsJson = JSON.serialize(new Map<String, Object>{
    'ouName' => 'UKI',
    'excludeProducts' => 'Agentforce',
    'negativeIntent' => true,
    'limit' => '10',
    'correlationId' => 'agent-test-001'
});

System.debug('MCP Args JSON: ' + testArgsJson);

try {
    List<AN_OpenPipeV3_FromMCP.Result> results = AN_OpenPipeV3_FromMCP.run(new List<String>{testArgsJson});
    
    if (!results.isEmpty()) {
        AN_OpenPipeV3_FromMCP.Result result = results[0];
        
        System.debug('=== MCP Adapter Results ===');
        System.debug('Success: ' + result.success);
        System.debug('Message Length: ' + (result.message != null ? result.message.length() : 0));
        System.debug('Execution Time: ' + result.executionTimeMs + 'ms');
        System.debug('Correlation ID: ' + result.correlationId);
        
        if (result.success && result.message != null) {
            System.debug('=== Message Content ===');
            System.debug(result.message);
            
            // Check for key indicators
            Boolean hasNegativeFilter = result.message.contains('Negative Filter');
            Boolean hasAECount = result.message.contains('AEs');
            Boolean hasUKI = result.message.contains('UKI');
            Boolean hasAgentforce = result.message.contains('Agentforce');
            
            System.debug('=== Content Analysis ===');
            System.debug('Contains "Negative Filter": ' + hasNegativeFilter);
            System.debug('Contains "AEs": ' + hasAECount);
            System.debug('Contains "UKI": ' + hasUKI);
            System.debug('Contains "Agentforce": ' + hasAgentforce);
            
            if (hasNegativeFilter && hasAECount && hasUKI) {
                System.debug('✅ MCP Adapter Test: PASSED - Proper negative filter response');
            } else {
                System.debug('❌ MCP Adapter Test: FAILED - Missing expected content');
            }
        } else {
            System.debug('❌ MCP Adapter Test: FAILED - No message or unsuccessful');
        }
    } else {
        System.debug('❌ MCP Adapter Test: FAILED - No results returned');
    }
} catch (Exception e) {
    System.debug('❌ MCP Adapter Test: ERROR - ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

System.debug('=== Test Complete ===');
