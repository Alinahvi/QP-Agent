/**
 * @description Handles queries about the data model itself, such as available fields or
 * the unique values for a specific field.
 * @author Your Name/Team
 * @date Created Date
 */
public class Employee_MetadataQueryHandler implements Employee_QueryHandler {

    @TestVisible
    private static Integer PAGE_SIZE = 20;

    public Employee_QueryResult handleQuery(Employee_QueryRequest request, Map<String, Object> queryData) {
        String requestType = (String) queryData.get('METADATA_REQUEST');

        if (String.isBlank(requestType)) {
            return createDefaultResponse();
        }

        try {
            if (requestType == 'AVAILABLE_FIELDS') {
                return getAvailableFields();
            } else if (requestType == 'FIELD_VALUES') {
                String fieldName = (String) queryData.get('FIELD_NAME');
                return getFieldValues(fieldName, request.pageNumber);
            } else if (requestType == 'FIELD_VALUES_COUNT') {
                String fieldName = (String) queryData.get('FIELD_NAME');
                return getFieldValuesCount(fieldName);
            } else {
                return createDefaultResponse();
            }
        } catch (Exception e) {
            Employee_QueryResult errorResult = new Employee_QueryResult();
            errorResult.success = false;
            errorResult.message = 'Error processing metadata request: ' + e.getMessage();
            System.debug(LoggingLevel.ERROR, 'Employee_MetadataQueryHandler Error: ' + e.getMessage());
            return errorResult;
        }
    }

    /**
     * @description Provides a list of queryable fields, grouped by category.
     */
    private Employee_QueryResult getAvailableFields() {
        Employee_QueryResult result = new Employee_QueryResult();
        result.success = true;
        // This message can be customized with more examples.
        result.message = 'Here are the employee data fields you can query:\n\n' +
                         '**General Information**\n- Employee Name\n- Email\n\n' +
                         '**Job**\n- Job Family\n- FTE\n- Commissionable\n- Hire Date\n\n' +
                         '**Organization**\n- Manager\n- Division\n- Business Unit\n- Location\n- Country';
        return result;
    }

    /**
     * @description Gets the unique values for a given field, with pagination.
     */
    private Employee_QueryResult getFieldValues(String fieldName, Integer pageNumber) {
        if (String.isBlank(fieldName)) {
            throw new AuraHandledException('No field name specified for field values request.');
        }

        Employee_QueryResult result = new Employee_QueryResult();
        pageNumber = pageNumber == null || pageNumber < 1 ? 1 : pageNumber;
        Integer offset = (pageNumber - 1) * PAGE_SIZE;

        // Use an Aggregate Query to get unique, non-null values.
        String countQuery = 'SELECT COUNT_DISTINCT(' + fieldName + ') FROM Learner_Profile__c WHERE ' + fieldName + ' != null';
        Integer totalRecords = Database.countQuery(countQuery);
        
        String query = 'SELECT ' + fieldName + ' FROM Learner_Profile__c WHERE ' + fieldName + ' != null GROUP BY ' + fieldName + ' ORDER BY ' + fieldName + ' ASC LIMIT ' + PAGE_SIZE + ' OFFSET ' + offset;
        
        List<AggregateResult> results = Database.query(query);
        List<String> values = new List<String>();
        for (AggregateResult ar : results) {
            values.add(String.valueOf(ar.get(fieldName)));
        }

        result.success = true;
        result.totalRecords = totalRecords;
        result.pageNumber = pageNumber;
        result.hasMore = totalRecords > (offset + values.size());
        result.message = 'Displaying ' + values.size() + ' of ' + totalRecords + ' unique values for ' + fieldName.remove('__c') + ':\n\n- ' +
                         String.join(values, '\n- ');

        if(result.hasMore) {
            result.message += '\n\n(Say "show more" to see the next page.)';
        }

        return result;
    }

    /**
     * @description Gets the count of unique values for a given field.
     */
    private Employee_QueryResult getFieldValuesCount(String fieldName) {
        if (String.isBlank(fieldName)) {
            throw new AuraHandledException('No field name specified for count request.');
        }

        String query = 'SELECT COUNT_DISTINCT(' + fieldName + ') FROM Learner_Profile__c WHERE ' + fieldName + ' != null';
        Integer uniqueCount = Database.countQuery(query);

        Employee_QueryResult result = new Employee_QueryResult();
        result.success = true;
        result.totalRecords = uniqueCount;
        result.message = 'There are ' + uniqueCount + ' unique values for the ' + fieldName.remove('__c') + ' field.';
        return result;
    }

    /**
     * @description Provides a default help message.
     */
    private Employee_QueryResult createDefaultResponse() {
        Employee_QueryResult result = new Employee_QueryResult();
        result.success = true;
        result.message = 'You can ask me to "show available fields" or "list all divisions".';
        return result;
    }
}