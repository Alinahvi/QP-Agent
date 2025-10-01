// UAT Test 1: ANAgentKPIsAnalysis - Basic KPI Analysis
// Test Date: September 25, 2025
// Test Environment: Innovation Sandbox
// Test Scope: Basic KPI analysis functionality

// Test 1: Basic KPI Analysis for AMER ACC
List<ANAGENTKPIAnalysisHandlerV3.Request> requests = new List<ANAGENTKPIAnalysisHandlerV3.Request>();
ANAGENTKPIAnalysisHandlerV3.Request req1 = new ANAGENTKPIAnalysisHandlerV3.Request();
req1.action = 'Search';
req1.OuName = 'AMER ACC';
req1.recordLimit = 10;
requests.add(req1);

List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(requests);

System.debug('=== UAT Test 1: Basic KPI Analysis for AMER ACC ===');
System.debug('Request: ' + JSON.serialize(req1));
System.debug('Response Count: ' + responses.size());
if (!responses.isEmpty()) {
    System.debug('Success: ' + responses[0].success);
    System.debug('Message: ' + responses[0].message);
    System.debug('Total Record Count: ' + responses[0].totalRecordCount);
    System.debug('KPI Records: ' + responses[0].kpiRecords.size());
}
System.debug('CPU Usage: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
System.debug('SOQL Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
System.debug('Query Rows: ' + Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
System.debug('==========================================');
