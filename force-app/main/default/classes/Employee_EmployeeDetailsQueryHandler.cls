/**
 * @description Handles queries for all available details for a single, specific employee
 * (e.g., "Tell me about John Smith").
 * @author Your Name/Team
 * @date Created Date
 */
public class Employee_EmployeeDetailsQueryHandler implements Employee_QueryHandler {

    // The query will limit to 5 to prevent overly broad, ambiguous results.
    private static final Integer MAX_AMBIGUOUS_RESULTS = 5;

    public Employee_QueryResult handleQuery(Employee_QueryRequest request, Map<String, Object> queryData) {
        Employee_QueryResult result = new Employee_QueryResult();
        String employeeName = (String) queryData.get('EMPLOYEE_NAME');

        if (String.isBlank(employeeName)) {
            result.success = false;
            result.message = 'No employee name was specified for the details query.';
            return result;
        }

        try {
            String searchName = '%' + String.escapeSingleQuotes(employeeName) + '%';
            String query = 'SELECT ' + String.join(Employee_FieldConstants.getDetailFields(), ', ') +
                         ' FROM Learner_Profile__c' +
                         ' WHERE Name LIKE :searchName AND Status__c = \'Active\'' +
                         ' ORDER BY Name ASC LIMIT ' + MAX_AMBIGUOUS_RESULTS;
            
            System.debug('Executing Employee Details Query: ' + query);
            List<Learner_Profile__c> employees = Database.query(query);

            if (employees.isEmpty()) {
                result.success = false;
                result.message = 'Sorry, I could not find an employee named "' + employeeName + '".';
                return result;
            }

            // If more than one employee is found, ask the user for clarification.
            if (employees.size() > 1) {
                result.success = true;
                result.totalRecords = employees.size();
                result.records = Employee_ResultFormatter.formatEmployeeRecords(employees);
                result.message = Employee_ResultFormatter.formatAmbiguousNameMessage(employeeName, employees);
                return result;
            }

            // If exactly one employee is found, show their details.
            Learner_Profile__c employee = employees[0];
            result.success = true;
            result.totalRecords = 1;
            result.queryUsed = query;
            result.records = Employee_ResultFormatter.formatEmployeeRecords(employees);
            result.message = Employee_ResultFormatter.formatDetailMessage(employee);

        } catch (Exception e) {
            result.success = false;
            result.message = 'Error retrieving employee details: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'Employee_DetailsQueryHandler Error: ' + e.getMessage() + ' Stack: ' + e.getStackTraceString());
        }

        return result;
    }
}