/**
 * @description MCP Adapter for Open Pipe Analysis V3
 * Routes MCP requests to existing ANAGENT_Open_Pipe_Analysis_V3_2
 * @version 1.0
 */
public with sharing class AN_OpenPipeV3_FromMCP {
    
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
        label='Run Open Pipe Analysis V3 from MCP'
        description='Routes MCP requests to ANAGENT_Open_Pipe_Analysis_V3_2'
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
                String ouName = (String) args.get('ouName');
                String product = (String) args.get('product');
                String stage = (String) args.get('stage');
                String country = (String) args.get('country');
                String limitStr = (String) args.get('limit');
                String timeFrame = (String) args.get('timeFrame');
                String includeProducts = (String) args.get('includeProducts');
                String excludeProducts = (String) args.get('excludeProducts');
                Boolean negativeIntent = (Boolean) args.get('negativeIntent');
                
                // Map MCP parameters to handler request
                ANAgentOpenPipeAnalysisV3Handler.Request handlerRequest = 
                    new ANAgentOpenPipeAnalysisV3Handler.Request();
                
                // Set required parameters
                if (String.isNotBlank(ouName)) {
                    handlerRequest.ouName = ouName;
                }
                if (String.isNotBlank(product)) {
                    handlerRequest.filterCriteria = 'open_pipe_prod_nm__c = \'' + String.escapeSingleQuotes(product) + '\'';
                }
                if (String.isNotBlank(stage)) {
                    String stageFilter = 'open_pipe_opty_stg_nm__c = \'' + String.escapeSingleQuotes(stage) + '\'';
                    if (String.isNotBlank(handlerRequest.filterCriteria)) {
                        handlerRequest.filterCriteria += ' AND ' + stageFilter;
                    } else {
                        handlerRequest.filterCriteria = stageFilter;
                    }
                }
                if (String.isNotBlank(country)) {
                    handlerRequest.workLocationCountry = country;
                }
                if (String.isNotBlank(limitStr)) {
                    handlerRequest.limitN = Integer.valueOf(limitStr);
                }
                if (String.isNotBlank(includeProducts)) {
                    handlerRequest.includeProductListCsv = includeProducts;
                }
                if (String.isNotBlank(excludeProducts)) {
                    handlerRequest.excludeProductListCsv = excludeProducts;
                }
                if (negativeIntent != null) {
                    handlerRequest.negativeIntent = negativeIntent;
                }
                
                // Set default values for required fields
                if (String.isBlank(handlerRequest.groupBy)) {
                    handlerRequest.groupBy = 'AE';
                }
                if (String.isBlank(handlerRequest.analysisType)) {
                    handlerRequest.analysisType = 'AE_SCORE_ANALYSIS';
                }
                if (String.isBlank(handlerRequest.aggregationType)) {
                    handlerRequest.aggregationType = 'COUNT';
                }
                handlerRequest.perAENormalize = true;
                
                // Call the actual handler
                List<ANAgentOpenPipeAnalysisV3Handler.Response> handlerResponses = 
                    ANAgentOpenPipeAnalysisV3Handler.analyzeOpenPipe(
                        new List<ANAgentOpenPipeAnalysisV3Handler.Request>{handlerRequest}
                    );
                
                Long endTime = System.currentTimeMillis();
                result.executionTimeMs = endTime - startTime;
                
                if (!handlerResponses.isEmpty()) {
                    ANAgentOpenPipeAnalysisV3Handler.Response handlerResponse = handlerResponses[0];
                    
                    Map<String, Object> response = new Map<String, Object>{
                        'tool' => 'open_pipe_analyze',
                        'args' => args,
                        'success' => true,
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
                    result.message = 'Handler call failed - no response received';
                }
                
            } catch (Exception e) {
                Long endTime = System.currentTimeMillis();
                result.executionTimeMs = endTime - startTime;
                result.success = false;
                result.message = 'Error in Open Pipe Analysis: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'Open Pipe MCP Adapter Error: ' + e.getStackTraceString());
            }
            
            results.add(result);
        }
        
        return results;
    }
}