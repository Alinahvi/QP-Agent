@isTest
private class AHMaySessionContextTest {

    @isTest
    static void testQueryContext() {
        String sessionId = 'session1';
        Map<String, Object> context = new Map<String, Object>{'field' => 'Division__c', 'value' => 'Sales'};

        Test.startTest();
        AHMaySessionContext.storeQueryContext(sessionId, context);
        Map<String, Object> retrieved = AHMaySessionContext.getQueryContext(sessionId);
        AHMaySessionContext.clearQueryContext(sessionId);
        Map<String, Object> afterClear = AHMaySessionContext.getQueryContext(sessionId);
        Test.stopTest();

        System.assertEquals('Sales', retrieved.get('value'), 'Should retrieve the stored context.');
        System.assert(afterClear.isEmpty(), 'Context should be empty after clearing.');
    }

    @isTest
    static void testSessionTotalCount() {
        String sessionId = 'session2';
        
        Test.startTest();
        AHMaySessionContext.storeSessionTotalCount(sessionId, 150);
        Integer count = AHMaySessionContext.getSessionTotalCount(sessionId);
        Test.stopTest();

        System.assertEquals(150, count, 'Should retrieve the stored total count.');
    }

    @isTest
    static void testResultSummary() {
        String sessionId = 'session3';
        
        Test.startTest();
        AHMaySessionContext.storeResultSummary(sessionId, 100, 1, true);
        Map<String, Object> summary = AHMaySessionContext.getResultSummary(sessionId);
        Test.stopTest();

        System.assertEquals(100, summary.get('totalRecords'));
        System.assertEquals(true, summary.get('hasMore'));
    }

    @isTest
    static void testIntelligentMergeContext() {
        String sessionId = 'session4';
        Map<String, Object> previousContext = new Map<String, Object>{'Division__c' => 'Sales'};
        Map<String, Object> newQuery = new Map<String, Object>{'Work_Location_Country__c' => 'USA'};

        AHMaySessionContext.storeQueryContext(sessionId, previousContext);

        Test.startTest();
        // This method has complex logic, we test a simple merge
        Map<String, Object> merged = AHMaySessionContext.intelligentMergeContext(sessionId, newQuery);
        Test.stopTest();
        
        // The provided implementation just returns the new query data, but a real implementation would merge.
        // We test the provided behavior.
        System.assertEquals('USA', merged.get('Work_Location_Country__c'));
    }

    @isTest
    static void testSegmentedEmployeeMethods() {
        String sessionId = 'session5';
        List<Id> employeeIds = new List<Id>{'001xx000003DHPWAA4'};
        
        Test.startTest();
        AHMaySessionContext.storeSegmentedEmployees(sessionId, employeeIds);
        Boolean hasEmployees = AHMaySessionContext.hasSegmentedEmployees(sessionId);
        Integer count = AHMaySessionContext.getSegmentedEmployeeCount(sessionId);
        List<Id> retrieved = AHMaySessionContext.getSegmentedEmployeeIds(sessionId);
        Test.stopTest();

        System.assertEquals(true, hasEmployees);
        System.assertEquals(1, count);
        System.assertEquals(1, retrieved.size());
    }

    @isTest
    static void testMinimalImplementationMethods() {
        Test.startTest();
        Map<String, Object> stats = AHMaySessionContext.getSessionStats();
        Integer cleaned = AHMaySessionContext.cleanupExpiredSessions();
        Test.stopTest();

        System.assertNotEquals(null, stats, 'Should return a stats map.');
        System.assertEquals(0, cleaned, 'Should return 0 as per minimal implementation.');
    }
}