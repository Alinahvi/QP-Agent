/**
 * Agent Interaction Logger
 * 
 * This class provides logging functionality for agent interactions.
 * It logs agent requests, responses, and session information for tracking and analysis.
 */
public with sharing class AgentInteractionLogger {
    
    /**
     * Log input structure for agent interactions
     */
    public class LogInput {
        public String sessionId;
        public String userId;
        public Integer turnNumber;
        public DateTime interactionTimestamp;
        public String detectedIntent;
        public Object actionParameters;
        public String responseMessage;
        public Map<String, Object> structuredResponse;
        public String responseStatus;
        public String queryTemplate;
    }
    
    /**
     * Logs agent interactions to the Agent_Conversation_Log__c object
     */
    public static void log(List<LogInput> logInputs) {
        try {
            List<Agent_Conversation_Log__c> conversationLogs = new List<Agent_Conversation_Log__c>();
            
            for (LogInput input : logInputs) {
                Agent_Conversation_Log__c conversationLog = new Agent_Conversation_Log__c();
                conversationLog.Session_Id__c = input.sessionId;
                conversationLog.User_Id__c = input.userId;
                conversationLog.Turn_Number__c = input.turnNumber;
                conversationLog.Interaction_Timestamp__c = input.interactionTimestamp;
                conversationLog.Detected_Intent__c = input.detectedIntent;
                conversationLog.Action_Parameters__c = input.actionParameters != null ? String.valueOf(input.actionParameters) : null;
                conversationLog.Response_Message__c = input.responseMessage;
                conversationLog.Structured_Response__c = input.structuredResponse != null ? JSON.serialize(input.structuredResponse) : null;
                conversationLog.Response_Status__c = input.responseStatus;
                conversationLog.Query_Template__c = input.queryTemplate;
                
                conversationLogs.add(conversationLog);
            }
            
            if (!conversationLogs.isEmpty()) {
                insert conversationLogs;
            }
            
        } catch (Exception e) {
            System.debug('Error logging agent interaction: ' + e.getMessage());
            // Fail silently to not break agent flow
        }
    }
}