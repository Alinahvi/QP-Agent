public with sharing class GAEOA2WorkHandler1 {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 Work ID' description='Salesforce Work record ID. Required for Modify action.')
        public String workId;
        
        // --- agf__ADM_Work__c Fields Part 1 ---
        @InvocableVariable(label='GA-EOA2 Subject' description='Value for the Subject (agf__Subject__c) field.')
        public String agfSubject;
        @InvocableVariable(label='GA-EOA2 Owner ID' description='Value for the Owner ID (OwnerId) field.')
        public String ownerid;
        @InvocableVariable(label='GA-EOA2 Record Type ID' description='Value for the Record Type ID (RecordTypeId) field.')
        public String recordtypeid;
        @InvocableVariable(label='GA-EOA2 Additional Details' description='Value for the Additional Details (agf__Additional_Details__c) field.')
        public String agfAdditionalDetails;
        @InvocableVariable(label='GA-EOA2 Apex Hammer Compile Failure' description='Value for the Apex Hammer Compile Failure (agf__Apex_Hammer_Compile_Failure__c) field.')
        public Boolean agfApexHammerCompileFailure;
        @InvocableVariable(label='GA-EOA2 Assigned On' description='Value for the Assigned On (agf__Assigned_On__c) field. Supported formats: YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public Date agfAssignedOn;
        @InvocableVariable(label='GA-EOA2 Assigned To' description='Value for the Assigned To (agf__Assignee__c) field.')
        public String agfAssignee;
        @InvocableVariable(label='GA-EOA2 transfer Assignees' description='Value for the transfer Assignees (agf__Assignees__c) field.')
        public String agfAssignees;
        @InvocableVariable(label='GA-EOA2 Attributes' description='Value for the Attributes (agf__Attributes__c) field.')
        public String agfAttributes;
        @InvocableVariable(label='GA-EOA2 Auto Build' description='Value for the Auto Build (agf__Auto_Build__c) field.')
        public String agfAutoBuild;
        @InvocableVariable(label='GA-EOA2 Backburner Rank' description='Value for the Backburner Rank (agf__Backburner_Rank__c) field.')
        public Decimal agfBackburnerRank;
        @InvocableVariable(label='GA-EOA2 Board Column Rank' description='Value for the Board Column Rank (agf__Board_Column_Rank__c) field.')
        public Decimal agfBoardColumnRank;
        @InvocableVariable(label='GA-EOA2 Board Column' description='Value for the Board Column (agf__Board_Column__c) field.')
        public String agfBoardColumn;
        @InvocableVariable(label='GA-EOA2 Branch' description='Value for the Branch (agf__Branch__c) field.')
        public String agfBranch;
        @InvocableVariable(label='GA-EOA2 Budget ID' description='Value for the Budget ID (agf__Budget_ID__c) field.')
        public String agfBudgetId;
        @InvocableVariable(label='GA-EOA2 Bugforce #' description='Value for the Bugforce # (agf__Bug_Number__c) field.')
        public String agfBugNumber;
        @InvocableVariable(label='GA-EOA2 Support Contact' description='Value for the Support Contact (agf__CS_Contact__c) field.')
        public String agfCsContact;
        @InvocableVariable(label='GA-EOA2 New Customer Facing Feature' description='Value for the New Customer Facing Feature (agf__Capex_Enabled__c) field.')
        public Boolean agfCapexEnabled;
        @InvocableVariable(label='GA-EOA2 Catch-up Factor' description='Value for the Catch-up Factor (agf__Catchup_Factor__c) field.')
        public Decimal agfCatchupFactor;
        @InvocableVariable(label='GA-EOA2 Child_ID' description='Value for the Child_ID (agf__Child_ID__c) field.')
        public String agfChildId;
        @InvocableVariable(label='GA-EOA2 Closed By' description='Value for the Closed By (agf__Closed_By__c) field.')
        public String agfClosedBy;
        @InvocableVariable(label='GA-EOA2 Closed On' description='Value for the Closed On (agf__Closed_On__c) field. Supported formats: YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public Datetime agfClosedOn;
        @InvocableVariable(label='GA-EOA2 Color' description='Value for the Color (agf__Color__c) field.')
        public String agfColor;
        @InvocableVariable(label='GA-EOA2 Column Rank' description='Value for the Column Rank (agf__Column_Rank__c) field.')
        public Decimal agfColumnRank;
        @InvocableVariable(label='GA-EOA2 Column' description='Value for the Column (agf__Column__c) field.')
        public String agfColumn;
        @InvocableVariable(label='GA-EOA2 Comment Copy' description='Value for the Comment Copy (agf__Comment_Copy__c) field.')
        public String agfCommentCopy;
        @InvocableVariable(label='GA-EOA2 Complete By' description='Value for the Complete By (agf__Complete_By__c) field.')
        public String agfCompleteBy;
        @InvocableVariable(label='GA-EOA2 Created By (import)' description='Value for the Created By (import) (agf__Created_By_import__c) field.')
        public String agfCreatedByImport;
        @InvocableVariable(label='GA-EOA2 Created On (import)' description='Value for the Created On (import) (agf__Created_On_import__c) field. Supported formats: YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public Datetime agfCreatedOnImport;
        @InvocableVariable(label='GA-EOA2 Critical CRM Feature or Org Inaccessible' description='Value for the Critical CRM Feature or Org Inaccessible (agf__Critical_CRM_Feature__c) field.')
        public Boolean agfCriticalCrmFeature;
        @InvocableVariable(label='GA-EOA2 Customer Impact' description='Value for the Customer Impact (agf__Customer_Impact__c) field.')
        public String agfCustomerImpact;
        @InvocableVariable(label='GA-EOA2 Customer' description='Value for the Customer (agf__Customer__c) field.')
        public String agfCustomer;
        @InvocableVariable(label='GA-EOA2 Data Silo Test Affected' description='Value for the Data Silo Test Affected (agf__Data_Silo_Test_Affected__c) field.')
        public Boolean agfDataSiloTestAffected;
        @InvocableVariable(label='GA-EOA2 Deal at Risk' description='Value for the Deal at Risk (agf__Deal_at_Risk__c) field.')
        public String agfDealAtRisk;
        @InvocableVariable(label='GA-EOA2 Dependencies' description='Value for the Dependencies (agf__Dependencies__c) field.')
        public Decimal agfDependencies;
        @InvocableVariable(label='GA-EOA2 Dependents' description='Value for the Dependents (agf__Dependents__c) field.')
        public Decimal agfDependents;
        @InvocableVariable(label='GA-EOA2 Comment' description='Value for the Comment (agf__Description__c) field.')
        public String agfDescription;
        @InvocableVariable(label='GA-EOA2 Exclude from Prioritize View' description='Value for the Exclude from Prioritize View (agf__Detailed__c) field.')
        public Boolean agfDetailed;
        @InvocableVariable(label='GA-EOA2 Description' description='Value for the Description (agf__Details__c) field.')
        public String agfDetails;
    }
    
    public class Response {
        @InvocableVariable(label='GA-EOA2 Success' description='True if the operation succeeded.')
        public Boolean success = false;
        @InvocableVariable(label='GA-EOA2 Message' description='Summary of the operation result.')
        public String message = '';
        @InvocableVariable(label='GA-EOA2 Work Records' description='List of Work records from the operation.')
        public List<agf__ADM_Work__c> workRecords = new List<agf__ADM_Work__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Work Records (Part 1)' description='Handles Create and Modify for a subset of Work fields. Use for creating new work items or updating the first group of fields.')
    public static List<Response> manageWork1(List<Request> requests) {
        List<agf__ADM_Work__c> toCreate = new List<agf__ADM_Work__c>();
        List<agf__ADM_Work__c> toUpdate = new List<agf__ADM_Work__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            responseMap.put(i, new Response());
            Request req = requests.get(i);
            if (req.actionType == 'Create') {
                if (String.isBlank(req.agfSubject)) {
                    responseMap.get(i).message = 'Error: Subject is required for creation.';
                } else {
                    toCreate.add(mapRequestToWork(req, new agf__ADM_Work__c()));
                }
            } else if (req.actionType == 'Modify') {
                if (String.isBlank(req.workId)) {
                    responseMap.get(i).message = 'Error: Work ID is required for Modify.';
                } else {
                    idsToProcess.add(req.workId);
                }
            } else {
                responseMap.get(i).message = 'Error: Invalid action. This handler only supports Create and Modify.';
            }
        }

        if (!toCreate.isEmpty()) {
            Database.SaveResult[] createResults = Database.insert(toCreate, false);
            handleDmlResults(createResults, toCreate, 'Create', requests, responseMap);
        }

        if (!idsToProcess.isEmpty()) {
            Map<Id, agf__ADM_Work__c> worksFromDb = new Map<Id, agf__ADM_Work__c>([SELECT Id FROM agf__ADM_Work__c WHERE Id IN :idsToProcess]);
            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (req.actionType == 'Modify' && String.isNotBlank(req.workId) && worksFromDb.containsKey(req.workId)) {
                    toUpdate.add(mapRequestToWork(req, worksFromDb.get(req.workId)));
                }
            }
        }
        
        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            handleDmlResults(updateResults, toUpdate, 'Modify', requests, responseMap);
        }
        
        return new List<Response>(responseMap.values());
    }

    private static agf__ADM_Work__c mapRequestToWork(Request req, agf__ADM_Work__c work) {
        if(req.workId != null) work.Id = req.workId;
        if(req.agfSubject != null) work.agf__Subject__c = req.agfSubject;
        if(req.ownerid != null) work.OwnerId = req.ownerid;
        if(req.recordtypeid != null) work.RecordTypeId = req.recordtypeid;
        if(req.agfAdditionalDetails != null) work.agf__Additional_Details__c = req.agfAdditionalDetails;
        if(req.agfApexHammerCompileFailure != null) work.agf__Apex_Hammer_Compile_Failure__c = req.agfApexHammerCompileFailure;
        if(req.agfAssignedOn != null) work.agf__Assigned_On__c = req.agfAssignedOn;
        if(req.agfAssignee != null) work.agf__Assignee__c = req.agfAssignee;
        if(req.agfAssignees != null) work.agf__Assignees__c = req.agfAssignees;
        if(req.agfAttributes != null) work.agf__Attributes__c = req.agfAttributes;
        if(req.agfAutoBuild != null) work.agf__Auto_Build__c = req.agfAutoBuild;
        if(req.agfBackburnerRank != null) work.agf__Backburner_Rank__c = req.agfBackburnerRank;
        if(req.agfBoardColumnRank != null) work.agf__Board_Column_Rank__c = req.agfBoardColumnRank;
        if(req.agfBoardColumn != null) work.agf__Board_Column__c = req.agfBoardColumn;
        if(req.agfBranch != null) work.agf__Branch__c = req.agfBranch;
        if(req.agfBudgetId != null) work.agf__Budget_ID__c = req.agfBudgetId;
        if(req.agfBugNumber != null) work.agf__Bug_Number__c = req.agfBugNumber;
        if(req.agfCsContact != null) work.agf__CS_Contact__c = req.agfCsContact;
        if(req.agfCapexEnabled != null) work.agf__Capex_Enabled__c = req.agfCapexEnabled;
        if(req.agfCatchupFactor != null) work.agf__Catchup_Factor__c = req.agfCatchupFactor;
        if(req.agfChildId != null) work.agf__Child_ID__c = req.agfChildId;
        if(req.agfClosedBy != null) work.agf__Closed_By__c = req.agfClosedBy;
        if(req.agfClosedOn != null) work.agf__Closed_On__c = req.agfClosedOn;
        if(req.agfColor != null) work.agf__Color__c = req.agfColor;
        if(req.agfColumnRank != null) work.agf__Column_Rank__c = req.agfColumnRank;
        if(req.agfColumn != null) work.agf__Column__c = req.agfColumn;
        if(req.agfCommentCopy != null) work.agf__Comment_Copy__c = req.agfCommentCopy;
        if(req.agfCompleteBy != null) work.agf__Complete_By__c = req.agfCompleteBy;
        if(req.agfCreatedByImport != null) work.agf__Created_By_import__c = req.agfCreatedByImport;
        if(req.agfCreatedOnImport != null) work.agf__Created_On_import__c = req.agfCreatedOnImport;
        if(req.agfCriticalCrmFeature != null) work.agf__Critical_CRM_Feature__c = req.agfCriticalCrmFeature;
        if(req.agfCustomerImpact != null) work.agf__Customer_Impact__c = req.agfCustomerImpact;
        if(req.agfCustomer != null) work.agf__Customer__c = req.agfCustomer;
        if(req.agfDataSiloTestAffected != null) work.agf__Data_Silo_Test_Affected__c = req.agfDataSiloTestAffected;
        if(req.agfDealAtRisk != null) work.agf__Deal_at_Risk__c = req.agfDealAtRisk;
        if(req.agfDependencies != null) work.agf__Dependencies__c = req.agfDependencies;
        if(req.agfDependents != null) work.agf__Dependents__c = req.agfDependents;
        if(req.agfDescription != null) work.agf__Description__c = req.agfDescription;
        if(req.agfDetailed != null) work.agf__Detailed__c = req.agfDetailed;
        if(req.agfDetails != null) work.agf__Details__c = req.agfDetails;
        return work;
    }
    
    private static void handleDmlResults(Database.SaveResult[] results, List<agf__ADM_Work__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            if (req.actionType == action && (action == 'Create' ? String.isNotBlank(req.agfSubject) : String.isNotBlank(req.workId))) {
                 if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Work ' + action.toLowerCase() + 'd successfully.';
                        res.workRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                 }
            }
        }
    }
}