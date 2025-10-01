// Basic Territory Analysis - Small Nugget of Insight
// Use this in Agentforce for quick KPI overview

// Simple request for territory KPIs
ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest request = new ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest();
request.analysisType = 'TERRITORY_KPIS';
request.operatingUnit = 'AMER ICE';
request.maxResults = 5;

List<ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisResponse> responses = 
    ANAgentAETerritoryAnalysisHandler.analyzeTerritory(new List<ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest>{request});

if (!responses.isEmpty()) {
    ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisResponse response = responses[0];
    System.debug('=== Basic Territory Analysis Results ===');
    System.debug('Success: ' + response.success);
    System.debug('Message: ' + response.message);
    System.debug('Analysis Type: ' + request.analysisType);
    System.debug('Operating Unit: ' + request.operatingUnit);
    System.debug('Results: ' + response.results);
} 