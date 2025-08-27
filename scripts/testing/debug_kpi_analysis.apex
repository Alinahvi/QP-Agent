/**
 * Debug KPI Analysis
 * Step through the process to find where it's failing
 */

System.debug('=== DEBUGGING KPI ANALYSIS ===');

try {
    // Test 1: Simple Coverage Query
    System.debug('--- TEST 1: Simple Coverage Query ---');
    
    String query1 = 'SELECT Id, COVERAGE__c, VAL_QUOTA__c FROM AGENT_OU_PIPELINE_V2__c WHERE OU_NAME__c = \'SMB - EMEA SMB\' AND COVERAGE__c != null LIMIT 5';
    System.debug('Query 1: ' + query1);
    
    List<AGENT_OU_PIPELINE_V2__c> records1 = Database.query(query1);
    System.debug('Records found: ' + records1.size());
    for (AGENT_OU_PIPELINE_V2__c record : records1) {
        System.debug('Coverage: ' + record.COVERAGE__c + ', Quota: ' + record.VAL_QUOTA__c);
    }
    
    // Test 2: Simple Ramp Status Query
    System.debug('\n--- TEST 2: Simple Ramp Status Query ---');
    
    String query2 = 'SELECT Id, RAMP_STATUS__c, TIME_SINCE_ONBOARDING__c FROM AGENT_OU_PIPELINE_V2__c WHERE PRIMARY_INDUSTRY__c = \'Technology\' AND RAMP_STATUS__c != null LIMIT 5';
    System.debug('Query 2: ' + query2);
    
    List<AGENT_OU_PIPELINE_V2__c> records2 = Database.query(query2);
    System.debug('Records found: ' + records2.size());
    for (AGENT_OU_PIPELINE_V2__c record : records2) {
        System.debug('Ramp Status: ' + record.RAMP_STATUS__c + ', Time Since Onboarding: ' + record.TIME_SINCE_ONBOARDING__c);
    }
    
    // Test 3: Simple Growth Factors Query
    System.debug('\n--- TEST 3: Simple Growth Factors Query ---');
    
    String query3 = 'SELECT Id, DEFINITION__c, ACTIONABLE__c FROM AGENT_OU_PIPELINE_V2__c WHERE EMP_ID__c = \'784466\' AND DEFINITION__c != null LIMIT 5';
    System.debug('Query 3: ' + query3);
    
    List<AGENT_OU_PIPELINE_V2__c> records3 = Database.query(query3);
    System.debug('Records found: ' + records3.size());
    for (AGENT_OU_PIPELINE_V2__c record : records3) {
        System.debug('Definition: ' + record.DEFINITION__c + ', Actionable: ' + record.ACTIONABLE__c);
    }
    
    // Test 4: Test the KPI Analysis Service directly
    System.debug('\n--- TEST 4: Test KPI Analysis Service Directly ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request.analysisType = 'COVERAGE';
    request.primaryDimension = 'OU_NAME';
    request.primaryValue = 'SMB - EMEA SMB';
    request.includeDetails = true;
    
    System.debug('Request: ' + request);
    
    try {
        ANAgentKPIAnalysisService.KPIAnalysisResponse response = ANAgentKPIAnalysisService.analyzeKPIs(request);
        System.debug('Response Success: ' + response.success);
        System.debug('Response Total Records: ' + response.totalRecords);
        System.debug('Response Total Value: ' + response.totalValue);
        System.debug('Response Message: ' + response.message);
    } catch (Exception e) {
        System.debug('Service Exception: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== KPI ANALYSIS DEBUG COMPLETED ==='); 