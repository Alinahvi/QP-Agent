// Test KPI analysis as Agent user to identify specific issues
System.debug('=== Testing KPI Analysis as Agent User ===');

try {
    // Test the KPI analysis
    ANAgentKPIAnalysisV2Request r = new ANAgentKPIAnalysisV2Request();
    r.metricKey = 'ACV';
    r.timeframe = 'CURRENT';
    r.groupByDim = 'COUNTRY';
    r.filter = 'country IN ("US","Brazil")';
    r.restrictInValuesCsv = 'US,Brazil';
    
    System.debug('Request: ' + r);
    
    List<ANAgentKPIAnalysisV2Response> out = 
        ANAgentKPIAnalysisV2Handler.run(new List<ANAgentKPIAnalysisV2Request>{ r });
    
    System.debug('✅ KPI Analysis successful');
    System.debug('Response: ' + JSON.serializePretty(out));
    
} catch (Exception e) {
    System.debug('❌ KPI Analysis failed');
    System.debug('Error: ' + e.getMessage());
    System.debug('Type: ' + e.getTypeName());
    System.debug('Stack trace: ' + e.getStackTraceString());
    
    // Try to identify the specific issue
    if (e.getMessage().contains('Permission')) {
        System.debug('🔒 This appears to be a permission issue');
    } else if (e.getMessage().contains('Object') || e.getMessage().contains('Field')) {
        System.debug('📊 This appears to be a data access issue');
    } else if (e.getMessage().contains('Method') || e.getMessage().contains('Class')) {
        System.debug('🔧 This appears to be a class/method access issue');
    }
}

System.debug('=== KPI Agent User Test Complete ==='); 