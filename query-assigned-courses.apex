// Query Assigned_Course__c object for sample data and unique course count
System.debug('=== Querying Assigned_Course__c Object ===');

// First, let's see what fields are available
System.debug('Getting field information...');
Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Assigned_Course__c.fields.getMap();
System.debug('Available fields in Assigned_Course__c:');
for (String fieldName : fieldMap.keySet()) {
    Schema.SObjectField field = fieldMap.get(fieldName);
    Schema.DescribeFieldResult fieldDesc = field.getDescribe();
    System.debug('  - ' + fieldName + ' (' + fieldDesc.getType() + ')');
}

// Query sample data (3 rows)
System.debug('');
System.debug('=== Sample Data (3 rows) ===');
List<Assigned_Course__c> sampleRecords = [
    SELECT Id, Name, CreatedDate, LastModifiedDate
    FROM Assigned_Course__c 
    ORDER BY CreatedDate DESC 
    LIMIT 3
];

if (sampleRecords.isEmpty()) {
    System.debug('❌ No Assigned_Course__c records found');
} else {
    System.debug('Found ' + sampleRecords.size() + ' sample records:');
    for (Integer i = 0; i < sampleRecords.size(); i++) {
        Assigned_Course__c record = sampleRecords[i];
        System.debug('Row ' + (i+1) + ':');
        System.debug('  ID: ' + record.Id);
        System.debug('  Name: ' + record.Name);
        System.debug('  Created Date: ' + record.CreatedDate);
        System.debug('  Last Modified: ' + record.LastModifiedDate);
        System.debug('');
    }
}

// Count total records
System.debug('=== Record Counts ===');
Integer totalRecords = [SELECT COUNT() FROM Assigned_Course__c];
System.debug('Total Assigned_Course__c records: ' + totalRecords);

// Try to find a field that might reference courses
System.debug('');
System.debug('=== Looking for Course-related Fields ===');

// Common field names that might reference courses
List<String> possibleCourseFields = new List<String>{
    'Course__c', 'Course_Id__c', 'CourseId__c', 'Course_Name__c', 
    'CourseId', 'Course__r', 'Related_Course__c'
};

for (String fieldName : possibleCourseFields) {
    if (fieldMap.containsKey(fieldName)) {
        System.debug('✅ Found course-related field: ' + fieldName);
        
        // Query to get unique values for this field
        String query = 'SELECT ' + fieldName + ' FROM Assigned_Course__c WHERE ' + fieldName + ' != null LIMIT 1000';
        try {
            List<Assigned_Course__c> records = Database.query(query);
            Set<String> uniqueValues = new Set<String>();
            for (Assigned_Course__c record : records) {
                Object fieldValue = record.get(fieldName);
                if (fieldValue != null) {
                    uniqueValues.add(String.valueOf(fieldValue));
                }
            }
            System.debug('  Unique values in ' + fieldName + ': ' + uniqueValues.size());
            System.debug('  Sample values: ' + uniqueValues);
        } catch (Exception e) {
            System.debug('  Error querying ' + fieldName + ': ' + e.getMessage());
        }
    }
}

// If we can't find specific course fields, let's show all fields for a sample record
if (sampleRecords.size() > 0) {
    System.debug('');
    System.debug('=== Detailed Sample Record ===');
    Assigned_Course__c sampleRecord = sampleRecords[0];
    
    // Get all field values for this record
    System.debug('Sample record ID: ' + sampleRecord.Id);
    System.debug('Sample record Name: ' + sampleRecord.Name);
    System.debug('Sample record Created Date: ' + sampleRecord.CreatedDate);
    System.debug('Sample record Last Modified: ' + sampleRecord.LastModifiedDate);
} 