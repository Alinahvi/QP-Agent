// Find what fields are actually available in the object
System.debug('=== FINDING AVAILABLE FIELDS ===');

try {
    // Get a sample record and try to access various field names
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
        
        // Try different possible field names for AE Score
        String[] possibleAEScoreFields = new String[]{'AE_Score__c', 'AE_SCORE__c', 'AEScore__c', 'AE_SCORE', 'AEScore'};
        for (String fieldName : possibleAEScoreFields) {
            try {
                // This is a hack to test field existence
                String testQuery = 'SELECT ' + fieldName + ' FROM AGENT_OU_PIPELINE_V2__c LIMIT 1';
                Database.query(testQuery);
                System.debug('✅ Found AE Score field: ' + fieldName);
                break;
            } catch (Exception e) {
                System.debug('❌ ' + fieldName + ' does not exist');
            }
        }
        
        // Try different possible field names for Coverage
        String[] possibleCoverageFields = new String[]{'Coverage__c', 'COVERAGE__c', 'Coverage', 'COVERAGE'};
        for (String fieldName : possibleCoverageFields) {
            try {
                String testQuery = 'SELECT ' + fieldName + ' FROM AGENT_OU_PIPELINE_V2__c LIMIT 1';
                Database.query(testQuery);
                System.debug('✅ Found Coverage field: ' + fieldName);
                break;
            } catch (Exception e) {
                System.debug('❌ ' + fieldName + ' does not exist');
            }
        }
        
    } else {
        System.debug('❌ No sample records found');
    }
} catch (Exception e) {
    System.debug('Error finding fields: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
