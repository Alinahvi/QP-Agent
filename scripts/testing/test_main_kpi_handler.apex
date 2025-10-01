// Check what ANAgentKPIAnalysisHandler looks like
System.debug('=== CHECKING ANAgentKPIAnalysisHandler ===');

try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest testReq = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    System.debug('✅ ANAgentKPIAnalysisHandler exists');
    System.debug('Request class: ' + testReq);
} catch (Exception e) {
    System.debug('❌ ANAgentKPIAnalysisHandler not found: ' + e.getMessage());
}

// Test it with AMER ACC
System.debug('\n=== TESTING ANAgentKPIAnalysisHandler WITH AMER ACC ===');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request.analysisType = 'MEETINGS';
    request.primaryDimension = 'OU_NAME';
    request.primaryValue = 'AMER ACC';
    request.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request });
    
    System.debug('Response: ' + responses[0].message);
    System.debug('Success: ' + responses[0].success);
    System.debug('Total Records: ' + responses[0].totalRecords);
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

// Test growth factors specifically
System.debug('\n=== TESTING GROWTH FACTORS WITH ANAgentKPIAnalysisHandler ===');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request.analysisType = 'GROWTH_FACTORS';
    request.primaryDimension = 'OU_NAME';
    request.primaryValue = 'AMER ACC';
    request.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request });
    
    System.debug('Growth Factor Response: ' + responses[0].message);
    System.debug('Success: ' + responses[0].success);
    System.debug('Total Records: ' + responses[0].totalRecords);
} catch (Exception e) {
    System.debug('Growth Factor Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
