// Find what scoring/performance fields are available
System.debug('=== FINDING SCORING FIELDS ===');

try {
    // Get a sample record and try to access various field names
    List<AGENT_OU_PIPELINE_V2__c> sampleRecords = [
        SELECT Id, FULL_NAME__c, OU_NAME__c, ACTIONABLE__c, DEFINITION__c, DESCRIPTION__c,
               CQ_CUSTOMER_MEETING__c, CQ_CALL_CONNECT__c, CQ_ACV__c, CQ_PG__c, Coverage__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c = 'AMER ACC' 
        LIMIT 1
    ];
    
    if (!sampleRecords.isEmpty()) {
        AGENT_OU_PIPELINE_V2__c record = sampleRecords[0];
        System.debug('✅ Sample record found');
        
        // Try different possible field names for scoring/performance
        String[] possibleScoreFields = new String[]{
            'Score__c', 'SCORE__c', 'Performance__c', 'PERFORMANCE__c',
            'Rating__c', 'RATING__c', 'Grade__c', 'GRADE__c',
            'Level__c', 'LEVEL__c', 'Tier__c', 'TIER__c',
            'Rank__c', 'RANK__c', 'Points__c', 'POINTS__c',
            'Value__c', 'VALUE__c', 'Metric__c', 'METRIC__c'
        };
        
        for (String fieldName : possibleScoreFields) {
            try {
                String testQuery = 'SELECT ' + fieldName + ' FROM AGENT_OU_PIPELINE_V2__c LIMIT 1';
                Database.query(testQuery);
                System.debug('✅ Found scoring field: ' + fieldName);
            } catch (Exception e) {
                System.debug('❌ ' + fieldName + ' does not exist');
            }
        }
        
        // Also check what fields are actually populated in the sample record
        System.debug('\n=== SAMPLE RECORD VALUES ===');
        System.debug('Id: ' + record.Id);
        System.debug('FULL_NAME__c: ' + record.FULL_NAME__c);
        System.debug('OU_NAME__c: ' + record.OU_NAME__c);
        System.debug('ACTIONABLE__c: ' + record.ACTIONABLE__c);
        System.debug('DEFINITION__c: ' + record.DEFINITION__c);
        System.debug('DESCRIPTION__c: ' + record.DESCRIPTION__c);
        System.debug('CQ_CUSTOMER_MEETING__c: ' + record.CQ_CUSTOMER_MEETING__c);
        System.debug('CQ_CALL_CONNECT__c: ' + record.CQ_CALL_CONNECT__c);
        System.debug('CQ_ACV__c: ' + record.CQ_ACV__c);
        System.debug('CQ_PG__c: ' + record.CQ_PG__c);
        System.debug('Coverage__c: ' + record.Coverage__c);
        
    } else {
        System.debug('❌ No sample records found');
    }
} catch (Exception e) {
    System.debug('Error finding fields: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
