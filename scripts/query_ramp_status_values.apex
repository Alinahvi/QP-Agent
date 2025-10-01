/**
 * Query Ramp Status Values from AGENT_OU_PIPELINE_V3__c
 * 
 * This script queries the actual data to extract all possible values
 * for the RAMP_STATUS__c field in the AGENT_OU_PIPELINE_V3__c object.
 * 
 * @author AI Assistant
 * @date 2025-01-28
 */

System.debug('🔍 QUERYING RAMP STATUS VALUES FROM AGENT_OU_PIPELINE_V3__c');
System.debug('==========================================================');

try {
    // Query all distinct ramp status values from the V3 object
    System.debug('📊 Querying distinct RAMP_STATUS__c values...');
    
    List<AggregateResult> rampStatusResults = [
        SELECT RAMP_STATUS__c, COUNT(Id) recordCount
        FROM AGENT_OU_PIPELINE_V3__c 
        WHERE RAMP_STATUS__c != null 
        GROUP BY RAMP_STATUS__c 
        ORDER BY COUNT(Id) DESC
    ];
    
    System.debug('✅ Query successful! Found ' + rampStatusResults.size() + ' distinct ramp status values:');
    System.debug('');
    
    List<String> allRampStatusValues = new List<String>();
    
    for (AggregateResult result : rampStatusResults) {
        String rampStatus = (String) result.get('RAMP_STATUS__c');
        Integer recordCount = (Integer) result.get('recordCount');
        
        allRampStatusValues.add(rampStatus);
        System.debug('📋 "' + rampStatus + '" - ' + recordCount + ' records');
    }
    
    System.debug('');
    System.debug('🎯 ALL RAMP STATUS VALUES FOUND:');
    System.debug('================================');
    System.debug('Values: ' + String.join(allRampStatusValues, ', '));
    System.debug('');
    
    // Create the updated filter criteria with all values
    String updatedFilterCriteria = 'ramp_status IN (\'' + String.join(allRampStatusValues, '\',\'') + '\')';
    System.debug('🔧 UPDATED FILTER CRITERIA:');
    System.debug('===========================');
    System.debug(updatedFilterCriteria);
    System.debug('');
    
    // Test a sample query with the new filter
    System.debug('🧪 Testing sample query with all ramp status values...');
    
    List<AGENT_OU_PIPELINE_V3__c> sampleRecords = [
        SELECT Id, RAMP_STATUS__c, FULL_NAME__c, WORK_LOCATION_COUNTRY__c, OU_NAME__c
        FROM AGENT_OU_PIPELINE_V3__c 
        WHERE RAMP_STATUS__c IN :allRampStatusValues
        LIMIT 10
    ];
    
    System.debug('✅ Sample query successful! Retrieved ' + sampleRecords.size() + ' sample records');
    
    if (!sampleRecords.isEmpty()) {
        System.debug('📋 Sample records:');
        for (AGENT_OU_PIPELINE_V3__c record : sampleRecords) {
            System.debug('  - ' + record.FULL_NAME__c + ' (' + record.RAMP_STATUS__c + ') - ' + record.WORK_LOCATION_COUNTRY__c);
        }
    }
    
    // Generate the updated configuration
    System.debug('');
    System.debug('🎯 UPDATED CONFIGURATION FOR MEETINGS ANALYSIS:');
    System.debug('===============================================');
    System.debug('Action: ANAGENT KPI Analysis V5');
    System.debug('Parameters:');
    System.debug('{');
    System.debug('  "metricKey": "MEETINGS",');
    System.debug('  "timeframe": "CURRENT",');
    System.debug('  "groupBy": "AE",');
    System.debug('  "filterCriteria": "' + updatedFilterCriteria + '",');
    System.debug('  "perAENormalize": true,');
    System.debug('  "aggregationType": "AVG"');
    System.debug('}');
    System.debug('');
    
    // Alternative configuration for grouping by ramp status
    System.debug('🎯 ALTERNATIVE CONFIGURATION (Group by Ramp Status):');
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
    
    // Store the values for later use
    System.debug('💾 Ramp status values to update in configuration:');
    System.debug('================================================');
    for (String value : allRampStatusValues) {
        System.debug('  - "' + value + '"');
    }
    
} catch (Exception e) {
    System.debug('❌ Error querying ramp status values: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
    
    // Fallback to known values if query fails
    System.debug('');
    System.debug('🔄 FALLBACK: Using known ramp status values from documentation');
    System.debug('=============================================================');
    List<String> fallbackValues = new List<String>{'Slow Ramping', 'No Ramping', 'Fast Ramping'};
    System.debug('Fallback values: ' + String.join(fallbackValues, ', '));
}

System.debug('');
System.debug('✅ RAMP STATUS VALUE EXTRACTION COMPLETED');
