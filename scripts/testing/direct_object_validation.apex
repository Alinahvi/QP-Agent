/**
 * Direct Object Validation Script
 * Queries AGENT_OU_PIPELINE_V2__c directly to validate KPI data and compare with service results
 */

System.debug('=== DIRECT OBJECT VALIDATION STARTED ===');

// Test 1: Direct SOQL Query - Basic Counts
System.debug('\n--- TEST 1: Direct SOQL Query - Basic Counts ---');
try {
    // Get total record count
    Integer totalRecords = [SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c WHERE IsDeleted = false];
    System.debug('Total Records: ' + totalRecords);
    
    // Get distinct OU names
    List<AggregateResult> ouResults = [SELECT OU_NAME__c, COUNT(Id) recordCount 
                                       FROM AGENT_OU_PIPELINE_V2__c 
                                       WHERE IsDeleted = false AND OU_NAME__c != null 
                                       GROUP BY OU_NAME__c 
                                       ORDER BY COUNT(Id) DESC];
    
    System.debug('OU Breakdown:');
    for (AggregateResult ar : ouResults) {
        System.debug('  ' + ar.get('OU_NAME__c') + ': ' + ar.get('recordCount') + ' records');
    }
    
    // Get distinct countries
    List<AggregateResult> countryResults = [SELECT WORK_LOCATION_COUNTRY__c, COUNT(Id) recordCount 
                                           FROM AGENT_OU_PIPELINE_V2__c 
                                           WHERE IsDeleted = false AND WORK_LOCATION_COUNTRY__c != null 
                                           GROUP BY WORK_LOCATION_COUNTRY__c 
                                           ORDER BY COUNT(Id) DESC];
    
    System.debug('Country Breakdown:');
    for (AggregateResult ar : countryResults) {
        System.debug('  ' + ar.get('WORK_LOCATION_COUNTRY__c') + ': ' + ar.get('recordCount') + ' records');
    }
    
} catch (Exception e) {
    System.debug('Test 1 Error: ' + e.getMessage());
}

// Test 2: Direct KPI Field Analysis
System.debug('\n--- TEST 2: Direct KPI Field Analysis ---');
try {
    // Analyze CQ_CUSTOMER_MEETING__c field
    List<AggregateResult> meetingResults = [SELECT 
        SUM(CQ_CUSTOMER_MEETING__c) totalMeetings,
        AVG(CQ_CUSTOMER_MEETING__c) avgMeetings,
        MAX(CQ_CUSTOMER_MEETING__c) maxMeetings,
        MIN(CQ_CUSTOMER_MEETING__c) minMeetings,
        COUNT(CQ_CUSTOMER_MEETING__c) nonNullCount
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE IsDeleted = false AND CQ_CUSTOMER_MEETING__c != null];
    
    if (!meetingResults.isEmpty()) {
        AggregateResult ar = meetingResults[0];
        System.debug('Customer Meetings Analysis:');
        System.debug('  Total: ' + ar.get('totalMeetings'));
        System.debug('  Average: ' + ar.get('avgMeetings'));
        System.debug('  Max: ' + ar.get('maxMeetings'));
        System.debug('  Min: ' + ar.get('minMeetings'));
        System.debug('  Non-null records: ' + ar.get('nonNullCount'));
    }
    
    // Analyze CQ_PG__c field
    List<AggregateResult> pipelineResults = [SELECT 
        SUM(CQ_PG__c) totalPipeline,
        AVG(CQ_PG__c) avgPipeline,
        MAX(CQ_PG__c) maxPipeline,
        MIN(CQ_PG__c) minPipeline,
        COUNT(CQ_PG__c) nonNullCount
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE IsDeleted = false AND CQ_PG__c != null];
    
    if (!pipelineResults.isEmpty()) {
        AggregateResult ar = pipelineResults[0];
        System.debug('Pipeline Generation Analysis:');
        System.debug('  Total: $' + ar.get('totalPipeline'));
        System.debug('  Average: $' + ar.get('avgPipeline'));
        System.debug('  Max: $' + ar.get('maxPipeline'));
        System.debug('  Min: $' + ar.get('minPipeline'));
        System.debug('  Non-null records: ' + ar.get('nonNullCount'));
    }
    
} catch (Exception e) {
    System.debug('Test 2 Error: ' + e.getMessage());
}

