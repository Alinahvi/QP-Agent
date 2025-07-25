@isTest
public class FRAgentAPMNominationServiceV2Test {
    
    @TestSetup
    static void setup() {
        // Create test user for email lookup
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'testuser',
            Email = 'test@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser@example.com.test'
        );
        insert testUser;
    }
    
    @isTest
    static void testCreateNominationSuccess() {
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new APMCalloutMock(200, 'Success'));
        
        Test.startTest();
        
        // Test data
        Map<String, Object> params = new Map<String, Object>{
            'OFFERING_NAME__c' => 'Test Course',
            'ENABLEMENTS_ID__c' => 'ENABLE-001',
            'PROGRAM_TYPE__c' => 'Training',
            'ENABLEMENT_TOOL__c' => 'Trailhead',
            'START_DATE__c' => Date.today(),
            'END_DATE__c' => Date.today().addDays(30),
            'NOTES__c' => 'Test nomination',
            'CREATED_USER__c' => 'Test User'
        };
        
        // Execute service
        Map<String, Object> result = FRAgentAPMNominationServiceV2.create(params);
        
        Test.stopTest();
        
        // Verify results
        System.assert((Boolean)result.get('success'), 'Should succeed');
        System.assert(result.get('message').toString().contains('created and API called'), 'Should indicate API was called');
        
        // Verify record was created
        apm_nomination_v2__c nom = (apm_nomination_v2__c)result.get('record');
        System.assertNotEquals(null, nom.Id, 'Record should have an ID');
        System.assertEquals('Test Course', nom.OFFERING_NAME__c, 'Offering name should match');
        System.assertEquals('Success', nom.APM_PROCESSED_STATUS__c, 'API status should be Success');
        System.assertEquals(40, nom.UNIQUE_LEARNERS__c, 'Unique learners should default to 40');
    }
    
    @isTest
    static void testCreateNominationAPIError() {
        // Set up mock callout that returns error
        Test.setMock(HttpCalloutMock.class, new APMCalloutMock(500, 'Internal Server Error'));
        
        Test.startTest();
        
        Map<String, Object> params = new Map<String, Object>{
            'OFFERING_NAME__c' => 'Test Course Error',
            'ENABLEMENTS_ID__c' => 'ENABLE-002',
            'PROGRAM_TYPE__c' => 'Training',
            'ENABLEMENT_TOOL__c' => 'Trailhead',
            'START_DATE__c' => Date.today(),
            'END_DATE__c' => Date.today().addDays(30),
            'CREATED_USER__c' => 'Test User'
        };
        
        Map<String, Object> result = FRAgentAPMNominationServiceV2.create(params);
        
        Test.stopTest();
        
        // Verify results
        System.assert((Boolean)result.get('success'), 'Should succeed even with API error');
        System.assert(result.get('message').toString().contains('created and API called'), 'Should indicate API was called');
        
        // Verify record was created but API status shows error
        apm_nomination_v2__c nom = (apm_nomination_v2__c)result.get('record');
        System.assertNotEquals(null, nom.Id, 'Record should have an ID');
        System.assert(nom.APM_PROCESSED_STATUS__c.contains('Error'), 'API status should show error');
    }
    
    @isTest
    static void testInvocableMethod() {
        Test.setMock(HttpCalloutMock.class, new APMCalloutMock(200, 'Success'));
        
        Test.startTest();
        
        FRAgentAPMNominationServiceV2.NominationInput input = new FRAgentAPMNominationServiceV2.NominationInput();
        input.offeringName = 'Invocable Test Course';
        input.enablementsId = 'ENABLE-003';
        input.programType = 'Training';
        input.enablementTool = 'Trailhead';
        input.startDate = Date.today();
        input.endDate = Date.today().addDays(30);
        input.notes = 'Invocable test';
        input.createdUser = 'Test User';
        
        List<FRAgentAPMNominationServiceV2.NominationInput> inputs = new List<FRAgentAPMNominationServiceV2.NominationInput>{input};
        List<FRAgentAPMNominationServiceV2.NominationOutput> results = FRAgentAPMNominationServiceV2.invocableCreateV2(inputs);
        
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assert(results[0].success, 'Should succeed');
        System.assert(results[0].message.contains('created and API called'), 'Should indicate API was called');
    }
    
    @isTest
    static void testHandlerMethod() {
        Test.setMock(HttpCalloutMock.class, new APMCalloutMock(200, 'Success'));
        
        Test.startTest();
        
        FRAgentAPMNominationHandlerV2.Request request = new FRAgentAPMNominationHandlerV2.Request();
        request.offeringName = 'Handler Test Course';
        request.enablementsId = 'ENABLE-004';
        request.programType = 'Training';
        request.enablementTool = 'Trailhead';
        request.startDate = Date.today();
        request.endDate = Date.today().addDays(30);
        request.notes = 'Handler test';
        request.createdUser = 'Test User';
        
        List<FRAgentAPMNominationHandlerV2.Request> requests = new List<FRAgentAPMNominationHandlerV2.Request>{request};
        List<FRAgentAPMNominationHandlerV2.Response> responses = FRAgentAPMNominationHandlerV2.createNominationV2(requests);
        
        Test.stopTest();
        
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assert(responses[0].success, 'Should succeed');
        System.assert(responses[0].message.contains('created and API called'), 'Should indicate API was called');
    }
    
    // Mock class for HTTP callouts
    public class APMCalloutMock implements HttpCalloutMock {
        private Integer statusCode;
        private String status;
        
        public APMCalloutMock(Integer statusCode, String status) {
            this.statusCode = statusCode;
            this.status = status;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody('{"status": "' + status + '"}');
            return res;
        }
    }
} 