/**
 * @description MCP Adapter for SME Search
 * Routes MCP requests to existing ANAgentSMESearchHandler
 * @version 1.0
 */
public with sharing class AN_SearchSME_FromMCP {
    
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
        label='Run SME Search from MCP'
        description='Routes MCP requests to ANAgentSMESearchHandler'
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
                
                // Extract parameters from MCP args with enhanced schema
                String searchTerm = (String) args.get('searchTerm');
                String searchType = (String) args.get('searchType');
                String ouName = (String) args.get('ouName');
                String workLocationCountry = (String) args.get('workLocationCountry');
                String productLevel = (String) args.get('productLevel');
                Boolean academyOnly = (Boolean) args.get('academyOnly');
                Boolean requireSameOU = (Boolean) args.get('requireSameOU');
                Boolean includeStale = (Boolean) args.get('includeStale');
                Integer limitN = (Integer) args.get('limitN');
                
                // Map MCP parameters to handler request
                ANAgentSMESearchHandler.SMESearchRequest handlerRequest = 
                    new ANAgentSMESearchHandler.SMESearchRequest();
                
                // Set parameters with enhanced mapping
                handlerRequest.searchTerm = String.isNotBlank(searchTerm) ? searchTerm : '';
                handlerRequest.searchType = String.isNotBlank(searchType) ? searchType : 'PRODUCT';
                handlerRequest.ouName = ouName;
                handlerRequest.workLocationCountry = workLocationCountry;
                handlerRequest.productLevel = String.isNotBlank(productLevel) ? productLevel : 'ANY';
                handlerRequest.academyOnly = academyOnly != null ? academyOnly : false;
                handlerRequest.requireSameOU = requireSameOU != null ? requireSameOU : true;
                handlerRequest.includeStale = includeStale != null ? includeStale : false;
                handlerRequest.limitN = limitN != null ? limitN : 25;
                
                // Call the actual handler
                List<ANAgentSMESearchHandler.SMESearchResponse> handlerResponses = 
                    ANAgentSMESearchHandler.searchSMEs(
                        new List<ANAgentSMESearchHandler.SMESearchRequest>{handlerRequest}
                    );
                
                Long endTime = System.currentTimeMillis();
                result.executionTimeMs = endTime - startTime;
                
                if (!handlerResponses.isEmpty() && handlerResponses[0].success) {
                    ANAgentSMESearchHandler.SMESearchResponse handlerResponse = handlerResponses[0];
                    
                    Map<String, Object> response = new Map<String, Object>{
                        'tool' => 'search_sme',
                        'args' => args,
                        'success' => handlerResponse.success,
                        'totalCount' => handlerResponse.totalCount,
                        'results' => handlerResponse.results,
                        'searchTerm' => handlerResponse.searchTerm,
                        'searchType' => handlerResponse.searchType,
                        'ouName' => handlerResponse.ouName,
                        'country' => handlerResponse.country,
                        'academyOnly' => handlerResponse.academyOnly,
                        'requireSameOU' => handlerResponse.requireSameOU,
                        'rankingExplanation' => handlerResponse.rankingExplanation,
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
                result.message = 'Error in SME Search: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'SME Search MCP Adapter Error: ' + e.getStackTraceString());
            }
            
            results.add(result);
        }
        
        return results;
    }
}