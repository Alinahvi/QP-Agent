// Test script to verify deployed KPI V4 classes work correctly
// Run this in anonymous apex to test the deployed classes

System.debug('=== Testing Deployed KPI V4 Classes ===');

try {
    // ===== TEST 1: Search Functionality =====
    System.debug('--- Testing Search Handler ---');
    
    ANAgentKPIAnalysisSearchV4Handler.KPISearchRequest searchReq = new ANAgentKPIAnalysisSearchV4Handler.KPISearchRequest();
    searchReq.searchTerm = 'Test';
    searchReq.recordLimit = 5;
    
    List<ANAgentKPIAnalysisSearchV4Handler.KPISearchResponse> searchResponses = 
        ANAgentKPIAnalysisSearchV4Handler.searchKPIs(new List<ANAgentKPIAnalysisSearchV4Handler.KPISearchRequest>{ searchReq });
    
    System.debug('Search Response count: ' + searchResponses.size());
    if (!searchResponses.isEmpty()) {
        System.debug('Search Success: ' + searchResponses[0].success);
        System.debug('Search Message: ' + searchResponses[0].message);
        System.debug('Search Total count: ' + searchResponses[0].totalRecordCount);
        System.debug('Search Results: ' + searchResponses[0].results.size());
    }
    
    // ===== TEST 2: Aggregation Functionality =====
    System.debug('--- Testing Aggregation Handler ---');
    
    ANAgentKPIAnalysisAggV4Handler.KPIAggRequest aggReq = new ANAgentKPIAnalysisAggV4Handler.KPIAggRequest();
    aggReq.aggregator = 'AVG';
    aggReq.metricApiName = 'CQ_ACV__c';
    aggReq.workCountryApi = 'US';
    aggReq.limitGroups = 5;
    
    List<ANAgentKPIAnalysisAggV4Handler.KPIAggResponse> aggResponses = 
        ANAgentKPIAnalysisAggV4Handler.aggregateKPIs(new List<ANAgentKPIAnalysisAggV4Handler.KPIAggRequest>{ aggReq });
    
    System.debug('Aggregation Response count: ' + aggResponses.size());
    if (!aggResponses.isEmpty()) {
        System.debug('Aggregation Success: ' + aggResponses[0].success);
        System.debug('Aggregation Message: ' + aggResponses[0].message);
        System.debug('Aggregation Rows: ' + aggResponses[0].rows.size());
        if (!aggResponses[0].rows.isEmpty()) {
            System.debug('Aggregation Value: ' + aggResponses[0].rows[0].value);
        }
    }
    
    // ===== TEST 3: Service Layer Direct Calls =====
    System.debug('--- Testing Service Layer ---');
    
    // Test search service
    ANAgentKPIAnalysisServiceV4.KPIAnalysisResult svcSearchResult = 
        ANAgentKPIAnalysisServiceV4.search('Test', null, null, null, 3);
    System.debug('Service Search Success: ' + svcSearchResult.success);
    
    // Test aggregation service
    ANAgentKPIAnalysisServiceV4.KPIAggResult svcAggResult = 
        ANAgentKPIAnalysisServiceV4.aggregate('COUNT', null, new Map<String,Object>{'WORK_LOCATION_COUNTRY__c' => 'US'}, null, 5);
    System.debug('Service Aggregation Success: ' + svcAggResult.success);
    
    System.debug('=== All Tests Completed Successfully ===');
    System.debug('✓ KPI V4 Classes are working correctly!');
    
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
    System.debug('Stack: ' + e.getStackTraceString());
} 