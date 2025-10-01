/**
 * @description Consensus content search handler for agent actions.
 * Provides a clean interface for searching Consensus content with intelligent routing.
 * @version 2.0 - Updated to use unified service
 */
public with sharing class ANAgentConsensusContentSearchHandler {

    /**
     * @description Request class for content search
     */
    public class ContentSearchRequest {
        @InvocableVariable(
            label='User Utterance'
            description='The complete user utterance to analyze and search'
            required=true
        )
        public String userUtterance;

        public ContentSearchRequest() {}

        public ContentSearchRequest(String userUtterance) {
            this.userUtterance = userUtterance;
        }
    }

    /**
     * @description Response class for content search
     */
    public class ContentSearchResponse {
        @InvocableVariable(
            label='Message'
            description='Composed message containing all search results and metadata'
        )
        public String message;

        public ContentSearchResponse() {
            this.message = '';
        }
    }

    /**
     * @description Main invocable method for content search
     * Routes to Consensus or ACT search based on user utterance
     * @param requests List of search requests
     * @return List of search responses with composed messages
     */
    @InvocableMethod(
        label='ANAgent Search Content (Consensus or ACT)'
        description='Intelligently routes content searches to Consensus or ACT based on user utterance. Returns unified results in a single composed message string.'
    )
    public static List<ContentSearchResponse> searchContent(List<ContentSearchRequest> requests) {
        List<ContentSearchResponse> responses = new List<ContentSearchResponse>();
        
        if (requests == null || requests.isEmpty()) {
            ContentSearchResponse errorResponse = new ContentSearchResponse();
            errorResponse.message = '**Content Search Error**\n\nNo search request provided.';
            responses.add(errorResponse);
            return responses;
        }

        for (ContentSearchRequest request : requests) {
            ContentSearchResponse response = new ContentSearchResponse();
            
            try {
                if (String.isBlank(request.userUtterance)) {
                    response.message = '**Content Search Error**\n\nUser utterance is required.';
                    responses.add(response);
                    continue;
                }

                // Use the new unified service for all searches with proper formatting
                ANAgentUnifiedContentSearchService.UnifiedSearchResult searchResult = 
                    ANAgentUnifiedContentSearchService.search(request.userUtterance);
                
                if (searchResult.success) {
                    response.message = searchResult.composedMessage;
                } else {
                    response.message = '**Content Search Error**\n\nSearch failed: ' + String.join(searchResult.errors, '; ');
                }

            } catch (Exception e) {
                response.message = '**Content Search Error**\n\nAn unexpected error occurred: ' + e.getMessage();
                System.debug('ANAgentConsensusContentSearchHandler error: ' + e.getMessage());
            }

            responses.add(response);
        }

        return responses;
    }
}
