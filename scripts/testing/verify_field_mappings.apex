// Comprehensive verification script to check actual field names and values
System.debug('🔍 Verifying Field Mappings Against Data Dictionary...');

// ========================================
// VERIFY FIELD NAMES (with and without __c)
// ========================================

System.debug('=== CHECK 1: Verify Field Names ===');
try {
    // Test both versions of field names
    String query1 = 'SELECT Id, EMP_ID__c, FULL_NAME__c, OU_NAME__c, PRIMARY_INDUSTRY__c, WORK_LOCATION_COUNTRY__c ' +
                    'FROM AGENT_OU_PIPELINE_V2__c LIMIT 1';
    
    String query2 = 'SELECT Id, EMP_ID, FULL_NAME, OU_NAME, PRIMARY_INDUSTRY, WORK_LOCATION_COUNTRY ' +
                    'FROM AGENT_OU_PIPELINE_V2__c LIMIT 1';
    
    try {
        List<AGENT_OU_PIPELINE_V2__c> records1 = Database.query(query1);
        System.debug('✅ Fields WITH __c suffix: WORKING');
    } catch (Exception e) {
        System.debug('❌ Fields WITH __c suffix: FAILED - ' + e.getMessage());
    }
    
    try {
        List<AGENT_OU_PIPELINE_V2__c> records2 = Database.query(query2);
        System.debug('✅ Fields WITHOUT __c suffix: WORKING');
    } catch (Exception e) {
        System.debug('❌ Fields WITHOUT __c suffix: FAILED - ' + e.getMessage());
    }
} catch (Exception e) {
    System.debug('❌ Field Name Check Failed: ' + e.getMessage());
}

// ========================================
// VERIFY ACTUAL STAGE NAMES IN DATABASE
// ========================================

System.debug('=== CHECK 2: Verify Actual Stage Names ===');
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
    
    System.debug('All Stage Names Found in Database:');
    for (String stageName : allStageNames) {
        System.debug('- ' + stageName);
    }
} catch (Exception e) {
    System.debug('❌ Stage Names Check Failed: ' + e.getMessage());
}

// ========================================
// VERIFY ACTUAL INDUSTRY VALUES IN DATABASE
// ========================================

System.debug('=== CHECK 3: Verify Actual Industry Values ===');
try {
    String query = 'SELECT Id, PRIMARY_INDUSTRY__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE PRIMARY_INDUSTRY__c != null ' +
                   'LIMIT 20';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' records with industry values');
    
    Set<String> allIndustryValues = new Set<String>();
    for (AGENT_OU_PIPELINE_V2__c record : records) {
        if (String.isNotBlank(record.PRIMARY_INDUSTRY__c)) allIndustryValues.add(record.PRIMARY_INDUSTRY__c);
    }
    
    System.debug('All Industry Values Found in Database:');
    for (String industryValue : allIndustryValues) {
        System.debug('- ' + industryValue);
    }
} catch (Exception e) {
    System.debug('❌ Industry Values Check Failed: ' + e.getMessage());
}

// ========================================
// VERIFY ACTUAL SUB-SECTOR VALUES IN DATABASE
// ========================================

System.debug('=== CHECK 4: Verify Actual Sub-Sector Values ===');
try {
    String query = 'SELECT Id, OPEN_PIPE_REVISED_SUB_SECTOR_1__c, OPEN_PIPE_REVISED_SUB_SECTOR_2__c, OPEN_PIPE_REVISED_SUB_SECTOR_3__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE (OPEN_PIPE_REVISED_SUB_SECTOR_1__c != null OR OPEN_PIPE_REVISED_SUB_SECTOR_2__c != null OR OPEN_PIPE_REVISED_SUB_SECTOR_3__c != null) ' +
                   'LIMIT 20';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' records with sub-sector values');
    
    Set<String> allSubSectorValues = new Set<String>();
    for (AGENT_OU_PIPELINE_V2__c record : records) {
        if (String.isNotBlank(record.OPEN_PIPE_REVISED_SUB_SECTOR_1__c)) allSubSectorValues.add(record.OPEN_PIPE_REVISED_SUB_SECTOR_1__c);
        if (String.isNotBlank(record.OPEN_PIPE_REVISED_SUB_SECTOR_2__c)) allSubSectorValues.add(record.OPEN_PIPE_REVISED_SUB_SECTOR_2__c);
        if (String.isNotBlank(record.OPEN_PIPE_REVISED_SUB_SECTOR_3__c)) allSubSectorValues.add(record.OPEN_PIPE_REVISED_SUB_SECTOR_3__c);
    }
    
    System.debug('All Sub-Sector Values Found in Database:');
    for (String subSectorValue : allSubSectorValues) {
        System.debug('- ' + subSectorValue);
    }
} catch (Exception e) {
    System.debug('❌ Sub-Sector Values Check Failed: ' + e.getMessage());
}

// ========================================
// VERIFY ACTUAL OU VALUES IN DATABASE
// ========================================

System.debug('=== CHECK 5: Verify Actual OU Values ===');
try {
    String query = 'SELECT Id, OU_NAME__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE OU_NAME__c != null ' +
                   'LIMIT 20';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' records with OU values');
    
    Set<String> allOUValues = new Set<String>();
    for (AGENT_OU_PIPELINE_V2__c record : records) {
        if (String.isNotBlank(record.OU_NAME__c)) allOUValues.add(record.OU_NAME__c);
    }
    
    System.debug('All OU Values Found in Database:');
    for (String ouValue : allOUValues) {
        System.debug('- ' + ouValue);
    }
} catch (Exception e) {
    System.debug('❌ OU Values Check Failed: ' + e.getMessage());
}

System.debug('🔍 Field Mapping Verification Complete!');
System.debug('📊 Next: Compare these results with the data dictionary to fix mappings!'); 