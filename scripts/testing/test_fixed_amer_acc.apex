// Test Fixed AMER ACC Field Mapping
System.debug('=== TESTING FIXED AMER ACC FIELD MAPPING ===');

// Test 1: Simulate what the agent sends (wrong primaryDimension)
System.debug('\n=== TEST 1: Agent sends WORK_LOCATION_COUNTRY__c but value is AMER ACC ===');
ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
request.analysisType = 'MEETINGS';
request.timeFrame = 'CURRENT';
request.primaryDimension = 'WORK_LOCATION_COUNTRY__c'; // Agent sends this incorrectly
request.primaryValue = 'AMER ACC'; // But value is clearly an OU
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

// Test 2: Test with correct primaryDimension
System.debug('\n=== TEST 2: Correct primaryDimension ===');
ANAgentKPIAnalysisHandler.KPIAnalysisRequest correctRequest = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
correctRequest.analysisType = 'MEETINGS';
correctRequest.timeFrame = 'CURRENT';
correctRequest.primaryDimension = 'OU_NAME__c'; // Correct dimension
correctRequest.primaryValue = 'AMER ACC';
correctRequest.maxResults = 10;
correctRequest.includeLearnerProfile = true;
correctRequest.fuzzySearchEnabled = true;

List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> correctResponses = 
    ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{correctRequest});

if (!correctResponses.isEmpty()) {
    System.debug('Correct Response Success: ' + correctResponses[0].success);
    System.debug('Correct Response Message: ' + correctResponses[0].message);
    System.debug('Correct Total AEs: ' + correctResponses[0].totalAEs);
    System.debug('Correct Total Meetings: ' + correctResponses[0].totalMeetings);
    System.debug('Correct Total Call Connects: ' + correctResponses[0].totalCallConnects);
}

// Test 3: Test with country value
System.debug('\n=== TEST 3: Country value (US) ===');
ANAgentKPIAnalysisHandler.KPIAnalysisRequest countryRequest = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
countryRequest.analysisType = 'MEETINGS';
countryRequest.timeFrame = 'CURRENT';
countryRequest.primaryDimension = 'WORK_LOCATION_COUNTRY__c';
countryRequest.primaryValue = 'US'; // This should map to country
countryRequest.maxResults = 5;
countryRequest.includeLearnerProfile = true;
countryRequest.fuzzySearchEnabled = true;

List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> countryResponses = 
    ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{countryRequest});

if (!countryResponses.isEmpty()) {
    System.debug('Country Response Success: ' + countryResponses[0].success);
    System.debug('Country Response Message: ' + countryResponses[0].message);
    System.debug('Country Total AEs: ' + countryResponses[0].totalAEs);
    System.debug('Country Total Meetings: ' + countryResponses[0].totalMeetings);
}

System.debug('\n=== TEST COMPLETE ===');
