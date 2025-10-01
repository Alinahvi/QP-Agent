/**
 * @description Simplified MCP Adapter for KPI Analysis
 * @version 1.0
 */
public with sharing class AN_KPI_FromMCP_Simple {
    
    public class Result {
        @InvocableVariable(label='Success') public Boolean success;
        @InvocableVariable(label='Message') public String message;
        @InvocableVariable(label='Response JSON') public String responseJson;
        @InvocableVariable(label='Correlation ID') public String correlationId;
        @InvocableVariable(label='Execution Time (ms)') public Long executionTimeMs;
        
        public Result() {
            this.success = false;
            this.message = '';
            this.responseJson = '';
            this.correlationId = '';
            this.executionTimeMs = 0;
        }
    }
    
    @InvocableMethod(
        label='Run KPI Analysis from MCP (Simple)'
        description='Executes KPI Analysis using normalized arguments from MCP'
    )
    public static List<Result> run(List<String> normalizedArgsJsons) {
        List<Result> results = new List<Result>();
        
        for (String argsJson : normalizedArgsJsons) {
            Result result = new Result();
            Long startTime = System.currentTimeMillis();
            
            try {
                Map<String, Object> args = (Map<String, Object>) JSON.deserializeUntyped(argsJson);
                String correlationId = (String) args.get('correlationId');
                if (String.isNotBlank(correlationId)) {
                    result.correlationId = correlationId;
                }
                
                String ouName = (String) args.get('ouName');
                
                ANAGENTKPIAnalysisHandlerV3.Request handlerRequest = new ANAGENTKPIAnalysisHandlerV3.Request();
                handlerRequest.action = 'Search';
                if (String.isNotBlank(ouName)) {
                    handlerRequest.OuName = ouName;
                }
                handlerRequest.recordLimit = 100;
                
                List<ANAGENTKPIAnalysisHandlerV3.Response> handlerResponses = 
                    ANAGENTKPIAnalysisHandlerV3.analyzeKPIs(new List<ANAGENTKPIAnalysisHandlerV3.Request>{handlerRequest});
                
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
            }
            
            results.add(result);
        }
        
        return results;
    }
}