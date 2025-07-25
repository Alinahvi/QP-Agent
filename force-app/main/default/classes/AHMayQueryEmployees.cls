public with sharing class AHMayQueryEmployees {
    
    @InvocableMethod(label='AH May - Query Employees' description='Query employee data with pagination')
    public static List<String> queryEmployees(List<AHMayQueryRequest> requests) {
        // Process the request and serialize to JSON
        List<String> jsonResults = new List<String>();
        
        try {
            if (requests == null || requests.isEmpty()) {
                AHMayQueryResult errorResult = new AHMayQueryResult();
                errorResult.success = false;
                errorResult.message = 'No request data provided.';
                jsonResults.add(JSON.serialize(errorResult));
                return jsonResults;
            }
            
            AHMayQueryRequest request = requests[0];
            
            // Check for bulk query mode or large dataset mode
            if (request.queryMode != null) {
                if (request.queryMode.equalsIgnoreCase('BULK')) {
                    return processBulkQueries(requests);
                } else if (request.queryMode.equalsIgnoreCase('LARGE_DATASET')) {
                    return processLargeQueries(requests);
                }
            }
            
            // Start timing execution for performance monitoring
            Long startTime = System.currentTimeMillis();
            
            // Process the query
            AHMayQueryResult result = processQuery(request);
            
            // Store segmented employee IDs for potential follow-up course queries
            storeSegmentedEmployees(result, request.sessionId);
            
            // End timing
            Long endTime = System.currentTimeMillis();
            
            // Add timing information for debugging/monitoring
            if (result.metadataMap == null) {
                result.metadataMap = new Map<String, Object>();
            }
            result.metadataMap.put('executionTimeMs', endTime - startTime);
            
            jsonResults.add(JSON.serialize(result));
        } catch (Exception e) {
            AHMayQueryResult errorResult = new AHMayQueryResult();
            errorResult.success = false;
            errorResult.message = 'Error processing query: ' + e.getMessage() + 
                               ' Line: ' + e.getLineNumber();
            jsonResults.add(JSON.serialize(errorResult));
            
            // Log the error for monitoring
            System.debug(LoggingLevel.ERROR, 'AHMayQueryEmployees Error: ' + e.getMessage() + 
                        ' Stack trace: ' + e.getStackTraceString());
        }
        
        return jsonResults;
    }
    
    // Process bulk queries - multiple requests in one invocation
    private static List<String> processBulkQueries(List<AHMayQueryRequest> requests) {
        List<String> batchJsonResults = new List<String>();
        
        // Process each request in the batch
        for (AHMayQueryRequest request : requests) {
            try {
                // Start timing execution for performance monitoring
                Long startTime = System.currentTimeMillis();
                
                // Process the query
                AHMayQueryResult result = processQuery(request);
                
                // Store segmented employee IDs for potential follow-up course queries
                storeSegmentedEmployees(result, request.sessionId);
                
                // End timing
                Long endTime = System.currentTimeMillis();
                
                // Add timing information for debugging/monitoring
                if (result.metadataMap == null) {
                    result.metadataMap = new Map<String, Object>();
                }
                result.metadataMap.put('executionTimeMs', endTime - startTime);
                result.metadataMap.put('processingMode', 'BULK');
                
                batchJsonResults.add(JSON.serialize(result));
            } catch (Exception e) {
                AHMayQueryResult errorResult = new AHMayQueryResult();
                errorResult.success = false;
                errorResult.message = 'Error processing query: ' + e.getMessage() + 
                               ' Line: ' + e.getLineNumber();
                batchJsonResults.add(JSON.serialize(errorResult));
                
                // Log the error for monitoring
                System.debug(LoggingLevel.ERROR, 'AHMayQueryEmployees Batch Error: ' + e.getMessage() + 
                            ' Stack trace: ' + e.getStackTraceString());
            }
        }
        
        return batchJsonResults;
    }
    
    // Process large dataset queries
    private static List<String> processLargeQueries(List<AHMayQueryRequest> requests) {
        List<String> jsonResults = new List<String>();
        
        try {
            if (requests == null || requests.isEmpty()) {
                AHMayQueryResult errorResult = new AHMayQueryResult();
                errorResult.success = false;
                errorResult.message = 'No request data provided.';
                jsonResults.add(JSON.serialize(errorResult));
                return jsonResults;
            }
            
            AHMayQueryRequest request = requests[0];
            
            // Start timing execution for performance monitoring
            Long startTime = System.currentTimeMillis();
            
            // Process the query with streaming mode enabled
            AHMayQueryResult result = processLargeQuery(request);
            
            // Store segmented employee IDs for potential follow-up course queries
            storeSegmentedEmployees(result, request.sessionId);
            
            // End timing
            Long endTime = System.currentTimeMillis();
            
            // Add timing information for debugging/monitoring
            if (result.metadataMap == null) {
                result.metadataMap = new Map<String, Object>();
            }
            result.metadataMap.put('executionTimeMs', endTime - startTime);
            result.metadataMap.put('processingMode', 'LARGE_DATASET');
            
            jsonResults.add(JSON.serialize(result));
        } catch (Exception e) {
            AHMayQueryResult errorResult = new AHMayQueryResult();
            errorResult.success = false;
            errorResult.message = 'Error processing large query: ' + e.getMessage();
            jsonResults.add(JSON.serialize(errorResult));
            
            // Log the error for monitoring
            System.debug(LoggingLevel.ERROR, 'AHMayQueryEmployees Large Error: ' + e.getMessage() + 
                        ' Stack trace: ' + e.getStackTraceString());
        }
        
        return jsonResults;
    }
    
    /**
     * Store segmented employee IDs after successful query
     * @param result The query result containing employee records
     * @param sessionId The conversation session ID
     */
    private static void storeSegmentedEmployees(AHMayQueryResult result, String sessionId) {
        if (result.success && result.records != null && !result.records.isEmpty() && 
            !String.isBlank(sessionId)) {
            
            List<Id> employeeIds = new List<Id>();
            for (AHMayEmployeeRecord record : result.records) {
                employeeIds.add(record.recordId);
            }
            
            // Store in context
            AHMayCrossTopicContext.storeSegmentedEmployees(sessionId, employeeIds);
            
            // Debug log
            System.debug('Stored ' + employeeIds.size() + ' employee IDs for session ' + sessionId);
        }
    }
    
    // Method to handle large dataset queries using queueable
    private static AHMayQueryResult processLargeQuery(AHMayQueryRequest request) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Parse natural language query using prompt template
            String parsedResponse = AHMayPromptService.generatePromptResponse(request.userInput);
            
            // Parse JSON response
            Map<String, Object> queryData = AHMayPromptService.parseResponseToMap(parsedResponse);
            
            // Check for follow-up context
            if (queryData.containsKey('MAINTAIN_PREVIOUS_CONTEXT') && 
                (Boolean)queryData.get('MAINTAIN_PREVIOUS_CONTEXT') && 
                request.sessionId != null) {
                queryData = AHMaySessionContext.applyContextToQuery(request.sessionId, queryData);
            }
            
            // Determine and use appropriate handler
            AHMayQueryHandler handler = AHMayQueryHandlerFactory.getHandler(queryData);
            
            // Process the first page of results
            result = handler.handleQuery(request, queryData);
            
            // If we have a large result set and it needs further processing
            if (result.success && result.totalRecords > 1000 && String.isNotBlank(request.sessionId)) {
                // Mark for background processing
                result.processingInBackground = true;
                
                // Schedule additional processing in the background
                AHMayLargeQueryProcessor processor = new AHMayLargeQueryProcessor(
                    request.sessionId,
                    result.queryUsed,
                    queryData,
                    result.totalRecords
                );
                
                // Queue the background processor
                System.enqueueJob(processor);
                
                // Update message to inform about background processing
                result.message += '\n\nProcessing ' + result.totalRecords + 
                               ' records in the background. You can continue to query as the first page of results is ready.';
            }
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error processing large query: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'AHMayQueryEmployees Large Process Error: ' + e.getMessage() + 
                        ' Stack trace: ' + e.getStackTraceString());
        }
        
        return result;
    }
    
    // Include the processQuery method directly in this class to avoid dependency issues
    private static AHMayQueryResult processQuery(AHMayQueryRequest request) {
        return AHMayQueryService.processQuery(request);
    }
    
    // Method for formatting grouped results in the UI
    private static String formatGroupedResults(String groupField, List<Learner_Profile__c> displayedRecords, 
                                             Map<String, Integer> totalGroupCounts, Integer pageNumber) {
        // Group displayed records by the group field
        Map<String, List<Learner_Profile__c>> displayGroups = new Map<String, List<Learner_Profile__c>>();
        
        for (Learner_Profile__c record : displayedRecords) {
            Object fieldValue = record.get(groupField);
            String groupValue = fieldValue != null ? String.valueOf(fieldValue) : '(No value)';
            
            if (!displayGroups.containsKey(groupValue)) {
                displayGroups.put(groupValue, new List<Learner_Profile__c>());
            }
            displayGroups.get(groupValue).add(record);
        }
        
        // Format the message
        String message = 'Employees grouped by ' + groupField.replace('__c', '') + ':\n\n';
        
        // Get all group keys in a sorted order
        List<String> sortedGroups = new List<String>(displayGroups.keySet());
        sortedGroups.sort();
        
        for (String groupValue : sortedGroups) {
            List<Learner_Profile__c> groupRecords = displayGroups.get(groupValue);
            Integer totalCount = totalGroupCounts.containsKey(groupValue) ? 
                                totalGroupCounts.get(groupValue) : groupRecords.size();
            
            message += groupValue + ' (Total: ' + totalCount + ')\n';
            
            for (Integer i = 0; i < groupRecords.size(); i++) {
                Learner_Profile__c emp = groupRecords[i];
                message += (i+1) + '. **' + emp.Name + '** (' + emp.Primary_Email__c + ')\n';
                message += '   * Manager: ' + emp.Manager__c + '\n';
            }
            
            message += '\n';
        }
        
        // Add pagination info if needed
        message += 'Page ' + pageNumber + ' - ';
        if (totalGroupCounts.size() > displayGroups.size()) {
            message += 'Showing ' + displayGroups.size() + ' out of ' + totalGroupCounts.size() + ' groups.\n';
        }
        
        return message;
    }
    
    // Queueable class for processing large query results in the background
    public class AHMayLargeQueryProcessor implements Queueable {
        private String sessionId;
        private String query;
        private Map<String, Object> queryData;
        private Integer totalRecords;
        private Integer processed;
        private Integer batchSize;
        
        public AHMayLargeQueryProcessor(String sessionId, String query, 
                                    Map<String, Object> queryData, Integer totalRecords) {
            this.sessionId = sessionId;
            this.query = query;
            this.queryData = queryData;
            this.totalRecords = totalRecords;
            this.processed = 0;
            this.batchSize = 200; // Process in batches of 200
        }
        
        public void execute(QueueableContext context) {
            try {
                // Calculate offset for this batch
                Integer offset = processed;
                
                // Remove any existing LIMIT and OFFSET
                String baseQuery = query;
                if (baseQuery.containsIgnoreCase(' LIMIT ')) {
                    baseQuery = baseQuery.substring(0, baseQuery.toLowerCase().indexOf(' limit '));
                }
                
                // Add new limits for this batch
                String batchQuery = baseQuery + ' LIMIT ' + batchSize + ' OFFSET ' + offset;
                
                // Execute query
                List<Learner_Profile__c> records = Database.query(batchQuery);
                processed += records.size();
                
                // Store results in cache and append to existing results
                List<Learner_Profile__c> existingRecords = AHMayQueryCache.getResults(sessionId);
                existingRecords.addAll(records);
                
                // Update cache
                AHMayQueryCache.storeResults(sessionId, existingRecords, totalRecords, queryData);
                
                // Store for segmentation context as well
                List<Id> employeeIds = new List<Id>();
                for (Learner_Profile__c record : existingRecords) {
                    employeeIds.add(record.Id);
                }
                AHMayCrossTopicContext.storeSegmentedEmployees(sessionId, employeeIds);
                
                // If we have more records to process, chain to next execution
                if (processed < totalRecords) {
                    System.enqueueJob(this);
                }
                
                System.debug('Processed ' + processed + ' of ' + totalRecords + 
                           ' total records for session ' + sessionId);
                
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Error in AHMayLargeQueryProcessor: ' + 
                            e.getMessage() + ' - ' + e.getStackTraceString());
            }
        }
    }
}