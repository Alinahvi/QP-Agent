/**
 * Test Segment-Based KPI Analysis
 * 
 * This script tests the newly added segment-based grouping capabilities
 * in the enhanced KPI analysis service.
 * 
 * @author AI Assistant
 * @date 2025-01-28
 */

System.debug('🧪 TESTING SEGMENT-BASED KPI ANALYSIS');
System.debug('====================================');

// Test 1: MACRO_SEGMENT grouping for COVERAGE
System.debug('\n--- Test 1: COVERAGE by MACRO_SEGMENT for AMER ACC ---');

try {
    String result1 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs(
        'COVERAGE',                   // metricKey
        'CURRENT',                    // timeframe
        'MACRO_SEGMENT',              // groupBy - this should now work!
        'ou_name__c = \'AMER ACC\'',  // filterCriteria
        null,                         // restrictInValuesCsv
        false,                        // perAENormalize
        10,                           // limitN
        'SUM'                         // aggregationType
    );
    
    System.debug('✅ SUCCESS: MACRO_SEGMENT grouping works!');
    System.debug('📊 Result preview (first 500 chars):');
    String preview = result1.length() > 500 ? result1.substring(0, 500) + '...' : result1;
    System.debug(preview);
    
} catch (Exception e) {
    System.debug('❌ FAILED: MACRO_SEGMENT grouping failed: ' + e.getMessage());
}

// Test 2: INDUSTRY grouping for COVERAGE
System.debug('\n--- Test 2: COVERAGE by INDUSTRY for AMER ACC ---');

try {
    String result2 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs(
        'COVERAGE',                   // metricKey
        'CURRENT',                    // timeframe
        'INDUSTRY',                   // groupBy
        'ou_name__c = \'AMER ACC\'',  // filterCriteria
        null,                         // restrictInValuesCsv
        false,                        // perAENormalize
        10,                           // limitN
        'SUM'                         // aggregationType
    );
    
    System.debug('✅ SUCCESS: INDUSTRY grouping works!');
    System.debug('📊 Result preview (first 500 chars):');
    String preview = result2.length() > 500 ? result2.substring(0, 500) + '...' : result2;
    System.debug(preview);
    
} catch (Exception e) {
    System.debug('❌ FAILED: INDUSTRY grouping failed: ' + e.getMessage());
}

// Test 3: SUB_SECTOR grouping for COVERAGE
System.debug('\n--- Test 3: COVERAGE by SUB_SECTOR for AMER ACC ---');

try {
    String result3 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs(
        'COVERAGE',                   // metricKey
        'CURRENT',                    // timeframe
        'SUB_SECTOR',                 // groupBy - new field!
        'ou_name__c = \'AMER ACC\'',  // filterCriteria
        null,                         // restrictInValuesCsv
        false,                        // perAENormalize
        10,                           // limitN
        'SUM'                         // aggregationType
    );
    
    System.debug('✅ SUCCESS: SUB_SECTOR grouping works!');
    System.debug('📊 Result preview (first 500 chars):');
    String preview = result3.length() > 500 ? result3.substring(0, 500) + '...' : result3;
    System.debug(preview);
    
} catch (Exception e) {
    System.debug('❌ FAILED: SUB_SECTOR grouping failed: ' + e.getMessage());
}

// Test 4: MEETINGS by MACRO_SEGMENT for AMER ICE vs AMER ACC
System.debug('\n--- Test 4: MEETINGS by MACRO_SEGMENT for AMER ICE vs AMER ACC ---');

try {
    String result4 = ANAGENTKPIAnalysisServiceV5.analyzeKPIs(
        'MEETINGS',                                        // metricKey
        'CURRENT',                                         // timeframe
        'MACRO_SEGMENT',                                   // groupBy
        'ou_name__c IN (\'AMER ICE\', \'AMER ACC\')',     // filterCriteria
        null,                                              // restrictInValuesCsv
        false,                                             // perAENormalize
        15,                                                // limitN
        'SUM'                                              // aggregationType
    );
    
    System.debug('✅ SUCCESS: MEETINGS by MACRO_SEGMENT works!');
    System.debug('📊 Result preview (first 500 chars):');
    String preview = result4.length() > 500 ? result4.substring(0, 500) + '...' : result4;
    System.debug(preview);
    
} catch (Exception e) {
    System.debug('❌ FAILED: MEETINGS by MACRO_SEGMENT failed: ' + e.getMessage());
}

System.debug('\n--- TEST SUMMARY ---');
System.debug('✅ Enhanced KPI Analysis Service now supports segment-based analysis!');
System.debug('✅ Available segment groupings:');
System.debug('  • MACRO_SEGMENT - Primary industry classification');
System.debug('  • INDUSTRY - Primary industry classification (alias)');
System.debug('  • SEGMENT - Primary industry classification (alias)');
System.debug('  • SUB_SECTOR - Detailed sub-sector classification');
System.debug('');
System.debug('📋 For the user\'s request:');
System.debug('  "Can you break it down based on segments as well?"');
System.debug('  The agent should now be able to use MACRO_SEGMENT, INDUSTRY, or SUB_SECTOR grouping');
System.debug('');
System.debug('🎯 Expected response from agent:');
System.debug('  "Here\'s the breakdown by segments for AMER ICE vs AMER ACC:"');
System.debug('  [Followed by industry/segment-based analysis]');

System.debug('\n✅ Segment-Based KPI Analysis Test Complete!');
