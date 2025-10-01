// Challenging Open Pipe Analysis - Big List with CSV Export
// Use this in Agentforce for comprehensive analysis and data export

// Multiple analysis types for comprehensive insights
List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest> requests = new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>();

// 1. Top Products Analysis
ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request1 = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
request1.analysisType = 'TOP_PRODUCTS';
request1.operatingUnit = 'AMER ICE';
request1.industry = 'Technology';
request1.maxResults = 50;
requests.add(request1);

// 2. Top Customers Analysis
ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request2 = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
request2.analysisType = 'TOP_CUSTOMERS';
request2.operatingUnit = 'AMER ICE';
request2.industry = 'Technology';
request2.maxResults = 50;
requests.add(request2);

// 3. Stagnation Analysis
ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request3 = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
request3.analysisType = 'STAGNATION_ANALYSIS';
request3.operatingUnit = 'AMER ICE';
request3.industry = 'Technology';
request3.maxResults = 50;
requests.add(request3);

// 4. CSV Export
ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request4 = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
request4.analysisType = 'EXPORT_CSV';
request4.operatingUnit = 'AMER ICE';
request4.industry = 'Technology';
request4.maxResults = 100;
requests.add(request4);

// Execute all analyses
List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
    ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(requests);

System.debug('=== Challenging Open Pipe Analysis Results ===');
System.debug('Total Requests: ' + requests.size());
System.debug('Total Responses: ' + responses.size());

// Process each response
for (Integer i = 0; i < responses.size(); i++) {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[i];
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest req = requests[i];
    
    System.debug('--- Analysis ' + (i+1) + ': ' + req.analysisType + ' ---');
    System.debug('Success: ' + response.success);
    System.debug('Message: ' + response.message);
    System.debug('Results Count: ' + (response.results != null ? response.results.size() : 0));
    
    // Special handling for CSV export
    if (req.analysisType == 'EXPORT_CSV' && response.csvData != null) {
        System.debug('CSV Data Length: ' + response.csvData.length());
        System.debug('CSV Preview (first 500 chars): ' + response.csvData.substring(0, Math.min(500, response.csvData.length())));
    }
    
    // Show sample results
    if (response.success && response.results != null && !response.results.isEmpty()) {
        System.debug('Sample Result: ' + response.results[0]);
        System.debug('Total Results: ' + response.results.size());
    }
} 