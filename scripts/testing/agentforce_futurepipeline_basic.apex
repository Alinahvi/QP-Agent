// Basic Future Pipeline Analysis - Small Nugget of Insight
// Use this in Agentforce for quick, simple future pipeline overview

// Simple request for all future pipeline types
ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
request.analysisType = 'FUTURE_PIPELINE';
request.operatingUnit = 'AMER ICE';
request.maxResults = 10;

List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses = 
    ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>{request});

if (!responses.isEmpty()) {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse response = responses[0];
    System.debug('=== Basic Future Pipeline Analysis Results ===');
    System.debug('Success: ' + response.success);
    System.debug('Message: ' + response.message);
    System.debug('Total Records: ' + response.totalRecords);
    System.debug('Renewal Count: ' + response.renewalCount);
    System.debug('Cross-Sell Count: ' + response.crossSellCount);
    System.debug('Upsell Count: ' + response.upsellCount);
} 