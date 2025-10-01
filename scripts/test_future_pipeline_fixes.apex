// Test script to validate Future Pipeline Analysis fixes
// This script tests both the basic and enhanced handlers to ensure capabilities work

System.debug('🧪 TESTING FUTURE PIPELINE ANALYSIS FIXES');
System.debug('==========================================');

// Test 1: Basic Handler Test
System.debug('\n🔍 Test 1: Basic Handler Test');
try {
    ABAgentFuturePipeAnalysisHandler.Request request = new ABAgentFuturePipeAnalysisHandler.Request();
    request.analysisType = 'RENEWALS';
    request.ouName = 'AMER ICE';
    request.groupBy = 'PRODUCT';
    request.limitN = 5;
    
    List<ABAgentFuturePipeAnalysisHandler.Response> responses = 
        ABAgentFuturePipeAnalysisHandler.analyzePipeline(new List<ABAgentFuturePipeAnalysisHandler.Request>{request});
    
    if (!responses.isEmpty()) {
        System.debug('✅ Basic Handler Test PASSED');
        System.debug('Response: ' + responses[0].message);
    } else {
        System.debug('❌ Basic Handler Test FAILED - No response');
    }
} catch (Exception e) {
    System.debug('❌ Basic Handler Test FAILED: ' + e.getMessage());
}

// Test 2: Enhanced Handler Test
System.debug('\n🔍 Test 2: Enhanced Handler Test');
try {
    ABAgentFuturePipeAnalysisHandlerEnhanced.EnhancedRequest enhancedRequest = new ABAgentFuturePipeAnalysisHandlerEnhanced.EnhancedRequest();
    enhancedRequest.analysisType = 'RENEWALS';
    enhancedRequest.ouName = 'AMER ICE';
    enhancedRequest.groupBy = 'PRODUCT';
    enhancedRequest.limitN = 5;
    enhancedRequest.includeRenewalRisk = true;
    enhancedRequest.includeAEPerf = true;
    enhancedRequest.includePMF = true;
    enhancedRequest.includeHealthScore = true;
    
    List<ABAgentFuturePipeAnalysisHandlerEnhanced.EnhancedResponse> enhancedResponses = 
        ABAgentFuturePipeAnalysisHandlerEnhanced.analyzePipelineEnhanced(new List<ABAgentFuturePipeAnalysisHandlerEnhanced.EnhancedRequest>{enhancedRequest});
    
    if (!enhancedResponses.isEmpty()) {
        System.debug('✅ Enhanced Handler Test PASSED');
        System.debug('Response: ' + enhancedResponses[0].message);
        
        // Check if intelligence features are included
        String responseText = enhancedResponses[0].message;
        Boolean hasEmojis = responseText.contains('🎯') || responseText.contains('👥') || responseText.contains('📊') || responseText.contains('🏥') || responseText.contains('💡');
        if (hasEmojis) {
            System.debug('✅ Intelligence Features with Emojis WORKING');
        } else {
            System.debug('⚠️ Intelligence Features may not be fully enabled');
        }
    } else {
        System.debug('❌ Enhanced Handler Test FAILED - No response');
    }
} catch (Exception e) {
    System.debug('❌ Enhanced Handler Test FAILED: ' + e.getMessage());
}

// Test 3: MCP Adapter Test (Basic)
System.debug('\n🔍 Test 3: MCP Adapter Test (Basic)');
try {
    Map<String, Object> mcpArgs = new Map<String, Object>{
        'ouName' => 'AMER ICE',
        'opportunityType' => 'renewal',
        'correlationId' => 'TEST_' + System.currentTimeMillis()
    };
    
    String argsJson = JSON.serialize(mcpArgs);
    List<String> argsList = new List<String>{argsJson};
    
    List<AN_FuturePipeline_FromMCP.Result> mcpResults = 
        AN_FuturePipeline_FromMCP.run(argsList);
    
    if (!mcpResults.isEmpty() && mcpResults[0].success) {
        System.debug('✅ MCP Adapter Test (Basic) PASSED');
        System.debug('Response: ' + mcpResults[0].message);
    } else {
        System.debug('❌ MCP Adapter Test (Basic) FAILED');
        if (!mcpResults.isEmpty()) {
            System.debug('Error: ' + mcpResults[0].message);
        }
    }
} catch (Exception e) {
    System.debug('❌ MCP Adapter Test (Basic) FAILED: ' + e.getMessage());
}

