// Check for off-sell fields
Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.AGENT_OU_PIPELINE_V2__c.fields.getMap();

System.debug('=== OFF-SELL FIELDS ===');
for(String fieldName : fieldMap.keySet()) {
    if(fieldName.contains('os_') || fieldName.contains('off')) {
        Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
        System.debug('Off-sell Field: ' + fieldName + ' - Type: ' + fieldDesc.getType() + ' - Label: ' + fieldDesc.getLabel());
    }
}

// Also check for any other future pipeline related fields
System.debug('=== OTHER FUTURE PIPELINE FIELDS ===');
for(String fieldName : fieldMap.keySet()) {
    if(fieldName.contains('pipeline') || fieldName.contains('future') || fieldName.contains('opportunity')) {
        Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
        System.debug('Pipeline Field: ' + fieldName + ' - Type: ' + fieldDesc.getType() + ' - Label: ' + fieldDesc.getLabel());
    }
} 