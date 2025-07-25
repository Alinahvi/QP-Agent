@isTest
private class TrainingSessionContextTest {

    private static User testUser;
    
    @TestSetup
    static void makeData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        testUser = new User(
            Alias = 'testu', Email = 'testuser@example.com', EmailEncodingKey = 'UTF-8',
            LastName = 'Test', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
            ProfileId = p.Id, TimeZoneSidKey = 'America/New_York', UserName = 'training_context_user@test.com'
        );
        insert testUser;
    }
    
    @isTest
    static void testStoreAndGetLastQuery() {
        System.runAs(testUser) {
            // Arrange
            String currentUserName = UserInfo.getName();
            TrainingQueryRequest originalRequest = new TrainingQueryRequest();
            originalRequest.USER_QUERY = 'who completed compliance training';
            originalRequest.AGENT_ACTION = 'GET_TRAINING_PARTICIPANTS';
            Integer totalRecords = 150;
            
            // Act
            Test.startTest();
            TrainingSessionContext.storeLastQuery(currentUserName, originalRequest, totalRecords, 'GET_TRAINING_PARTICIPANTS');
            
            TrainingQueryRequest retrievedRequest = TrainingSessionContext.getLastQueryRequest(currentUserName);
            Integer retrievedTotal = TrainingSessionContext.getLastTotalRecords(currentUserName);
            String retrievedAction = TrainingSessionContext.getLastHandlerAction(currentUserName);
            Test.stopTest();
            
            // Assert
            System.assertNotEquals(null, retrievedRequest, 'Retrieved request should not be null.');
            System.assertEquals(originalRequest.USER_QUERY, retrievedRequest.USER_QUERY, 'User query should match.');
            System.assertEquals(totalRecords, retrievedTotal, 'Total records should match.');
            System.assertEquals('GET_TRAINING_PARTICIPANTS', retrievedAction, 'Handler action should match.');
        }
    }
    
    @isTest
    static void testClearLastQuery() {
        System.runAs(testUser) {
            // Arrange
            String currentUserName = UserInfo.getName();
            TrainingQueryRequest originalRequest = new TrainingQueryRequest();
            originalRequest.USER_QUERY = 'test query';
            
            TrainingSessionContext.storeLastQuery(currentUserName, originalRequest, 10, 'TEST_ACTION');
            
            // Act
            Test.startTest();
            TrainingSessionContext.clearLastQuery(currentUserName);
            Test.stopTest();
            
            // Assert
            System.assertEquals(null, TrainingSessionContext.getLastQueryRequest(currentUserName), 'Request should be null after clearing.');
            System.assertEquals(null, TrainingSessionContext.getLastTotalRecords(currentUserName), 'Total records should be null after clearing.');
            System.assertEquals(null, TrainingSessionContext.getLastHandlerAction(currentUserName), 'Action should be null after clearing.');
        }
    }

    @isTest
    static void testGetLastQuery_NoData() {
        System.runAs(testUser) {
            // Arrange
            String currentUserName = UserInfo.getName();
            
            // Act
            TrainingQueryRequest retrievedRequest = TrainingSessionContext.getLastQueryRequest(currentUserName);
            
            // Assert
            System.assertEquals(null, retrievedRequest, 'Should return null when no data is in the cache.');
        }
    }
}