// Test 4: MCP Adapter Test (Enhanced)
System.debug('\n🔍 Test 4: MCP Adapter Test (Enhanced)');
try {
    Map<String, Object> enhancedMcpArgs = new Map<String, Object>{
        'ouName' => 'AMER ICE',
        'opportunityType' => 'renewal',
        'includeRenewalRisk' => 'true',
        'includeAEPerf' => 'true',
        'includePMF' => 'true',
        'includeHealthScore' => 'true',
        'correlationId' => 'TEST_ENHANCED_' + System.currentTimeMillis()
    };
    
    String enhancedArgsJson = JSON.serialize(enhancedMcpArgs);
    List<String> enhancedArgsList = new List<String>{enhancedArgsJson};
    
    List<AN_FuturePipeline_Enhanced_FromMCP.Result> enhancedMcpResults = 
        AN_FuturePipeline_Enhanced_FromMCP.runEnhanced(enhancedArgsList);
    
    if (!enhancedMcpResults.isEmpty() && enhancedMcpResults[0].success) {
        System.debug('✅ MCP Adapter Test (Enhanced) PASSED');
        System.debug('Response: ' + enhancedMcpResults[0].message);
        
        // Check if intelligence features are included
        String responseText = enhancedMcpResults[0].message;
        Boolean hasEmojis = responseText.contains('🎯') || responseText.contains('👥') || responseText.contains('📊') || responseText.contains('🏥') || responseText.contains('💡');
        if (hasEmojis) {
            System.debug('✅ Enhanced MCP with Intelligence Features WORKING');
        } else {
            System.debug('⚠️ Enhanced MCP may not have full intelligence features');
        }
    } else {
        System.debug('❌ MCP Adapter Test (Enhanced) FAILED');
        if (!enhancedMcpResults.isEmpty()) {
            System.debug('Error: ' + enhancedMcpResults[0].message);
        }
    }
} catch (Exception e) {
    System.debug('❌ MCP Adapter Test (Enhanced) FAILED: ' + e.getMessage());
}

// Test 5: Cross-Sell Analysis Test
System.debug('\n🔍 Test 5: Cross-Sell Analysis Test');
try {
    ABAgentFuturePipeAnalysisHandler.Request crossSellRequest = new ABAgentFuturePipeAnalysisHandler.Request();
    crossSellRequest.analysisType = 'CROSS_SELL';
    crossSellRequest.ouName = 'AMER ICE';
    crossSellRequest.groupBy = 'PRODUCT';
    crossSellRequest.limitN = 5;
    
    List<ABAgentFuturePipeAnalysisHandler.Response> crossSellResponses = 
        ABAgentFuturePipeAnalysisHandler.analyzePipeline(new List<ABAgentFuturePipeAnalysisHandler.Request>{crossSellRequest});
    
    if (!crossSellResponses.isEmpty()) {
        System.debug('✅ Cross-Sell Analysis Test PASSED');
        System.debug('Response: ' + crossSellResponses[0].message);
    } else {
        System.debug('❌ Cross-Sell Analysis Test FAILED - No response');
    }
} catch (Exception e) {
    System.debug('❌ Cross-Sell Analysis Test FAILED: ' + e.getMessage());
}

// Test 6: Upsell Analysis Test
System.debug('\n🔍 Test 6: Upsell Analysis Test');
try {
    ABAgentFuturePipeAnalysisHandler.Request upsellRequest = new ABAgentFuturePipeAnalysisHandler.Request();
    upsellRequest.analysisType = 'UPSELL';
    upsellRequest.ouName = 'AMER ICE';
    upsellRequest.groupBy = 'PRODUCT';
    upsellRequest.limitN = 5;
    
    List<ABAgentFuturePipeAnalysisHandler.Response> upsellResponses = 
        ABAgentFuturePipeAnalysisHandler.analyzePipeline(new List<ABAgentFuturePipeAnalysisHandler.Request>{upsellRequest});
    
    if (!upsellResponses.isEmpty()) {
        System.debug('✅ Upsell Analysis Test PASSED');
        System.debug('Response: ' + upsellResponses[0].message);
    } else {
        System.debug('❌ Upsell Analysis Test FAILED - No response');
    }
} catch (Exception e) {
    System.debug('❌ Upsell Analysis Test FAILED: ' + e.getMessage());
}

System.debug('\n🎉 FUTURE PIPELINE ANALYSIS FIXES TESTING COMPLETE');
System.debug('==================================================');
System.debug('Check the results above to verify all fixes are working correctly.');
System.debug('Look for ✅ PASSED indicators and emoji formatting in responses.');
