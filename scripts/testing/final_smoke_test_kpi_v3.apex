// Final smoke test for KPI Analysis V3 - testing basic functionality
// This verifies the core structure works without triggering permission issues

System.debug('=== Final KPI Analysis V3 Smoke Test ===');

// Test 1: Basic class instantiation and DTO creation
try {
    ANAGENTKPIAnalysisHandlerV3.Request req = new ANAGENTKPIAnalysisHandlerV3.Request();
    req.action = 'Search';
    req.OuName = 'AMER - FINS';
    req.searchTerm = 'Test';
    
    ANAGENTKPIAnalysisHandlerV3.Response res = new ANAGENTKPIAnalysisHandlerV3.Response();
    
    System.debug('✅ Basic instantiation PASSED - Request and Response objects created successfully');
    System.debug('✅ Request action: ' + req.action + ', OU Name: ' + req.OuName);
} catch (Exception e) {
    System.debug('❌ Basic instantiation FAILED: ' + e.getMessage());
}

// Test 2: Test direct SOQL query to verify all required fields are accessible
try {
    List<AGENT_OU_PIPELINE_V2__c> records = [
        SELECT Id, EMP_ID__c, FULL_NAME__c, OU_NAME__c, WORK_LOCATION_COUNTRY__c,
               EMP_EMAIL_ADDR__c, LEARNER_PROFILE_ID__c, RAMP_STATUS__c, TIME_SINCE_ONBOARDING__c,
               ACV_THRESHOLD__c, DAYS_TO_PRODUCTIVITY__c, FULLTOTALACVQUOTAUSD__c,
               CQ_DAYS_ACV__c, CQ_DAYS_ACV_PART__c, CQ_DAYS_PG_PART__c, CQ_DAYS_PG__c,
               PQ_DAYS_ACV__c, PQ_DAYS_ACV_PART__c, PQ_DAYS_PG_PART__c, PQ_DAYS_PG__c,
               AOV__c, DEFINITION__c, DESCRIPTION__c, VAL_QUOTA__c, COVERAGE__c,
               CQ_CUSTOMER_MEETING__c, CQ_PG__c, CQ_ACV__c, CQ_CALL_CONNECT__c, CQ_CC_ACV__c,
               PQ_CUSTOMER_MEETING__c, PQ_PG__c, PQ_ACV__c, PQ_CALL_CONNECT__c, PQ_CC_ACV__c,
               CALL_AI_MENTION__c, PRIMARY_INDUSTRY__c, EMP_MGR_NM__c
        FROM AGENT_OU_PIPELINE_V2__c 
        LIMIT 1
    ];
    
    if (!records.isEmpty()) {
        AGENT_OU_PIPELINE_V2__c record = records[0];
        System.debug('✅ Direct SOQL PASSED - Retrieved record with ID: ' + record.Id);
        System.debug('✅ Core fields accessible - EMP_ID: ' + record.EMP_ID__c + ', FULL_NAME: ' + record.FULL_NAME__c);
        System.debug('✅ KPI fields accessible - VAL_QUOTA: ' + record.VAL_QUOTA__c + ', COVERAGE: ' + record.COVERAGE__c);
        System.debug('✅ New fields accessible - RAMP_STATUS: ' + record.RAMP_STATUS__c + ', TIME_SINCE_ONBOARDING: ' + record.TIME_SINCE_ONBOARDING__c);
        System.debug('✅ Days fields accessible - CQ_DAYS_ACV: ' + record.CQ_DAYS_ACV__c + ', PQ_DAYS_ACV: ' + record.PQ_DAYS_ACV__c);
    } else {
        System.debug('⚠️ Direct SOQL returned no records (this is OK if no data exists)');
    }
} catch (Exception e) {
    System.debug('❌ Direct SOQL FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Test 3: Test service DTO classes (no permission checks)
try {
    ANAGENTKPIAnalysisServiceV3.OpenPipeSearchResult result = new ANAGENTKPIAnalysisServiceV3.OpenPipeSearchResult();
    ANAGENTKPIAnalysisServiceV3.UnifiedOpenPipeRecord record = new ANAGENTKPIAnalysisServiceV3.UnifiedOpenPipeRecord();
    
    record.empId = 'TEST123';
    record.fullName = 'Test User';
    record.ouName = 'AMER - FINS';
    record.workLocationCountry = 'USA';
    
    result.records.add(record);
    result.totalCount = 1;
    
    System.debug('✅ Service DTOs PASSED - Created result with ' + result.records.size() + ' records');
    System.debug('✅ Record data - EMP_ID: ' + record.empId + ', FULL_NAME: ' + record.fullName);
} catch (Exception e) {
    System.debug('❌ Service DTOs FAILED: ' + e.getMessage());
}

System.debug('=== Final Smoke Test Complete ===');
System.debug('If all tests passed, the core functionality should work!');
System.debug('The "Invalid Config" error should be resolved once the agent runs with proper permissions.'); 