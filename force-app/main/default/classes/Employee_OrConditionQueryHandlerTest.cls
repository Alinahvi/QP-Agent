@isTest
private class Employee_OrConditionQueryHandlerTest {

    @TestSetup
    static void makeData() {
        List<Learner_Profile__c> testProfiles = new List<Learner_Profile__c>();
        // 5 AMER Engineers
        for (Integer i = 0; i < 5; i++) {
            testProfiles.add(new Learner_Profile__c(
                Name = 'AMER Engineer ' + i, Status__c = 'Active', Division__c = 'AMER', Job_Family__c = 'Engineer'
            ));
        }
        // 3 EMEA Engineers
        for (Integer i = 0; i < 3; i++) {
            testProfiles.add(new Learner_Profile__c(
                Name = 'EMEA Engineer ' + i, Status__c = 'Active', Division__c = 'EMEA', Job_Family__c = 'Engineer'
            ));
        }
        // 10 APAC Engineers (should be excluded by the OR clause)
        for (Integer i = 0; i < 10; i++) {
            testProfiles.add(new Learner_Profile__c(
                Name = 'APAC Engineer ' + i, Status__c = 'Active', Division__c = 'APAC', Job_Family__c = 'Engineer'
            ));
        }
        // 5 AMER Sales Reps (should be excluded by the AND clause)
        for (Integer i = 0; i < 5; i++) {
            testProfiles.add(new Learner_Profile__c(
                Name = 'AMER Sales ' + i, Status__c = 'Active', Division__c = 'AMER', Job_Family__c = 'Sales'
            ));
        }
        insert testProfiles;
    }

    @isTest
    static void testOrCondition_WithAndCondition_Success() {
        // Arrange: Find all 'Engineers' who are in division 'AMER' OR 'EMEA'.
        Employee_OrConditionQueryHandler handler = new Employee_OrConditionQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{
            'Job_Family__c' => 'Engineer',
            'Division__c_OR' => new List<String>{'AMER', 'EMEA'}
        };

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);

        // Assert
        System.assertEquals(true, result.success, 'Query should be successful.');
        // Should find the 5 AMER engineers + 3 EMEA engineers = 8 total.
        System.assertEquals(8, result.totalRecords, 'Should find all engineers in AMER and EMEA.');
        System.assertEquals(8, result.records.size());
        
        // Verify the query structure
        System.assert(result.queryUsed.contains('Job_Family__c = \'Engineer\''), 'Query should contain the AND condition.');
        System.assert(result.queryUsed.contains('(Division__c = \'AMER\' OR Division__c = \'EMEA\')'), 'Query should contain the OR clause.');
    }
}