/**
 * @description Provides utility methods for building dynamic SOQL queries from parsed data.
 * @author Your Name/Team
 * @date Created Date
 */
public with sharing class Employee_QueryUtils {
    /**
     * @description Builds a list of SOQL WHERE conditions from a query map.
     * @param queryData The map of parsed query parameters.
     * @return List<String> A list of individual WHERE clause conditions.
     */
    public static List<String> buildWhereConditions(Map<String, Object> queryData) {
        List<String> conditions = new List<String>();

        for (String field : queryData.keySet()) {
            Object value = queryData.get(field);
            if (value == null) continue;

            // Handle special system keys that are not filter fields
            if (field.equalsIgnoreCase('MAINTAIN_PREVIOUS_CONTEXT') || field.equalsIgnoreCase('NEXT_PAGE') ||
                field.equalsIgnoreCase('AGGREGATION') || field.startsWith('GROUP_BY_') || field.startsWith('METADATA_') ||
                field.startsWith('EMPLOYEE_') || field.startsWith('DIRECT_REPORTS') || field.startsWith('HIERARCHICAL_')) {
                continue;
            }

            // Handle LIKE operator for location search
            if (field.endsWithIgnoreCase('_LIKE')) {
                String baseField = field.removeEndIgnoreCase('_LIKE');
                conditions.add(baseField + ' LIKE \'' + String.escapeSingleQuotes(String.valueOf(value)) + '\'');
            }
            // NEW: Handle OR conditions, expecting a List of values
            else if (field.endsWithIgnoreCase('_OR')) {
                if (value instanceof List<Object>) {
                    String baseField = field.removeEndIgnoreCase('_OR');
                    List<String> orSubConditions = new List<String>();
                    for (Object orValue : (List<Object>) value) {
                        orSubConditions.add(baseField + ' = \'' + String.escapeSingleQuotes(String.valueOf(orValue)) + '\'');
                    }
                    if (!orSubConditions.isEmpty()) {
                        conditions.add('(' + String.join(orSubConditions, ' OR ') + ')');
                    }
                }
            }
            // Handle standard field conditions
            else if(field.endsWith('__c')) {
                if (value instanceof String) {
                    conditions.add(field + ' = \'' + String.escapeSingleQuotes(String.valueOf(value)) + '\'');
                } else if (value instanceof Boolean || value instanceof Integer || value instanceof Decimal) {
                    conditions.add(field + ' = ' + value);
                }
            }
        }
        return conditions;
    }
}