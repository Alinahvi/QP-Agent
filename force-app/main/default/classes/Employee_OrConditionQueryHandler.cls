/**
 * @description Handles queries that contain one or more OR conditions
 * (e.g., "Show me employees in AMER or EMEA").
 * @author Your Name/Team
 * @date Created Date
 */
public class Employee_OrConditionQueryHandler implements Employee_QueryHandler {

    private static final Integer PAGE_SIZE = 20;

    public Employee_QueryResult handleQuery(Employee_QueryRequest request, Map<String, Object> queryData) {
        Employee_QueryResult result = new Employee_QueryResult();

        try {
            // The updated QueryUtils class now handles the OR logic automatically.
            List<String> conditions = Employee_QueryUtils.buildWhereConditions(queryData);
            conditions.add('Status__c = \'Active\'');
            String whereClause = ' WHERE ' + String.join(conditions, ' AND ');

            String countQuery = 'SELECT COUNT() FROM Learner_Profile__c' + whereClause;
            Integer totalRecords = Database.countQuery(countQuery);

            Integer pageNumber = request.pageNumber == null || request.pageNumber < 1 ? 1 : request.pageNumber;
            Integer offset = (pageNumber - 1) * PAGE_SIZE;

            String query = 'SELECT ' + String.join(Employee_FieldConstants.getStandardFields(), ', ') +
                         ' FROM Learner_Profile__c' + whereClause +
                         ' ORDER BY Name ASC LIMIT ' + PAGE_SIZE + ' OFFSET ' + offset;

            System.debug('Executing OR Condition Query: ' + query);
            List<Learner_Profile__c> profiles = Database.query(query);

            result.success = true;
            result.totalRecords = totalRecords;
            result.pageNumber = pageNumber;
            result.queryUsed = query;
            result.hasMore = (totalRecords > (offset + profiles.size()));
            result.records = Employee_ResultFormatter.formatEmployeeRecords(profiles);
            result.message = Employee_ResultFormatter.formatSuccessMessage(profiles.size(), totalRecords, pageNumber, PAGE_SIZE);

        } catch (Exception e) {
            result.success = false;
            result.message = 'Error processing OR condition query: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'Employee_OrConditionQueryHandler Error: ' + e.getMessage() + ' Stack: ' + e.getStackTraceString());
        }

        return result;
    }
}