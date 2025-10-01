// Test OU Matching Fix
System.debug('=== TESTING OU MATCHING FIX ===');

// Test the current fuzzy matching logic
String testOU = 'EMEA SMB';
System.debug('Testing OU: ' + testOU);

// Simulate the fuzzy matching logic
Map<String, List<String>> FUZZY_PATTERNS = new Map<String, List<String>>{
    'AMER' => new List<String>{'AMER', 'AMERICAS', 'AMERICA', 'NORTH AMERICA', 'NA', 'US', 'USA'},
    'EMEA' => new List<String>{'EMEA', 'EUROPE', 'MIDDLE EAST', 'AFRICA', 'EU', 'EMEA-APAC'},
    'APAC' => new List<String>{'APAC', 'ASIA PACIFIC', 'ASIA', 'PACIFIC', 'JAPAN', 'ANZ', 'AUSTRALIA'},
    'ACC' => new List<String>{'ACC', 'ACCOUNT', 'ACCOUNTS', 'ACCOUNTING', 'ACCOUNT MANAGER'},
    'SALES' => new List<String>{'SALES', 'SELLING', 'REVENUE', 'REP', 'REPRESENTATIVE'},
    'TECH' => new List<String>{'TECH', 'TECHNICAL', 'TECHNOLOGY', 'ENGINEERING', 'SOLUTIONS'},
    'SERVICES' => new List<String>{'SERVICES', 'SERVICE', 'CONSULTING', 'PROFESSIONAL SERVICES'}
};

List<String> findFuzzyMatches(String input, Map<String, List<String>> patterns) {
    List<String> matches = new List<String>();
    String upperInput = input.toUpperCase();
    
    for (String key : patterns.keySet()) {
        for (String pattern : patterns.get(key)) {
            if (upperInput.contains(pattern) || pattern.contains(upperInput)) {
                matches.add(pattern);
            }
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

// Test the correct approach - direct OU matching
System.debug('\n=== TESTING DIRECT OU MATCHING ===');
try {
    List<AGENT_OU_PIPELINE_V2__c> directRecords = [
        SELECT Id, OU_NAME__c, WORK_LOCATION_COUNTRY__c, CQ_CUSTOMER_MEETING__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c LIKE '%EMEA%SMB%'
        LIMIT 10
    ];
    
    System.debug('Direct EMEA SMB records found: ' + directRecords.size());
    for (AGENT_OU_PIPELINE_V2__c record : directRecords) {
        System.debug('Direct Record: ' + record.OU_NAME__c + ' | Country: ' + record.WORK_LOCATION_COUNTRY__c + ' | Meetings: ' + record.CQ_CUSTOMER_MEETING__c);
    }
} catch (Exception e) {
    System.debug('Direct matching error: ' + e.getMessage());
}
