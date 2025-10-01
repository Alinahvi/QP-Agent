// UAT Test 5: ANAgentKPIsAnalysis - Error Handling
// Test Date: September 25, 2025
// Test Environment: Innovation Sandbox
// Test Scope: Error handling and edge cases

// Test 5: Error Handling and Edge Cases
List<ANAGENTKPIAnalysisHandlerV3.Request> requests = new List<ANAGENTKPIAnalysisHandlerV3.Request>();

// Test 5a: Missing Required Fields
ANAGENTKPIAnalysisHandlerV3.Request req5a = new ANAGENTKPIAnalysisHandlerV3.Request();
req5a.action = 'Search';
// No OU Name or Work Location Country provided
req5a.recordLimit = 5;
requests.add(req5a);

// Test 5b: Invalid Action
ANAGENTKPIAnalysisHandlerV3.Request req5b = new ANAGENTKPIAnalysisHandlerV3.Request();
req5b.action = 'InvalidAction';
req5b.OuName = 'AMER ACC';
req5b.recordLimit = 5;
requests.add(req5b);

// Test 5c: Empty Search Term
ANAGENTKPIAnalysisHandlerV3.Request req5c = new ANAGENTKPIAnalysisHandlerV3.Request();
req5c.action = 'Search';
req5c.OuName = 'AMER ACC';
req5c.searchTerm = '';
req5c.recordLimit = 5;
requests.add(req5c);

// Test 5d: Large Record Limit
ANAGENTKPIAnalysisHandlerV3.Request req5d = new ANAGENTKPIAnalysisHandlerV3.Request();
req5d.action = 'Search';
req5d.OuName = 'AMER ACC';
req5d.recordLimit = 1000; // Large limit
requests.add(req5d);

// Test 5e: Negative Record Limit
ANAGENTKPIAnalysisHandlerV3.Request req5e = new ANAGENTKPIAnalysisHandlerV3.Request();
req5e.action = 'Search';
req5e.OuName = 'AMER ACC';
req5e.recordLimit = -1; // Negative limit
requests.add(req5e);

List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(requests);

System.debug('=== UAT Test 5: Error Handling ===');
for (Integer i = 0; i < responses.size(); i++) {
    System.debug('Test 5' + String.fromCharArray(new List<Integer>{97 + i}) + ': Success=' + responses[i].success + 
                ', Message=' + responses[i].message);
}
System.debug('CPU Usage: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
System.debug('SOQL Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
System.debug('Query Rows: ' + Limits.getQueryRows() + '/' + Limits.getLimitQueries());
System.debug('==========================================');
