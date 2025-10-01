/**
 * Brazil vs USA Calls per AE Analysis - FIXED VERSION
 * Comprehensive comparison with accurate averages
 */

System.debug('=== BRAZIL vs USA CALLS PER AE ANALYSIS - FIXED ===');

try {
    // PART 1: BRAZIL CALLS ANALYSIS
    System.debug('\n--- PART 1: BRAZIL CALLS ANALYSIS ---');
    
    // Brazil calls by AE - FIXED SYNTAX
    String brazilCallsByAEQuery = 'SELECT FULL_NAME__c, EMP_ID__c, SUM(CQ_CALL_CONNECT__c), COUNT(Id), AVG(CQ_CALL_CONNECT__c) ' +
                                  'FROM AGENT_OU_PIPELINE_V2__c ' +
                                  'WHERE WORK_LOCATION_COUNTRY__c = \'Brazil\' ' +
                                  'AND CQ_CALL_CONNECT__c != null ' +
                                  'AND FULL_NAME__c != null ' +
                                  'GROUP BY FULL_NAME__c, EMP_ID__c ' +
                                  'ORDER BY SUM(CQ_CALL_CONNECT__c) DESC';
    
    System.debug('Brazil Calls by AE Query: ' + brazilCallsByAEQuery);
    
    try {
        List<AggregateResult> brazilCallsByAEResults = Database.query(brazilCallsByAEQuery);
        System.debug('Brazil Calls by AE - Found ' + brazilCallsByAEResults.size() + ' AEs');
        
        Decimal brazilTotalCalls = 0;
        Integer brazilTotalRecords = 0;
        
        for (AggregateResult result : brazilCallsByAEResults) {
            String aeName = (String) result.get('FULL_NAME__c');
            String empId = (String) result.get('EMP_ID__c');
            Decimal totalCalls = (Decimal) result.get('expr0'); // SUM(CQ_CALL_CONNECT__c)
            Integer recordCount = (Integer) result.get('expr1'); // COUNT(Id)
            Decimal avgCalls = (Decimal) result.get('expr2'); // AVG(CQ_CALL_CONNECT__c)
            
            brazilTotalCalls += totalCalls;
            brazilTotalRecords += recordCount;
            
            System.debug('  AE: ' + aeName + ' (ID: ' + empId + ') - Total Calls: ' + totalCalls + ', Records: ' + recordCount + ', Avg: ' + avgCalls);
        }
        
        Decimal brazilOverallAvg = brazilTotalRecords > 0 ? brazilTotalCalls / brazilTotalRecords : 0;
        System.debug('\nBrazil Summary:');
        System.debug('  Total Calls: ' + brazilTotalCalls);
        System.debug('  Total Records: ' + brazilTotalRecords);
        System.debug('  Overall Average per Record: ' + brazilOverallAvg);
        
    } catch (Exception e) {
        System.debug('Brazil Calls by AE Query Error: ' + e.getMessage());
    }
    
    // PART 2: BRAZIL MEETINGS ANALYSIS
    System.debug('\n--- PART 2: BRAZIL MEETINGS ANALYSIS ---');
    
    // Brazil meetings by AE - FIXED SYNTAX
    String brazilMeetingsByAEQuery = 'SELECT FULL_NAME__c, EMP_ID__c, SUM(CQ_CUSTOMER_MEETING__c), COUNT(Id), AVG(CQ_CUSTOMER_MEETING__c) ' +
                                    'FROM AGENT_OU_PIPELINE_V2__c ' +
                                    'WHERE WORK_LOCATION_COUNTRY__c = \'Brazil\' ' +
                                    'AND CQ_CUSTOMER_MEETING__c != null ' +
                                    'AND FULL_NAME__c != null ' +
                                    'GROUP BY FULL_NAME__c, EMP_ID__c ' +
                                    'ORDER BY SUM(CQ_CUSTOMER_MEETING__c) DESC';
    
    System.debug('Brazil Meetings by AE Query: ' + brazilMeetingsByAEQuery);
    
    try {
        List<AggregateResult> brazilMeetingsByAEResults = Database.query(brazilMeetingsByAEQuery);
        System.debug('Brazil Meetings by AE - Found ' + brazilMeetingsByAEResults.size() + ' AEs');
        
        Decimal brazilTotalMeetings = 0;
        Integer brazilTotalMeetingRecords = 0;
        
        for (AggregateResult result : brazilMeetingsByAEResults) {
            String aeName = (String) result.get('FULL_NAME__c');
            String empId = (String) result.get('EMP_ID__c');
            Decimal totalMeetings = (Decimal) result.get('expr0'); // SUM(CQ_CUSTOMER_MEETING__c)
            Integer recordCount = (Integer) result.get('expr1'); // COUNT(Id)
            Decimal avgMeetings = (Decimal) result.get('expr2'); // AVG(CQ_CUSTOMER_MEETING__c)
            
            brazilTotalMeetings += totalMeetings;
            brazilTotalMeetingRecords += recordCount;
            
            System.debug('  AE: ' + aeName + ' (ID: ' + empId + ') - Total Meetings: ' + totalMeetings + ', Records: ' + recordCount + ', Avg: ' + avgMeetings);
        }
        
        Decimal brazilOverallMeetingAvg = brazilTotalMeetingRecords > 0 ? brazilTotalMeetings / brazilTotalMeetingRecords : 0;
        System.debug('\nBrazil Meetings Summary:');
        System.debug('  Total Meetings: ' + brazilTotalMeetings);
        System.debug('  Total Records: ' + brazilTotalMeetingRecords);
        System.debug('  Overall Average per Record: ' + brazilOverallMeetingAvg);
        
    } catch (Exception e) {
        System.debug('Brazil Meetings by AE Query Error: ' + e.getMessage());
    }
    
    // PART 3: USA CALLS ANALYSIS
    System.debug('\n--- PART 3: USA CALLS ANALYSIS ---');
    
    // USA calls by AE - FIXED SYNTAX
    String usaCallsByAEQuery = 'SELECT FULL_NAME__c, EMP_ID__c, SUM(CQ_CALL_CONNECT__c), COUNT(Id), AVG(CQ_CALL_CONNECT__c) ' +
                               'FROM AGENT_OU_PIPELINE_V2__c ' +
                               'WHERE WORK_LOCATION_COUNTRY__c = \'US\' ' +
                               'AND CQ_CALL_CONNECT__c != null ' +
                               'AND FULL_NAME__c != null ' +
                               'GROUP BY FULL_NAME__c, EMP_ID__c ' +
                               'ORDER BY SUM(CQ_CALL_CONNECT__c) DESC';
    
    System.debug('USA Calls by AE Query: ' + usaCallsByAEQuery);
    
    try {
        List<AggregateResult> usaCallsByAEResults = Database.query(usaCallsByAEQuery);
        System.debug('USA Calls by AE - Found ' + usaCallsByAEResults.size() + ' AEs');
        
        Decimal usaTotalCalls = 0;
        Integer usaTotalRecords = 0;
        
        for (AggregateResult result : usaCallsByAEResults) {
            String aeName = (String) result.get('FULL_NAME__c');
            String empId = (String) result.get('EMP_ID__c');
            Decimal totalCalls = (Decimal) result.get('expr0'); // SUM(CQ_CALL_CONNECT__c)
            Integer recordCount = (Integer) result.get('expr1'); // COUNT(Id)
            Decimal avgCalls = (Decimal) result.get('expr2'); // AVG(CQ_CALL_CONNECT__c)
            
            usaTotalCalls += totalCalls;
            usaTotalRecords += recordCount;
            
            System.debug('  AE: ' + aeName + ' (ID: ' + empId + ') - Total Calls: ' + totalCalls + ', Records: ' + recordCount + ', Avg: ' + avgCalls);
        }
        
        Decimal usaOverallAvg = usaTotalRecords > 0 ? usaTotalCalls / usaTotalRecords : 0;
        System.debug('\nUSA Summary:');
        System.debug('  Total Calls: ' + usaTotalCalls);
        System.debug('  Total Records: ' + usaTotalRecords);
        System.debug('  Overall Average per Record: ' + usaOverallAvg);
        
    } catch (Exception e) {
        System.debug('USA Calls by AE Query Error: ' + e.getMessage());
    }
    
    // PART 4: COMPARISON SUMMARY (This part worked correctly)
    System.debug('\n--- PART 4: COMPARISON SUMMARY ---');
    
    // Get overall Brazil vs USA comparison
    String comparisonQuery = 'SELECT WORK_LOCATION_COUNTRY__c, ' +
                            'COUNT(Id) totalRecords, ' +
                            'SUM(CQ_CALL_CONNECT__c) totalCalls, ' +
                            'AVG(CQ_CALL_CONNECT__c) avgCalls, ' +
                            'SUM(CQ_CUSTOMER_MEETING__c) totalMeetings, ' +
                            'AVG(CQ_CUSTOMER_MEETING__c) avgMeetings ' +
                            'FROM AGENT_OU_PIPELINE_V2__c ' +
                            'WHERE WORK_LOCATION_COUNTRY__c IN (\'Brazil\', \'US\') ' +
                            'GROUP BY WORK_LOCATION_COUNTRY__c';
    
    System.debug('Comparison Query: ' + comparisonQuery);
    
    try {
        List<AggregateResult> comparisonResults = Database.query(comparisonQuery);
        System.debug('\nCountry Comparison:');
        
        for (AggregateResult result : comparisonResults) {
            String country = (String) result.get('WORK_LOCATION_COUNTRY__c');
            Integer totalRecords = (Integer) result.get('totalRecords');
            Decimal totalCalls = (Decimal) result.get('totalCalls');
            Decimal avgCalls = (Decimal) result.get('avgCalls');
            Decimal totalMeetings = (Decimal) result.get('totalMeetings');
            Decimal avgMeetings = (Decimal) result.get('avgMeetings');
            
            System.debug('\n' + country + ':');
            System.debug('  Total Records: ' + totalRecords);
            System.debug('  Total Calls: ' + totalCalls);
            System.debug('  Average Calls per Record: ' + avgCalls);
            System.debug('  Total Meetings: ' + totalMeetings);
            System.debug('  Average Meetings per Record: ' + avgMeetings);
        }
        
    } catch (Exception e) {
        System.debug('Comparison Query Error: ' + e.getMessage());
    }
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== BRAZIL vs USA ANALYSIS COMPLETED ==='); 