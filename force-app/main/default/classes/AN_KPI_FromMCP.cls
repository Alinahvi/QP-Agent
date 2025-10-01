/**
 * @description MCP Adapter for KPI Analysis
 * Routes MCP requests to existing ANAgentKPIsAnalysis
 * @version 1.0
 */
public with sharing class AN_KPI_FromMCP {
    
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
        label='Run KPI Analysis from MCP'
        description='Routes MCP requests to ANAgentKPIsAnalysis'
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
                String timeFrame = (String) args.get('timeFrame');
                String kpiType = (String) args.get('kpiType');
                String region = (String) args.get('region');
                String groupBy = (String) args.get('groupBy');
                String filterCriteria = (String) args.get('filterCriteria');
                String rampStatus = (String) args.get('rampStatus');
                Boolean perAENormalize = (Boolean) args.get('perAENormalize');
                String aggregationType = (String) args.get('aggregationType');
                
                // Map MCP parameters to handler request
                ANAGENTKPIAnalysisHandlerV3.Request handlerRequest = 
                    new ANAGENTKPIAnalysisHandlerV3.Request();
                
                // Set parameters
                handlerRequest.action = 'Search';
                if (String.isNotBlank(ouName)) {
                    handlerRequest.OuName = ouName;
                }
                if (String.isNotBlank(region)) {
                    handlerRequest.WorkLocationCountry = region;
                }
                if (String.isNotBlank(kpiType)) {
                    handlerRequest.metricKey = kpiType;
                }
                if (String.isNotBlank(timeFrame)) {
                    handlerRequest.timeFrame = timeFrame;
                }
                if (String.isNotBlank(groupBy)) {
                    handlerRequest.groupBy = groupBy;
                }
                if (String.isNotBlank(filterCriteria)) {
                    handlerRequest.filterCriteria = filterCriteria;
                }
                if (String.isNotBlank(rampStatus)) {
                    handlerRequest.RampStatus = rampStatus;
                }
                if (perAENormalize != null) {
                    handlerRequest.perAENormalize = perAENormalize;
                }
                if (String.isNotBlank(aggregationType)) {
                    handlerRequest.aggregationType = aggregationType;
                }
                handlerRequest.recordLimit = 100;
                
                // Call the actual handler
                List<ANAGENTKPIAnalysisHandlerV3.Response> handlerResponses = 
                    ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(
                        new List<ANAGENTKPIAnalysisHandlerV3.Request>{handlerRequest}
                    );
                
                Long endTime = System.currentTimeMillis();
                result.executionTimeMs = endTime - startTime;
                
                if (!handlerResponses.isEmpty() && handlerResponses[0].success) {
                    ANAGENTKPIAnalysisHandlerV3.Response handlerResponse = handlerResponses[0];
                    
                    Map<String, Object> response = new Map<String, Object>{
                        'tool' => 'kpi_analyze',
                        'args' => args,
                        'success' => handlerResponse.success,
                        'totalRecordCount' => handlerResponse.totalRecordCount,
                        'kpiRecords' => handlerResponse.kpiRecords,
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
                result.message = 'Error in KPI Analysis: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'KPI MCP Adapter Error: ' + e.getStackTraceString());
            }
            
            results.add(result);
        }
        
        return results;
    }
}