// Test script for top-level DTOs
System.debug('=== Testing Top-Level DTOs ===');

// Test the new top-level request
ANAgentKPIAnalysisV2Request r = new ANAgentKPIAnalysisV2Request();
r.metricKey = 'ACV';
r.timeframe = 'CURRENT';
r.groupByDim = 'COUNTRY';
r.filter = 'country IN ("US","Brazil") AND tenure_months >= 6';
r.restrictInValuesCsv = 'US,Brazil';
r.limitN = 5;
r.perAENormalize = true;

System.debug('Request: ' + r);

// Test the handler with top-level DTOs
List<ANAgentKPIAnalysisV2Response> resp = 
    ANAgentKPIAnalysisV2Handler.run(new List<ANAgentKPIAnalysisV2Request>{ r });

System.debug('Response: ' + resp);
System.debug('JSON: ' + JSON.serializePretty(resp));

// Test empty request
List<ANAgentKPIAnalysisV2Response> emptyResp = 
    ANAgentKPIAnalysisV2Handler.run(new List<ANAgentKPIAnalysisV2Request>());

System.debug('=== Empty Request Test ===');
System.debug('Empty Response: ' + emptyResp);
System.debug('Empty JSON: ' + JSON.serializePretty(emptyResp)); 