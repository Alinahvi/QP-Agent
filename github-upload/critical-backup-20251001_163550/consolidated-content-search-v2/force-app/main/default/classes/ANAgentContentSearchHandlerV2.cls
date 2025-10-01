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

                // Use the V2 service that includes enrollment and completion data
                ANAgentContentSearchServiceV2.ContentSearchResult searchResult = 
                    ANAgentContentSearchServiceV2.search(request.searchTerm, request.contentType);

                // Process results
                response.success = searchResult.success;
                response.totalRecordCount = searchResult.totalCount;
                response.errors = searchResult.errors;
                response.results = searchResult.records;

                // Create formatted message with enrollment and completion data
                if (searchResult.success) {
                    response.message = formatContentSearchMessage(searchResult.records, request.searchTerm);
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
     * @param contentType Optional content type filter (ignored, using unified service)
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

    /**
     * @description Format content search results with enrollment and completion data
     * @param records List of unified content records
     * @param searchTerm The search term used
     * @return Formatted message string
     */
    private static String formatContentSearchMessage(List<ANAgentContentSearchServiceV2.UnifiedContent> records, String searchTerm) {
        if (records == null || records.isEmpty()) {
            return 'No content found matching: ' + searchTerm;
        }

        String message = 'I found ' + records.size() + ' ' + searchTerm + ' related courses and demos! Here\'s what I discovered:\n\n';
        message += '## **' + searchTerm + ' Content Overview**\n\n';
        message += '**Total Results Found:** ' + records.size() + ' courses and demos\n\n';

        // Group by content type
        List<ANAgentContentSearchServiceV2.UnifiedContent> courses = new List<ANAgentContentSearchServiceV2.UnifiedContent>();
        List<ANAgentContentSearchServiceV2.UnifiedContent> assets = new List<ANAgentContentSearchServiceV2.UnifiedContent>();
        List<ANAgentContentSearchServiceV2.UnifiedContent> curriculums = new List<ANAgentContentSearchServiceV2.UnifiedContent>();

        for (ANAgentContentSearchServiceV2.UnifiedContent content : records) {
            if (content.type == 'Course') {
                courses.add(content);
            } else if (content.type == 'Asset') {
                assets.add(content);
            } else if (content.type == 'Curriculum') {
                curriculums.add(content);
            }
        }

        // Format courses with enrollment and completion data
        if (!courses.isEmpty()) {
            message += '### **Featured ' + searchTerm + ' Courses**\n\n';
            message += '🔥 **Most Recent & Popular:**\n\n';

            for (ANAgentContentSearchServiceV2.UnifiedContent course : courses) {
                message += '**' + course.name + '**\n\n';
                
                if (course.createdDate != null) {
                    message += 'Created: ' + course.createdDate.format('MMMM d, yyyy') + '\n';
                }
                
                if (String.isNotBlank(course.description)) {
                    message += 'Duration: Self-paced\n';
                    message += 'Watch Course\n';
                    message += course.description + '\n';
                }

                // Include enrollment and completion data
                if (course.learnerCount != null && course.learnerCount > 0) {
                    message += '**Enrollment Data:**\n';
                    message += '• **Total Learners:** ' + course.learnerCount + '\n';
                    
                    if (course.completionCount != null) {
                        message += '• **Completions:** ' + course.completionCount + '\n';
                    }
                    
                    if (course.completionRate != null && course.completionRate > 0) {
                        Decimal rate = Decimal.valueOf(course.completionRate).setScale(1);
                        message += '• **Completion Rate:** ' + String.valueOf(rate) + '%\n';
                    }
                } else {
                    message += '**Note:** Enrollment and completion data not available for this course.\n';
                }
                
                message += '\n';
            }
        }

        // Format assets
        if (!assets.isEmpty()) {
            message += '### **Related Assets**\n\n';
            for (ANAgentContentSearchServiceV2.UnifiedContent asset : assets) {
                message += '• **' + asset.name + '**';
                if (String.isNotBlank(asset.description)) {
                    message += ' - ' + asset.description;
                }
                message += '\n';
            }
            message += '\n';
        }

        // Format curriculums
        if (!curriculums.isEmpty()) {
            message += '### **Learning Curriculums**\n\n';
            for (ANAgentContentSearchServiceV2.UnifiedContent curriculum : curriculums) {
                message += '• **' + curriculum.name + '**';
                if (String.isNotBlank(curriculum.description)) {
                    message += ' - ' + curriculum.description;
                }
                message += '\n';
            }
            message += '\n';
        }

        // Add note about data availability
        message += '**Note:** The search returned course content and listings. ';
        message += 'Enrollment numbers and completion rates are displayed when available. ';
        message += 'For detailed completion statistics, you may need to access the individual course analytics or contact your learning administrator.\n\n';
        
        message += 'Would you like me to search for more specific ' + searchTerm + ' topics or help you find completion data for any particular course?';

        return message;
    }
} 