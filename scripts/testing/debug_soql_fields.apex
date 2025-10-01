// Debug what fields are being queried by the ANAgentKPIAnalysisHandler
System.debug('=== DEBUGGING SOQL FIELDS ===');

// Test a simple query to see what fields are available
try {
    List<AGENT_OU_PIPELINE_V2__c> testRecords = [
        SELECT Id, EMP_ID__c, FULL_NAME__c, OU_NAME__c, DEFINITION__c, DESCRIPTION__c, ACTIONABLE__c, 
               CQ_CUSTOMER_MEETING__c, CQ_CALL_CONNECT__c, CQ_ACV__c, CQ_PG__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c = 'AMER ACC' 
        AND DEFINITION__c != null
        LIMIT 5
    ];
    
    System.debug('Test query successful, found ' + testRecords.size() + ' records');
    for (AGENT_OU_PIPELINE_V2__c record : testRecords) {
        System.debug('  - ' + record.FULL_NAME__c + ' | ' + record.DEFINITION__c + ' | ' + record.ACTIONABLE__c);
    }
} catch (Exception e) {
    System.debug('Test query error: ' + e.getMessage());
}

// Now test the handler to see what error we get
System.debug('\n=== TESTING HANDLER WITH MINIMAL REQUEST ===');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request.analysisType = 'GROWTH_FACTORS';
    request.primaryDimension = 'OU_NAME';
    request.primaryValue = 'AMER ACC';
    request.includeDetails = false; // Try without details first
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request });
    
    System.debug('Handler Response: ' + responses[0].message);
    System.debug('Success: ' + responses[0].success);
} catch (Exception e) {
    System.debug('Handler Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
