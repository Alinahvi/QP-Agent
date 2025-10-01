// Check what KPI handlers are available
System.debug('=== CHECKING AVAILABLE KPI HANDLERS ===');

// Check if V5 classes exist
try {
    ANAGENTKPIAnalysisHandlerV5.Request testReq = new ANAGENTKPIAnalysisHandlerV5.Request();
    System.debug('✅ ANAGENTKPIAnalysisHandlerV5 exists');
} catch (Exception e) {
    System.debug('❌ ANAGENTKPIAnalysisHandlerV5 not found: ' + e.getMessage());
}

try {
    ANAGENTKPIAnalysisServiceV5 testService = new ANAGENTKPIAnalysisServiceV5();
    System.debug('✅ ANAGENTKPIAnalysisServiceV5 exists');
} catch (Exception e) {
    System.debug('❌ ANAGENTKPIAnalysisServiceV5 not found: ' + e.getMessage());
}

// Check V3 handler
try {
    ANAGENTKPIAnalysisHandlerV3.Request testReq = new ANAGENTKPIAnalysisHandlerV3.Request();
    System.debug('✅ ANAGENTKPIAnalysisHandlerV3 exists');
} catch (Exception e) {
    System.debug('❌ ANAGENTKPIAnalysisHandlerV3 not found: ' + e.getMessage());
}

// Test V3 handler with growth factors
System.debug('\n=== TESTING V3 HANDLER WITH GROWTH FACTORS ===');
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'Search';
    req.OuName = 'AMER ACC';
    req.metricKey = 'MEETINGS'; // Use a valid metric
    req.timeFrame = 'CURRENT';
    req.groupBy = 'OU';
    req.recordLimit = 10;
    
    List<ANAGENTKPIAnalysisHandlerV3.Request> requests = new List<ANAGENTKPIAnalysisHandlerV3.Request>{req};
    List<ANAGENTKPIAnalysisHandlerV3.Response> responses = ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(requests);
    
    System.debug('V3 Handler Result: ' + responses[0].message);
    System.debug('Success: ' + responses[0].success);
    System.debug('Total Records: ' + responses[0].totalRecordCount);
} catch (Exception e) {
    System.debug('V3 Handler Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
