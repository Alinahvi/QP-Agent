// Basic test for Open Pipe V3 functionality
System.debug('🧪 Testing Open Pipe V3 Basic Functionality...');

try {
    // Test 1: Direct handler call
    System.debug('📋 Test 1: Direct Handler Call');
    ANAgentOpenPipeAnalysisV3Handler.Request directRequest = new ANAgentOpenPipeAnalysisV3Handler.Request();
    directRequest.ouName = 'AMER ACC';
    directRequest.groupBy = 'STAGE';
    directRequest.analysisType = 'STAGE_COUNT';
    directRequest.limitN = 10;
    
    List<ANAgentOpenPipeAnalysisV3Handler.Response> directResponses = 
        ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(
            new List<ANAgentOpenPipeAnalysisV3Handler.Request>{directRequest}
        );
    
    if (!directResponses.isEmpty()) {
        System.debug('✅ Direct Handler Success: ' + directResponses[0].message);
    } else {
        System.debug('❌ Direct Handler Failed: No response');
    }
    
    // Test 2: MCP adapter call
    System.debug('📋 Test 2: MCP Adapter Call');
    Map<String, Object> mcpArgs = new Map<String, Object>();
    mcpArgs.put('ouName', 'AMER ACC');
    mcpArgs.put('minStage', '4');
    mcpArgs.put('timeFrame', 'CURRENT');
    mcpArgs.put('limitN', 10);
    mcpArgs.put('correlationId', 'TEST_' + System.currentTimeMillis());
    
    String mcpArgsJson = JSON.serialize(mcpArgs);
    
    List<AN_OpenPipeV3_FromMCP_Simple.Result> mcpResults = 
        AN_OpenPipeV3_FromMCP_Simple.run(new List<String>{mcpArgsJson});
    
    if (!mcpResults.isEmpty()) {
        AN_OpenPipeV3_FromMCP_Simple.Result mcpResult = mcpResults[0];
        System.debug('✅ MCP Adapter Success: ' + mcpResult.success);
        System.debug('✅ MCP Message: ' + mcpResult.message);
    } else {
        System.debug('❌ MCP Adapter Failed: No response');
    }
    
    // Test 3: Compare results
    System.debug('📋 Test 3: Result Comparison');
    if (!directResponses.isEmpty() && !mcpResults.isEmpty()) {
        String directMessage = directResponses[0].message;
        String mcpMessage = mcpResults[0].message;
        
        Boolean messagesSimilar = directMessage.contains('Open Pipe') && mcpMessage.contains('Open Pipe');
        System.debug('✅ Messages Similar: ' + messagesSimilar);
        
        if (messagesSimilar) {
            System.debug('🎉 SUCCESS: Both paths produce similar results');
        } else {
            System.debug('⚠️  WARNING: Results may differ between paths');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Test Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('🎯 Basic Open Pipe V3 Test Complete');
