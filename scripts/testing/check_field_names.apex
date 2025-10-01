// Check what the actual field names are in the object
System.debug('=== CHECKING FIELD NAMES ===');

try {
    // Get a sample record to see what fields are available
    List<AGENT_OU_PIPELINE_V2__c> sampleRecords = [
        SELECT Id, FULL_NAME__c, OU_NAME__c, AE_Score__c, Coverage__c, 
               ACTIONABLE__c, DEFINITION__c, DESCRIPTION__c,
               CQ_CUSTOMER_MEETING__c, CQ_CALL_CONNECT__c, CQ_ACV__c, CQ_PG__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c = 'AMER ACC' 
        LIMIT 1
    ];
    
    if (!sampleRecords.isEmpty()) {
        AGENT_OU_PIPELINE_V2__c record = sampleRecords[0];
        System.debug('✅ Sample record found');
        System.debug('AE_Score__c: ' + record.AE_Score__c);
        System.debug('Coverage__c: ' + record.Coverage__c);
        System.debug('ACTIONABLE__c: ' + record.ACTIONABLE__c);
        System.debug('DEFINITION__c: ' + record.DEFINITION__c);
        System.debug('CQ_CUSTOMER_MEETING__c: ' + record.CQ_CUSTOMER_MEETING__c);
        System.debug('CQ_CALL_CONNECT__c: ' + record.CQ_CALL_CONNECT__c);
        System.debug('CQ_ACV__c: ' + record.CQ_ACV__c);
        System.debug('CQ_PG__c: ' + record.CQ_PG__c);
    } else {
        System.debug('❌ No sample records found');
    }
} catch (Exception e) {
    System.debug('Error checking field names: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
