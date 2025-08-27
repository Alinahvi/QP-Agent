/**
 * Debug Apex KPI Analysis Service Issues
 * Test basic functionality and identify problems
 */

System.debug('=== DEBUGGING APEX KPI ANALYSIS SERVICE ===');

try {
    // Test 1: Basic Brazil calls analysis
    System.debug('\n--- TEST 1: BRAZIL CALLS ANALYSIS ---');
    
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request1 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request1.analysisType = 'CALLS';
    request1.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request1.primaryValue = 'Brazil';
    request1.includeDetails = true;
    
    System.debug('Request 1: ' + request1);
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses1 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request1 });
    
    if (!responses1.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response1 = responses1[0];
        System.debug('Response 1 Success: ' + response1.success);
        System.debug('Response 1 Total Records: ' + response1.totalRecords);
        System.debug('Response 1 Total Value: ' + response1.totalValue);
        System.debug('Response 1 Message: ' + response1.message);
        System.debug('Response 1 Detailed Results: ' + response1.detailedResults);
    }
    
    // Test 2: Brazil meetings analysis
    System.debug('\n--- TEST 2: BRAZIL MEETINGS ANALYSIS ---');
    
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request2 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request2.analysisType = 'MEETINGS';
    request2.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request2.primaryValue = 'Brazil';
    request2.includeDetails = true;
    
    System.debug('Request 2: ' + request2);
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses2 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request2 });
    
    if (!responses2.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response2 = responses2[0];
        System.debug('Response 2 Success: ' + response2.success);
        System.debug('Response 2 Total Records: ' + response2.totalRecords);
        System.debug('Response 2 Total Value: ' + response2.totalValue);
        System.debug('Response 2 Message: ' + response2.message);
        System.debug('Response 2 Detailed Results: ' + response2.detailedResults);
    }
    
    // Test 3: Direct SOQL to verify data exists
    System.debug('\n--- TEST 3: DIRECT SOQL VERIFICATION ---');
    
    // Check Brazil calls
    String brazilCallsQuery = 'SELECT COUNT(Id) totalRecords, SUM(CQ_CALL_CONNECT__c) totalCalls, AVG(CQ_CALL_CONNECT__c) avgCalls ' +
                             'FROM AGENT_OU_PIPELINE_V2__c ' +
                             'WHERE WORK_LOCATION_COUNTRY__c = \'Brazil\' ' +
                             'AND CQ_CALL_CONNECT__c != null';
    
    System.debug('Brazil Calls Query: ' + brazilCallsQuery);
    
    try {
        List<AggregateResult> brazilCallsResults = Database.query(brazilCallsQuery);
        if (!brazilCallsResults.isEmpty()) {
            AggregateResult result = brazilCallsResults[0];
            Integer totalRecords = (Integer) result.get('totalRecords');
            Decimal totalCalls = (Decimal) result.get('totalCalls');
            Decimal avgCalls = (Decimal) result.get('avgCalls');
            System.debug('Brazil Calls - Total Records: ' + totalRecords + ', Total Calls: ' + totalCalls + ', Avg Calls: ' + avgCalls);
        }
    } catch (Exception e) {
        System.debug('Brazil Calls Query Error: ' + e.getMessage());
    }
    
    // Check Brazil meetings
    String brazilMeetingsQuery = 'SELECT COUNT(Id) totalRecords, SUM(CQ_CUSTOMER_MEETING__c) totalMeetings, AVG(CQ_CUSTOMER_MEETING__c) avgMeetings ' +
                                'FROM AGENT_OU_PIPELINE_V2__c ' +
                                'WHERE WORK_LOCATION_COUNTRY__c = \'Brazil\' ' +
                                'AND CQ_CUSTOMER_MEETING__c != null';
    
    System.debug('Brazil Meetings Query: ' + brazilMeetingsQuery);
    
    try {
        List<AggregateResult> brazilMeetingsResults = Database.query(brazilMeetingsQuery);
        if (!brazilMeetingsResults.isEmpty()) {
            AggregateResult result = brazilMeetingsResults[0];
            Integer totalRecords = (Integer) result.get('totalRecords');
            Decimal totalMeetings = (Decimal) result.get('totalMeetings');
            Decimal avgMeetings = (Decimal) result.get('avgMeetings');
            System.debug('Brazil Meetings - Total Records: ' + totalRecords + ', Total Meetings: ' + totalMeetings + ', Avg Meetings: ' + avgMeetings);
        }
    } catch (Exception e) {
        System.debug('Brazil Meetings Query Error: ' + e.getMessage());
    }
    
    // Test 4: Check what countries actually exist
    System.debug('\n--- TEST 4: CHECK AVAILABLE COUNTRIES ---');
    
    List<AGENT_OU_PIPELINE_V2__c> countrySamples = [
        SELECT WORK_LOCATION_COUNTRY__c
        FROM AGENT_OU_PIPELINE_V2__c 
        WHERE WORK_LOCATION_COUNTRY__c != null
        LIMIT 50
    ];
    
    Map<String, Integer> countryCounts = new Map<String, Integer>();
    for (AGENT_OU_PIPELINE_V2__c record : countrySamples) {
        String country = record.WORK_LOCATION_COUNTRY__c;
        countryCounts.put(country, countryCounts.containsKey(country) ? countryCounts.get(country) + 1 : 1);
    }
    
    System.debug('Sample Countries with data:');
    for (String country : countryCounts.keySet()) {
        System.debug('  ' + country + ': ' + countryCounts.get(country) + ' records');
    }
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== APEX SERVICE DEBUG COMPLETED ==='); 