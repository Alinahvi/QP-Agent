/**
 * @description Formats SOQL query results into user-friendly messages and structured records.
 * @author Adam Hakey
 * @date Created Date
 */
public with sharing class Employee_ResultFormatter {
    /**
     * @description Converts a list of Learner_Profile__c SObjects into a list of wrapper records.
     * @param profiles The list of Learner_Profile__c records from the database.
     * @return List<Employee_EmployeeRecord> The formatted list of records for the result object.
     */
    public static List<Employee_EmployeeRecord> formatEmployeeRecords(List<SObject> profiles) {
        List<Employee_EmployeeRecord> formattedRecords = new List<Employee_EmployeeRecord>();
        for (SObject sobj : profiles) {
            Learner_Profile__c profile = (Learner_Profile__c) sobj;
            Employee_EmployeeRecord record = new Employee_EmployeeRecord();
            record.recordId = profile.Id;
            record.name = profile.Name;
            record.email = profile.Primary_Email__c;
            record.manager = profile.Manager__c;
            
            // CORRECTED: Assign the manager's email to the record.
            record.managerEmail = profile.Manager_Email__c;
            
            record.metadataMap = new Map<String, Object>{
                'jobFamily' => profile.Job_Family__c,
                'division' => profile.Division__c
            };
            formattedRecords.add(record);
        }
        return formattedRecords;
    }

    /**
     * @description Creates a standard success message with pagination details.
     */
    public static String formatSuccessMessage(Integer recordCount, Integer totalRecords, Integer pageNumber, Integer pageSize) {
        if (totalRecords == 0) {
            return 'No matching employees found. Please try different criteria.';
        }
        Integer totalPages = Math.max(1, (Integer) Math.ceil(totalRecords / (Double)pageSize));
        String message = 'Displaying ' + recordCount + ' of ' + totalRecords + ' employees (Page ' + pageNumber + ' of ' + totalPages + ').\n';

        if (pageNumber < totalPages) {
            message += '\nYou can say "show more" to see the next page.';
        }
        return message;
    }

    /**
     * @description Formats a detailed, multi-line message for a single employee's profile.
     * @param emp The Learner_Profile__c record to format.
     * @return String The formatted, user-friendly detail message.
     */
    public static String formatDetailMessage(Learner_Profile__c emp) {
        String message = 'Details for: ' + emp.Name + '\n\n' +
                         'Email: ' + getFieldValue(emp, 'Primary_Email__c') + '\n' +
                         'Manager: ' + getFieldValue(emp, 'Manager__c') + '\n' +
                         'Division: ' + getFieldValue(emp, 'Division__c') + '\n' +
                         'Job Family: ' + getFieldValue(emp, 'Job_Family__c') + '\n' +
                         'Location: ' + getFieldValue(emp, 'Employee_Location__c') + '\n' +
                         'FTE: ' + (emp.FTE__c ? 'Yes' : 'No') + '\n';
        return message;
    }

    /**
     * @description Formats a message to ask the user for clarification when multiple employees match a query.
     * @param name The ambiguous name the user searched for.
     * @param possibleMatches A list of the employees who were found.
     * @return String The formatted clarification message.
     */
    public static String formatAmbiguousNameMessage(String name, List<Learner_Profile__c> possibleMatches) {
        String message = 'Found multiple people matching "' + name + '". Please be more specific. Did you mean:\n\n';
        for (Learner_Profile__c match : possibleMatches) {
            message += '- ' + match.Name + ' (' + getFieldValue(match, 'Division__c') + ')\n';
        }
        return message;
    }
    
    /**
     * @description Formats the results of an aggregation query into a summary message.
     * @param groupFieldLabel The user-friendly label for the field that was grouped by.
     * @param groupCounts A map where the key is the group name and the value is the count of records.
     * @return String The formatted, user-friendly summary message.
     */
    public static String formatGroupedResultMessage(String groupFieldLabel, Map<String, Integer> groupCounts) {
        if (groupCounts == null || groupCounts.isEmpty()) {
            return 'Could not group the results.';
        }

        String message = 'Analysis of employees grouped by ' + groupFieldLabel + ':\n\n';
        List<String> sortedGroupKeys = new List<String>(groupCounts.keySet());
        sortedGroupKeys.sort();

        for (String key : sortedGroupKeys) {
            message += '- ' + key + ': ' + groupCounts.get(key) + ' employees\n';
        }
        return message;
    }

    /**
     * @description Helper to safely get a field value and return 'N/A' if it's null.
     */
    private static String getFieldValue(SObject obj, String fieldName) {
        Object value = obj.get(fieldName);
        return value != null ? String.valueOf(value) : 'N/A';
    }
}