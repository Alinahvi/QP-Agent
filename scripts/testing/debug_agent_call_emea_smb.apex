// Debug actual agent call for EMEA SMB
System.debug('=== DEBUGGING ACTUAL AGENT CALL FOR EMEA SMB ===');

try {
    // Create the exact same request the agent would make
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request.analysisType = 'MEETINGS';
    request.timeFrame = 'CURRENT';
    request.primaryDimension = 'OU_NAME__c';
    request.primaryValue = 'EMEA SMB';
    request.maxResults = 1000;
    request.includeLearnerProfile = true;
    request.fuzzySearchEnabled = true;
    
    System.debug('Request: ' + JSON.serialize(request));
    
    // Call the handler
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
        System.debug('Response Success: ' + response.success);
        System.debug('Response Message: ' + response.message);
        System.debug('Total Records: ' + response.totalRecordCount);
        System.debug('Total AEs: ' + response.totalAEs);
        System.debug('Total Meetings: ' + response.totalMeetings);
        System.debug('OU Name: ' + response.ouName);
        System.debug('Country: ' + response.country);
        System.debug('Analysis Type: ' + response.analysisType);
        System.debug('Time Frame: ' + response.timeFrame);
    } else {
        System.debug('No response received');
    }
    
} catch (Exception e) {
    System.debug('Error calling agent: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Also test the service directly
System.debug('\n=== TESTING SERVICE DIRECTLY ===');
try {
    ANAgentKPIAnalysisService.KPIAnalysisRequest serviceRequest = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    serviceRequest.analysisType = 'MEETINGS';
    serviceRequest.timeFrame = 'CURRENT';
    serviceRequest.ouName = 'EMEA SMB';
    serviceRequest.maxResults = 1000;
    serviceRequest.includeLearnerProfile = true;
    serviceRequest.fuzzySearchEnabled = true;
    
    System.debug('Service Request: ' + JSON.serialize(serviceRequest));
    
    List<ANAgentKPIAnalysisService.KPIAnalysisResponse> serviceResponses = 
        ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{serviceRequest});
    
    if (!serviceResponses.isEmpty()) {
        ANAgentKPIAnalysisService.KPIAnalysisResponse serviceResponse = serviceResponses[0];
        System.debug('Service Response Success: ' + serviceResponse.success);
        System.debug('Service Response Message: ' + serviceResponse.message);
        System.debug('Service Total Records: ' + serviceResponse.totalRecordCount);
        System.debug('Service OU Name: ' + serviceResponse.ouName);
        System.debug('Service Country: ' + serviceResponse.country);
    } else {
        System.debug('No service response received');
    }
    
} catch (Exception e) {
    System.debug('Error calling service: ' + e.getMessage());
    System.debug('Service stack trace: ' + e.getStackTraceString());
}
