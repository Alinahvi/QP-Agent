/**
 * Utility Verification Test
 * Tests that all utility classes are working correctly
 */

System.debug('=== TESTING UTILITY CLASSES ===');

try {
    // Test ANAgentKPIUtils
    System.debug('\n--- Testing ANAgentKPIUtils ---');
    
    // Test field mapping
    String dimField = ANAgentKPIUtils.mapDimensionToField('WORK_LOCATION_COUNTRY');
    System.debug('WORK_LOCATION_COUNTRY -> ' + dimField);
    System.assert(dimField == 'WORK_LOCATION_COUNTRY__c', 'Dimension mapping failed');
    
    // Test KPI field resolution
    String kpiField = ANAgentKPIUtils.resolveKpiField('ACV', 'CURRENT');
    System.debug('ACV CURRENT -> ' + kpiField);
    System.assert(kpiField == 'CQ_ACV__c', 'KPI field resolution failed');
    
    // Test value canonicalization
    String canonicalValue = ANAgentKPIUtils.canonicalizeValue('WORK_LOCATION_COUNTRY', 'USA');
    System.debug('USA -> ' + canonicalValue);
    System.assert(canonicalValue == 'US', 'Value canonicalization failed');
    
    // Test threshold clause
    String thresholdClause = ANAgentKPIUtils.buildThresholdClause('ACV', 'CURRENT', 'GT', 1000, null);
    System.debug('Threshold clause: ' + thresholdClause);
    System.assert(thresholdClause == 'CQ_ACV__c > 1000', 'Threshold clause failed');
    
    // Test ANAgentStats
    System.debug('\n--- Testing ANAgentStats ---');
    
    List<Decimal> testValues = new List<Decimal>{ 1, 2, 3, 4, 5 };
    Decimal sum = ANAgentStats.sum(testValues);
    Decimal avg = ANAgentStats.avg(testValues);
    Decimal min = ANAgentStats.min(testValues);
    Decimal max = ANAgentStats.max(testValues);
    Decimal median = ANAgentStats.median(testValues);
    
    System.debug('Sum: ' + sum + ', Avg: ' + avg + ', Min: ' + min + ', Max: ' + max + ', Median: ' + median);
    System.assert(sum == 15, 'Sum calculation failed');
    System.assert(avg == 3, 'Average calculation failed');
    System.assert(min == 1, 'Min calculation failed');
    System.assert(max == 5, 'Max calculation failed');
    System.assert(median == 3, 'Median calculation failed');
    
    // Test ANAgentSOQLBuilder
    System.debug('\n--- Testing ANAgentSOQLBuilder ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request.analysisType = 'ACV';
    request.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request.primaryValue = 'USA';
    request.timeFrame = 'CURRENT';
    
    ANAgentSOQLBuilder.Built built = ANAgentSOQLBuilder.buildSelect(request);
    System.debug('Built SOQL: ' + built.soql);
    System.debug('KPI Field: ' + built.kpiField);
    System.debug('Dimension Field: ' + built.dimField);
    
    System.assert(built.soql.contains('SELECT Id, WORK_LOCATION_COUNTRY__c'), 'SOQL SELECT failed');
    System.assert(built.soql.contains('CQ_ACV__c'), 'SOQL KPI field failed');
    System.assert(built.soql.contains('WORK_LOCATION_COUNTRY__c = \'US\''), 'SOQL WHERE failed');
    System.assert(built.kpiField == 'CQ_ACV__c', 'KPI field mapping failed');
    System.assert(built.dimField == 'WORK_LOCATION_COUNTRY__c', 'Dimension field mapping failed');
    
    System.debug('\n✅ ALL UTILITY TESTS PASSED!');
    
} catch (Exception e) {
    System.debug('❌ UTILITY TEST FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== UTILITY VERIFICATION COMPLETED ==='); 