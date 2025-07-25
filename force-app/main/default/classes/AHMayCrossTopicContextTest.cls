@isTest
private class AHMayCrossTopicContextTest {

    @isTest
    static void testStoreAndGetEmployees() {
        String sessionId = 'session123';
        List<Id> employeeIds = new List<Id>{'001xx000003DHPWAA4', '001xx000003DHPWAA5'};

        Test.startTest();
        AHMayCrossTopicContext.storeSegmentedEmployees(sessionId, employeeIds);
        List<Id> retrievedIds = AHMayCrossTopicContext.getSegmentedEmployeeIds(sessionId);
        Integer count = AHMayCrossTopicContext.getSegmentedEmployeeCount(sessionId);
        Boolean hasEmployees = AHMayCrossTopicContext.hasSegmentedEmployees(sessionId);
        Test.stopTest();

        System.assertEquals(2, retrievedIds.size(), 'Should retrieve the stored employee IDs.');
        System.assertEquals(2, count, 'Count should be 2.');
        System.assertEquals(true, hasEmployees, 'Should have segmented employees.');
    }

    @isTest
    static void testAddToSegmentedEmployees() {
        String sessionId = 'session123';
        List<Id> initialIds = new List<Id>{'001xx000003DHPWAA4'};
        List<Id> additionalIds = new List<Id>{'001xx000003DHPWAA5', '001xx000003DHPWAA6'};

        AHMayCrossTopicContext.storeSegmentedEmployees(sessionId, initialIds);
        
        Test.startTest();
        AHMayCrossTopicContext.addToSegmentedEmployees(sessionId, additionalIds);
        Integer count = AHMayCrossTopicContext.getSegmentedEmployeeCount(sessionId);
        Test.stopTest();

        System.assertEquals(3, count, 'Should combine initial and additional IDs.');
    }

    @isTest
    static void testClearContext() {
        String sessionId = 'session123';
        List<Id> employeeIds = new List<Id>{'001xx000003DHPWAA4'};
        AHMayCrossTopicContext.storeSegmentedEmployees(sessionId, employeeIds);

        Test.startTest();
        AHMayCrossTopicContext.clearContext(sessionId);
        Boolean hasEmployees = AHMayCrossTopicContext.hasSegmentedEmployees(sessionId);
        Test.stopTest();

        System.assertEquals(false, hasEmployees, 'Context should be cleared.');
    }

    @isTest
    static void testEdgeCases() {
        Test.startTest();
        // Null and blank session IDs
        AHMayCrossTopicContext.storeSegmentedEmployees(null, new List<Id>{'001xx000003DHPWAA4'});
        AHMayCrossTopicContext.storeSegmentedEmployees('', new List<Id>{'001xx000003DHPWAA4'});
        // Null or empty lists
        AHMayCrossTopicContext.storeSegmentedEmployees('session123', null);
        AHMayCrossTopicContext.storeSegmentedEmployees('session123', new List<Id>());

        // Verify no state was stored
        Boolean hasEmployees = AHMayCrossTopicContext.hasSegmentedEmployees('session123');
        List<Id> retrievedForNull = AHMayCrossTopicContext.getSegmentedEmployeeIds(null);
        Test.stopTest();

        System.assertEquals(false, hasEmployees, 'No employees should be stored for edge cases.');
        System.assert(retrievedForNull.isEmpty(), 'Getting with null session ID should return empty list.');
    }
}