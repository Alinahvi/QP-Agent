// Describe Learner Profile object to understand its structure
System.debug('=== LEARNER PROFILE OBJECT ANALYSIS ===');

// Get object describe
Schema.SObjectType learnerProfileType = Schema.getGlobalDescribe().get('Learner_Profile__c');
if (learnerProfileType != null) {
    Schema.DescribeSObjectResult learnerProfileDescribe = learnerProfileType.getDescribe();
    
    System.debug('Object Name: ' + learnerProfileDescribe.getName());
    System.debug('Label: ' + learnerProfileDescribe.getLabel());
    System.debug('Total Fields: ' + learnerProfileDescribe.fields.getMap().size());
    
    // Get all field names
    Map<String, Schema.SObjectField> fieldMap = learnerProfileDescribe.fields.getMap();
    System.debug('\n=== ALL FIELDS ===');
    for (String fieldName : fieldMap.keySet()) {
        Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
        System.debug('Field: ' + fieldName + ' | Type: ' + fieldDescribe.getType() + ' | Label: ' + fieldDescribe.getLabel());
    }
    
    // Look for specific fields we need
    System.debug('\n=== RELEVANT FIELDS FOR KPI ANALYSIS ===');
    List<String> relevantFields = new List<String>{
        'OU', 'Manager', 'Region', 'Vertical', 'Industry', 'Country', 'Hierarchy',
        'Name', 'Id', 'Profile', 'Location', 'Territory', 'Division', 'Segment'
    };
    
    for (String searchTerm : relevantFields) {
        for (String fieldName : fieldMap.keySet()) {
            if (fieldName.toLowerCase().contains(searchTerm.toLowerCase())) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                System.debug('Found: ' + fieldName + ' | Type: ' + fieldDescribe.getType() + ' | Label: ' + fieldDescribe.getLabel());
            }
        }
    }
} else {
    System.debug('Learner_Profile__c object not found!');
}

// Also check the relationship between AGENT_OU_PIPELINE_V2__c and Learner_Profile__c
System.debug('\n=== AGENT_OU_PIPELINE_V2__c LEARNER PROFILE RELATIONSHIP ===');
Schema.SObjectType pipelineType = Schema.getGlobalDescribe().get('AGENT_OU_PIPELINE_V2__c');
if (pipelineType != null) {
    Schema.DescribeSObjectResult pipelineDescribe = pipelineType.getDescribe();
    Map<String, Schema.SObjectField> pipelineFieldMap = pipelineDescribe.fields.getMap();
    
    for (String fieldName : pipelineFieldMap.keySet()) {
        if (fieldName.toLowerCase().contains('learner') || fieldName.toLowerCase().contains('profile')) {
            Schema.DescribeFieldResult fieldDescribe = pipelineFieldMap.get(fieldName).getDescribe();
            System.debug('Pipeline Field: ' + fieldName + ' | Type: ' + fieldDescribe.getType() + ' | Label: ' + fieldDescribe.getLabel());
        }
    }
}

System.debug('\n=== ANALYSIS COMPLETE ===');
