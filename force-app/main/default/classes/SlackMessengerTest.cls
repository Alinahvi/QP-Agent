/**
 * Test class for SlackMessenger
 * Comprehensive test coverage for all scenarios
 */
@isTest
public class SlackMessengerTest {
    
    /**
     * Mock HTTP response for successful Slack API calls
     */
    public class MockHttpResponseSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"ok": true, "channel": "C09592Q0L1L", "ts": "1234567890.123456"}');
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
    
    /**
     * Mock HTTP response for Slack API errors
     */
    public class MockHttpResponseError implements HttpCalloutMock {
        private String errorType;
        
        public MockHttpResponseError(String errorType) {
            this.errorType = errorType;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"ok": false, "error": "' + errorType + '"}');
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
    
    /**
     * Mock HTTP response for HTTP errors
     */
    public class MockHttpResponseHttpError implements HttpCalloutMock {
        private Integer statusCode;
        
        public MockHttpResponseHttpError(Integer statusCode) {
            this.statusCode = statusCode;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody('{"error": "HTTP Error"}');
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
    
    /**
     * Test successful message sending
     */
    @isTest
    static void testSendSlackMessage_Success() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        
        SlackMessenger.SlackMessageInput input = new SlackMessenger.SlackMessageInput();
        input.channelId = 'C09592Q0L1L';
        input.messageText = 'Hello from Salesforce!';
        
        List<SlackMessenger.SlackMessageInput> inputs = new List<SlackMessenger.SlackMessageInput>{input};
        
        Test.startTest();
        List<SlackMessenger.SlackMessageOutput> outputs = SlackMessenger.sendSlackMessage(inputs);
        Test.stopTest();
        
        System.assertEquals(1, outputs.size(), 'Should have one output');
        SlackMessenger.SlackMessageOutput output = outputs[0];
        
        System.assertEquals(true, output.isSuccess, 'Should be successful');
        System.assert(output.message.contains('Message sent successfully'), 'Should contain success message');
        System.assertEquals('1234567890.123456', output.slackTimestamp, 'Should have timestamp');
        System.assertEquals('C09592Q0L1L', output.channel, 'Should have channel');
    }
    
    /**
     * Test successful message with thread timestamp
     */
    @isTest
    static void testSendSlackMessage_WithThread() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        
        SlackMessenger.SlackMessageInput input = new SlackMessenger.SlackMessageInput();
        input.channelId = 'C09592Q0L1L';
        input.messageText = 'Reply to thread';
        input.threadTimestamp = '1234567890.123456';
        
        List<SlackMessenger.SlackMessageInput> inputs = new List<SlackMessenger.SlackMessageInput>{input};
        
        Test.startTest();
        List<SlackMessenger.SlackMessageOutput> outputs = SlackMessenger.sendSlackMessage(inputs);
        Test.stopTest();
        
        System.assertEquals(1, outputs.size(), 'Should have one output');
        SlackMessenger.SlackMessageOutput output = outputs[0];
        
        System.assertEquals(true, output.isSuccess, 'Should be successful');
        System.assert(output.message.contains('Message sent successfully'), 'Should contain success message');
    }
    
    /**
     * Test missing channel ID
     */
    @isTest
    static void testSendSlackMessage_MissingChannelId() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        
        SlackMessenger.SlackMessageInput input = new SlackMessenger.SlackMessageInput();
        input.channelId = ''; // Empty channel ID
        input.messageText = 'Hello from Salesforce!';
        
        List<SlackMessenger.SlackMessageInput> inputs = new List<SlackMessenger.SlackMessageInput>{input};
        
        Test.startTest();
        List<SlackMessenger.SlackMessageOutput> outputs = SlackMessenger.sendSlackMessage(inputs);
        Test.stopTest();
        
        System.assertEquals(1, outputs.size(), 'Should have one output');
        SlackMessenger.SlackMessageOutput output = outputs[0];
        
        System.assertEquals(false, output.isSuccess, 'Should fail');
        System.assert(output.message.contains('Channel ID is required'), 'Should have validation error');
    }
    
    /**
     * Test missing message text
     */
    @isTest
    static void testSendSlackMessage_MissingMessage() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        
        SlackMessenger.SlackMessageInput input = new SlackMessenger.SlackMessageInput();
        input.channelId = 'C09592Q0L1L';
        input.messageText = ''; // Empty message
        
        List<SlackMessenger.SlackMessageInput> inputs = new List<SlackMessenger.SlackMessageInput>{input};
        
        Test.startTest();
        List<SlackMessenger.SlackMessageOutput> outputs = SlackMessenger.sendSlackMessage(inputs);
        Test.stopTest();
        
        System.assertEquals(1, outputs.size(), 'Should have one output');
        SlackMessenger.SlackMessageOutput output = outputs[0];
        
        System.assertEquals(false, output.isSuccess, 'Should fail');
        System.assert(output.message.contains('Message text is required'), 'Should have validation error');
    }
    
    /**
     * Test Slack API error
     */
    @isTest
    static void testSendSlackMessage_SlackApiError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseError('channel_not_found'));
        
        SlackMessenger.SlackMessageInput input = new SlackMessenger.SlackMessageInput();
        input.channelId = 'INVALID_CHANNEL';
        input.messageText = 'Hello from Salesforce!';
        
        List<SlackMessenger.SlackMessageInput> inputs = new List<SlackMessenger.SlackMessageInput>{input};
        
        Test.startTest();
        List<SlackMessenger.SlackMessageOutput> outputs = SlackMessenger.sendSlackMessage(inputs);
        Test.stopTest();
        
        System.assertEquals(1, outputs.size(), 'Should have one output');
        SlackMessenger.SlackMessageOutput output = outputs[0];
        
        System.assertEquals(false, output.isSuccess, 'Should fail');
        System.assert(output.message.contains('channel_not_found'), 'Should contain API error');
    }
    
    /**
     * Test HTTP error
     */
    @isTest
    static void testSendSlackMessage_HttpError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseHttpError(401));
        
        SlackMessenger.SlackMessageInput input = new SlackMessenger.SlackMessageInput();
        input.channelId = 'C09592Q0L1L';
        input.messageText = 'Hello from Salesforce!';
        
        List<SlackMessenger.SlackMessageInput> inputs = new List<SlackMessenger.SlackMessageInput>{input};
        
        Test.startTest();
        List<SlackMessenger.SlackMessageOutput> outputs = SlackMessenger.sendSlackMessage(inputs);
        Test.stopTest();
        
        System.assertEquals(1, outputs.size(), 'Should have one output');
        SlackMessenger.SlackMessageOutput output = outputs[0];
        
        System.assertEquals(false, output.isSuccess, 'Should fail');
        System.assert(output.message.contains('HTTP Error 401'), 'Should contain HTTP error');
    }
    
    /**
     * Test multiple inputs (bulk processing)
     */
    @isTest
    static void testSendSlackMessage_MultipleInputs() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        
        SlackMessenger.SlackMessageInput input1 = new SlackMessenger.SlackMessageInput();
        input1.channelId = 'C09592Q0L1L';
        input1.messageText = 'Message 1';
        
        SlackMessenger.SlackMessageInput input2 = new SlackMessenger.SlackMessageInput();
        input2.channelId = 'C09592Q0L1L';
        input2.messageText = 'Message 2';
        
        List<SlackMessenger.SlackMessageInput> inputs = new List<SlackMessenger.SlackMessageInput>{input1, input2};
        
        Test.startTest();
        List<SlackMessenger.SlackMessageOutput> outputs = SlackMessenger.sendSlackMessage(inputs);
        Test.stopTest();
        
        System.assertEquals(2, outputs.size(), 'Should have two outputs');
        
        for (SlackMessenger.SlackMessageOutput output : outputs) {
            System.assertEquals(true, output.isSuccess, 'Both should be successful');
            System.assert(output.message.contains('Message sent successfully'), 'Should contain success message');
        }
    }
    
    /**
     * Test bot token validation
     */
    @isTest
    static void testBotTokenValidation() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        
        Test.startTest();
        String result = SlackMessenger.testBotToken();
        Test.stopTest();
        
        System.assert(result.contains('Token test result'), 'Should contain test result');
    }
    
    /**
     * Test channel info retrieval
     */
    @isTest
    static void testGetChannelInfo() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        
        Test.startTest();
        String result = SlackMessenger.getChannelInfo('C09592Q0L1L');
        Test.stopTest();
        
        System.assert(result.contains('Channel info'), 'Should contain channel info');
    }
    
    /**
     * Test direct message to user
     */
    @isTest
    static void testSendDirectMessage() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        
        SlackMessenger.SlackMessageInput input = new SlackMessenger.SlackMessageInput();
        input.channelId = 'U1234567890'; // User ID format
        input.messageText = 'Direct message';
        
        List<SlackMessenger.SlackMessageInput> inputs = new List<SlackMessenger.SlackMessageInput>{input};
        
        Test.startTest();
        List<SlackMessenger.SlackMessageOutput> outputs = SlackMessenger.sendSlackMessage(inputs);
        Test.stopTest();
        
        System.assertEquals(1, outputs.size(), 'Should have one output');
        SlackMessenger.SlackMessageOutput output = outputs[0];
        
        System.assertEquals(true, output.isSuccess, 'Should be successful');
        System.assert(output.message.contains('Message sent successfully'), 'Should contain success message');
    }
    
    /**
     * Test special characters in message
     */
    @isTest
    static void testSpecialCharacters() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        
        SlackMessenger.SlackMessageInput input = new SlackMessenger.SlackMessageInput();
        input.channelId = 'C09592Q0L1L';
        input.messageText = 'Hello @channel! :wave: *Bold* _italic_ `code` https://example.com';
        
        List<SlackMessenger.SlackMessageInput> inputs = new List<SlackMessenger.SlackMessageInput>{input};
        
        Test.startTest();
        List<SlackMessenger.SlackMessageOutput> outputs = SlackMessenger.sendSlackMessage(inputs);
        Test.stopTest();
        
        System.assertEquals(1, outputs.size(), 'Should have one output');
        SlackMessenger.SlackMessageOutput output = outputs[0];
        
        System.assertEquals(true, output.isSuccess, 'Should be successful');
        System.assert(output.message.contains('Message sent successfully'), 'Should contain success message');
    }
}