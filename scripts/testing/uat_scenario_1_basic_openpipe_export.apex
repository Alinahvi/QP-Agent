// UAT SCENARIO 1: Basic OpenPipe Export - Simple Data
// Test basic CSV export functionality with real data from Agent_Open_Pipe__c
System.debug('=== UAT SCENARIO 1: Basic OpenPipe Export ===\n');

// Query basic OpenPipe records with correct field names
List<Agent_Open_Pipe__c> records = [
    SELECT Id, Name, open_pipe_prod_nm__c, emp_id__c, emp_email_addr__c, 
           open_pipe_original_openpipe_alloc_amt__c, open_pipe_opty_nm__c,
           macrosgment__c, work_location_country__c, open_pipe_opty_stg_nm__c
    FROM Agent_Open_Pipe__c 
    LIMIT 5
];

System.debug('=== Records Found: ' + records.size() + ' ===');
for (Agent_Open_Pipe__c record : records) {
    System.debug('ID: ' + record.Id + ', Product: ' + record.open_pipe_prod_nm__c + ', Amount: ' + record.open_pipe_original_openpipe_alloc_amt__c);
}

// Convert to CSV format with correct field names
String csvData = 'ID,Name,Product Name,Employee ID,Employee Email,Opportunity Amount,Opportunity Name,Macro Segment,Country,Stage\n';
for (Agent_Open_Pipe__c record : records) {
    csvData += record.Id + ',' + 
               (record.Name != null ? record.Name : '') + ',' +
               (record.open_pipe_prod_nm__c != null ? record.open_pipe_prod_nm__c : '') + ',' +
               (record.emp_id__c != null ? String.valueOf(record.emp_id__c) : '') + ',' +
               (record.emp_email_addr__c != null ? record.emp_email_addr__c : '') + ',' +
               (record.open_pipe_original_openpipe_alloc_amt__c != null ? String.valueOf(record.open_pipe_original_openpipe_alloc_amt__c) : '') + ',' +
               (record.open_pipe_opty_nm__c != null ? record.open_pipe_opty_nm__c : '') + ',' +
               (record.macrosgment__c != null ? record.macrosgment__c : '') + ',' +
               (record.work_location_country__c != null ? record.work_location_country__c : '') + ',' +
               (record.open_pipe_opty_stg_nm__c != null ? record.open_pipe_opty_stg_nm__c : '') + '\n';
}

System.debug('=== Generated CSV Data ===');
System.debug(csvData);

// Test CSV service
ANAgentSimpleCSVService.CSVRequest request = new ANAgentSimpleCSVService.CSVRequest();
request.textData = csvData;
request.fileName = 'UAT_Scenario_1_Basic_OpenPipe_Export.csv';
request.description = 'UAT Scenario 1: Basic OpenPipe export with simple data';
request.requestId = 'UAT-1-' + Datetime.now().getTime();

System.debug('=== Executing CSV Service for UAT Scenario 1 ===');
List<ANAgentSimpleCSVService.CSVResponse> responses = 
    ANAgentSimpleCSVService.convertTextToCSV(new List<ANAgentSimpleCSVService.CSVRequest>{request});

for (ANAgentSimpleCSVService.CSVResponse response : responses) {
    if (response.success) {
        System.debug('✅ UAT SCENARIO 1 PASSED: Basic CSV export successful');
        System.debug('✅ File: ' + response.fileName);
        System.debug('✅ Download URL: ' + response.fileUrl);
        System.debug('✅ Records exported: ' + records.size());
    } else {
        System.debug('❌ UAT SCENARIO 1 FAILED: ' + response.message);
    }
}
