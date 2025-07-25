/**
 * @description Interface for all specialized query handlers. Each handler is responsible
 * for processing a specific type of query (e.g., standard, hierarchical, metadata).
 * @author Your Name/Team
 * @date Created Date
 */
public interface Employee_QueryHandler {
    /**
     * @description Handles the query execution based on the parsed query data.
     * @param request The original query request object.
     * @param queryData The map of parsed query parameters from the LLM.
     * @return Employee_QueryResult The result of the query execution.
     */
    Employee_QueryResult handleQuery(Employee_QueryRequest request, Map<String, Object> queryData);
}