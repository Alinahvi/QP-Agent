// Check what OUs are available and specifically look for AMER ACC
System.debug('=== CHECKING ORGANIZATIONAL UNITS ===');

// Get all unique OUs
List<AggregateResult> ouList = [
    SELECT ou_name__c, COUNT(Id) recordCount
    FROM AGENT_OU_PIPELINE_V2__c 
    WHERE ou_name__c != null
    GROUP BY ou_name__c 
    ORDER BY COUNT(Id) DESC
    LIMIT 20
];

System.debug('📊 Available OUs:');
for (AggregateResult ou : ouList) {
    String ouName = (String) ou.get('ou_name__c');
    Integer count = (Integer) ou.get('recordCount');
    System.debug('  - ' + ouName + ': ' + count + ' records');
}

// Check specifically for AMER ACC
System.debug('\n=== CHECKING FOR AMER ACC ===');
List<AGENT_OU_PIPELINE_V2__c> amerAccRecords = [
    SELECT Id, full_name__c, ou_name__c, definition__c, description__c
    FROM AGENT_OU_PIPELINE_V2__c 
    WHERE ou_name__c = 'AMER ACC'
    LIMIT 10
];

System.debug('AMER ACC records found: ' + amerAccRecords.size());
for (AGENT_OU_PIPELINE_V2__c record : amerAccRecords) {
    System.debug('  - ' + record.full_name__c + ': ' + record.definition__c);
}

// Check for AMER-related OUs
System.debug('\n=== CHECKING FOR AMER-RELATED OUs ===');
List<AGENT_OU_PIPELINE_V2__c> amerRelatedRecords = [
    SELECT Id, full_name__c, ou_name__c, definition__c
    FROM AGENT_OU_PIPELINE_V2__c 
    WHERE ou_name__c LIKE '%AMER%'
    LIMIT 10
];

System.debug('AMER-related records found: ' + amerRelatedRecords.size());
for (AGENT_OU_PIPELINE_V2__c record : amerRelatedRecords) {
    System.debug('  - ' + record.full_name__c + ' (' + record.ou_name__c + '): ' + record.definition__c);
}

// Check growth factors for AMER-related OUs
System.debug('\n=== CHECKING GROWTH FACTORS FOR AMER-RELATED OUs ===');
List<AggregateResult> amerGrowthFactors = [
    SELECT ou_name__c, definition__c, COUNT(Id) recordCount
    FROM AGENT_OU_PIPELINE_V2__c 
    WHERE ou_name__c LIKE '%AMER%' AND definition__c != null
    GROUP BY ou_name__c, definition__c
    ORDER BY COUNT(Id) DESC
    LIMIT 20
];

System.debug('Growth factors for AMER-related OUs:');
for (AggregateResult gf : amerGrowthFactors) {
    String ouName = (String) gf.get('ou_name__c');
    String definition = (String) gf.get('definition__c');
    Integer count = (Integer) gf.get('recordCount');
    System.debug('  - ' + ouName + ' | ' + definition + ': ' + count + ' records');
}
