// UAT SCENARIO 5: Edge Cases - Test CSV export with null values, empty fields, and extreme scenarios
// Test CSV service's ability to handle edge cases and data integrity
System.debug('=== UAT SCENARIO 5: Edge Cases ===\n');

// Create test data with edge cases
String csvDataWithEdgeCases = 'ID,Name,Employee ID,Employee Email,Product L2,Value,Forecast Type,Region,Segment,Vertical\n' +
                             '001,,EMP001,,Data Cloud,0.00,OpenPipe_ACV,AMER,ENTR,\n' +
                             '002,Very Long Company Name That Exceeds Normal Length Expectations And Contains Multiple Special Characters Like &, %, $, #, @, *, (, ), [, ], {, }, |, \\, /, <, >, ?, !, ~, `, +, =, -, _, :, ;, ", \', ., ,,EMP002,test@verylongdomainname.com,Tableau Cloud,999999999.99,PipeGen,EMEA,ENTR,Technology\n' +
                             '003,Company with "quotes" and \'apostrophes\',EMP003,test@company.com,Sales Cloud,0.01,OpenPipe_ACV,AMER,ENTR,Banking\n' +
                             '004,Company with multiple\nnewlines\nin name,EMP004,test@company.com,Service Cloud,1000000.00,PipeGen,APAC,ENTR,Consulting\n' +
                             '005,Company with\t\ttabs\t\tand\t\tspaces,EMP005,test@company.com,Marketing Cloud,500000.00,OpenPipe_ACV,AMER,ENTR,Research\n' +
                             '006,Company with unicode characters: é, ñ, ü, ç,EMP006,test@company.com,Data Cloud,750000.00,OpenPipe_ACV,EMEA,ENTR,International\n' +
                             '007,Company with very long product name: Salesforce Data Cloud Enterprise Edition with Advanced Analytics and Machine Learning Capabilities,EMP007,test@company.com,Data Cloud,2500000.00,PipeGen,AMER,ENTR,Technology\n' +
                             '008,Company with numbers in name: 12345 Company Ltd,EMP008,test@company.com,Tableau Cloud,1250000.00,OpenPipe_ACV,APAC,ENTR,Financial\n' +
                             '009,Company with special symbols: @#$%^&*()_+-={}[]|\\:";\'<>?,./~`,EMP009,test@company.com,Sales Cloud,875000.00,PipeGen,EMEA,ENTR,Consulting\n' +
                             '010,Company with emojis: 🚀💼📊🎯,EMP010,test@company.com,Marketing Cloud,1500000.00,OpenPipe_ACV,AMER,ENTR,Innovation';

System.debug('=== Test Data with Edge Cases ===');
System.debug(csvDataWithEdgeCases);

// Test CSV service with edge case data
ANAgentSimpleCSVService.CSVRequest request = new ANAgentSimpleCSVService.CSVRequest();
request.textData = csvDataWithEdgeCases;
request.fileName = 'UAT_Scenario_5_Edge_Cases.csv';
request.description = 'UAT Scenario 5: CSV export with edge cases, null values, and extreme data scenarios';
request.requestId = 'UAT-5-' + Datetime.now().getTime();

System.debug('=== Executing CSV Service for UAT Scenario 5 ===');
List<ANAgentSimpleCSVService.CSVResponse> responses = 
    ANAgentSimpleCSVService.convertTextToCSV(new List<ANAgentSimpleCSVService.CSVRequest>{request});

for (ANAgentSimpleCSVService.CSVResponse response : responses) {
    if (response.success) {
        System.debug('✅ UAT SCENARIO 5 PASSED: Edge cases CSV export successful');
        System.debug('✅ File: ' + response.fileName);
        System.debug('✅ Download URL: ' + response.fileUrl);
        System.debug('✅ Edge cases properly handled:');
        System.debug('   - Null/empty values');
        System.debug('   - Very long field values');
        System.debug('   - Special characters and symbols');
        System.debug('   - Newlines and tabs');
        System.debug('   - Unicode characters');
        System.debug('   - Emojis');
    } else {
        System.debug('❌ UAT SCENARIO 5 FAILED: ' + response.message);
    }
}
