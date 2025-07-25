/**
 * @description Simplified content search handler for agent actions.
 * Provides a clean interface for searching content across multiple objects.
 * @version 2.0
 */
public with sharing class ANAgentContentSearchHandlerV2 {

    /**
     * @description Request class for content search
     */
    public class ContentSearchRequest {
        @InvocableVariable(
            label='Search Term'
            description='The term to search for in content names and descriptions'
            required=true
        )
        public String searchTerm;

        @InvocableVariable(
            label='Content Type'
            description='Optional filter for content type: Course, Asset, or Curriculum. Leave blank to search all types.'
        )
        public String contentType;

        public ContentSearchRequest() {}

        public ContentSearchRequest(String searchTerm, String contentType) {
            this.searchTerm = searchTerm;
            this.contentType = contentType;
        }
    }

    /**
     * @description Response class for content search
     */
    public class ContentSearchResponse {
        @InvocableVariable(
            label='Success'
            description='Indicates whether the search was successful'
        )
        public Boolean success;

        @InvocableVariable(
            label='Message'
            description='Human-readable message about the search results'
        )
        public String message;

        @InvocableVariable(
            label='Search Results'
            description='List of content records matching the search criteria'
        )
        public List<ANAgentContentSearchServiceV2.UnifiedContent> results;

        @InvocableVariable(
            label='Total Record Count'
            description='Total number of records found'
        )
        public Integer totalRecordCount;

        @InvocableVariable(
            label='Errors'
            description='List of error messages if any occurred'
        )
        public List<String> errors;

        public ContentSearchResponse() {
            this.success = false;
            this.message = '';
            this.results = new List<ANAgentContentSearchServiceV2.UnifiedContent>();
            this.totalRecordCount = 0;
            this.errors = new List<String>();
        }
    }

    /**
     * @description Main invocable method for content search
     * @param requests List of search requests
     * @return List of search responses
     */
    @InvocableMethod(
        label='ANAgent Search Content V2'
        description='Searches for content across Course, Asset, and Curriculum objects. Returns unified results with basic information including learner statistics (learner count, completion count, completion rate) for courses to provide insights about course popularity and effectiveness.'
    )
    public static List<ContentSearchResponse> searchContent(List<ContentSearchRequest> requests) {
        List<ContentSearchResponse> responses = new List<ContentSearchResponse>();

        // Handle null or empty requests
        if (requests == null || requests.isEmpty()) {
            ContentSearchResponse errorResponse = new ContentSearchResponse();
            errorResponse.message = 'No search request provided.';
            errorResponse.errors.add('Request list is null or empty.');
            responses.add(errorResponse);
            return responses;
        }

        // Process each request
        for (ContentSearchRequest request : requests) {
            ContentSearchResponse response = new ContentSearchResponse();
            
            try {
                // Validate request
                if (String.isBlank(request.searchTerm)) {
                    response.message = 'Search term is required.';
                    response.errors.add('Search term cannot be blank.');
                    responses.add(response);
                    continue;
                }

                // Perform search
                ANAgentContentSearchServiceV2.ContentSearchResult searchResult = 
                    ANAgentContentSearchServiceV2.search(request.searchTerm, request.contentType);

                // Process results
                response.success = searchResult.success;
                response.results = searchResult.records;
                response.totalRecordCount = searchResult.totalCount;
                response.errors = searchResult.errors;

                // Build message
                if (searchResult.success) {
                    if (searchResult.totalCount > 0) {
                        response.message = 'Found ' + searchResult.totalCount + ' content item(s) matching "' + request.searchTerm + '"';
                        if (String.isNotBlank(request.contentType)) {
                            response.message += ' in ' + request.contentType + ' type';
                        }
                        response.message += '.';
                        
                        // Add learner statistics summary for courses
                        if (String.isBlank(request.contentType) || request.contentType == 'Course') {
                            Integer totalLearners = 0;
                            Integer totalCompletions = 0;
                            Integer courseCount = 0;
                            
                            for (ANAgentContentSearchServiceV2.UnifiedContent content : searchResult.records) {
                                if (content.type == 'Course') {
                                    totalLearners += content.learnerCount;
                                    totalCompletions += content.completionCount;
                                    courseCount++;
                                }
                            }
                            
                            if (courseCount > 0) {
                                response.message += ' Course results include learner statistics: ' + courseCount + ' courses with ' + totalLearners + ' total learners and ' + totalCompletions + ' completions.';
                            }
                        }
                    } else {
                        response.message = 'No content found matching "' + request.searchTerm + '"';
                        if (String.isNotBlank(request.contentType)) {
                            response.message += ' in ' + request.contentType + ' type';
                        }
                        response.message += '.';
                    }
                } else {
                    response.message = 'Search failed: ' + String.join(searchResult.errors, '; ');
                }

            } catch (Exception e) {
                response.success = false;
                response.message = 'An unexpected error occurred during search.';
                response.errors.add('Exception: ' + e.getMessage());
                System.debug('ANAgentContentSearchHandlerV2 error: ' + e.getMessage());
            }

            responses.add(response);
        }

        return responses;
    }

    /**
     * @description Convenience method for single search request
     * @param searchTerm The search term
     * @param contentType Optional content type filter
     * @return ContentSearchResponse
     */
    public static ContentSearchResponse searchContent(String searchTerm, String contentType) {
        ContentSearchRequest request = new ContentSearchRequest(searchTerm, contentType);
        List<ContentSearchRequest> requests = new List<ContentSearchRequest>{request};
        List<ContentSearchResponse> responses = searchContent(requests);
        return responses.isEmpty() ? new ContentSearchResponse() : responses[0];
    }

    /**
     * @description Convenience method for single search request without content type
     * @param searchTerm The search term
     * @return ContentSearchResponse
     */
    public static ContentSearchResponse searchContent(String searchTerm) {
        return searchContent(searchTerm, null);
    }
} 