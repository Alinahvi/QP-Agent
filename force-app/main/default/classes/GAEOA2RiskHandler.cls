public with sharing class GAEOA2RiskHandler {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 Risk ID' description='Salesforce Risk record ID. Required for Modify and Retrieve actions.')
        public String riskId;

        // --- Risk__c Fields ---
        @InvocableVariable(label='GA-EOA2 Risk Name' description='Value for the Risk Name (Risk_Name__c) field.')
        public String riskName;
        @InvocableVariable(label='GA-EOA2 Status' description='Value for the Status (Status__c) field.')
        public String status;
        @InvocableVariable(label='GA-EOA2 Impact' description='Value for the Impact (Impact__c) field.')
        public String impact;
        @InvocableVariable(label='GA-EOA2 Probability' description='Value for the Probability (Probability__c) field.')
        public String probability;
        @InvocableVariable(label='GA-EOA2 Identified On' description='Value for the Identified On (Identified_On__c) field. Format: YYYY-MM-DD')
        public Date identifiedOn;
        @InvocableVariable(label='GA-EOA2 Target Close Date' description='Value for the Target Close Date (Target_Close_Date__c) field. Format: YYYY-MM-DD')
        public Date targetCloseDate;
        @InvocableVariable(label='GA-EOA2 Closed Date' description='Value for the Closed Date (Closed_Date__c) field. Format: YYYY-MM-DD')
        public Date closedDate;
        @InvocableVariable(label='GA-EOA2 Details' description='Value for the Details (Details__c) field.')
        public String details;
        @InvocableVariable(label='GA-EOA2 Impact Description' description='Value for the Impact Description (Impact_Description__c) field.')
        public String impactDescription;
        @InvocableVariable(label='GA-EOA2 Mitigation Strategy' description='Value for the Mitigation Strategy (Mitigation_Strategy__c) field.')
        public String mitigationStrategy;
        @InvocableVariable(label='GA-EOA2 Closure Criteria' description='Value for the Closure Criteria (Closure_Criteria__c) field.')
        public String closureCriteria;
        @InvocableVariable(label='GA-EOA2 Project' description='Salesforce ID of the related Project (Project__c).')
        public String projectId;
        @InvocableVariable(label='GA-EOA2 Program' description='Salesforce ID of the related Program (Program__c).')
        public String programId;
        @InvocableVariable(label='GA-EOA2 Epic' description='Salesforce ID of the related Epic (Epic__c).')
        public String epicId;
        @InvocableVariable(label='GA-EOA2 Issue' description='Salesforce ID of the related Issue (Issue__c).')
        public String issueId;
        @InvocableVariable(label='GA-EOA2 Work Item' description='Salesforce ID of the related Work Item (Work_Item__c).')
        public String workItemId;
        @InvocableVariable(label='GA-EOA2 Team' description='Salesforce ID of the related Team (Team__c).')
        public String teamId;
        @InvocableVariable(label='GA-EOA2 Convert Risk to Issue' description='Value for the Convert Risk to Issue (Convert_Risk_to_Issue__c) field.')
        public Boolean convertRiskToIssue;
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
        @InvocableVariable(label='GA-EOA2 Risk Records' description='List of Risk records from the operation.')
        public List<Risk__c> riskRecords = new List<Risk__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Risks' description='Handles Create, Modify, Retrieve, and Search actions for Risk records.')
    public static List<Response> manageRisks(List<Request> requests) {
        List<Risk__c> toCreate = new List<Risk__c>();
        List<Risk__c> toUpdate = new List<Risk__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            responseMap.put(i, new Response());
            Request req = requests.get(i);
            
            switch on req.actionType {
                when 'Create' {
                    toCreate.add(mapRequestToRisk(req, new Risk__c()));
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.riskId)) {
                        responseMap.get(i).message = 'Error: Risk ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.riskId);
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
            String allFieldsQuery = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Risk__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM Risk__c WHERE Id IN :idsToProcess';
            Map<Id, Risk__c> risksFromDb = new Map<Id, Risk__c>((List<Risk__c>)Database.query(allFieldsQuery));

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                Response res = responseMap.get(i);
                
                if (String.isNotBlank(req.riskId) && risksFromDb.containsKey(req.riskId)) {
                    if (req.actionType == 'Modify') {
                        toUpdate.add(mapRequestToRisk(req, risksFromDb.get(req.riskId)));
                    } else if (req.actionType == 'Retrieve') {
                        res.success = true;
                        res.message = 'Risk retrieved successfully.';
                        res.riskRecords.add(risksFromDb.get(req.riskId));
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

    private static Risk__c mapRequestToRisk(Request req, Risk__c risk) {
        if(req.actionType == 'Modify') risk.Id = req.riskId;
        if(req.riskName != null) risk.Risk_Name__c = req.riskName;
        if(req.status != null) risk.Status__c = req.status;
        if(req.impact != null) risk.Impact__c = req.impact;
        if(req.probability != null) risk.Probability__c = req.probability;
        if(req.identifiedOn != null) risk.Identified_On__c = req.identifiedOn;
        if(req.targetCloseDate != null) risk.Target_Close_Date__c = req.targetCloseDate;
        if(req.closedDate != null) risk.Closed_Date__c = req.closedDate;
        if(req.details != null) risk.Details__c = req.details;
        if(req.impactDescription != null) risk.Impact_Description__c = req.impactDescription;
        if(req.mitigationStrategy != null) risk.Mitigation_Strategy__c = req.mitigationStrategy;
        if(req.closureCriteria != null) risk.Closure_Criteria__c = req.closureCriteria;
        if(req.projectId != null) risk.Project__c = req.projectId;
        if(req.programId != null) risk.Program__c = req.programId;
        if(req.epicId != null) risk.Epic__c = req.epicId;
        if(req.issueId != null) risk.Issue__c = req.issueId;
        if(req.workItemId != null) risk.Work_Item__c = req.workItemId;
        if(req.teamId != null) risk.Team__c = req.teamId;
        if(req.convertRiskToIssue != null) risk.Convert_Risk_to_Issue__c = req.convertRiskToIssue;
        if(req.ownerId != null) risk.OwnerId = req.ownerId;
        return risk;
    }

    private static void handleDmlResults(Database.SaveResult[] results, List<Risk__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType == action) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Risk ' + action.toLowerCase() + 'd successfully.';
                        res.riskRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                }
            }
        }
    }
    
    private static void handleSearch(Request req, Response res) {
        String allFields = String.join(new List<String>(Schema.getGlobalDescribe().get('Risk__c').getDescribe().fields.getMap().keySet()), ',');
        String soql = 'SELECT ' + allFields + ' FROM Risk__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.riskName)) {
            conditions.add('Risk_Name__c LIKE \'%' + String.escapeSingleQuotes(req.riskName) + '%\'');
        }
        if (String.isNotBlank(req.status)) {
            conditions.add('Status__c = \'' + String.escapeSingleQuotes(req.status) + '\'');
        }
        if (String.isNotBlank(req.impact)) {
            conditions.add('Impact__c = \'' + String.escapeSingleQuotes(req.impact) + '\'');
        }
        if (String.isNotBlank(req.ownerId)) {
            conditions.add('OwnerId = \'' + String.escapeSingleQuotes(req.ownerId) + '\'');
        }
        if (String.isNotBlank(req.probability)) {
            conditions.add('Probability__c = \'' + String.escapeSingleQuotes(req.probability) + '\'');
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
        if (String.isNotBlank(req.issueId)) {
            conditions.add('Issue__c = \'' + String.escapeSingleQuotes(req.issueId) + '\'');
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
            res.riskRecords = Database.query(soql);
            res.success = true;
            res.message = 'Risk search executed. Records found: ' + res.riskRecords.size();
        } catch (Exception e) {
            res.message = 'Error during Risk search: ' + e.getMessage();
        }
    }
}