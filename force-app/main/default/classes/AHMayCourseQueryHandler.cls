/**
 * Interface for handling course-related queries
 */
public interface AHMayCourseQueryHandler {
    /**
     * Process a course-related query request
     * @param request The query request object
     * @param queryData The structured data from the parsed query
     * @return AHMayQueryResult object with the query results
     */
    AHMayQueryResult handleQuery(AHMayQueryRequest request, Map<String, Object> queryData);
}