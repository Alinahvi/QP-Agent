// Debug script to understand customer ranking issue
// This script will directly test the customer analysis logic

System.debug('=== DEBUGGING CUSTOMER RANKING ISSUE ===');

// Create test request
ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest();
request.analysisType = 'TOP_CUSTOMERS_BY_OPENPIPE';
request.operatingUnit = 'AMER ICE';

System.debug('Request: ' + request);

// Call the service directly
Test.startTest();
ANAgentOpenPipeAnalysisService.OpenPipeAnalysisResponse response = 
    ANAgentOpenPipeAnalysisService.analyzeOpenPipe(request);
Test.stopTest();

System.debug('=== RESPONSE ANALYSIS ===');
System.debug('Success: ' + response.success);
System.debug('Message: ' + response.message);
System.debug('Total Records: ' + response.totalRecords);
System.debug('Detailed Results Count: ' + (response.detailedResults != null ? String.valueOf(response.detailedResults.size()) : 'NULL'));

if (response.detailedResults != null && response.detailedResults.size() > 0) {
    System.debug('=== CUSTOMER RANKING DETAILS ===');
    
    // Print all customers with their amounts
    for (Integer i = 0; i < response.detailedResults.size(); i++) {
        ANAgentOpenPipeAnalysisService.OpenPipeAnalysisResult result = response.detailedResults[i];
        System.debug('Customer ' + i + ': ' + result.customerName + ' - $' + result.amount + ' - AE: ' + result.aeName);
    }
    
    // Check ranking manually
    if (response.detailedResults.size() > 1) {
        System.debug('=== RANKING VERIFICATION ===');
        Decimal previousAmount = response.detailedResults[0].amount;
        System.debug('First customer amount: $' + previousAmount);
        
        for (Integer i = 1; i < response.detailedResults.size(); i++) {
            Decimal currentAmount = response.detailedResults[i].amount;
            System.debug('Customer ' + i + ' amount: $' + currentAmount);
            
            if (currentAmount > previousAmount) {
                System.debug('❌ RANKING ISSUE: Customer ' + i + ' ($' + currentAmount + ') has HIGHER amount than previous ($' + previousAmount + ')');
            } else {
                System.debug('✅ Ranking OK: Customer ' + i + ' ($' + currentAmount + ') has LOWER or EQUAL amount than previous ($' + previousAmount + ')');
            }
            
            previousAmount = currentAmount;
        }
    }
} else {
    System.debug('❌ No detailed results returned');
}

// Also check the raw data to see what's being processed
System.debug('=== RAW DATA CHECK ===');
String query = 'SELECT Id, EMP_ID__c, FULL_NAME__c, OU_NAME__c, ' +
               'OPEN_PIPE_OPTY_NM_1__c, OPEN_PIPE_OPTY_NM_2__c, OPEN_PIPE_OPTY_NM_3__c, ' +
               'OPEN_PIPE_OPTY_NM_4__c, OPEN_PIPE_OPTY_NM_5__c, ' +
               'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c, ' +
               'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_3__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_4__c, ' +
               'OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_5__c ' +
               'FROM AGENT_OU_PIPELINE_V2__c ' +
               'WHERE OU_NAME__c = \'AMER ICE\' AND EMP_ID__c LIKE \'CUST_TEST_%\' ' +
               'LIMIT 3';

List<AGENT_OU_PIPELINE_V2__c> rawRecords = Database.query(query);
System.debug('Raw records found: ' + rawRecords.size());

for (AGENT_OU_PIPELINE_V2__c record : rawRecords) {
    System.debug('=== RAW RECORD ===');
    System.debug('EMP_ID: ' + record.EMP_ID__c);
    System.debug('FULL_NAME: ' + record.FULL_NAME__c);
    System.debug('OU_NAME: ' + record.OU_NAME__c);
    
    // Check each stage
    for (Integer stage = 1; stage <= 5; stage++) {
        String optyName = (String)record.get('OPEN_PIPE_OPTY_NM_' + stage + '__c');
        Decimal amount = (Decimal)record.get('OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_' + stage + '__c');
        System.debug('Stage ' + stage + ': ' + optyName + ' - $' + amount);
    }
}

System.debug('=== DEBUG COMPLETE ==='); 