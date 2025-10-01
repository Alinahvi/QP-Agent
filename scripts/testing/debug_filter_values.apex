// Debug script to check actual values in the database for filtering
System.debug('🔍 Debug Filter Values - Checking Actual Data...');

// Check 1: What are the actual stage names in the database?
System.debug('=== CHECK 1: Actual Stage Names ===');
try {
    String query = 'SELECT Id, OPEN_PIPE_OPTY_STG_NM_1__c, OPEN_PIPE_OPTY_STG_NM_2__c, OPEN_PIPE_OPTY_STG_NM_3__c, OPEN_PIPE_OPTY_STG_NM_4__c, OPEN_PIPE_OPTY_STG_NM_5__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE (OPEN_PIPE_OPTY_STG_NM_1__c != null OR OPEN_PIPE_OPTY_STG_NM_2__c != null OR OPEN_PIPE_OPTY_STG_NM_3__c != null OR OPEN_PIPE_OPTY_STG_NM_4__c != null OR OPEN_PIPE_OPTY_STG_NM_5__c != null) ' +
                   'LIMIT 20';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' records with stage names');
    
    Set<String> allStageNames = new Set<String>();
    for (AGENT_OU_PIPELINE_V2__c record : records) {
        if (String.isNotBlank(record.OPEN_PIPE_OPTY_STG_NM_1__c)) allStageNames.add(record.OPEN_PIPE_OPTY_STG_NM_1__c);
        if (String.isNotBlank(record.OPEN_PIPE_OPTY_STG_NM_2__c)) allStageNames.add(record.OPEN_PIPE_OPTY_STG_NM_2__c);
        if (String.isNotBlank(record.OPEN_PIPE_OPTY_STG_NM_3__c)) allStageNames.add(record.OPEN_PIPE_OPTY_STG_NM_3__c);
        if (String.isNotBlank(record.OPEN_PIPE_OPTY_STG_NM_4__c)) allStageNames.add(record.OPEN_PIPE_OPTY_STG_NM_4__c);
        if (String.isNotBlank(record.OPEN_PIPE_OPTY_STG_NM_5__c)) allStageNames.add(record.OPEN_PIPE_OPTY_STG_NM_5__c);
    }
    
    System.debug('All Stage Names Found:');
    for (String stageName : allStageNames) {
        System.debug('- ' + stageName);
    }
} catch (Exception e) {
    System.debug('❌ Stage Names Check Failed: ' + e.getMessage());
}

// Check 2: What are the actual segment values in the database?
System.debug('=== CHECK 2: Actual Segment Values ===');
try {
    String query = 'SELECT Id, OPEN_PIPE_REVISED_SUB_SECTOR_1__c, OPEN_PIPE_REVISED_SUB_SECTOR_2__c, OPEN_PIPE_REVISED_SUB_SECTOR_3__c, OPEN_PIPE_REVISED_SUB_SECTOR_4__c, OPEN_PIPE_REVISED_SUB_SECTOR_5__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE (OPEN_PIPE_REVISED_SUB_SECTOR_1__c != null OR OPEN_PIPE_REVISED_SUB_SECTOR_2__c != null OR OPEN_PIPE_REVISED_SUB_SECTOR_3__c != null OR OPEN_PIPE_REVISED_SUB_SECTOR_4__c != null OR OPEN_PIPE_REVISED_SUB_SECTOR_5__c != null) ' +
                   'LIMIT 20';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' records with segment values');
    
    Set<String> allSegmentValues = new Set<String>();
    for (AGENT_OU_PIPELINE_V2__c record : records) {
        if (String.isNotBlank(record.OPEN_PIPE_REVISED_SUB_SECTOR_1__c)) allSegmentValues.add(record.OPEN_PIPE_REVISED_SUB_SECTOR_1__c);
        if (String.isNotBlank(record.OPEN_PIPE_REVISED_SUB_SECTOR_2__c)) allSegmentValues.add(record.OPEN_PIPE_REVISED_SUB_SECTOR_2__c);
        if (String.isNotBlank(record.OPEN_PIPE_REVISED_SUB_SECTOR_3__c)) allSegmentValues.add(record.OPEN_PIPE_REVISED_SUB_SECTOR_3__c);
        if (String.isNotBlank(record.OPEN_PIPE_REVISED_SUB_SECTOR_4__c)) allSegmentValues.add(record.OPEN_PIPE_REVISED_SUB_SECTOR_4__c);
        if (String.isNotBlank(record.OPEN_PIPE_REVISED_SUB_SECTOR_5__c)) allSegmentValues.add(record.OPEN_PIPE_REVISED_SUB_SECTOR_5__c);
    }
    
    System.debug('All Segment Values Found:');
    for (String segmentValue : allSegmentValues) {
        System.debug('- ' + segmentValue);
    }
} catch (Exception e) {
    System.debug('❌ Segment Values Check Failed: ' + e.getMessage());
}

