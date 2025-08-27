// Test Open Pipe Analysis with Real Data
// This script tests the service using actual data in the AGENT_OU_PIPELINE_V2__c object

System.debug('=== OPEN PIPE ANALYSIS COMPREHENSIVE TEST WITH REAL DATA ===');

// Test 1: Top Product Analysis by Stage
System.debug('=== TEST 1: TOP PRODUCT ANALYSIS BY STAGE ===');
ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest request1 = new ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest();
request1.analysisType = 'TOP_PRODUCT_BY_STAGE';
request1.operatingUnit = 'AMER ICE';

System.debug('Request: ' + request1);
List<ANAgentOpenPipeAnalysisService.OpenPipeAnalysisResponse> responses1 = ANAgentOpenPipeAnalysisService.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest>{request1});
ANAgentOpenPipeAnalysisService.OpenPipeAnalysisResponse response1 = responses1[0];

System.debug('Response Success: ' + response1.success);
System.debug('Response Message: ' + response1.message);
System.debug('Total Records: ' + response1.totalRecords);
System.debug('Summary: ' + response1.summary);

// Test 2: Top Customers by Open Pipe
System.debug('=== TEST 2: TOP CUSTOMERS BY OPEN PIPE ===');
ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest request2 = new ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest();
request2.analysisType = 'TOP_CUSTOMERS_BY_OPENPIPE';
request2.operatingUnit = 'AMER ICE';

System.debug('Request: ' + request2);
List<ANAgentOpenPipeAnalysisService.OpenPipeAnalysisResponse> responses2 = ANAgentOpenPipeAnalysisService.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest>{request2});
ANAgentOpenPipeAnalysisService.OpenPipeAnalysisResponse response2 = responses2[0];

System.debug('Response Success: ' + response2.success);
System.debug('Response Message: ' + response2.message);
System.debug('Total Records: ' + response2.totalRecords);
System.debug('Detailed Results Count: ' + (response2.detailedResults != null ? String.valueOf(response2.detailedResults.size()) : 'NULL'));

if (response2.detailedResults != null && response2.detailedResults.size() > 0) {
    System.debug('=== TOP CUSTOMERS DETAILS ===');
    for (Integer i = 0; i < Math.min(5, response2.detailedResults.size()); i++) {
        ANAgentOpenPipeAnalysisService.OpenPipeAnalysisResult result = response2.detailedResults[i];
        System.debug('Customer ' + i + ': ' + result.customerName + ' - $' + result.amount + ' - AE: ' + result.aeName);
    }
}

// Test 3: Stagnation and Amount Analysis
System.debug('=== TEST 3: STAGNATION AND AMOUNT ANALYSIS ===');
ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest request3 = new ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest();
request3.analysisType = 'STAGNATION_AND_AMOUNT_ANALYSIS';
request3.operatingUnit = 'AMER ICE';

System.debug('Request: ' + request3);
List<ANAgentOpenPipeAnalysisService.OpenPipeAnalysisResponse> responses3 = ANAgentOpenPipeAnalysisService.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest>{request3});
ANAgentOpenPipeAnalysisService.OpenPipeAnalysisResponse response3 = responses3[0];

System.debug('Response Success: ' + response3.success);
System.debug('Response Message: ' + response3.message);
System.debug('Total Records: ' + response3.totalRecords);
System.debug('Summary: ' + response3.summary);

// Test 4: Skill Recommendations
System.debug('=== TEST 4: SKILL RECOMMENDATIONS ===');
ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest request4 = new ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest();
request4.analysisType = 'SKILL_RECOMMENDATIONS';
request4.operatingUnit = 'AMER ICE';

System.debug('Request: ' + request4);
List<ANAgentOpenPipeAnalysisService.OpenPipeAnalysisResponse> responses4 = ANAgentOpenPipeAnalysisService.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisService.OpenPipeAnalysisRequest>{request4});
ANAgentOpenPipeAnalysisService.OpenPipeAnalysisResponse response4 = responses4[0];

System.debug('Response Success: ' + response4.success);
System.debug('Response Message: ' + response4.message);
System.debug('Total Records: ' + response4.totalRecords);
System.debug('Summary: ' + response4.summary);

// Check real data availability
System.debug('=== REAL DATA AVAILABILITY CHECK ===');
String checkQuery = 'SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c WHERE OU_NAME__c = \'AMER ICE\'';
Integer totalRecords = Database.countQuery(checkQuery);
System.debug('Total AMER ICE records: ' + totalRecords);

String stageQuery = 'SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c WHERE OU_NAME__c = \'AMER ICE\' AND (OPEN_PIPE_OPTY_STG_NM_1__c != null OR OPEN_PIPE_OPTY_STG_NM_2__c != null OR OPEN_PIPE_OPTY_STG_NM_3__c != null OR OPEN_PIPE_OPTY_STG_NM_4__c != null OR OPEN_PIPE_OPTY_STG_NM_5__c != null)';
Integer stageRecords = Database.countQuery(stageQuery);
System.debug('AMER ICE records with stage data: ' + stageRecords);

String amountQuery = 'SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c WHERE OU_NAME__c = \'AMER ICE\' AND (OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c != null OR OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c != null OR OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_3__c != null OR OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_4__c != null OR OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_5__c != null)';
Integer amountRecords = Database.countQuery(amountQuery);
System.debug('AMER ICE records with amount data: ' + amountRecords);

System.debug('=== TEST COMPLETE ==='); 