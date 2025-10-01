// UAT Test for ANAgentKPIsAnalysis
System.debug('🧪 UAT: ANAgentKPIsAnalysis - Small Test');

try {
    ANAGENTKPIAnalysisHandlerV3.Request request = new ANAGENTKPIAnalysisHandlerV3.Request();
    request.action = 'Search';
    request.searchTerm = 'AMER ACC';
    request.OuName = 'AMER ACC';
    request.WorkLocationCountry = 'USA';
    
    List<ANAGENTKPIAnalysisHandlerV3.Request> requests = new List<ANAGENTKPIAnalysisHandlerV3.Request>{request};
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(requests);
    
    if (responses != null && !responses.isEmpty()) {
        System.debug('✅ SUCCESS: ' + responses[0].message);
    } else {
        System.debug('⚠️ No response received');
    }
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
}

System.debug('✅ Test completed!');
