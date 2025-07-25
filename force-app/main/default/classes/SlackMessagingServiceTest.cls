@IsTest
public class SlackMessagingServiceTest {
    
    @IsTest
    static void testSendSlackMessage_Success() {
        // Create mock response
        Test.setMock(HttpCalloutMock.class, new SlackMockResponse(true, '1234567890.123456', null));
        
        // Prepare test data
        SlackMessagingService.SlackMessageRequest request = new SlackMessagingService.SlackMessageRequest();
        request.channel = 'C1234567890';
        request.text = 'Test message from AgentForce';
        request.username = 'TestBot';
        
        // Execute test
        Test.startTest();
        List<SlackMessagingService.SlackMessageResponse> responses = 
            SlackMessagingService.sendSlackMessage(new List<SlackMessagingService.SlackMessageRequest>{request});
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals(true, responses[0].ok, 'Response should be successful');
        System.assertEquals('1234567890.123456', responses[0].ts, 'Timestamp should match mock response');
        System.assertEquals('C1234567890', responses[0].channel, 'Channel should match mock response');
    }
    
    @IsTest
    static void testSendSlackMessage_WithThread() {
        // Create mock response
        Test.setMock(HttpCalloutMock.class, new SlackMockResponse(true, '1234567890.123457', null));
        
        // Prepare test data with thread
        SlackMessagingService.SlackMessageRequest request = new SlackMessagingService.SlackMessageRequest();
        request.channel = 'C1234567890';
        request.text = 'Reply message';
        request.thread_ts = '1234567890.123456';
        
        // Execute test
        Test.startTest();
        List<SlackMessagingService.SlackMessageResponse> responses = 
            SlackMessagingService.sendSlackMessage(new List<SlackMessagingService.SlackMessageRequest>{request});
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals(true, responses[0].ok, 'Response should be successful');
    }
    
    @IsTest
    static void testSendSlackMessage_MissingChannel() {
        // Prepare test data with missing channel
        SlackMessagingService.SlackMessageRequest request = new SlackMessagingService.SlackMessageRequest();
        request.text = 'Test message';
        // Note: channel is intentionally left null
        
        // Execute test
        Test.startTest();
        List<SlackMessagingService.SlackMessageResponse> responses = 
            SlackMessagingService.sendSlackMessage(new List<SlackMessagingService.SlackMessageRequest>{request});
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals(false, responses[0].ok, 'Response should indicate failure');
        System.assert(responses[0].error.contains('Missing required fields'), 'Error should mention missing fields');
    }
    
    @IsTest
    static void testSendSlackMessage_MissingText() {
        // Prepare test data with missing text
        SlackMessagingService.SlackMessageRequest request = new SlackMessagingService.SlackMessageRequest();
        request.channel = 'C1234567890';
        // Note: text is intentionally left null
        
        // Execute test
        Test.startTest();
        List<SlackMessagingService.SlackMessageResponse> responses = 
            SlackMessagingService.sendSlackMessage(new List<SlackMessagingService.SlackMessageRequest>{request});
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals(false, responses[0].ok, 'Response should indicate failure');
        System.assert(responses[0].error.contains('Missing required fields'), 'Error should mention missing fields');
    }
    
    @IsTest
    static void testSendSlackMessage_SlackError() {
        // Create mock response with Slack error
        Test.setMock(HttpCalloutMock.class, new SlackMockResponse(false, null, 'channel_not_found'));
        
        // Prepare test data
        SlackMessagingService.SlackMessageRequest request = new SlackMessagingService.SlackMessageRequest();
        request.channel = 'invalid_channel';
        request.text = 'Test message';
        
        // Execute test
        Test.startTest();
        List<SlackMessagingService.SlackMessageResponse> responses = 
            SlackMessagingService.sendSlackMessage(new List<SlackMessagingService.SlackMessageRequest>{request});
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals(false, responses[0].ok, 'Response should indicate failure');
        System.assertEquals('channel_not_found', responses[0].error, 'Error should match Slack error');
    }
    
    @IsTest
    static void testSendMessage_DirectCall() {
        // Test the static sendMessage method directly
        Test.setMock(HttpCalloutMock.class, new SlackMockResponse(true, '1234567890.123456', null));
        
        // Prepare test data
        SlackMessagingService.SlackMessageRequest request = new SlackMessagingService.SlackMessageRequest();
        request.channel = 'C1234567890';
        request.text = 'Direct call test';
        
        // Execute test
        Test.startTest();
        SlackMessagingService.SlackMessageResponse response = SlackMessagingService.sendMessage(request);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(true, response.ok, 'Response should be successful');
        System.assertEquals('1234567890.123456', response.ts, 'Timestamp should match mock response');
    }
    
    @IsTest
    static void testSendSlackMessage_MultipleRequests() {
        // Create mock response
        Test.setMock(HttpCalloutMock.class, new SlackMockResponse(true, '1234567890.123456', null));
        
        // Prepare multiple test requests
        List<SlackMessagingService.SlackMessageRequest> requests = new List<SlackMessagingService.SlackMessageRequest>();
        
        SlackMessagingService.SlackMessageRequest request1 = new SlackMessagingService.SlackMessageRequest();
        request1.channel = 'C1234567890';
        request1.text = 'First message';
        requests.add(request1);
        
        SlackMessagingService.SlackMessageRequest request2 = new SlackMessagingService.SlackMessageRequest();
        request2.channel = 'C0987654321';
        request2.text = 'Second message';
        requests.add(request2);
        
        // Execute test
        Test.startTest();
        List<SlackMessagingService.SlackMessageResponse> responses = 
            SlackMessagingService.sendSlackMessage(requests);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(2, responses.size(), 'Should return two responses');
        System.assertEquals(true, responses[0].ok, 'First response should be successful');
        System.assertEquals(true, responses[1].ok, 'Second response should be successful');
    }
    
    // Mock HTTP response class
    public class SlackMockResponse implements HttpCalloutMock {
        private Boolean success;
        private String timestamp;
        private String errorMsg;
        
        public SlackMockResponse(Boolean success, String timestamp, String errorMsg) {
            this.success = success;
            this.timestamp = timestamp;
            this.errorMsg = errorMsg;
        }
        
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            
            Map<String, Object> body = new Map<String, Object>();
            body.put('ok', success);
            
            if (success) {
                body.put('ts', timestamp);
                body.put('channel', 'C1234567890');
            } else {
                body.put('error', errorMsg);
            }
            
            response.setBody(JSON.serialize(body));
            return response;
        }
    }
}