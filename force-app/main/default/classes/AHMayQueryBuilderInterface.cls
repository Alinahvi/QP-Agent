/**
 * Interface for all query builders
 * Implements the Strategy pattern for flexible query construction
 */
public interface AHMayQueryBuilderInterface {
    /**
     * Build a complete SOQL query for execution
     * @param queryData Map of query parameters and filters
     * @param pageSize Number of records per page
     * @param offset Starting offset for pagination
     * @return SOQL query string
     */
    String buildQuery(Map<String, Object> queryData, Integer pageSize, Integer offset);
    
    /**
     * Build a COUNT query to get total record count
     * @param queryData Map of query parameters and filters
     * @return SOQL COUNT query string
     */
    String buildCountQuery(Map<String, Object> queryData);
    
    /**
     * Get list of fields required for this query
     * @param queryData Map of query parameters and filters
     * @return List of field API names to include in SELECT clause
     */
    List<String> getRequiredFields(Map<String, Object> queryData);
    
    /**
     * Get map of query conditions
     * @param queryData Map of query parameters and filters
     * @return List of condition strings to include in WHERE clause
     */
    List<String> getQueryConditions(Map<String, Object> queryData);
}