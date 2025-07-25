public with sharing class AIController {
    
    @AuraEnabled
    public static Map<String, Object> sendMessage(String message, String recordId, String objectType) {
        System.debug('=== sendMessage called ===');
        System.debug('Message: ' + message);
        System.debug('RecordId: ' + recordId);
        System.debug('ObjectType: ' + objectType);
        
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Get user context
            User currentUser = [
                SELECT Id, Name, Email, Profile.Name 
                FROM User 
                WHERE Id = :UserInfo.getUserId() 
                LIMIT 1
            ];
            
            // Build context
            Map<String, Object> context = new Map<String, Object>{
                'userId' => currentUser.Id,
                'userName' => currentUser.Name,
                'userEmail' => currentUser.Email,
                'userProfile' => currentUser.Profile.Name,
                'orgId' => UserInfo.getOrganizationId(),
                'timestamp' => System.now().format()
            };
            
            // Make callout to MCP Server
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:MCP_Server/chat');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(30000);
            
            Map<String, Object> payload = new Map<String, Object>{
                'message' => message,
                'context' => context,
                'timestamp' => System.now().getTime()
            };
            
            req.setBody(JSON.serialize(payload));
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseData = 
                    (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                
                result.put('success', true);
                result.put('response', (String) responseData.get('response'));
                result.put('error', null);
            } else {
                result.put('success', false);
                result.put('response', null);
                result.put('error', 'Server returned status: ' + res.getStatusCode());
            }
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('response', null);
            result.put('error', e.getMessage());
        }
        
        return result;
    }
    
    @AuraEnabled
    public static String testConnection() {
        System.debug('Test connection called');
        String result = 'Connection successful at ' + System.now().format();
        System.debug('Returning: ' + result);
        return result;
    }
}