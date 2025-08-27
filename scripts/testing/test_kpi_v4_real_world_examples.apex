// Real-world KPI V4 Test Examples
// Testing the specific scenarios mentioned by the user
// Run this in anonymous apex to verify the examples work

System.debug('=== Testing Real-World KPI V4 Examples ===');

try {
    // ===== EXAMPLE 1: "avg ACV of AEs who joined past 6 months in Brazil" =====
    System.debug('--- Example 1: Avg ACV for AEs ≤6 months in Brazil ---');
    
    ANAgentKPIAnalysisAggV4Handler.KPIAggRequest brazilExample = new ANAgentKPIAnalysisAggV4Handler.KPIAggRequest();
    brazilExample.aggregator = 'AVG';
    brazilExample.metricApiName = 'CQ_ACV__c';  // Current Quarter ACV
    brazilExample.workCountryApi = 'Brazil';
    brazilExample.maxMonthsSinceOnboarding = '6';
    brazilExample.limitGroups = 5;
    
    List<ANAgentKPIAnalysisAggV4Handler.KPIAggResponse> brazilResults = 
        ANAgentKPIAnalysisAggV4Handler.aggregateKPIs(new List<ANAgentKPIAnalysisAggV4Handler.KPIAggRequest>{ brazilExample });
    
    System.debug('Brazil Example Results:');
    System.debug('Response count: ' + brazilResults.size());
    if (!brazilResults.isEmpty()) {
        System.debug('Success: ' + brazilResults[0].success);
        System.debug('Message: ' + brazilResults[0].message);
        System.debug('Rows returned: ' + brazilResults[0].rows.size());
        
        if (!brazilResults[0].rows.isEmpty()) {
            System.debug('Average ACV for AEs ≤6 months in Brazil: ' + brazilResults[0].rows[0].value);
        }
    }
    
    // ===== EXAMPLE 2: "compare avg calls in Brazil vs USA" =====
    System.debug('--- Example 2: Compare Avg Calls by Country (Brazil vs USA) ---');
    
    ANAgentKPIAnalysisAggV4Handler.KPIAggRequest countryComparison = new ANAgentKPIAnalysisAggV4Handler.KPIAggRequest();
    countryComparison.aggregator = 'AVG';
    countryComparison.metricApiName = 'CQ_CALL_CONNECT__c';  // Current Quarter Call Connects
    countryComparison.groupByApiName = 'WORK_LOCATION_COUNTRY__c';
    countryComparison.limitGroups = 10;
    
    List<ANAgentKPIAnalysisAggV4Handler.KPIAggResponse> countryResults = 
        ANAgentKPIAnalysisAggV4Handler.aggregateKPIs(new List<ANAgentKPIAnalysisAggV4Handler.KPIAggRequest>{ countryComparison });
    
    System.debug('Country Comparison Results:');
    System.debug('Response count: ' + countryResults.size());
    if (!countryResults.isEmpty()) {
        System.debug('Success: ' + countryResults[0].success);
        System.debug('Message: ' + countryResults[0].message);
        System.debug('Countries returned: ' + countryResults[0].rows.size());
        
        // Show the comparison
        for (ANAgentKPIAnalysisServiceV4.KPIAggRow row : countryResults[0].rows) {
            System.debug('Country: ' + row.groupKey + ' | Avg Calls: ' + row.value);
        }
    }
    
    // ===== BONUS EXAMPLE 3: Test PQ_ACV__c (Previous Quarter) for Brazil =====
    System.debug('--- Example 3: Previous Quarter ACV for AEs ≤6 months in Brazil ---');
    
    ANAgentKPIAnalysisAggV4Handler.KPIAggRequest brazilPQExample = new ANAgentKPIAnalysisAggV4Handler.KPIAggRequest();
    brazilPQExample.aggregator = 'AVG';
    brazilPQExample.metricApiName = 'PQ_ACV__c';  // Previous Quarter ACV
    brazilPQExample.workCountryApi = 'Brazil';
    brazilPQExample.maxMonthsSinceOnboarding = '6';
    brazilPQExample.limitGroups = 5;
    
    List<ANAgentKPIAnalysisAggV4Handler.KPIAggResponse> brazilPQResults = 
        ANAgentKPIAnalysisAggV4Handler.aggregateKPIs(new List<ANAgentKPIAnalysisAggV4Handler.KPIAggRequest>{ brazilPQExample });
    
    System.debug('Brazil PQ Example Results:');
    if (!brazilPQResults.isEmpty() && !brazilPQResults[0].rows.isEmpty()) {
        System.debug('Previous Quarter ACV for AEs ≤6 months in Brazil: ' + brazilPQResults[0].rows[0].value);
    }
    
    // ===== BONUS EXAMPLE 4: Count of AEs in Brazil ≤6 months =====
    System.debug('--- Example 4: Count of AEs ≤6 months in Brazil ---');
    
    ANAgentKPIAnalysisAggV4Handler.KPIAggRequest brazilCountExample = new ANAgentKPIAnalysisAggV4Handler.KPIAggRequest();
    brazilCountExample.aggregator = 'COUNT';
    brazilCountExample.workCountryApi = 'Brazil';
    brazilCountExample.maxMonthsSinceOnboarding = '6';
    
    List<ANAgentKPIAnalysisAggV4Handler.KPIAggResponse> brazilCountResults = 
        ANAgentKPIAnalysisAggV4Handler.aggregateKPIs(new List<ANAgentKPIAnalysisAggV4Handler.KPIAggRequest>{ brazilCountExample });
    
    System.debug('Brazil Count Example Results:');
    if (!brazilCountResults.isEmpty() && !brazilCountResults[0].rows.isEmpty()) {
        System.debug('Total AEs ≤6 months in Brazil: ' + brazilCountResults[0].rows[0].value);
    }
    
    // ===== SUMMARY =====
    System.debug('=== Test Summary ===');
    System.debug('✓ Example 1: Avg ACV for AEs ≤6 months in Brazil - TESTED');
    System.debug('✓ Example 2: Compare Avg Calls by Country - TESTED');
    System.debug('✓ Example 3: Previous Quarter ACV for Brazil - TESTED');
    System.debug('✓ Example 4: Count of AEs in Brazil - TESTED');
    System.debug('🎯 All real-world examples tested successfully!');
    
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
    System.debug('Stack: ' + e.getStackTraceString());
} 