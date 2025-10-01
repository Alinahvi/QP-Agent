public with sharing class MCPChatController {
    
    private static final String MCP_SERVER_ENDPOINT = 'callout:MCP_Server';
    
    @AuraEnabled
    public static InitializationResponse initializeChat(String recordId) {
        try {
            InitializationResponse response = new InitializationResponse();
            response.sessionId = String.valueOf(Crypto.getRandomInteger()) + '-' + String.valueOf(DateTime.now().getTime());
            return response;
        } catch (Exception e) {
            throw new AuraHandledException('Failed to initialize chat: ' + e.getMessage());
        }
    }
    
    // --- MODIFIED: Method signature changed to accept history ---
    @AuraEnabled
    public static ChatResponse sendMessage(String sessionId, String recordId, List<Map<String, Object>> history) {
        if (history == null || history.isEmpty()) {
            throw new AuraHandledException('Cannot send a message with no history.');
        }

        try {
            Map<String, Object> mcpContext = new Map<String, Object>{
                'sessionId' => sessionId,
                'userName' => UserInfo.getName(),
                'userEmail' => UserInfo.getUserEmail(),
                'userId' => UserInfo.getUserId(),
                'organizationId' => UserInfo.getOrganizationId()
            };
            
            if (String.isNotBlank(recordId)) {
                // Simplified getRecordBasicInfo for robustness
                mcpContext.put('currentRecordId', recordId);
            }
            
            // --- MODIFIED: Request body now sends the full history ---
            Map<String, Object> requestBody = new Map<String, Object>{
                'history' => history,
                'context' => mcpContext
            };
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(MCP_SERVER_ENDPOINT + '/chat');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000); 
            request.setBody(JSON.serialize(requestBody));
            
            HttpResponse httpResponse = new Http().send(request);
            
            if (httpResponse.getStatusCode() != 200) {
                throw new AuraHandledException('MCP server error: ' + httpResponse.getBody());
            }
            
            Map<String, Object> mcpResponse = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            
            ChatResponse response = new ChatResponse();
            if ((Boolean) mcpResponse.get('success')) {
                response.message = (String) mcpResponse.get('response');
            } else {
                response.message = 'Error: ' + mcpResponse.get('error');
            }
            
            return response;

        } catch (Exception e) {
            throw new AuraHandledException('Failed to send message: ' + e.getMessage());
        }
    }
    
    public class InitializationResponse {
        @AuraEnabled public String sessionId;
    }
    
    public class ChatResponse {
        @AuraEnabled public String message;
    }
}