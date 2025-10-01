/**
 * @description MCP Adapter for Future Pipeline Analysis
 * Routes MCP requests to ABAgentFuturePipeAnalysisHandler with enhanced intelligence capabilities
 * @version 2.0 - Fixed to use correct handler
 */
public with sharing class AN_FuturePipeline_FromMCP {
    
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
        label='Run Future Pipeline Analysis from MCP'
        description='Routes MCP requests to ANAgentFuturePipelineAnalysisHandler'
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
                String opportunityType = (String) args.get('opportunityType');
                String segment = (String) args.get('segment');
                String timeFrame = (String) args.get('timeFrame');
                
                // Map MCP parameters to handler request (using correct handler)
                ABAgentFuturePipeAnalysisHandler.Request handlerRequest = 
                    new ABAgentFuturePipeAnalysisHandler.Request();
                
                // Map opportunity type to analysis type
                if (opportunityType == 'cross-sell') {
                    handlerRequest.analysisType = 'CROSS_SELL';
                } else if (opportunityType == 'upsell') {
                    handlerRequest.analysisType = 'UPSELL';
                } else if (opportunityType == 'renewal') {
                    handlerRequest.analysisType = 'RENEWALS';
                } else {
                    handlerRequest.analysisType = 'FUTURE_PIPELINE';
                }
                
                // Set optional parameters (matching correct handler structure)
                if (String.isNotBlank(ouName)) {
                    handlerRequest.ouName = ouName;
                }
                if (String.isNotBlank(product)) {
                    handlerRequest.filterCriteria = 'product=\'' + String.escapeSingleQuotes(product) + '\'';
                }
                if (String.isNotBlank(segment)) {
                    handlerRequest.groupBy = 'MACRO_SEGMENT';
                    handlerRequest.filterCriteria = (String.isNotBlank(handlerRequest.filterCriteria) ? handlerRequest.filterCriteria + ' AND ' : '') + 'macrosgment__c=\'' + String.escapeSingleQuotes(segment) + '\'';
                }
                if (String.isNotBlank((String) args.get('region'))) {
                    handlerRequest.workLocationCountry = (String) args.get('region');
                }
                if (String.isNotBlank((String) args.get('industry'))) {
                    handlerRequest.groupBy = 'INDUSTRY';
                    handlerRequest.filterCriteria = (String.isNotBlank(handlerRequest.filterCriteria) ? handlerRequest.filterCriteria + ' AND ' : '') + 'primary_industry__c=\'' + String.escapeSingleQuotes((String) args.get('industry')) + '\'';
                }
                
                // Call the correct handler
                List<ABAgentFuturePipeAnalysisHandler.Response> handlerResponses = 
                    ABAgentFuturePipeAnalysisHandler.analyzePipeline(
                        new List<ABAgentFuturePipeAnalysisHandler.Request>{handlerRequest}
                    );
                
                Long endTime = System.currentTimeMillis();
                result.executionTimeMs = endTime - startTime;
                
                if (!handlerResponses.isEmpty()) {
                    ABAgentFuturePipeAnalysisHandler.Response handlerResponse = handlerResponses[0];
                    
                    Map<String, Object> response = new Map<String, Object>{
                        'tool' => 'future_pipeline',
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
                    result.message = 'No response from handler';
                }
                
            } catch (Exception e) {
                Long endTime = System.currentTimeMillis();
                result.executionTimeMs = endTime - startTime;
                result.success = false;
                result.message = 'Error in Future Pipeline Analysis: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'Future Pipeline MCP Adapter Error: ' + e.getStackTraceString());
            }
            
            results.add(result);
        }
        
        return results;
    }
}