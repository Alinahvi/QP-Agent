public class AHMayStandardQueryHandler implements AHMayQueryHandler {
    
    private static final Integer MAX_DIRECT_QUERY_ROWS = 10000; // Threshold for large queries
    
    public AHMayQueryResult handleQuery(AHMayQueryRequest request, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Debug: Check input data
            System.debug('Standard Query Data: ' + JSON.serialize(queryData));
            
            // First estimate the result size
            Integer estimatedCount = getEstimatedCount(queryData);
            
            // If too large, provide feedback and sampling
            if (estimatedCount > MAX_DIRECT_QUERY_ROWS) {
                return handleLargeResultSet(request, queryData, estimatedCount);
            }
            
            // For manageable result sets, proceed with normal query
            Integer pageSize = 20;
            Integer offset = (request.pageNumber != null ? request.pageNumber - 1 : 0) * pageSize;
            
            // Build and execute the query
            String query = buildStandardQuery(queryData, pageSize, offset);
            System.debug('Standard Query: ' + query);
            
            List<Learner_Profile__c> profiles = Database.query(query);
            
            // Get total count
            Integer totalRecords = Database.countQuery(buildCountQuery(queryData));
            
            // Format result
            result.success = true;
            result.totalRecords = totalRecords;
            result.pageNumber = request.pageNumber != null ? request.pageNumber : 1;
            result.records = AHMayResultFormatter.formatEmployeeRecords(profiles);
            result.message = AHMayResultFormatter.formatSuccessMessage(profiles.size(), totalRecords, result.pageNumber);
            result.queryUsed = query;
            result.hasMore = (totalRecords > offset + pageSize);
            
            // Add session context
            if (request.sessionId != null) {
                AHMaySessionContext.storeSessionTotalCount(request.sessionId, totalRecords);
            }
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error processing query: ' + e.getMessage() + 
                           ' (Line: ' + e.getLineNumber() + ')';
            System.debug('Standard Query Error: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
        }
        
        return result;
    }
    
    private Integer getEstimatedCount(Map<String, Object> queryData) {
        try {
            if (queryData == null) {
                return 0;
            }
            return Database.countQuery(buildCountQuery(queryData));
        } catch (Exception e) {
            // If count query fails due to size, return a high number
            if (e.getMessage().contains('Too many')) {
                return MAX_DIRECT_QUERY_ROWS + 1;
            }
            throw e;
        }
    }
    
    private AHMayQueryResult handleLargeResultSet(AHMayQueryRequest request, Map<String, Object> queryData, Integer estimatedCount) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Return a sample of the data with a warning
            Integer pageSize = 20;
            String query = buildStandardQuery(queryData, pageSize, 0);
            List<Learner_Profile__c> sampleProfiles = Database.query(query);
            
            result.success = true;
            result.totalRecords = estimatedCount;
            result.pageNumber = 1;
            result.records = AHMayResultFormatter.formatEmployeeRecords(sampleProfiles);
            
            // Format special message for large result sets
            result.message = 'Your query would return approximately ' + estimatedCount + ' employees, which is too large to process all at once.\n\n';
            result.message += 'Here is a sample of the first ' + sampleProfiles.size() + ' matching employees.\n\n';
            result.message += 'To narrow your results, try adding more specific criteria such as:\n';
            result.message += '- A specific division (e.g., "in AMER")\n';
            result.message += '- A job family (e.g., "Engineers")\n';
            result.message += '- A location (e.g., "in India")\n';
            result.message += '- A reporting relationship (e.g., "who report to [Manager]")\n';
            
            result.queryUsed = query;
            result.hasMore = true;
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error processing large query: ' + e.getMessage();
        }
        
        return result;
    }
    
    // Build a standard query with pagination
    private String buildStandardQuery(Map<String, Object> queryData, Integer pageSize, Integer offset) {
        // Get fields from AHMayFieldConstants
        List<String> selectFields = AHMayFieldConstants.getFieldsForQuery(queryData);
        
        // Add Physical_Location__c if not already in the list to ensure it's always queried
        if (!selectFields.contains('Physical_Location__c')) {
            selectFields.add('Physical_Location__c');
        }
        
        // Build the base query
        String query = 'SELECT ' + String.join(selectFields, ', ') + 
                      ' FROM Learner_Profile__c WHERE Status__c = \'Active\'';
        
        // Process conditions using AHMayQueryUtils
        List<String> conditions = AHMayQueryUtils.buildWhereConditions(queryData);
        
        // Add the conditions to the query
        for (String condition : conditions) {
            if (!condition.startsWith('Status__c')) {
                query += ' AND ' + condition;
            }
        }
        
        query += ' ORDER BY Name ASC LIMIT ' + pageSize + ' OFFSET ' + offset;
        
        return query;
    }
    
    // Build a count query
    private String buildCountQuery(Map<String, Object> queryData) {
        String query = 'SELECT COUNT() FROM Learner_Profile__c WHERE Status__c = \'Active\'';
        
        // Process conditions using AHMayQueryUtils
        List<String> conditions = AHMayQueryUtils.buildWhereConditions(queryData);
        
        // Add the conditions to the query
        for (String condition : conditions) {
            if (!condition.startsWith('Status__c')) {
                query += ' AND ' + condition;
            }
        }
        
        return query;
    }
}