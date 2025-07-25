public with sharing class GAFRA2ChecklistHandler {

    public class Request {
        @InvocableVariable(label='Action Type' description='Specify the action: Create | Modify | Retrieve | Search | Inactivate' required=true)
        public String actionType;
        @InvocableVariable(label='Checklist ID' description='The unique ID of the Checklist record to target for Modify, Retrieve, or Inactivate actions. For bulk operations, provide the specific ID for each record in its corresponding request object. Example: "a00Hu000002XYZ123"')
        public String checklistId;
        @InvocableVariable(label='Checklist Name' description='The name for the Checklist. Required for "Create" and used for "Modify" and "Search" actions.')
        public String checklistName;
        @InvocableVariable(label='Created Date' description='Search only. Filters by Created Date. WARNING: Each "Search" request executes an independent database query. Example: "TODAY" or "LAST_N_DAYS:30"')
        public String createdDate;
        @InvocableVariable(label='Last Modified Date' description='Search only. Filters by Last Modified Date. WARNING: Each "Search" request executes an independent database query. Example: "2023-10-27"')
        public String lastModifiedDate;
        @InvocableVariable(label='Created By User ID' description='Search only. Filters by the creator User ID. WARNING: Each "Search" request executes an independent database query. Example: "005Hu000001ERwyIAG"')
        public String createdById;
        @InvocableVariable(label='Last Modified By User ID' description='Search only. Filters by the last modifier User ID. WARNING: Each "Search" request executes an independent database query. Example: "005Hu000001ERwzIAG"')
        public String lastModifiedById;
    }

    public class Response {
        @InvocableVariable(label='Success' description='Indicates if the specific operation for this request succeeded.')
        public Boolean success = false;
        @InvocableVariable(label='Message' description='A summary of the operation result for this specific request.')
        public String message = '';
        @InvocableVariable(label='Checklist Records' description='The Checklist record(s) returned by this specific request.')
        public List<Checklist__c> checklistRecords = new List<Checklist__c>();
    }

    @InvocableMethod(label='GA-FRA2 Manage Checklist' description='A bulk-safe method to manage Checklist records. Supports Create, Modify, Retrieve, and Search actions.')
    public static List<Response> manageChecklist(List<Request> requests) {
        List<Checklist__c> toCreate = new List<Checklist__c>();
        List<Checklist__c> toUpdate = new List<Checklist__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);
            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.checklistName)) {
                        res.message = 'Error: Checklist Name is required for Create.';
                    } else {
                        toCreate.add(new Checklist__c(Name = req.checklistName));
                    }
                }
                when 'Modify', 'Retrieve', 'Inactivate' {
                    if (String.isBlank(req.checklistId)) {
                        res.message = 'Error: Checklist ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.checklistId);
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
            Integer createIndex = 0;
            for (Integer i = 0; i < requests.size(); i++) {
                if (requests.get(i).actionType == 'Create' && String.isNotBlank(requests.get(i).checklistName)) {
                    Database.SaveResult sr = createResults[createIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Checklist created successfully.';
                        res.checklistRecords.add(toCreate[createIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    createIndex++;
                }
            }
        }

        if (!idsToProcess.isEmpty()) {
            Map<Id, Checklist__c> recordsFromDb = new Map<Id, Checklist__c>([SELECT Id, Name FROM Checklist__c WHERE Id IN :idsToProcess]);
            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (String.isBlank(req.checklistId) || !recordsFromDb.containsKey(req.checklistId)) continue;
                Response res = responseMap.get(i);
                Checklist__c record = recordsFromDb.get(req.checklistId);
                if (req.actionType == 'Modify') {
                    if (String.isNotBlank(req.checklistName)) {
                        record.Name = req.checklistName;
                        toUpdate.add(record);
                    }
                } else if (req.actionType == 'Inactivate') {
                    res.success = true;
                    res.message = 'Inactivate action noted, but no status field exists on object to update.';
                } else if (req.actionType == 'Retrieve') {
                    res.success = true;
                    res.message = 'Checklist retrieved successfully.';
                    res.checklistRecords.add(record);
                }
            }
        }
        
        if (!toUpdate.isEmpty()){
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            Integer updateIndex = 0;
            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                 if(req.actionType == 'Modify' && String.isNotBlank(req.checklistId) && responseMap.get(i).message == ''){
                     Database.SaveResult sr = updateResults[updateIndex];
                     Response res = responseMap.get(i);
                     if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Checklist modified successfully.';
                        res.checklistRecords.add(toUpdate[updateIndex]);
                     } else {
                         res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                     }
                     updateIndex++;
                 }
            }
        }
        
        return new List<Response>(responseMap.values());
    }
    
    private static void handleSearch(Request req, Response res) {
        String query = 'SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById FROM Checklist__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.checklistName)) conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.checklistName) + '%\'');
        if (String.isNotBlank(req.createdById)) conditions.add('CreatedById = \'' + String.escapeSingleQuotes(req.createdById) + '\'');
        if (String.isNotBlank(req.lastModifiedById)) conditions.add('LastModifiedById = \'' + String.escapeSingleQuotes(req.lastModifiedById) + '\'');
        
        if (String.isNotBlank(req.createdDate)) {
            conditions.add(GAFRA2Utility.parseDateFilter('CreatedDate', req.createdDate));
        }
        if (String.isNotBlank(req.lastModifiedDate)) {
            conditions.add(GAFRA2Utility.parseDateFilter('LastModifiedDate', req.lastModifiedDate));
        }

        if(!conditions.isEmpty()){
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        query += ' ORDER BY LastModifiedDate DESC LIMIT 500';

        try {
            List<Checklist__c> records = Database.query(query);
            res.success = true;
            res.message = 'Search executed successfully. Records found: ' + records.size();
            res.checklistRecords = records;
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}