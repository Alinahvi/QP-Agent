public with sharing class GAEOA2CaseHandler {

    // --- REQUEST CLASS (FLATTENED) ---
    public class Request {
        @InvocableVariable(label='Action' description='The action to perform: Create | Modify | Retrieve | Search' required=true)
        public String action;

        @InvocableVariable(label='Case ID' description='The Salesforce ID of the Case record. Required for Modify or Retrieve actions.')
        public String caseId;

        @InvocableVariable(label='Subject' description='The subject line of the case.')
        public String subject;
        @InvocableVariable(label='Description' description='The detailed description of the case.')
        public String description;
        @InvocableVariable(label='Status' description='The current status of the case (e.g., New, Closed).')
        public String status;
        @InvocableVariable(label='Origin' description='The source of the case (e.g., Email, Web, Phone).')
        public String origin;
        @InvocableVariable(label='Priority' description='The priority level of the case.')
        public String priority;
        @InvocableVariable(label='Type' description='The type of case.')
        public String type;
        @InvocableVariable(label='Reason' description='The reason for the case.')
        public String reason;
        @InvocableVariable(label='Contact ID' description='The ID of the Contact associated with the case.')
        public String contactId;
        @InvocableVariable(label='Account ID' description='The ID of the Account associated with the case.')
        public String accountId;
        @InvocableVariable(label='Asset ID' description='The ID of the Asset associated with the case.')
        public String assetId;
        @InvocableVariable(label='Work ID (agf__ADM_Work__c)' description='The ID of the related Work record from the AGF package.')
        public String workId;
        @InvocableVariable(label='Topic (Topic__c)' description='The custom Topic of the case.')
        public String topic;

        // --- SEARCH FIELDS ---
        @InvocableVariable(label='Created Date' description='For search operations. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals.')
        public String createdDate;
        @InvocableVariable(label='Last Modified Date' description='For search operations. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals.')
        public String lastModifiedDate;
        @InvocableVariable(label='Created By User ID' description='For search operations. Salesforce User ID of the creator.')
        public String createdById;
        @InvocableVariable(label='Last Modified By User ID' description='For search operations. Salesforce User ID of the last modifier.')
        public String lastModifiedById;
    }

    // --- RESPONSE CLASS ---
    public class Response {
        @InvocableVariable(label='Success' description='Indicates whether the operation was successful.')
        public Boolean success = false;
        @InvocableVariable(label='Message' description='Provides a summary of the operation results.')
        public String message = '';
        @InvocableVariable(label='Cases' description='A list of the processed Case records.')
        public List<Case> cases = new List<Case>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Cases' description='Handles Create, Modify, Retrieve, and Search for Case records.')
    public static List<Response> manageCases(List<Request> requests) {
        List<Case> toCreate = new List<Case>();
        List<Case> toUpdate = new List<Case>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            switch on req.action.toLowerCase() {
                when 'create' {
                    if (String.isBlank(req.subject)) {
                        res.message = 'Error: Subject is required for Case creation.';
                    } else {
                        toCreate.add(mapRequestToCase(req, new Case()));
                    }
                }
                when 'modify', 'retrieve' {
                    if (String.isBlank(req.caseId)) {
                        res.message = 'Error: Case ID is required for ' + req.action + '.';
                    } else {
                        idsToProcess.add(req.caseId);
                    }
                }
                when 'search' {
                    handleSearch(req, res);
                }
                when else {
                    res.message = 'Error: Invalid action specified: ' + req.action;
                }
            }
        }

        if (!toCreate.isEmpty()) {
            Database.SaveResult[] createResults = Database.insert(toCreate, false);
            handleDmlResults(createResults, toCreate, 'Create', requests, responseMap);
        }

        if (!idsToProcess.isEmpty()) {
            Map<Id, Case> casesFromDb = new Map<Id, Case>([
                SELECT Id, Subject, Description, Status, Origin, Priority, Type, Reason, ContactId, AccountId, AssetId, agf__ADM_Work__c, Topic__c, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById 
                FROM Case WHERE Id IN :idsToProcess
            ]);

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (String.isBlank(req.caseId) || !casesFromDb.containsKey(req.caseId)) continue;
                
                Response res = responseMap.get(i);
                Case cs = casesFromDb.get(req.caseId);

                if (req.action.equalsIgnoreCase('Modify')) {
                    toUpdate.add(mapRequestToCase(req, cs));
                } else if (req.action.equalsIgnoreCase('Retrieve')) {
                    res.success = true;
                    res.message = 'Case retrieved successfully.';
                    res.cases.add(cs);
                }
            }
        }
        
        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            handleDmlResults(updateResults, toUpdate, 'Modify', requests, responseMap);
        }

        return responseMap.values();
    }
    
    // --- HELPER METHODS ---
    private static void handleDmlResults(Database.SaveResult[] results, List<Case> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            if (req.action.equalsIgnoreCase(action) && (action.equalsIgnoreCase('Create') ? String.isNotBlank(req.subject) : String.isNotBlank(req.caseId))) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Case ' + action.toLowerCase() + 'd successfully.';
                        res.cases.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                }
            }
        }
    }

    private static Case mapRequestToCase(Request req, Case c) {
        if (String.isNotBlank(req.caseId)) c.Id = req.caseId;
        if (req.subject != null) c.Subject = req.subject;
        if (req.description != null) c.Description = req.description;
        if (req.status != null) c.Status = req.status;
        if (req.origin != null) c.Origin = req.origin;
        if (req.priority != null) c.Priority = req.priority;
        if (req.type != null) c.Type = req.type;
        if (req.reason != null) c.Reason = req.reason;
        if (req.contactId != null) c.ContactId = req.contactId;
        if (req.accountId != null) c.AccountId = req.accountId;
        if (req.assetId != null) c.AssetId = req.assetId;
        if (req.workId != null) c.agf__ADM_Work__c = req.workId;
        if (req.topic != null) c.Topic__c = req.topic;
        return c;
    }

    private static void handleSearch(Request req, Response res) {
        String soql = 'SELECT Id, Subject, Description, Status, Origin, Priority, Type, Reason, ContactId, AccountId, AssetId, agf__ADM_Work__c, Topic__c, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById FROM Case';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.subject)) conditions.add('Subject LIKE \'%' + String.escapeSingleQuotes(req.subject) + '%\'');
        if (String.isNotBlank(req.status)) conditions.add('Status = \'' + String.escapeSingleQuotes(req.status) + '\'');
        if (String.isNotBlank(req.origin)) conditions.add('Origin = \'' + String.escapeSingleQuotes(req.origin) + '\'');
        if (String.isNotBlank(req.priority)) conditions.add('Priority = \'' + String.escapeSingleQuotes(req.priority) + '\'');
        if (String.isNotBlank(req.type)) conditions.add('Type = \'' + String.escapeSingleQuotes(req.type) + '\'');
        if (String.isNotBlank(req.reason)) conditions.add('Reason = \'' + String.escapeSingleQuotes(req.reason) + '\'');
        if (String.isNotBlank(req.contactId)) conditions.add('ContactId = \'' + String.escapeSingleQuotes(req.contactId) + '\'');
        if (String.isNotBlank(req.accountId)) conditions.add('AccountId = \'' + String.escapeSingleQuotes(req.accountId) + '\'');
        if (String.isNotBlank(req.assetId)) conditions.add('AssetId = \'' + String.escapeSingleQuotes(req.assetId) + '\'');
        if (String.isNotBlank(req.workId)) conditions.add('agf__ADM_Work__c = \'' + String.escapeSingleQuotes(req.workId) + '\'');
        if (String.isNotBlank(req.topic)) conditions.add('Topic__c = \'' + String.escapeSingleQuotes(req.topic) + '\'');
        if (String.isNotBlank(req.createdById)) conditions.add('CreatedById = \'' + String.escapeSingleQuotes(req.createdById) + '\'');
        if (String.isNotBlank(req.lastModifiedById)) conditions.add('LastModifiedById = \'' + String.escapeSingleQuotes(req.lastModifiedById) + '\'');

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

        if(!conditions.isEmpty()){
            soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        soql += ' ORDER BY LastModifiedDate DESC LIMIT 500';

        try {
            res.cases = Database.query(soql);
            res.success = true;
            res.message = 'Case search executed. Records found: ' + res.cases.size();
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}