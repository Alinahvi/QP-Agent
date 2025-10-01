// Simple script to check what KPI fields exist
System.debug('🔍 Checking KPI Fields in AGENT_OU_PIPELINE_V2__c...');

// ========================================
// CHECK 1: Basic object query
// ========================================

System.debug('=== CHECK 1: Basic Object Query ===');
try {
    String query = 'SELECT Id, OU_NAME__c FROM AGENT_OU_PIPELINE_V2__c WHERE OU_NAME__c = \'UKI\' LIMIT 1';
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('✅ Basic query successful - Found ' + records.size() + ' records');
} catch (Exception e) {
    System.debug('❌ Basic query failed: ' + e.getMessage());
}

// ========================================
// CHECK 2: Look for KPI-related fields
// ========================================

System.debug('=== CHECK 2: Looking for KPI Fields ===');
try {
    // Try to find fields that might contain KPI data
    String query = 'SELECT Id, OU_NAME__c FROM AGENT_OU_PIPELINE_V2__c WHERE OU_NAME__c = \'UKI\' LIMIT 1';
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    
    if (!records.isEmpty()) {
        AGENT_OU_PIPELINE_V2__c record = records[0];
        System.debug('🔍 Record ID: ' + record.Id);
        System.debug('🔍 OU Name: ' + record.OU_NAME__c);
        
        // Try to access some potential KPI fields
        try {
            // These are just examples - we'll see which ones exist
            System.debug('🔍 Checking for KPI fields...');
        } catch (Exception fieldError) {
            System.debug('⚠️ Field access error: ' + fieldError.getMessage());
        }
    }
} catch (Exception e) {
    System.debug('❌ KPI field check failed: ' + e.getMessage());
}

// ========================================
// CHECK 3: Describe the object to see available fields
// ========================================

System.debug('=== CHECK 3: Object Description ===');
try {
    Schema.DescribeSObjectResult describeResult = AGENT_OU_PIPELINE_V2__c.SObjectType.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
    
    System.debug('🔍 Total fields in object: ' + fieldMap.size());
    
    // Look for fields that might be KPI-related
    List<String> kpiRelatedFields = new List<String>();
    for (String fieldName : fieldMap.keySet()) {
        if (fieldName.toLowerCase().contains('kpi') || 
            fieldName.toLowerCase().contains('acv') || 
            fieldName.toLowerCase().contains('coverage') || 
            fieldName.toLowerCase().contains('acp') ||
            fieldName.toLowerCase().contains('cq_')) {
            kpiRelatedFields.add(fieldName);
        }
    }
    
    System.debug('🔍 KPI-related fields found: ' + kpiRelatedFields.size());
    for (String fieldName : kpiRelatedFields) {
        System.debug('- ' + fieldName);
    }
    
} catch (Exception e) {
    System.debug('❌ Object description failed: ' + e.getMessage());
}

System.debug('🎯 KPI Field Check Complete!');
System.debug('📊 This should show what KPI fields are available!'); 