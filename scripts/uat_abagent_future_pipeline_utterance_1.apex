// UAT Test 1 for ABAGENT Future Pipeline Analysis
System.debug('🧪 UAT 1: ABAGENT Future Pipeline Analysis');
System.debug('UTTERANCE: Show me future pipeline analysis for AMER ACC');
try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request.analysisType = 'FUTURE_PIPELINE';
    request.operatingUnit = 'AMER ACC';
    
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest> requests = new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>{request};
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses = ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(requests);
    
    if (responses != null && !responses.isEmpty()) {
        System.debug('AGENT RESPONSE: ' + responses[0].detailedResults);
        System.debug('RESULT: PASS');
    } else {
        System.debug('AGENT RESPONSE: No response received');
        System.debug('RESULT: FAIL');
    }
} catch (Exception e) {
    System.debug('AGENT RESPONSE: ERROR: ' + e.getMessage());
    System.debug('RESULT: FAIL');
}