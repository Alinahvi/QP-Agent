/**
 * @description Handles queries for an entire organizational reporting chain
 * (e.g., "Show me everyone who rolls up to John Smith").
 * @author Your Name/Team
 * @date Created Date
 */
public class Employee_HierarchicalQueryHandler implements Employee_QueryHandler {

    private static final Integer PAGE_SIZE = 20;

    public Employee_QueryResult handleQuery(Employee_QueryRequest request, Map<String, Object> queryData) {
        Employee_QueryResult result = new Employee_QueryResult();
        String managerName = (String) queryData.get('HIERARCHICAL_QUERY');

        if (String.isBlank(managerName)) {
            result.success = false;
            result.message = 'No manager was specified for the hierarchical query.';
            return result;
        }

        try {
            // 1. Find the specified manager's email, which is used as the key in the hierarchy fields.
            String managerEmail = findManagerEmail(managerName);
            if (String.isBlank(managerEmail)) {
                result.success = false;
                result.message = 'Could not find a manager named "' + managerName + '". Please check the spelling.';
                return result;
            }

            // 2. Build the list of OR conditions for the hierarchy fields.
            List<String> hierarchyConditions = new List<String>();
            for (Integer i = 1; i <= 10; i++) {
                String level = String.valueOf(i).leftPad(2, '0');
                hierarchyConditions.add('Emp_Mgt_Chain_Lvl_' + level + '_Nm__c = \'' + String.escapeSingleQuotes(managerEmail) + '\'');
            }
            String hierarchyWhereClause = ' (' + String.join(hierarchyConditions, ' OR ') + ') ';

            // 3. Build WHERE clause for any additional filters (e.g., "...in AMER division").
            List<String> additionalConditions = Employee_QueryUtils.buildWhereConditions(queryData);
            String additionalWhereClause = additionalConditions.isEmpty() ? '' : ' AND ' + String.join(additionalConditions, ' AND ');

            // 4. Combine all conditions.
            String finalWhereClause = ' WHERE Status__c = \'Active\' AND ' + hierarchyWhereClause + additionalWhereClause;

            // 5. Execute queries and format the result.
            String countQuery = 'SELECT COUNT() FROM Learner_Profile__c' + finalWhereClause;
            Integer totalRecords = Database.countQuery(countQuery);

            Integer pageNumber = request.pageNumber == null || request.pageNumber < 1 ? 1 : request.pageNumber;
            Integer offset = (pageNumber - 1) * PAGE_SIZE;

            String query = 'SELECT ' + String.join(Employee_FieldConstants.getHierarchicalFields(), ', ') +
                         ' FROM Learner_Profile__c' + finalWhereClause +
                         ' ORDER BY Name ASC LIMIT ' + PAGE_SIZE + ' OFFSET ' + offset;
            
            System.debug('Executing Hierarchical Query: ' + query);
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
            result.message = 'Error processing hierarchical query: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'Employee_HierarchicalQueryHandler Error: ' + e.getMessage() + ' Stack: ' + e.getStackTraceString());
        }

        return result;
    }

    /**
     * @description Finds a manager's email by searching first for an exact name match on the
     * Learner_Profile__c object, then a partial match, then finally the User object.
     * @param managerName The name of the manager to find.
     * @return String The manager's email address or an empty string if not found.
     */
    private String findManagerEmail(String managerName) {
        String searchName = String.escapeSingleQuotes(managerName);
        
        // Prioritize finding an exact match on Learner_Profile__c first.
        List<Learner_Profile__c> exactProfiles = [
            SELECT Primary_Email__c FROM Learner_Profile__c
            WHERE Name = :searchName AND Status__c = 'Active'
            LIMIT 1
        ];
        if (!exactProfiles.isEmpty()) {
            return exactProfiles[0].Primary_Email__c;
        }

        // If no exact match, try a partial match.
        List<Learner_Profile__c> partialProfiles = [
            SELECT Primary_Email__c FROM Learner_Profile__c
            WHERE Name LIKE :('%' + searchName + '%') AND Status__c = 'Active'
            LIMIT 1
        ];
        if (!partialProfiles.isEmpty()) {
            return partialProfiles[0].Primary_Email__c;
        }

        return ''; // Return empty if no match found
    }
}