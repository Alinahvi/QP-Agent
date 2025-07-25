/**
 * Default handler for unsupported course query types
 */
public with sharing class AHMayCourseUnsupportedQueryHandler implements AHMayCourseQueryHandler {
    
    /**
     * Handle unsupported course queries
     * @param request The query request object
     * @param queryData The structured data from the parsed query
     * @return AHMayQueryResult with error message
     */
    public AHMayQueryResult handleQuery(AHMayQueryRequest request, Map<String, Object> queryData) {
        AHMayQueryResult result = new AHMayQueryResult();
        result.success = false;
        result.message = 'This type of course query is not yet supported. Please try a different question format.';
        
        // Add query information to help with debugging
        result.metadataMap = new Map<String, Object>{
            'queryType' => 'UNSUPPORTED_COURSE_QUERY',
            'originalQuery' => request.userInput
        };
        
        return result;
    }
}