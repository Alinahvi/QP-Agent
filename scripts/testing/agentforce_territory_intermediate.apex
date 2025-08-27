// Intermediate Territory Analysis - Moderate Analysis
// Use this in Agentforce for deeper KPI insights with filtering

// Multiple territory analysis with different filters
List<ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest> requests = new List<ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest>();

// 1. AMER ICE Technology KPIs
ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest request1 = new ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest();
request1.analysisType = 'TERRITORY_KPIS';
request1.operatingUnit = 'AMER ICE';
request1.industry = 'Technology';
request1.maxResults = 15;
requests.add(request1);

// 2. UKI FINS KPIs
ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest request2 = new ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest();
request2.analysisType = 'TERRITORY_KPIS';
request2.operatingUnit = 'UKI';
request2.industry = 'FINS';
request2.maxResults = 15;
requests.add(request2);

// Execute analyses
List<ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisResponse> responses = 
    ANAgentAETerritoryAnalysisHandler.analyzeTerritory(requests);

System.debug('=== Intermediate Territory Analysis Results ===');

// Process each response
for (Integer i = 0; i < responses.size(); i++) {
    ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisResponse response = responses[i];
    ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest req = requests[i];
    
    System.debug('--- Analysis ' + (i+1) + ': ' + req.operatingUnit + ' - ' + req.industry + ' ---');
    System.debug('Success: ' + response.success);
    System.debug('Message: ' + response.message);
    System.debug('Operating Unit: ' + req.operatingUnit);
    System.debug('Industry: ' + req.industry);
    System.debug('Max Results: ' + req.maxResults);
    System.debug('Results Count: ' + (response.results != null ? response.results.size() : 0));
    
    // Show sample results
    if (response.success && response.results != null && !response.results.isEmpty()) {
        System.debug('Sample Result: ' + response.results[0]);
    }
} 