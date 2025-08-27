// Basic Open Pipe Analysis - Small Nugget of Insight
// Use this in Agentforce for quick, simple analysis

// Simple request for top products by stage
ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
request.analysisType = 'TOP_PRODUCTS';
request.operatingUnit = 'AMER ICE';
request.maxResults = 5;

List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
    ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});

if (!responses.isEmpty()) {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
    System.debug('=== Basic Open Pipe Analysis Results ===');
    System.debug('Success: ' + response.success);
    System.debug('Message: ' + response.message);
    System.debug('Analysis Type: ' + request.analysisType);
    System.debug('Operating Unit: ' + request.operatingUnit);
    System.debug('Results: ' + response.results);
} 