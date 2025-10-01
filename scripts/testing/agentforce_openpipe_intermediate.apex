// Intermediate Open Pipe Analysis - Moderate Analysis
// Use this in Agentforce for deeper insights with filtering

// Comprehensive request with multiple filters
ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
request.analysisType = 'TOP_CUSTOMERS';
request.operatingUnit = 'UKI';
request.industry = 'FINS';
request.region = 'UK';
request.stageFilter = 'Prospecting';
request.maxResults = 10;

List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
    ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});

if (!responses.isEmpty()) {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
    System.debug('=== Intermediate Open Pipe Analysis Results ===');
    System.debug('Success: ' + response.success);
    System.debug('Message: ' + response.message);
    System.debug('Analysis Type: ' + request.analysisType);
    System.debug('Operating Unit: ' + request.operatingUnit);
    System.debug('Industry: ' + request.industry);
    System.debug('Region: ' + request.region);
    System.debug('Stage Filter: ' + request.stageFilter);
    System.debug('Max Results: ' + request.maxResults);
    System.debug('Results: ' + response.results);
    
    // Additional analysis
    if (response.success && response.results != null) {
        System.debug('Total Results: ' + response.results.size());
        System.debug('First Result: ' + response.results[0]);
    }
} 