// Test 3: Dimension-Specific Analysis
System.debug('\n--- TEST 3: Dimension-Specific Analysis ---');
try {
    // US-specific analysis
    List<AggregateResult> usResults = [SELECT 
        SUM(CQ_CUSTOMER_MEETING__c) totalMeetings,
        SUM(CQ_PG__c) totalPipeline,
        SUM(CQ_ACV__c) totalACV,
        COUNT(Id) recordCount
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE IsDeleted = false AND WORK_LOCATION_COUNTRY__c = 'US'];
    
    if (!usResults.isEmpty()) {
        AggregateResult ar = usResults[0];
        System.debug('US Analysis:');
        System.debug('  Records: ' + ar.get('recordCount'));
        System.debug('  Total Meetings: ' + ar.get('totalMeetings'));
        System.debug('  Total Pipeline: $' + ar.get('totalPipeline'));
        System.debug('  Total ACV: $' + ar.get('totalACV'));
    }
    
    // AMER ICE-specific analysis
    List<AggregateResult> amerIceResults = [SELECT 
        SUM(CQ_CUSTOMER_MEETING__c) totalMeetings,
        SUM(CQ_PG__c) totalPipeline,
        SUM(CQ_ACV__c) totalACV,
        COUNT(Id) recordCount
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE IsDeleted = false AND OU_NAME__c = 'AMER ICE'];
    
    if (!amerIceResults.isEmpty()) {
        AggregateResult ar = amerIceResults[0];
        System.debug('AMER ICE Analysis:');
        System.debug('  Records: ' + ar.get('recordCount'));
        System.debug('  Total Meetings: ' + ar.get('totalMeetings'));
        System.debug('  Total Pipeline: $' + ar.get('totalPipeline'));
        System.debug('  Total ACV: $' + ar.get('totalACV'));
    }
    
} catch (Exception e) {
    System.debug('Test 3 Error: ' + e.getMessage());
}

// Test 4: Statistical Analysis by Dimension
System.debug('\n--- TEST 4: Statistical Analysis by Dimension ---');
try {
    // Meetings by Country with statistics
    List<AggregateResult> countryMeetings = [SELECT 
        WORK_LOCATION_COUNTRY__c country,
        SUM(CQ_CUSTOMER_MEETING__c) totalMeetings,
        AVG(CQ_CUSTOMER_MEETING__c) avgMeetings,
        MAX(CQ_CUSTOMER_MEETING__c) maxMeetings,
        MIN(CQ_CUSTOMER_MEETING__c) minMeetings,
        COUNT(Id) recordCount
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE IsDeleted = false AND CQ_CUSTOMER_MEETING__c != null AND WORK_LOCATION_COUNTRY__c != null
        GROUP BY WORK_LOCATION_COUNTRY__c
        ORDER BY SUM(CQ_CUSTOMER_MEETING__c) DESC
        LIMIT 10];
    
    System.debug('Top 10 Countries by Customer Meetings:');
    for (AggregateResult ar : countryMeetings) {
        System.debug('  ' + ar.get('country') + ': ' + ar.get('totalMeetings') + ' total, ' + 
                    ar.get('avgMeetings') + ' avg, ' + ar.get('recordCount') + ' records');
    }
    
    // Pipeline by OU with statistics
    List<AggregateResult> ouPipeline = [SELECT 
        OU_NAME__c ouName,
        SUM(CQ_PG__c) totalPipeline,
        AVG(CQ_PG__c) avgPipeline,
        MAX(CQ_PG__c) maxPipeline,
        MIN(CQ_PG__c) minPipeline,
        COUNT(Id) recordCount
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE IsDeleted = false AND CQ_PG__c != null AND OU_NAME__c != null
        GROUP BY OU_NAME__c
        ORDER BY SUM(CQ_PG__c) DESC
        LIMIT 10];
    
    System.debug('Top 10 OUs by Pipeline Generation:');
    for (AggregateResult ar : ouPipeline) {
        System.debug('  ' + ar.get('ouName') + ': $' + ar.get('totalPipeline') + ' total, $' + 
                    ar.get('avgPipeline') + ' avg, ' + ar.get('recordCount') + ' records');
    }
    
} catch (Exception e) {
    System.debug('Test 4 Error: ' + e.getMessage());
}

