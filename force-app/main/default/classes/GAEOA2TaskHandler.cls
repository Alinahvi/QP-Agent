public with sharing class GAEOA2TaskHandler {

    // Inner class for request data
    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;

        @InvocableVariable(label='GA-EOA2 Task ID' description='Salesforce Task record ID. Required for Modify, Retrieve actions.')
        public String taskId;
        
        // --- All agf__ADM_Task__c Fields ---
        @InvocableVariable(label='GA-EOA2 Work' description='Value for the Work (agf__Work__c) field.')
        public String agfWork;
        @InvocableVariable(label='GA-EOA2 Actual Hours' description='Value for the Actual Hours (agf__Actual_Hours__c) field.')
        public Decimal agfActualHours;
        @InvocableVariable(label='GA-EOA2 Assigned To' description='Value for the Assigned To (agf__Assigned_To__c) field.')
        public String agfAssignedTo;
        @InvocableVariable(label='GA-EOA2 Quality' description='Value for the Quality (agf__Capex_Enabled__c) field.')
        public Boolean agfCapexEnabled;
        @InvocableVariable(label='GA-EOA2 Comments' description='Value for the Comments (agf__Comments__c) field.')
        public String agfComments;
        @InvocableVariable(label='GA-EOA2 Completed On' description='Value for the Completed On (agf__Completed_On__c) field. Supported formats: YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public Datetime agfCompletedOn;
        @InvocableVariable(label='GA-EOA2 Due Date' description='Value for the Due Date (agf__Due_By__c) field. Supported formats: YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public Date agfDueBy;
        @InvocableVariable(label='GA-EOA2 External ID' description='Value for the External ID (agf__External_ID__c) field.')
        public String agfExternalId;
        @InvocableVariable(label='GA-EOA2 Hours Remaining' description='Value for the Hours Remaining (agf__Hours_Remaining__c) field.')
        public Decimal agfHoursRemaining;
        @InvocableVariable(label='GA-EOA2 Order' description='Value for the Order (agf__Order__c) field.')
        public Decimal agfOrder;
        @InvocableVariable(label='GA-EOA2 SprintId' description='Value for the SprintId (agf__SprintId__c) field.')
        public String agfSprintid;
        @InvocableVariable(label='GA-EOA2 Starting Hours' description='Value for the Starting Hours (agf__Starting_Hours__c) field.')
        public Decimal agfStartingHours;
        @InvocableVariable(label='GA-EOA2 Status' description='Value for the Status (agf__Status__c) field.')
        public String agfStatus;
        @InvocableVariable(label='GA-EOA2 Subject' description='Value for the Subject (agf__Subject__c) field.')
        public String agfSubject;

        // Search-specific fields
        @InvocableVariable(label='GA-EOA2 Created Date' description='For search operations. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals.')
        public String createdDate;
        @InvocableVariable(label='GA-EOA2 Last Modified Date' description='For search operations. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals.')
        public String lastModifiedDate;
        @InvocableVariable(label='GA-EOA2 Created By User ID' description='For search operations. Salesforce User ID of the creator.')
        public String createdById;
        @InvocableVariable(label='GA-EOA2 Last Modified By User ID' description='For search operations. Salesforce User ID of the last modifier.')
        public String lastModifiedById;
    }
    
    // Inner class for response data
    public class Response {
        @InvocableVariable(label='GA-EOA2 Success' description='True if the operation succeeded.')
        public Boolean success = false;
        @InvocableVariable(label='GA-EOA2 Message' description='Summary of the operation result.')
        public String message = '';
        @InvocableVariable(label='GA-EOA2 Task Records' description='List of Task records from the operation.')
        public List<agf__ADM_Task__c> taskRecords = new List<agf__ADM_Task__c>();
    }

    // Main invocable method
    @InvocableMethod(label='GA-EOA2 Manage Task Records' description='A single, bulk-safe method to create, modify, retrieve, and search for Task records.')
    public static List<Response> manageTasks(List<Request> requests) {
        List<agf__ADM_Task__c> toCreate = new List<agf__ADM_Task__c>();
        List<agf__ADM_Task__c> toUpdate = new List<agf__ADM_Task__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.agfSubject)) {
                        res.message = 'Error: Subject is required for creation.';
                    } else {
                        toCreate.add(mapRequestToTask(req, new agf__ADM_Task__c()));
                    }
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.taskId)) {
                        res.message = 'Error: Task ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.taskId);
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
            Map<Id, agf__ADM_Task__c> tasksFromDb = new Map<Id, agf__ADM_Task__c>([
                SELECT Id, agf__Work__c, agf__Actual_Hours__c, agf__Assigned_To__c, agf__Capex_Enabled__c, agf__Comments__c, agf__Completed_On__c, agf__Due_By__c, agf__External_ID__c, agf__Hours_Remaining__c, agf__Order__c, agf__SprintId__c, agf__Starting_Hours__c, agf__Status__c, agf__Subject__c, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById 
                FROM agf__ADM_Task__c WHERE Id IN :idsToProcess
            ]);

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (String.isBlank(req.taskId) || !tasksFromDb.containsKey(req.taskId)) continue;
                
                Response res = responseMap.get(i);
                agf__ADM_Task__c task = tasksFromDb.get(req.taskId);

                if (req.actionType == 'Modify') {
                    toUpdate.add(mapRequestToTask(req, task));
                } else if (req.actionType == 'Retrieve') {
                    res.success = true;
                    res.message = 'Task retrieved successfully.';
                    res.taskRecords.add(task);
                }
            }
        }
        
        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            handleDmlResults(updateResults, toUpdate, 'Modify', requests, responseMap);
        }
        
        return new List<Response>(responseMap.values());
    }

    // Maps request fields to a Task SObject
    private static agf__ADM_Task__c mapRequestToTask(Request req, agf__ADM_Task__c task) {
        if(req.agfWork != null) task.agf__Work__c = req.agfWork;
        if(req.agfActualHours != null) task.agf__Actual_Hours__c = req.agfActualHours;
        if(req.agfAssignedTo != null) task.agf__Assigned_To__c = req.agfAssignedTo;
        if(req.agfCapexEnabled != null) task.agf__Capex_Enabled__c = req.agfCapexEnabled;
        if(req.agfComments != null) task.agf__Comments__c = req.agfComments;
        if(req.agfCompletedOn != null) task.agf__Completed_On__c = req.agfCompletedOn;
        if(req.agfDueBy != null) task.agf__Due_By__c = req.agfDueBy;
        if(req.agfExternalId != null) task.agf__External_ID__c = req.agfExternalId;
        if(req.agfHoursRemaining != null) task.agf__Hours_Remaining__c = req.agfHoursRemaining;
        if(req.agfOrder != null) task.agf__Order__c = req.agfOrder;
        if(req.agfSprintid != null) task.agf__SprintId__c = req.agfSprintid;
        if(req.agfStartingHours != null) task.agf__Starting_Hours__c = req.agfStartingHours;
        if(req.agfStatus != null) task.agf__Status__c = req.agfStatus;
        if(req.agfSubject != null) task.agf__Subject__c = req.agfSubject;
        return task;
    }

    // Handles DML results and updates response map
    private static void handleDmlResults(Database.SaveResult[] results, List<agf__ADM_Task__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType == action && (action == 'Create' ? String.isNotBlank(requests.get(i).agfSubject) : String.isNotBlank(requests.get(i).taskId))) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Task ' + action.toLowerCase() + 'd successfully.';
                        res.taskRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                }
            }
        }
    }

    // Handles dynamic SOQL search
    private static void handleSearch(Request req, Response res) {
        String soql = 'SELECT Id, agf__Work__c, agf__Actual_Hours__c, agf__Assigned_To__c, agf__Capex_Enabled__c, agf__Comments__c, agf__Completed_On__c, agf__Due_By__c, agf__External_ID__c, agf__Hours_Remaining__c, agf__Order__c, agf__SprintId__c, agf__Starting_Hours__c, agf__Status__c, agf__Subject__c, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById FROM agf__ADM_Task__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.agfSubject)) {
            conditions.add('agf__Subject__c LIKE \'%' + String.escapeSingleQuotes(req.agfSubject) + '%\'');
        }
        if (String.isNotBlank(req.agfStatus)) {
            conditions.add('agf__Status__c = \'' + String.escapeSingleQuotes(req.agfStatus) + '\'');
        }
        if (String.isNotBlank(req.createdById)) {
            conditions.add('CreatedById = \'' + String.escapeSingleQuotes(req.createdById) + '\'');
        }
        if (String.isNotBlank(req.lastModifiedById)) {
            conditions.add('LastModifiedById = \'' + String.escapeSingleQuotes(req.lastModifiedById) + '\'');
        }
        if (String.isNotBlank(req.agfWork)) {
            conditions.add('agf__Work__c = \'' + String.escapeSingleQuotes(req.agfWork) + '\'');
        }
        if (String.isNotBlank(req.agfAssignedTo)) {
            conditions.add('agf__Assigned_To__c = \'' + String.escapeSingleQuotes(req.agfAssignedTo) + '\'');
        }
        if (String.isNotBlank(req.agfSprintid)) {
            conditions.add('agf__SprintId__c = \'' + String.escapeSingleQuotes(req.agfSprintid) + '\'');
        }
        if (String.isNotBlank(req.agfExternalId)) {
            conditions.add('agf__External_ID__c = \'' + String.escapeSingleQuotes(req.agfExternalId) + '\'');
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

        if(!conditions.isEmpty()){
            soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        soql += ' ORDER BY LastModifiedDate DESC LIMIT 500';

        try {
            res.taskRecords = Database.query(soql);
            res.success = true;
            res.message = 'Task search executed. Records found: ' + res.taskRecords.size();
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}