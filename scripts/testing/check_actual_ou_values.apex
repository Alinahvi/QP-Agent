/**
 * Script to check actual OU values in Agent_Open_Pipe__c object
 * This will show us what OUs really exist, including whether UKI is one of them
 */
System.debug('=== Checking Actual OU Values in Agent_Open_Pipe__c ===');

try {
    // Check 1: Get all unique OU names with record counts
    System.debug('--- Check 1: All Unique OU Names with Record Counts ---');
    List<AggregateResult> allOUResults = [
        SELECT ou_name__c, COUNT(Id) recordCount 
        FROM Agent_Open_Pipe__c 
        WHERE ou_name__c != null 
        GROUP BY ou_name__c 
        ORDER BY COUNT(Id) DESC
    ];
    
    System.debug('All OUs found:');
    for (AggregateResult ar : allOUResults) {
        String ouName = (String)ar.get('ou_name__c');
        Integer count = (Integer)ar.get('recordCount');
        System.debug('OU: "' + ouName + '" - Records: ' + count);
        
        // Check if this OU contains "UKI" anywhere
        if (ouName != null && ouName.containsIgnoreCase('UKI')) {
            System.debug('*** FOUND UKI-related OU: "' + ouName + '" ***');
        }
    }
    
    // Check 2: Search specifically for UKI (case insensitive)
    System.debug('--- Check 2: Specific Search for UKI ---');
    List<Agent_Open_Pipe__c> ukiRecords = [
        SELECT Id, ou_name__c, work_location_country__c, open_pipe_prod_nm__c
        FROM Agent_Open_Pipe__c 
        WHERE ou_name__c LIKE '%UKI%' 
        LIMIT 5
    ];
    
    if (!ukiRecords.isEmpty()) {
        System.debug('Found ' + ukiRecords.size() + ' records with UKI in OU name:');
        for (Agent_Open_Pipe__c record : ukiRecords) {
            System.debug('  ID: ' + record.Id + ', OU: "' + record.ou_name__c + '", Country: ' + record.work_location_country__c);
        }
    } else {
        System.debug('No records found with UKI in OU name');
    }
    
    // Check 3: Look for UKI in country field
    System.debug('--- Check 3: Search for UKI in Country Field ---');
    List<Agent_Open_Pipe__c> ukiCountryRecords = [
        SELECT Id, ou_name__c, work_location_country__c, open_pipe_prod_nm__c
        FROM Agent_Open_Pipe__c 
        WHERE work_location_country__c LIKE '%UKI%' 
        LIMIT 5
    ];
    
    if (!ukiCountryRecords.isEmpty()) {
        System.debug('Found ' + ukiCountryRecords.size() + ' records with UKI in country:');
        for (Agent_Open_Pipe__c record : ukiCountryRecords) {
            System.debug('  ID: ' + record.Id + ', OU: "' + record.ou_name__c + '", Country: ' + record.work_location_country__c);
        }
    } else {
        System.debug('No records found with UKI in country field');
    }
    
    // Check 4: Look for UK, Great Britain, England, etc.
    System.debug('--- Check 4: Search for UK-related Countries ---');
    List<Agent_Open_Pipe__c> ukRelatedRecords = [
        SELECT Id, ou_name__c, work_location_country__c, open_pipe_prod_nm__c
        FROM Agent_Open_Pipe__c 
        WHERE work_location_country__c LIKE '%UK%' 
           OR work_location_country__c LIKE '%Great Britain%'
           OR work_location_country__c LIKE '%England%'
           OR work_location_country__c LIKE '%Scotland%'
           OR work_location_country__c LIKE '%Wales%'
        LIMIT 10
    ];
    
    if (!ukRelatedRecords.isEmpty()) {
        System.debug('Found ' + ukRelatedRecords.size() + ' records with UK-related countries:');
        for (Agent_Open_Pipe__c record : ukRelatedRecords) {
            System.debug('  ID: ' + record.Id + ', OU: "' + record.ou_name__c + '", Country: ' + record.work_location_country__c);
        }
    } else {
        System.debug('No records found with UK-related countries');
    }
    
    // Check 5: Get sample records from different OUs to see the pattern
    System.debug('--- Check 5: Sample Records from Different OUs ---');
    Map<String, List<Agent_Open_Pipe__c>> ouSamples = new Map<String, List<Agent_Open_Pipe__c>>();
    
    for (AggregateResult ar : allOUResults) {
        String ouName = (String)ar.get('ou_name__c');
        if (ouSamples.size() < 5) { // Limit to 5 OUs for samples
            List<Agent_Open_Pipe__c> samples = [
                SELECT Id, ou_name__c, work_location_country__c, open_pipe_prod_nm__c, open_pipe_ae_score__c
                FROM Agent_Open_Pipe__c 
                WHERE ou_name__c = :ouName 
                LIMIT 2
            ];
            ouSamples.put(ouName, samples);
        }
    }
    
    System.debug('Sample records from different OUs:');
    for (String ouName : ouSamples.keySet()) {
        System.debug('OU: "' + ouName + '":');
        for (Agent_Open_Pipe__c sample : ouSamples.get(ouName)) {
            System.debug('  - Country: ' + sample.work_location_country__c + ', Product: ' + sample.open_pipe_prod_nm__c + ', AE Score: ' + sample.open_pipe_ae_score__c);
        }
    }
    
    System.debug('=== OU Value Check Completed ===');
    
} catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'Check failed with error: ' + e.getMessage());
    System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
}
