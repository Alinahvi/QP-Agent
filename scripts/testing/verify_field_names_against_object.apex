// Comprehensive field name verification script
// This script verifies that all field names used in the service class
// exactly match the actual API field names in the AGENT_OU_PIPELINE_V2__c object

System.debug('=== FIELD NAME VERIFICATION AGAINST OBJECT ===\n');

// Get the object describe to verify field existence
Schema.SObjectType objectType = Schema.getGlobalDescribe().get('AGENT_OU_PIPELINE_V2__c');
if (objectType == null) {
    System.debug('❌ ERROR: AGENT_OU_PIPELINE_V2__c object not found!');
    return;
}

Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();

System.debug('✅ Object found: ' + objectDescribe.getName());
System.debug('Total fields in object: ' + fieldMap.size());

// Define all the fields that the service class uses
Map<String, List<String>> serviceFields = new Map<String, List<String>>{
    'SELECT_FIELDS' => new List<String>{
        'emp_id__c',
        'full_name__c', 
        'emp_email_addr__c',
        'work_location_country__c',
        'ou_name__c',
        'emp_mgr_nm__c',
        'primary_industry__c',
        'definition__c',
        'description__c',
        'learner_profile_id__c',
        'ramp_status__c',
        'time_since_onboarding__c'
    },
    'METRIC_FIELDS' => new List<String>{
        'cq_acv__c',
        'pq_acv__c',
        'cq_pg__c',
        'pq_pg__c',
        'cq_call_connect__c',
        'pq_call_connect__c',
        'cq_customer_meeting__c',
        'pq_customer_meeting__c',
        'coverage__c',
        'val_quota__c',
        'cq_cc_acv__c',
        'pq_cc_acv__c',
        'cq_days_acv__c',
        'pq_days_acv__c',
        'cq_days_acv_part__c',
        'pq_days_acv_part__c',
        'cq_days_pg_part__c',
        'pq_days_pg_part__c',
        'cq_days_pg__c',
        'pq_days_pg__c',
        'aov__c',
        'fulltotalacvquotausd__c',
        'days_to_productivity__c'
    },
    'FILTER_FIELDS' => new List<String>{
        'work_location_country__c',
        'ou_name__c',
        'primary_industry__c',
        'full_name__c',
        'emp_mgr_nm__c',
        'emp_email_addr__c',
        'learner_profile_id__c',
        'definition__c',
        'description__c',
        'ramp_status__c',
        'time_since_onboarding__c'
    },
    'GROUP_FIELDS' => new List<String>{
        'work_location_country__c',
        'ou_name__c',
        'primary_industry__c',
        'full_name__c',
        'emp_mgr_nm__c',
        'emp_email_addr__c',
        'learner_profile_id__c',
        'definition__c',
        'ramp_status__c'
    }
};

// Test Case 1: Verify SELECT fields exist
System.debug('=== Test Case 1: Verify SELECT Fields ===');
List<String> missingSelectFields = new List<String>();
List<String> validSelectFields = new List<String>();

for (String fieldName : serviceFields.get('SELECT_FIELDS')) {
    if (fieldMap.containsKey(fieldName)) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        System.debug('✅ ' + fieldName + ' - Type: ' + fieldDescribe.getType() + ', Label: ' + fieldDescribe.getLabel());
        validSelectFields.add(fieldName);
    } else {
        System.debug('❌ MISSING: ' + fieldName);
        missingSelectFields.add(fieldName);
    }
}

System.debug('Select Fields Summary:');
System.debug('  Valid: ' + validSelectFields.size() + '/' + serviceFields.get('SELECT_FIELDS').size());
System.debug('  Missing: ' + missingSelectFields.size());
if (!missingSelectFields.isEmpty()) {
    System.debug('  Missing fields: ' + missingSelectFields);
}

// Test Case 2: Verify METRIC fields exist
System.debug('\n=== Test Case 2: Verify METRIC Fields ===');
List<String> missingMetricFields = new List<String>();
List<String> validMetricFields = new List<String>();

for (String fieldName : serviceFields.get('METRIC_FIELDS')) {
    if (fieldMap.containsKey(fieldName)) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        System.debug('✅ ' + fieldName + ' - Type: ' + fieldDescribe.getType() + ', Label: ' + fieldDescribe.getLabel());
        validMetricFields.add(fieldName);
    } else {
        System.debug('❌ MISSING: ' + fieldName);
        missingMetricFields.add(fieldName);
    }
}

System.debug('Metric Fields Summary:');
System.debug('  Valid: ' + validMetricFields.size() + '/' + serviceFields.get('METRIC_FIELDS').size());
System.debug('  Missing: ' + missingMetricFields.size());
if (!missingMetricFields.isEmpty()) {
    System.debug('  Missing fields: ' + missingMetricFields);
}

// Test Case 3: Verify FILTER fields exist
System.debug('\n=== Test Case 3: Verify FILTER Fields ===');
List<String> missingFilterFields = new List<String>();
List<String> validFilterFields = new List<String>();

for (String fieldName : serviceFields.get('FILTER_FIELDS')) {
    if (fieldMap.containsKey(fieldName)) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        System.debug('✅ ' + fieldName + ' - Type: ' + fieldDescribe.getType() + ', Label: ' + fieldDescribe.getLabel());
        validFilterFields.add(fieldName);
    } else {
        System.debug('❌ MISSING: ' + fieldName);
        missingFilterFields.add(fieldName);
    }
}

