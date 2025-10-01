// Check what the actual field names are in the object
System.debug('=== CHECKING ACTUAL FIELD NAMES ===');

try {
    // Get a sample record to see what fields are available
    List<AGENT_OU_PIPELINE_V2__c> sampleRecords = [
        SELECT Id, FULL_NAME__c, OU_NAME__c, ACTIONABLE__c, DEFINITION__c, DESCRIPTION__c,
               CQ_CUSTOMER_MEETING__c, CQ_CALL_CONNECT__c, CQ_ACV__c, CQ_PG__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c = 'AMER ACC' 
        LIMIT 1
    ];
    
    if (!sampleRecords.isEmpty()) {
        AGENT_OU_PIPELINE_V2__c record = sampleRecords[0];
        System.debug('✅ Sample record found');
        System.debug('ACTIONABLE__c: ' + record.ACTIONABLE__c);
        System.debug('DEFINITION__c: ' + record.DEFINITION__c);
        System.debug('CQ_CUSTOMER_MEETING__c: ' + record.CQ_CUSTOMER_MEETING__c);
        System.debug('CQ_CALL_CONNECT__c: ' + record.CQ_CALL_CONNECT__c);
        System.debug('CQ_ACV__c: ' + record.CQ_ACV__c);
        System.debug('CQ_PG__c: ' + record.CQ_PG__c);
        
        // Try to access other fields that might exist
        try {
            System.debug('Trying to access AE_Score__c...');
            // This will fail if the field doesn't exist
        } catch (Exception e) {
            System.debug('AE_Score__c field does not exist: ' + e.getMessage());
        }
        
        try {
            System.debug('Trying to access Coverage__c...');
            // This will fail if the field doesn't exist
        } catch (Exception e) {
            System.debug('Coverage__c field does not exist: ' + e.getMessage());
        }
        
    } else {
        System.debug('❌ No sample records found');
    }
} catch (Exception e) {
    System.debug('Error checking field names: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
