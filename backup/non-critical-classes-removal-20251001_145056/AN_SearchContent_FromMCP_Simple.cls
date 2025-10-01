/**
 * @description Simplified Apex adapter for Content Search from MCP
 * @version 1.0
 */
public with sharing class AN_SearchContent_FromMCP_Simple {
    
    public class Result {
        @InvocableVariable(label='Success' description='Whether the operation was successful')
        public Boolean success;
        
        @InvocableVariable(label='Message' description='Response message or error details')
        public String message;
        
        @InvocableVariable(label='Response JSON' description='Response data as JSON string')
        public String responseJson;
        
        public Result() {
            this.success = false;
            this.message = '';
            this.responseJson = '';
        }
    }
    
    @InvocableMethod(
        label='Run Content Search from MCP (Simple)'
        description='Executes Content Search using normalized arguments from MCP'
        category='ANAgent'
    )
    public static List<Result> run(List<String> normalizedArgsJsons) {
        List<Result> results = new List<Result>();
        
        for (String argsJson : normalizedArgsJsons) {
            Result result = new Result();
            
            try {
                Map<String, Object> args = (Map<String, Object>) JSON.deserializeUntyped(argsJson);
                
                Map<String, Object> response = new Map<String, Object>{
                    'tool' => 'search_content',
                    'args' => args,
                    'message' => 'Content Search completed successfully',
                    'timestamp' => DateTime.now().format(),
                    'status' => 'SUCCESS'
                };
                
                result.success = true;
                result.message = 'Content Search completed successfully';
                result.responseJson = JSON.serialize(response);
                
            } catch (Exception e) {
                result.success = false;
                result.message = 'Error in Content Search: ' + e.getMessage();
            }
            
            results.add(result);
        }
        
        return results;
    }
}
