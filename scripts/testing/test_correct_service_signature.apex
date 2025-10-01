// Test the existing service with correct method signature
System.debug('=== TESTING EXISTING SERVICE WITH CORRECT SIGNATURE ===');

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
    System.debug('  - Total Records: ' + response.totalRecordCount);
    
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

// Test MEETINGS analysis
try {
    System.debug('\\n=== TESTING MEETINGS ANALYSIS ===');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest meetingRequest = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    meetingRequest.analysisType = 'MEETINGS';
    meetingRequest.primaryDimension = 'OU_NAME';
    meetingRequest.primaryValue = 'AMER ACC';
    meetingRequest.timeFrame = 'CURRENT';
    meetingRequest.maxResults = 10;
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse meetingResponse = ANAgentKPIAnalysisService.analyzeKPIs(meetingRequest);
    
    System.debug('✅ MEETINGS Analysis Result:');
    System.debug('  - Success: ' + meetingResponse.success);
    System.debug('  - Message: ' + meetingResponse.message);
    System.debug('  - Total Records: ' + meetingResponse.totalRecordCount);
    
    // Check if we get the missing field error
    if (meetingResponse.message.contains('SObject row was retrieved via SOQL without querying the requested field')) {
        System.debug('❌ Still getting missing field error for meetings - service needs to be updated');
    } else if (meetingResponse.message.contains('Error')) {
        System.debug('⚠️  Got error but not missing field error: ' + meetingResponse.message);
    } else {
        System.debug('✅ No missing field error for meetings - service may already be fixed');
    }
    
} catch (Exception e) {
    System.debug('❌ MEETINGS Analysis Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

// Test with the handler
try {
    System.debug('\\n=== TESTING HANDLER ===');
    
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest handlerRequest = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    handlerRequest.analysisType = 'GROWTH_FACTORS';
    handlerRequest.primaryDimension = 'OU_NAME';
    handlerRequest.primaryValue = 'AMER ACC';
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{handlerRequest});
    
    if (!responses.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
        System.debug('✅ Handler Result:');
        System.debug('  - Success: ' + response.success);
        System.debug('  - Message: ' + response.message);
        System.debug('  - Total Records: ' + response.totalRecordCount);
        
        // Check if we get the missing field error
        if (response.message.contains('SObject row was retrieved via SOQL without querying the requested field')) {
            System.debug('❌ Handler still getting missing field error - service needs to be updated');
        } else if (response.message.contains('Error')) {
            System.debug('⚠️  Handler got error but not missing field error: ' + response.message);
        } else {
            System.debug('✅ Handler no missing field error - service may already be fixed');
        }
    } else {
        System.debug('❌ No responses from handler');
    }
    
} catch (Exception e) {
    System.debug('❌ Handler Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