// Test 5: Data Quality Check
System.debug('\n--- TEST 5: Data Quality Check ---');
try {
    // Check for null values in key fields
    Integer nullMeetings = [SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c 
                           WHERE IsDeleted = false AND CQ_CUSTOMER_MEETING__c = null];
    Integer nullPipeline = [SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c 
                           WHERE IsDeleted = false AND CQ_PG__c = null];
    Integer nullACV = [SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c 
                      WHERE IsDeleted = false AND CQ_ACV__c = null];
    
    System.debug('Data Quality Analysis:');
    System.debug('  Records with null CQ_CUSTOMER_MEETING__c: ' + nullMeetings);
    System.debug('  Records with null CQ_PG__c: ' + nullPipeline);
    System.debug('  Records with null CQ_ACV__c: ' + nullACV);
    
    // Check for zero values
    Integer zeroMeetings = [SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c 
                           WHERE IsDeleted = false AND CQ_CUSTOMER_MEETING__c = 0];
    Integer zeroPipeline = [SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c 
                           WHERE IsDeleted = false AND CQ_PG__c = 0];
    Integer zeroACV = [SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c 
                      WHERE IsDeleted = false AND CQ_ACV__c = 0];
    
    System.debug('Zero Value Analysis:');
    System.debug('  Records with CQ_CUSTOMER_MEETING__c = 0: ' + zeroMeetings);
    System.debug('  Records with CQ_PG__c = 0: ' + zeroPipeline);
    System.debug('  Records with CQ_ACV__c = 0: ' + zeroACV);
    
} catch (Exception e) {
    System.debug('Test 5 Error: ' + e.getMessage());
}

// Test 6: Sample Record Analysis
System.debug('\n--- TEST 6: Sample Record Analysis ---');
try {
    // Get a few sample records to examine structure
    List<AGENT_OU_PIPELINE_V2__c> sampleRecords = [SELECT 
        Id, OU_NAME__c, WORK_LOCATION_COUNTRY__c, PRIMARY_INDUSTRY__c,
        CQ_CUSTOMER_MEETING__c, CQ_PG__c, CQ_ACV__c,
        PQ_CUSTOMER_MEETING__c, PQ_PG__c, PQ_ACV__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE IsDeleted = false 
        LIMIT 5];
    
    System.debug('Sample Records Analysis:');
    for (Integer i = 0; i < sampleRecords.size(); i++) {
        AGENT_OU_PIPELINE_V2__c record = sampleRecords[i];
        System.debug('  Record ' + (i+1) + ':');
        System.debug('    OU: ' + record.OU_NAME__c);
        System.debug('    Country: ' + record.WORK_LOCATION_COUNTRY__c);
        System.debug('    Industry: ' + record.PRIMARY_INDUSTRY__c);
        System.debug('    CQ Meetings: ' + record.CQ_CUSTOMER_MEETING__c);
        System.debug('    CQ Pipeline: $' + record.CQ_PG__c);
        System.debug('    CQ ACV: $' + record.CQ_ACV__c);
    }
    
} catch (Exception e) {
    System.debug('Test 6 Error: ' + e.getMessage());
}

System.debug('\n=== DIRECT OBJECT VALIDATION COMPLETED ==='); 