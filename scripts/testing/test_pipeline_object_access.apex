/**
 * @description Test script to check AGENT_OU_PIPELINE_V2__c object access
 * @author AI Assistant
 * @version 1.0
 */
System.debug('=== TESTING PIPELINE OBJECT ACCESS ===');

try {
    // Test 1: Check if object is accessible
    System.debug('--- Test 1: Object Accessibility ---');
    
    // Try to describe the object
    Schema.DescribeSObjectResult objectDesc = AGENT_OU_PIPELINE_V2__c.SObjectType.getDescribe();
    System.debug('Object accessible: ' + objectDesc.isAccessible());
    System.debug('Object createable: ' + objectDesc.isCreateable());
    System.debug('Object updateable: ' + objectDesc.isUpdateable());
    System.debug('Object deleteable: ' + objectDesc.isDeletable());
    
    // Test 2: Check field accessibility
    System.debug('--- Test 2: Field Accessibility ---');
    
    Map<String, Schema.SObjectField> fieldMap = objectDesc.fields.getMap();
    List<String> testFields = new List<String>{
        'EMP_ID__c', 'FULL_NAME__c', 'EMP_EMAIL_ADDR__c', 'OU_NAME__c', 
        'PRIMARY_INDUSTRY__c', 'COVERAGE__c', 'FULLTOTALACVQUOTAUSD__c'
    };
    
    for (String fieldName : testFields) {
        if (fieldMap.containsKey(fieldName)) {
            Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
            System.debug('Field ' + fieldName + ': accessible=' + fieldDesc.isAccessible() + ', readable=' + fieldDesc.isAccessible());
        } else {
            System.debug('Field ' + fieldName + ': NOT FOUND');
        }
    }
    
    // Test 3: Try a simple query
    System.debug('--- Test 3: Simple Query Test ---');
    
    List<AGENT_OU_PIPELINE_V2__c> testRecords = [
        SELECT EMP_ID__c, FULL_NAME__c, OU_NAME__c 
        FROM AGENT_OU_PIPELINE_V2__c 
        LIMIT 1
    ];
    
    System.debug('Query successful: ' + testRecords.size() + ' records found');
    if (testRecords.size() > 0) {
        System.debug('Sample record: ' + testRecords[0]);
    }
    
    // Test 4: Check if our service class can be instantiated
    System.debug('--- Test 4: Service Class Test ---');
    
    try {
        ANAgentPipelineSearchService.PipelineSearchResult result = 
            ANAgentPipelineSearchService.searchPipeline('Test', 'All', 1, false);
        System.debug('Service class accessible: ' + result.success);
        System.debug('Records found: ' + result.records.size());
    } catch (Exception e) {
        System.debug('Service class error: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
    
    System.debug('=== OBJECT ACCESS TEST COMPLETED ===');
    
} catch (Exception e) {
    System.debug('=== TEST FAILED WITH EXCEPTION ===');
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
    throw e;
} 