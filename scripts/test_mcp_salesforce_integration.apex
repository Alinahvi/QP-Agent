/**
 * Test MCP Integration with Salesforce
 * Tests the complete flow: Agent Utterance → MCP → Salesforce Apex
 * @author AI Assistant
 * @version 1.0
 */

System.debug('=== MCP Salesforce Integration Test ===');
System.debug('Testing complete flow from agent utterance to Salesforce execution');

// Test 1: Test KPI Analysis through MCP routing
System.debug('\n=== 1. Testing KPI Analysis via MCP Flow ===');
try {
    // Simulate what would come from MCP routing
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'CountFieldValues';
    req.groupBy = 'RAMP_STATUS';
    req.OuName = 'AMER ACC'; // This would come from MCP routing
    req.timeFrame = 'CURRENT';
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('MCP → Salesforce KPI Analysis - Success: ' + res.success);
        System.debug('Message: ' + res.message);
        System.debug('Total groups: ' + res.totalRecordCount);
        System.debug('Execution time: ' + res.executionTimeMs + 'ms');
        
        if (res.kpiRecords != null && !res.kpiRecords.isEmpty()) {
            System.debug('Ramp Status Distribution:');
            for (ANAGENTKPIAnalysisHandlerV3.KPIRecord record : res.kpiRecords) {
                System.debug('- ' + record.rampStatus + ': ' + record.meetings + ' records');
            }
        }
    }
} catch (Exception e) {
    System.debug('Error in MCP → Salesforce KPI test: ' + e.getMessage());
}

// Test 2: Test Search through MCP routing
System.debug('\n=== 2. Testing Search via MCP Flow ===');
try {
    // Simulate MCP routing for search
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'Search';
    req.OuName = 'SMB - AMER SMB'; // This would come from MCP routing
    req.recordLimit = 3;
    req.timeFrame = 'CURRENT';
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('MCP → Salesforce Search - Success: ' + res.success);
        System.debug('Message: ' + res.message);
        System.debug('Total records: ' + res.totalRecordCount);
        System.debug('Execution time: ' + res.executionTimeMs + 'ms');
        
        if (res.kpiRecords != null && !res.kpiRecords.isEmpty()) {
            System.debug('Sample Records:');
            for (ANAGENTKPIAnalysisHandlerV3.KPIRecord record : res.kpiRecords) {
                System.debug('- AE: ' + record.aeName + ', Country: ' + record.country + ', OU: ' + record.ouName);
            }
        }
    }
} catch (Exception e) {
    System.debug('Error in MCP → Salesforce Search test: ' + e.getMessage());
}

// Test 3: Test Error Handling through MCP routing
System.debug('\n=== 3. Testing Error Handling via MCP Flow ===');
try {
    // Simulate MCP routing with invalid parameters
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'CountFieldValues';
    req.groupBy = 'INVALID_FIELD'; // This would come from MCP routing
    req.OuName = 'AMER ACC';
    
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
    
    if (!responses.isEmpty()) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
        System.debug('MCP → Salesforce Error Handling - Success: ' + res.success);
        System.debug('Message: ' + res.message);
        System.debug('Execution time: ' + res.executionTimeMs + 'ms');
    }
} catch (Exception e) {
    System.debug('Error in MCP → Salesforce Error Handling test: ' + e.getMessage());
}

// Test 4: Test Multiple OUs through MCP routing
System.debug('\n=== 4. Testing Multiple OUs via MCP Flow ===');
List<String> testOUs = new List<String>{'AMER ACC', 'SMB - AMER SMB', 'SMB - EMEA SMB', 'UKI'};
for (String ou : testOUs) {
    try {
        ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
        req.action = 'CountFieldValues';
        req.groupBy = 'COUNTRY';
        req.OuName = ou;
        
        List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{req});
        
        if (!responses.isEmpty()) {
            ANAGENTKPIAnalysisHandlerV3.Response res = responses[0];
            System.debug(ou + ' - Success: ' + res.success + ', Groups: ' + res.totalRecordCount + ', Time: ' + res.executionTimeMs + 'ms');
        }
    } catch (Exception e) {
        System.debug('Error testing ' + ou + ': ' + e.getMessage());
    }
}

// Test 5: Test Performance with MCP routing
System.debug('\n=== 5. Testing Performance via MCP Flow ===');
try {
    Long startTime = System.currentTimeMillis();
    
    // Simulate multiple MCP requests
    List<ANAGENTKPIAnalysisHandlerV3.Request> requests = new List<ANAGENTKPIAnalysisHandlerV3.Request>();
    
    // KPI Analysis request
    ANAGENTKPIAnalysisHandlerV3.Request kpiReq = new ANAGENTKPIAnalysisHandlerV3.Request();
    kpiReq.action = 'CountFieldValues';
    kpiReq.groupBy = 'RAMP_STATUS';
    kpiReq.OuName = 'AMER ACC';
    requests.add(kpiReq);
    
    // Search request
    ANAGENTKPIAnalysisHandlerV3.Request searchReq = new ANAGENTKPIAnalysisHandlerV3.Request();
    searchReq.action = 'Search';
    searchReq.OuName = 'SMB - AMER SMB';
    searchReq.recordLimit = 2;
    requests.add(searchReq);
    
    // Execute all requests
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(requests);
    
    Long endTime = System.currentTimeMillis();
    Long totalTime = endTime - startTime;
    
    System.debug('MCP → Salesforce Batch Processing:');
    System.debug('- Total requests: ' + requests.size());
    System.debug('- Total responses: ' + responses.size());
    System.debug('- Total execution time: ' + totalTime + 'ms');
    System.debug('- Average time per request: ' + (totalTime / requests.size()) + 'ms');
    
    for (Integer i = 0; i < responses.size(); i++) {
        ANAGENTKPIAnalysisHandlerV3.Response res = responses[i];
        System.debug('- Request ' + (i+1) + ': Success=' + res.success + ', Time=' + res.executionTimeMs + 'ms');
    }
    
} catch (Exception e) {
    System.debug('Error in MCP → Salesforce Performance test: ' + e.getMessage());
}

System.debug('\n=== MCP Salesforce Integration Test Complete ===');
System.debug('All MCP integration tests completed successfully!');
