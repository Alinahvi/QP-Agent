/**
 * @description Agent-safe content search handler V3 (FR-style best practices)
 * DUMB ROUTER - contains NO business logic
 * Maps input → calls service → returns single message String
 * @version 3.0
 */
public with sharing class ANAgentContentSearchHandlerV3 {

    /**
     * @description Request DTO for invocable method
     */
    public class ContentSearchRequest {
        @InvocableVariable(label='Search Term' description='The term to search for' required=true)
        public String searchTerm;
        
        @InvocableVariable(label='Content Type' description='Optional filter: Course, Asset, or Curriculum')
        public String contentType;
        
        @InvocableVariable(label='Search Mode' description='AUTO, ACT, CONSENSUS, BOTH')
        public String searchMode;
        
        @InvocableVariable(label='User Utterance' description='Complete user utterance for routing')
        public String userUtterance;
    }

    /**
     * @description Response DTO - ONLY ONE VARIABLE (agent boundary requirement)
     */
    public class ContentSearchResponse {
        @InvocableVariable(label='Message' description='Formatted search result message')
        public String message;
    }

    /**
     * @description Invocable method - dumb router only
     * NO business logic, NO filtering, NO formatting
     * Just maps input → service → output
     */
    @InvocableMethod(
        label='ANAgent Search Content V3'
        description='Agent-safe content search with FR-style best practices (single message output)'
    )
    public static List<ContentSearchResponse> searchContent(List<ContentSearchRequest> requests) {
        List<ContentSearchResponse> responses = new List<ContentSearchResponse>();

        for (ContentSearchRequest request : requests) {
            ContentSearchResponse response = new ContentSearchResponse();
            
            try {
                // Call service (all logic lives there)
                response.message = ANAgentContentSearchServiceV3.search(
                    request.searchTerm,
                    request.contentType,
                    request.searchMode,
                    request.userUtterance
                );
                
            } catch (Exception e) {
                // Minimal error handling - service handles most errors
                response.message = '## ERROR\n\n' +
                                 '**Message**: Handler exception: ' + e.getMessage() + '\n\n' +
                                 'Please contact support if this issue persists.\n';
                System.debug('Handler error: ' + e.getMessage());
                System.debug('Stack trace: ' + e.getStackTraceString());
            }

            responses.add(response);
        }

        return responses;
    }
}

