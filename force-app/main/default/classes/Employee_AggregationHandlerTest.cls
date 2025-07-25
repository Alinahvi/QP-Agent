@isTest
private class Employee_AggregationHandlerTest {

    @TestSetup
    static void makeData() {
        List<Learner_Profile__c> testProfiles = new List<Learner_Profile__c>();
        // Create 5 active engineers in AMER
        for (Integer i = 0; i < 5; i++) {
            testProfiles.add(new Learner_Profile__c(
                Name = 'AMER Engineer ' + i, Status__c = 'Active', Division__c = 'AMER', Job_Family__c = 'Engineer'
            ));
        }
        // Create 3 active sales reps in AMER
        for (Integer i = 0; i < 3; i++) {
            testProfiles.add(new Learner_Profile__c(
                Name = 'AMER Sales ' + i, Status__c = 'Active', Division__c = 'AMER', Job_Family__c = 'Sales'
            ));
        }
        // Create 10 active sales reps in EMEA (These should be ignored by the test)
        for (Integer i = 0; i < 10; i++) {
            testProfiles.add(new Learner_Profile__c(
                Name = 'EMEA Sales ' + i, Status__c = 'Active', Division__c = 'EMEA', Job_Family__c = 'Sales'
            ));
        }
        insert testProfiles;
    }

    @isTest
    static void testAggregation_Success() {
        // Arrange
        String sessionId = 'aggTest123';
        Employee_AggregationHandler handler = new Employee_AggregationHandler();

        // 1. Simulate the result of a previous query: "Find employees in AMER"
        // The previous query would have found 8 employees (5 engineers + 3 sales).
        Map<String, Object> previousContext = new Map<String, Object>{'Division__c' => 'AMER'};
        Employee_SessionContext.storeQueryContext(sessionId, previousContext);
        
        // We must also store some segmented employees and a result summary for the handler to proceed.
        // THIS IS THE CORRECTED LOGIC: We re-query for a record created in the setup.
        Learner_Profile__c testRecordForId = [SELECT Id FROM Learner_Profile__c LIMIT 1];
        Employee_SessionContext.storeSegmentedEmployees(sessionId, new List<Id>{testRecordForId.Id});
        Employee_SessionContext.storeResultSummary(sessionId, 8, 1, false);

        // 2. Now, create the aggregation request: "Group them by Job Family"
        Employee_QueryRequest request = new Employee_QueryRequest();
        request.sessionId = sessionId;
        Map<String, Object> queryData = new Map<String, Object>{
            'AGGREGATION' => true,
            'GROUP_BY_FIELD' => 'Job_Family__c'
        };

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);

        // Assert
        System.assertEquals(true, result.success, 'Aggregation should be successful.');
        System.assertEquals(8, result.totalRecords, 'Should process all 8 employees from the previous context.');
        System.assert(result.message.contains('Engineer: 5 employees'), 'Message should contain the count for Engineers.');
        System.assert(result.message.contains('Sales: 3 employees'), 'Message should contain the count for Sales.');
    }

    @isTest
    static void testAggregation_NoPreviousContext() {
        // Arrange: No context is stored in the session cache.
        Employee_AggregationHandler handler = new Employee_AggregationHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        request.sessionId = 'noContextSession';
        Map<String, Object> queryData = new Map<String, Object>{
            'AGGREGATION' => true,
            'GROUP_BY_FIELD' => 'Job_Family__c'
        };
        
        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);

        // Assert
        System.assertEquals(false, result.success, 'Should fail without a previous context.');
        System.assert(result.message.contains('Please run a query to find a set of employees first'), 'Should return a helpful error message.');
    }
}