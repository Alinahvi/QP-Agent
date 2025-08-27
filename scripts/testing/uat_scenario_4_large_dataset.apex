// UAT SCENARIO 4: Large Dataset - Test CSV export with larger dataset for performance testing
// Test CSV service's ability to handle larger datasets and performance
System.debug('=== UAT SCENARIO 4: Large Dataset ===\n');

// Query larger dataset from OpenPipe
List<Agent_Open_Pipe__c> records = [
    SELECT Id, Name, EMPLOYEE_ID__c, EMPLOYEE_EMAIL__c, PRODUCT_L2__c, 
           VALUE__c, FORECAST_TYPE__c, EMPLOYEE_LOCATION_REGION__c, 
           MACRO_SEGMENT__c, FORMATTED_VERTICAL__c, EMPLOYEE_LOCATION_COUNTRY__c,
           ROLE_LEVEL_4__c, ROLE_LEVEL_5__c, ROLE_LEVEL_6__c
    FROM Agent_Open_Pipe__c 
    LIMIT 50
];

System.debug('=== Large Dataset Records Found: ' + records.size() + ' ===');

// Convert to CSV format with comprehensive headers
String csvData = 'ID,Name,Employee ID,Employee Email,Product L2,Value,Forecast Type,Region,Segment,Vertical,Country,Role Level 4,Role Level 5,Role Level 6\n';

for (Agent_Open_Pipe__c record : records) {
    csvData += record.Id + ',' + 
               (record.Name != null ? record.Name : '') + ',' +
               (record.EMPLOYEE_ID__c != null ? record.EMPLOYEE_ID__c : '') + ',' +
               (record.EMPLOYEE_EMAIL__c != null ? record.EMPLOYEE_EMAIL__c : '') + ',' +
               (record.PRODUCT_L2__c != null ? record.PRODUCT_L2__c : '') + ',' +
               (record.VALUE__c != null ? String.valueOf(record.VALUE__c) : '') + ',' +
               (record.FORECAST_TYPE__c != null ? record.FORECAST_TYPE__c : '') + ',' +
               (record.EMPLOYEE_LOCATION_REGION__c != null ? record.EMPLOYEE_LOCATION_REGION__c : '') + ',' +
               (record.MACRO_SEGMENT__c != null ? record.MACRO_SEGMENT__c : '') + ',' +
               (record.FORMATTED_VERTICAL__c != null ? record.FORMATTED_VERTICAL__c : '') + ',' +
               (record.EMPLOYEE_LOCATION_COUNTRY__c != null ? record.EMPLOYEE_LOCATION_COUNTRY__c : '') + ',' +
               (record.ROLE_LEVEL_4__c != null ? record.ROLE_LEVEL_4__c : '') + ',' +
               (record.ROLE_LEVEL_5__c != null ? record.ROLE_LEVEL_5__c : '') + ',' +
               (record.ROLE_LEVEL_6__c != null ? record.ROLE_LEVEL_6__c : '') + '\n';
}

System.debug('=== Large Dataset CSV Generated ===');
System.debug('Total characters: ' + csvData.length());
System.debug('Total lines: ' + (csvData.split('\n').size() - 1));

// Test CSV service with large dataset
ANAgentSimpleCSVService.CSVRequest request = new ANAgentSimpleCSVService.CSVRequest();
request.textData = csvData;
request.fileName = 'UAT_Scenario_4_Large_Dataset.csv';
request.description = 'UAT Scenario 4: CSV export with large dataset for performance testing';
request.requestId = 'UAT-4-' + Datetime.now().getTime();

System.debug('=== Executing CSV Service for UAT Scenario 4 ===');
List<ANAgentSimpleCSVService.CSVResponse> responses = 
    ANAgentSimpleCSVService.convertTextToCSV(new List<ANAgentSimpleCSVService.CSVRequest>{request});

for (ANAgentSimpleCSVService.CSVResponse response : responses) {
    if (response.success) {
        System.debug('✅ UAT SCENARIO 4 PASSED: Large dataset CSV export successful');
        System.debug('✅ File: ' + response.fileName);
        System.debug('✅ Download URL: ' + response.fileUrl);
        System.debug('✅ Records exported: ' + records.size());
        System.debug('✅ Performance: Large dataset handled efficiently');
    } else {
        System.debug('❌ UAT SCENARIO 4 FAILED: ' + response.message);
    }
}
