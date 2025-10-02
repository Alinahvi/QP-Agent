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
            List<Agent_Conversation_Log__c> logs = new List<Agent_Conversation_Log__c>();
            
            for (LogInput input : logInputs) {
                Agent_Conversation_Log__c log = new Agent_Conversation_Log__c();
                log.Session_Id__c = input.sessionId;
                log.User_Id__c = input.userId;
                log.Turn_Number__c = input.turnNumber;
                log.Interaction_Timestamp__c = input.interactionTimestamp;
                log.Detected_Intent__c = input.detectedIntent;
                log.Action_Parameters__c = input.actionParameters != null ? String.valueOf(input.actionParameters) : null;
                log.Response_Message__c = input.responseMessage;
                log.Structured_Response__c = input.structuredResponse != null ? JSON.serialize(input.structuredResponse) : null;
                log.Response_Status__c = input.responseStatus;
                log.Query_Template__c = input.queryTemplate;
                
                logs.add(log);
            }
            
            if (!logs.isEmpty()) {
                insert logs;
            }
            
        } catch (Exception e) {
            System.debug('Error logging agent interaction: ' + e.getMessage());
            // Fail silently to not break agent flow
        }
    }
}
