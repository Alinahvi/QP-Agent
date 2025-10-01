// Test Enhanced KPI Analysis UX with Human Language Insights
System.debug('=== ENHANCED KPI ANALYSIS UX TEST ===');

// Test 1: AMER ACC Growth Factors with enhanced UX
System.debug('\n=== TEST 1: AMER ACC Growth Factors ===');
ANAgentKPIAnalysisHandler.KPIAnalysisRequest request1 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
request1.analysisType = 'GROWTH_FACTORS';
request1.timeFrame = 'CURRENT';
request1.primaryDimension = 'OU_NAME__c';
request1.primaryValue = 'AMER ACC';
request1.maxResults = 10;
request1.includeLearnerProfile = true;
request1.fuzzySearchEnabled = true;

List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses1 = 
    ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request1});

if (!responses1.isEmpty()) {
    System.debug('Response 1 - Enhanced UX:');
    System.debug(responses1[0].message);
    System.debug('Success: ' + responses1[0].success);
    System.debug('Total AEs: ' + responses1[0].totalAEs);
    System.debug('Warnings: ' + responses1[0].warnings);
} else {
    System.debug('No response received for AMER ACC Growth Factors');
}

// Test 2: EMEA SMB Meetings Analysis with enhanced UX
System.debug('\n=== TEST 2: EMEA SMB Meetings ===');
ANAgentKPIAnalysisHandler.KPIAnalysisRequest request2 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
request2.analysisType = 'MEETINGS';
request2.timeFrame = 'CURRENT';
request2.primaryDimension = 'OU_NAME__c';
request2.primaryValue = 'EMEA SMB';
request2.maxResults = 10;
request2.includeLearnerProfile = true;
request2.fuzzySearchEnabled = true;

List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses2 = 
    ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request2});

if (!responses2.isEmpty()) {
    System.debug('Response 2 - Enhanced UX:');
    System.debug(responses2[0].message);
    System.debug('Success: ' + responses2[0].success);
    System.debug('Total AEs: ' + responses2[0].totalAEs);
    System.debug('Total Meetings: ' + responses2[0].totalMeetings);
} else {
    System.debug('No response received for EMEA SMB Meetings');
}

// Test 3: US Country Analysis with enhanced UX
System.debug('\n=== TEST 3: US Country Analysis ===');
ANAgentKPIAnalysisHandler.KPIAnalysisRequest request3 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
request3.analysisType = 'MEETINGS';
request3.timeFrame = 'CURRENT';
request3.primaryDimension = 'WORK_LOCATION_COUNTRY__c';
request3.primaryValue = 'US';
request3.maxResults = 10;
request3.includeLearnerProfile = true;
request3.fuzzySearchEnabled = true;

List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses3 = 
    ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request3});

if (!responses3.isEmpty()) {
    System.debug('Response 3 - Enhanced UX:');
    System.debug(responses3[0].message);
    System.debug('Success: ' + responses3[0].success);
    System.debug('Total AEs: ' + responses3[0].totalAEs);
} else {
    System.debug('No response received for US Country Analysis');
}

System.debug('\n=== ENHANCED KPI UX TEST COMPLETE ===');
