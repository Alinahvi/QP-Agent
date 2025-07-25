@isTest
private class AHMayStandardQueryHandlerTest {
    @TestSetup
    static void setupTestData() {
        List<Learner_Profile__c> testProfiles = AHMayTestDataFactory.createTestProfiles(50);
        insert testProfiles;
    }
    
    @isTest
    static void testStandardQuery() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.pageNumber = 1;
        
        Map<String, Object> queryData = new Map<String, Object>{
            'Status__c' => 'Active',
            'Division__c' => 'AMER'
        };
        
        AHMayStandardQueryHandler handler = new AHMayStandardQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assertNotEquals(null, result.records);
    }
    
    @isTest
    static void testLargeResultSetHandling() {
        // Create many records to test large result set handling
        List<Learner_Profile__c> largeDataSet = AHMayTestDataFactory.createTestProfiles(10001);
        insert largeDataSet;
        
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.pageNumber = 1;
        
        Map<String, Object> queryData = new Map<String, Object>{
            'Status__c' => 'Active'
        };
        
        AHMayStandardQueryHandler handler = new AHMayStandardQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assert(result.message.contains('Your query would return approximately'));
    }
    
    @isTest
    static void testOrConditions() {
        AHMayQueryRequest request = new AHMayQueryRequest();
        request.pageNumber = 1;
        
        Map<String, Object> queryData = new Map<String, Object>{
            'Status__c' => 'Active',
            'Division__c_OR' => new List<String>{'AMER', 'EMEA'}
        };
        
        AHMayOrConditionQueryHandler handler = new AHMayOrConditionQueryHandler();
        Test.startTest();
        AHMayQueryResult result = handler.handleQuery(request, queryData);
        Test.stopTest();
        
        System.assertEquals(true, result.success);
    }
}