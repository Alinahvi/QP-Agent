// Comprehensive test for enhanced KPI Analysis system with fuzzy search and learner profile integration
System.debug('=== ENHANCED KPI ANALYSIS SYSTEM TEST ===');

// Test 1: Basic AMER ACC Growth Factors with fuzzy search
System.debug('\n--- Test 1: AMER ACC Growth Factors with Fuzzy Search ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request.analysisType = 'GROWTH_FACTORS';
    request.timeFrame = 'CURRENT';
    request.primaryDimension = 'OU_NAME__c';
    request.primaryValue = 'AMER'; // Test fuzzy matching
    request.maxResults = 10;
    request.includeLearnerProfile = true;
    request.fuzzySearchEnabled = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
    
    System.debug('Handler Response Count: ' + responses.size());
    if (!responses.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Total Records: ' + response.totalRecordCount);
        System.debug('OU Name: ' + response.ouName);
        System.debug('Total AEs: ' + response.totalAEs);
        System.debug('Avg Coverage: ' + response.avgCoverage);
        System.debug('Total ACV: ' + response.totalACV);
        System.debug('Total PG: ' + response.totalPG);
        System.debug('Warnings: ' + response.warnings);
        System.debug('Fuzzy Matches: ' + response.fuzzyMatches);
        System.debug('Learner Profiles Count: ' + (response.learnerProfiles != null ? response.learnerProfiles.size() : 0));
        
        // Show sample learner profile data
        if (response.learnerProfiles != null && !response.learnerProfiles.isEmpty()) {
            ANAgentKPIAnalysisService.LearnerProfileData sampleProfile = response.learnerProfiles[0];
            System.debug('Sample Learner Profile:');
            System.debug('  Name: ' + sampleProfile.fullName);
            System.debug('  OU: ' + sampleProfile.ou);
            System.debug('  Manager: ' + sampleProfile.manager);
            System.debug('  Region: ' + sampleProfile.region);
            System.debug('  Vertical: ' + sampleProfile.vertical);
            System.debug('  Industry: ' + sampleProfile.industry);
            System.debug('  Country: ' + sampleProfile.country);
            System.debug('  Manager Hierarchy: ' + sampleProfile.managerHierarchy);
        }
    }
} catch (Exception e) {
    System.debug('Handler Test Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

// Test 2: Fuzzy search for different OU variations
System.debug('\n--- Test 2: Fuzzy Search for OU Variations ---');
List<String> ouVariations = new List<String>{'AMER', 'AMERICAS', 'AMERICA', 'EMEA', 'EUROPE', 'APAC', 'ASIA'};
for (String ou : ouVariations) {
    try {
        ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
        request.analysisType = 'GROWTH_FACTORS';
        request.timeFrame = 'CURRENT';
        request.primaryDimension = 'OU_NAME__c';
        request.primaryValue = ou;
        request.maxResults = 5;
        request.fuzzySearchEnabled = true;
        
        List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
        
        if (!responses.isEmpty()) {
            ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
            System.debug('OU: ' + ou + ' - Success: ' + response.success + ', Records: ' + response.totalRecordCount + ', Fuzzy Matches: ' + response.fuzzyMatches);
        } else {
            System.debug('OU: ' + ou + ' - No responses');
        }
    } catch (Exception e) {
        System.debug('OU: ' + ou + ' - Error: ' + e.getMessage());
    }
}

// Test 3: Country fuzzy search
System.debug('\n--- Test 3: Country Fuzzy Search ---');
List<String> countryVariations = new List<String>{'US', 'USA', 'UNITED STATES', 'UK', 'UNITED KINGDOM', 'CANADA', 'AUSTRALIA'};
for (String country : countryVariations) {
    try {
        ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
        request.analysisType = 'GROWTH_FACTORS';
        request.timeFrame = 'CURRENT';
        request.primaryDimension = 'WORK_LOCATION_COUNTRY__c';
        request.primaryValue = country;
        request.maxResults = 5;
        request.fuzzySearchEnabled = true;
        
        List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
        
        if (!responses.isEmpty()) {
            ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
            System.debug('Country: ' + country + ' - Success: ' + response.success + ', Records: ' + response.totalRecordCount + ', Fuzzy Matches: ' + response.fuzzyMatches);
        } else {
            System.debug('Country: ' + country + ' - No responses');
        }
    } catch (Exception e) {
        System.debug('Country: ' + country + ' - Error: ' + e.getMessage());
    }
}

// Test 4: Direct service test with learner profile data
System.debug('\n--- Test 4: Direct Service Test with Learner Profile Data ---');
try {
    ANAgentKPIAnalysisService.KPIAnalysisRequest serviceRequest = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    serviceRequest.analysisType = 'GROWTH_FACTORS';
    serviceRequest.timeFrame = 'CURRENT';
    serviceRequest.ouName = 'AMER ACC';
    serviceRequest.maxResults = 5;
    serviceRequest.includeLearnerProfile = true;
    serviceRequest.fuzzySearchEnabled = true;
    
    List<ANAgentKPIAnalysisService.KPIAnalysisResponse> serviceResponses = ANAgentKPIAnalysisService.analyzeKPIs(new List<ANAgentKPIAnalysisService.KPIAnalysisRequest>{serviceRequest});
    
    System.debug('Service Response Count: ' + serviceResponses.size());
    if (!serviceResponses.isEmpty()) {
        ANAgentKPIAnalysisService.KPIAnalysisResponse serviceResponse = serviceResponses[0];
        System.debug('Service Success: ' + serviceResponse.success);
        System.debug('Service Message: ' + serviceResponse.message);
        System.debug('Service Total Records: ' + serviceResponse.totalRecordCount);
        System.debug('Service OU Name: ' + serviceResponse.ouName);
        System.debug('Service Total AEs: ' + serviceResponse.totalAEs);
        System.debug('Service Learner Profiles Count: ' + (serviceResponse.learnerProfiles != null ? serviceResponse.learnerProfiles.size() : 0));
        System.debug('Service Fuzzy Matches: ' + serviceResponse.fuzzyMatches);
    }
} catch (Exception e) {
    System.debug('Service Test Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

// Test 5: Meetings analysis with learner profile
System.debug('\n--- Test 5: Meetings Analysis with Learner Profile ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request.analysisType = 'MEETINGS';
    request.timeFrame = 'CURRENT';
    request.primaryDimension = 'OU_NAME__c';
    request.primaryValue = 'AMER ACC';
    request.maxResults = 10;
    request.includeLearnerProfile = true;
    request.fuzzySearchEnabled = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
    
    System.debug('Meetings Handler Response Count: ' + responses.size());
    if (!responses.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
        System.debug('Meetings Success: ' + response.success);
        System.debug('Meetings Message: ' + response.message);
        System.debug('Total Meetings: ' + response.totalMeetings);
        System.debug('Total Call Connects: ' + response.totalCallConnects);
        System.debug('Warnings: ' + response.warnings);
        System.debug('Learner Profiles Count: ' + (response.learnerProfiles != null ? response.learnerProfiles.size() : 0));
    }
} catch (Exception e) {
    System.debug('Meetings Test Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

// Test 6: Test with both OU and Country filters
System.debug('\n--- Test 6: Combined OU and Country Filters ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request.analysisType = 'GROWTH_FACTORS';
    request.timeFrame = 'CURRENT';
    request.primaryDimension = 'OU_NAME__c';
    request.primaryValue = 'AMER';
    request.secondaryDimension = 'WORK_LOCATION_COUNTRY__c';
    request.secondaryValue = 'US';
    request.maxResults = 10;
    request.includeLearnerProfile = true;
    request.fuzzySearchEnabled = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{request});
    
    System.debug('Combined Filter Response Count: ' + responses.size());
    if (!responses.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
        System.debug('Combined Success: ' + response.success);
        System.debug('Combined Records: ' + response.totalRecordCount);
        System.debug('OU Name: ' + response.ouName);
        System.debug('Country: ' + response.country);
        System.debug('Fuzzy Matches: ' + response.fuzzyMatches);
    }
} catch (Exception e) {
    System.debug('Combined Filter Test Error: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
}

System.debug('\n=== ENHANCED KPI ANALYSIS SYSTEM TEST COMPLETE ===');
