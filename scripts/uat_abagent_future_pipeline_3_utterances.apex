// Detailed UAT Test for ABAGENT Future Pipeline Analysis - 3 Utterances
System.debug('🧪 DETAILED UAT: ABAGENT Future Pipeline Analysis - 3 Utterances');
System.debug('================================================================');

// Test Results
Integer testCount = 0;
Integer passCount = 0;
Integer failCount = 0;

// Test 1: Basic Future Pipeline Analysis
testCount++;
System.debug('Test ' + testCount + ': Basic Future Pipeline Analysis');
try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request.analysisType = 'FUTURE_PIPELINE';
    request.operatingUnit = 'AMER ACC';
    
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest> requests = new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>{request};
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses = ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(requests);
    
    System.debug('UTTERANCE: Show me future pipeline analysis for AMER ACC');
    if (responses != null && !responses.isEmpty()) {
        System.debug('AGENT RESPONSE: ' + responses[0].detailedResults);
        System.debug('RESULT: PASS');
        passCount++;
    } else {
        System.debug('AGENT RESPONSE: No response received');
        System.debug('RESULT: FAIL');
        failCount++;
    }
} catch (Exception e) {
    System.debug('UTTERANCE: Show me future pipeline analysis for AMER ACC');
    System.debug('AGENT RESPONSE: ERROR: ' + e.getMessage());
    System.debug('RESULT: FAIL');
    failCount++;
}

// Test 2: Naming Convention - AMERACC
testCount++;
System.debug('Test ' + testCount + ': Naming Convention - AMERACC');
try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request.analysisType = 'RENEWALS';
    request.operatingUnit = 'AMERACC';
    
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest> requests = new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>{request};
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses = ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(requests);
    
    System.debug('UTTERANCE: Analyze renewals for AMERACC');
    if (responses != null && !responses.isEmpty()) {
        System.debug('AGENT RESPONSE: ' + responses[0].detailedResults);
        System.debug('RESULT: PASS');
        passCount++;
    } else {
        System.debug('AGENT RESPONSE: No response received');
        System.debug('RESULT: FAIL');
        failCount++;
    }
} catch (Exception e) {
    System.debug('UTTERANCE: Analyze renewals for AMERACC');
    System.debug('AGENT RESPONSE: ERROR: ' + e.getMessage());
    System.debug('RESULT: FAIL');
    failCount++;
}

// Test 3: Cross-sell Analysis
testCount++;
System.debug('Test ' + testCount + ': Cross-sell Analysis');
try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request.analysisType = 'CROSS_SELL';
    request.operatingUnit = 'EMEA ENTR';
    request.industry = 'Healthcare';
    
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest> requests = new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>{request};
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses = ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(requests);
    
    System.debug('UTTERANCE: What cross-sell opportunities exist in EMEA ENTR healthcare?');
    if (responses != null && !responses.isEmpty()) {
        System.debug('AGENT RESPONSE: ' + responses[0].detailedResults);
        System.debug('RESULT: PASS');
        passCount++;
    } else {
        System.debug('AGENT RESPONSE: No response received');
        System.debug('RESULT: FAIL');
        failCount++;
    }
} catch (Exception e) {
    System.debug('UTTERANCE: What cross-sell opportunities exist in EMEA ENTR healthcare?');
    System.debug('AGENT RESPONSE: ERROR: ' + e.getMessage());
    System.debug('RESULT: FAIL');
    failCount++;
}

// Summary
System.debug('==========================================');
System.debug('ABAGENT Future Pipeline Analysis UAT Summary');
System.debug('==========================================');
System.debug('Total Tests: ' + testCount);
System.debug('Passed: ' + passCount);
System.debug('Failed: ' + failCount);
System.debug('Success Rate: ' + (passCount * 100 / testCount) + '%');
System.debug('✅ ABAGENT Future Pipeline Analysis Detailed UAT COMPLETED!');
