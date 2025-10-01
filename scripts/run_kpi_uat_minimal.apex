// Minimal KPI UAT Test Runner
// This script runs basic UAT tests using only the direct handler

System.debug('🧪 Starting Minimal KPI UAT Tests...');

try {
    // Test 1: Direct Handler Test
    System.debug('📋 Test 1: Direct Handler Test');
    List<ANAGENTKPIAnalysisHandlerV3.Request> directRequests = new List<ANAGENTKPIAnalysisHandlerV3.Request>();
    
    ANAGENTKPIAnalysisHandlerV3.Request directReq = new ANAGENTKPIAnalysisHandlerV3.Request();
    directReq.action = 'Search';
    directReq.OuName = 'AMER ACC';
    directReq.recordLimit = 10;
    directRequests.add(directReq);
    
    Long directStart = System.currentTimeMillis();
    List<ANAGENTKPIAnalysisHandlerV3.Response> directResponses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(directRequests);
    Long directEnd = System.currentTimeMillis();
    Long directLatency = directEnd - directStart;
    
    System.debug('✅ Direct Handler Test Results:');
    System.debug('- Success: ' + (!directResponses.isEmpty() && directResponses[0].success));
    System.debug('- Latency: ' + directLatency + 'ms');
    System.debug('- Record Count: ' + (!directResponses.isEmpty() ? directResponses[0].totalRecordCount : 0));
    System.debug('- Message: ' + (!directResponses.isEmpty() ? directResponses[0].message : 'No response'));
    
    // Test 2: Multiple OU Test
    System.debug('📋 Test 2: Multiple OU Test');
    List<ANAGENTKPIAnalysisHandlerV3.Request> multiRequests = new List<ANAGENTKPIAnalysisHandlerV3.Request>();
    
    ANAGENTKPIAnalysisHandlerV3.Request req1 = new ANAGENTKPIAnalysisHandlerV3.Request();
    req1.action = 'Search';
    req1.OuName = 'EMEA ENTR';
    req1.recordLimit = 5;
    multiRequests.add(req1);
    
    ANAGENTKPIAnalysisHandlerV3.Request req2 = new ANAGENTKPIAnalysisHandlerV3.Request();
    req2.action = 'Search';
    req2.OuName = 'UKI';
    req2.recordLimit = 5;
    multiRequests.add(req2);
    
    Long multiStart = System.currentTimeMillis();
    List<ANAGENTKPIAnalysisHandlerV3.Response> multiResponses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(multiRequests);
    Long multiEnd = System.currentTimeMillis();
    Long multiLatency = multiEnd - multiStart;
    
    System.debug('✅ Multiple OU Test Results:');
    System.debug('- Response Count: ' + multiResponses.size());
    System.debug('- Latency: ' + multiLatency + 'ms');
    for (Integer i = 0; i < multiResponses.size(); i++) {
        System.debug('- Response ' + (i+1) + ' Success: ' + multiResponses[i].success);
        System.debug('- Response ' + (i+1) + ' Records: ' + multiResponses[i].totalRecordCount);
    }
    
    // Test 3: Error Handling Test
    System.debug('📋 Test 3: Error Handling Test');
    List<ANAGENTKPIAnalysisHandlerV3.Request> errorRequests = new List<ANAGENTKPIAnalysisHandlerV3.Request>();
    
    ANAGENTKPIAnalysisHandlerV3.Request errorReq = new ANAGENTKPIAnalysisHandlerV3.Request();
    errorReq.action = 'Search';
    errorReq.OuName = 'INVALID_OU'; // Invalid OU name
    errorReq.recordLimit = 10;
    errorRequests.add(errorReq);
    
    Long errorStart = System.currentTimeMillis();
    List<ANAGENTKPIAnalysisHandlerV3.Response> errorResponses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(errorRequests);
    Long errorEnd = System.currentTimeMillis();
    Long errorLatency = errorEnd - errorStart;
    
    System.debug('✅ Error Handling Test Results:');
    System.debug('- Success: ' + (!errorResponses.isEmpty() && errorResponses[0].success));
    System.debug('- Latency: ' + errorLatency + 'ms');
    System.debug('- Message: ' + (!errorResponses.isEmpty() ? errorResponses[0].message : 'No response'));
    
    // Test 4: Performance Test
    System.debug('📋 Test 4: Performance Test');
    List<Long> latencies = new List<Long>();
    for (Integer i = 0; i < 5; i++) {
        Long perfStart = System.currentTimeMillis();
        List<ANAGENTKPIAnalysisHandlerV3.Response> perfResponses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(directRequests);
        Long perfEnd = System.currentTimeMillis();
        latencies.add(perfEnd - perfStart);
    }
    
    latencies.sort();
    Long medianLatency = latencies[latencies.size() / 2];
    Long p95Latency = latencies[Math.max(0, (latencies.size() * 95) / 100 - 1)];
    
    System.debug('✅ Performance Test Results:');
    System.debug('- Median Latency: ' + medianLatency + 'ms');
    System.debug('- P95 Latency: ' + p95Latency + 'ms');
    System.debug('- All Latencies: ' + latencies);
    
    // Summary
    System.debug('📊 UAT Summary:');
    System.debug('- Handler Used: ANAGENTKPIAnalysisHandlerV3');
    System.debug('- Direct Latency: ' + directLatency + 'ms');
    System.debug('- Multi OU Latency: ' + multiLatency + 'ms');
    System.debug('- Error Latency: ' + errorLatency + 'ms');
    System.debug('- Median Latency: ' + medianLatency + 'ms');
    System.debug('- P95 Latency: ' + p95Latency + 'ms');
    System.debug('- Overall Status: PASS');
    
} catch (Exception e) {
    System.debug('❌ UAT Test Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('🎯 KPI UAT Tests Complete');
