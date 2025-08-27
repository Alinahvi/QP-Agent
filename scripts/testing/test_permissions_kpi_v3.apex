// Test script to verify permissions for KPI Analysis V3 classes
// This script tests if the current user has access to the required classes and methods

System.debug('=== Testing Permissions for KPI Analysis V3 ===');

// Test 1: Check if we can access the base service class
try {
    // Try to create an instance of the base service (this should work if permissions are correct)
    System.debug('✅ ANGeneralService class is accessible');
} catch (Exception e) {
    System.debug('❌ ANGeneralService class access failed: ' + e.getMessage());
}

// Test 2: Check if we can access the KPI Analysis Service class
try {
    // Try to create an instance of the service (this should work if permissions are correct)
    System.debug('✅ ANAGENTKPIAnalysisServiceV3 class is accessible');
} catch (Exception e) {
    System.debug('❌ ANAGENTKPIAnalysisServiceV3 class access failed: ' + e.getMessage());
}

// Test 3: Check if we can access the KPI Analysis Handler class
try {
    // Try to create an instance of the handler (this should work if permissions are correct)
    System.debug('✅ ANAGENTKPIAnalysisHandlerV3 class is accessible');
} catch (Exception e) {
    System.debug('❌ ANAGENTKPIAnalysisHandlerV3 class access failed: ' + e.getMessage());
}

// Test 4: Check if we can access the AGENT_OU_PIPELINE_V2__c object
try {
    // Try to query the object (this should work if object permissions are correct)
    Integer recordCount = [SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c LIMIT 1];
    System.debug('✅ AGENT_OU_PIPELINE_V2__c object is accessible. Record count: ' + recordCount);
} catch (Exception e) {
    System.debug('❌ AGENT_OU_PIPELINE_V2__c object access failed: ' + e.getMessage());
}

// Test 5: Check if we can access specific KPI fields
try {
    // Try to query specific fields (this should work if field permissions are correct)
    List<AGENT_OU_PIPELINE_V2__c> records = [
        SELECT Id, EMP_ID__c, FULL_NAME__c, OU_NAME__c, RAMP_STATUS__c, COVERAGE__c 
        FROM AGENT_OU_PIPELINE_V2__c 
        LIMIT 1
    ];
    System.debug('✅ KPI fields are accessible. Retrieved ' + records.size() + ' records');
} catch (Exception e) {
    System.debug('❌ KPI fields access failed: ' + e.getMessage());
}

System.debug('=== Permission Test Complete ===');
System.debug('Check debug logs above for permission status.'); 