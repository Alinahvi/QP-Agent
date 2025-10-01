// UAT Test 2: ANAgentKPIsAnalysis - OU Name Variations
// Test Date: September 25, 2025
// Test Environment: Innovation Sandbox
// Test Scope: OU name normalization and variations

// Test 2: OU Name Variations (AMERACC vs AMER ACC)
List<ANAGENTKPIAnalysisHandlerV3.Request> requests = new List<ANAGENTKPIAnalysisHandlerV3.Request>();

// Test 2a: AMERACC (without space)
ANAGENTKPIAnalysisHandlerV3.Request req2a = new ANAGENTKPIAnalysisHandlerV3.Request();
req2a.action = 'Search';
req2a.OuName = 'AMERACC';
req2a.recordLimit = 5;
requests.add(req2a);

// Test 2b: AMER ACC (with space)
ANAGENTKPIAnalysisHandlerV3.Request req2b = new ANAGENTKPIAnalysisHandlerV3.Request();
req2b.action = 'Search';
req2b.OuName = 'AMER ACC';
req2b.recordLimit = 5;
requests.add(req2b);

// Test 2c: EMEA ENTR
ANAGENTKPIAnalysisHandlerV3.Request req2c = new ANAGENTKPIAnalysisHandlerV3.Request();
req2c.action = 'Search';
req2c.OuName = 'EMEA ENTR';
req2c.recordLimit = 5;
requests.add(req2c);

List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(requests);

System.debug('=== UAT Test 2: OU Name Variations ===');
System.debug('Test 2a - AMERACC: Success=' + responses[0].success + ', Records=' + responses[0].totalRecordCount);
System.debug('Test 2b - AMER ACC: Success=' + responses[1].success + ', Records=' + responses[1].totalRecordCount);
System.debug('Test 2c - EMEA ENTR: Success=' + responses[2].success + ', Records=' + responses[2].totalRecordCount);
System.debug('CPU Usage: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
System.debug('SOQL Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
System.debug('Query Rows: ' + Limits.getQueryRows() + '/' + Limits.getLimitQueries());
System.debug('==========================================');
