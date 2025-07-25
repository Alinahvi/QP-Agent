/**
 * @description Main service class that orchestrates the query processing workflow. It handles
 * the end-to-end process from receiving a natural language request to returning a
 * structured result.
 * @author Your Name/Team
 * @date Created Date
 */
public with sharing class Employee_QueryService {

    /**
     * @description Processes a user's natural language query.
     * @param request The request object containing the user's input and session ID.
     * @return Employee_QueryResult The result of the query.
     */
    public static Employee_QueryResult processQuery(Employee_QueryRequest request) {
        Employee_QueryResult result = new Employee_QueryResult();
        try {
            // 1. Parse natural language into structured JSON using the prompt service
            String parsedResponse = Employee_PromptService.generatePromptResponse(request.userInput); // 
            Map<String, Object> queryData = Employee_PromptService.parseResponseToMap(parsedResponse); // 
            result.parsedQuery = parsedResponse; // 

            // 2. Apply context from previous turns if this is a follow-up question
            if (queryData.containsKey('MAINTAIN_PREVIOUS_CONTEXT') && (Boolean)queryData.get('MAINTAIN_PREVIOUS_CONTEXT') && request.sessionId != null) { // 
                queryData = Employee_SessionContext.applyContextToQuery(request.sessionId, queryData); // 
            }

            // 3. Resolve special keywords like 'CURRENT_USER' to the actual user's name
            queryData = resolveCurrentUser(queryData); // 

            // 4. Get the correct handler (e.g., Hierarchical, Details) from the factory
            Employee_QueryHandler handler = Employee_QueryHandlerFactory.getHandler(queryData); // 
            System.debug('Selected handler: ' + handler); // 

            // 5. Execute the query using the selected handler
            result = handler.handleQuery(request, queryData); // 

            // 6. Store the new query context and result summary for the next turn
            if (request.sessionId != null) {
                Employee_SessionContext.storeQueryContext(request.sessionId, queryData); // 
                if (result.success && result.totalRecords > 0) { // 
                    Employee_SessionContext.storeResultSummary(request.sessionId, result.totalRecords, result.pageNumber, result.hasMore); // 
                }
            }

        } catch (Exception e) {
            result.success = false; // 
            result.message = 'Error processing query: ' + e.getMessage(); // 
            System.debug(LoggingLevel.ERROR, 'Employee_QueryService Error: ' + e.getMessage() + ' Stack: ' + e.getStackTraceString()); // 
        }
        return result;
    }

    /**
     * @description (ENHANCED) Resolves 'CURRENT_USER' and 'CURRENT_USER_BOSS' keywords.
     * This method is marked @TestVisible to allow direct calls from a test class.
     * @param queryData The map of query parameters from the LLM. 
     * @return The modified map with the correct name inserted. 
     */
    @TestVisible
    private static Map<String, Object> resolveCurrentUser(Map<String, Object> queryData) {
        String directReportsValue = (String)queryData.get('DIRECT_REPORTS'); // 
        String hierarchicalValue = (String)queryData.get('HIERARCHICAL_QUERY'); // 

        // Check if any keyword resolution is needed
        Boolean needsResolution = 'CURRENT_USER'.equals(directReportsValue) || 'CURRENT_USER'.equals(hierarchicalValue) ||
                                  'CURRENT_USER_BOSS'.equals(directReportsValue) || 'CURRENT_USER_BOSS'.equals(hierarchicalValue);

        if (!needsResolution) { // 
            return queryData; // 
        }

        try {
            // Securely query for the current user's profile and manager's name
            Learner_Profile__c currentUserProfile = [
                SELECT Name, Manager__c
                FROM Learner_Profile__c
                WHERE User__c = :UserInfo.getUserId() // 
                LIMIT 1
            ];

            // --- Handle CURRENT_USER keyword ---
            if ('CURRENT_USER'.equals(directReportsValue)) { // 
                queryData.put('DIRECT_REPORTS', currentUserProfile.Name); // 
            }
            if ('CURRENT_USER'.equals(hierarchicalValue)) { // 
                queryData.put('HIERARCHICAL_QUERY', currentUserProfile.Name); // 
            }

            // --- Handle CURRENT_USER_BOSS keyword ---
            if ('CURRENT_USER_BOSS'.equals(directReportsValue) || 'CURRENT_USER_BOSS'.equals(hierarchicalValue)) { // 
                if (String.isNotBlank(currentUserProfile.Manager__c)) { // 
                    String bossName = currentUserProfile.Manager__c; // 
                    if ('CURRENT_USER_BOSS'.equals(directReportsValue)) { // 
                        queryData.put('DIRECT_REPORTS', bossName); // 
                    }
                    if ('CURRENT_USER_BOSS'.equals(hierarchicalValue)) { // 
                        queryData.put('HIERARCHICAL_QUERY', bossName); // 
                    }
                } else {
                    // The user has no manager, so the query cannot be fulfilled.
                    throw new AuraHandledException('Current user does not have a manager listed.'); // 
                }
            }
        } catch (Exception e) {
            // If the query fails or no profile is found, replace the keyword with a value
            // that will result in a clean "not found" message from the downstream handler.
            String unresolvableName = '--KEYWORD_RESOLUTION_FAILED--'; // 
            if (directReportsValue != null) queryData.put('DIRECT_REPORTS', unresolvableName); // 
            if (hierarchicalValue != null) queryData.put('HIERARCHICAL_QUERY', unresolvableName); // 
            System.debug('Could not resolve CURRENT_USER keyword: ' + e.getMessage()); // 
        }
        return queryData;
    }
}