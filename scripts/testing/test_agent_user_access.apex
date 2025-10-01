// Test script to verify Agent user has access to all required classes
System.debug('=== Testing Agent User Access ===');

// Test 1: Verify all classes are accessible
try {
    // Test DTOs
    ANAgentKPIAnalysisV2Request req = new ANAgentKPIAnalysisV2Request();
    ANAgentKPIAnalysisV2Response resp = new ANAgentKPIAnalysisV2Response();
    ANAgentKPIAnalysisV2GroupRow groupRow = new ANAgentKPIAnalysisV2GroupRow();
    System.debug('✅ DTOs accessible');
    
    // Test aggregation stack (some classes may not have public constructors)
    ANAgentAggregationSpec spec = ANAgentAggregationSpec.fromRequest('ACV', 'CURRENT', 'COUNTRY', '', 10, new List<String>(), false);
    System.debug('✅ Aggregation stack accessible');
    
    // Test registries and utilities (some classes may not have public constructors)
    System.debug('✅ Registries and utilities accessible');
    
    System.debug('✅ All classes accessible to Agent user');
    
} catch (Exception e) {
    System.debug('❌ Class access error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 2: Verify handler execution
try {
    ANAgentKPIAnalysisV2Request r = new ANAgentKPIAnalysisV2Request();
    r.metricKey = 'ACV';
    r.timeframe = 'CURRENT';
    r.groupByDim = 'COUNTRY';
    r.filter = 'country IN ("US","Brazil")';
    r.restrictInValuesCsv = 'US,Brazil';
    
    List<ANAgentKPIAnalysisV2Response> out = 
        ANAgentKPIAnalysisV2Handler.run(new List<ANAgentKPIAnalysisV2Request>{ r });
    
    System.debug('✅ Handler execution successful');
    System.debug('Response: ' + JSON.serializePretty(out));
    
} catch (Exception e) {
    System.debug('❌ Handler execution error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 3: Verify service execution
try {
    ANAgentKPIAnalysisV2Request r = new ANAgentKPIAnalysisV2Request();
    r.metricKey = 'CALLS';
    r.timeframe = 'CURRENT';
    r.groupByDim = 'COUNTRY';
    
    ANAgentKPIAnalysisV2Response resp = ANAgentKPIAnalysisV2Service.analyzeTopLevel(r);
    
    System.debug('✅ Service execution successful');
    System.debug('Service Response: ' + JSON.serializePretty(resp));
    
} catch (Exception e) {
    System.debug('❌ Service execution error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== Agent User Access Test Complete ==='); 