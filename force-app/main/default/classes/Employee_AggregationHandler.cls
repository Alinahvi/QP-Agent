/**
 * @description Handles aggregation queries that group the results of a previous query
 * (e.g., "group them by division").
 * @author Your Name/Team
 * @date Created Date
 */
public class Employee_AggregationHandler implements Employee_QueryHandler {

    private static final Integer MAX_AGGREGATION_RECORDS = 5000;

    public Employee_QueryResult handleQuery(Employee_QueryRequest request, Map<String, Object> queryData) {
        Employee_QueryResult result = new Employee_QueryResult();
        String groupByField = (String) queryData.get('GROUP_BY_FIELD');

        // 1. Aggregation requires a previous query context.
        if (String.isBlank(request.sessionId) || !Employee_SessionContext.hasSegmentedEmployees(request.sessionId)) {
            result.success = false;
            result.message = 'Please run a query to find a set of employees first, then ask to group them.';
            return result;
        }
        
        // 2. Get the context from the previous query.
        Map<String, Object> previousContext = Employee_SessionContext.getQueryContext(request.sessionId);
        Map<String, Object> previousResultSummary = Employee_SessionContext.getResultSummary(request.sessionId);
        Integer totalRecords = (Integer) previousResultSummary.get('totalRecords');

        if (totalRecords > MAX_AGGREGATION_RECORDS) {
            result.success = false;
            result.message = 'The result set of ' + totalRecords + ' employees is too large to aggregate. Please narrow your initial query.';
            return result;
        }

        try {
            // 3. Fetch the FULL result set from the previous query by re-running it without pagination.
            List<Learner_Profile__c> recordsToProcess = fetchAllRecords(previousContext);

            if (recordsToProcess.isEmpty()) {
                result.success = false;
                result.message = 'There were no records in the previous result set to group.';
                return result;
            }

            // 4. Perform the grouping in Apex.
            Map<String, Integer> groupCounts = new Map<String, Integer>();
            for (Learner_Profile__c record : recordsToProcess) {
                String key = String.valueOf(record.get(groupByField));
                if (String.isBlank(key)) {
                    key = '(Not Specified)';
                }
                groupCounts.put(key, groupCounts.containsKey(key) ? groupCounts.get(key) + 1 : 1);
            }
            
            // 5. Format the results for the user.
            result.success = true;
            result.totalRecords = recordsToProcess.size();
            // Pass a user-friendly label for the group field
            String fieldLabel = groupByField.remove('__c').replace('_', ' ');
            result.message = Employee_ResultFormatter.formatGroupedResultMessage(fieldLabel, groupCounts);

        } catch (Exception e) {
            result.success = false;
            result.message = 'An error occurred while grouping the results: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'Employee_AggregationHandler Error: ' + e.getMessage() + ' Stack: ' + e.getStackTraceString());
        }

        return result;
    }

    /**
     * @description Re-runs the previous query without pagination to get the full dataset for aggregation.
     * @param previousQueryData The context map from the previous query.
     * @return List<Learner_Profile__c> The full list of matching records.
     */
    private List<Learner_Profile__c> fetchAllRecords(Map<String, Object> previousQueryData) {
        List<String> conditions = Employee_QueryUtils.buildWhereConditions(previousQueryData);
        conditions.add('Status__c = \'Active\'');
        String whereClause = ' WHERE ' + String.join(conditions, ' AND ');

        // Note: For simplicity, this re-fetcher only supports standard queries.
        // A more complex version would check for HIERARCHICAL_QUERY, etc., like the original.
        if (previousQueryData.containsKey('HIERARCHICAL_QUERY') || previousQueryData.containsKey('DIRECT_REPORTS')) {
            throw new AuraHandledException('Aggregation on hierarchical results is not yet supported in this version.');
        }

        String query = 'SELECT ' + String.join(Employee_FieldConstants.getStandardFields(), ', ') +
                     ' FROM Learner_Profile__c' + whereClause +
                     ' ORDER BY Name ASC LIMIT ' + MAX_AGGREGATION_RECORDS;

        return Database.query(query);
    }
}