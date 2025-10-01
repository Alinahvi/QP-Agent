// Debug AMER ACC Field Mapping Issues
System.debug('=== DEBUGGING AMER ACC FIELD MAPPING ===');

// Test 1: Check what happens when we query AMER ACC as OU
System.debug('\n=== TEST 1: AMER ACC as OU_NAME__c ===');
List<AGENT_OU_PIPELINE_V2__c> ouRecords = [
    SELECT Id, FULL_NAME__c, OU_NAME__c, WORK_LOCATION_COUNTRY__c, CQ_CUSTOMER_MEETING__c, CQ_CALL_CONNECT__c
    FROM AGENT_OU_PIPELINE_V2__c 
    WHERE OU_NAME__c = 'AMER ACC' 
    LIMIT 5
];
System.debug('OU Records found: ' + ouRecords.size());
for (AGENT_OU_PIPELINE_V2__c record : ouRecords) {
    System.debug('OU: ' + record.OU_NAME__c + ', Country: ' + record.WORK_LOCATION_COUNTRY__c + ', Name: ' + record.FULL_NAME__c);
}

// Test 2: Check what happens when we query AMER ACC as Country
System.debug('\n=== TEST 2: AMER ACC as WORK_LOCATION_COUNTRY__c ===');
List<AGENT_OU_PIPELINE_V2__c> countryRecords = [
    SELECT Id, FULL_NAME__c, OU_NAME__c, WORK_LOCATION_COUNTRY__c, CQ_CUSTOMER_MEETING__c, CQ_CALL_CONNECT__c
    FROM AGENT_OU_PIPELINE_V2__c 
    WHERE WORK_LOCATION_COUNTRY__c = 'AMER ACC' 
    LIMIT 5
];
System.debug('Country Records found: ' + countryRecords.size());

// Test 3: Check what OUs exist that contain "AMER"
System.debug('\n=== TEST 3: OUs containing AMER ===');
List<AggregateResult> ouAggregates = [
    SELECT OU_NAME__c, COUNT(Id) recordCount
    FROM AGENT_OU_PIPELINE_V2__c 
    WHERE OU_NAME__c LIKE '%AMER%'
    GROUP BY OU_NAME__c
    ORDER BY COUNT(Id) DESC
    LIMIT 10
];
for (AggregateResult ar : ouAggregates) {
    System.debug('OU: ' + ar.get('OU_NAME__c') + ', Count: ' + ar.get('recordCount'));
}

// Test 4: Check what countries exist
System.debug('\n=== TEST 4: Sample Countries ===');
List<AggregateResult> countryAggregates = [
    SELECT WORK_LOCATION_COUNTRY__c, COUNT(Id) recordCount
    FROM AGENT_OU_PIPELINE_V2__c 
    WHERE WORK_LOCATION_COUNTRY__c != null
    GROUP BY WORK_LOCATION_COUNTRY__c
    ORDER BY COUNT(Id) DESC
    LIMIT 10
];
for (AggregateResult ar : countryAggregates) {
    System.debug('Country: ' + ar.get('WORK_LOCATION_COUNTRY__c') + ', Count: ' + ar.get('recordCount'));
}

// Test 5: Test the actual handler with correct mapping
System.debug('\n=== TEST 5: Handler with OU_NAME__c mapping ===');
ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
request.analysisType = 'MEETINGS';
request.timeFrame = 'CURRENT';
request.primaryDimension = 'OU_NAME__c';
request.primaryValue = 'AMER ACC';
request.maxResults = 10;
request.includeLearnerProfile = true;
request.fuzzySearchEnabled = true;

List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
    ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});

if (!responses.isEmpty()) {
    System.debug('Response Success: ' + responses[0].success);
    System.debug('Response Message: ' + responses[0].message);
    System.debug('Total AEs: ' + responses[0].totalAEs);
    System.debug('Total Meetings: ' + responses[0].totalMeetings);
    System.debug('Total Call Connects: ' + responses[0].totalCallConnects);
} else {
    System.debug('No response received');
}

System.debug('\n=== DEBUG COMPLETE ===');
