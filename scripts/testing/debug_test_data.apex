// Debug script for Test Data
System.debug('🔍 DEBUGGING TEST DATA');

// Check if test data exists
try {
    // Check for test records with our specific naming pattern
    List<AGENT_OU_PIPELINE_V2__c> testRecords = [
        SELECT Id, EMP_ID__c, FULL_NAME__c, OU_NAME__c, PRIMARY_INDUSTRY__c, WORK_LOCATION_COUNTRY__c,
               OPEN_PIPE_OPTY_NM_1__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE EMP_ID__c LIKE 'CUST_TEST_%' OR EMP_ID__c LIKE 'STAGE_TEST_%' OR EMP_ID__c LIKE 'STAG_TEST_%'
        LIMIT 10
    ];
    
    System.debug('Test Records Found: ' + testRecords.size());
    
    for (AGENT_OU_PIPELINE_V2__c record : testRecords) {
        System.debug('Test Record: ' + record.EMP_ID__c + ' - OU: ' + record.OU_NAME__c + ' - Customer: ' + record.OPEN_PIPE_OPTY_NM_1__c + ' - Amount: ' + record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c);
    }
    
    // Check total records in the object
    Integer totalRecords = Database.countQuery('SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c');
    System.debug('Total Records in Object: ' + totalRecords);
    
    // Check records for AMER ICE specifically
    List<AGENT_OU_PIPELINE_V2__c> amerIceRecords = [
        SELECT Id, EMP_ID__c, FULL_NAME__c, OU_NAME__c, OPEN_PIPE_OPTY_NM_1__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c = 'AMER ICE'
        LIMIT 5
    ];
    
    System.debug('AMER ICE Records Found: ' + amerIceRecords.size());
    for (AGENT_OU_PIPELINE_V2__c record : amerIceRecords) {
        System.debug('AMER ICE Record: ' + record.EMP_ID__c + ' - Customer: ' + record.OPEN_PIPE_OPTY_NM_1__c + ' - Amount: ' + record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c);
    }
    
} catch (Exception e) {
    System.debug('❌ Error checking test data: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('🔍 TEST DATA DEBUG COMPLETE'); 