// Check 3: Test the exact query that's failing for UKI Stage 2
System.debug('=== CHECK 3: Test UKI Stage 2 Query ===');
try {
    String query = 'SELECT Id, OU_NAME__c, OPEN_PIPE_OPTY_NM_2__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c, OPEN_PIPE_OPTY_STG_NM_2__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE OU_NAME__c = \'UKI\' ' +
                   'AND (OPEN_PIPE_OPTY_STG_NM_1__c LIKE \'%Stage 2%\' OR OPEN_PIPE_OPTY_STG_NM_2__c LIKE \'%Stage 2%\' OR OPEN_PIPE_OPTY_STG_NM_3__c LIKE \'%Stage 2%\' OR OPEN_PIPE_OPTY_STG_NM_4__c LIKE \'%Stage 2%\' OR OPEN_PIPE_OPTY_STG_NM_5__c LIKE \'%Stage 2%\') ' +
                   'LIMIT 10';
    
    System.debug('Generated Query: ' + query);
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' UKI Stage 2 records with LIKE filter');
    
    for (Integer i = 0; i < Math.min(5, records.size()); i++) {
        AGENT_OU_PIPELINE_V2__c record = records[i];
        System.debug((i+1) + '. ' + record.OPEN_PIPE_OPTY_NM_2__c + ' - Stage: ' + record.OPEN_PIPE_OPTY_STG_NM_2__c);
    }
} catch (Exception e) {
    System.debug('❌ UKI Stage 2 Query Test Failed: ' + e.getMessage());
}

// Check 4: Test the exact query that's failing for AMER ICE ENTR
System.debug('=== CHECK 4: Test AMER ICE ENTR Query ===');
try {
    String query = 'SELECT Id, OU_NAME__c, OPEN_PIPE_REVISED_SUB_SECTOR_1__c, OPEN_PIPE_REVISED_SUB_SECTOR_2__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE OU_NAME__c = \'AMER ICE\' ' +
                   'AND (OPEN_PIPE_REVISED_SUB_SECTOR_1__c = \'ENTR\' OR OPEN_PIPE_REVISED_SUB_SECTOR_2__c = \'ENTR\' OR OPEN_PIPE_REVISED_SUB_SECTOR_3__c = \'ENTR\' OR OPEN_PIPE_REVISED_SUB_SECTOR_4__c = \'ENTR\' OR OPEN_PIPE_REVISED_SUB_SECTOR_5__c = \'ENTR\') ' +
                   'LIMIT 10';
    
    System.debug('Generated Query: ' + query);
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' AMER ICE ENTR records');
    
    for (Integer i = 0; i < Math.min(5, records.size()); i++) {
        AGENT_OU_PIPELINE_V2__c record = records[i];
        System.debug((i+1) + '. OU: ' + record.OU_NAME__c + ' - Sector1: ' + record.OPEN_PIPE_REVISED_SUB_SECTOR_1__c + ' - Sector2: ' + record.OPEN_PIPE_REVISED_SUB_SECTOR_2__c);
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE ENTR Query Test Failed: ' + e.getMessage());
}

System.debug('🔍 Debug Filter Values Complete!'); 