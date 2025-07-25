/**
 * @description Handles CRUD operations for Enhancement/Bug Log records. This invocable handler
 * is used to create and manage logs for bugs and enhancement requests, which are crucial
 * for tracking product feedback and planning development work.
 */
public with sharing class GAEOA2EnhancementBugLogHandler {

    // --- INNER REQUEST CLASS (Strongly-Typed) ---
    public class Request {
        @InvocableVariable(label='Action Type' description='Specify the action: Create | Modify | Retrieve | Search | Cancel' required=true)
        public String actionType;

        @InvocableVariable(label='Enhancement/Bug Log ID' description='Salesforce ID of the record. Required for Modify, Retrieve, or Cancel.')
        public String enhancementBugLogId;

        @InvocableVariable(label='Enhancement/Bug Name' description='A descriptive name for the enhancement or bug. Required for Create.')
        public String enhancementBugName;
        
        @InvocableVariable(label='Category' description='The area of the application this log applies to (e.g., Projects, Kanban Board, Epics).')
        public String category;
        
        @InvocableVariable(label='Detail Description' description='A detailed description of the issue, including steps to reproduce, expected result, and observed result.')
        public String detailDescription;
        
        @InvocableVariable(label='Status' description='The current status of the log (e.g., New Request, In Progress, Complete).')
        public String status;
        
        @InvocableVariable(label='Frequency' description='How often the issue occurs (e.g., Always, Often, Sometimes, Rarely).')
        public String frequency;
        
        @InvocableVariable(label='Users Impacted' description='The number of users affected by this issue.')
        public String usersImpacted;

        // Search-specific fields
        @InvocableVariable(label='Search by Status' description='For Search only. Filter records by a specific status.')
        public String searchStatus;
        
        @InvocableVariable(label='Search by Category' description='For Search only. Filter records by a specific category.')
        public String searchCategory;
    }

    // --- INNER RESPONSE CLASS ---
    public class Response {
        @InvocableVariable(label='Success' description='True if the operation was successful.')
        public Boolean success = false;

        @InvocableVariable(label='Message' description='A summary of the operation result.')
        public String message = '';

        @InvocableVariable(label='Enhancement/Bug Log Records' description='A list of Enhancement/Bug Log records returned by the operation.')
        public List<Enhancement_Bug_Log__c> enhancementBugLogRecords = new List<Enhancement_Bug_Log__c>();
    }

    // --- INVOCABLE METHOD ---
    @InvocableMethod(label='EOA Manage Enhancement/Bug Logs' description='A bulk-safe method to manage Enhancement/Bug Log records in the EOA.')
    public static List<Response> manageEnhancementBugLogs(List<Request> requests) {
        List<Enhancement_Bug_Log__c> toCreate = new List<Enhancement_Bug_Log__c>();
        List<Enhancement_Bug_Log__c> toUpdate = new List<Enhancement_Bug_Log__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.enhancementBugName)) {
                        res.message = 'Error: Enhancement/Bug Name is required for creation.';
                    } else {
                        Enhancement_Bug_Log__c newLog = new Enhancement_Bug_Log__c(
                            Enhancement_Bug_Name__c = req.enhancementBugName,
                            Category__c = req.category,
                            Detail_Description__c = req.detailDescription,
                            Frequency__c = req.frequency,
                            Users_Impacted__c = req.usersImpacted,
                            Status__c = String.isNotBlank(req.status) ? req.status : 'New Request' // Default status
                        );
toCreate.add(newLog);
                    }
                }
                when 'Modify', 'Retrieve', 'Cancel' {
                    if (String.isBlank(req.enhancementBugLogId)) {
                        res.message = 'Error: Enhancement/Bug Log ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.enhancementBugLogId);
                    }
                }
                when 'Search' {
                    handleSearch(req, res);
                }
                when else {
                    res.message = 'Error: Invalid or missing action type provided.';
                }
            }
        }
        
        // --- DML OPERATIONS ---
        if (!toCreate.isEmpty()) {
            Database.SaveResult[] createResults = Database.insert(toCreate, false);
            Integer createIndex = 0;
            for (Integer i = 0; i < requests.size(); i++) {
                if (requests.get(i).actionType == 'Create' && responseMap.get(i).message == '') {
                    Database.SaveResult sr = createResults[createIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Enhancement/Bug Log created successfully.';
                        res.enhancementBugLogRecords.add(toCreate[createIndex]);
                    } else {
                        res.message = 'Error creating log: ' + sr.getErrors()[0].getMessage();
                    }
                    createIndex++;
                }
            }
        }

        if (!idsToProcess.isEmpty()) {
            Map<Id, Enhancement_Bug_Log__c> logsFromDb = new Map<Id, Enhancement_Bug_Log__c>([
                SELECT Id, Name, Enhancement_Bug_Name__c, Category__c, Detail_Description__c, Status__c, Frequency__c
                FROM Enhancement_Bug_Log__c WHERE Id IN :idsToProcess
            ]);

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (req.actionType == 'Modify' || req.actionType == 'Retrieve' || req.actionType == 'Cancel') {
                     if (String.isBlank(req.enhancementBugLogId) || !logsFromDb.containsKey(req.enhancementBugLogId)) {
                        if (responseMap.get(i).message == '') {
                           responseMap.get(i).message = 'Error: Log with ID ' + req.enhancementBugLogId + ' not found.';
                        }
                        continue;
                    }

                    Enhancement_Bug_Log__c log = logsFromDb.get(req.enhancementBugLogId);
                    if (req.actionType == 'Modify') {
                        if(String.isNotBlank(req.enhancementBugName)) log.Enhancement_Bug_Name__c = req.enhancementBugName;
                        if(String.isNotBlank(req.category)) log.Category__c = req.category;
                        if(String.isNotBlank(req.detailDescription)) log.Detail_Description__c = req.detailDescription;
                        if(String.isNotBlank(req.status)) log.Status__c = req.status;
                        toUpdate.add(log);
                    } else if (req.actionType == 'Cancel') {
                        // Business Rule: To cancel, set the status field.
                        log.Status__c = 'Canceled';
                        toUpdate.add(log);
                    } else if (req.actionType == 'Retrieve') {
                        responseMap.get(i).success = true;
                        responseMap.get(i).message = 'Log retrieved successfully.';
                        responseMap.get(i).enhancementBugLogRecords.add(log);
                    }
                }
            }
        }

        if(!toUpdate.isEmpty()){
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            Integer updateIndex = 0;
            for(Integer i = 0; i < requests.size(); i++){
                 Request req = requests.get(i);
                 if((req.actionType == 'Modify' || req.actionType == 'Cancel') && responseMap.get(i).message == ''){
                     Database.SaveResult sr = updateResults[updateIndex];
                     Response res = responseMap.get(i);
                     if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Log ' + req.actionType.toLowerCase() + ' action completed successfully.';
                        res.enhancementBugLogRecords.add(toUpdate[updateIndex]);
                     } else {
                         res.message = 'Error updating log: ' + sr.getErrors()[0].getMessage();
                     }
                     updateIndex++;
                 }
            }
        }
        
        return new List<Response>(responseMap.values());
    }
    
    // --- SEARCH HELPER METHOD ---
    private static void handleSearch(Request req, Response res) {
        String soql = 'SELECT Id, Name, Enhancement_Bug_Name__c, Category__c, Detail_Description__c, Status__c, Frequency__c, Users_Impacted__c, CreatedDate ' + 
                      'FROM Enhancement_Bug_Log__c';
        
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.enhancementBugName)) {
            conditions.add('Enhancement_Bug_Name__c LIKE \'%' + String.escapeSingleQuotes(req.enhancementBugName) + '%\'');
        }
        if (String.isNotBlank(req.searchStatus)) {
            conditions.add('Status__c = \'' + String.escapeSingleQuotes(req.searchStatus) + '\'');
        }
        if (String.isNotBlank(req.searchCategory)) {
            conditions.add('Category__c = \'' + String.escapeSingleQuotes(req.searchCategory) + '\'');
        }

        if(!conditions.isEmpty()){
            soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        soql += ' ORDER BY CreatedDate DESC LIMIT 500';

        try {
            List<Enhancement_Bug_Log__c> logs = Database.query(soql);
            res.success = true;
            res.message = 'Enhancement/Bug Log search executed successfully. Records found: ' + logs.size();
            res.enhancementBugLogRecords = logs;
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}