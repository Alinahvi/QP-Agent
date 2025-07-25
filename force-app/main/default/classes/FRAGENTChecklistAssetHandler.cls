/**
 * TEMPLATE HANDLER - This class acts as agent instructions in our handler/service template.
 * Business Requirement: Responses include both Ids and Names when applicable to meet user-friendly output requirements.
 * The handler validates requests and delegates business logic to the service layer.
 * @description Handler class for all operations related to Checklist Asset records.
 * This class is the primary entry point for the AI agent to create, find, modify, or delete checklist items.
 * It validates requests and routes them to the FRAGENTChecklistAssetService for execution.
 *
 * The service ensures `Checklist__c`, content lookups, ordering fields and
 * description values are returned along with `CreatedDate` and
 * `LastModifiedDate`.
 *
 * @version 4.0
 */
public with sharing class FRAGENTChecklistAssetHandler {
    
    public class Request {
        @InvocableVariable(label='Action Type' required=true description='Specifies the operation: "Create", "Read", "Update", "Delete", or "Search".')
        public String action;

        @InvocableVariable(label='Checklist Asset ID' description='The unique 18-character Salesforce ID of a Checklist Asset record. Required for "Read", "Update", and "Delete" actions.')
        public Id checklistAssetId;
        
        @InvocableVariable(label='Checklist ID' description='The ID of the parent Checklist. Required for "Create". Can be used as a filter for "Search".')
        public Id checklistId;
        
        @InvocableVariable(label='Asset ID' description='The ID of the Asset to associate. Used for "Create" or "Update".')
        public Id assetId;

        @InvocableVariable(label='Course ID' description='The ID of the Course to associate. Used for "Create" or "Update".')
        public Id courseId;

        @InvocableVariable(label='Curriculum ID' description='The ID of the Curriculum to associate. Used for "Create" or "Update".')
        public Id curriculumId;

        @InvocableVariable(label='Actions' description='A description of the actions to be taken for this checklist item.')
        public String actions;

        @InvocableVariable(label='Description' description='A detailed description of the checklist item.')
        public String description;

        @InvocableVariable(label='Order' description='The numerical order of this item within the checklist.')
        public Integer order;

        @InvocableVariable(label='Week' description='The week number this item belongs to.')
        public Integer week;
        
        @InvocableVariable(label='Day' description='The day number this item belongs to.')
        public Integer day;

        @InvocableVariable(label='General Search Term' description='A keyword to search in the Description field.')
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
        
        @InvocableVariable(label='Returned Records' description='A list of Checklist_Asset__c records that were created, updated, or found.')
        public List<Checklist_Asset__c> records;
        
        @InvocableVariable(label='Total Matching Record Count' description='For "Search", the total number of records matching the criteria, used for pagination.')
        public Integer totalRecordCount;
        
        public Response() {
            this.success = false;
            this.records = new List<Checklist_Asset__c>();
            this.totalRecordCount = 0;
        }
    }

    @InvocableMethod(label='FRAGENT Manage Checklist Asset' description='Performs Create, Read, Update, Delete, and Search operations on Checklist Asset records.')
    public static List<Response> manageChecklistAssets(List<Request> requests) {
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
        if (req.checklistId == null) {
            Response res = new Response();
            res.message = 'Checklist ID is required for Create action.';
            return res;
        }
        Checklist_Asset__c newAsset = new Checklist_Asset__c(
            Checklist__c = req.checklistId, Asset__c = req.assetId, Course__c = req.courseId, Curriculum__c = req.curriculumId,
            Actions__c = req.actions, Description__c = req.description, Order__c = req.order, Week__c = req.week, Day__c = req.day
        );
        FRAGENTGeneralService.Result serviceResult = FRAGENTChecklistAssetService.create(new List<Checklist_Asset__c>{newAsset});
        return processServiceResult(serviceResult, 'Checklist Asset created successfully.');
    }
    
    private static Response handleRead(Request req) {
        if (req.checklistAssetId == null) {
            Response res = new Response();
            res.message = 'Checklist Asset ID is required for Read action.';
            return res;
        }
        FRAGENTGeneralService.Result serviceResult = FRAGENTChecklistAssetService.getById(req.checklistAssetId);
        return processServiceResult(serviceResult, 'Checklist Asset retrieved successfully.');
    }
    
    private static Response handleUpdate(Request req) {
        if (req.checklistAssetId == null) {
            Response res = new Response();
            res.message = 'Checklist Asset ID is required for Update action.';
            return res;
        }
        Checklist_Asset__c toUpdate = new Checklist_Asset__c(
            Id = req.checklistAssetId, Asset__c = req.assetId, Course__c = req.courseId, Curriculum__c = req.curriculumId,
            Actions__c = req.actions, Description__c = req.description, Order__c = req.order, Week__c = req.week, Day__c = req.day
        );
        FRAGENTGeneralService.Result serviceResult = FRAGENTChecklistAssetService.updateRecords(new List<Checklist_Asset__c>{toUpdate});
        return processServiceResult(serviceResult, 'Checklist Asset updated successfully.');
    }
    
    private static Response handleDelete(Request req) {
        if (req.checklistAssetId == null) {
            Response res = new Response();
            res.message = 'Checklist Asset ID is required for Delete action.';
            return res;
        }
        FRAGENTGeneralService.Result serviceResult = FRAGENTChecklistAssetService.remove(new List<Id>{req.checklistAssetId});
        return processServiceResult(serviceResult, 'Checklist Asset deleted successfully.');
    }
    
    private static Response handleSearch(Request req) {
        if (req.checklistId == null && String.isBlank(req.searchTerm) && String.isBlank(req.dateLiteral) && req.startDate == null && req.endDate == null) {
            Response res = new Response();
            res.message = 'A Checklist ID, search term, or date criterion is required for a Search action.';
            return res;
        }
        
        FRAGENTChecklistAssetService.SearchResult serviceResult = FRAGENTChecklistAssetService.search(
            req.checklistId, req.searchTerm, req.dateFieldToSearch, req.dateLiteral, req.startDate, req.endDate, req.recordLimit, req.offset
        );
        
        Response res = new Response();
        res.success = serviceResult.success;
        if (serviceResult.success) {
            res.totalRecordCount = serviceResult.totalCount;
            res.message = 'Search successful. Found ' + serviceResult.totalCount + ' total checklist asset(s).';
            if (serviceResult.records != null) {
                res.records = (List<Checklist_Asset__c>)serviceResult.records;
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
                res.records = (List<Checklist_Asset__c>)serviceResult.records;
            }
        } else {
            res.message = String.join(serviceResult.errors, '; ');
        }
        return res;
    }
}