// Debug Geographic and AMER ACC Issues
System.debug('=== DEBUGGING GEOGRAPHIC AND AMER ACC ISSUES ===');

// Issue 1: Check Canada's actual OU assignment
System.debug('\n=== ISSUE 1: CANADA GEOGRAPHIC ASSIGNMENT ===');
try {
    List<AGENT_OU_PIPELINE_V2__c> canadaRecords = [
        SELECT Id, FULL_NAME__c, OU_NAME__c, WORK_LOCATION_COUNTRY__c, CQ_CUSTOMER_MEETING__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE WORK_LOCATION_COUNTRY__c LIKE '%Canada%' 
        LIMIT 10
    ];
    
    System.debug('Canada Records Found: ' + canadaRecords.size());
    for (AGENT_OU_PIPELINE_V2__c record : canadaRecords) {
        System.debug('Canada Record: ' + record.FULL_NAME__c + ' | OU: ' + record.OU_NAME__c + ' | Country: ' + record.WORK_LOCATION_COUNTRY__c + ' | Meetings: ' + record.CQ_CUSTOMER_MEETING__c);
    }
} catch (Exception e) {
    System.debug('Error querying Canada records: ' + e.getMessage());
}

// Issue 2: Check AMER ACC data availability
System.debug('\n=== ISSUE 2: AMER ACC DATA AVAILABILITY ===');
try {
    List<AGENT_OU_PIPELINE_V2__c> amerAccRecords = [
        SELECT Id, FULL_NAME__c, OU_NAME__c, WORK_LOCATION_COUNTRY__c, CQ_CALL_CONNECT__c, CQ_CUSTOMER_MEETING__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c LIKE '%AMER%ACC%' 
        LIMIT 10
    ];
    
    System.debug('AMER ACC Records Found: ' + amerAccRecords.size());
    for (AGENT_OU_PIPELINE_V2__c record : amerAccRecords) {
        System.debug('AMER ACC Record: ' + record.FULL_NAME__c + ' | OU: ' + record.OU_NAME__c + ' | Country: ' + record.WORK_LOCATION_COUNTRY__c + ' | Calls: ' + record.CQ_CALL_CONNECT__c + ' | Meetings: ' + record.CQ_CUSTOMER_MEETING__c);
    }
} catch (Exception e) {
    System.debug('Error querying AMER ACC records: ' + e.getMessage());
}

// Issue 3: Check EMEA SMB data
System.debug('\n=== ISSUE 3: EMEA SMB DATA ===');
try {
    List<AGENT_OU_PIPELINE_V2__c> emeaSMBRecords = [
        SELECT Id, FULL_NAME__c, OU_NAME__c, WORK_LOCATION_COUNTRY__c, CQ_CUSTOMER_MEETING__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c LIKE '%EMEA%SMB%' 
        LIMIT 10
    ];
    
    System.debug('EMEA SMB Records Found: ' + emeaSMBRecords.size());
    for (AGENT_OU_PIPELINE_V2__c record : emeaSMBRecords) {
        System.debug('EMEA SMB Record: ' + record.FULL_NAME__c + ' | OU: ' + record.OU_NAME__c + ' | Country: ' + record.WORK_LOCATION_COUNTRY__c + ' | Meetings: ' + record.CQ_CUSTOMER_MEETING__c);
    }
} catch (Exception e) {
    System.debug('Error querying EMEA SMB records: ' + e.getMessage());
}

// Issue 4: Check all OUs to understand the data structure
System.debug('\n=== ISSUE 4: ALL OUs OVERVIEW ===');
try {
    List<AggregateResult> ouSummary = [
        SELECT OU_NAME__c, COUNT(Id) recordCount, 
               SUM(CQ_CUSTOMER_MEETING__c) totalMeetings,
               SUM(CQ_CALL_CONNECT__c) totalCalls
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE OU_NAME__c != null
        GROUP BY OU_NAME__c
        ORDER BY COUNT(Id) DESC
        LIMIT 20
    ];
    
    System.debug('Top OUs by Record Count:');
    for (AggregateResult result : ouSummary) {
        System.debug('OU: ' + result.get('OU_NAME__c') + ' | Records: ' + result.get('recordCount') + ' | Meetings: ' + result.get('totalMeetings') + ' | Calls: ' + result.get('totalCalls'));
    }
} catch (Exception e) {
    System.debug('Error querying OU summary: ' + e.getMessage());
}

// Issue 5: Check country distribution
System.debug('\n=== ISSUE 5: COUNTRY DISTRIBUTION ===');
try {
    List<AggregateResult> countrySummary = [
        SELECT WORK_LOCATION_COUNTRY__c, COUNT(Id) recordCount,
               SUM(CQ_CUSTOMER_MEETING__c) totalMeetings
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE WORK_LOCATION_COUNTRY__c != null
        GROUP BY WORK_LOCATION_COUNTRY__c
        ORDER BY COUNT(Id) DESC
        LIMIT 15
    ];
    
    System.debug('Top Countries by Record Count:');
    for (AggregateResult result : countrySummary) {
        System.debug('Country: ' + result.get('WORK_LOCATION_COUNTRY__c') + ' | Records: ' + result.get('recordCount') + ' | Meetings: ' + result.get('totalMeetings'));
    }
} catch (Exception e) {
    System.debug('Error querying country summary: ' + e.getMessage());
}
