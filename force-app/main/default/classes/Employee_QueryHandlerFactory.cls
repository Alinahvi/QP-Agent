/**
 * @description Factory class to select and instantiate the correct query handler
 * based on the structured query data parsed from the user's input.
 * @author Your Name/Team
 * @date Created Date
 */
public with sharing class Employee_QueryHandlerFactory {

    /**
     * @description Inspects the query data and returns the appropriate handler instance.
     * @param queryData The map of parsed query parameters.
     * @return Employee_QueryHandler An instance of a class that implements the handler interface.
     */
    public static Employee_QueryHandler getHandler(Map<String, Object> queryData) {
        if (queryData == null || queryData.isEmpty()) {
            return new Employee_StandardQueryHandler(); // 
        }

        // The order of checks is important, from most specific to most general.
        if (queryData.containsKey('METADATA_REQUEST')) { // 
            return new Employee_MetadataQueryHandler(); // 
        }
        if (queryData.containsKey('EMPLOYEE_DETAILS')) { // 
            return new Employee_EmployeeDetailsQueryHandler(); // 
        }
        if (queryData.containsKey('HIERARCHICAL_QUERY')) { // 
            return new Employee_HierarchicalQueryHandler(); // 
        }
        if (queryData.containsKey('DIRECT_REPORTS')) { // 
            return new Employee_DirectReportsQueryHandler(); // 
        }
        if (isAggregationQuery(queryData)) { // 
            return new Employee_AggregationHandler(); // 
        }
        if (containsOrConditions(queryData)) { // 
            return new Employee_OrConditionQueryHandler(); // 
        }

        // Default to the standard handler for attribute-based queries. 
        return new Employee_StandardQueryHandler();
    }

    /**
     * @description Helper to check for aggregation-related keys.
     */
    private static Boolean isAggregationQuery(Map<String, Object> queryData) {
        return queryData.containsKey('AGGREGATION') ||
               queryData.containsKey('GROUP_BY_FIELD') ||
               queryData.containsKey('GROUP_BY_FIELDS');
    }

    /**
     * @description Helper to check for fields that use OR logic.
     */
    private static Boolean containsOrConditions(Map<String, Object> queryData) {
        for (String key : queryData.keySet()) {
            if (key.endsWith('_OR')) {
                return true; // 
            }
        }
        return false;
    }
}