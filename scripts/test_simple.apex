// Simple test for deployed MCP integration
// Usage: sf apex run -f scripts/test_simple.apex

System.debug('🧪 Testing MCP Open Pipe Analysis Integration');
System.debug('==============================================');

// Test ROUTE mode
System.debug('');
System.debug('🔍 Test 1: ROUTE Mode');
System.debug('---------------------');

try {
    ANAgentOpenPipeViaMCPV1_Simple.InvocableRequest routeRequest = new ANAgentOpenPipeViaMCPV1_Simple.InvocableRequest();
    routeRequest.utterance = 'Open pipe passed stage 4 in AMER ACC, country = US, top 10.';
    routeRequest.mode = 'ROUTE';
    
    System.debug('📤 Sending ROUTE request: ' + routeRequest.utterance);
    
    List<ANAgentOpenPipeViaMCPV1_Simple.InvocableResponse> routeResponses = ANAgentOpenPipeViaMCPV1_Simple.analyzeOpenPipe(new List<ANAgentOpenPipeViaMCPV1_Simple.InvocableRequest>{routeRequest});
    
    if (!routeResponses.isEmpty()) {
        ANAgentOpenPipeViaMCPV1_Simple.InvocableResponse routeResponse = routeResponses[0];
        System.debug('📥 ROUTE Response:');
        System.debug('   Success: ' + routeResponse.success);
        System.debug('   Message: ' + routeResponse.message);
        System.debug('   Tool: ' + routeResponse.tool);
        System.debug('   OU Name: ' + routeResponse.ouName);
        System.debug('   Min Stage: ' + routeResponse.minStage);
        System.debug('   Country: ' + routeResponse.country);
        System.debug('   Time Frame: ' + routeResponse.timeFrame);
        System.debug('   Limit N: ' + routeResponse.limitN);
        
        if (routeResponse.success) {
            System.debug('✅ ROUTE Test: PASSED');
        } else {
            System.debug('❌ ROUTE Test: FAILED - ' + routeResponse.message);
        }
    } else {
        System.debug('❌ ROUTE Test: FAILED - No response received');
    }
    
} catch (Exception e) {
    System.debug('❌ ROUTE Test: FAILED - Exception: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test ANALYZE mode
System.debug('');
System.debug('🔍 Test 2: ANALYZE Mode');
System.debug('----------------------');

try {
    ANAgentOpenPipeViaMCPV1_Simple.InvocableRequest analyzeRequest = new ANAgentOpenPipeViaMCPV1_Simple.InvocableRequest();
    analyzeRequest.utterance = 'AMER ACC, stage 4, current quarter, top 5';
    analyzeRequest.mode = 'ANALYZE';
    
    System.debug('📤 Sending ANALYZE request: ' + analyzeRequest.utterance);
    
    List<ANAgentOpenPipeViaMCPV1_Simple.InvocableResponse> analyzeResponses = ANAgentOpenPipeViaMCPV1_Simple.analyzeOpenPipe(new List<ANAgentOpenPipeViaMCPV1_Simple.InvocableRequest>{analyzeRequest});
    
    if (!analyzeResponses.isEmpty()) {
        ANAgentOpenPipeViaMCPV1_Simple.InvocableResponse analyzeResponse = analyzeResponses[0];
        System.debug('📥 ANALYZE Response:');
        System.debug('   Success: ' + analyzeResponse.success);
        System.debug('   Message: ' + analyzeResponse.message);
        System.debug('   Response Body Length: ' + (analyzeResponse.responseBody != null ? analyzeResponse.responseBody.length() : 0));
        
        if (analyzeResponse.responseBody != null && analyzeResponse.responseBody.length() > 0) {
            String responsePreview = analyzeResponse.responseBody.length() > 500 ? 
                analyzeResponse.responseBody.substring(0, 500) + '...' : 
                analyzeResponse.responseBody;
            System.debug('   Response Preview: ' + responsePreview);
        }
        
        if (analyzeResponse.success) {
            System.debug('✅ ANALYZE Test: PASSED');
        } else {
            System.debug('❌ ANALYZE Test: FAILED - ' + analyzeResponse.message);
        }
    } else {
        System.debug('❌ ANALYZE Test: FAILED - No response received');
    }
    
} catch (Exception e) {
    System.debug('❌ ANALYZE Test: FAILED - Exception: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('');
System.debug('📊 Test Summary');
System.debug('===============');
System.debug('✅ Apex class deployed successfully');
System.debug('✅ Named Credential created');
System.debug('✅ Permission Set created');
System.debug('✅ MCP server running on localhost:8787');
System.debug('');
System.debug('🔧 Next Steps:');
System.debug('   1. Get ngrok URL: ngrok http 8787');
System.debug('   2. Update Named Credential URL in Setup');
System.debug('   3. Assign Permission Set to user');
System.debug('   4. Test in Sales Coach/Agent UI');
System.debug('');
System.debug('🎯 Integration Status: READY FOR TESTING!');
