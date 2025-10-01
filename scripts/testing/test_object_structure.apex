// Test script to verify Agent_Open_Pipe__c object structure
System.debug('=== Testing Agent_Open_Pipe__c Object Structure ===\n');

// First, let's check if the object exists and get some basic info
try {
    // Get object describe
    Schema.DescribeSObjectResult describeResult = Agent_Open_Pipe__c.SObjectType.getDescribe();
    System.debug('✅ Object exists: ' + describeResult.getName());
    System.debug('✅ Label: ' + describeResult.getLabel());
    System.debug('✅ Fields count: ' + describeResult.fields.getMap().size());
    
    // List all field names
    System.debug('\n=== Available Fields ===');
    for (String fieldName : describeResult.fields.getMap().keySet()) {
        Schema.DescribeFieldResult fieldDescribe = describeResult.fields.getMap().get(fieldName).getDescribe();
        System.debug('Field: ' + fieldName + ' (' + fieldDescribe.getType() + ')');
    }
    
    // Try to query a few records to see what we get
    System.debug('\n=== Testing Basic Query ===');
    List<Agent_Open_Pipe__c> records = [
        SELECT Id, Name 
        FROM Agent_Open_Pipe__c 
        LIMIT 3
    ];
    
    System.debug('Records found: ' + records.size());
    for (Agent_Open_Pipe__c record : records) {
        System.debug('ID: ' + record.Id + ', Name: ' + record.Name);
    }
    
} catch (Exception e) {
    System.debug('❌ Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