System.debug('Filter Fields Summary:');
System.debug('  Valid: ' + validFilterFields.size() + '/' + serviceFields.get('FILTER_FIELDS').size());
System.debug('  Missing: ' + missingFilterFields.size());
if (!missingFilterFields.isEmpty()) {
    System.debug('  Missing fields: ' + missingFilterFields);
}

// Test Case 4: Verify GROUP fields exist
System.debug('\n=== Test Case 4: Verify GROUP Fields ===');
List<String> missingGroupFields = new List<String>();
List<String> validGroupFields = new List<String>();

for (String fieldName : serviceFields.get('GROUP_FIELDS')) {
    if (fieldMap.containsKey(fieldName)) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        System.debug('✅ ' + fieldName + ' - Type: ' + fieldDescribe.getType() + ', Label: ' + fieldDescribe.getLabel());
        validGroupFields.add(fieldName);
    } else {
        System.debug('❌ MISSING: ' + fieldName);
        missingGroupFields.add(fieldName);
    }
}

System.debug('Group Fields Summary:');
System.debug('  Valid: ' + validGroupFields.size() + '/' + serviceFields.get('GROUP_FIELDS').size());
System.debug('  Missing: ' + missingGroupFields.size());
if (!missingGroupFields.isEmpty()) {
    System.debug('  Missing fields: ' + missingGroupFields);
}

// Test Case 5: Test actual SOQL query to verify field access
System.debug('\n=== Test Case 5: Test SOQL Query Field Access ===');

try {
    // Build a minimal SOQL query with all the fields we need
    String testQuery = 'SELECT ' + String.join(validSelectFields, ', ') + ' FROM AGENT_OU_PIPELINE_V2__c LIMIT 1';
    System.debug('Testing query: ' + testQuery);
    
    List<AGENT_OU_PIPELINE_V2__c> testRecords = Database.query(testQuery);
    System.debug('✅ SOQL query executed successfully');
    System.debug('Records returned: ' + testRecords.size());
    
    if (!testRecords.isEmpty()) {
        AGENT_OU_PIPELINE_V2__c testRecord = testRecords[0];
        System.debug('Sample record ID: ' + testRecord.Id);
        
        // Test accessing a few key fields
        System.debug('Testing field access:');
        System.debug('  emp_id__c: ' + testRecord.emp_id__c);
        System.debug('  full_name__c: ' + testRecord.full_name__c);
        System.debug('  work_location_country__c: ' + testRecord.work_location_country__c);
        System.debug('  ou_name__c: ' + testRecord.ou_name__c);
        
    }
    
} catch (Exception e) {
    System.debug('❌ SOQL query failed: ' + e.getMessage());
    System.debug('This indicates field access issues that need to be fixed');
}

// Test Case 6: Verify field types are appropriate for operations
System.debug('\n=== Test Case 6: Verify Field Types for Operations ===');

Map<String, String> fieldTypeMap = new Map<String, String>();
for (String fieldName : validSelectFields) {
    if (fieldMap.containsKey(fieldName)) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        fieldTypeMap.put(fieldName, String.valueOf(fieldDescribe.getType()));
    }
}

System.debug('Field Types Summary:');
for (String fieldName : fieldTypeMap.keySet()) {
    String fieldType = fieldTypeMap.get(fieldName);
    System.debug('  ' + fieldName + ' -> ' + fieldType);
}

// Test Case 7: Check for any deprecated or inaccessible fields
System.debug('\n=== Test Case 7: Check Field Accessibility ===');

List<String> inaccessibleFields = new List<String>();
List<String> accessibleFields = new List<String>();

for (String fieldName : validSelectFields) {
    if (fieldMap.containsKey(fieldName)) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        
        if (fieldDescribe.isAccessible()) {
            System.debug('✅ ' + fieldName + ' - Accessible');
            accessibleFields.add(fieldName);
        } else {
            System.debug('❌ ' + fieldName + ' - NOT ACCESSIBLE');
            inaccessibleFields.add(fieldName);
        }
    }
}

System.debug('Field Accessibility Summary:');
System.debug('  Accessible: ' + accessibleFields.size() + '/' + validSelectFields.size());
System.debug('  Not Accessible: ' + inaccessibleFields.size());
if (!inaccessibleFields.isEmpty()) {
    System.debug('  Inaccessible fields: ' + inaccessibleFields);
}

// Final Summary
System.debug('\n=== FINAL VERIFICATION SUMMARY ===');
Integer totalFields = serviceFields.get('SELECT_FIELDS').size() + serviceFields.get('METRIC_FIELDS').size() + 
                     serviceFields.get('FILTER_FIELDS').size() + serviceFields.get('GROUP_FIELDS').size();
Integer totalValidFields = validSelectFields.size() + validMetricFields.size() + 
                          validFilterFields.size() + validGroupFields.size();
Integer totalMissingFields = missingSelectFields.size() + missingMetricFields.size() + 
                            missingFilterFields.size() + missingGroupFields.size();

System.debug('Overall Field Verification:');
System.debug('  Total fields checked: ' + totalFields);
System.debug('  Valid fields: ' + totalValidFields);
System.debug('  Missing fields: ' + totalMissingFields);
System.debug('  Success rate: ' + Math.round((totalValidFields * 100.0) / totalFields) + '%');

if (totalMissingFields == 0) {
    System.debug('🎉 ALL FIELDS VERIFIED SUCCESSFULLY!');
    System.debug('The service class field names perfectly match the object API field names.');
} else {
    System.debug('⚠️  SOME FIELDS ARE MISSING OR MISMATCHED!');
    System.debug('Please review and fix the missing fields before deployment.');
}

System.debug('\n=== FIELD VERIFICATION COMPLETE ==='); 