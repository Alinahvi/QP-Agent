// Check AGENT_OU_PIPELINE_V2__c fields for future pipeline analysis
System.debug('Checking AGENT_OU_PIPELINE_V2__c fields...');

Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.AGENT_OU_PIPELINE_V2__c.fields.getMap();

System.debug('=== RENEWAL FIELDS ===');
for(String fieldName : fieldMap.keySet()) {
    if(fieldName.contains('renewal')) {
        Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
        System.debug('Field: ' + fieldName + ' - Type: ' + fieldDesc.getType() + ' - Label: ' + fieldDesc.getLabel());
    }
}

System.debug('=== CROSS-SELL FIELDS ===');
for(String fieldName : fieldMap.keySet()) {
    if(fieldName.contains('cs_')) {
        Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
        System.debug('Field: ' + fieldName + ' - Type: ' + fieldDesc.getType() + ' - Label: ' + fieldDesc.getLabel());
    }
}

System.debug('=== UPSELL FIELDS ===');
for(String fieldName : fieldMap.keySet()) {
    if(fieldName.contains('upsell')) {
        Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
        System.debug('Field: ' + fieldName + ' - Type: ' + fieldDesc.getType() + ' - Label: ' + fieldDesc.getLabel());
    }
}

System.debug('=== OFF-SELL FIELDS ===');
for(String fieldName : fieldMap.keySet()) {
    if(fieldName.contains('os_')) {
        Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
        System.debug('Field: ' + fieldName + ' - Type: ' + fieldDesc.getType() + ' - Label: ' + fieldDesc.getLabel());
    }
}

System.debug('Field check completed!'); 