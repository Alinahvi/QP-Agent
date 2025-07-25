@isTest
private class Employee_StandardQueryHandlerTest {

    @TestSetup
    static void makeData() {
        List<Learner_Profile__c> testProfiles = new List<Learner_Profile__c>();
        // Create 15 active engineers in AMER
        for (Integer i = 0; i < 15; i++) {
            testProfiles.add(new Learner_Profile__c(
                Name = 'AMER Engineer ' + i,
                Status__c = 'Active',
                Division__c = 'AMER',
                Job_Family__c = 'Engineer'
            ));
        }
        // Create 10 active sales reps in EMEA
        for (Integer i = 0; i < 10; i++) {
            testProfiles.add(new Learner_Profile__c(
                Name = 'EMEA Sales ' + i,
                Status__c = 'Active',
                Division__c = 'EMEA',
                Job_Family__c = 'Sales'
            ));
        }
        // Create 1 inactive employee that should never be found
        testProfiles.add(new Learner_Profile__c(
            Name = 'Inactive User',
            Status__c = 'Inactive',
            Division__c = 'AMER',
            Job_Family__c = 'Engineer'
        ));
        insert testProfiles;
    }

    @isTest
    static void testSingleConditionQuery_Success() {
        // Arrange
        Employee_StandardQueryHandler handler = new Employee_StandardQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{'Division__c' => 'AMER'};

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);

        // Assert
        System.assertEquals(true, result.success, 'Query should be successful.');
        System.assertEquals(15, result.totalRecords, 'Should find all 15 active AMER employees.');
        System.assertEquals(15, result.records.size(), 'Should display all 15 found records.');
        System.assert(!result.hasMore, 'There should not be more pages.');
    }

    @isTest
    static void testCompoundConditionQuery_Success() {
        // Arrange
        Employee_StandardQueryHandler handler = new Employee_StandardQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{
            'Division__c' => 'EMEA',
            'Job_Family__c' => 'Sales'
        };

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);

        // Assert
        System.assertEquals(true, result.success);
        System.assertEquals(10, result.totalRecords, 'Should find all 10 active EMEA Sales employees.');
        System.assertEquals(10, result.records.size());
    }

    @isTest
    static void testQuery_NoResultsFound() {
        // Arrange
        Employee_StandardQueryHandler handler = new Employee_StandardQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        Map<String, Object> queryData = new Map<String, Object>{'Division__c' => 'APAC'};

        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);

        // Assert
        System.assertEquals(true, result.success);
        System.assertEquals(0, result.totalRecords, 'Should find 0 records.');
        System.assertEquals(0, result.records.size());
        System.assert(result.message.contains('No matching employees found'), 'Should display the no results message.');
    }

    @isTest
    static void testPagination_MultiplePages() {
        // Arrange
        Employee_StandardQueryHandler handler = new Employee_StandardQueryHandler();
        // The page size is 20, and we have 25 total active employees.
        // Let's query for ALL active employees to test pagination.
        Map<String, Object> queryData = new Map<String, Object>();
        
        // --- Test Page 1 ---
        Employee_QueryRequest page1Request = new Employee_QueryRequest();
        page1Request.pageNumber = 1;

        // Act
        Employee_QueryResult page1Result = handler.handleQuery(page1Request, queryData);
        
        // Assert
        System.assertEquals(25, page1Result.totalRecords, 'Total records should be 25.');
        System.assertEquals(20, page1Result.records.size(), 'Page 1 should show 20 records.');
        System.assertEquals(true, page1Result.hasMore, 'hasMore should be true on page 1.');

        // --- Test Page 2 ---
        Employee_QueryRequest page2Request = new Employee_QueryRequest();
        page2Request.pageNumber = 2;

        // Act
        Employee_QueryResult page2Result = handler.handleQuery(page2Request, queryData);

        // Assert
        System.assertEquals(25, page2Result.totalRecords, 'Total records should still be 25.');
        System.assertEquals(5, page2Result.records.size(), 'Page 2 should show the remaining 5 records.');
        System.assertEquals(false, page2Result.hasMore, 'hasMore should be false on the last page.');
    }

    @isTest
    static void testLargeResultSet_ReturnsWarning() {
        // Arrange
        // Use the @TestVisible variable to lower the threshold for this test
        Employee_StandardQueryHandler.MAX_QUERY_ROWS = 10;
        
        Employee_StandardQueryHandler handler = new Employee_StandardQueryHandler();
        Employee_QueryRequest request = new Employee_QueryRequest();
        // This query will find 15 AMER employees, which is > our test threshold of 10
        Map<String, Object> queryData = new Map<String, Object>{'Division__c' => 'AMER'};
        
        // Act
        Employee_QueryResult result = handler.handleQuery(request, queryData);

        // Assert
        System.assertEquals(true, result.success, 'The query itself should be considered successful.');
        System.assertEquals(15, result.totalRecords, 'Total records should be correctly counted as 15.');
        System.assertEquals(0, result.records.size(), 'No records should be displayed in the list for a large result set.');
        System.assert(result.message.contains('Your query would return approximately'), 'The special warning message for large result sets should be shown.');
    }
}