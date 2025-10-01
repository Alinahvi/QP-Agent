// Test the existing service to see if our fixes work
System.debug('=== TESTING EXISTING SERVICE WITH AMER ACC ===');

try {
    // Test GROWTH_FACTORS analysis for AMER ACC using the existing service
    System.debug('\\n=== TESTING GROWTH_FACTORS ANALYSIS ===');
    
    String result = ANAgentKPIAnalysisService.analyzeKPIs('GROWTH_FACTORS', 'CURRENT', 'GROWTH_FACTOR', 
                                                         'ou_name__c=\'AMER ACC\'', null, false, 10, 'COUNT');
    
    System.debug('✅ GROWTH_FACTORS Analysis Result:');
    System.debug('Result: ' + result);
    
    // Check if we get the missing field error
    if (result.contains('SObject row was retrieved via SOQL without querying the requested field')) {
        System.debug('❌ Still getting missing field error - service needs to be updated');
    } else if (result.contains('Error')) {
        System.debug('⚠️  Got error but not missing field error: ' + result);
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
    
    String meetingResult = ANAgentKPIAnalysisService.analyzeKPIs('MEETINGS', 'CURRENT', 'MEETINGS', 
                                                                'ou_name__c=\'AMER ACC\'', null, false, 10, 'COUNT');
    
    System.debug('✅ MEETINGS Analysis Result:');
    System.debug('Result: ' + meetingResult);
    
    // Check if we get the missing field error
    if (meetingResult.contains('SObject row was retrieved via SOQL without querying the requested field')) {
        System.debug('❌ Still getting missing field error for meetings - service needs to be updated');
    } else if (meetingResult.contains('Error')) {
        System.debug('⚠️  Got error but not missing field error: ' + meetingResult);
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
    
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request.analysisType = 'GROWTH_FACTORS';
    request.primaryDimension = 'OU_NAME';
    request.primaryValue = 'AMER ACC';
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
    
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
