public class AHMayQueryHandlerFactory {
    // Query handler types for better type safety
    public enum QueryHandlerType {
        STANDARD,
        HIERARCHICAL,
        DIRECT_REPORTS,
        EMPLOYEE_DETAILS,
        METADATA,
        AGGREGATION,
        OR_CONDITION,
        COMPOUND_QUERY,
        UNSUPPORTED
    }
    
    // Get the appropriate handler based on query data
    public static AHMayQueryHandler getHandler(Map<String, Object> queryData) {
        // Debug incoming query data
        System.debug('AHMayQueryHandlerFactory - Selecting handler for: ' + JSON.serialize(queryData));
        
        // Enhanced intent detection based on original query text
        if (queryData.containsKey('ORIGINAL_QUERY')) {
            String originalQuery = String.valueOf(queryData.get('ORIGINAL_QUERY')).toLowerCase();
            
            // Check for hierarchical intent first
            if (containsHierarchicalPhrases(originalQuery) && 
                queryData.containsKey('DIRECT_REPORTS')) {
                System.debug('Redirecting to HierarchicalQueryHandler based on phrase detection');
                // Transfer intent from DIRECT_REPORTS to HIERARCHICAL_QUERY
                queryData.put('HIERARCHICAL_QUERY', queryData.get('DIRECT_REPORTS'));
                queryData.remove('DIRECT_REPORTS');
            }
        }
        
        // Check for compound query conditions first
        if (isCompoundQuery(queryData)) {
            System.debug('Detected compound query - using CompoundQueryHandler');
            return new AHMayCompoundQueryHandler();
        }
        
        QueryHandlerType handlerType = determineHandlerType(queryData);
        System.debug('Selected handler type: ' + getHandlerName(handlerType));
        
        switch on handlerType {
            when STANDARD {
                return new AHMayStandardQueryHandler();
            }
            when HIERARCHICAL {
                return new AHMayHierarchicalQueryHandler();
            }
            when DIRECT_REPORTS {
                return new AHMayDirectReportsQueryHandler();
            }
            when EMPLOYEE_DETAILS {
                return new AHMayEmployeeDetailsQueryHandler();
            }
            when METADATA {
                return new AHMayMetadataQueryHandler();
            }
            when AGGREGATION {
                return new AHMayAggregationHandler();
            }
            when OR_CONDITION {
                return new AHMayOrConditionQueryHandler();
            }
            when COMPOUND_QUERY {
                return new AHMayCompoundQueryHandler();
            }
            when UNSUPPORTED {
                return new AHMayUnsupportedQueryHandler();
            }
            when else {
                // Default to standard handler if we can't determine the type
                return new AHMayStandardQueryHandler();
            }
        }
    }
    
    // Check if the query contains hierarchical phrases
    private static Boolean containsHierarchicalPhrases(String query) {
        if (String.isBlank(query)) {
            return false;
        }
        
        List<String> hierarchicalPhrases = new List<String>{
            'roll up', 'rolls up', 'rolling up',
            'organization', 'org', 'organizational', 
            'entire team', 'all employees under', 'all employees who report',
            'report up', 'reporting up', 'reports up',
            'management chain', 'chain of command',
            'everyone under', 'everyone who reports',
            'hierarchy', 'everyone in', 'all staff in',
            'rolls up to'
        };
        
        for (String phrase : hierarchicalPhrases) {
            if (query.contains(phrase)) {
                System.debug('Found hierarchical phrase in query: ' + phrase);
                return true;
            }
        }
        
        return false;
    }
    
