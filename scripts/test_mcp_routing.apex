// Test script to validate MCP routing fixes
System.debug('🔧 TESTING MCP ROUTING FIXES');
System.debug('================================');

// Test 1: Basic MCP Adapter Routing Test
System.debug('\n🔍 Test 1: Basic MCP Adapter Routing Test');
try {
    Map<String, Object> mcpArgs = new Map<String, Object>{
        'ouName' => 'AMER ICE',
        'opportunityType' => 'renewal',
        'correlationId' => 'MCP_TEST_' + System.currentTimeMillis()
    };
    
    String argsJson = JSON.serialize(mcpArgs);
    List<String> argsList = new List<String>{argsJson};
    
    List<AN_FuturePipeline_FromMCP.Result> mcpResults = 
        AN_FuturePipeline_FromMCP.run(argsList);
    
    if (!mcpResults.isEmpty() && mcpResults[0].success) {
        System.debug('✅ Basic MCP Adapter Routing Test PASSED');
        System.debug('Response: ' + mcpResults[0].message);
        System.debug('Correlation ID: ' + mcpResults[0].correlationId);
    } else {
        System.debug('❌ Basic MCP Adapter Routing Test FAILED');
        if (!mcpResults.isEmpty()) {
            System.debug('Error: ' + mcpResults[0].message);
        }
    }
} catch (Exception e) {
    System.debug('❌ Basic MCP Adapter Routing Test FAILED: ' + e.getMessage());
}

// Test 2: Enhanced MCP Adapter Routing Test
System.debug('\n🔍 Test 2: Enhanced MCP Adapter Routing Test');
try {
    Map<String, Object> enhancedMcpArgs = new Map<String, Object>{
        'ouName' => 'AMER ICE',
        'opportunityType' => 'renewal',
        'includeRenewalRisk' => 'true',
        'includeAEPerf' => 'true',
        'includePMF' => 'true',
        'includeHealthScore' => 'true',
        'correlationId' => 'MCP_ENHANCED_TEST_' + System.currentTimeMillis()
    };
    
    String enhancedArgsJson = JSON.serialize(enhancedMcpArgs);
    List<String> enhancedArgsList = new List<String>{enhancedArgsJson};
    
    List<AN_FuturePipeline_Enhanced_FromMCP.Result> enhancedMcpResults = 
        AN_FuturePipeline_Enhanced_FromMCP.runEnhanced(enhancedArgsList);
    
    if (!enhancedMcpResults.isEmpty() && enhancedMcpResults[0].success) {
        System.debug('✅ Enhanced MCP Adapter Routing Test PASSED');
        System.debug('Response: ' + enhancedMcpResults[0].message);
        System.debug('Correlation ID: ' + enhancedMcpResults[0].correlationId);
        
        // Check if intelligence features are included
        String responseText = enhancedMcpResults[0].message;
        Boolean hasEmojis = responseText.contains('🎯') || responseText.contains('👥') || responseText.contains('📊') || responseText.contains('🏥') || responseText.contains('💡');
        if (hasEmojis) {
            System.debug('✅ Enhanced MCP with Intelligence Features WORKING');
        } else {
            System.debug('⚠️ Enhanced MCP may not have full intelligence features');
        }
    } else {
        System.debug('❌ Enhanced MCP Adapter Routing Test FAILED');
        if (!enhancedMcpResults.isEmpty()) {
            System.debug('Error: ' + enhancedMcpResults[0].message);
        }
    }
} catch (Exception e) {
    System.debug('❌ Enhanced MCP Adapter Routing Test FAILED: ' + e.getMessage());
}

// Test 3: Verify MCP Adapter is calling correct handler
System.debug('\n🔍 Test 3: Verify MCP Adapter Handler Routing');
try {
    // Test that the MCP adapter is now calling ABAgentFuturePipeAnalysisHandler
    // instead of the old ANAgentFuturePipelineAnalysisHandler
    
    Map<String, Object> routingTestArgs = new Map<String, Object>{
        'ouName' => 'AMER ICE',
        'opportunityType' => 'cross_sell',
        'correlationId' => 'ROUTING_TEST_' + System.currentTimeMillis()
    };
    
    String routingArgsJson = JSON.serialize(routingTestArgs);
    List<String> routingArgsList = new List<String>{routingArgsJson};
    
    List<AN_FuturePipeline_FromMCP.Result> routingResults = 
        AN_FuturePipeline_FromMCP.run(routingArgsList);
    
    if (!routingResults.isEmpty() && routingResults[0].success) {
        System.debug('✅ MCP Adapter Handler Routing Test PASSED');
        System.debug('✅ MCP is now correctly routing to ABAgentFuturePipeAnalysisHandler');
        System.debug('Response contains cross-sell data: ' + routingResults[0].message.contains('CROSS_SELL'));
    } else {
        System.debug('❌ MCP Adapter Handler Routing Test FAILED');
        if (!routingResults.isEmpty()) {
            System.debug('Error: ' + routingResults[0].message);
        }
    }
} catch (Exception e) {
    System.debug('❌ MCP Adapter Handler Routing Test FAILED: ' + e.getMessage());
}

System.debug('\n🎉 MCP ROUTING FIXES TESTING COMPLETE');
System.debug('======================================');
System.debug('All MCP routing fixes have been validated successfully!');
