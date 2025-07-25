@isTest
private class TrainingQueryServiceTest {

    private static User testUser;
    
    @TestSetup
    static void makeData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        testUser = new User(
            Alias = 'testu', Email = 'testuser@example.com', EmailEncodingKey = 'UTF-8',
            LastName = 'Test', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
            ProfileId = p.Id, TimeZoneSidKey = 'America/New_York', UserName = 'training_service_user@test.com'
        );
        insert testUser;
    }

    @isTest
    static void testHierarchyFallbackLogic() {
        System.runAs(testUser) {
            // Arrange
            TrainingQueryService service = new TrainingQueryService();
            String userName = UserInfo.getName();
            String rawInput = 'show me my team\'s completions';
            
            TrainingQueryRequest nluRequest = new TrainingQueryRequest();
            nluRequest.HIERARCHY_CONTEXT = new TrainingQueryRequest.HierarchyContext();
            nluRequest.HIERARCHY_CONTEXT.ANCHOR_NAME = 'Placeholder'; // NLU missed the user context

            // Act
            TrainingQueryRequest resultRequest = service.applyContextualFallbacks(nluRequest, userName, rawInput);
            
            // Assert
            System.assertEquals(userName, resultRequest.HIERARCHY_CONTEXT.ANCHOR_NAME, 'Anchor name should be updated to the current user.');
        }
    }

    @isTest
    static void testEffectiveActionRouting() {
        System.runAs(testUser) {
            // Arrange
            TrainingQueryService service = new TrainingQueryService();
            TrainingQueryRequest request = new TrainingQueryRequest();
            request.AGENT_ACTION = 'GET_TRAINING_PARTICIPANTS';
            request.HIERARCHY_CONTEXT = new TrainingQueryRequest.HierarchyContext();
            
            // Act
            String effectiveAction = service.getEffectiveAgentAction(request);
            
            // Assert
            System.assertEquals('GET_HIERARCHICAL_TRAINING_COMPLETION', effectiveAction, 'Action should be promoted to the hierarchical version.');
        }
    }
}