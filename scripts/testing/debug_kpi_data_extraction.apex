/**
 * Debug KPI Data Extraction
 * See what's actually in the records and why values are 0
 */

System.debug('=== DEBUG KPI DATA EXTRACTION ===');

try {
    // Test 1: Check what's actually in Brazil records
    System.debug('\n--- TEST 1: CHECK BRAZIL RECORD DATA ---');
    
    List<AGENT_OU_PIPELINE_V2__c> brazilRecords = [
        SELECT Id, WORK_LOCATION_COUNTRY__c, CQ_CALL_CONNECT__c, CQ_CUSTOMER_MEETING__c, CQ_PG__c, CQ_ACV__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE WORK_LOCATION_COUNTRY__c = 'Brazil' 
        AND CQ_CALL_CONNECT__c != null
        LIMIT 5
    ];
    
    System.debug('Found ' + brazilRecords.size() + ' Brazil records with call data');
    
    for (Integer i = 0; i < brazilRecords.size(); i++) {
        AGENT_OU_PIPELINE_V2__c record = brazilRecords[i];
        System.debug('Record ' + (i+1) + ':');
        System.debug('  ID: ' + record.Id);
        System.debug('  Country: ' + record.WORK_LOCATION_COUNTRY__c);
        System.debug('  Calls: ' + record.CQ_CALL_CONNECT__c);
        System.debug('  Meetings: ' + record.CQ_CUSTOMER_MEETING__c);
        System.debug('  Pipeline: ' + record.CQ_PG__c);
        System.debug('  ACV: ' + record.CQ_ACV__c);
    }
    
    // Test 2: Check what's in US records
    System.debug('\n--- TEST 2: CHECK US RECORD DATA ---');
    
    List<AGENT_OU_PIPELINE_V2__c> usRecords = [
        SELECT Id, WORK_LOCATION_COUNTRY__c, CQ_CALL_CONNECT__c, CQ_CUSTOMER_MEETING__c, CQ_PG__c, CQ_ACV__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE WORK_LOCATION_COUNTRY__c = 'US' 
        AND CQ_CALL_CONNECT__c != null
        LIMIT 5
    ];
    
    System.debug('Found ' + usRecords.size() + ' US records with call data');
    
    for (Integer i = 0; i < usRecords.size(); i++) {
        AGENT_OU_PIPELINE_V2__c record = usRecords[i];
        System.debug('Record ' + (i+1) + ':');
        System.debug('  ID: ' + record.Id);
        System.debug('  Country: ' + record.WORK_LOCATION_COUNTRY__c);
        System.debug('  Calls: ' + record.CQ_CALL_CONNECT__c);
        System.debug('  Meetings: ' + record.CQ_CUSTOMER_MEETING__c);
        System.debug('  Pipeline: ' + record.CQ_PG__c);
        System.debug('  ACV: ' + record.CQ_ACV__c);
    }
    
    // Test 3: Check aggregate data directly
    System.debug('\n--- TEST 3: CHECK AGGREGATE DATA DIRECTLY ---');
    
    List<AggregateResult> brazilAggregate = [
        SELECT COUNT(Id) totalRecords, SUM(CQ_CALL_CONNECT__c) totalCalls, AVG(CQ_CALL_CONNECT__c) avgCalls
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE WORK_LOCATION_COUNTRY__c = 'Brazil' 
        AND CQ_CALL_CONNECT__c != null
    ];
    
    if (!brazilAggregate.isEmpty()) {
        AggregateResult result = brazilAggregate[0];
        System.debug('Brazil Aggregate:');
        System.debug('  Total Records: ' + result.get('totalRecords'));
        System.debug('  Total Calls: ' + result.get('totalCalls'));
        System.debug('  Avg Calls: ' + result.get('avgCalls'));
    }
    
    // Test 4: Check what the extractKPIValue method would return
    System.debug('\n--- TEST 4: TEST EXTRACT KPI VALUE METHOD ---');
    
    if (!brazilRecords.isEmpty()) {
        AGENT_OU_PIPELINE_V2__c testRecord = brazilRecords[0];
        
        // Simulate what the extractKPIValue method does
        Decimal callValue = (Decimal) testRecord.get('CQ_CALL_CONNECT__c');
        Decimal meetingValue = (Decimal) testRecord.get('CQ_CUSTOMER_MEETING__c');
        Decimal pipelineValue = (Decimal) testRecord.get('CQ_PG__c');
        Decimal acvValue = (Decimal) testRecord.get('CQ_ACV__c');
        
        System.debug('Extracted Values:');
        System.debug('  Call Value: ' + callValue + ' (Type: ' + callValue?.getType() + ')');
        System.debug('  Meeting Value: ' + meetingValue + ' (Type: ' + meetingValue?.getType() + ')');
        System.debug('  Pipeline Value: ' + pipelineValue + ' (Type: ' + pipelineValue?.getType() + ')');
        System.debug('  ACV Value: ' + acvValue + ' (Type: ' + acvValue?.getType() + ')');
        
        // Check if values are actually 0 or null
        System.debug('Value Checks:');
        System.debug('  Call Value > 0: ' + (callValue > 0));
        System.debug('  Call Value != null: ' + (callValue != null));
        System.debug('  Call Value >= 0: ' + (callValue >= 0));
    }
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== DEBUG KPI DATA EXTRACTION COMPLETED ==='); 