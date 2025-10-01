/**
 * @description MCP Adapter for Content Search
 * Routes MCP requests to existing ANAgentConsensusContentSearchHandler
 * @version 1.0
 */
public with sharing class AN_SearchContent_FromMCP {
    
    public class Result {
        @InvocableVariable(label='Success' description='Whether the operation was successful')
        public Boolean success;
        
        @InvocableVariable(label='Message' description='Response message or error details')
        public String message;
        
        @InvocableVariable(label='Response JSON' description='Response data as JSON string')
        public String responseJson;
        
        @InvocableVariable(label='Correlation ID' description='Correlation ID for tracking')
        public String correlationId;
        
        @InvocableVariable(label='Execution Time (ms)' description='Handler execution time in milliseconds')
        public Long executionTimeMs;
        
        public Result() {
            this.success = false;
            this.message = '';
            this.responseJson = '';
            this.correlationId = '';
            this.executionTimeMs = 0;
        }
    }
    
    @InvocableMethod(
        label='Run Content Search from MCP'
        description='Routes MCP requests to ANAgentConsensusContentSearchHandler'
        category='ANAgent'
    )
    public static List<Result> run(List<String> normalizedArgsJsons) {
        List<Result> results = new List<Result>();
        
        for (String argsJson : normalizedArgsJsons) {
            Result result = new Result();
            Long startTime = System.currentTimeMillis();
            
            try {
                Map<String, Object> args = (Map<String, Object>) JSON.deserializeUntyped(argsJson);
                
                // Extract correlation ID if present
                String correlationId = (String) args.get('correlationId');
                if (String.isNotBlank(correlationId)) {
                    result.correlationId = correlationId;
                }
                
                // Extract parameters from MCP args
                String topicParam = (String) args.get('topic');
                String sourceParam = (String) args.get('source');
                String dateRangeParam = (String) args.get('dateRange');
                String limitParam = (String) args.get('limit');
                
                // Map MCP parameters to handler request
                ANAgentConsensusContentSearchHandler.ContentSearchRequest handlerRequest = 
                    new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
                
                // Set parameters
                if (String.isNotBlank(topicParam)) {
                    handlerRequest.topic = topicParam;
                }
                if (String.isNotBlank(sourceParam)) {
                    handlerRequest.source = sourceParam;
                }
                if (String.isNotBlank(dateRangeParam)) {
                    handlerRequest.dateRange = dateRangeParam;
                }
                if (String.isNotBlank(limitParam)) {
                    handlerRequest.limit = Integer.valueOf(limitParam);
                }
                
                // Call the actual handler
                List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> handlerResponses = 
                    ANAgentConsensusContentSearchHandler.searchContent(
                        new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{handlerRequest}
                    );
                
                Long endTime = System.currentTimeMillis();
                result.executionTimeMs = endTime - startTime;
                
                if (!handlerResponses.isEmpty() && handlerResponses[0].success) {
                    ANAgentConsensusContentSearchHandler.ContentSearchResponse handlerResponse = handlerResponses[0];
                    
                    Map<String, Object> response = new Map<String, Object>{
                        'tool' => 'content_search',
                        'args' => args,
                        'success' => handlerResponse.success,
                        'totalResults' => handlerResponse.totalResults,
                        'contentItems' => handlerResponse.contentItems,
                        'message' => handlerResponse.message,
                        'timestamp' => DateTime.now().format(),
                        'status' => 'SUCCESS',
                        'correlationId' => result.correlationId,
                        'executionTimeMs' => result.executionTimeMs
                    };
                    
                    result.success = true;
                    result.message = handlerResponse.message;
                    result.responseJson = JSON.serialize(response);
                } else {
                    result.success = false;
                    result.message = !handlerResponses.isEmpty() ? handlerResponses[0].message : 'Handler call failed';
                }
                
            } catch (Exception e) {
                Long endTime = System.currentTimeMillis();
                result.executionTimeMs = endTime - startTime;
                result.success = false;
                result.message = 'Error in Content Search: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'Content Search MCP Adapter Error: ' + e.getStackTraceString());
            }
            
            results.add(result);
        }
        
        return results;
    }
}