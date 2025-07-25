/**
 * @description Test class for Employee_SessionContext.
 * This class verifies that session data is correctly stored in and retrieved from
 * the Platform Cache.
 */
@isTest
private class Employee_SessionContextTest {

    private static final String SESSION_ID = 'testSession123';

    @isTest
    static void testStoreAndGetQueryContext() {
        // Arrange
        Map<String, Object> queryData = new Map<String, Object>{
            'Division__c' => 'AMER',
            'FTE__c' => true
        };

        // Act
        Test.startTest();
        Employee_SessionContext.storeQueryContext(SESSION_ID, queryData);
        Map<String, Object> result = Employee_SessionContext.getQueryContext(SESSION_ID);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Query context should not be null.');
        System.assertEquals(2, result.size(), 'Query context should have 2 entries.');
        System.assertEquals('AMER', result.get('Division__c'), 'Division__c should be AMER.');
    }

    @isTest
    static void testGetQueryContext_NoData() {
        // Act
        Test.startTest();
        Map<String, Object> result = Employee_SessionContext.getQueryContext('nonexistentSession');
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Result should be an empty map, not null.');
        System.assertEquals(true, result.isEmpty(), 'Result should be an empty map.');
    }

    @isTest
    static void testStoreAndGetResultSummary() {
        // Act
        Test.startTest();
        Employee_SessionContext.storeResultSummary(SESSION_ID, 100, 1, true);
        Map<String, Object> result = Employee_SessionContext.getResultSummary(SESSION_ID);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Result summary should not be null.');
        System.assertEquals(100, result.get('totalRecords'));
        System.assertEquals(1, result.get('pageNumber'));
        System.assertEquals(true, result.get('hasMore'));
    }

    @isTest
    static void testStoreAndGetSegmentedEmployees() {
        // Arrange
        List<Id> employeeIds = new List<Id>{
            '001xx000003DHPPAA4',
            '001xx000003DHPPAA5'
        };
        
        // Act
        Test.startTest();
        Employee_SessionContext.storeSegmentedEmployees(SESSION_ID, employeeIds);
        Boolean hasEmployees = Employee_SessionContext.hasSegmentedEmployees(SESSION_ID);
        List<Id> resultIds = Employee_SessionContext.getSegmentedEmployeeIds(SESSION_ID);
        Test.stopTest();

        // Assert
        System.assertEquals(true, hasEmployees, 'Should report having segmented employees.');
        System.assertEquals(2, resultIds.size(), 'Should retrieve 2 employee IDs.');
        System.assertEquals(employeeIds[0], resultIds[0]);
    }

    @isTest
    static void testIntelligentMergeContext() {
        // Arrange
        Map<String, Object> initialContext = new Map<String, Object>{
            'Division__c' => 'AMER',
            'Job_Family__c' => 'Engineer'
        };
        Employee_SessionContext.storeQueryContext(SESSION_ID, initialContext);
        
        Map<String, Object> followUpQuery = new Map<String, Object>{
            'MAINTAIN_PREVIOUS_CONTEXT' => true,
            'Work_Location_Country__c' => 'USA'
        };

        // Act
        Test.startTest();
        Map<String, Object> mergedResult = Employee_SessionContext.intelligentMergeContext(SESSION_ID, followUpQuery);
        Test.stopTest();

        // Assert
        System.assertEquals(3, mergedResult.size(), 'Merged context should have 3 filters.');
        System.assertEquals('AMER', mergedResult.get('Division__c'), 'Original Division filter should be maintained.');
        System.assertEquals('USA', mergedResult.get('Work_Location_Country__c'), 'New Country filter should be added.');
    }

    @isTest
    static void testClearAllContext() {
        // Arrange
        Map<String, Object> queryData = new Map<String, Object>{'Division__c' => 'AMER'};
        Employee_SessionContext.storeQueryContext(SESSION_ID, queryData);
        Employee_SessionContext.storeResultSummary(SESSION_ID, 10, 1, false);

        // Act
        Test.startTest();
        Employee_SessionContext.clearAllContext(SESSION_ID);
        Map<String, Object> queryResult = Employee_SessionContext.getQueryContext(SESSION_ID);
        Map<String, Object> summaryResult = Employee_SessionContext.getResultSummary(SESSION_ID);
        Test.stopTest();

        // Assert
        System.assertEquals(true, queryResult.isEmpty(), 'Query context should be empty after clearing.');
        System.assertEquals(null, summaryResult, 'Result summary should be null after clearing.');
    }
}