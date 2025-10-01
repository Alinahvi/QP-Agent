// Small UAT Test for ABAGENT Future Pipeline Analysis
System.debug('🧪 UAT: ABAGENT Future Pipeline Analysis - Small Test');

try {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
    request.analysisType = 'FUTURE_PIPELINE';
    request.operatingUnit = 'AMER ACC';
    
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest> requests = new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>{request};
    List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses = ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(requests);
    
    if (responses != null && !responses.isEmpty()) {
        System.debug('✅ SUCCESS: ' + responses[0].detailedResults);
    } else {
        System.debug('⚠️ No response received');
    }
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
}

System.debug('✅ Test completed!');
