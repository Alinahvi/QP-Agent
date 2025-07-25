@isTest
private class TrainingQueryInvocableTest {

    @TestSetup
    static void makeData() {
        // Create a user to run the test as.
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(
            Alias = 'testu', Email = 'testuser@example.com', EmailEncodingKey = 'UTF-8',
            LastName = 'Test', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
            ProfileId = p.Id, TimeZoneSidKey = 'America/New_York', UserName = 'training_invocable_user@test.com'
        );
        insert testUser;

        // Create a sample course for the metadata handler to find
        insert new Course__c(Name = 'Alpha Course', Status__c = 'Active');
    }

    @isTest
    static void testInvocable_SuccessFlow() {
        User u = [SELECT Id FROM User WHERE UserName LIKE 'training_invocable_user@test.com' LIMIT 1];
        System.runAs(u) {
            // Arrange
            List<String> userInputs = new List<String>{'what courses are available'};
            
            // Mock the HTTP callout that the deeper TrainingNluService makes.
            // We simulate the NLU identifying a metadata request.
            String fakeNluJson = '{"AGENT_ACTION":"GET_TRAINING_METADATA", "METADATA_REQUEST_TYPE":"AVAILABLE_COURSES"}';
            Test.setMock(HttpCalloutMock.class, new TrainingNluMock(200, fakeNluJson));

            // Act
            Test.startTest();
            List<String> responses = TrainingQueryInvocable.processQuery(userInputs);
            Test.stopTest();

            // Assert
            System.assertEquals(1, responses.size(), 'Should return one response string.');
            // This proves the entire flow worked, from the invocable action through the
            // service, factory, and finally to the (now fully implemented) TrainingMetadataQueryHandler.
            System.assert(responses[0].contains('Available courses include: Alpha Course.'), 'The response should come from the metadata handler.');
        }
    }
    
    // Mock for simulating the LLM API Callout
    private class TrainingNluMock implements HttpCalloutMock {
        protected Integer statusCode;
        protected String body;

        public TrainingNluMock(Integer code, String body) {
            this.statusCode = code;
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            String responseBody = '{"generations":[{"text":"' + this.body.escapeJava() + '"}]}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }
}