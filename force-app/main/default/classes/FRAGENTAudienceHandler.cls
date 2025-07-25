/**
 * TEMPLATE HANDLER - This class acts as agent instructions in our handler/service template.
 * Business Requirement: Responses include both Ids and Names when applicable to meet user-friendly output requirements.
 * The handler validates requests and delegates business logic to the service layer.
 * @description Handler class for all operations related to Audience records. An 'Audience' is a group or cohort of employees.
 * This class is the primary entry point for the AI agent to create, find, modify, delete, or search for audiences.
 * It validates requests and routes them to the FRAGENTAudienceService for execution.
 *
 * The service fetches `Audience__c` records selecting `Name`, `CreatedDate`, `LastModifiedDate`, `CreatedById`
 * and `LastModifiedById` so downstream consumers always receive these fields.
 *
 * @version 2.8
 */
public with sharing class FRAGENTAudienceHandler {
    
    public class Request {
        @InvocableVariable(
            label='Action Type'
            description='Specifies the operation to perform. Must be one of the following exact string values: "Create", "Read", "Update", "Delete", or "Search". This parameter determines which logic branch is executed.'
            required=true
        )
        public String action;

        @InvocableVariable(
            label='Audience Record ID'
            description='The unique 18-character Salesforce ID for a specific Audience record. Use this ONLY for "Read", "Update", and "Delete" actions when the user provides a specific ID.'
        )
        public Id audienceId;
        
        @InvocableVariable(
            label='Audience Name'
            description='The human-readable name of the Audience. REQUIRED for the "Create" action. It can also be used for a keyword "Search".'
        )
        public String audienceName;
        
        @InvocableVariable(
            label='General Search Term'
            description='A keyword or partial name for the "Search" action. Use this for general text-based searches like "find all cohorts with \'Sales Kickoff\' in the name". This parameter is IGNORED if any date search parameter (dateLiteral, startDate, endDate) is provided.'
        )
        public String searchTerm;
        
        @InvocableVariable(
            label='Date Field to Search'
            description='Specifies which date field to search when using date-based filtering. Valid values are "CreatedDate" or "LastModifiedDate". If not specified, defaults to "CreatedDate". This parameter is used in conjunction with dateLiteral, startDate, or endDate parameters.'
        )
        public String dateFieldToSearch;

        @InvocableVariable(
            label='Date Literal for Search'
            // FIX: Heavily expanded description with explicit examples and rules for the AI.
            description='For a date-based search using a relative period, use ONLY a valid Salesforce SOQL Date Literal. The search checks the specified date field (or CreatedDate by default). Examples of valid literals include: TODAY, YESTERDAY, LAST_WEEK, THIS_MONTH, LAST_90_DAYS. For a specific number of days, use the format "LAST_N_DAYS:45" or "NEXT_N_DAYS:30". This parameter takes precedence over start/end dates. A specific date like "2025-06-02" or a format like "LAST_10_DAYS" are INVALID and will cause an error. Use startDate and endDate for specific dates.'
        )
        public String dateLiteral;

        @InvocableVariable(
            label='Search Start Date'
            description='Use this field for searching for an ABSOLUTE date or the beginning of a custom date range. For a query like "on June 2nd, 2025", set BOTH this `startDate` and the `endDate` to "2025-06-02". For "since June 1st", set this field to "2025-06-01".'
        )
        public Date startDate;

        @InvocableVariable(
            label='Search End Date'
            description='Use this field for the end of a custom date range (inclusive). For a query like "before July 3rd", set this field to "2025-07-02". To search for records on a SINGLE specific day, set BOTH this `endDate` and the `startDate` to that same day.'
        )
        public Date endDate;

        @InvocableVariable(
            label='Record Limit for Search'
            description='For the "Search" action, this determines the maximum number of audience records to return in a single response. This enables pagination. Defaults to 50 if not specified.'
        )
        public Integer recordLimit = 50;
        
        @InvocableVariable(
            label='Search Result Offset'
            description='For the "Search" action, this specifies how many initial records to skip. Use this for pagination. For example, to get the second page of results with a limit of 50, set the offset to 50.'
        )
        public Integer offset = 0;
    }
    
    public class Response {
        @InvocableVariable(
            label='Operation Succeeded'
            description='A boolean value indicating the outcome. Returns `true` if the entire operation was completed successfully. Returns `false` if any error occurred, including permission errors or validation failures.'
        )
        public Boolean success;
        
        @InvocableVariable(
            label='Feedback Message'
            description='A detailed, human-readable message describing the result of the operation. For successes, it confirms the action (e.g., "Audience created successfully"). For failures, it provides specific error details (e.g., "Insufficient permissions: Missing Permission Set...") that can be relayed to the user.'
        )
        public String message;
        
        @InvocableVariable(
            label='Returned Audience Records'
            description='A list of the full Audience__c records that were created, updated, or found by the operation. The agent should use the fields from these records to answer user questions about audience details (Name, ID, Created Date, etc.). IMPORTANT: When displaying DateTime fields like CreatedDate or LastModifiedDate to the user, format them as a simple date (e.g., "YYYY-MM-DD") and omit the time details.'
        )
        public List<Audience__c> audienceRecords;
        
        @InvocableVariable(
            label='Total Matching Record Count'
            description='For a "Search" action, this provides the total number of records that matched the search criteria, even if only a subset was returned due to the Record Limit. Use this value to determine if pagination is needed (e.g., if totalRecordCount is greater than the size of the returned audienceRecords list).'
        )
        public Integer totalRecordCount;

        @InvocableVariable(
            label='Member Count'
            description='For a single Audience read, this is the number of related Audience Member records.'
        )
        public Integer memberCount;

        public Map<Id, Integer> memberCounts;

        public List<FRAGENTAudienceMemberService.UnifiedAudienceMember> members;

        public Map<String, Integer> divisionCounts;

        public Map<Id, Map<String, Integer>> divisionCountsByAudience;

        public Map<String, Integer> aeTypeCounts;

        public Map<Id, Map<String, Integer>> aeTypeCountsByAudience;

        public Map<String, Integer> roleLevel4Counts;

        public Map<Id, Map<String, Integer>> roleLevel4CountsByAudience;

        public Response() {
            this.success = false;
            this.audienceRecords = new List<Audience__c>();
            this.totalRecordCount = 0;
            this.memberCount = 0;
            this.memberCounts = new Map<Id, Integer>();
            this.members = new List<FRAGENTAudienceMemberService.UnifiedAudienceMember>();
            this.divisionCounts = new Map<String, Integer>();
            this.divisionCountsByAudience = new Map<Id, Map<String, Integer>>();
            this.aeTypeCounts = new Map<String, Integer>();
            this.aeTypeCountsByAudience = new Map<Id, Map<String, Integer>>();
            this.roleLevel4Counts = new Map<String, Integer>();
            this.roleLevel4CountsByAudience = new Map<Id, Map<String, Integer>>();
        }
    }

    @InvocableMethod(
        label='FRAGENT Manage Audience'
        description='A comprehensive tool to perform all Create, Read, Update, Delete, and Search operations on Audience records. Use this for any task involving managing employee cohorts or groups. The Search action can filter by keyword or by date. Date-based searches will check both the Created Date and Last Modified Date fields.'
    )
    public static List<Response> manageAudiences(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();
            
            try {
                if (String.isBlank(req.action)) {
                    res.message = 'Action parameter is required.';
                    responses.add(res);
                    continue;
                }
                
                String action = req.action.toLowerCase();
                
                switch on action {
                    when 'create' { res = handleCreate(req); }
                    when 'read'   { res = handleRead(req); }
                    when 'update' { res = handleUpdate(req); }
                    when 'delete' { res = handleDelete(req); }
                    when 'search' { res = handleSearch(req); }
                    when else {
                        res.message = 'Invalid action: ' + req.action;
                    }
                }
                
            } catch (AuraHandledException e) {
                res.success = false;
                res.message = e.getMessage();
            } catch (Exception e) {
                res.success = false;
                res.message = 'An unexpected error occurred in the handler: ' + e.getMessage();
            }
            
            responses.add(res);
        }
        return responses;
    }
    
    private static Response handleCreate(Request req) {
        if (String.isBlank(req.audienceName)) {
            Response res = new Response();
            res.message = 'Audience Name is required for Create action.';
            return res;
        }
        
        Audience__c newAudience = new Audience__c(Name = req.audienceName);
        FRAGENTGeneralService.Result serviceResult = FRAGENTAudienceService.createAudiences(new List<Audience__c>{newAudience});
        return processServiceResult(serviceResult, 'Audience created successfully.');
    }
    
    private static Response handleRead(Request req) {
        if (req.audienceId == null) {
            Response res = new Response();
            res.message = 'Audience ID is required for Read action.';
            return res;
        }
        
        FRAGENTAudienceService.AudienceResult serviceResult = FRAGENTAudienceService.getAudienceById(req.audienceId);

        Response res = processServiceResult(serviceResult, 'Audience retrieved successfully.');
        if (serviceResult.success) {
            res.memberCount = serviceResult.memberCount;
            res.divisionCounts = serviceResult.divisionCounts;
            res.aeTypeCounts = serviceResult.aeTypeCounts;
            res.roleLevel4Counts = serviceResult.roleLevel4Counts;
            res.members = serviceResult.members;
        }
        return res;
    }
    
    private static Response handleUpdate(Request req) {
        if (req.audienceId == null || String.isBlank(req.audienceName)) {
            Response res = new Response();
            res.message = 'Audience ID and Audience Name are required for Update action.';
            return res;
        }
        
        Audience__c updateAudience = new Audience__c(Id = req.audienceId, Name = req.audienceName);
        FRAGENTGeneralService.Result serviceResult = FRAGENTAudienceService.updateAudiences(new List<Audience__c>{updateAudience});
        return processServiceResult(serviceResult, 'Audience updated successfully.');
    }
    
    private static Response handleDelete(Request req) {
        if (req.audienceId == null) {
            Response res = new Response();
            res.message = 'Audience ID is required for Delete action.';
            return res;
        }

        FRAGENTGeneralService.Result serviceResult = FRAGENTAudienceService.deleteAudiences(new List<Id>{req.audienceId});
        return processServiceResult(serviceResult, 'Audience deleted successfully.');
    }
    
    private static Response handleSearch(Request req) {
        Response res = new Response();
        String searchTerm = String.isNotBlank(req.searchTerm) ? req.searchTerm : req.audienceName;
        
        if (String.isBlank(searchTerm) && String.isBlank(req.dateLiteral) && req.startDate == null && req.endDate == null) {
            res.message = 'A search term or a date criterion is required for a Search action.';
            return res;
        }
        
        FRAGENTAudienceService.SearchResult serviceResult = FRAGENTAudienceService.search(
            searchTerm, req.dateFieldToSearch, req.dateLiteral, req.startDate, req.endDate, req.recordLimit, req.offset
        );
        
        res.success = serviceResult.success;
        if (serviceResult.success) {
            res.totalRecordCount = serviceResult.totalCount;
            res.message = 'Search successful. Found ' + serviceResult.totalCount + ' total audience(s).';
            if (serviceResult.records != null) {
                res.audienceRecords = (List<Audience__c>)serviceResult.records;
            }
            res.memberCounts = serviceResult.memberCounts;
            res.divisionCountsByAudience = serviceResult.divisionCounts;
            res.aeTypeCountsByAudience = serviceResult.aeTypeCounts;
            res.roleLevel4CountsByAudience = serviceResult.roleLevel4Counts;
        } else {
            res.message = String.join(serviceResult.errors, '; ');
        }

        return res;
    }

    private static Response processServiceResult(FRAGENTGeneralService.Result serviceResult, String successMessage) {
        Response res = new Response();
        res.success = serviceResult.success;

        if (res.success) {
            res.message = successMessage;
            if (serviceResult.records != null) {
                res.audienceRecords = (List<Audience__c>)serviceResult.records;
            }
        } else {
            res.message = String.join(serviceResult.errors, '; ');
        }
        return res;
    }
}