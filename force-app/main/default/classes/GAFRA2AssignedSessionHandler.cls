public with sharing class GAFRA2AssignedSessionHandler {

    public class Request {
        @InvocableVariable(label='Action Type' description='Specify the action: Create | Modify | Retrieve | Search | Inactivate' required=true)
        public String actionType;

        @InvocableVariable(label='Assigned Session ID' description='The unique ID of the Assigned Session record to target. Required for Modify, Retrieve, or Inactivate actions.')
        public String assignedSessionId;
        
        @InvocableVariable(label='Assigned Session Name' description='Used for "Search" actions only to find records by their auto-generated name.')
        public String assignedSessionName;

        @InvocableVariable(label='Learner Profile ID' description='The ID of the Learner Profile for this assignment. Required for "Create".')
        public String learnerProfileId;

        @InvocableVariable(label='Session ID' description='The ID of the Session for this assignment. Required for "Create".')
        public String sessionId;

        @InvocableVariable(label='Status' description='The registration status for the session.')
        public String status;

        @InvocableVariable(label='Registration Type' description='The registration type for the session.')
        public String registrationType;

        @InvocableVariable(label='Registration Date/Time' description='The date and time of registration.')
        public Datetime registrationDateTime;
        
        @InvocableVariable(label='Self Registered' description='Indicates if the learner self-registered.')
        public Boolean selfRegistered;
    }

    public class Response {
        @InvocableVariable(label='Success' description='Indicates if the specific operation for this request succeeded.')
        public Boolean success = false;

        @InvocableVariable(label='Message' description='A summary of the operation result for this specific request.')
        public String message = '';

        @InvocableVariable(label='Assigned Session Records' description='The Assigned Session record(s) returned by this specific request.')
        public List<Assigned_Session__c> assignedSessionRecords = new List<Assigned_Session__c>();
    }

    @InvocableMethod(label='GA-FRA2 Manage Assigned Session' description='A bulk-safe method to manage session assignments for learners. Supports Create, Modify, Retrieve, Search, and Inactivate actions.')
    public static List<Response> manageAssignedSession(List<Request> requests) {
        List<Assigned_Session__c> toCreate = new List<Assigned_Session__c>();
        List<Assigned_Session__c> toUpdate = new List<Assigned_Session__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.learnerProfileId) || String.isBlank(req.sessionId)) {
                        res.message = 'Error: Learner Profile ID and Session ID are required for Create.';
                    } else {
                        toCreate.add(buildRecordFromRequest(new Assigned_Session__c(), req));
                    }
                }
                when 'Modify', 'Retrieve', 'Inactivate' {
                    if (String.isBlank(req.assignedSessionId)) {
                        res.message = 'Error: Assigned Session ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.assignedSessionId);
                    }
                }
                when 'Search' {
                    handleSearch(req, res);
                }
                when else {
                    res.message = 'Error: Invalid or missing action type.';
                }
            }
        }

        if (!toCreate.isEmpty()) {
            Database.SaveResult[] createResults = Database.insert(toCreate, false);
            handleDmlResults(createResults, toCreate, 'Create', requests, responseMap);
        }

        if (!idsToProcess.isEmpty()) {
            Map<Id, Assigned_Session__c> recordsFromDb = new Map<Id, Assigned_Session__c>([
                SELECT Id, Name, Learner_Profile__c, Session__c, Status__c, Registration_Type__c, Registration_Date_Time__c, Self_Registered__c
                FROM Assigned_Session__c WHERE Id IN :idsToProcess
            ]);

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (String.isBlank(req.assignedSessionId) || !recordsFromDb.containsKey(req.assignedSessionId)) continue;
                
                Response res = responseMap.get(i);
                Assigned_Session__c record = recordsFromDb.get(req.assignedSessionId);

                if (req.actionType == 'Modify') {
                    toUpdate.add(buildRecordFromRequest(record, req));
                } else if (req.actionType == 'Inactivate') {
                    // Assuming 'Inactivate' means setting status to a specific value, e.g., 'Inactive' or 'Cancelled'
                    record.Status__c = 'Inactive';
                    toUpdate.add(record);
                } else if (req.actionType == 'Retrieve') {
                    res.success = true;
                    res.message = 'Assigned Session retrieved successfully.';
                    res.assignedSessionRecords.add(record);
                }
            }
        }
        
        if (!toUpdate.isEmpty()){
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            handleDmlResults(updateResults, toUpdate, 'Update', requests, responseMap);
        }
        
        return new List<Response>(responseMap.values());
    }

    private static Assigned_Session__c buildRecordFromRequest(Assigned_Session__c record, Request req) {
        if (String.isNotBlank(req.learnerProfileId)) record.Learner_Profile__c = req.learnerProfileId;
        if (String.isNotBlank(req.sessionId)) record.Session__c = req.sessionId;
        if (String.isNotBlank(req.status)) record.Status__c = req.status;
        if (String.isNotBlank(req.registrationType)) record.Registration_Type__c = req.registrationType;
        if (req.registrationDateTime != null) record.Registration_Date_Time__c = req.registrationDateTime;
        if (req.selfRegistered != null) record.Self_Registered__c = req.selfRegistered;
        return record;
    }

    private static void handleDmlResults(Database.SaveResult[] results, List<Assigned_Session__c> records, String operationType, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            
            Request req = requests.get(i);
            boolean isCreate = operationType == 'Create' && req.actionType == 'Create';
            boolean isUpdate = operationType == 'Update' && (req.actionType == 'Modify' || req.actionType == 'Inactivate');

            if ((isCreate || isUpdate) && responseMap.get(i).message == '') { 
                if (recordIndex >= results.size()) continue;

                Database.SaveResult sr = results[recordIndex];
                Response res = responseMap.get(i);

                if (sr.isSuccess()) {
                    res.success = true;
                    res.message = 'Assigned Session ' + req.actionType.toLowerCase() + 'd successfully.';
                    res.assignedSessionRecords.add(records[recordIndex]);
                } else {
                    res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                }
                recordIndex++;
            }
        }
    }
    
    private static void handleSearch(Request req, Response res) {
        String query = 'SELECT Id, Name, Learner_Profile__c, Session__c, Status__c, Registration_Type__c, Registration_Date_Time__c, Self_Registered__c FROM Assigned_Session__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.assignedSessionName)) conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.assignedSessionName) + '%\'');
        if (String.isNotBlank(req.learnerProfileId)) conditions.add('Learner_Profile__c = \'' + String.escapeSingleQuotes(req.learnerProfileId) + '\'');
        if (String.isNotBlank(req.sessionId)) conditions.add('Session__c = \'' + String.escapeSingleQuotes(req.sessionId) + '\'');
        if (String.isNotBlank(req.status)) conditions.add('Status__c = \'' + String.escapeSingleQuotes(req.status) + '\'');
        if (String.isNotBlank(req.registrationType)) conditions.add('Registration_Type__c = \'' + String.escapeSingleQuotes(req.registrationType) + '\'');

        if(!conditions.isEmpty()){
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        query += ' ORDER BY LastModifiedDate DESC LIMIT 500';

        try {
            List<Assigned_Session__c> records = Database.query(query);
            res.success = true;
            res.message = 'Search executed successfully. Records found: ' + records.size();
            res.assignedSessionRecords = records;
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}