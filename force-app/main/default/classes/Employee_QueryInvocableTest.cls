@isTest
private class Employee_QueryInvocableTest {

    private static User testUser;
    private static List<Learner_Profile__c> testProfiles;

    @TestSetup
    static void makeData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        testUser = new User(
            Alias = 'testu', Email = 'testuser@example.com', EmailEncodingKey = 'UTF-8',
            LastName = 'Test', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
            ProfileId = p.Id, TimeZoneSidKey = 'America/New_York', UserName = 'testuser' + System.currentTimeMillis() + '@testorg.com'
        );
        insert testUser;

        // Create test records for the queueable to query
        testProfiles = new List<Learner_Profile__c>();
        for(Integer i=0; i < 5; i++){
            testProfiles.add(new Learner_Profile__c(Name = 'Test Employee ' + i));
        }
        insert testProfiles;
    }

    @isTest
    static void testStandardQueryFlow_Success() {
        System.runAs(testUser) {
            // Arrange
            // THIS IS THE CORRECTED SYNTAX
            Employee_QueryRequest request = new Employee_QueryRequest();
            request.userInput = 'Find engineers in AMER';
            request.sessionId = 'session1';
            
            List<Employee_QueryRequest> requests = new List<Employee_QueryRequest>{ request };
            
            String llmJsonResponse = '{"Job_Family__c": "Engineer", "Division__c": "AMER"}';
            HttpCalloutMock mock = new Employee_PromptMock(200, '{"generations":[{"text":"' + llmJsonResponse + '"}]}');
            Test.setMock(HttpCalloutMock.class, mock);

            // Act
            Test.startTest();
            List<String> results = Employee_QueryInvocable.queryEmployees(requests);
            Test.stopTest();

            // Assert
            System.assertEquals(1, results.size(), 'Should return one result string.');
            Employee_QueryResult result = (Employee_QueryResult) JSON.deserialize(results[0], Employee_QueryResult.class);
            System.assertEquals(true, result.success, 'The success flag should be true for a valid query.');
        }
    }

    @isTest
    static void testQueueable_ProcessesAndCachesData() {
        System.runAs(testUser) {
            // Arrange
            String sessionId = 'session-q-123';
            // The base query must not have LIMIT or OFFSET
            String baseQuery = 'SELECT Id, Name FROM Learner_Profile__c';
            // Simulate that the total records are more than the test data, to test chaining.
            // We start at offset 0 for this direct test.
            Employee_QueryInvocable.LargeQueryProcessor processor = new Employee_QueryInvocable.LargeQueryProcessor(sessionId, baseQuery + ' ORDER BY Name LIMIT 20 OFFSET 0', 10, 0);

            // Act
            Test.startTest();
            System.enqueueJob(processor);
            Test.stopTest();

            // Assert
            // The job will have run and processed the 5 records we created.
            List<Id> cachedIds = Employee_SessionContext.getSegmentedEmployeeIds(sessionId);
            System.assertEquals(5, cachedIds.size(), 'Queueable should have queried and cached the 5 test records.');
            
            // Because totalRecords (10) > records found (5), a second job should be chained.
            System.assertEquals(2, [SELECT COUNT() FROM AsyncApexJob], 'The initial job plus one chained job should have been enqueued.');
        }
    }
    
    /** INNER CLASS MOCK */
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