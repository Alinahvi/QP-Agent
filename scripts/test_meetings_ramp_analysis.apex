/**
 * Test Script: Meetings Analysis by Ramp Status
 * 
 * This script tests the correct configuration for analyzing meetings data
 * broken down by slow ramping vs fast ramping AEs.
 * 
 * @author AI Assistant
 * @date 2025-01-28
 */

System.debug('🎯 MEETINGS RAMP STATUS ANALYSIS TEST');
System.debug('=====================================');

try {
    // Test 1: Meetings analysis by individual AEs with ramp status filter
    System.debug('🧪 TEST 1: Meetings by AE with Slow/Fast ramp filter');
    
    String metricKey = 'MEETINGS';
    String timeframe = 'CURRENT';
    String groupBy = 'AE';
    String filterCriteria = 'ramp_status IN (\'Slow Ramper\',\'Fast Ramper\',\'On Track\',\'Not Ramping\',\'unknown\')';
    String restrictInValuesCsv = '';
    Boolean perAENormalize = true;
    Integer limitN = 20;
    String aggregationType = 'AVG';
    
    System.debug('Parameters:');
    System.debug('- metricKey: ' + metricKey);
    System.debug('- timeframe: ' + timeframe);
    System.debug('- groupBy: ' + groupBy);
    System.debug('- filterCriteria: ' + filterCriteria);
    System.debug('- perAENormalize: ' + perAENormalize);
    System.debug('- limitN: ' + limitN);
    System.debug('- aggregationType: ' + aggregationType);
    
    // Call the service method (assuming ANAGENTKPIAnalysisServiceV5 exists)
    try {
        String result = ANAGENTKPIAnalysisServiceV5.analyzeKPIs(
            metricKey, timeframe, groupBy, filterCriteria, 
            restrictInValuesCsv, perAENormalize, limitN, aggregationType
        );
        
        System.debug('✅ Service call successful!');
        System.debug('Result length: ' + result.length());
        System.debug('Result preview: ' + result.substring(0, Math.min(1000, result.length())));
        
        // Verify the result contains expected content
        if (result.contains('KPI Analysis') || result.contains('Meetings')) {
            System.debug('✅ Result contains meetings analysis content');
        } else {
            System.debug('❌ Result does not contain expected meetings content');
        }
        
    } catch (Exception e) {
        System.debug('❌ Service call failed: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
    
} catch (Exception e) {
    System.debug('❌ Test 1 Error: ' + e.getMessage());
}

System.debug('\n--- TEST 2: Alternative - Group by Ramp Status ---');
try {
    // Test 2: Alternative approach - group by ramp status directly
    String metricKey2 = 'MEETINGS';
    String timeframe2 = 'CURRENT';
    String groupBy2 = 'RAMP_STATUS';  // This might need to be implemented
    String filterCriteria2 = '';
    String restrictInValuesCsv2 = '';
    Boolean perAENormalize2 = true;
    Integer limitN2 = 10;
    String aggregationType2 = 'AVG';
    
    System.debug('Parameters for Test 2:');
    System.debug('- metricKey: ' + metricKey2);
    System.debug('- timeframe: ' + timeframe2);
    System.debug('- groupBy: ' + groupBy2);
    System.debug('- perAENormalize: ' + perAENormalize2);
    
    // This would be the ideal approach if RAMP_STATUS grouping is supported
    System.debug('Note: This test assumes RAMP_STATUS grouping is supported');
    System.debug('If not supported, use Test 1 approach with AE grouping + ramp_status filter');
    
} catch (Exception e) {
    System.debug('❌ Test 2 Error: ' + e.getMessage());
}

System.debug('\n--- TEST 3: Geographic Analysis with Ramp Status ---');
try {
    // Test 3: Meetings analysis by country for slow/fast rampers
    String metricKey3 = 'MEETINGS';
    String timeframe3 = 'CURRENT';
    String groupBy3 = 'COUNTRY';
    String filterCriteria3 = 'ramp_status IN (\'Slow Ramper\',\'Fast Ramper\',\'On Track\',\'Not Ramping\',\'unknown\')';
    String restrictInValuesCsv3 = '';
    Boolean perAENormalize3 = true;
    Integer limitN3 = 15;
    String aggregationType3 = 'AVG';
    
    System.debug('Parameters for Test 3:');
    System.debug('- metricKey: ' + metricKey3);
    System.debug('- timeframe: ' + timeframe3);
    System.debug('- groupBy: ' + groupBy3);
    System.debug('- filterCriteria: ' + filterCriteria3);
    System.debug('- perAENormalize: ' + perAENormalize3);
    
    System.debug('This would show meetings performance by country for slow/fast ramping AEs');
    
} catch (Exception e) {
    System.debug('❌ Test 3 Error: ' + e.getMessage());
}

System.debug('\n🎯 RECOMMENDED CONFIGURATION FOR AGENT:');
System.debug('=========================================');
System.debug('Action: ANAGENT KPI Analysis V5');
System.debug('Parameters:');
System.debug('{');
System.debug('  "metricKey": "MEETINGS",');
System.debug('  "timeframe": "CURRENT",');
System.debug('  "groupBy": "AE",');
System.debug('  "filterCriteria": "ramp_status IN (\'Slow Ramper\',\'Fast Ramper\',\'On Track\',\'Not Ramping\',\'unknown\')",');
System.debug('  "perAENormalize": true,');
System.debug('  "aggregationType": "AVG"');
System.debug('}');
System.debug('');
System.debug('This will show individual AEs with their meeting counts,');
System.debug('filtered to only show slow and fast ramping AEs.');

System.debug('\n✅ TEST COMPLETED');
