/**
 * @description Invocable Apex class that exposes content search functionality to the APM Nomination Agent.
 *              This class acts as the entry point for the GenAI Planner.
 * 
 * IMPORTANT AGENT INSTRUCTIONS FOR COURSE SEARCH RESULTS:
 * When displaying Course search results, ALWAYS include the learner count data:
 * - Show "Total Learners: X" for each course
 * - Show "Completions: Y" for each course  
 * - Show "Completion Rate: Z%" for each course
 * - Format: "Course Name - Total Learners: X, Completions: Y (Z% completion rate)"
 * 
 * Example: "Data Cloud Setup - Total Learners: 1,803, Completions: 732 (40.6% completion rate)"
 * 
 * @author Gemini
 * @date 2025-07-11
 */
public with sharing class ANAgentContentSearchHandler {
    /**
     * @description The request object for the content search invocable method.
     */
    public class ContentSearchRequest {
        @InvocableVariable(label='Action' description='The action to perform: Search' required=true)
        public String action;
        @InvocableVariable(label='Search Term' description='The term to search for across content.' required=true)
        public String searchTerm;
        @InvocableVariable(label='Content Type' description='Optional. Filters the search by content type. Valid values: Course, Asset, Curriculum.')
        public String contentType;
    }
    /**
     * @description The response object for the content search invocable method.
     */
    public class ContentSearchResponse {
        @InvocableVariable(label='Search Results' description='A list of content records matching the search term.')
        public List<ANAgentContentSearchService.UnifiedContent> results;
        @InvocableVariable(label='Success' description='Indicates whether the operation was successful.')
        public Boolean success;
        @InvocableVariable(label='Message' description='Provides a message about the outcome, especially in case of an error.')
        public String message;
        @InvocableVariable(label='Total Record Count' description='The total number of records found.')
        public Integer totalRecordCount;
        public ContentSearchResponse() {
            this.success = false;
            this.results = new List<ANAgentContentSearchService.UnifiedContent>();
            this.totalRecordCount = 0;
        }
    }
    /**
     * @description The main invocable method that searches for content.
     * @param requests A list of search requests, though typically only one is processed.
     * @return A list of search responses.
     */
    @InvocableMethod(label='ANAgent Search Content' description='Searches for Courses, Assets, and Curriculums based on a search term. For Course results, includes learner count data (total learners, completions, and completion rate) to provide rich insights for course selection.')
    public static List<ContentSearchResponse> searchContent(List<ContentSearchRequest> requests) {
        List<ContentSearchResponse> responses = new List<ContentSearchResponse>();
        if (requests == null || requests.isEmpty()) {
            ContentSearchResponse errRes = new ContentSearchResponse();
            errRes.message = 'No request provided.';
            responses.add(errRes);
            return responses;
        }
        for (ContentSearchRequest req : requests) {
            ContentSearchResponse res = new ContentSearchResponse();
            try {
                // Validate action parameter
                if (String.isBlank(req.action)) {
                    res.message = 'Action parameter is required. Valid actions: Search';
                    responses.add(res);
                    continue;
                }
                String action = req.action.toLowerCase();
                // Route to appropriate service method based on action
                switch on action {
                    when 'search' {
                        res = handleSearch(req);
                    }
                    when else {
                        res.message = 'Invalid action: ' + req.action + '. Valid actions: Search';
                    }
                }
            } catch (Exception e) {
                res.success = false;
                res.message = 'An unexpected error occurred: ' + e.getMessage();
            }
            responses.add(res);
        }
        return responses;
    }
    private static ContentSearchResponse handleSearch(ContentSearchRequest req) {
        ContentSearchResponse res = new ContentSearchResponse();
        // Validate required fields for Search
        if (String.isBlank(req.searchTerm)) {
            res.message = 'Search term is required for Search action';
            return res;
        }
        try {
            Map<String, Object> params = new Map<String, Object>();
            params.put('searchTerm', req.searchTerm);
            if(String.isNotBlank(req.contentType)) {
                params.put('contentType', req.contentType);
            }
            ANAgentContentSearchService.ContentSearchResult serviceResult = ANAgentContentSearchService.search(params);
            if (serviceResult.success) {
                res.results = serviceResult.records;
                res.success = true;
                if (res.results != null) {
                    res.message = 'Search completed successfully. Found ' + res.results.size() + ' results.';
                    if (req.contentType == 'Course' || String.isBlank(req.contentType)) {
                        res.message += ' Course results include learner count data (total learners, completions, and completion rate).';
                    }
                    res.totalRecordCount = res.results.size();
                } else {
                    res.message = 'Search completed successfully with no results.';
                    res.totalRecordCount = 0;
                }
            } else {
                res.success = false;
                res.message = serviceResult.errors != null && !serviceResult.errors.isEmpty() ? 
                    String.join(serviceResult.errors, '; ') : 'Search failed.';
                res.totalRecordCount = 0;
            }
        } catch (Exception e) {
            res.success = false;
            res.message = 'An unexpected error occurred: ' + e.getMessage();
        }
        return res;
    }
} 