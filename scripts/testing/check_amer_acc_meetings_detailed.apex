// Check AMER ACC Meeting Data in Detail
System.debug('=== DETAILED AMER ACC MEETING ANALYSIS ===');

// Test 1: Check all AMER ACC records with meeting data (no timeframe filter)
System.debug('\n=== TEST 1: All AMER ACC records with meeting data (no timeframe) ===');
List<AGENT_OU_PIPELINE_V2__c> allRecords = [
    SELECT Id, FULL_NAME__c, OU_NAME__c, CQ_CUSTOMER_MEETING__c, CQ_CALL_CONNECT__c, 
           Fiscal_Quarter__c, Fiscal_Year__c, CreatedDate
    FROM AGENT_OU_PIPELINE_V2__c 
    WHERE OU_NAME__c = 'AMER ACC' 
    AND (CQ_CUSTOMER_MEETING__c > 0 OR CQ_CALL_CONNECT__c > 0)
    ORDER BY CQ_CUSTOMER_MEETING__c DESC
    LIMIT 20
];
System.debug('Records with meetings found: ' + allRecords.size());
for (AGENT_OU_PIPELINE_V2__c record : allRecords) {
    System.debug('Name: ' + record.FULL_NAME__c + 
                ', Meetings: ' + record.CQ_CUSTOMER_MEETING__c + 
                ', Calls: ' + record.CQ_CALL_CONNECT__c +
                ', Quarter: ' + record.Fiscal_Quarter__c +
                ', Year: ' + record.Fiscal_Year__c +
                ', Created: ' + record.CreatedDate);
}

// Test 2: Check what fiscal quarters exist for AMER ACC
System.debug('\n=== TEST 2: Fiscal quarters for AMER ACC ===');
List<AggregateResult> quarters = [
    SELECT Fiscal_Quarter__c, Fiscal_Year__c, COUNT(Id) recordCount,
           SUM(CQ_CUSTOMER_MEETING__c) totalMeetings,
           SUM(CQ_CALL_CONNECT__c) totalCalls
    FROM AGENT_OU_PIPELINE_V2__c 
    WHERE OU_NAME__c = 'AMER ACC'
    GROUP BY Fiscal_Quarter__c, Fiscal_Year__c
    ORDER BY Fiscal_Year__c DESC, Fiscal_Quarter__c DESC
    LIMIT 10
];
for (AggregateResult ar : quarters) {
    System.debug('Quarter: ' + ar.get('Fiscal_Quarter__c') + 
                ', Year: ' + ar.get('Fiscal_Year__c') +
                ', Records: ' + ar.get('recordCount') +
                ', Meetings: ' + ar.get('totalMeetings') +
                ', Calls: ' + ar.get('totalCalls'));
}

// Test 3: Test with PREVIOUS timeframe
System.debug('\n=== TEST 3: Test with PREVIOUS timeframe ===');
ANAgentKPIAnalysisHandler.KPIAnalysisRequest prevRequest = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
prevRequest.analysisType = 'MEETINGS';
prevRequest.timeFrame = 'PREVIOUS'; // Try previous quarter
prevRequest.primaryDimension = 'OU_NAME__c';
prevRequest.primaryValue = 'AMER ACC';
prevRequest.maxResults = 10;
prevRequest.includeLearnerProfile = true;
prevRequest.fuzzySearchEnabled = true;

List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> prevResponses = 
    ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{prevRequest});

if (!prevResponses.isEmpty()) {
    System.debug('Previous Response Success: ' + prevResponses[0].success);
    System.debug('Previous Response Message: ' + prevResponses[0].message);
    System.debug('Previous Total AEs: ' + prevResponses[0].totalAEs);
    System.debug('Previous Total Meetings: ' + prevResponses[0].totalMeetings);
    System.debug('Previous Total Call Connects: ' + prevResponses[0].totalCallConnects);
}

// Test 4: Test with ALL timeframe
System.debug('\n=== TEST 4: Test with ALL timeframe ===');
ANAgentKPIAnalysisHandler.KPIAnalysisRequest allRequest = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
allRequest.analysisType = 'MEETINGS';
allRequest.timeFrame = 'ALL'; // Try all time
allRequest.primaryDimension = 'OU_NAME__c';
allRequest.primaryValue = 'AMER ACC';
allRequest.maxResults = 10;
allRequest.includeLearnerProfile = true;
allRequest.fuzzySearchEnabled = true;

List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> allResponses = 
    ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{allRequest});

if (!allResponses.isEmpty()) {
    System.debug('All Response Success: ' + allResponses[0].success);
    System.debug('All Response Message: ' + allResponses[0].message);
    System.debug('All Total AEs: ' + allResponses[0].totalAEs);
    System.debug('All Total Meetings: ' + allResponses[0].totalMeetings);
    System.debug('All Total Call Connects: ' + allResponses[0].totalCallConnects);
}

System.debug('\n=== DETAILED ANALYSIS COMPLETE ===');
