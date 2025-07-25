@isTest
private class AHMayAggregationHandlerTest {
    @TestSetup
    static void setupTestData() {
        List<Learner_Profile__c> employees = AHMayTestDataFactory.createTestProfiles(100);
        insert employees;
    }
    
    @isTest
    static void testBasicAggregation() {
        // First run a query to populate the cache
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.userInput = 'Show me employees in AMER';
        request.sessionId = 'test-session';
        request.pageNumber = 1;
        
        AHMayQueryEmployees.queryEmployees(new List<AHMayQueryRequest>{request});
        
        // Now run aggregation
        Map<String, Object> aggregationData = new Map<String, Object>{
            'MAINTAIN_PREVIOUS_CONTEXT' => true,
            'AGGREGATION' => true,
            'GROUP_BY_FIELD' => 'Division__c'
        };
        
        AHMayAggregationHandler handler = new AHMayAggregationHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, aggregationData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assert(result.message.contains('Employees grouped by Division'));
    }
    
    @isTest
    static void testDateAggregation() {
        String sessionId = 'test-session-date';
        
        // Populate cache
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.sessionId = sessionId;
        request.pageNumber = 1;
        
        List<Learner_Profile__c> employees = [SELECT Id, Name, Primary_Email__c, Hire_Date__c 
                                            FROM Learner_Profile__c 
                                            WHERE Status__c = 'Active' 
                                            LIMIT 50];
        
        AHMayQueryCache.storeResults(sessionId, employees);
        AHMaySessionContext.storeSessionTotalCount(sessionId, employees.size());
        
        Map<String, Object> aggregationData = new Map<String, Object>{
            'AGGREGATION' => true,
            'GROUP_BY_FIELD' => 'Hire_Date__c',
            'GROUP_BY_DATE_UNIT' => 'MONTH'
        };
        
        AHMayAggregationHandler handler = new AHMayAggregationHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, aggregationData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assert(result.message.contains('Employees grouped by month'));
    }
    
    @isTest
    static void testMultiFieldAggregation() {
        String sessionId = 'test-session-multi';
        
        // Populate cache
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.sessionId = sessionId;
        request.pageNumber = 1;
        
        List<Learner_Profile__c> employees = [SELECT Id, Name, Primary_Email__c, Division__c, Job_Family__c 
                                            FROM Learner_Profile__c 
                                            WHERE Status__c = 'Active' 
                                            LIMIT 50];
        
        AHMayQueryCache.storeResults(sessionId, employees);
        AHMaySessionContext.storeSessionTotalCount(sessionId, employees.size());
        
        Map<String, Object> aggregationData = new Map<String, Object>{
            'AGGREGATION' => true,
            'GROUP_BY_FIELDS' => new List<String>{'Division__c', 'Job_Family__c'}
        };
        
        AHMayAggregationHandler handler = new AHMayAggregationHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, aggregationData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assert(result.message.contains('Employees grouped by multiple fields'));
    }
    
    @isTest
    static void testAggregationWithoutCache() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.sessionId = 'no-cache-session';
        
        Map<String, Object> aggregationData = new Map<String, Object>{
            'AGGREGATION' => true,
            'GROUP_BY_FIELD' => 'Division__c'
        };
        
        AHMayAggregationHandler handler = new AHMayAggregationHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, aggregationData);
        Test.stopTest();
        
        System.assertEquals(false, result.success);
        System.assert(result.message.contains('previous context'));
    }
    
    @isTest
    static void testPartialDataAggregation() {
        String sessionId = 'test-session-partial';
        
        // Simulate partial data scenario
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.sessionId = sessionId;
        
        List<Learner_Profile__c> employees = [SELECT Id, Name, Primary_Email__c, Division__c 
                                            FROM Learner_Profile__c 
                                            WHERE Status__c = 'Active' 
                                            LIMIT 20];
        
        AHMayQueryCache.storeResults(sessionId, employees);
        AHMaySessionContext.storeSessionTotalCount(sessionId, 1000); // Simulate more total records
        
        Map<String, Object> aggregationData = new Map<String, Object>{
            'AGGREGATION' => true,
            'GROUP_BY_FIELD' => 'Division__c'
        };
        
        AHMayAggregationHandler handler = new AHMayAggregationHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, aggregationData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assert(result.message.contains('based on a subset of the data'));
    }
}