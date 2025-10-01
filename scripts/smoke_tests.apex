// Smoke tests for MCP Open Pipe Analysis integration
// Usage: sfdx force:apex:execute -u MySandbox -f scripts/smoke_tests.apex

System.debug('🧪 Starting MCP Open Pipe Analysis Smoke Tests');
System.debug('================================================');

// Test 1: ROUTE mode
System.debug('');
System.debug('🔍 Test 1: ROUTE Mode');
System.debug('---------------------');

try {
    ANAgentOpenPipeViaMCPV1.InvocableRequest routeRequest = new ANAgentOpenPipeViaMCPV1.InvocableRequest();
    routeRequest.utterance = 'Open pipe passed stage 4 in AMER ACC, country = US, top 10.';
    routeRequest.mode = 'ROUTE';
    
    System.debug('📤 Sending ROUTE request: ' + routeRequest.utterance);
    
    List<ANAgentOpenPipeViaMCPV1.InvocableResponse> routeResponses = ANAgentOpenPipeViaMCPV1.analyzeOpenPipe(new List<ANAgentOpenPipeViaMCPV1.InvocableRequest>{routeRequest});
    
    if (!routeResponses.isEmpty()) {
        ANAgentOpenPipeViaMCPV1.InvocableResponse routeResponse = routeResponses[0];
        System.debug('📥 ROUTE Response:');
        System.debug('   Success: ' + routeResponse.success);
        System.debug('   Message: ' + routeResponse.message);
        System.debug('   Tool: ' + routeResponse.tool);
        System.debug('   OU Name: ' + routeResponse.ouName);
        System.debug('   Min Stage: ' + routeResponse.minStage);
        System.debug('   Country: ' + routeResponse.country);
        System.debug('   Time Frame: ' + routeResponse.timeFrame);
        System.debug('   Limit N: ' + routeResponse.limitN);
        
        if (routeResponse.success && routeResponse.tool == 'open_pipe_analyze') {
            System.debug('✅ ROUTE Test: PASSED');
        } else {
            System.debug('❌ ROUTE Test: FAILED - ' + routeResponse.message);
        }
    } else {
        System.debug('❌ ROUTE Test: FAILED - No response received');
    }
    
} catch (Exception e) {
    System.debug('❌ ROUTE Test: FAILED - Exception: ' + e.getMessage());
}

// Test 2: ANALYZE mode
System.debug('');
System.debug('🔍 Test 2: ANALYZE Mode');
System.debug('----------------------');

try {
    ANAgentOpenPipeViaMCPV1.InvocableRequest analyzeRequest = new ANAgentOpenPipeViaMCPV1.InvocableRequest();
    analyzeRequest.utterance = 'AMER ACC, stage 4, current quarter, top 5';
    analyzeRequest.mode = 'ANALYZE';
    
    System.debug('📤 Sending ANALYZE request: ' + analyzeRequest.utterance);
    
    List<ANAgentOpenPipeViaMCPV1.InvocableResponse> analyzeResponses = ANAgentOpenPipeViaMCPV1.analyzeOpenPipe(new List<ANAgentOpenPipeViaMCPV1.InvocableRequest>{analyzeRequest});
    
    if (!analyzeResponses.isEmpty()) {
        ANAgentOpenPipeViaMCPV1.InvocableResponse analyzeResponse = analyzeResponses[0];
        System.debug('📥 ANALYZE Response:');
        System.debug('   Success: ' + analyzeResponse.success);
        System.debug('   Message: ' + analyzeResponse.message);
        System.debug('   Response Body Length: ' + (analyzeResponse.responseBody != null ? analyzeResponse.responseBody.length() : 0));
        
        if (analyzeResponse.responseBody != null && analyzeResponse.responseBody.length() > 0) {
            String responsePreview = analyzeResponse.responseBody.length() > 1000 ? 
                analyzeResponse.responseBody.substring(0, 1000) + '...' : 
                analyzeResponse.responseBody;
            System.debug('   Response Preview: ' + responsePreview);
        }
        
        if (analyzeResponse.success && analyzeResponse.responseBody != null) {
            System.debug('✅ ANALYZE Test: PASSED');
        } else {
            System.debug('❌ ANALYZE Test: FAILED - ' + analyzeResponse.message);
        }
    } else {
        System.debug('❌ ANALYZE Test: FAILED - No response received');
    }
    
} catch (Exception e) {
    System.debug('❌ ANALYZE Test: FAILED - Exception: ' + e.getMessage());
}

// Test 3: Error handling
System.debug('');
System.debug('🔍 Test 3: Error Handling');
System.debug('-------------------------');

try {
    ANAgentOpenPipeViaMCPV1.InvocableRequest errorRequest = new ANAgentOpenPipeViaMCPV1.InvocableRequest();
    errorRequest.utterance = 'Invalid request';
    errorRequest.mode = 'INVALID_MODE';
    
    System.debug('📤 Sending invalid request with mode: ' + errorRequest.mode);
    
    List<ANAgentOpenPipeViaMCPV1.InvocableResponse> errorResponses = ANAgentOpenPipeViaMCPV1.analyzeOpenPipe(new List<ANAgentOpenPipeViaMCPV1.InvocableRequest>{errorRequest});
    
    if (!errorResponses.isEmpty()) {
        ANAgentOpenPipeViaMCPV1.InvocableResponse errorResponse = errorResponses[0];
        System.debug('📥 Error Response:');
        System.debug('   Success: ' + errorResponse.success);
        System.debug('   Message: ' + errorResponse.message);
        
        if (!errorResponse.success && errorResponse.message.contains('Invalid mode')) {
            System.debug('✅ Error Handling Test: PASSED');
        } else {
            System.debug('❌ Error Handling Test: FAILED - Expected error not received');
        }
    } else {
        System.debug('❌ Error Handling Test: FAILED - No response received');
    }
    
} catch (Exception e) {
    System.debug('❌ Error Handling Test: FAILED - Exception: ' + e.getMessage());
}

// Summary
System.debug('');
System.debug('📊 Smoke Test Summary');
System.debug('===================');
System.debug('✅ ROUTE Mode: Tested natural language routing');
System.debug('✅ ANALYZE Mode: Tested direct analysis');
System.debug('✅ Error Handling: Tested invalid input handling');
System.debug('');
System.debug('🎯 Next Steps:');
System.debug('   1. Check debug logs for detailed results');
System.debug('   2. Test in Sales Coach/Agent UI');
System.debug('   3. Verify MCP server is running and accessible');
System.debug('   4. Check Named Credential URL is correct');
System.debug('');
System.debug('🔧 Troubleshooting:');
System.debug('   - If ROUTE fails: Check MCP server /route endpoint');
System.debug('   - If ANALYZE fails: Check MCP server /analyze endpoint');
System.debug('   - If both fail: Check Named Credential URL and network connectivity');
System.debug('   - Check debug logs for detailed error messages');
