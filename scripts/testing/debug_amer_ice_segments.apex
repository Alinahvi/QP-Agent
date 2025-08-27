// Debug script to check what segment values actually exist for AMER ICE
System.debug('🔍 Debug AMER ICE Segments - Checking Actual Values...');

// Check 1: What are the actual segment values for AMER ICE?
System.debug('=== CHECK 1: AMER ICE Segment Values ===');
try {
    String query = 'SELECT Id, OU_NAME__c, OPEN_PIPE_REVISED_SUB_SECTOR_1__c, OPEN_PIPE_REVISED_SUB_SECTOR_2__c, OPEN_PIPE_REVISED_SUB_SECTOR_3__c, OPEN_PIPE_REVISED_SUB_SECTOR_4__c, OPEN_PIPE_REVISED_SUB_SECTOR_5__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE OU_NAME__c = \'AMER ICE\' ' +
                   'AND (OPEN_PIPE_REVISED_SUB_SECTOR_1__c != null OR OPEN_PIPE_REVISED_SUB_SECTOR_2__c != null OR OPEN_PIPE_REVISED_SUB_SECTOR_3__c != null OR OPEN_PIPE_REVISED_SUB_SECTOR_4__c != null OR OPEN_PIPE_REVISED_SUB_SECTOR_5__c != null) ' +
                   'LIMIT 20';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' AMER ICE records with segment values');
    
    Set<String> allSegmentValues = new Set<String>();
    for (AGENT_OU_PIPELINE_V2__c record : records) {
        if (String.isNotBlank(record.OPEN_PIPE_REVISED_SUB_SECTOR_1__c)) allSegmentValues.add(record.OPEN_PIPE_REVISED_SUB_SECTOR_1__c);
        if (String.isNotBlank(record.OPEN_PIPE_REVISED_SUB_SECTOR_2__c)) allSegmentValues.add(record.OPEN_PIPE_REVISED_SUB_SECTOR_2__c);
        if (String.isNotBlank(record.OPEN_PIPE_REVISED_SUB_SECTOR_3__c)) allSegmentValues.add(record.OPEN_PIPE_REVISED_SUB_SECTOR_3__c);
        if (String.isNotBlank(record.OPEN_PIPE_REVISED_SUB_SECTOR_4__c)) allSegmentValues.add(record.OPEN_PIPE_REVISED_SUB_SECTOR_4__c);
        if (String.isNotBlank(record.OPEN_PIPE_REVISED_SUB_SECTOR_5__c)) allSegmentValues.add(record.OPEN_PIPE_REVISED_SUB_SECTOR_5__c);
    }
    
    System.debug('All Segment Values for AMER ICE:');
    for (String segmentValue : allSegmentValues) {
        System.debug('- ' + segmentValue);
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE Segment Check Failed: ' + e.getMessage());
}

// Check 2: What are the actual industry values for AMER ICE?
System.debug('=== CHECK 2: AMER ICE Industry Values ===');
try {
    String query = 'SELECT Id, OU_NAME__c, PRIMARY_INDUSTRY__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE OU_NAME__c = \'AMER ICE\' ' +
                   'AND PRIMARY_INDUSTRY__c != null ' +
                   'LIMIT 20';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' AMER ICE records with industry values');
    
    Set<String> allIndustryValues = new Set<String>();
    for (AGENT_OU_PIPELINE_V2__c record : records) {
        if (String.isNotBlank(record.PRIMARY_INDUSTRY__c)) allIndustryValues.add(record.PRIMARY_INDUSTRY__c);
    }
    
    System.debug('All Industry Values for AMER ICE:');
    for (String industryValue : allIndustryValues) {
        System.debug('- ' + industryValue);
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE Industry Check Failed: ' + e.getMessage());
}

// Check 3: Test with actual segment values found
System.debug('=== CHECK 3: Test with Actual Segment Values ===');
try {
    // Test with one of the actual segment values we found
    String query = 'SELECT Id, OU_NAME__c, OPEN_PIPE_REVISED_SUB_SECTOR_1__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE OU_NAME__c = \'AMER ICE\' ' +
                   'AND OPEN_PIPE_REVISED_SUB_SECTOR_1__c != null ' +
                   'LIMIT 5';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' AMER ICE records with any segment value');
    
    for (Integer i = 0; i < Math.min(3, records.size()); i++) {
        AGENT_OU_PIPELINE_V2__c record = records[i];
        System.debug((i+1) + '. OU: ' + record.OU_NAME__c + ' - Sector1: ' + record.OPEN_PIPE_REVISED_SUB_SECTOR_1__c);
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE Segment Test Failed: ' + e.getMessage());
}

System.debug('🔍 AMER ICE Segments Debug Complete!'); 