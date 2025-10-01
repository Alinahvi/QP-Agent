/**
 * @description MCP Adapter for Workflow Service
 * Routes MCP requests to existing ANAgentWorkflowService
 * @version 1.0
 */
public with sharing class AN_Workflow_FromMCP {
    
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
        label='Run Workflow Service from MCP'
        description='Routes MCP requests to ANAgentWorkflowService'
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
                String process = (String) args.get('process');
                String context = (String) args.get('context');
                String step = (String) args.get('step');
                
                // Map MCP parameters to handler request
                ANAgentWorkflowService.WorkflowRequest handlerRequest = 
                    new ANAgentWorkflowService.WorkflowRequest();
                
                // Set parameters
                if (String.isNotBlank(process)) {
                    handlerRequest.process = process;
                }
                if (String.isNotBlank(context)) {
                    handlerRequest.context = context;
                }
                if (String.isNotBlank(step)) {
                    handlerRequest.step = step;
                }
                
                // Call the actual handler
                List<ANAgentWorkflowService.WorkflowResponse> handlerResponses = 
                    ANAgentWorkflowService.executeWorkflow(
                        new List<ANAgentWorkflowService.WorkflowRequest>{handlerRequest}
                    );
                
                Long endTime = System.currentTimeMillis();
                result.executionTimeMs = endTime - startTime;
                
                if (!handlerResponses.isEmpty() && handlerResponses[0].success) {
                    ANAgentWorkflowService.WorkflowResponse handlerResponse = handlerResponses[0];
                    
                    Map<String, Object> response = new Map<String, Object>{
                        'tool' => 'workflow',
                        'args' => args,
                        'success' => handlerResponse.success,
                        'workflowSteps' => handlerResponse.workflowSteps,
                        'currentStep' => handlerResponse.currentStep,
                        'nextStep' => handlerResponse.nextStep,
                        'completionPercentage' => handlerResponse.completionPercentage,
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
                result.message = 'Error in Workflow Service: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'Workflow MCP Adapter Error: ' + e.getStackTraceString());
            }
            
            results.add(result);
        }
        
        return results;
    }
}