    // New method to detect compound queries
    private static Boolean isCompoundQuery(Map<String, Object> queryData) {
        // A compound query has multiple different intent types
        
        // Count special intent keys
        Integer intentCount = 0;
        
        if (queryData.containsKey('DIRECT_REPORTS') || 
            queryData.containsKey('DIRECT_REPORTS_OR')) {
            intentCount++;
        }
        
        if (queryData.containsKey('HIERARCHICAL_QUERY') || 
            queryData.containsKey('HIERARCHICAL_QUERY_OR')) {
            intentCount++;
        }
        
        if (queryData.containsKey('EMPLOYEE_DETAILS')) {
            intentCount++;
        }
        
        if (queryData.containsKey('AGGREGATION') || 
            queryData.containsKey('GROUP_BY_FIELD') || 
            queryData.containsKey('GROUP_BY_FIELDS')) {
            intentCount++;
        }
        
        // If we have more than one core intent, it's a compound query
        return intentCount > 1;
    }
    
    // Determine the handler type based on query data
    private static QueryHandlerType determineHandlerType(Map<String, Object> queryData) {
        // Handle null queryData case
        if (queryData == null || queryData.isEmpty()) {
            return QueryHandlerType.STANDARD;
        }
        
        // Check for compound query first
        if (isCompoundQuery(queryData)) {
            return QueryHandlerType.COMPOUND_QUERY;
        }

        // Check for aggregation or analysis queries
        if ((queryData.containsKey('AGGREGATION') && 
             queryData.get('AGGREGATION') != null && 
             (Boolean)queryData.get('AGGREGATION')) ||
            (queryData.containsKey('ANALYSIS') && 
             queryData.get('ANALYSIS') != null && 
             (Boolean)queryData.get('ANALYSIS')) ||
            queryData.containsKey('GROUP_BY_FIELD') ||
            queryData.containsKey('GROUP_BY_FIELDS')) {
            
            return QueryHandlerType.AGGREGATION;
        }
        
        // Check for unsupported query
        if (queryData.containsKey('UNSUPPORTED_QUERY')) {
            return QueryHandlerType.UNSUPPORTED;
        }
        
        // Check for metadata request
        if (queryData.containsKey('METADATA_REQUEST')) {
            return QueryHandlerType.METADATA;
        }
        
        // Check for employee details
        if (queryData.containsKey('EMPLOYEE_DETAILS')) {
            return QueryHandlerType.EMPLOYEE_DETAILS;
        }
        
        // Check for hierarchical query
        if (queryData.containsKey('HIERARCHICAL_QUERY') || queryData.containsKey('HIERARCHICAL_QUERY_OR')) {
            return QueryHandlerType.HIERARCHICAL;
        }
        
        // Check for direct reports
        if (queryData.containsKey('DIRECT_REPORTS') || queryData.containsKey('DIRECT_REPORTS_OR')) {
            return QueryHandlerType.DIRECT_REPORTS;
        }
        
        // Check for OR conditions
        if (containsOrConditions(queryData)) {
            return QueryHandlerType.OR_CONDITION;
        }
        
        // Default to standard handler
        return QueryHandlerType.STANDARD;
    }
    
    // Check if query data contains OR conditions
    private static Boolean containsOrConditions(Map<String, Object> queryData) {
        for (String field : queryData.keySet()) {
            if (field.endsWith('_OR')) {
                return true;
            }
        }
        return false;
    }
    
    // Get handler name for logging and debugging
    public static String getHandlerName(QueryHandlerType handlerType) {
        switch on handlerType {
            when STANDARD {
                return 'Standard';
            }
            when HIERARCHICAL {
                return 'Hierarchical';
            }
            when DIRECT_REPORTS {
                return 'DirectReports';
            }
            when EMPLOYEE_DETAILS {
                return 'EmployeeDetails';
            }
            when METADATA {
                return 'Metadata';
            }
            when AGGREGATION {
                return 'Aggregation';
            }
            when OR_CONDITION {
                return 'OrCondition';
            }
            when COMPOUND_QUERY {
                return 'CompoundQuery';
            }
            when UNSUPPORTED {
                return 'Unsupported';
            }
            when else {
                return 'Unknown';
            }
        }
    }
}