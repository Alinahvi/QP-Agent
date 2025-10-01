// Comprehensive test for KPI V4 classes (Search + Aggregation)
// Run this in anonymous apex to verify both functionalities work

System.debug('=== Testing KPI V4 Complete Functionality ===');

try {
    // ===== TEST 1: Basic Search =====
    System.debug('--- Testing Search Functionality ---');
    
    ANAgentKPIAnalysisHandlerV4.KPISearchRequest searchReq = new ANAgentKPIAnalysisHandlerV4.KPISearchRequest();
    searchReq.searchTerm = 'Test';
    searchReq.recordLimit = 5;
    
    List<ANAgentKPIAnalysisHandlerV4.KPISearchResponse> searchResponses = 
        ANAgentKPIAnalysisHandlerV4.searchKPIs(new List<ANAgentKPIAnalysisHandlerV4.KPISearchRequest>{ searchReq });
    
    System.debug('Search Response count: ' + searchResponses.size());
    if (!searchResponses.isEmpty()) {
        System.debug('Search Success: ' + searchResponses[0].success);
        System.debug('Search Message: ' + searchResponses[0].message);
        System.debug('Search Total count: ' + searchResponses[0].totalRecordCount);
        System.debug('Search Results: ' + searchResponses[0].results.size());
    }
    
    // ===== TEST 2: Aggregation - Single Value =====
    System.debug('--- Testing Aggregation (Single Value) ---');
    
    ANAgentKPIAnalysisHandlerV4.KPIAggRequest aggReq1 = new ANAgentKPIAnalysisHandlerV4.KPIAggRequest();
    aggReq1.aggregator = 'AVG';
    aggReq1.metricApiName = 'CQ_ACV__c';
    aggReq1.workCountryApi = 'US';
    aggReq1.limitGroups = 5;
    
    List<ANAgentKPIAnalysisHandlerV4.KPIAggResponse> aggResponses1 = 
        ANAgentKPIAnalysisHandlerV4.aggregateKPIs(new List<ANAgentKPIAnalysisHandlerV4.KPIAggRequest>{ aggReq1 });
    
    System.debug('Single Aggregation Response count: ' + aggResponses1.size());
    if (!aggResponses1.isEmpty()) {
        System.debug('Single Aggregation Success: ' + aggResponses1[0].success);
        System.debug('Single Aggregation Message: ' + aggResponses1[0].message);
        System.debug('Single Aggregation Rows: ' + aggResponses1[0].rows.size());
        if (!aggResponses1[0].rows.isEmpty()) {
            System.debug('Single Aggregation Value: ' + aggResponses1[0].rows[0].value);
        }
    }
    
    // ===== TEST 3: Aggregation - Grouped Comparison =====
    System.debug('--- Testing Aggregation (Grouped Comparison) ---');
    
    ANAgentKPIAnalysisHandlerV4.KPIAggRequest aggReq2 = new ANAgentKPIAnalysisHandlerV4.KPIAggRequest();
    aggReq2.aggregator = 'AVG';
    aggReq2.metricApiName = 'CQ_CALL_CONNECT__c';
    aggReq2.groupByApiName = 'WORK_LOCATION_COUNTRY__c';
    aggReq2.limitGroups = 10;
    
    List<ANAgentKPIAnalysisHandlerV4.KPIAggResponse> aggResponses2 = 
        ANAgentKPIAnalysisHandlerV4.aggregateKPIs(new List<ANAgentKPIAnalysisHandlerV4.KPIAggRequest>{ aggReq2 });
    
    System.debug('Grouped Aggregation Response count: ' + aggResponses2.size());
    if (!aggResponses2.isEmpty()) {
        System.debug('Grouped Aggregation Success: ' + aggResponses2[0].success);
        System.debug('Grouped Aggregation Message: ' + aggResponses2[0].message);
        System.debug('Grouped Aggregation Rows: ' + aggResponses2[0].rows.size());
        
        for (ANAgentKPIAnalysisServiceV4.KPIAggRow row : aggResponses2[0].rows) {
            System.debug('Group: ' + row.groupKey + ', Value: ' + row.value);
        }
    }
    
    // ===== TEST 4: Aggregation - Count with Filters =====
    System.debug('--- Testing Aggregation (Count with Filters) ---');
    
    ANAgentKPIAnalysisHandlerV4.KPIAggRequest aggReq3 = new ANAgentKPIAnalysisHandlerV4.KPIAggRequest();
    aggReq3.aggregator = 'COUNT';
    aggReq3.workCountryApi = 'Brazil';
    aggReq3.maxMonthsSinceOnboarding = '6';
    
    List<ANAgentKPIAnalysisHandlerV4.KPIAggResponse> aggResponses3 = 
        ANAgentKPIAnalysisHandlerV4.aggregateKPIs(new List<ANAgentKPIAnalysisHandlerV4.KPIAggRequest>{ aggReq3 });
    
    System.debug('Count Aggregation Response count: ' + aggResponses3.size());
    if (!aggResponses3.isEmpty()) {
        System.debug('Count Aggregation Success: ' + aggResponses3[0].success);
        System.debug('Count Aggregation Message: ' + aggResponses3[0].message);
        System.debug('Count Aggregation Rows: ' + aggResponses3[0].rows.size());
        if (!aggResponses3[0].rows.isEmpty()) {
            System.debug('Count Aggregation Value: ' + aggResponses3[0].rows[0].value);
        }
    }
    
    // ===== TEST 5: Service Layer Direct Calls =====
    System.debug('--- Testing Service Layer Directly ---');
    
    // Test search service
    ANAgentKPIAnalysisServiceV4.KPIAnalysisResult svcSearchResult = 
        ANAgentKPIAnalysisServiceV4.search('Test', null, null, null, 3);
    System.debug('Service Search Success: ' + svcSearchResult.success);
    
    // Test aggregation service
    ANAgentKPIAnalysisServiceV4.KPIAggResult svcAggResult = 
        ANAgentKPIAnalysisServiceV4.aggregate('SUM', 'PQ_ACV__c', new Map<String,Object>{'OU_NAME__c' => 'AMER - FINS'}, null, 5);
    System.debug('Service Aggregation Success: ' + svcAggResult.success);
    
    System.debug('=== KPI V4 Complete Test Completed Successfully ===');
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack: ' + e.getStackTraceString());
} 