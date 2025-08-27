/**
 * Check EMEA and ENTR Data
 * Verify what data exists in the database for these values
 */

System.debug('=== CHECKING EMEA AND ENTR DATA ===');

try {
    // Check what countries exist in EMEA
    System.debug('--- CHECKING COUNTRIES IN EMEA ---');
    List<AggregateResult> emeaCountries = [
        SELECT WORK_LOCATION_COUNTRY__c, COUNT(Id) recordCount
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE IsDeleted = false 
        AND OU_NAME__c LIKE '%EMEA%'
        GROUP BY WORK_LOCATION_COUNTRY__c
        ORDER BY WORK_LOCATION_COUNTRY__c
    ];
    
    System.debug('EMEA Countries found: ' + emeaCountries.size());
    for (AggregateResult ar : emeaCountries) {
        System.debug('  ' + ar.get('WORK_LOCATION_COUNTRY__c') + ': ' + ar.get('recordCount') + ' records');
    }
    
    // Check what industries exist
    System.debug('\n--- CHECKING INDUSTRIES ---');
    List<AggregateResult> industries = [
        SELECT PRIMARY_INDUSTRY__c, COUNT(Id) recordCount
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE IsDeleted = false 
        GROUP BY PRIMARY_INDUSTRY__c
        ORDER BY PRIMARY_INDUSTRY__c
    ];
    
    System.debug('Industries found: ' + industries.size());
    for (AggregateResult ar : industries) {
        System.debug('  ' + ar.get('PRIMARY_INDUSTRY__c') + ': ' + ar.get('recordCount') + ' records');
    }
    
    // Check for ENTR specifically
    System.debug('\n--- CHECKING FOR ENTR SPECIFICALLY ---');
    List<AggregateResult> entrRecords = [
        SELECT PRIMARY_INDUSTRY__c, WORK_LOCATION_COUNTRY__c, COUNT(Id) recordCount
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE IsDeleted = false 
        AND (PRIMARY_INDUSTRY__c LIKE '%ENTR%' OR PRIMARY_INDUSTRY__c LIKE '%Enterprise%')
        GROUP BY PRIMARY_INDUSTRY__c, WORK_LOCATION_COUNTRY__c
        ORDER BY PRIMARY_INDUSTRY__c, WORK_LOCATION_COUNTRY__c
    ];
    
    System.debug('ENTR-like records found: ' + entrRecords.size());
    for (AggregateResult ar : entrRecords) {
        System.debug('  Industry: ' + ar.get('PRIMARY_INDUSTRY__c') + 
                    ', Country: ' + ar.get('WORK_LOCATION_COUNTRY__c') + 
                    ', Count: ' + ar.get('recordCount'));
    }
    
    // Check what OU names exist
    System.debug('\n--- CHECKING OU NAMES ---');
    List<AggregateResult> ouNames = [
        SELECT OU_NAME__c, COUNT(Id) recordCount
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE IsDeleted = false 
        GROUP BY OU_NAME__c
        ORDER BY OU_NAME__c
    ];
    
    System.debug('OU Names found: ' + ouNames.size());
    for (AggregateResult ar : ouNames) {
        System.debug('  ' + ar.get('OU_NAME__c') + ': ' + ar.get('recordCount') + ' records');
    }
    
    // Check for EMEA specifically in OU names
    System.debug('\n--- CHECKING FOR EMEA IN OU NAMES ---');
    List<AggregateResult> emeaOUs = [
        SELECT OU_NAME__c, COUNT(Id) recordCount
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE IsDeleted = false 
        AND OU_NAME__c LIKE '%EMEA%'
        GROUP BY OU_NAME__c
        ORDER BY OU_NAME__c
    ];
    
    System.debug('EMEA OUs found: ' + emeaOUs.size());
    for (AggregateResult ar : emeaOUs) {
        System.debug('  ' + ar.get('OU_NAME__c') + ': ' + ar.get('recordCount') + ' records');
    }
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== DATA CHECK COMPLETED ==='); 