// Test the new simplified ANAgentKPIAnalysisService
System.debug('=== TESTING NEW ANAgentKPIAnalysisService ===');

try {
    // Test GROWTH_FACTORS analysis for AMER ACC
    ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request.analysisType = 'GROWTH_FACTORS';
    request.ouName = 'AMER ACC';
    request.timeFrame = 'CURRENT';
    request.maxResults = 10;
    
    System.debug('Testing GROWTH_FACTORS for AMER ACC...');
    List<ANAgentKPIAnalysisService.KPIAnalysisResponse> responses = ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentKPIAnalysisService.KPIAnalysisResponse response = responses[0];
        System.debug('✅ SUCCESS! Analysis completed');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Analysis Type: ' + response.analysisType);
        System.debug('OU Name: ' + response.ouName);
        System.debug('Total AEs: ' + response.totalAEs);
        System.debug('Total Record Count: ' + response.totalRecordCount);
        System.debug('Average Coverage: ' + response.avgCoverage);
        System.debug('Total ACV: ' + response.totalACV);
        System.debug('Total PG: ' + response.totalPG);
        
        if (response.warnings != null && !response.warnings.isEmpty()) {
            System.debug('Warnings:');
            for (String warning : response.warnings) {
                System.debug('  - ' + warning);
            }
        } else {
            System.debug('No warnings');
        }
    } else {
        System.debug('❌ No responses returned');
    }
    
    // Test MEETINGS analysis
    System.debug('\n=== TESTING MEETINGS ANALYSIS ===');
    ANAgentKPIAnalysisService.KPIAnalysisRequest request2 = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request2.analysisType = 'MEETINGS';
    request2.ouName = 'AMER ACC';
    request2.timeFrame = 'CURRENT';
    request2.maxResults = 5;
    
    List<ANAgentKPIAnalysisService.KPIAnalysisResponse> responses2 = ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{request2});
    
    if (!responses2.isEmpty()) {
        ANAgentKPIAnalysisService.KPIAnalysisResponse response2 = responses2[0];
        System.debug('✅ MEETINGS Analysis completed');
        System.debug('Total AEs: ' + response2.totalAEs);
        System.debug('Total Meetings: ' + response2.totalMeetings);
        System.debug('Total Call Connects: ' + response2.totalCallConnects);
        System.debug('Average Coverage: ' + response2.avgCoverage);
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing service: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
