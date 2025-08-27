/**
 * Query All Object Fields
 * Get all available fields from AGENT_OU_PIPELINE_V2__c to fix field mapping issues
 */

System.debug('=== QUERYING ALL OBJECT FIELDS ===');

try {
    // Get the object describe
    Schema.DescribeSObjectResult objectDescribe = AGENT_OU_PIPELINE_V2__c.SObjectType.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
    
    System.debug('Object: ' + objectDescribe.getName());
    System.debug('Total Fields: ' + fieldMap.size());
    System.debug('Label: ' + objectDescribe.getLabel());
    System.debug('Plural Label: ' + objectDescribe.getLabelPlural());
    
    System.debug('\n=== ALL FIELDS IN AGENT_OU_PIPELINE_V2__c ===');
    
    // Categorize fields by type
    Map<String, List<String>> fieldsByType = new Map<String, List<String>>();
    
    for (String fieldName : fieldMap.keySet()) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        
        String fieldType = String.valueOf(fieldDescribe.getType());
        String apiName = fieldDescribe.getName();
        String label = fieldDescribe.getLabel();
        Boolean isCustom = fieldDescribe.isCustom();
        Boolean isAccessible = fieldDescribe.isAccessible();
        
        if (!fieldsByType.containsKey(fieldType)) {
            fieldsByType.put(fieldType, new List<String>());
        }
        
        String fieldInfo = apiName + ' (' + label + ')' + (isCustom ? ' [CUSTOM]' : ' [STANDARD]');
        if (!isAccessible) {
            fieldInfo += ' [NOT ACCESSIBLE]';
        }
        
        fieldsByType.get(fieldType).add(fieldInfo);
    }
    
    // Display fields by type
    for (String fieldType : fieldsByType.keySet()) {
        System.debug('\n--- ' + fieldType + ' FIELDS ---');
        List<String> fields = fieldsByType.get(fieldType);
        fields.sort();
        for (String field : fields) {
            System.debug('  ' + field);
        }
    }
    
    // Special focus on key fields we need
    System.debug('\n=== KEY FIELDS FOR KPI ANALYSIS ===');
    
    // Look for OU/Region fields
    System.debug('--- OU/REGION RELATED FIELDS ---');
    for (String fieldName : fieldMap.keySet()) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        String apiName = fieldDescribe.getName();
        String label = fieldDescribe.getLabel();
        
        if (apiName.toLowerCase().contains('ou') || 
            apiName.toLowerCase().contains('region') || 
            apiName.toLowerCase().contains('segment') ||
            apiName.toLowerCase().contains('industry') ||
            label.toLowerCase().contains('ou') ||
            label.toLowerCase().contains('region') ||
            label.toLowerCase().contains('segment') ||
            label.toLowerCase().contains('industry')) {
            
            System.debug('  ' + apiName + ' (' + label + ') - Type: ' + fieldDescribe.getType());
        }
    }
    
    // Look for KPI fields
    System.debug('\n--- KPI RELATED FIELDS ---');
    for (String fieldName : fieldMap.keySet()) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        String apiName = fieldDescribe.getName();
        String label = fieldDescribe.getLabel();
        
        if (apiName.toLowerCase().contains('meeting') || 
            apiName.toLowerCase().contains('pipeline') || 
            apiName.toLowerCase().contains('acv') ||
            apiName.toLowerCase().contains('call') ||
            apiName.toLowerCase().contains('ai') ||
            label.toLowerCase().contains('meeting') ||
            label.toLowerCase().contains('pipeline') ||
            label.toLowerCase().contains('acv') ||
            label.toLowerCase().contains('call') ||
            label.toLowerCase().contains('ai')) {
            
            System.debug('  ' + apiName + ' (' + label + ') - Type: ' + fieldDescribe.getType());
        }
    }
    
    // Look for location fields
    System.debug('\n--- LOCATION RELATED FIELDS ---');
    for (String fieldName : fieldMap.keySet()) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        String apiName = fieldDescribe.getName();
        String label = fieldDescribe.getLabel();
        
        if (apiName.toLowerCase().contains('country') || 
            apiName.toLowerCase().contains('location') || 
            apiName.toLowerCase().contains('territory') ||
            label.toLowerCase().contains('country') ||
            label.toLowerCase().contains('location') ||
            label.toLowerCase().contains('territory')) {
            
            System.debug('  ' + apiName + ' (' + label + ') - Type: ' + fieldDescribe.getType());
        }
    }
    
} catch (Exception e) {
    System.debug('Error querying object fields: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== FIELD QUERY COMPLETED ==='); 