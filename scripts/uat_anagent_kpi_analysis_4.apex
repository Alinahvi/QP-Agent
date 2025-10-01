// UAT Test 4: ANAgentKPIsAnalysis - Different Actions
// Test Date: September 25, 2025
// Test Environment: Innovation Sandbox
// Test Scope: Testing different action types

// Test 4: Different Action Types
List<ANAGENTKPIAnalysisHandlerV3.Request> requests = new List<ANAGENTKPIAnalysisHandlerV3.Request>();

// Test 4a: CountFieldValues Action
ANAGENTKPIAnalysisHandlerV3.Request req4a = new ANAGENTKPIAnalysisHandlerV3.Request();
req4a.action = 'CountFieldValues';
req4a.OuName = 'AMER ACC';
req4a.countValuesForField = 'OU_NAME__c';
requests.add(req4a);

// Test 4b: GetDistinctFieldValues Action
ANAGENTKPIAnalysisHandlerV3.Request req4b = new ANAGENTKPIAnalysisHandlerV3.Request();
req4b.action = 'GetDistinctFieldValues';
req4b.fieldNameForValues = 'Primary Industry';
requests.add(req4b);

// Test 4c: GetSearchableFields Action
ANAGENTKPIAnalysisHandlerV3.Request req4c = new ANAGENTKPIAnalysisHandlerV3.Request();
req4c.action = 'GetSearchableFields';
requests.add(req4c);

// Test 4d: Search with Search Term
ANAGENTKPIAnalysisHandlerV3.Request req4d = new ANAGENTKPIAnalysisHandlerV3.Request();
req4d.action = 'Search';
req4d.OuName = 'EMEA ENTR';
req4d.searchTerm = 'John Smith';
req4d.recordLimit = 5;
requests.add(req4d);

List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(requests);

System.debug('=== UAT Test 4: Different Actions ===');
for (Integer i = 0; i < responses.size(); i++) {
    System.debug('Test 4' + String.fromCharArray(new List<Integer>{97 + i}) + ' (' + requests[i].action + '): Success=' + responses[i].success);
    if (responses[i].fieldValueCountsJSON != null) {
        System.debug('Field Value Counts: ' + responses[i].fieldValueCountsJSON);
    }
    if (responses[i].fieldValues != null && !responses[i].fieldValues.isEmpty()) {
        System.debug('Field Values: ' + responses[i].fieldValues);
    }
}
System.debug('CPU Usage: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
System.debug('SOQL Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
System.debug('Query Rows: ' + Limits.getQueryRows() + '/' + Limits.getLimitQueries());
System.debug('==========================================');
