// Test V5 handler for growth factors
System.debug('=== TESTING V5 HANDLER FOR GROWTH FACTORS ===');

try {
    ANAGENTKPIAnalysisHandlerV5.Request req = new ANAGENTKPIAnalysisHandlerV5.Request();
    req.metricKey = 'GROWTH_FACTOR';
    req.timeframe = 'CURRENT';
    req.groupBy = 'GROWTH_FACTOR';
    req.filterCriteria = 'ou_name__c=\'AMER ACC\'';
    req.limitN = 10;
    req.aggregationType = 'COUNT';
    
    List<ANAGENTKPIAnalysisHandlerV5.Request> requests = new List<ANAGENTKPIAnalysisHandlerV5.Request>{req};
    List<ANAGENTKPIAnalysisHandlerV5.Response> responses = ANAGENTKPIAnalysisHandlerV5.analyzeKPIs(requests);
    
    System.debug('V5 Handler Result: ' + responses[0].message);
    System.debug('Success: ' + responses[0].success);
    System.debug('Total Records: ' + responses[0].totalRecordCount);
    
    if (responses[0].kpiRecords != null) {
        System.debug('KPI Records: ' + responses[0].kpiRecords.size());
        for (ANAGENTKPIAnalysisHandlerV5.KPIRecord record : responses[0].kpiRecords) {
            System.debug('  - ' + record.aeName + ' | ' + record.ouName + ' | ' + record.industry);
        }
    }
} catch (Exception e) {
    System.debug('V5 Handler Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

// Also test the service directly
System.debug('\n=== TESTING V5 SERVICE DIRECTLY ===');
try {
    String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs('GROWTH_FACTOR', 'CURRENT', 'GROWTH_FACTOR', 'ou_name__c=\'AMER ACC\'', null, false, 10, 'COUNT');
    System.debug('V5 Service Result: ' + result);
} catch (Exception e) {
    System.debug('V5 Service Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
