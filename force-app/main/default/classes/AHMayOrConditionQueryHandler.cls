public class AHMayOrConditionQueryHandler implements AHMayQueryHandler {
    
    public AHMayQueryResult handleQuery(AHMayQueryRequest request, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        
        try {
            // Debug: Check input data
            System.debug('OR Query Data: ' + JSON.serialize(queryData));
            
            // Process field conditions using AHMayQueryUtils
            Map<String, Object> fieldConditions = AHMayQueryUtils.extractQueryFields(queryData);
            
            // Build the complete query
            Integer pageSize = 20;
            Integer offset = (request.pageNumber != null ? request.pageNumber - 1 : 0) * pageSize;
            
            // Get fields from AHMayFieldConstants
            List<String> selectFields = AHMayFieldConstants.getFieldsForQuery(queryData);
            
            // Build conditions using AHMayQueryUtils
            List<String> conditions = AHMayQueryUtils.buildWhereConditions(fieldConditions);
            
            // Always ensure Status__c = 'Active' is included
            Boolean hasStatusCondition = false;
            for (String condition : conditions) {
                if (condition.startsWith('Status__c')) {
                    hasStatusCondition = true;
                    break;
                }
            }
            if (!hasStatusCondition) {
                conditions.add(0, 'Status__c = \'Active\'');
            }
            
            String query = 'SELECT ' + String.join(selectFields, ', ') + 
                         ' FROM Learner_Profile__c WHERE ' + 
                         String.join(conditions, ' AND ');
            
            // Apply pagination
            query += ' ORDER BY Name ASC LIMIT ' + pageSize + ' OFFSET ' + offset;
            
            // Execute the query
            List<Learner_Profile__c> employees = Database.query(query);
            
            // Count query
            String countQuery = 'SELECT COUNT() FROM Learner_Profile__c WHERE ' + 
                             String.join(conditions, ' AND ');
            
            Integer totalCount = Database.countQuery(countQuery);
            
            // Format results
            result.success = true;
            result.totalRecords = totalCount;
            result.pageNumber = request.pageNumber != null ? request.pageNumber : 1;
            result.records = AHMayResultFormatter.formatEmployeeRecords(employees);
            result.message = AHMayResultFormatter.formatSuccessMessage(employees.size(), totalCount, result.pageNumber);
            result.queryUsed = query;
            result.hasMore = (totalCount > offset + pageSize);
            result.parsedQuery = 'Query with OR conditions';
            
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error executing query: ' + e.getMessage() + 
                           ' (Line: ' + e.getLineNumber() + ')';
            System.debug('OR Query Error: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
        }
        
        return result;
    }
}