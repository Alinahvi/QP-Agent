// Test the complete KPI Analysis system
// This script tests both the service and handler together

System.debug('=== COMPLETE KPI ANALYSIS SYSTEM TEST ===');

// Test 1: AMER ACC Growth Factors through Handler
System.debug('\n--- Test 1: AMER ACC Growth Factors via Handler ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request.analysisType = 'GROWTH_FACTORS';
    request.timeFrame = 'CURRENT';
    request.primaryDimension = 'OU_NAME__c';
    request.primaryValue = 'AMER ACC';
    request.maxResults = 10;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
    
    System.debug('Handler Response Count: ' + responses.size());
    if (!responses.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Total Records: ' + response.totalRecordCount);
        System.debug('OU Name: ' + response.ouName);
        System.debug('Total AEs: ' + response.totalAEs);
        System.debug('Avg Coverage: ' + response.avgCoverage);
        System.debug('Total ACV: ' + response.totalACV);
        System.debug('Total PG: ' + response.totalPG);
        System.debug('Warnings: ' + response.warnings);
    }
} catch (Exception e) {
    System.debug('Handler Test Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

// Test 2: AMER ACC Meetings through Handler
System.debug('\n--- Test 2: AMER ACC Meetings via Handler ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request.analysisType = 'MEETINGS';
    request.timeFrame = 'CURRENT';
    request.primaryDimension = 'OU_NAME__c';
    request.primaryValue = 'AMER ACC';
    request.maxResults = 10;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
    
    System.debug('Handler Response Count: ' + responses.size());
    if (!responses.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Total Records: ' + response.totalRecordCount);
        System.debug('Total Meetings: ' + response.totalMeetings);
        System.debug('Total Call Connects: ' + response.totalCallConnects);
        System.debug('Warnings: ' + response.warnings);
    }
} catch (Exception e) {
    System.debug('Handler Test Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

// Test 3: Direct Service Test for AMER ACC
System.debug('\n--- Test 3: Direct Service Test for AMER ACC ---');
try {
    ANAgentKPIAnalysisService.KPIAnalysisRequest serviceRequest = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    serviceRequest.analysisType = 'GROWTH_FACTORS';
    serviceRequest.timeFrame = 'CURRENT';
    serviceRequest.ouName = 'AMER ACC';
    serviceRequest.maxResults = 10;
    
    List<ANAgentKPIAnalysisService.KPIAnalysisResponse> serviceResponses = ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{serviceRequest});
    
    System.debug('Service Response Count: ' + serviceResponses.size());
    if (!serviceResponses.isEmpty()) {
        ANAgentKPIAnalysisService.KPIAnalysisResponse serviceResponse = serviceResponses[0];
        System.debug('Service Success: ' + serviceResponse.success);
        System.debug('Service Message: ' + serviceResponse.message);
        System.debug('Service Total Records: ' + serviceResponse.totalRecordCount);
        System.debug('Service OU Name: ' + serviceResponse.ouName);
        System.debug('Service Total AEs: ' + serviceResponse.totalAEs);
        System.debug('Service Avg Coverage: ' + serviceResponse.avgCoverage);
        System.debug('Service Warnings: ' + serviceResponse.warnings);
    }
} catch (Exception e) {
    System.debug('Service Test Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

// Test 4: Test different OUs
System.debug('\n--- Test 4: Test Different OUs ---');
List<String> testOUs = new List<String>{'AMER ACC', 'EMEA', 'APAC'};
for (String ou : testOUs) {
    try {
        ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
        request.analysisType = 'GROWTH_FACTORS';
        request.timeFrame = 'CURRENT';
        request.primaryDimension = 'OU_NAME__c';
        request.primaryValue = ou;
        request.maxResults = 5;
        
        List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
        
        if (!responses.isEmpty()) {
            ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
            System.debug('OU: ' + ou + ' - Success: ' + response.success + ', Records: ' + response.totalRecordCount);
        } else {
            System.debug('OU: ' + ou + ' - No responses');
        }
    } catch (Exception e) {
        System.debug('OU: ' + ou + ' - Error: ' + e.getMessage());
    }
}

System.debug('\n=== COMPLETE SYSTEM TEST FINISHED ===');
