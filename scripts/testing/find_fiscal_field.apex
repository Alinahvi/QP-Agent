// Find the correct fiscal quarter field name
System.debug('=== FINDING FISCAL QUARTER FIELD ===');

try {
    // Get a sample record and check what fields are available
    List<AGENT_OU_PIPELINE_V2__c> sampleRecords = [
        SELECT Id, FULL_NAME__c, OU_NAME__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c = 'AMER ACC' 
        LIMIT 1
    ];
    
    if (!sampleRecords.isEmpty()) {
        System.debug('✅ Sample record found');
        
        // Try different possible field names for fiscal quarter
        String[] possibleFiscalFields = new String[]{
            'Fiscal_Quarter__c', 'FISCAL_QUARTER__c', 'FiscalQuarter__c', 'FISCALQUARTER__c',
            'Quarter__c', 'QUARTER__c', 'Fiscal_Year__c', 'FISCAL_YEAR__c',
            'FiscalYear__c', 'FISCALYEAR__c', 'Year__c', 'YEAR__c',
            'Period__c', 'PERIOD__c', 'Time_Period__c', 'TIME_PERIOD__c'
        };
        
        for (String fieldName : possibleFiscalFields) {
            try {
                String testQuery = 'SELECT ' + fieldName + ' FROM AGENT_OU_PIPELINE_V2__c LIMIT 1';
                Database.query(testQuery);
                System.debug('✅ Found fiscal field: ' + fieldName);
            } catch (Exception e) {
                System.debug('❌ ' + fieldName + ' does not exist');
            }
        }
        
        // Also try to find any field that might contain quarter or year info
        System.debug('\n=== CHECKING FOR ANY TIME-RELATED FIELDS ===');
        String[] timeFields = new String[]{
            'CreatedDate', 'LastModifiedDate', 'SystemModstamp',
            'Fiscal_Year__c', 'Fiscal_Quarter__c', 'Quarter__c', 'Year__c',
            'Period__c', 'Time__c', 'Date__c', 'Month__c', 'Day__c'
        };
        
        for (String fieldName : timeFields) {
            try {
                String testQuery = 'SELECT ' + fieldName + ' FROM AGENT_OU_PIPELINE_V2__c LIMIT 1';
                Database.query(testQuery);
                System.debug('✅ Found time field: ' + fieldName);
            } catch (Exception e) {
                System.debug('❌ ' + fieldName + ' does not exist');
            }
        }
        
    } else {
        System.debug('❌ No sample records found');
    }
} catch (Exception e) {
    System.debug('Error finding fiscal field: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}
