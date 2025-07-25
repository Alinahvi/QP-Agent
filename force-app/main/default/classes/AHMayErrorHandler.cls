/**
 * Consistent error handling for the Agentforce employee query system
 */
public class AHMayErrorHandler {
    // Error categories
    public enum ErrorCategory {
        PROMPT_ERROR,       // Error in prompt generation/parsing
        QUERY_ERROR,        // Error in query execution
        DATA_ERROR,         // Error in data retrieval/processing
        HANDLER_ERROR,      // Error in specific handler logic
        SYSTEM_ERROR        // Unexpected system errors
    }
    
    // Log and handle errors consistently
    public static AHMayQueryResult handleError(ErrorCategory category, Exception e, 
                                              String context, String userQuery) {
        // Log the error with proper context
        logError(category, e, context, userQuery);
        
        // Create user-friendly error message
        AHMayQueryResult result = new AHMayQueryResult();
        result.success = false;
        
        switch on category {
            when PROMPT_ERROR {
                result.message = 'I had trouble understanding your query. Could you please rephrase it or provide more details?';
                
                // Add prompt help suggestions
                result.message += '\n\nTry queries like:';
                result.message += '\n- "Show me employees in AMER division"';
                result.message += '\n- "Who reports to [Manager Name]?"';
                result.message += '\n- "Find employees in the Engineering job family"';
            }
            when QUERY_ERROR {
                result.message = 'There was a problem with the query format. Please try a simpler query or contact support if this persists.';
                
                // Add query troubleshooting suggestions
                if (userQuery != null) {
                    result.message += '\n\nYour query might contain terms or attributes that are not available in the employee database.';
                    result.message += '\nTry asking "What employee fields do you have?" to see available search options.';
                }
            }
            when DATA_ERROR {
                result.message = 'I couldn\'t find the data you requested. Please check your search terms or try with different criteria.';
                
                // Add data troubleshooting suggestions
                if (userQuery != null && userQuery.containsIgnoreCase('reports to') || userQuery.containsIgnoreCase('manager')) {
                    result.message += '\n\nIf you\'re looking for reporting relationships, try to be more specific with the manager\'s name.';
                    result.message += '\nMake sure you\'re using the correct spelling and full name if possible.';
                }
            }
            when HANDLER_ERROR, SYSTEM_ERROR {
                result.message = 'I encountered a system error while processing your request. Please try again later or contact support.';
                
                // Add basic error reference for support
                String errorRef = generateErrorReference();
                result.message += '\n\nError reference: ' + errorRef;
                
                // Store error reference for support lookup
                storeErrorReference(errorRef, category, e, context, userQuery);
            }
        }
        
        // Add detailed error info only for specific users or in test context
        if (Test.isRunningTest() || isSupportUser()) {
            result.metadataMap = new Map<String, Object>{
                'errorCategory' => category.name(),
                'errorMessage' => e.getMessage(),
                'errorContext' => context,
                'errorLineNumber' => e.getLineNumber()
            };
            
            // Add more detailed message for support users
            result.message += '\n\n--- DEVELOPER DETAILS ---';
            result.message += '\nError: ' + e.getMessage();
            result.message += '\nContext: ' + context;
            result.message += '\nLine: ' + e.getLineNumber();
        }
        
        return result;
    }
    
    // Log detailed error information
    private static void logError(ErrorCategory category, Exception e, 
                              String context, String userQuery) {
        // Format error for logging
        String errorLog = 'AHMay Error [' + category.name() + ']: ' + 
                        e.getMessage() + ' - ' + e.getStackTraceString() + 
                        ' - Context: ' + context;
        
        if (String.isNotBlank(userQuery)) {
            errorLog += ' - Query: ' + userQuery;
        }
        
        // Log to debug logs
        System.debug(LoggingLevel.ERROR, errorLog);
        
        // In a production system, consider logging to a custom object
        // that can be monitored and analyzed
        logToCustomObject(category, e, context, userQuery);
    }
    
    // Log to custom object for persistent error tracking
    private static void logToCustomObject(ErrorCategory category, Exception e, 
                                       String context, String userQuery) {
        // In a production implementation, you would create/use a custom object
        // to store error logs for monitoring and troubleshooting
        
        // Example:
        /*
        AHMay_Error_Log__c errorLog = new AHMay_Error_Log__c(
            Category__c = category.name(),
            Error_Message__c = e.getMessage(),
            Stack_Trace__c = e.getStackTraceString(),
            Context__c = context,
            User_Query__c = userQuery,
            Line_Number__c = e.getLineNumber(),
            User__c = UserInfo.getUserId(),
            Timestamp__c = System.now()
        );
        
        try {
            insert errorLog;
        } catch (Exception logEx) {
            // If we can't log to the custom object, just log to debug logs
            System.debug(LoggingLevel.ERROR, 'Failed to log error to custom object: ' + logEx.getMessage());
        }
        */
    }
    
    // Generate a unique error reference for support
    private static String generateErrorReference() {
        Datetime now = System.now();
        String dateString = now.format('yyyyMMddHHmmss');
        
        // Create a hash from current time and random number
        Integer randomPart = Math.abs(Math.round(Math.random() * 10000));
        
        return 'AHM-' + dateString + '-' + randomPart;
    }
    
    // Store error reference for support lookup
    private static void storeErrorReference(String errorRef, ErrorCategory category, 
                                         Exception e, String context, String userQuery) {
        // In a production implementation, store this reference with full error details
        // in a custom object or external system for support lookup
        
        // For this implementation, just log the reference
        System.debug(LoggingLevel.ERROR, 'Error reference: ' + errorRef + 
                    ' - Category: ' + category.name() + 
                    ' - Error: ' + e.getMessage());
    }
    
    // Check if current user is a support/admin user
    private static Boolean isSupportUser() {
        // In a production implementation, check for admin profile or permission set
        // Example: return [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'AHMay_Support_Admin' LIMIT 1].size() > 0;
        
        // For this implementation, just return false
        return false;
    }
}