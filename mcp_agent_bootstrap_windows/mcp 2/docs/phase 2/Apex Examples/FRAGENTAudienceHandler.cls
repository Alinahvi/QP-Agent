/**
 * TEMPLATE HANDLER (Entry Point)
 *
 * 1) Template Type: Handler/Service template. This is the Handler layer.
 * 2) Business Logic Location: Business rules live in FRAGENTAudienceService. The handler only validates
 *    inputs and routes calls.
 * 3) Important Code: manageAudiences(...) is the only invocable entry. processServiceResult(...) translates
 *    service results into user-friendly output.
 * 4) Hardcoded Values: None in this class; all required fields and labels are handled in the Service.
 * 5) Plain Language: This class helps the agent do audience actions (create, find, update, delete) and
 *    explains results clearly.
 *
 * The service fetches `Audience__c` records selecting `Name`, `CreatedDate`, `LastModifiedDate`, `CreatedById`,
 * `CreatedBy.Name`, `LastModifiedById`, and `LastModifiedBy.Name` so downstream consumers always receive these fields.
 *
 * For AI Operators
 * - Cross-function playbook:
 *   - Before deleting an Audience, call Assigned Learning (Retrieve by Audience). If any records exist, do not delete.
 *   - After creating an Audience, add members via Audience Member handler; optionally assign a Checklist via Audience Checklist.
 * - Allowed values and rules:
 *   - dateFieldToSearch: [CreatedDate, LastModifiedDate]
 *   - Date precedence: dateLiteral takes precedence over start/end dates.
 * - Unsupported actions: None (Create/Retrieve/Update/Delete supported).
 * - Defaults & pagination: If not specified, recordLimit defaults to 50. Prefer returning ≤ 15 records by default; page using narrower filters or successive date windows.
 * - Permission/visibility: Executes with sharing (user mode). Empty results may be due to object/field visibility.
 * - Error semantics: Use machine-readable prefixes when blocking deletes, e.g., "BLOCKED: MEMBERS_EXIST" or "BLOCKED: ASSIGNED_LEARNING_EXISTS".
 * - Clarifying question templates:
 *   - Search: "Confirm name, creator, and timeframe; cap results at 15?"
 *   - Writes: "Confirm create/update/delete; here is the impact summary. Proceed?"
 * - Naming/data conventions: For onboarding cohorts, use "<Prefix> - <Region>/<City> - <MM/DD>"; validate per team rules.
 * - Timezone & dates: Interpret startDate/endDate in org timezone; SOQL date literals are server-evaluated.
 * - Return contract snippet: AudienceDetails includes Id, Name, CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name, and member count summary.
 * - Example:
 *   - Retrieve by name in last 30 days → return audiences with core fields and counts; suggest adding members or assigning a checklist.
 *
 * @version 2.8
 */
