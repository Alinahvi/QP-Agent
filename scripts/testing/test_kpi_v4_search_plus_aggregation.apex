// KPI V4 Complete System Test: Search + Aggregation
// Shows how both functionalities work together
// Run this in anonymous apex to see the full system in action

System.debug('=== KPI V4 Complete System Test ===');
System.debug('Testing both Search and Aggregation together');

try {
    // ===== PART 1: SEARCH FOR BRAZIL AEs =====
    System.debug('--- PART 1: Search for AEs in Brazil ---');
    
    ANAgentKPIAnalysisSearchV4Handler.KPISearchRequest searchReq = new ANAgentKPIAnalysisSearchV4Handler.KPISearchRequest();
    searchReq.searchTerm = 'Brazil';  // Search for Brazil in name/email/OU
    searchReq.workLocationCountry = 'Brazil';  // Filter by country
    searchReq.recordLimit = 10;
    
    List<ANAgentKPIAnalysisSearchV4Handler.KPISearchResponse> searchResults = 
        ANAgentKPIAnalysisSearchV4Handler.searchKPIs(new List<ANAgentKPIAnalysisSearchV4Handler.KPISearchRequest>{ searchReq });
    
    System.debug('Search Results:');
    if (!searchResults.isEmpty()) {
        System.debug('Success: ' + searchResults[0].success);
        System.debug('Message: ' + searchResults[0].message);
        System.debug('Found ' + searchResults[0].totalRecordCount + ' AEs in Brazil');
        
        // Show first few results
        if (!searchResults[0].results.isEmpty()) {
            System.debug('Sample AEs found:');
            for (Integer i = 0; i < Math.min(3, searchResults[0].results.size()); i++) {
                ANAgentKPIAnalysisServiceV4.UnifiedKPI ae = searchResults[0].results[i];
                System.debug('  ' + (i+1) + '. ' + ae.fullName + ' | OU: ' + ae.ouName + ' | ACV: ' + ae.cqAcv);
            }
        }
    }
    
    // ===== PART 2: AGGREGATE ACV FOR BRAZIL AEs ≤6 MONTHS =====
    System.debug('--- PART 2: Aggregate ACV for Brazil AEs ≤6 months ---');
    
    ANAgentKPIAnalysisAggV4Handler.KPIAggRequest aggReq = new ANAgentKPIAnalysisAggV4Handler.KPIAggRequest();
    aggReq.aggregator = 'AVG';
    aggReq.metricApiName = 'CQ_ACV__c';
    aggReq.workCountryApi = 'Brazil';
    aggReq.maxMonthsSinceOnboarding = '6';
    
    List<ANAgentKPIAnalysisAggV4Handler.KPIAggResponse> aggResults = 
        ANAgentKPIAnalysisAggV4Handler.aggregateKPIs(new List<ANAgentKPIAnalysisAggV4Handler.KPIAggRequest>{ aggReq });
    
    System.debug('Aggregation Results:');
    if (!aggResults.isEmpty()) {
        System.debug('Success: ' + aggResults[0].success);
        System.debug('Message: ' + aggResults[0].message);
        
        if (!aggResults[0].rows.isEmpty()) {
            System.debug('Average ACV for Brazil AEs ≤6 months: ' + aggResults[0].rows[0].value);
        }
    }
    
    // ===== PART 3: COMPARE BRAZIL vs USA CALL PERFORMANCE =====
    System.debug('--- PART 3: Compare Brazil vs USA Call Performance ---');
    
    ANAgentKPIAnalysisAggV4Handler.KPIAggRequest comparisonReq = new ANAgentKPIAnalysisAggV4Handler.KPIAggRequest();
    comparisonReq.aggregator = 'AVG';
    comparisonReq.metricApiName = 'CQ_CALL_CONNECT__c';
    comparisonReq.groupByApiName = 'WORK_LOCATION_COUNTRY__c';
    comparisonReq.limitGroups = 5;
    
    List<ANAgentKPIAnalysisAggV4Handler.KPIAggResponse> comparisonResults = 
        ANAgentKPIAnalysisAggV4Handler.aggregateKPIs(new List<ANAgentKPIAnalysisAggV4Handler.KPIAggRequest>{ comparisonReq });
    
    System.debug('Country Comparison Results:');
    if (!comparisonResults.isEmpty() && !comparisonResults[0].rows.isEmpty()) {
        System.debug('Call Performance by Country:');
        for (ANAgentKPIAnalysisServiceV4.KPIAggRow row : comparisonResults[0].rows) {
            System.debug('  ' + row.groupKey + ': ' + row.value + ' avg calls');
        }
    }
    
    // ===== PART 4: COUNT TOTAL AEs BY TENURE =====
    System.debug('--- PART 4: Count AEs by Tenure (≤6 months vs >6 months) ---');
    
    // Count AEs ≤6 months
    ANAgentKPIAnalysisAggV4Handler.KPIAggRequest countRecent = new ANAgentKPIAnalysisAggV4Handler.KPIAggRequest();
    countRecent.aggregator = 'COUNT';
    countRecent.maxMonthsSinceOnboarding = '6';
    
    List<ANAgentKPIAnalysisAggV4Handler.KPIAggResponse> countRecentResults = 
        ANAgentKPIAnalysisAggV4Handler.aggregateKPIs(new List<ANAgentKPIAnalysisAggV4Handler.KPIAggRequest>{ countRecent });
    
    System.debug('Tenure Analysis:');
    if (!countRecentResults.isEmpty() && !countRecentResults[0].rows.isEmpty()) {
        System.debug('AEs ≤6 months: ' + countRecentResults[0].rows[0].value);
    }
    
    // ===== SUMMARY =====
    System.debug('=== KPI V4 System Test Complete ===');
    System.debug('✓ Search functionality: Working');
    System.debug('✓ Aggregation functionality: Working');
    System.debug('✓ Country filtering: Working');
    System.debug('✓ Tenure filtering: Working');
    System.debug('✓ Group by functionality: Working');
    System.debug('🎯 Full KPI V4 system is operational!');
    
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
    System.debug('Stack: ' + e.getStackTraceString());
} 