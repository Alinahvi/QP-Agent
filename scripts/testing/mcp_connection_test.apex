// Test script to verify MCP connection for ANAgentOpenPipeAnalysisV3Handler
// This script tests the MCP adapter and provides sample utterances

System.debug('=== MCP Connection Test for Open Pipe Analysis V3 ===');

// Test 1: Basic MCP Adapter Test
System.debug('\n--- Test 1: Basic MCP Adapter Test ---');
try {
    String testArgsJson = JSON.serialize(new Map<String, Object>{
        'ouName' => 'UKI',
        'product' => 'Agentforce',
        'limit' => '10',
        'correlationId' => 'test-001'
    });
    
    List<AN_OpenPipeV3_FromMCP.Result> results = AN_OpenPipeV3_FromMCP.run(new List<String>{testArgsJson});
    
    if (!results.isEmpty()) {
        AN_OpenPipeV3_FromMCP.Result result = results[0];
        System.debug('Success: ' + result.success);
        System.debug('Message Length: ' + (result.message != null ? result.message.length() : 0));
        System.debug('Execution Time: ' + result.executionTimeMs + 'ms');
        System.debug('Correlation ID: ' + result.correlationId);
        
        if (result.success) {
            System.debug('✅ MCP Adapter Test: PASSED');
        } else {
            System.debug('❌ MCP Adapter Test: FAILED - ' + result.message);
        }
    } else {
        System.debug('❌ MCP Adapter Test: FAILED - No results returned');
    }
} catch (Exception e) {
    System.debug('❌ MCP Adapter Test: ERROR - ' + e.getMessage());
}

// Test 2: Negative Filter Test
System.debug('\n--- Test 2: Negative Filter Test ---');
try {
    String negativeArgsJson = JSON.serialize(new Map<String, Object>{
        'ouName' => 'UKI',
        'excludeProducts' => 'Agentforce',
        'negativeIntent' => true,
        'limit' => '5',
        'correlationId' => 'test-002'
    });
    
    List<AN_OpenPipeV3_FromMCP.Result> results = AN_OpenPipeV3_FromMCP.run(new List<String>{negativeArgsJson});
    
    if (!results.isEmpty()) {
        AN_OpenPipeV3_FromMCP.Result result = results[0];
        System.debug('Success: ' + result.success);
        System.debug('Message Length: ' + (result.message != null ? result.message.length() : 0));
        System.debug('Contains "Negative Filter": ' + (result.message != null && result.message.contains('Negative Filter')));
        
        if (result.success && result.message != null && result.message.contains('Negative Filter')) {
            System.debug('✅ Negative Filter Test: PASSED');
        } else {
            System.debug('❌ Negative Filter Test: FAILED - ' + result.message);
        }
    } else {
        System.debug('❌ Negative Filter Test: FAILED - No results returned');
    }
} catch (Exception e) {
    System.debug('❌ Negative Filter Test: ERROR - ' + e.getMessage());
}

// Test 3: Multi-OU Test
System.debug('\n--- Test 3: Multi-OU Test ---');
try {
    String multiOuArgsJson = JSON.serialize(new Map<String, Object>{
        'ouName' => 'AMER SMB',
        'country' => 'United States',
        'stage' => 'Prospecting',
        'limit' => '3',
        'correlationId' => 'test-003'
    });
    
    List<AN_OpenPipeV3_FromMCP.Result> results = AN_OpenPipeV3_FromMCP.run(new List<String>{multiOuArgsJson});
    
    if (!results.isEmpty()) {
        AN_OpenPipeV3_FromMCP.Result result = results[0];
        System.debug('Success: ' + result.success);
        System.debug('Message Length: ' + (result.message != null ? result.message.length() : 0));
        System.debug('Contains "AMER SMB": ' + (result.message != null && result.message.contains('AMER SMB')));
        
        if (result.success) {
            System.debug('✅ Multi-OU Test: PASSED');
        } else {
            System.debug('❌ Multi-OU Test: FAILED - ' + result.message);
        }
    } else {
        System.debug('❌ Multi-OU Test: FAILED - No results returned');
    }
} catch (Exception e) {
    System.debug('❌ Multi-OU Test: ERROR - ' + e.getMessage());
}

System.debug('\n=== MCP Connection Test Complete ===');
System.debug('\n=== 5 Test Utterances for Your Agent ===');
System.debug('1. "Show me AEs who don\'t have Agentforce deals in their open pipe in UKI"');
System.debug('2. "Find AEs in AMER SMB without Data Cloud opportunities, limit to 20"');
System.debug('3. "Show me open pipe analysis for EMEA SMB AEs in Prospecting stage"');
System.debug('4. "List AEs in PubSec+ who don\'t have Slack deals, top 15"');
System.debug('5. "Analyze open pipeline for South Asia AEs excluding MuleSoft products"');

System.debug('\n=== Expected MCP Parameters ===');
System.debug('For utterance 1: ouName=UKI, excludeProducts=Agentforce, negativeIntent=true');
System.debug('For utterance 2: ouName=AMER SMB, excludeProducts=Data Cloud, negativeIntent=true, limit=20');
System.debug('For utterance 3: ouName=EMEA SMB, stage=Prospecting');
System.debug('For utterance 4: ouName=PubSec+.Org, excludeProducts=Slack, negativeIntent=true, limit=15');
System.debug('For utterance 5: ouName=South Asia - India, excludeProducts=MuleSoft, negativeIntent=true');