public with sharing class FRAGENTAudienceHandler {
    
    public class Request {
        @InvocableVariable(
            label='Action Type'
            description='Specifies the operation to perform on Audience__c and its related Audience_Member__c and Audience_Checklist__c records. Must be one of the following exact string values: "Create", "Retrieve", "Update", or "Delete". This parameter determines which logic branch is executed.'
            required=true
        )
        public String action;

        @InvocableVariable(
            label='Audience Record ID'
            description='The unique 18-character Salesforce ID for a specific Audience__c record (Audience__c.Id). Use this ONLY for "Retrieve", "Update", and "Delete" actions when the user provides a specific ID. The ID also ties to any related Audience_Member__c and Audience_Checklist__c records.'
        )
        public Id audienceId;
        
        @InvocableVariable(
            label='Audience Name'
            description='The human-readable name of the Audience (Audience__c.Name). REQUIRED for the "Create" action. For "Retrieve", this filters audiences by exact or partial name matches.'
        )
        public String audienceName;
        
        @InvocableVariable(
            label='Date Field to Search'
            description='Specifies which Audience__c date field to search when using date-based filtering: "CreatedDate" or "LastModifiedDate". If not specified, defaults to "CreatedDate". This parameter is used in conjunction with dateLiteral, startDate, or endDate parameters and narrows which related Audience_Member__c and Audience_Checklist__c records are returned.'
        )
        public String dateFieldToSearch;

        @InvocableVariable(
            label='Date Literal for Retrieve'
            // FIX: Heavily expanded description with explicit examples and rules for the AI.
            description='For a date-based retrieval using a relative period, use ONLY a valid Salesforce SOQL Date Literal. The search checks the specified Audience__c date field (or CreatedDate by default). Examples of valid literals include: TODAY, YESTERDAY, LAST_WEEK, THIS_MONTH, LAST_90_DAYS. For a specific number of days, use the format "LAST_N_DAYS:45" or "NEXT_N_DAYS:30". This parameter takes precedence over start/end dates. A specific date like "2025-06-02" or a format like "LAST_10_DAYS" are INVALID and will cause an error. Use startDate and endDate for specific dates. This filter indirectly limits the related Audience_Member__c and Audience_Checklist__c records returned.'
        )
        public String dateLiteral;

        @InvocableVariable(
            label='Retrieve Start Date'
            description='Use this field for retrieving records for an ABSOLUTE date or the beginning of a custom date range against Audience__c date fields. For a query like "on June 2nd, 2025", set BOTH this `startDate` and the `endDate` to "2025-06-02". For "since June 1st", set this field to "2025-06-01". This range determines which related Audience_Member__c and Audience_Checklist__c records are considered.'
        )
        public Date startDate;

        @InvocableVariable(
            label='Retrieve End Date'
            description='Use this field for the end of a custom date range (inclusive) against Audience__c date fields. For a query like "before July 3rd", set this field to "2025-07-02". To retrieve records on a SINGLE specific day, set BOTH this `endDate` and the `startDate` to that same day. This range determines which related Audience_Member__c and Audience_Checklist__c records are considered.'
        )
        public Date endDate;

        @InvocableVariable(
            label='Created By User ID'
            description='Filters results to audiences created by this user (Audience__c.CreatedById). Use this for the "Retrieve" action.'
        )
        public Id createdByUserId;

        @InvocableVariable(
            label='Record Limit for Retrieve'
            description='Optional. Limits the number of Audience__c records returned with their related Audience_Member__c and Audience_Checklist__c details. Use lower values to narrow results or higher values to broaden them.'
        )
        public Integer recordLimit;
        
    }
    
    public class Response {
        @InvocableVariable(
            label='Operation Succeeded'
            description='A boolean value indicating the outcome of work on Audience__c records and their related Audience_Member__c and Audience_Checklist__c associations. Returns `true` if the entire operation was completed successfully. Returns `false` if any error occurred, including permission errors or validation failures.'
        )
        public Boolean success;

        @InvocableVariable(
            label='Permission Denied'
            description='True when the underlying service blocked the action due to missing permissions. This provides a stable flag for flows/tests beyond error message text.'
        )
        public Boolean permissionDenied;

        @InvocableVariable(
            label='Audience Details'
            description='Wrapper containing the feedback message, total matching record count, and returned Audience records.'
        )
        public AudienceResultPayload audienceDetails;

        public Response() {
            this.success = false;
            this.permissionDenied = false;
            this.audienceDetails = new AudienceResultPayload();
        }
    }

    public class AudienceResultPayload {
        @InvocableVariable(
            label='Feedback Message'
            description='A detailed, human-readable message describing the result of the operation across Audience__c and any related Audience_Member__c or Audience_Checklist__c records. For successes, it confirms the action (e.g., "Audience created successfully"). For failures, it provides specific error details (e.g., "Insufficient permissions: Missing Permission Set...") that can be relayed to the user.'
        )
        public String message;

        @InvocableVariable(
            label='Total Matching Record Count'
            description='For a "Retrieve" action that returns multiple records, this provides the total number of Audience__c records that matched the specified criteria, even if only a subset was returned due to the Record Limit. This count also reflects how many sets of related Audience_Member__c and Audience_Checklist__c records exist. Use this value to determine if pagination is needed (e.g., if totalRecordCount is greater than the size of the returned records list).'
        )
        public Integer totalRecordCount;

        @InvocableVariable(
            label='Returned Audience Records'
            description='A list of AudienceDetails entries for Audience__c records that were created, updated, or retrieved by the operation. When displaying DateTime fields like CreatedDate or LastModifiedDate to the user, format them as a simple date (e.g., "YYYY-MM-DD") and omit the time details.'
        )
        public List<FRAGENTAudienceService.AudienceDetails> records;

        public AudienceResultPayload() {
            this.totalRecordCount = 0;
            this.records = new List<FRAGENTAudienceService.AudienceDetails>();
        }
    }

    @InvocableMethod(
        label='FRAGENT Manage Audience'
        description='Create, retrieve, update, or delete Audience cohorts. Filter by Id, Name, creator, and Created/LastModified dates. Returns core fields and member counts. Deletion is blocked if members exist or they have assigned learning. Confirm writes.'
    )
    public static List<Response> manageAudiences(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();
            
            try {
                if (String.isBlank(req.action)) {
                    res.audienceDetails.message = 'Action parameter is required.';
                    responses.add(res);
                    continue;
                }
                
                String action = req.action.toLowerCase();

                switch on action {
                    when 'create' { res = handleCreate(req); }
                    when 'retrieve' { res = handleRetrieve(req); }
                    when 'update' { res = handleUpdate(req); }
                    when 'delete' { res = handleDelete(req); }
                    when else {
                        res.audienceDetails.message = 'Invalid action: ' + req.action;
                    }
                }
                
            } catch (AuraHandledException e) {
                res.success = false;
                res.audienceDetails.message = e.getMessage();
            } catch (Exception e) {
                res.success = false;
                res.audienceDetails.message = 'An unexpected error occurred in the handler: ' + e.getMessage();
            }
            
            responses.add(res);
        }
        return responses;
    }
    
    private static Response handleCreate(Request req) {
        Audience__c newAudience = new Audience__c(Name = req.audienceName);
        AgentCore_Result serviceResult = FRAGENTAudienceService.createAudiences(new List<Audience__c>{newAudience});
        return processServiceResult(serviceResult);
    }
    
    private static Response handleUpdate(Request req) {
        Audience__c updateAudience = new Audience__c(Id = req.audienceId, Name = req.audienceName);
        AgentCore_Result serviceResult = FRAGENTAudienceService.updateAudiences(new List<Audience__c>{updateAudience});
        return processServiceResult(serviceResult);
    }
    
    private static Response handleRetrieve(Request req) {
        FRAGENTAudienceService.AudienceResult serviceResult = FRAGENTAudienceService.retrieveAudiences(
            req.audienceId, req.audienceName, req.dateFieldToSearch, req.dateLiteral,
            req.startDate, req.endDate, req.createdByUserId, req.recordLimit
        );
        return processServiceResult(serviceResult);
    }

    private static Response handleDelete(Request req) {
        if (req.audienceId == null) {
            Response res = new Response();
            res.success = false;
            res.audienceDetails.message = 'Audience ID is required for Delete action.';
            return res;
        }
        AgentCore_Result serviceResult = FRAGENTAudienceService.deleteAudiences(new List<Id>{req.audienceId});
        return processServiceResult(serviceResult);
    }

    private static Response processServiceResult(AgentCore_Result serviceResult) {
        Response res = new Response();
        res.success = serviceResult.success;
        res.audienceDetails.message = serviceResult.message;

        if (serviceResult instanceof FRAGENTAudienceService.AudienceResult) {
            FRAGENTAudienceService.AudienceResult ar =
                (FRAGENTAudienceService.AudienceResult)serviceResult;
            res.audienceDetails.totalRecordCount = ar.totalCount;
            res.audienceDetails.records =
                ar.audienceDetails != null
                ? ar.audienceDetails
                : new List<FRAGENTAudienceService.AudienceDetails>();
            if (ar.permissionDenied == true) {
                res.permissionDenied = true;
            }
        } else if (serviceResult.records != null) {
            res.audienceDetails.records = new List<FRAGENTAudienceService.AudienceDetails>();
            for (SObject s : serviceResult.records) {
                Audience__c aud = (Audience__c)s;
                res.audienceDetails.records.add(new FRAGENTAudienceService.AudienceDetails(
                    aud, 0, new List<FRAGENTAudienceService.AudienceMemberSummary>()));
            }
        }
        return res;
    }
}

