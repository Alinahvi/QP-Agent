// Check AMER ACC Meeting Data
System.debug('=== CHECKING AMER ACC MEETING DATA ===');

// Test 1: Check if there are any meeting records for AMER ACC
System.debug('\n=== TEST 1: Meeting records for AMER ACC ===');
List<AGENT_OU_PIPELINE_V2__c> meetingRecords = [
    SELECT Id, FULL_NAME__c, OU_NAME__c, CQ_CUSTOMER_MEETING__c, CQ_CALL_CONNECT__c
    FROM AGENT_OU_PIPELINE_V2__c 
    WHERE OU_NAME__c = 'AMER ACC' 
    AND (CQ_CUSTOMER_MEETING__c > 0 OR CQ_CALL_CONNECT__c > 0)
    LIMIT 10
];
System.debug('Meeting records found: ' + meetingRecords.size());
for (AGENT_OU_PIPELINE_V2__c record : meetingRecords) {
    System.debug('Name: ' + record.FULL_NAME__c + ', Meetings: ' + record.CQ_CUSTOMER_MEETING__c + ', Calls: ' + record.CQ_CALL_CONNECT__c);
}

// Test 2: Check all AMER ACC records to see if any have meeting data
System.debug('\n=== TEST 2: All AMER ACC records with meeting data ===');
List<AGENT_OU_PIPELINE_V2__c> allAmerAccRecords = [
    SELECT Id, FULL_NAME__c, OU_NAME__c, CQ_CUSTOMER_MEETING__c, CQ_CALL_CONNECT__c
    FROM AGENT_OU_PIPELINE_V2__c 
    WHERE OU_NAME__c = 'AMER ACC' 
    LIMIT 20
];
System.debug('Total AMER ACC records: ' + allAmerAccRecords.size());
Integer meetingCount = 0;
Integer callCount = 0;
for (AGENT_OU_PIPELINE_V2__c record : allAmerAccRecords) {
    if (record.CQ_CUSTOMER_MEETING__c != null && record.CQ_CUSTOMER_MEETING__c > 0) {
        meetingCount++;
        System.debug('Meeting: ' + record.FULL_NAME__c + ' = ' + record.CQ_CUSTOMER_MEETING__c);
    }
    if (record.CQ_CALL_CONNECT__c != null && record.CQ_CALL_CONNECT__c > 0) {
        callCount++;
        System.debug('Call: ' + record.FULL_NAME__c + ' = ' + record.CQ_CALL_CONNECT__c);
    }
}
System.debug('Records with meetings: ' + meetingCount);
System.debug('Records with calls: ' + callCount);

// Test 3: Check what analysis types work for AMER ACC
System.debug('\n=== TEST 3: Different analysis types for AMER ACC ===');

// Test GROWTH_FACTORS
ANAgentKPIAnalysisHandler.KPIAnalysisRequest growthRequest = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
growthRequest.analysisType = 'GROWTH_FACTORS';
growthRequest.timeFrame = 'CURRENT';
growthRequest.primaryDimension = 'OU_NAME__c';
growthRequest.primaryValue = 'AMER ACC';
growthRequest.maxResults = 5;
growthRequest.includeLearnerProfile = true;
growthRequest.fuzzySearchEnabled = true;

List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> growthResponses = 
    ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{growthRequest});

if (!growthResponses.isEmpty()) {
    System.debug('GROWTH_FACTORS - Success: ' + growthResponses[0].success);
    System.debug('GROWTH_FACTORS - Total AEs: ' + growthResponses[0].totalAEs);
    System.debug('GROWTH_FACTORS - Avg Coverage: ' + growthResponses[0].avgCoverage);
}

// Test ACV
ANAgentKPIAnalysisHandler.KPIAnalysisRequest acvRequest = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
acvRequest.analysisType = 'ACV';
acvRequest.timeFrame = 'CURRENT';
acvRequest.primaryDimension = 'OU_NAME__c';
acvRequest.primaryValue = 'AMER ACC';
acvRequest.maxResults = 5;
acvRequest.includeLearnerProfile = true;
acvRequest.fuzzySearchEnabled = true;

List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> acvResponses = 
    ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{acvRequest});

if (!acvResponses.isEmpty()) {
    System.debug('ACV - Success: ' + acvResponses[0].success);
    System.debug('ACV - Total AEs: ' + acvResponses[0].totalAEs);
    System.debug('ACV - Total ACV: ' + acvResponses[0].totalACV);
}

System.debug('\n=== CHECK COMPLETE ===');
