public with sharing class AHMayQueryService {
    
    public static AHMayQueryResult processQuery(AHMayQueryRequest request) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            System.debug('Original user input: ' + request.userInput);
            
            // Parse natural language query using prompt template
            String parsedResponse = AHMayPromptService.generatePromptResponse(request.userInput);
            System.debug('Parsed response from LLM: ' + parsedResponse);
            
            // Parse JSON response
            Map<String, Object> queryData = AHMayPromptService.parseResponseToMap(parsedResponse);
            System.debug('Query data after parsing: ' + JSON.serialize(queryData));
            
            // Enrichment: Add original query for reference and intent detection
            queryData.put('ORIGINAL_QUERY', request.userInput);
            
            // Check for follow-up context with improved context handling
            if (queryData.containsKey('MAINTAIN_PREVIOUS_CONTEXT') && 
                (Boolean)queryData.get('MAINTAIN_PREVIOUS_CONTEXT') && 
                request.sessionId != null) {
                System.debug('Before applying context - Query data: ' + JSON.serialize(queryData));
                queryData = AHMaySessionContext.intelligentMergeContext(request.sessionId, queryData);
                System.debug('After applying context - Query data: ' + JSON.serialize(queryData));
            }

            // Resolve "CURRENT_USER" or "CURRENT_USER_BOSS" keywords to the appropriate name
            queryData = resolveCurrentUser(queryData);
            
            // Enhanced intent detection
            queryData = enhanceQueryIntent(queryData, request.userInput);
            System.debug('After intent enhancement - Query data: ' + JSON.serialize(queryData));
            
            // Check for multi-intent query
            if (isMultiIntentQuery(queryData)) {
                result = processMultiIntentQuery(request, queryData);
            } else {
                // Determine and use appropriate handler
                AHMayQueryHandler handler = AHMayQueryHandlerFactory.getHandler(queryData);
                System.debug('Selected handler: ' + handler);
                
                result = handler.handleQuery(request, queryData);
            }
            
            // Store context if needed for follow-up queries
            if (request.sessionId != null) {
                AHMaySessionContext.storeQueryContext(request.sessionId, queryData);
                
                // Store result summary for context as well if present
                if (result.success && result.totalRecords > 0) {
                    AHMaySessionContext.storeResultSummary(request.sessionId, 
                                                        result.totalRecords, 
                                                        result.pageNumber, 
                                                        result.hasMore);
                }
            }
            
            // Add parsed query to result
            result.parsedQuery = parsedResponse;
            
        } catch (JSONException je) {
            result.success = false;
            result.message = 'Error parsing query response: ' + je.getMessage() + '. Please try again with a different phrasing.';
            System.debug(LoggingLevel.ERROR, 'JSON parse error: ' + je.getMessage());
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error processing query: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'Error processing query: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }
        
        return result;
    }

    /**
     * @description (ENHANCED) Checks for "CURRENT_USER" or "CURRENT_USER_BOSS" keywords and resolves 
     * them to the appropriate name from the logged-in user's Learner_Profile__c record.
     * @param queryData The map of query parameters from the LLM.
     * @return The modified map with the correct name inserted.
     */
    private static Map<String, Object> resolveCurrentUser(Map<String, Object> queryData) {
        // Check for the keywords in both direct reports and hierarchical queries
        String directReportsValue = (String)queryData.get('DIRECT_REPORTS');
        String hierarchicalValue = (String)queryData.get('HIERARCHICAL_QUERY');

        Boolean isMyTeamQuery = 'CURRENT_USER'.equals(directReportsValue);
        Boolean isMyOrgQuery = 'CURRENT_USER'.equals(hierarchicalValue);
        Boolean isMyBossTeamQuery = 'CURRENT_USER_BOSS'.equals(directReportsValue);
        Boolean isMyBossOrgQuery = 'CURRENT_USER_BOSS'.equals(hierarchicalValue);

        // If no special keywords are found, exit immediately.
        if (!isMyTeamQuery && !isMyOrgQuery && !isMyBossTeamQuery && !isMyBossOrgQuery) {
            return queryData;
        }

        try {
            // Find the Learner Profile for the currently logged-in user.
            // We now need the Manager__c field for "boss" queries.
            Learner_Profile__c currentUserProfile = [
                SELECT Name, Manager__c 
                FROM Learner_Profile__c 
                WHERE User__c = :UserInfo.getUserId() 
                LIMIT 1
            ];
            
            // --- Handle CURRENT_USER keyword ---
            if (isMyTeamQuery) {
                queryData.put('DIRECT_REPORTS', currentUserProfile.Name);
                System.debug('Resolved CURRENT_USER to: ' + currentUserProfile.Name);
            }
            if (isMyOrgQuery) {
                queryData.put('HIERARCHICAL_QUERY', currentUserProfile.Name);
                System.debug('Resolved CURRENT_USER to: ' + currentUserProfile.Name);
            }

            // --- Handle CURRENT_USER_BOSS keyword ---
            if (isMyBossTeamQuery || isMyBossOrgQuery) {
                if (String.isNotBlank(currentUserProfile.Manager__c)) {
                    String bossName = currentUserProfile.Manager__c;
                    if (isMyBossTeamQuery) {
                        queryData.put('DIRECT_REPORTS', bossName);
                    }
                    if (isMyBossOrgQuery) {
                        queryData.put('HIERARCHICAL_QUERY', bossName);
                    }
                    System.debug('Resolved CURRENT_USER_BOSS to: ' + bossName);
                } else {
                    // The user has no manager listed, so we can't proceed.
                    throw new AuraHandledException('Current user does not have a manager listed.');
                }
            }

        } catch (Exception e) {
            // If any error occurs (e.g., no profile found, no manager), replace the keyword 
            // with a value that will cause a clean "not found" message from the handler.
            String unresolvableName = '--KEYWORD_RESOLUTION_FAILED--';
            if (isMyTeamQuery || isMyBossTeamQuery) {
                queryData.put('DIRECT_REPORTS', unresolvableName);
            }
            if (isMyOrgQuery || isMyBossOrgQuery) {
                queryData.put('HIERARCHICAL_QUERY', unresolvableName);
            }
            System.debug('Could not resolve keyword: ' + e.getMessage());
        }

        return queryData;
    }
    
    // New method to detect if this is a multi-intent query
    private static Boolean isMultiIntentQuery(Map<String, Object> queryData) {
        // Check for key combinations that indicate multiple intents
        
        // Direct Reports + Aggregation
        if ((queryData.containsKey('DIRECT_REPORTS') || queryData.containsKey('DIRECT_REPORTS_OR')) && 
            ((queryData.containsKey('AGGREGATION') && (Boolean)queryData.get('AGGREGATION')) || 
             (queryData.containsKey('GROUP_BY_FIELD') || queryData.containsKey('GROUP_BY_FIELDS')))) {
            return true;
        }
        
        // Hierarchical + Aggregation
        if ((queryData.containsKey('HIERARCHICAL_QUERY') || queryData.containsKey('HIERARCHICAL_QUERY_OR')) && 
            ((queryData.containsKey('AGGREGATION') && (Boolean)queryData.get('AGGREGATION')) || 
             (queryData.containsKey('GROUP_BY_FIELD') || queryData.containsKey('GROUP_BY_FIELDS')))) {
            return true;
        }
        
        // Multi-aggregation (multiple GROUP_BY)
        if (queryData.containsKey('GROUP_BY_FIELDS') && 
            queryData.get('GROUP_BY_FIELDS') instanceof List<Object> && 
            ((List<Object>)queryData.get('GROUP_BY_FIELDS')).size() > 1) {
            return true;
        }
        
        return false;
    }
    
    // New method to process multi-intent queries
    private static AHMayQueryResult processMultiIntentQuery(AHMayQueryRequest request, Map<String, Object> queryData) {
        System.debug('Processing multi-intent query: ' + JSON.serialize(queryData));
        
        // Step 1: Determine the primary intent (usually fetching data)
        Map<String, Object> primaryQueryData = new Map<String, Object>(queryData);
        
        // Remove aggregation flags for primary query
        primaryQueryData.remove('AGGREGATION');
        primaryQueryData.remove('GROUP_BY_FIELD');
        primaryQueryData.remove('GROUP_BY_FIELDS');
        primaryQueryData.remove('GROUP_BY_DATE_UNIT');
        
        // Step 2: Execute primary query to get base dataset
        AHMayQueryHandler primaryHandler = AHMayQueryHandlerFactory.getHandler(primaryQueryData);
        AHMayQueryResult primaryResult = primaryHandler.handleQuery(request, primaryQueryData);
        
        if (!primaryResult.success || primaryResult.totalRecords == 0) {
            // If primary query fails or returns no data, just return its result
            return primaryResult;
        }
        
        // Step 3: Process secondary intent (usually aggregation)
        if ((queryData.containsKey('AGGREGATION') && (Boolean)queryData.get('AGGREGATION')) || 
            queryData.containsKey('GROUP_BY_FIELD') || queryData.containsKey('GROUP_BY_FIELDS')) {
            
            // Prepare secondary query data
            Map<String, Object> secondaryQueryData = new Map<String, Object>();
            secondaryQueryData.put('AGGREGATION', true);
            
            // Transfer grouping parameters
            if (queryData.containsKey('GROUP_BY_FIELD')) {
                secondaryQueryData.put('GROUP_BY_FIELD', queryData.get('GROUP_BY_FIELD'));
            }
            if (queryData.containsKey('GROUP_BY_FIELDS')) {
                secondaryQueryData.put('GROUP_BY_FIELDS', queryData.get('GROUP_BY_FIELDS'));
            }
            if (queryData.containsKey('GROUP_BY_DATE_UNIT')) {
                secondaryQueryData.put('GROUP_BY_DATE_UNIT', queryData.get('GROUP_BY_DATE_UNIT'));
            }
            
            // Execute aggregation on the result set from primary query
            AHMayAggregationHandler aggregationHandler = new AHMayAggregationHandler();
            
            // Store primary results in cache to be used by aggregation handler
            if (request.sessionId != null) {
                // We should already have the data from the primary query stored in the cache
                // This ensures aggregation handler will find it
                AHMaySessionContext.storeQueryContext(request.sessionId, primaryQueryData);
            }
            
            return aggregationHandler.handleQuery(request, secondaryQueryData);
        }
        
        // If no clear secondary intent, just return primary result
        return primaryResult;
    }
    
    // Enhanced intent detection based on query text
    private static Map<String, Object> enhanceQueryIntent(Map<String, Object> queryData, String userInput) {
        String normalizedInput = userInput.toLowerCase();
        Map<String, Object> enhancedData = new Map<String, Object>(queryData);
        
        // Detect hierarchical query phrases
        List<String> hierarchicalPhrases = new List<String>{
            'roll up', 'rolls up', 'rolling up',
            'organization', 'org', 'organizational', 
            'entire team', 'all employees under', 'all employees who report',
            'report up', 'reporting up', 'reports up',
            'management chain', 'chain of command',
            'everyone under', 'everyone who reports',
            'hierarchy'
        };
        
        // Direct reports phrases
        List<String> directPhrases = new List<String>{
            'direct report', 'directly report', 'immediate report',
            'direct team', 'immediately report'
        };
        
        // Aggregation phrases
        List<String> aggregationPhrases = new List<String>{
            'group by', 'categorize by', 'segment by', 'break down by', 
            'analyze by', 'summarize by', 'count by', 'calculate by',
            'stats for', 'statistics for', 'metrics for'
        };
        
        // Correct direct reports to hierarchical if needed
        if (enhancedData.containsKey('DIRECT_REPORTS') && !containsAnyPhrase(normalizedInput, directPhrases)) {
            if (containsAnyPhrase(normalizedInput, hierarchicalPhrases)) {
                System.debug('CORRECTING: Converting DIRECT_REPORTS to HIERARCHICAL_QUERY based on phrasing');
                enhancedData.put('HIERARCHICAL_QUERY', enhancedData.get('DIRECT_REPORTS'));
                enhancedData.remove('DIRECT_REPORTS');
            }
        }
        
        // Add aggregation intent if missing but implied
        if (!enhancedData.containsKey('AGGREGATION') && 
            containsAnyPhrase(normalizedInput, aggregationPhrases)) {
            System.debug('ENHANCING: Adding aggregation intent based on phrasing');
            enhancedData.put('AGGREGATION', true);
            
            // Attempt to detect grouping field if missing
            if (!enhancedData.containsKey('GROUP_BY_FIELD')) {
                String groupByField = detectGroupByField(normalizedInput);
                if (groupByField != null) {
                    enhancedData.put('GROUP_BY_FIELD', groupByField);
                }
            }
        }
        
        return enhancedData;
    }
    
    // Helper method to check if text contains any phrase from a list
    private static Boolean containsAnyPhrase(String text, List<String> phrases) {
        for (String phrase : phrases) {
            if (text.contains(phrase)) {
                return true;
            }
        }
        return false;
    }
    
    // Method to detect grouping field from text
    private static String detectGroupByField(String text) {
        // Simple field detection based on common patterns
        Map<String, String> fieldPhraseMap = new Map<String, String>{
            'location' => 'Employee_Location__c',
            'division' => 'Division__c',
            'job' => 'Job_Family__c',
            'manager' => 'Manager__c',
            'country' => 'Work_Location_Country__c',
            'hire date' => 'Hire_Date__c',
            'business unit' => 'Business_Unit_Name__c'
        };
        
        for (String phrase : fieldPhraseMap.keySet()) {
            if (text.contains(phrase)) {
                return fieldPhraseMap.get(phrase);
            }
        }
        
        return null;
    }
}