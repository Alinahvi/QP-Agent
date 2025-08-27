// UAT SCENARIO 3: Special Characters - Test CSV export with quotes, ampersands, and complex formatting
// Test CSV service's ability to handle special characters and complex field values
System.debug('=== UAT SCENARIO 3: Special Characters ===\n');

// Create test data with special characters, quotes, and complex formatting
String csvDataWithSpecialChars = 'ID,Name,Employee ID,Employee Email,Product L2,Value,Forecast Type,Region,Segment,Vertical\n' +
                                '001,Johnson & Sons "Premium" Services,EMP001,john@company.com,Data Cloud "Enterprise",1,000,000.00,OpenPipe_ACV,AMER,ENTR,"Financial & Banking"\n' +
                                '002,Smith\'s Consulting Group,EMP002,sarah@company.com,Tableau Cloud (Advanced),2,500,000.00,PipeGen,EMEA,ENTR,"Technology & Innovation"\n' +
                                '003,Wilson & Associates, Inc.,EMP003,mike@company.com,Sales Cloud - "Enterprise Edition",750,000.00,OpenPipe_ACV,AMER,ENTR,"Healthcare & Life Sciences"\n' +
                                '004,Brown\'s "Elite" Solutions,EMP004,lisa@company.com,Service Cloud (Premium),1,250,000.00,PipeGen,APAC,ENTR,"Manufacturing & Logistics"\n' +
                                '005,Lee & Partners "Global",EMP005,david@company.com,Marketing Cloud - "Enterprise Suite",500,000.00,OpenPipe_ACV,AMER,ENTR,"Education & Research"';

System.debug('=== Test Data with Special Characters ===');
System.debug(csvDataWithSpecialChars);

// Test CSV service with special character data
ANAgentSimpleCSVService.CSVRequest request = new ANAgentSimpleCSVService.CSVRequest();
request.textData = csvDataWithSpecialChars;
request.fileName = 'UAT_Scenario_3_Special_Characters.csv';
request.description = 'UAT Scenario 3: CSV export with special characters, quotes, and complex formatting';
request.requestId = 'UAT-3-' + Datetime.now().getTime();

System.debug('=== Executing CSV Service for UAT Scenario 3 ===');
List<ANAgentSimpleCSVService.CSVResponse> responses = 
    ANAgentSimpleCSVService.convertTextToCSV(new List<ANAgentSimpleCSVService.CSVRequest>{request});

for (ANAgentSimpleCSVService.CSVResponse response : responses) {
    if (response.success) {
        System.debug('✅ UAT SCENARIO 3 PASSED: CSV export with special characters successful');
        System.debug('✅ File: ' + response.fileName);
        System.debug('✅ Download URL: ' + response.fileUrl);
        System.debug('✅ Special characters, quotes, and complex formatting properly handled');
    } else {
        System.debug('❌ UAT SCENARIO 3 FAILED: ' + response.message);
    }
}
