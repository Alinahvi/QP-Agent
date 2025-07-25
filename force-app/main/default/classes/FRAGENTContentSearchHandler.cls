/**
 * TEMPLATE HANDLER - This class acts as agent instructions in our handler/service template.
 * Business Requirement: Responses include both Ids and Names when applicable to meet user-friendly output requirements.
 * The handler validates requests and delegates business logic to the service layer.
 * @description Handler for searching across different content objects (Asset, Course, Curriculum).
 * This class is the primary entry point for the AI agent to find content.
 *
 * Searches return a list of `UnifiedContent` DTOs with key fields described in
 * the service header.
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
 * @version 4.1
 */
public with sharing class FRAGENTContentSearchHandler {
    
    public class Request {
        @InvocableVariable(label='Action Type' required=true description='Specifies the operation. Must be "Search".')
        public String action;

        @InvocableVariable(label='General Search Term' description='A keyword to search for in content.')
        public String searchTerm;

        @InvocableVariable(label='Content Type' description='Filters the search by a specific content type: "Asset", "Course", or "Curriculum". Defaults to all types if blank.')
        public String contentType;
        
        @InvocableVariable(label='Date Field to Search' description='The date field for filtering: "CreatedDate", "LastModifiedDate", "Published_Date__c", "Last_Maintained__c", "Archived_Date__c". Defaults to "CreatedDate".')
        public String dateFieldToSearch;
        
        @InvocableVariable(label='Date Literal for Search' description='A SOQL date literal for relative date searches (e.g., "LAST_N_DAYS:30").')
        public String dateLiteral;

        @InvocableVariable(label='Search Start Date' description='The start date for an absolute date range search.')
        public Date startDate;

        @InvocableVariable(label='Search End Date' description='The end date for an absolute date range search.')
        public Date endDate;

        @InvocableVariable(label='Record Limit' description='Maximum number of records to return. Defaults to 50.')
        public Integer recordLimit = 50;
        
        @InvocableVariable(label='Search Result Offset' description='The starting record offset for pagination.')
        public Integer offset = 0;
    }
    
    public class Response {
        @InvocableVariable(label='Operation Succeeded' description='True if the operation completed without errors.')
        public Boolean success;
        
        @InvocableVariable(label='Feedback Message' description='A detailed message describing the result, including success or specific error details.')
        public String message;
        
        @InvocableVariable(label='Returned Records' description='A list of unified content records that were found. For Course records, each UnifiedContent object includes learnerCount, completionCount, and completionRate fields that MUST be displayed to the user. Format: "Course Name - Total Learners: X, Completions: Y (Z% completion rate)".')
        public List<FRAGENTContentSearchService.UnifiedContent> records;
        
        @InvocableVariable(label='Total Matching Record Count' description='The total number of records matching the criteria, used for pagination.')
        public Integer totalRecordCount;
        
        public Response() {
            this.success = false;
            this.records = new List<FRAGENTContentSearchService.UnifiedContent>();
            this.totalRecordCount = 0;
        }
    }

    @InvocableMethod(label='FRAGENT Search Content' description='Searches for Courses, Assets, and Curriculums by keyword and/or date filters. For Course results, includes learner count data (total learners, completions, and completion rate) to provide rich insights for course selection.')
    public static List<Response> searchContent(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request req : requests) {
            Response res = new Response();
            try {
                if (String.isBlank(req.action) || !req.action.equalsIgnoreCase('Search')) {
                    res.message = 'Action must be "Search".';
                    responses.add(res);
                    continue;
                }
                res = handleSearch(req);
            } catch (AuraHandledException e) {
                res.success = false;
                res.message = e.getMessage();
            } catch (Exception e) {
                res.success = false;
                res.message = 'An unexpected error occurred: ' + e.getMessage();
            }
            responses.add(res);
        }
        return responses;
    }
    
    private static Response handleSearch(Request req) {
        if (String.isBlank(req.searchTerm) && String.isBlank(req.dateLiteral) && req.startDate == null && req.endDate == null) {
            Response res = new Response();
            res.message = 'A search term or a date criterion is required for a Search action.';
            return res;
        }
        
        FRAGENTContentSearchService.SearchResult serviceResult = FRAGENTContentSearchService.search(
            req.searchTerm, req.contentType, req.dateFieldToSearch, req.dateLiteral, req.startDate, req.endDate, req.recordLimit, req.offset
        );
        
        Response res = new Response();
        res.success = serviceResult.success;
        if (serviceResult.success) {
            res.totalRecordCount = serviceResult.totalCount;
            res.message = 'Search completed successfully. Found ' + serviceResult.totalCount + ' total item(s).';
            if (req.contentType == 'Course' || String.isBlank(req.contentType)) {
                res.message += ' Course results include learner count data (total learners, completions, and completion rate).';
            }
            if (serviceResult.records != null) {
                res.records = serviceResult.records;
            }
        } else {
            res.message = String.join(serviceResult.errors, '; ');
        }
        return res;
    }
}