public class SlackMessenger {
    
    // Constants
    private static final String SLACK_API_URL = 'https://slack.com/api/chat.postMessage';
    private static final String BOT_TOKEN = 'xoxb-4909201991235-9180995054709-6h79WjhfS2Ziuy0eRNlFrlqs';
    
    /**
     * Input wrapper class for Agentforce
     */
    public class SlackMessageInput {
        @InvocableVariable(required=true label='Channel ID' description='Slack channel ID (starts with C) or user ID (starts with U)')
        public String channelId;
        
        @InvocableVariable(required=true label='Message Text' description='The message content to send')
        public String messageText;
        
        @InvocableVariable(required=false label='Thread Timestamp' description='Optional: Reply to thread (timestamp)')
        public String threadTimestamp;
    }
    
    /**
     * Output wrapper class for Agentforce
     */
    public class SlackMessageOutput {
        @InvocableVariable(label='Success' description='True if message was sent successfully')
        public Boolean isSuccess;
        
        @InvocableVariable(label='Message' description='Success confirmation or error message')
        public String message;
        
        @InvocableVariable(label='Slack Timestamp' description='Timestamp of the sent message')
        public String slackTimestamp;
        
        @InvocableVariable(label='Channel' description='Channel where message was sent')
        public String channel;
    }
    
    /**
     * Main invocable method for Agentforce
     * Sends messages to Slack channels or users
     */
    @InvocableMethod(label='Send Slack Message' description='Posts a message to a Slack channel or user')
    public static List<SlackMessageOutput> sendSlackMessage(List<SlackMessageInput> inputs) {
        List<SlackMessageOutput> outputs = new List<SlackMessageOutput>();
        
        for (SlackMessageInput input : inputs) {
            SlackMessageOutput output = new SlackMessageOutput();
            
            try {
                // Validate inputs
                if (String.isBlank(input.channelId)) {
                    throw new SlackException('Channel ID is required');
                }
                if (String.isBlank(input.messageText)) {
                    throw new SlackException('Message text is required');
                }
                
                // Send message
                SlackApiResponse response = sendMessageToSlack(input.channelId, input.messageText, input.threadTimestamp);
                
                // Set success output
                output.isSuccess = true;
                output.message = 'Message sent successfully to ' + input.channelId;
                output.slackTimestamp = response.timestamp;
                output.channel = response.channel;
                
                System.debug('SUCCESS: Message sent to ' + input.channelId);
                
            } catch (Exception e) {
                // Set error output
                output.isSuccess = false;
                output.message = 'Failed to send message: ' + e.getMessage();
                output.slackTimestamp = null;
                output.channel = input.channelId;
                
                System.debug('ERROR: ' + e.getMessage());
                System.debug('Stack trace: ' + e.getStackTraceString());
            }
            
            outputs.add(output);
        }
        
        return outputs;
    }
    
    /**
     * Internal method to make HTTP callout to Slack API
     */
    private static SlackApiResponse sendMessageToSlack(String channelId, String messageText, String threadTimestamp) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Set endpoint
        request.setEndpoint(SLACK_API_URL);
        request.setMethod('POST');
        request.setTimeout(60000); // 60 second timeout
        
        // Set headers
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + BOT_TOKEN);
        
        // Build request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'channel' => channelId,
            'text' => messageText
        };
        
        // Add thread timestamp if provided
        if (String.isNotBlank(threadTimestamp)) {
            requestBody.put('thread_ts', threadTimestamp);
        }
        
        request.setBody(JSON.serialize(requestBody));
        
        System.debug('Sending request to Slack API...');
        System.debug('Channel: ' + channelId);
        System.debug('Message: ' + messageText);
        
        // Make the callout
        HttpResponse response = http.send(request);
        
        System.debug('Response Status Code: ' + response.getStatusCode());
        System.debug('Response Body: ' + response.getBody());
        
        // Parse response
        return parseSlackResponse(response);
    }
    
    /**
     * Parse Slack API response and handle errors
     */
    private static SlackApiResponse parseSlackResponse(HttpResponse response) {
        SlackApiResponse result = new SlackApiResponse();
        
        // Check HTTP status
        if (response.getStatusCode() != 200) {
            throw new SlackException('HTTP Error ' + response.getStatusCode() + ': ' + response.getBody());
        }
        
        // Parse JSON response
        try {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Boolean ok = (Boolean) responseMap.get('ok');
            
            if (ok == true) {
                // Success
                result.success = true;
                result.timestamp = (String) responseMap.get('ts');
                result.channel = (String) responseMap.get('channel');
                result.errorMessage = null;
            } else {
                // Slack API error
                String error = (String) responseMap.get('error');
                result.success = false;
                result.errorMessage = 'Slack API Error: ' + error;
                throw new SlackException(result.errorMessage);
            }
            
        } catch (JSONException e) {
            throw new SlackException('Invalid JSON response from Slack API: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * Wrapper class for Slack API response
     */
    private class SlackApiResponse {
        public Boolean success;
        public String timestamp;
        public String channel;
        public String errorMessage;
    }
    
    /**
     * Custom exception for Slack-related errors
     */
    public class SlackException extends Exception {}
    
    /**
     * Utility method to test bot token (for debugging)
     */
    public static String testBotToken() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint('https://slack.com/api/auth.test');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + BOT_TOKEN);
        
        try {
            HttpResponse response = http.send(request);
            return 'Token test result: ' + response.getBody();
        } catch (Exception e) {
            return 'Token test failed: ' + e.getMessage();
        }
    }
    
    /**
     * Utility method to get channel info (for debugging)
     */
    public static String getChannelInfo(String channelId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint('https://slack.com/api/conversations.info?channel=' + channelId);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + BOT_TOKEN);
        
        try {
            HttpResponse response = http.send(request);
            return 'Channel info: ' + response.getBody();
        } catch (Exception e) {
            return 'Channel info failed: ' + e.getMessage();
        }
    }
}