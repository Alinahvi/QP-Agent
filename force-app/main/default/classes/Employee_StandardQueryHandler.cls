public class Employee_StandardQueryHandler implements Employee_QueryHandler {

    @TestVisible
    private static Integer MAX_QUERY_ROWS = 10000;
    private static final Integer PAGE_SIZE = 20;

    public Employee_QueryResult handleQuery(Employee_QueryRequest request, Map<String, Object> queryData) {
        Employee_QueryResult result = new Employee_QueryResult();

        try {
            List<String> conditions = Employee_QueryUtils.buildWhereConditions(queryData);
            conditions.add('Status__c = \'Active\'');
            String whereClause = ' WHERE ' + String.join(conditions, ' AND ');

            String countQuery = 'SELECT COUNT() FROM Learner_Profile__c' + whereClause;
            Integer totalRecords = Database.countQuery(countQuery);

            if (totalRecords > MAX_QUERY_ROWS) {
                return handleLargeResultSet(totalRecords);
            }

            Integer pageNumber = request.pageNumber == null || request.pageNumber < 1 ? 1 : request.pageNumber;
            Integer offset = (pageNumber - 1) * PAGE_SIZE;

            String query = 'SELECT ' + String.join(Employee_FieldConstants.getStandardFields(), ', ') +
                         ' FROM Learner_Profile__c' + whereClause +
                         ' ORDER BY Name ASC LIMIT ' + PAGE_SIZE + ' OFFSET ' + offset;

            System.debug('Executing Standard Query: ' + query);
            List<Learner_Profile__c> profiles = Database.query(query);

            result.success = true;
            result.totalRecords = totalRecords;
            result.pageNumber = pageNumber;
            result.queryUsed = query;
            result.hasMore = (totalRecords > (offset + profiles.size()));
            result.records = Employee_ResultFormatter.formatEmployeeRecords(profiles);
            result.message = Employee_ResultFormatter.formatSuccessMessage(profiles.size(), totalRecords, pageNumber, PAGE_SIZE);

            if(request.sessionId != null) {
                Employee_SessionContext.storeResultSummary(request.sessionId, totalRecords, pageNumber, result.hasMore);
            }

        } catch (Exception e) {
            result.success = false;
            result.message = 'Error processing standard query: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'Employee_StandardQueryHandler Error: ' + e.getMessage() + ' Stack: ' + e.getStackTraceString());
        }

        return result;
    }

    private Employee_QueryResult handleLargeResultSet(Integer estimatedCount) {
        Employee_QueryResult result = new Employee_QueryResult();
        result.success = true;
        result.totalRecords = estimatedCount;
        result.message = 'Your query would return approximately ' + estimatedCount + ' employees, which is too large to display at once.\n\n' +
                         'Please add more specific criteria to narrow your results, such as:\n' +
                         '- A specific Division (e.g., "in AMER")\n' +
                         '- A specific Job Family (e.g., "who are engineers")';
        return result;
    }
}