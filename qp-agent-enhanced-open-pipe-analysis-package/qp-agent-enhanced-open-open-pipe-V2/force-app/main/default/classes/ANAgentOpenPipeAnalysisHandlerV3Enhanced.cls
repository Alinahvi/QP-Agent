/**
 * @description DUMB ROUTER - Open Pipe Analysis Handler V3 Enhanced
 * 
 * BEST PRACTICES COMPLIANCE:
 * - Single @InvocableMethod
 * - Single @InvocableVariable output: message (String)
 * - Zero business logic - all logic in service layer
 * - Clean input → service call → clean output
 * 
 * @author Salesforce
 * @date 2025-10-10
 */
public with sharing class ANAgentOpenPipeAnalysisHandlerV3Enhanced {
    
    /**
     * @description Request DTO - accepts query parameters as JSON string
     */
    public class Request {
        @InvocableVariable(
            label='Query Parameters JSON'
            description='JSON string containing all query parameters for open pipe analysis'
            required=true
        )
        public String queryParamsJson;
    }
    
    /**
     * @description Response DTO - single message variable for agent
     */
    public class Response {
        @InvocableVariable(
            label='Message'
            description='Complete analysis result formatted for agent consumption'
            required=true
        )
        public String message;
    }
    
    /**
     * @description Single invocable method - dumb router pattern
     * @param requests List of requests with query parameters
     * @return List of responses with formatted messages
     */
    @InvocableMethod(
        label='ANAGENT Open Pipe Analysis V3 Enhanced'
        description='Clean, JSON-focused open pipe analysis with agent-friendly output'
    )
    public static List<Response> analyzeOpenPipe(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        if (requests == null || requests.isEmpty()) {
            Response errRes = new Response();
            errRes.message = 'No request provided.';
            responses.add(errRes);
            return responses;
        }
        
        for (Request req : requests) {
            Response res = new Response();
            
            try {
                // Parse query parameters from JSON
                Map<String, Object> queryParams = new Map<String, Object>();
                if (String.isNotBlank(req.queryParamsJson)) {
                    queryParams = (Map<String, Object>) JSON.deserializeUntyped(req.queryParamsJson);
                }
                
                // Call service - all business logic lives here
                String serviceResult = ANAgentOpenPipeAnalysisServiceV3Enhanced.executeQuery(queryParams);
                
                // Add agent instruction for presentation
                res.message = 'AGENT INSTRUCTION: Present this data in a friendly, conversational format with appropriate emojis. Make the JSON data easy to read and engaging for the user.\n\n---\n\n' + serviceResult;
                
            } catch (Exception e) {
                res.message = 'Error: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'Handler Error: ' + e.getStackTraceString());
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}

