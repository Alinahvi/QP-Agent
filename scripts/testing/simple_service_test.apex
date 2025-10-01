// Simple test of the existing service
System.debug('=== SIMPLE SERVICE TEST ===');

try {
    // Test GROWTH_FACTORS analysis for AMER ACC using the existing service
    System.debug('\\n=== TESTING GROWTH_FACTORS ANALYSIS ===');
    
    // Create a request object
    ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request.analysisType = 'GROWTH_FACTORS';
    request.primaryDimension = 'OU_NAME';
    request.primaryValue = 'AMER ACC';
    request.timeFrame = 'CURRENT';
    request.maxResults = 10;
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response = ANAgentKPIAnalysisService.analyzeKPIs(request);
    
    System.debug('✅ GROWTH_FACTORS Analysis Result:');
    System.debug('  - Success: ' + response.success);
    System.debug('  - Message: ' + response.message);
    
    // Check if we get the missing field error
    if (response.message.contains('SObject row was retrieved via SOQL without querying the requested field')) {
        System.debug('❌ Still getting missing field error - service needs to be updated');
    } else if (response.message.contains('Error')) {
        System.debug('⚠️  Got error but not missing field error: ' + response.message);
    } else {
        System.debug('✅ No missing field error - service may already be fixed');
    }
    
} catch (Exception e) {
    System.debug('❌ GROWTH_FACTORS Analysis Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
