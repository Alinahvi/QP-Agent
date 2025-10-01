// UAT Test 2 for ANAgentKPIsAnalysis
System.debug('🧪 UAT 2: ANAgentKPIsAnalysis');
System.debug('UTTERANCE: Analyze KPIs for AMERACC');
try {
    ANAGENTKPIAnalysisHandlerV3.Request request = new ANAGENTKPIAnalysisHandlerV3.Request();
    request.action = 'Search';
    request.searchTerm = 'AMERACC';
    request.OuName = 'AMERACC';
    request.WorkLocationCountry = 'USA';
    
    List<ANAGENTKPIAnalysisHandlerV3.Request> requests = new List<ANAGENTKPIAnalysisHandlerV3.Request>{request};
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(requests);
    
    if (responses != null && !responses.isEmpty()) {
        System.debug('AGENT RESPONSE: ' + responses[0].message);
        System.debug('RESULT: PASS');
    } else {
        System.debug('AGENT RESPONSE: No response received');
        System.debug('RESULT: FAIL');
    }
} catch (Exception e) {
    System.debug('AGENT RESPONSE: ERROR: ' + e.getMessage());
    System.debug('RESULT: FAIL');
}
