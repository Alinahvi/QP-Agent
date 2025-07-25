public with sharing class GAEOA2IssueHandler {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 Issue ID' description='Salesforce Issue record ID. Required for Modify and Retrieve actions.')
        public String issueId;

        // --- Issue__c Fields ---
        @InvocableVariable(label='GA-EOA2 Issue Name' description='Value for the Issue Name (Issue_Name__c) field.')
        public String issueName;
        @InvocableVariable(label='GA-EOA2 Status' description='Value for the Status (Status__c) field.')
        public String status;
        @InvocableVariable(label='GA-EOA2 Priority' description='Value for the Priority (Priority__c) field.')
        public String priority;
        @InvocableVariable(label='GA-EOA2 Identified On' description='Value for the Identified On (Identified_On__c) field. Format: YYYY-MM-DD')
        public Date identifiedOn;
        @InvocableVariable(label='GA-EOA2 Target Close Date' description='Value for the Target Close Date (Target_Close_Date__c) field. Format: YYYY-MM-DD')
        public Date targetCloseDate;
        @InvocableVariable(label='GA-EOA2 Close Date' description='Value for the Close Date (Close_Date__c) field. Format: YYYY-MM-DD')
        public Date closeDate;
        @InvocableVariable(label='GA-EOA2 Issue Summary' description='Value for the Issue Summary (Issue_Summary__c) field.')
        public String issueSummary;
        @InvocableVariable(label='GA-EOA2 Issue Resolution Plan' description='Value for the Issue Resolution Plan (Issue_Resolution_Plan__c) field.')
        public String issueResolutionPlan;
        @InvocableVariable(label='GA-EOA2 Issue Resolution Comments' description='Value for the Issue Resolution Comments (Issue_Resolution_Comments__c) field.')
        public String issueResolutionComments;
        @InvocableVariable(label='GA-EOA2 Project' description='Salesforce ID of the related Project (Project__c).')
        public String projectId;
        @InvocableVariable(label='GA-EOA2 Program' description='Salesforce ID of the related Program (Program__c).')
        public String programId;
        @InvocableVariable(label='GA-EOA2 Epic' description='Salesforce ID of the related Epic (Epic__c).')
        public String epicId;
        @InvocableVariable(label='GA-EOA2 Risk' description='Salesforce ID of the related Risk (Risk__c).')
        public String riskId;
        @InvocableVariable(label='GA-EOA2 Work Item' description='Salesforce ID of the related Work Item (Work_Item__c).')
        public String workItemId;
        @InvocableVariable(label='GA-EOA2 Team' description='Salesforce ID of the related Team (Team__c).')
        public String teamId;
        @InvocableVariable(label='GA-EOA2 Owner' description='Salesforce ID of the record owner.')
        public String ownerId;
        
        // --- Search Fields ---
        @InvocableVariable(label='GA-EOA2 Created Date' description='For search operations. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals.')
        public String createdDate;
        @InvocableVariable(label='GA-EOA2 Last Modified Date' description='For search operations. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals.')
        public String lastModifiedDate;
    }

    public class Response {
        @InvocableVariable(label='GA-EOA2 Success' description='True if the operation succeeded.')
        public Boolean success = false;
        @InvocableVariable(label='GA-EOA2 Message' description='Summary of the operation result.')
        public String message = '';
        @InvocableVariable(label='GA-EOA2 Issue Records' description='List of Issue records from the operation.')
        public List<Issue__c> issueRecords = new List<Issue__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Issues' description='Handles Create, Modify, Retrieve, and Search actions for Issue records.')
    public static List<Response> manageIssues(List<Request> requests) {
        List<Issue__c> toCreate = new List<Issue__c>();
        List<Issue__c> toUpdate = new List<Issue__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            responseMap.put(i, new Response());
            Request req = requests.get(i);
            
            switch on req.actionType {
                when 'Create' {
                    toCreate.add(mapRequestToIssue(req, new Issue__c()));
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.issueId)) {
                        responseMap.get(i).message = 'Error: Issue ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.issueId);
                    }
                }
                when 'Search' {
                    handleSearch(req, responseMap.get(i));
                }
                when else {
                    responseMap.get(i).message = 'Error: Invalid action type specified.';
                }
            }
        }
        
        if (!toCreate.isEmpty()) {
            Database.SaveResult[] createResults = Database.insert(toCreate, false);
            handleDmlResults(createResults, toCreate, 'Create', requests, responseMap);
        }
        
        if (!idsToProcess.isEmpty()) {
            String allFieldsQuery = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Issue__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM Issue__c WHERE Id IN :idsToProcess';
            Map<Id, Issue__c> issuesFromDb = new Map<Id, Issue__c>((List<Issue__c>)Database.query(allFieldsQuery));

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                Response res = responseMap.get(i);
                
                if (String.isNotBlank(req.issueId) && issuesFromDb.containsKey(req.issueId)) {
                    if (req.actionType == 'Modify') {
                        toUpdate.add(mapRequestToIssue(req, issuesFromDb.get(req.issueId)));
                    } else if (req.actionType == 'Retrieve') {
                        res.success = true;
                        res.message = 'Issue retrieved successfully.';
                        res.issueRecords.add(issuesFromDb.get(req.issueId));
                    }
                }
            }
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            handleDmlResults(updateResults, toUpdate, 'Modify', requests, responseMap);
        }
        
        return new List<Response>(responseMap.values());
    }

    private static Issue__c mapRequestToIssue(Request req, Issue__c issue) {
        if(req.actionType == 'Modify') issue.Id = req.issueId;
        if(req.issueName != null) issue.Issue_Name__c = req.issueName;
        if(req.status != null) issue.Status__c = req.status;
        if(req.priority != null) issue.Priority__c = req.priority;
        if(req.identifiedOn != null) issue.Identified_On__c = req.identifiedOn;
        if(req.targetCloseDate != null) issue.Target_Close_Date__c = req.targetCloseDate;
        if(req.closeDate != null) issue.Close_Date__c = req.closeDate;
        if(req.issueSummary != null) issue.Issue_Summary__c = req.issueSummary;
        if(req.issueResolutionPlan != null) issue.Issue_Resolution_Plan__c = req.issueResolutionPlan;
        if(req.issueResolutionComments != null) issue.Issue_Resolution_Comments__c = req.issueResolutionComments;
        if(req.projectId != null) issue.Project__c = req.projectId;
        if(req.programId != null) issue.Program__c = req.programId;
        if(req.epicId != null) issue.Epic__c = req.epicId;
        if(req.riskId != null) issue.Risk__c = req.riskId;
        if(req.workItemId != null) issue.Work_Item__c = req.workItemId;
        if(req.teamId != null) issue.Team__c = req.teamId;
        if(req.ownerId != null) issue.OwnerId = req.ownerId;
        return issue;
    }

    private static void handleDmlResults(Database.SaveResult[] results, List<Issue__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType == action) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Issue ' + action.toLowerCase() + 'd successfully.';
                        res.issueRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                }
            }
        }
    }
    
    private static void handleSearch(Request req, Response res) {
        String allFields = String.join(new List<String>(Schema.getGlobalDescribe().get('Issue__c').getDescribe().fields.getMap().keySet()), ',');
        String soql = 'SELECT ' + allFields + ' FROM Issue__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.issueName)) {
            conditions.add('Issue_Name__c LIKE \'%' + String.escapeSingleQuotes(req.issueName) + '%\'');
        }
        if (String.isNotBlank(req.status)) {
            conditions.add('Status__c = \'' + String.escapeSingleQuotes(req.status) + '\'');
        }
        if (String.isNotBlank(req.priority)) {
            conditions.add('Priority__c = \'' + String.escapeSingleQuotes(req.priority) + '\'');
        }
        if (String.isNotBlank(req.ownerId)) {
            conditions.add('OwnerId = \'' + String.escapeSingleQuotes(req.ownerId) + '\'');
        }
        if (String.isNotBlank(req.projectId)) {
            conditions.add('Project__c = \'' + String.escapeSingleQuotes(req.projectId) + '\'');
        }
        if (String.isNotBlank(req.programId)) {
            conditions.add('Program__c = \'' + String.escapeSingleQuotes(req.programId) + '\'');
        }
        if (String.isNotBlank(req.epicId)) {
            conditions.add('Epic__c = \'' + String.escapeSingleQuotes(req.epicId) + '\'');
        }
        if (String.isNotBlank(req.riskId)) {
            conditions.add('Risk__c = \'' + String.escapeSingleQuotes(req.riskId) + '\'');
        }
        if (String.isNotBlank(req.workItemId)) {
            conditions.add('Work_Item__c = \'' + String.escapeSingleQuotes(req.workItemId) + '\'');
        }
        if (String.isNotBlank(req.teamId)) {
            conditions.add('Team__c = \'' + String.escapeSingleQuotes(req.teamId) + '\'');
        }
        if (String.isNotBlank(req.createdDate)) {
            String dateCondition = GAFRA2Utility.parseDateFilter('CreatedDate', req.createdDate);
            if(String.isNotBlank(dateCondition)) {
                conditions.add(dateCondition);
            }
        }
        if (String.isNotBlank(req.lastModifiedDate)) {
            String dateCondition = GAFRA2Utility.parseDateFilter('LastModifiedDate', req.lastModifiedDate);
            if(String.isNotBlank(dateCondition)) {
                conditions.add(dateCondition);
            }
        }
        
        if (!conditions.isEmpty()) {
            soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        soql += ' ORDER BY LastModifiedDate DESC LIMIT 500';

        try {
            res.issueRecords = Database.query(soql);
            res.success = true;
            res.message = 'Issue search executed. Records found: ' + res.issueRecords.size();
        } catch (Exception e) {
            res.message = 'Error during Issue search: ' + e.getMessage();
        }
    }
}