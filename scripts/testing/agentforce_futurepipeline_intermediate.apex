// Intermediate Future Pipeline Analysis - Moderate Analysis
// Use this in Agentforce for deeper insights with segmentation

// Multiple analysis types with filtering
List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest> requests = new List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest>();

// 1. Renewals Analysis
ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request1 = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
request1.analysisType = 'RENEWALS';
request1.operatingUnit = 'UKI';
request1.industry = 'FINS';
request1.maxResults = 25;
requests.add(request1);

// 2. Cross-Sell Analysis
ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest request2 = new ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest();
request2.analysisType = 'CROSS_SELL';
request2.operatingUnit = 'UKI';
request2.industry = 'FINS';
request2.maxResults = 25;
requests.add(request2);

// Execute analyses
List<ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse> responses = 
    ANAgentFuturePipelineAnalysisHandler.analyzeFuturePipeline(requests);

System.debug('=== Intermediate Future Pipeline Analysis Results ===');

// Process each response
for (Integer i = 0; i < responses.size(); i++) {
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineResponse response = responses[i];
    ANAgentFuturePipelineAnalysisHandler.FuturePipelineRequest req = requests[i];
    
    System.debug('--- Analysis ' + (i+1) + ': ' + req.analysisType + ' ---');
    System.debug('Success: ' + response.success);
    System.debug('Message: ' + response.message);
    System.debug('Operating Unit: ' + req.operatingUnit);
    System.debug('Industry: ' + req.industry);
    
    if (req.analysisType == 'RENEWALS') {
        System.debug('Renewal Count: ' + response.renewalCount);
        System.debug('Most Important Product: ' + response.mostImportantRenewalProduct);
        System.debug('Most Important Amount: $' + response.mostImportantRenewalAmount);
        System.debug('Most Important Reason: ' + response.mostImportantRenewalReason);
    } else if (req.analysisType == 'CROSS_SELL') {
        System.debug('Cross-Sell Count: ' + response.crossSellCount);
        System.debug('Detailed Opportunities: ' + response.crossSellOpportunities.size());
    }
} 