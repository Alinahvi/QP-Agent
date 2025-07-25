public class AHMayValidator {
    
    public static void validateQueryRequest(AHMayQueryRequest request) {
        if (request == null) {
            throw new AHMayQueryException('Query request cannot be null');
        }
        
        if (String.isBlank(request.userInput)) {
            throw new AHMayQueryException('User input is required');
        }
        
        if (request.pageNumber != null && request.pageNumber <= 0) {
            throw new AHMayQueryException('Page number must be greater than zero');
        }
    }
    
    public static void validateQueryData(Map<String, Object> queryData) {
        if (queryData == null) {
            throw new AHMayQueryException('Query data cannot be null');
        }
        
        // Validate specific query patterns if needed
        if (queryData.containsKey('EMPLOYEE_NAME') && String.isBlank((String)queryData.get('EMPLOYEE_NAME'))) {
            throw new AHMayQueryException('Employee name cannot be empty');
        }
        
        if (queryData.containsKey('DIRECT_REPORTS') && String.isBlank((String)queryData.get('DIRECT_REPORTS'))) {
            throw new AHMayQueryException('Manager name cannot be empty');
        }
        
        if (queryData.containsKey('HIERARCHICAL_QUERY') && String.isBlank((String)queryData.get('HIERARCHICAL_QUERY'))) {
            throw new AHMayQueryException('Manager name for hierarchical query cannot be empty');
        }
    }
    
    // Add additional validation methods as needed
}