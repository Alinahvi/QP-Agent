/**
 * Check KPI Field Data
 * Verify what data exists for the KPI fields
 */

System.debug('=== CHECKING KPI FIELD DATA ===');

try {
    // Check what data exists for different analysis types
    System.debug('--- CHECKING COVERAGE DATA ---');
    
    List<AGENT_OU_PIPELINE_V2__c> coverageRecords = [
        SELECT Id, COVERAGE__c, VAL_QUOTA__c, OU_NAME__c, WORK_LOCATION_COUNTRY__c 
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE COVERAGE__c != null 
        LIMIT 5
    ];
    
    System.debug('Coverage records found: ' + coverageRecords.size());
    for (AGENT_OU_PIPELINE_V2__c record : coverageRecords) {
        System.debug('Coverage: ' + record.COVERAGE__c + ', Quota: ' + record.VAL_QUOTA__c + ', OU: ' + record.OU_NAME__c);
    }
    
    System.debug('\n--- CHECKING RAMP STATUS DATA ---');
    
    List<AGENT_OU_PIPELINE_V2__c> rampRecords = [
        SELECT Id, RAMP_STATUS__c, TIME_SINCE_ONBOARDING__c, DAYS_TO_PRODUCTIVITY__c, PRIMARY_INDUSTRY__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE RAMP_STATUS__c != null 
        LIMIT 5
    ];
    
    System.debug('Ramp status records found: ' + rampRecords.size());
    for (AGENT_OU_PIPELINE_V2__c record : rampRecords) {
        System.debug('Ramp Status: ' + record.RAMP_STATUS__c + ', Time Since Onboarding: ' + record.TIME_SINCE_ONBOARDING__c + ', Industry: ' + record.PRIMARY_INDUSTRY__c);
    }
    
    System.debug('\n--- CHECKING GROWTH FACTORS DATA ---');
    
    List<AGENT_OU_PIPELINE_V2__c> growthRecords = [
        SELECT Id, DEFINITION__c, DESCRIPTION__c, ACTIONABLE__c, RECOMMENDED_ACTION__c, ACTION_LINK__c, EMP_ID__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE DEFINITION__c != null 
        LIMIT 5
    ];
    
    System.debug('Growth factors records found: ' + growthRecords.size());
    for (AGENT_OU_PIPELINE_V2__c record : growthRecords) {
        System.debug('Definition: ' + record.DEFINITION__c + ', Actionable: ' + record.ACTIONABLE__c + ', Emp ID: ' + record.EMP_ID__c);
    }
    
    System.debug('\n--- CHECKING WORK_LOCATION_COUNTRY VALUES ---');
    
    System.debug('\n--- CHECKING WORK_LOCATION_COUNTRY VALUES ---');
    
    List<AGENT_OU_PIPELINE_V2__c> countryRecords = [
        SELECT WORK_LOCATION_COUNTRY__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE WORK_LOCATION_COUNTRY__c != null 
        LIMIT 100
    ];
    
    Map<String, Integer> countryCounts = new Map<String, Integer>();
    for (AGENT_OU_PIPELINE_V2__c record : countryRecords) {
        String country = record.WORK_LOCATION_COUNTRY__c;
        countryCounts.put(country, countryCounts.containsKey(country) ? countryCounts.get(country) + 1 : 1);
    }
    
    System.debug('Top countries by record count:');
    for (String country : countryCounts.keySet()) {
        System.debug('Country: ' + country + ', Count: ' + countryCounts.get(country));
    }
    
    System.debug('\n--- CHECKING PRIMARY_INDUSTRY VALUES ---');
    
    List<AGENT_OU_PIPELINE_V2__c> industryRecords = [
        SELECT PRIMARY_INDUSTRY__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE PRIMARY_INDUSTRY__c != null 
        LIMIT 100
    ];
    
    Map<String, Integer> industryCounts = new Map<String, Integer>();
    for (AGENT_OU_PIPELINE_V2__c record : industryRecords) {
        String industry = record.PRIMARY_INDUSTRY__c;
        industryCounts.put(industry, industryCounts.containsKey(industry) ? industryCounts.get(industry) + 1 : 1);
    }
    
    System.debug('Top industries by record count:');
    for (String industry : industryCounts.keySet()) {
        System.debug('Industry: ' + industry + ', Count: ' + industryCounts.get(industry));
    }
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== KPI FIELD DATA CHECK COMPLETED ==='); 