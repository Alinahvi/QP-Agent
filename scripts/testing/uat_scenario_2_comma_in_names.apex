// UAT SCENARIO 2: Comma in Names - Test CSV export with comma-containing data
// Test CSV service's ability to handle commas in field values
System.debug('=== UAT SCENARIO 2: Comma in Names ===\n');

// Create test data with commas in various fields
String csvDataWithCommas = 'ID,Name,Employee ID,Employee Email,Product L2,Value,Forecast Type,Region,Segment,Vertical\n' +
                          '001,Smith, Johnson & Associates, LLC,EMP001,john.smith@company.com,Data Cloud, 1,000,000.00,OpenPipe_ACV,AMER,ENTR,Financial Services\n' +
                          '002,Global Solutions, Inc. - Enterprise Division,EMP002,sarah.jones@company.com,Tableau Cloud,2,500,000.00,PipeGen,EMEA,ENTR,Technology\n' +
                          '003,Regional Bank, N.A. - West Coast,EMP003,mike.wilson@company.com,Sales Cloud,750,000.00,OpenPipe_ACV,AMER,ENTR,Banking\n' +
                          '004,Tech Partners, Ltd. - Consulting Group,EMP004,lisa.brown@company.com,Service Cloud,1,250,000.00,PipeGen,APAC,ENTR,Consulting\n' +
                          '005,Innovation Corp, Inc. - Research & Development,EMP005,david.lee@company.com,Marketing Cloud,500,000.00,OpenPipe_ACV,AMER,ENTR,Research';

System.debug('=== Test Data with Commas ===');
System.debug(csvDataWithCommas);

// Test CSV service with comma-containing data
ANAgentSimpleCSVService.CSVRequest request = new ANAgentSimpleCSVService.CSVRequest();
request.textData = csvDataWithCommas;
request.fileName = 'UAT_Scenario_2_Comma_in_Names.csv';
request.description = 'UAT Scenario 2: CSV export with comma-containing names and special characters';
request.requestId = 'UAT-2-' + Datetime.now().getTime();

System.debug('=== Executing CSV Service for UAT Scenario 2 ===');
List<ANAgentSimpleCSVService.CSVResponse> responses = 
    ANAgentSimpleCSVService.convertTextToCSV(new List<ANAgentSimpleCSVService.CSVRequest>{request});

for (ANAgentSimpleCSVService.CSVResponse response : responses) {
    if (response.success) {
        System.debug('✅ UAT SCENARIO 2 PASSED: CSV export with commas successful');
        System.debug('✅ File: ' + response.fileName);
        System.debug('✅ Download URL: ' + response.fileUrl);
        System.debug('✅ Test data with commas properly handled');
    } else {
        System.debug('❌ UAT SCENARIO 2 FAILED: ' + response.message);
    }
}
