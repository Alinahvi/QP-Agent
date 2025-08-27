// Smoke test for V2 KPI Analysis Service
ANAgentKPIAnalysisV2Service.Request r = new ANAgentKPIAnalysisV2Service.Request();
r.metricKey = 'ACV';
r.timeframe = 'CURRENT';
r.groupByDim = 'COUNTRY';
r.filter = 'country IN ("US","Brazil") AND tenure_months >= 6';
r.restrictInValuesCsv = 'US,Brazil';
r.limitN = 5;
r.perAENormalize = true;

List<ANAgentKPIAnalysisV2Service.Response> resp = 
    ANAgentKPIAnalysisV2Handler.run(new List<ANAgentKPIAnalysisV2Service.Request>{ r });

System.debug('=== V2 Service Smoke Test ===');
System.debug('Request: ' + r);
System.debug('Response: ' + resp);
System.debug('JSON: ' + JSON.serializePretty(resp));

// Test with empty request
List<ANAgentKPIAnalysisV2Service.Response> emptyResp = 
    ANAgentKPIAnalysisV2Handler.run(new List<ANAgentKPIAnalysisV2Service.Request>());

System.debug('=== Empty Request Test ===');
System.debug('Empty Response: ' + emptyResp);
System.debug('Empty JSON: ' + JSON.serializePretty(emptyResp)); 