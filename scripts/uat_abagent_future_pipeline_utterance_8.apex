// UAT Test 8 for ABAGENT Future Pipeline Analysis
System.debug('🧪 UAT 8: ABAGENT Future Pipeline Analysis');
System.debug('UTTERANCE: Find upsell opportunities for Marketing Cloud in APAC TECH');
try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request.analysisType = 'UPSELL';
    request.operatingUnit = 'APAC TECH';
    request.industry = 'Technology';
    request.product = 'Marketing Cloud';
    
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
