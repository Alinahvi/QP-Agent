@isTest
private class AHMayCompoundQueryHandlerTest {
    @TestSetup
    static void setupTestData() {
        List<Learner_Profile__c> employees = AHMayTestDataFactory.createTestProfiles(50);
        insert employees;
    }
    
    @isTest
    static void testDirectReportsWithAggregation() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.sessionId = 'compound-test';
        request.pageNumber = 1;
        
        Map<String, Object> queryData = new Map<String, Object>{
            'Status__c' => 'Active',
            'DIRECT_REPORTS' => 'Test Manager 0',
            'AGGREGATION' => true,
            'GROUP_BY_FIELD' => 'Division__c'
        };
        
        AHMayCompoundQueryHandler handler = new AHMayCompoundQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assertNotEquals(null, result.metadataMap);
        System.assertEquals(true, result.metadataMap.get('isCompoundQuery'));
    }
    
    @isTest
    static void testHierarchicalWithAggregation() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.sessionId = 'compound-test-2';
        request.pageNumber = 1;
        
        Map<String, Object> queryData = new Map<String, Object>{
            'Status__c' => 'Active',
            'HIERARCHICAL_QUERY' => 'Test Manager 0',
            'AGGREGATION' => true,
            'GROUP_BY_FIELD' => 'Job_Family__c'
        };
        
        AHMayCompoundQueryHandler handler = new AHMayCompoundQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
    }
    
    @isTest
    static void testCompoundWithoutSession() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.pageNumber = 1;
        // No session ID
        
        Map<String, Object> queryData = new Map<String, Object>{
            'Status__c' => 'Active',
            'DIRECT_REPORTS' => 'Test Manager 0',
            'AGGREGATION' => true,
            'GROUP_BY_FIELD' => 'Division__c'
        };
        
        AHMayCompoundQueryHandler handler = new AHMayCompoundQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assert(result.message.contains('requires a session context'));
    }
    
    @isTest
    static void testCompoundPrimaryFailure() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.sessionId = 'compound-test-3';
        request.pageNumber = 1;
        
        Map<String, Object> queryData = new Map<String, Object>{
            'Status__c' => 'Active',
            'DIRECT_REPORTS' => 'Nonexistent Manager',
            'AGGREGATION' => true,
            'GROUP_BY_FIELD' => 'Division__c'
        };
        
        AHMayCompoundQueryHandler handler = new AHMayCompoundQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        // Should return primary result even if it fails
        System.assertNotEquals(null, result);
    }
}