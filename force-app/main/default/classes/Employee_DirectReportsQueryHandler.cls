/**
 * @description Handles queries for a manager's immediate direct reports
 * (e.g., "Who reports to Jane Doe?").
 * @author Your Name/Team
 * @date Created Date
 */
public class Employee_DirectReportsQueryHandler implements Employee_QueryHandler {

    private static final Integer PAGE_SIZE = 20;

    public Employee_QueryResult handleQuery(Employee_QueryRequest request, Map<String, Object> queryData) {
        Employee_QueryResult result = new Employee_QueryResult();
        String managerName = (String) queryData.get('DIRECT_REPORTS');

        if (String.isBlank(managerName)) {
            result.success = false;
            result.message = 'No manager was specified for the direct reports query.';
            return result;
        }

        try {
            // 1. Build the WHERE clause for any additional filters.
            List<String> additionalConditions = Employee_QueryUtils.buildWhereConditions(queryData);
            String additionalWhereClause = additionalConditions.isEmpty() ? '' : ' AND ' + String.join(additionalConditions, ' AND ');

            // 2. Build the primary WHERE clause to find reports by manager name OR email.
            // This is more robust than relying on just one field.
            String managerEmail = findManagerEmail(managerName);
            String managerWhereClause = ' (Manager__c = \'' + String.escapeSingleQuotes(managerName) + '\'';
            if(String.isNotBlank(managerEmail)) {
                managerWhereClause += ' OR Manager_Email__c = \'' + String.escapeSingleQuotes(managerEmail) + '\') ';
            } else {
                managerWhereClause += ') ';
            }

            // 3. Combine all conditions.
            String finalWhereClause = ' WHERE Status__c = \'Active\' AND ' + managerWhereClause + additionalWhereClause;

            // 4. Execute queries and format the result.
            String countQuery = 'SELECT COUNT() FROM Learner_Profile__c' + finalWhereClause;
            Integer totalRecords = Database.countQuery(countQuery);

            Integer pageNumber = request.pageNumber == null || request.pageNumber < 1 ? 1 : request.pageNumber;
            Integer offset = (pageNumber - 1) * PAGE_SIZE;

            String query = 'SELECT ' + String.join(Employee_FieldConstants.getStandardFields(), ', ') +
                         ' FROM Learner_Profile__c' + finalWhereClause +
                         ' ORDER BY Name ASC LIMIT ' + PAGE_SIZE + ' OFFSET ' + offset;
            
            System.debug('Executing Direct Reports Query: ' + query);
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
            result.message = 'Error processing direct reports query: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'Employee_DirectReportsQueryHandler Error: ' + e.getMessage() + ' Stack: ' + e.getStackTraceString());
        }

        return result;
    }

    /**
     * @description Finds a manager's email by searching the Learner_Profile__c object.
     * @param managerName The name of the manager to find.
     * @return String The manager's email address or an empty string if not found.
     */
    private String findManagerEmail(String managerName) {
        String searchName = String.escapeSingleQuotes(managerName);
        List<Learner_Profile__c> profiles = [
            SELECT Primary_Email__c FROM Learner_Profile__c
            WHERE Name = :searchName AND Status__c = 'Active'
            LIMIT 1
        ];
        return profiles.isEmpty() ? '' : profiles[0].Primary_Email__c;
    }
}