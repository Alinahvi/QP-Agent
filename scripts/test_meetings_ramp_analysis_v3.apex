/**
 * Test Script: Meetings Analysis by Ramp Status (AGENT_OU_PIPELINE_V3__c)
 * 
 * This script tests the correct configuration for analyzing meetings data
 * broken down by all ramp status values from AGENT_OU_PIPELINE_V3__c.
 * 
 * @author AI Assistant
 * @date 2025-01-28
 */

System.debug('🎯 MEETINGS RAMP STATUS ANALYSIS TEST (V3)');
System.debug('==========================================');

try {
    // Test 1: Meetings analysis by individual AEs with all ramp status values
    System.debug('🧪 TEST 1: Meetings by AE with all ramp status values');
    
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
    
    // Test direct SOQL query to verify data structure
    System.debug('');
    System.debug('🔍 Testing direct SOQL query on AGENT_OU_PIPELINE_V3__c...');
    
    List<AGENT_OU_PIPELINE_V3__c> sampleRecords = [
        SELECT Id, RAMP_STATUS__c, FULL_NAME__c, WORK_LOCATION_COUNTRY__c, OU_NAME__c,
               CQ_CUSTOMER_MEETING__c, CQ_PG__c, CQ_ACV__c, CQ_CALL_CONNECT__c
        FROM AGENT_OU_PIPELINE_V3__c 
        WHERE RAMP_STATUS__c IN ('Slow Ramper','Fast Ramper','On Track','Not Ramping','unknown')
        LIMIT 10
    ];
    
    System.debug('✅ Direct SOQL query successful! Retrieved ' + sampleRecords.size() + ' sample records');
    
    if (!sampleRecords.isEmpty()) {
        System.debug('📋 Sample records with meetings data:');
        for (AGENT_OU_PIPELINE_V3__c record : sampleRecords) {
            System.debug('  - ' + record.FULL_NAME__c + ' (' + record.RAMP_STATUS__c + ') - ' + 
                        record.WORK_LOCATION_COUNTRY__c + ' - Meetings: ' + record.CQ_CUSTOMER_MEETING__c);
        }
    }
    
    // Test aggregation by ramp status
    System.debug('');
    System.debug('📊 Testing aggregation by ramp status...');
    
    List<AggregateResult> rampStatusAgg = [
        SELECT RAMP_STATUS__c, 
               COUNT(Id) recordCount,
               AVG(CQ_CUSTOMER_MEETING__c) avgMeetings,
               SUM(CQ_CUSTOMER_MEETING__c) totalMeetings
        FROM AGENT_OU_PIPELINE_V3__c 
        WHERE RAMP_STATUS__c IN ('Slow Ramper','Fast Ramper','On Track','Not Ramping','unknown')
        GROUP BY RAMP_STATUS__c 
        ORDER BY AVG(CQ_CUSTOMER_MEETING__c) DESC
    ];
    
    System.debug('✅ Aggregation successful! Found ' + rampStatusAgg.size() + ' ramp status groups:');
    for (AggregateResult result : rampStatusAgg) {
        String rampStatus = (String) result.get('RAMP_STATUS__c');
        Integer recordCount = (Integer) result.get('recordCount');
        Decimal avgMeetings = (Decimal) result.get('avgMeetings');
        Decimal totalMeetings = (Decimal) result.get('totalMeetings');
        
        System.debug('  📋 ' + rampStatus + ': ' + recordCount + ' AEs, ' + 
                    'Avg: ' + avgMeetings + ' meetings, Total: ' + totalMeetings + ' meetings');
    }
    
} catch (Exception e) {
    System.debug('❌ Test 1 Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n--- TEST 2: Alternative - Group by Ramp Status ---');
try {
    // Test 2: Alternative approach - group by ramp status directly
    System.debug('🧪 TEST 2: Meetings analysis grouped by ramp status');
    
    List<AggregateResult> meetingsByRampStatus = [
        SELECT RAMP_STATUS__c,
               COUNT(Id) aeCount,
               AVG(CQ_CUSTOMER_MEETING__c) avgMeetings,
               SUM(CQ_CUSTOMER_MEETING__c) totalMeetings,
               MAX(CQ_CUSTOMER_MEETING__c) maxMeetings,
               MIN(CQ_CUSTOMER_MEETING__c) minMeetings
        FROM AGENT_OU_PIPELINE_V3__c 
        WHERE RAMP_STATUS__c IN ('Slow Ramper','Fast Ramper','On Track','Not Ramping','unknown')
        GROUP BY RAMP_STATUS__c 
        ORDER BY AVG(CQ_CUSTOMER_MEETING__c) DESC
    ];
    
    System.debug('✅ Meetings analysis by ramp status:');
    System.debug('====================================');
    
    for (AggregateResult result : meetingsByRampStatus) {
        String rampStatus = (String) result.get('RAMP_STATUS__c');
        Integer aeCount = (Integer) result.get('aeCount');
        Decimal avgMeetings = (Decimal) result.get('avgMeetings');
        Decimal totalMeetings = (Decimal) result.get('totalMeetings');
        Decimal maxMeetings = (Decimal) result.get('maxMeetings');
        Decimal minMeetings = (Decimal) result.get('minMeetings');
        
        System.debug('📊 ' + rampStatus + ':');
        System.debug('   - AEs: ' + aeCount);
        System.debug('   - Avg Meetings: ' + avgMeetings);
        System.debug('   - Total Meetings: ' + totalMeetings);
        System.debug('   - Max Meetings: ' + maxMeetings);
        System.debug('   - Min Meetings: ' + minMeetings);
        System.debug('');
    }
    
} catch (Exception e) {
    System.debug('❌ Test 2 Error: ' + e.getMessage());
}

System.debug('\n--- TEST 3: Geographic Analysis with Ramp Status ---');
try {
    // Test 3: Meetings analysis by country for all ramp statuses
    System.debug('🧪 TEST 3: Meetings analysis by country and ramp status');
    
    List<AggregateResult> meetingsByCountryRamp = [
        SELECT WORK_LOCATION_COUNTRY__c, RAMP_STATUS__c,
               COUNT(Id) aeCount,
               AVG(CQ_CUSTOMER_MEETING__c) avgMeetings
        FROM AGENT_OU_PIPELINE_V3__c 
        WHERE RAMP_STATUS__c IN ('Slow Ramper','Fast Ramper','On Track','Not Ramping','unknown')
        GROUP BY WORK_LOCATION_COUNTRY__c, RAMP_STATUS__c 
        ORDER BY WORK_LOCATION_COUNTRY__c, AVG(CQ_CUSTOMER_MEETING__c) DESC
    ];
    
    System.debug('✅ Meetings analysis by country and ramp status:');
    System.debug('===============================================');
    
    String currentCountry = '';
    for (AggregateResult result : meetingsByCountryRamp) {
        String country = (String) result.get('WORK_LOCATION_COUNTRY__c');
        String rampStatus = (String) result.get('RAMP_STATUS__c');
        Integer aeCount = (Integer) result.get('aeCount');
        Decimal avgMeetings = (Decimal) result.get('avgMeetings');
        
        if (country != currentCountry) {
            System.debug('🌍 ' + country + ':');
            currentCountry = country;
        }
        
        System.debug('   - ' + rampStatus + ': ' + aeCount + ' AEs, Avg: ' + avgMeetings + ' meetings');
    }
    
} catch (Exception e) {
    System.debug('❌ Test 3 Error: ' + e.getMessage());
}

System.debug('\n🎯 UPDATED CONFIGURATION FOR MEETINGS ANALYSIS:');
System.debug('===============================================');
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
System.debug('filtered to show all ramp status types from AGENT_OU_PIPELINE_V3__c.');

System.debug('\n🎯 ALTERNATIVE CONFIGURATION (Group by Ramp Status):');
System.debug('===================================================');
System.debug('Action: ANAGENT KPI Analysis V5');
System.debug('Parameters:');
System.debug('{');
System.debug('  "metricKey": "MEETINGS",');
System.debug('  "timeframe": "CURRENT",');
System.debug('  "groupBy": "RAMP_STATUS",');
System.debug('  "perAENormalize": true,');
System.debug('  "aggregationType": "AVG"');
System.debug('}');
System.debug('');
System.debug('This will show meetings performance grouped by ramp status type.');

System.debug('\n✅ ALL TESTS COMPLETED');
