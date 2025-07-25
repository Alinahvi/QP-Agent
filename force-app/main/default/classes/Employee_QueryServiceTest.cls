@isTest
private class Employee_QueryServiceTest {

    private static User testUser;

    @TestSetup
    static void makeData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        testUser = new User(
            Alias = 'testu', Email = 'testuser@example.com', EmailEncodingKey = 'UTF-8',
            LastName = 'Test', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
            ProfileId = p.Id, TimeZoneSidKey = 'America/New_York', UserName = 'testuser' + System.currentTimeMillis() + '@testorg.com'
        );
        insert testUser;

        // Create a Learner Profile corresponding to the test user
        Learner_Profile__c profile = new Learner_Profile__c(
            Name = 'User, Test',
            User__c = testUser.Id,
            Manager__c = 'Boss, Test'
        );
        insert profile;
    }

    @isTest
    static void testProcessQuery_StandardFlow() {
        System.runAs(testUser) {
            // Arrange
            Employee_QueryRequest request = new Employee_QueryRequest();
            request.userInput = 'Show me engineers';
            request.sessionId = 'session1';
            
            // Mock the response from the LLM via the prompt service
            String llmJsonResponse = '{"Job_Family__c": "Engineer"}';
            HttpCalloutMock mock = new Employee_PromptMock(200, '{"generations":[{"text":"' + llmJsonResponse + '"}]}');
            Test.setMock(HttpCalloutMock.class, mock);

            // Act
            Test.startTest();
            Employee_QueryResult result = Employee_QueryService.processQuery(request);
            Test.stopTest();
            
            // Assert
            // We expect the stub handler to return a default result, but we can verify the service's work.
            System.assertEquals(llmJsonResponse, result.parsedQuery, 'The parsed query from the LLM should be stored in the result.');

            // Verify that the context was stored in the cache
            Map<String, Object> storedContext = Employee_SessionContext.getQueryContext(request.sessionId);
            System.assertNotEquals(null, storedContext, 'Query context should have been stored in the session.');
            System.assertEquals('Engineer', storedContext.get('Job_Family__c'), 'The parsed job family should be in the stored context.');
        }
    }
    
    @isTest
    static void testProcessQuery_HandlesException() {
         System.runAs(testUser) {
            // Arrange
            Employee_QueryRequest request = new Employee_QueryRequest();
            request.userInput = 'some query';

            // Mock an error response from the LLM
            HttpCalloutMock mock = new Employee_PromptMock(500, '{}');
            Test.setMock(HttpCalloutMock.class, mock);

            // Act
            Test.startTest();
            Employee_QueryResult result = Employee_QueryService.processQuery(request);
            Test.stopTest();
            
            // Assert
            System.assertEquals(false, result.success, 'Result success should be false on exception.');
            System.assert(result.message.contains('Error processing query'), 'Result message should indicate an error.');
        }
    }

    @isTest
    static void testResolveCurrentUser_MyTeam() {
        System.runAs(testUser) {
            // Arrange
            Map<String, Object> queryData = new Map<String, Object>{'DIRECT_REPORTS' => 'CURRENT_USER'};
            
            // Act: Call the method directly thanks to @TestVisible
            Map<String, Object> result = Employee_QueryService.resolveCurrentUser(queryData);
            
            // Assert
            System.assertEquals('User, Test', result.get('DIRECT_REPORTS'), 'CURRENT_USER should be resolved to the running user\'s name.');
        }
    }

    @isTest
    static void testResolveCurrentUser_MyBossTeam() {
        System.runAs(testUser) {
            // Arrange
            Map<String, Object> queryData = new Map<String, Object>{'HIERARCHICAL_QUERY' => 'CURRENT_USER_BOSS'};
            
            // Act: Call the method directly thanks to @TestVisible
            Map<String, Object> result = Employee_QueryService.resolveCurrentUser(queryData);
            
            // Assert
            System.assertEquals('Boss, Test', result.get('HIERARCHICAL_QUERY'), 'CURRENT_USER_BOSS should be resolved to the manager\'s name.');
        }
    }

    /**
    * @description INNER CLASS (SIMPLIFIED MOCK).
    * This mock class returns a hardcoded JSON string in the response body.
    */
    private class Employee_PromptMock implements HttpCalloutMock {
        protected Integer statusCode;
        protected String body;
        public Employee_PromptMock(Integer sc, String b) { this.statusCode = sc; this.body = b; }
        public HTTPResponse respond(HTTPRequest r) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(this.body);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }
}