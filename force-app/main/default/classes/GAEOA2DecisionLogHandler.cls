public with sharing class GAEOA2DecisionLogHandler {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 Decision Log ID' description='Salesforce Decision Log record ID. Required for Modify and Retrieve actions.')
        public String decisionLogId;

        // --- Decision_Log__c Fields ---
        @InvocableVariable(label='GA-EOA2 Topic' description='Value for the Topic (Topic__c) field.')
        public String topic;
        @InvocableVariable(label='GA-EOA2 Decision Date' description='Value for the Decision Date (Decision_Date__c) field. Format: YYYY-MM-DD')
        public Date decisionDate;
        @InvocableVariable(label='GA-EOA2 Disposition' description='Value for the Disposition (Disposition__c) field.')
        public String disposition;
        @InvocableVariable(label='GA-EOA2 Decision Details' description='Value for the Decision Details (Decision_Details__c) field.')
        public String decisionDetails;
        @InvocableVariable(label='GA-EOA2 Teams Affected' description='Value for the Teams Affected (Teams_Affected__c) field.')
        public String teamsAffected;
        @InvocableVariable(label='GA-EOA2 Project' description='Salesforce ID of the related Project (Project__c).')
        public String projectId;
        @InvocableVariable(label='GA-EOA2 Program' description='Salesforce ID of the related Program (Program__c).')
        public String programId;
        @InvocableVariable(label='GA-EOA2 Epic' description='Salesforce ID of the related Epic (Epic__c).')
        public String epicId;
        @InvocableVariable(label='GA-EOA2 Issue' description='Salesforce ID of the related Issue (Issue__c).')
        public String issueId;
        @InvocableVariable(label='GA-EOA2 Risk' description='Salesforce ID of the related Risk (Risk__c).')
        public String riskId;
        @InvocableVariable(label='GA-EOA2 Source' description='Salesforce ID of the related Source (Source__c).')
        public String sourceId;
        @InvocableVariable(label='GA-EOA2 Vendor' description='Salesforce ID of the related Vendor (Vendor__c).')
        public String vendorId;
        @InvocableVariable(label='GA-EOA2 Team Dependency' description='Salesforce ID of the related Team Dependency (Team_Dependency__c).')
        public String teamDependencyId;
        @InvocableVariable(label='GA-EOA2 Related Decision Log' description='Salesforce ID of the related Decision Log (Related_Decision_Log__c).')
        public String relatedDecisionLogId;
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
        @InvocableVariable(label='GA-EOA2 Decision Log Records' description='List of Decision Log records from the operation.')
        public List<Decision_Log__c> decisionLogRecords = new List<Decision_Log__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Decision Logs' description='Handles Create, Modify, Retrieve, and Search actions for Decision Log records.')
    public static List<Response> manageDecisionLogs(List<Request> requests) {
        List<Decision_Log__c> toCreate = new List<Decision_Log__c>();
        List<Decision_Log__c> toUpdate = new List<Decision_Log__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            responseMap.put(i, new Response());
            Request req = requests.get(i);
            
            switch on req.actionType {
                when 'Create' {
                    toCreate.add(mapRequestToDecisionLog(req, new Decision_Log__c()));
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.decisionLogId)) {
                        responseMap.get(i).message = 'Error: Decision Log ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.decisionLogId);
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
            String allFieldsQuery = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Decision_Log__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM Decision_Log__c WHERE Id IN :idsToProcess';
            Map<Id, Decision_Log__c> logsFromDb = new Map<Id, Decision_Log__c>((List<Decision_Log__c>)Database.query(allFieldsQuery));

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                Response res = responseMap.get(i);
                
                if (String.isNotBlank(req.decisionLogId) && logsFromDb.containsKey(req.decisionLogId)) {
                    if (req.actionType == 'Modify') {
                        toUpdate.add(mapRequestToDecisionLog(req, logsFromDb.get(req.decisionLogId)));
                    } else if (req.actionType == 'Retrieve') {
                        res.success = true;
                        res.message = 'Decision Log retrieved successfully.';
                        res.decisionLogRecords.add(logsFromDb.get(req.decisionLogId));
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

    private static Decision_Log__c mapRequestToDecisionLog(Request req, Decision_Log__c log) {
        if(req.actionType == 'Modify') log.Id = req.decisionLogId;
        if(req.topic != null) log.Topic__c = req.topic;
        if(req.decisionDate != null) log.Decision_Date__c = req.decisionDate;
        if(req.disposition != null) log.Disposition__c = req.disposition;
        if(req.decisionDetails != null) log.Decision_Details__c = req.decisionDetails;
        if(req.teamsAffected != null) log.Teams_Affected__c = req.teamsAffected;
        if(req.projectId != null) log.Project__c = req.projectId;
        if(req.programId != null) log.Program__c = req.programId;
        if(req.epicId != null) log.Epic__c = req.epicId;
        if(req.issueId != null) log.Issue__c = req.issueId;
        if(req.riskId != null) log.Risk__c = req.riskId;
        if(req.sourceId != null) log.Source__c = req.sourceId;
        if(req.vendorId != null) log.Vendor__c = req.vendorId;
        if(req.teamDependencyId != null) log.Team_Dependency__c = req.teamDependencyId;
        if(req.relatedDecisionLogId != null) log.Related_Decision_Log__c = req.relatedDecisionLogId;
        if(req.ownerId != null) log.OwnerId = req.ownerId;
        return log;
    }

    private static void handleDmlResults(Database.SaveResult[] results, List<Decision_Log__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType == action) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Decision Log ' + action.toLowerCase() + 'd successfully.';
                        res.decisionLogRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                }
            }
        }
    }
    
    private static void handleSearch(Request req, Response res) {
        String allFields = String.join(new List<String>(Schema.getGlobalDescribe().get('Decision_Log__c').getDescribe().fields.getMap().keySet()), ',');
        String soql = 'SELECT ' + allFields + ' FROM Decision_Log__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.topic)) {
            conditions.add('Topic__c LIKE \'%' + String.escapeSingleQuotes(req.topic) + '%\'');
        }
        if (String.isNotBlank(req.disposition)) {
            conditions.add('Disposition__c = \'' + String.escapeSingleQuotes(req.disposition) + '\'');
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
        if (String.isNotBlank(req.issueId)) {
            conditions.add('Issue__c = \'' + String.escapeSingleQuotes(req.issueId) + '\'');
        }
        if (String.isNotBlank(req.riskId)) {
            conditions.add('Risk__c = \'' + String.escapeSingleQuotes(req.riskId) + '\'');
        }
        if (String.isNotBlank(req.sourceId)) {
            conditions.add('Source__c = \'' + String.escapeSingleQuotes(req.sourceId) + '\'');
        }
        if (String.isNotBlank(req.vendorId)) {
            conditions.add('Vendor__c = \'' + String.escapeSingleQuotes(req.vendorId) + '\'');
        }
        if (String.isNotBlank(req.teamDependencyId)) {
            conditions.add('Team_Dependency__c = \'' + String.escapeSingleQuotes(req.teamDependencyId) + '\'');
        }
        if (String.isNotBlank(req.relatedDecisionLogId)) {
            conditions.add('Related_Decision_Log__c = \'' + String.escapeSingleQuotes(req.relatedDecisionLogId) + '\'');
        }
        if (String.isNotBlank(req.createdDate)) {
            String dateCondition = GAFRA2Utility.parseDateFilter('CreatedDate', req.createdDate);
            if (String.isNotBlank(dateCondition)) {
                conditions.add(dateCondition);
            }
        }
        if (String.isNotBlank(req.lastModifiedDate)) {
            String dateCondition = GAFRA2Utility.parseDateFilter('LastModifiedDate', req.lastModifiedDate);
            if (String.isNotBlank(dateCondition)) {
                conditions.add(dateCondition);
            }
        }
        
        if (!conditions.isEmpty()) {
            soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        soql += ' ORDER BY LastModifiedDate DESC LIMIT 500';

        try {
            res.decisionLogRecords = Database.query(soql);
            res.success = true;
            res.message = 'Decision Log search executed. Records found: ' + res.decisionLogRecords.size();
        } catch (Exception e) {
            res.message = 'Error during Decision Log search: ' + e.getMessage();
        }
    }
}