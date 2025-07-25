/**
 * TEMPLATE HANDLER - This class acts as agent instructions in our handler/service template.
 * Business Requirement: Responses include both Ids and Names when applicable to meet user-friendly output requirements.
 * The handler validates requests and delegates business logic to the service layer.
 * @description Handler class for all operations related to Audience Checklist records.
 * This class is the primary entry point for the AI agent to create, find, modify,
 * or delete associations between Audiences and Checklists.
 *
 * The service layer returns `Audience_Checklist__c` records with the following
 * fields populated: `Audience__c`, `Checklist__c`, `CreatedDate` and `LastModifiedDate`.
 *
 * @version 4.0
 */
public with sharing class FRAGENTAudienceChecklistHandler {
    
    public class Request {
        @InvocableVariable(label='Action Type' required=true description='Specifies the operation: "Create", "Read", "Delete", or "Search".')
        public String action;

        @InvocableVariable(label='Audience Checklist ID' description='The unique 18-character Salesforce ID of an Audience_Checklist__c record. Required for "Read" and "Delete" actions.')
        public Id audienceChecklistId;

        @InvocableVariable(label='Audience ID' description='The ID of the Audience. Required for "Create". Can be used as a filter for "Search".')
        public Id audienceId;
        
        @InvocableVariable(label='Checklist ID' description='The ID of the Checklist. Required for "Create". Can be used as a filter for "Search".')
        public Id checklistId;

        @InvocableVariable(label='General Search Term' description='A keyword for "Search". Not currently used for this object.')
        public String searchTerm;
        
        @InvocableVariable(label='Date Field to Search' description='The date field for filtering: "CreatedDate" or "LastModifiedDate". Defaults to "CreatedDate".')
        public String dateFieldToSearch;
        
        @InvocableVariable(label='Date Literal for Search' description='A SOQL date literal for relative date searches (e.g., "LAST_N_DAYS:30").')
        public String dateLiteral;

        @InvocableVariable(label='Search Start Date' description='The start date for an absolute date range search.')
        public Date startDate;

        @InvocableVariable(label='Search End Date' description='The end date for an absolute date range search.')
        public Date endDate;

        @InvocableVariable(label='Record Limit' description='Maximum number of records to return for "Search". Defaults to 50.')
        public Integer recordLimit = 50;
        
        @InvocableVariable(label='Search Result Offset' description='The starting record offset for "Search" pagination.')
        public Integer offset = 0;
    }
    
    public class Response {
        @InvocableVariable(label='Operation Succeeded' description='True if the operation completed without errors.')
        public Boolean success;
        
        @InvocableVariable(label='Feedback Message' description='A detailed message describing the result, including success or specific error details.')
        public String message;
        
        @InvocableVariable(label='Returned Records' description='A list of Audience_Checklist__c records that were created, updated, or found.')
        public List<Audience_Checklist__c> records;
        
        @InvocableVariable(label='Total Matching Record Count' description='For "Search", the total number of records matching the criteria, used for pagination.')
        public Integer totalRecordCount;
        
        public Response() {
            this.success = false;
            this.records = new List<Audience_Checklist__c>();
            this.totalRecordCount = 0;
        }
    }

    @InvocableMethod(label='FRAGENT Manage Audience Checklist' description='Performs Create, Read, Delete, and Search operations on Audience Checklist records.')
    public static List<Response> manageAudienceChecklists(List<Request> requests) {
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
                    when 'delete' { res = handleDelete(req); }
                    when 'search' { res = handleSearch(req); }
                    when 'update' {
                        res.message = 'Update action is not supported for Audience Checklists.';
                    }
                    when else { res.message = 'Invalid action: ' + req.action; }
                }
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
    
    private static Response handleCreate(Request req) {
        if (req.audienceId == null || req.checklistId == null) {
            Response res = new Response();
            res.message = 'Audience ID and Checklist ID are required for Create action.';
            return res;
        }
        Audience_Checklist__c newRecord = new Audience_Checklist__c(Audience__c = req.audienceId, Checklist__c = req.checklistId);
        FRAGENTGeneralService.Result serviceResult = FRAGENTAudienceChecklistService.create(new List<Audience_Checklist__c>{newRecord});
        return processServiceResult(serviceResult, 'Association created successfully.');
    }
    
    private static Response handleRead(Request req) {
        if (req.audienceChecklistId == null) {
            Response res = new Response();
            res.message = 'Audience Checklist ID is required for Read action.';
            return res;
        }
        FRAGENTGeneralService.Result serviceResult = FRAGENTAudienceChecklistService.getById(req.audienceChecklistId);
        return processServiceResult(serviceResult, 'Association retrieved successfully.');
    }
    
    private static Response handleDelete(Request req) {
        if (req.audienceChecklistId == null) {
            Response res = new Response();
            res.message = 'Audience Checklist ID is required for Delete action.';
            return res;
        }
        FRAGENTGeneralService.Result serviceResult = FRAGENTAudienceChecklistService.remove(new List<Id>{req.audienceChecklistId});
        return processServiceResult(serviceResult, 'Association deleted successfully.');
    }
    
    private static Response handleSearch(Request req) {
        if (req.audienceId == null && req.checklistId == null && String.isBlank(req.dateLiteral) && req.startDate == null && req.endDate == null) {
            Response res = new Response();
            res.message = 'An Audience ID, Checklist ID, or a date criterion is required for a Search action.';
            return res;
        }
        
        FRAGENTAudienceChecklistService.SearchResult serviceResult = FRAGENTAudienceChecklistService.search(
            req.audienceId, req.checklistId, req.searchTerm, req.dateFieldToSearch, req.dateLiteral, req.startDate, req.endDate, req.recordLimit, req.offset
        );
        
        Response res = new Response();
        res.success = serviceResult.success;
        if (serviceResult.success) {
            res.totalRecordCount = serviceResult.totalCount;
            res.message = 'Search successful. Found ' + serviceResult.totalCount + ' total association(s).';
            if (serviceResult.records != null) {
                res.records = (List<Audience_Checklist__c>)serviceResult.records;
            }
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
                res.records = (List<Audience_Checklist__c>)serviceResult.records;
            }
        } else {
            res.message = String.join(serviceResult.errors, '; ');
        }
        return res;
    }
}