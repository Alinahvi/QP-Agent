// Script to check the actual field names in the AGENT_OU_PIPELINE_V2__c object
// This will help us understand the naming convention used in the org

System.debug('🔍 CHECKING ACTUAL FIELD NAMES IN AGENT_OU_PIPELINE_V2__c');
System.debug('==========================================================');

try {
    // Get the object describe
    Schema.DescribeSObjectResult objectDesc = Schema.getGlobalDescribe().get('AGENT_OU_PIPELINE_V2__c').getDescribe();
    Map<String, Schema.SObjectField> fieldMap = objectDesc.fields.getMap();
    
    System.debug('✅ Object exists with ' + fieldMap.size() + ' fields');
    
    // Group fields by type for better understanding
    Map<String, List<String>> fieldsByType = new Map<String, List<String>>();
    
    for (String fieldName : fieldMap.keySet()) {
        Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
        String fieldType = String.valueOf(fieldDesc.getType());
        
        if (!fieldsByType.containsKey(fieldType)) {
            fieldsByType.put(fieldType, new List<String>());
        }
        fieldsByType.get(fieldType).add(fieldName);
    }
    
    System.debug('\n📋 FIELDS BY TYPE:');
    System.debug('==================');
    
    for (String fieldType : fieldsByType.keySet()) {
        List<String> fields = fieldsByType.get(fieldType);
        System.debug('\n' + fieldType + ' (' + fields.size() + ' fields):');
        
        // Sort fields alphabetically for easier reading
        fields.sort();
        
        for (String fieldName : fields) {
            Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
            String label = fieldDesc.getLabel();
            System.debug('  • ' + fieldName + ' - "' + label + '"');
        }
    }
    
    // Look for specific patterns
    System.debug('\n🔍 LOOKING FOR SPECIFIC PATTERNS:');
    System.debug('==================================');
    
    // Check for EMP fields
    List<String> empFields = new List<String>();
    for (String fieldName : fieldMap.keySet()) {
        if (fieldName.contains('EMP') || fieldName.contains('emp')) {
            empFields.add(fieldName);
        }
    }
    System.debug('EMP-related fields (' + empFields.size() + '): ' + empFields);
    
    // Check for OPEN_PIPE fields
    List<String> openPipeFields = new List<String>();
    for (String fieldName : fieldMap.keySet()) {
        if (fieldName.contains('OPEN_PIPE') || fieldName.contains('open_pipe')) {
            openPipeFields.add(fieldName);
        }
    }
    System.debug('OPEN_PIPE-related fields (' + openPipeFields.size() + '): ' + openPipeFields);
    
    // Check for CQ fields (Current Quarter)
    List<String> cqFields = new List<String>();
    for (String fieldName : fieldMap.keySet()) {
        if (fieldName.contains('CQ') || fieldName.contains('cq')) {
            cqFields.add(fieldName);
        }
    }
    System.debug('CQ-related fields (' + cqFields.size() + '): ' + cqFields);
    
    // Check for PQ fields (Previous Quarter)
    List<String> pqFields = new List<String>();
    for (String fieldName : fieldMap.keySet()) {
        if (fieldName.contains('PQ') || fieldName.contains('pq')) {
            pqFields.add(fieldName);
        }
    }
    System.debug('PQ-related fields (' + pqFields.size() + '): ' + pqFields);
    
    // Check for UPSELL fields
    List<String> upsellFields = new List<String>();
    for (String fieldName : fieldMap.keySet()) {
        if (fieldName.contains('UPSELL') || fieldName.contains('upsell')) {
            upsellFields.add(fieldName);
        }
    }
    System.debug('UPSELL-related fields (' + upsellFields.size() + '): ' + upsellFields);
    
    // Check for CS fields (Cross-Sell)
    List<String> csFields = new List<String>();
    for (String fieldName : fieldMap.keySet()) {
        if (fieldName.contains('CS_') || fieldName.contains('cs_')) {
            csFields.add(fieldName);
        }
    }
    System.debug('CS-related fields (' + csFields.size() + '): ' + csFields);
    
    // Check for RENEWAL fields
    List<String> renewalFields = new List<String>();
    for (String fieldName : fieldMap.keySet()) {
        if (fieldName.contains('RENEWAL') || fieldName.contains('renewal')) {
            renewalFields.add(fieldName);
        }
    }
    System.debug('RENEWAL-related fields (' + renewalFields.size() + '): ' + renewalFields);
    
    System.debug('\n💡 ANALYSIS COMPLETE');
    System.debug('=====================');
    System.debug('The object has ' + fieldMap.size() + ' fields with various naming conventions.');
    System.debug('Use the patterns above to understand the actual field structure.');
    
} catch (Exception e) {
    System.debug('❌ Error accessing object: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
} 