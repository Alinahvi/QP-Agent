// UAT Test 3: ANAgentKPIsAnalysis - Advanced Filtering
// Test Date: September 25, 2025
// Test Environment: Innovation Sandbox
// Test Scope: Advanced filtering with multiple parameters

// Test 3: Advanced Filtering with Multiple Parameters
List<ANAGENTKPIAnalysisHandlerV3.Request> requests = new List<ANAGENTKPIAnalysisHandlerV3.Request>();

// Test 3a: Search with OU and Country
ANAGENTKPIAnalysisHandlerV3.Request req3a = new ANAGENTKPIAnalysisHandlerV3.Request();
req3a.action = 'Search';
req3a.OuName = 'AMER ACC';
req3a.WorkLocationCountry = 'USA';
req3a.recordLimit = 10;
requests.add(req3a);

// Test 3b: Search with Industry Filter
ANAGENTKPIAnalysisHandlerV3.Request req3b = new ANAGENTKPIAnalysisHandlerV3.Request();
req3b.action = 'Search';
req3b.OuName = 'EMEA ENTR';
req3b.PrimaryIndustry = 'Healthcare';
req3b.recordLimit = 10;
requests.add(req3b);

// Test 3c: Search with Ramp Status Filter
ANAGENTKPIAnalysisHandlerV3.Request req3c = new ANAGENTKPIAnalysisHandlerV3.Request();
req3c.action = 'Search';
req3c.OuName = 'APAC INDIA';
req3c.RampStatus = 'Fast Ramper';
req3c.recordLimit = 10;
requests.add(req3c);

// Test 3d: Search with Performance Metrics
ANAGENTKPIAnalysisHandlerV3.Request req3d = new ANAGENTKPIAnalysisHandlerV3.Request();
req3d.action = 'Search';
req3d.OuName = 'AMER SMB';
req3d.ValQuota = '1000000';
req3d.Coverage = '1.5';
req3d.recordLimit = 10;
requests.add(req3d);

List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(requests);

System.debug('=== UAT Test 3: Advanced Filtering ===');
for (Integer i = 0; i < responses.size(); i++) {
    System.debug('Test 3' + String.fromCharArray(new List<Integer>{97 + i}) + ': Success=' + responses[i].success + 
                ', Records=' + responses[i].totalRecordCount + ', Message=' + responses[i].message);
}
System.debug('CPU Usage: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
System.debug('SOQL Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
System.debug('Query Rows: ' + Limits.getQueryRows() + '/' + Limits.getLimitQueries());
System.debug('==========================================');
