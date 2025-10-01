// Test Fixed Fuzzy Matching
System.debug('=== TESTING FIXED FUZZY MATCHING ===');

// Test the new fuzzy matching logic
String testOU = 'EMEA SMB';
System.debug('Testing OU: ' + testOU);

// Simulate the new fuzzy matching logic
Map<String, List<String>> FUZZY_PATTERNS = new Map<String, List<String>>{
    'AMER ACC' => new List<String>{'AMER ACC', 'AMER-ACC', 'AMER_ACC', 'AMERICAS ACC', 'AMERICA ACC'},
    'EMEA SMB' => new List<String>{'EMEA SMB', 'EMEA-SMB', 'EMEA_SMB', 'SMB - EMEA SMB', 'SMB EMEA', 'EMEA SMB -'},
    'APAC REG' => new List<String>{'APAC REG', 'APAC-REG', 'APAC_REG', 'APAC REGION', 'ASIA PACIFIC REG'},
    'UKI' => new List<String>{'UKI', 'UK & IRELAND', 'UK AND IRELAND', 'UNITED KINGDOM IRELAND'},
    'AMER SMB' => new List<String>{'AMER SMB', 'AMER-SMB', 'AMER_SMB', 'SMB - AMER SMB', 'SMB AMER', 'AMER SMB -'},
    'EMEA ACC' => new List<String>{'EMEA ACC', 'EMEA-ACC', 'EMEA_ACC', 'EUROPE ACC', 'EMEA ACCOUNT'},
    'APAC SMB' => new List<String>{'APAC SMB', 'APAC-SMB', 'APAC_SMB', 'SMB - APAC SMB', 'SMB APAC', 'APAC SMB -'},
    'AMER REG' => new List<String>{'AMER REG', 'AMER-REG', 'AMER_REG', 'AMER REGION', 'AMERICAS REGION'}
};

List<String> findFuzzyMatches(String input, Map<String, List<String>> patterns) {
    List<String> matches = new List<String>();
    String upperInput = input.toUpperCase().trim();
    
    // First try exact key matching for common OU patterns
    if (patterns.containsKey(upperInput)) {
        matches.addAll(patterns.get(upperInput));
        return matches;
    }
    
    // Then try partial matching for known patterns
    for (String key : patterns.keySet()) {
        if (upperInput.contains(key) || key.contains(upperInput)) {
            matches.addAll(patterns.get(key));
            break; // Only match the first found pattern to avoid over-matching
        }
    }
    
    // If no fuzzy matches found, return the original input
    if (matches.isEmpty()) {
        matches.add(input);
    }
    
    return matches;
}

List<String> fuzzyMatches = findFuzzyMatches(testOU, FUZZY_PATTERNS);
System.debug('Fuzzy matches for "' + testOU + '": ' + fuzzyMatches);

// Test what the actual SOQL would look like
List<String> orConditions = new List<String>();
for (String match : fuzzyMatches) {
    orConditions.add('OU_NAME__c LIKE \'%' + String.escapeSingleQuotes(match) + '%\'');
}
String soqlCondition = '(' + String.join(orConditions, ' OR ') + ')';
System.debug('SOQL Condition: ' + soqlCondition);

// Test with actual data
System.debug('\n=== TESTING WITH ACTUAL DATA ===');
try {
    String testSOQL = 'SELECT Id, OU_NAME__c, WORK_LOCATION_COUNTRY__c, CQ_CUSTOMER_MEETING__c FROM AGENT_OU_PIPELINE_V2__c WHERE ' + soqlCondition + ' LIMIT 10';
    System.debug('Test SOQL: ' + testSOQL);
    
    List<AGENT_OU_PIPELINE_V2__c> testRecords = Database.query(testSOQL);
    System.debug('Records found: ' + testRecords.size());
    
    for (AGENT_OU_PIPELINE_V2__c record : testRecords) {
        System.debug('Record: ' + record.OU_NAME__c + ' | Country: ' + record.WORK_LOCATION_COUNTRY__c + ' | Meetings: ' + record.CQ_CUSTOMER_MEETING__c);
    }
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}

// Test AMER ACC specifically
System.debug('\n=== TESTING AMER ACC ===');
try {
    List<AGENT_OU_PIPELINE_V2__c> amerAccRecords = [
        SELECT Id, OU_NAME__c, WORK_LOCATION_COUNTRY__c, CQ_CALL_CONNECT__c, CQ_CUSTOMER_MEETING__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c LIKE '%AMER%ACC%'
        LIMIT 5
    ];
    
    System.debug('AMER ACC records found: ' + amerAccRecords.size());
    for (AGENT_OU_PIPELINE_V2__c record : amerAccRecords) {
        System.debug('AMER ACC Record: ' + record.OU_NAME__c + ' | Country: ' + record.WORK_LOCATION_COUNTRY__c + ' | Calls: ' + record.CQ_CALL_CONNECT__c + ' | Meetings: ' + record.CQ_CUSTOMER_MEETING__c);
    }
} catch (Exception e) {
    System.debug('AMER ACC error: ' + e.getMessage());
}
