// Challenging Territory Analysis - Big List with Comprehensive KPI Analysis
// Use this in Agentforce for comprehensive territory insights across multiple dimensions

// Comprehensive territory analysis across multiple OUs, industries, and regions
List<ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest> requests = new List<ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest>();

// 1. AMER ICE Technology - High Volume
ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest request1 = new ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest();
request1.analysisType = 'TERRITORY_KPIS';
request1.operatingUnit = 'AMER ICE';
request1.industry = 'Technology';
request1.region = 'US';
request1.maxResults = 100;
requests.add(request1);

// 2. UKI FINS - Financial Focus
ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest request2 = new ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest();
request2.analysisType = 'TERRITORY_KPIS';
request2.operatingUnit = 'UKI';
request2.industry = 'FINS';
request2.region = 'UK';
request2.maxResults = 100;
requests.add(request2);

// 3. LATAM Manufacturing - Manufacturing Focus
ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest request3 = new ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest();
request3.analysisType = 'TERRITORY_KPIS';
request3.operatingUnit = 'LATAM';
request3.industry = 'Manufacturing';
request3.region = 'Brazil';
request3.maxResults = 100;
requests.add(request3);

// 4. EMEA HLS - Healthcare Focus
ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest request4 = new ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest();
request4.analysisType = 'TERRITORY_KPIS';
request4.operatingUnit = 'EMEA';
request4.industry = 'HLS';
request4.region = 'Germany';
request4.maxResults = 100;
requests.add(request4);

// Execute all analyses
List<ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisResponse> responses = 
    ANAgentAETerritoryAnalysisHandler.analyzeTerritory(requests);

System.debug('=== Challenging Territory Analysis Results ===');
System.debug('Total Requests: ' + requests.size());
System.debug('Total Responses: ' + responses.size());

// Process each response with detailed KPI analysis
for (Integer i = 0; i < responses.size(); i++) {
    ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisResponse response = responses[i];
    ANAgentAETerritoryAnalysisHandler.TerritoryAnalysisRequest req = requests[i];
    
    System.debug('--- Analysis ' + (i+1) + ': ' + req.operatingUnit + ' - ' + req.industry + ' (' + req.region + ') ---');
    System.debug('Success: ' + response.success);
    System.debug('Message: ' + response.message);
    System.debug('Analysis Type: ' + req.analysisType);
    System.debug('Max Results: ' + req.maxResults);
    System.debug('Results Count: ' + (response.results != null ? response.results.size() : 0));
    
    // Show detailed KPI breakdown
    if (response.success && response.results != null && !response.results.isEmpty()) {
        System.debug('KPI Analysis:');
        System.debug('- Total Records: ' + response.results.size());
        System.debug('- Sample Result: ' + response.results[0]);
        
        // Show first few results for detailed inspection
        Integer showCount = Math.min(3, response.results.size());
        for (Integer j = 0; j < showCount; j++) {
            System.debug('- Result ' + (j+1) + ': ' + response.results[j]);
        }
    }
    
    System.debug('---');
} 