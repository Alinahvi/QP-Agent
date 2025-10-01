// UAT Test 5 for ABAGENT Future Pipeline Analysis
System.debug('🧪 UAT 5: ABAGENT Future Pipeline Analysis');
System.debug('UTTERANCE: Show me future pipeline for AMER SMB technology segment');
try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request.analysisType = 'FUTURE_PIPELINE';
    request.operatingUnit = 'AMER SMB';
    request.industry = 'Technology';
    request.segment = 'SMB';
    
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
