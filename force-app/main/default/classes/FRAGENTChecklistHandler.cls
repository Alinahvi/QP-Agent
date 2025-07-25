/**
 * TEMPLATE HANDLER - This class acts as agent instructions in our handler/service template.
 * Business Requirement: Responses include both Ids and Names when applicable to meet user-friendly output requirements.
 * The handler validates requests and delegates business logic to the service layer.
 * @description Handler class for all operations related to Checklist records.
 * This class is the primary entry point for the AI agent to create, find, modify, or delete checklists.
 * It validates requests and routes them to the FRAGENTChecklistService for execution.
 *
 * The service selects `Name`, `CreatedDate` and `LastModifiedDate` fields from
 * `Checklist__c` so consuming flows have predictable columns.
 *
 * @version 4.0
 */
public with sharing class FRAGENTChecklistHandler {
    
    public class Request {
        @InvocableVariable(label='Action Type' required=true description='Specifies the operation: "Create", "Read", "Update", "Delete", or "Search".')
        public String action;

        @InvocableVariable(label='Checklist ID' description='The unique 18-character Salesforce ID of a Checklist record. Required for "Read", "Update", and "Delete" actions.')
        public Id checklistId;
        
        @InvocableVariable(label='Checklist Name' description='The name of the Checklist. Required for "Create" and "Update" actions.')
        public String checklistName;
        
        @InvocableVariable(label='General Search Term' description='A keyword or partial name for the "Search" action.')
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
        
        @InvocableVariable(label='Returned Records' description='A list of Checklist__c records that were created, updated, or found.')
        public List<Checklist__c> records;
        
        @InvocableVariable(label='Total Matching Record Count' description='For "Search", the total number of records matching the criteria, used for pagination.')
        public Integer totalRecordCount;
        
        public Response() {
            this.success = false;
            this.records = new List<Checklist__c>();
            this.totalRecordCount = 0;
        }
    }

    @InvocableMethod(label='FRAGENT Manage Checklist' description='Performs Create, Read, Update, Delete, and Search operations on Checklist records.')
    public static List<Response> manageChecklists(List<Request> requests) {
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
        if (String.isBlank(req.checklistName)) {
            Response res = new Response();
            res.message = 'Checklist Name is required for Create action.';
            return res;
        }
        Checklist__c newChecklist = new Checklist__c(Name = req.checklistName);
        FRAGENTGeneralService.Result serviceResult = FRAGENTChecklistService.create(new List<Checklist__c>{newChecklist});
        return processServiceResult(serviceResult, 'Checklist created successfully.');
    }
    
    private static Response handleRead(Request req) {
        if (req.checklistId == null) {
            Response res = new Response();
            res.message = 'Checklist ID is required for Read action.';
            return res;
        }
        FRAGENTGeneralService.Result serviceResult = FRAGENTChecklistService.getById(req.checklistId);
        return processServiceResult(serviceResult, 'Checklist retrieved successfully.');
    }
    
    private static Response handleUpdate(Request req) {
        if (req.checklistId == null || String.isBlank(req.checklistName)) {
            Response res = new Response();
            res.message = 'Checklist ID and Name are required for Update action.';
            return res;
        }
        Checklist__c toUpdate = new Checklist__c(Id = req.checklistId, Name = req.checklistName);
        FRAGENTGeneralService.Result serviceResult = FRAGENTChecklistService.updateRecords(new List<Checklist__c>{toUpdate});
        return processServiceResult(serviceResult, 'Checklist updated successfully.');
    }
    
    private static Response handleDelete(Request req) {
        if (req.checklistId == null) {
            Response res = new Response();
            res.message = 'Checklist ID is required for Delete action.';
            return res;
        }
        FRAGENTGeneralService.Result serviceResult = FRAGENTChecklistService.remove(new List<Id>{req.checklistId});
        return processServiceResult(serviceResult, 'Checklist deleted successfully.');
    }
    
    private static Response handleSearch(Request req) {
        String searchTerm = String.isNotBlank(req.searchTerm) ? req.searchTerm : req.checklistName;
        if (String.isBlank(searchTerm) && String.isBlank(req.dateLiteral) && req.startDate == null && req.endDate == null) {
            Response res = new Response();
            res.message = 'A search term or a date criterion is required for a Search action.';
            return res;
        }
        
        FRAGENTChecklistService.SearchResult serviceResult = FRAGENTChecklistService.search(
            searchTerm, req.dateFieldToSearch, req.dateLiteral, req.startDate, req.endDate, req.recordLimit, req.offset
        );
        
        Response res = new Response();
        res.success = serviceResult.success;
        if (serviceResult.success) {
            res.totalRecordCount = serviceResult.totalCount;
            res.message = 'Search successful. Found ' + serviceResult.totalCount + ' total checklist(s).';
            if (serviceResult.records != null) {
                res.records = (List<Checklist__c>)serviceResult.records;
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
                res.records = (List<Checklist__c>)serviceResult.records;
            }
        } else {
            res.message = String.join(serviceResult.errors, '; ');
        }
        return res;
    }
}