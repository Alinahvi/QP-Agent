public with sharing class GAFRA2ChecklistAssetHandler {

    // Request and Response classes remain the same...
    public class Request {
        @InvocableVariable(label='Action Type' description='Specify the action: Create | Modify | Retrieve | Search | Inactivate' required=true)
        public String actionType;
        @InvocableVariable(label='Checklist Asset ID' description='The unique ID of the Checklist Asset record to target for Modify, Retrieve, or Inactivate actions. For bulk operations, provide the specific ID for each record in its corresponding request object. Example: "a02Hu000001ABCDEFE"')
        public String checklistAssetId;
        @InvocableVariable(label='Checklist Asset Name' description='The name for the Checklist Asset (the individual task). Required for "Create" and used for "Modify" and "Search" actions.')
        public String checklistAssetName;
        @InvocableVariable(label='Checklist ID' description='The ID of the parent Checklist record this asset belongs to. Required for "Create" and used for "Modify" actions to re-parent the record. Example: "a00Hu000002XYZ123"')
        public String checklistId;
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
        @InvocableVariable(label='Checklist Asset Records' description='The Checklist Asset record(s) returned by this specific request.')
        public List<Checklist_Asset__c> checklistAssetRecords = new List<Checklist_Asset__c>();
    }

    @InvocableMethod(label='GA-FRA2 Manage Checklist Asset' description='A bulk-safe method to manage Checklist Asset (task) records. Supports Create, Modify, Retrieve, and Search actions.')
    public static List<Response> manageChecklistAsset(List<Request> requests) {
        // The main logic of the method remains the same
        List<Checklist_Asset__c> toCreate = new List<Checklist_Asset__c>();
        List<Checklist_Asset__c> toUpdate = new List<Checklist_Asset__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.checklistAssetName) || String.isBlank(req.checklistId)) {
                        res.message = 'Error: Checklist Asset Name and parent Checklist ID are required for Create.';
                    } else {
                        toCreate.add(new Checklist_Asset__c(
                            Name = req.checklistAssetName,
                            Checklist__c = req.checklistId
                        ));
                    }
                }
                when 'Modify', 'Retrieve', 'Inactivate' {
                    if (String.isBlank(req.checklistAssetId)) {
                        res.message = 'Error: Checklist Asset ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.checklistAssetId);
                    }
                }
                when 'Search' {
                    handleSearch(req, res); // This now calls the improved search handler
                }
                when else {
                    res.message = 'Error: Invalid or missing action type.';
                }
            }
        }
        
        // ... rest of the DML logic remains the same ...
        if (!toCreate.isEmpty()) {
            Database.SaveResult[] createResults = Database.insert(toCreate, false);
            Integer createIndex = 0;
            for (Integer i = 0; i < requests.size(); i++) {
                if (requests.get(i).actionType == 'Create' && String.isNotBlank(requests.get(i).checklistAssetName)) {
                    Database.SaveResult sr = createResults[createIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Checklist Asset created successfully.';
                        res.checklistAssetRecords.add(toCreate[createIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    createIndex++;
                }
            }
        }
        if (!idsToProcess.isEmpty()) {
            Map<Id, Checklist_Asset__c> recordsFromDb = new Map<Id, Checklist_Asset__c>([
                SELECT Id, Name, Checklist__c FROM Checklist_Asset__c WHERE Id IN :idsToProcess
            ]);
            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (String.isBlank(req.checklistAssetId) || !recordsFromDb.containsKey(req.checklistAssetId)) continue;
                Response res = responseMap.get(i);
                Checklist_Asset__c record = recordsFromDb.get(req.checklistAssetId);
                if (req.actionType == 'Modify') {
                    if (String.isNotBlank(req.checklistAssetName)) record.Name = req.checklistAssetName;
                    if (String.isNotBlank(req.checklistId)) record.Checklist__c = req.checklistId;
                    toUpdate.add(record);
                } else if (req.actionType == 'Inactivate') {
                    res.success = true;
                    res.message = 'Inactivate action noted, but no status field exists on object to update.';
                } else if (req.actionType == 'Retrieve') {
                    res.success = true;
                    res.message = 'Checklist Asset retrieved successfully.';
                    res.checklistAssetRecords.add(record);
                }
            }
        }
        if (!toUpdate.isEmpty()){
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            Integer updateIndex = 0;
            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                 if(req.actionType == 'Modify' && String.isNotBlank(req.checklistAssetId) && responseMap.get(i).message == ''){
                     Database.SaveResult sr = updateResults[updateIndex];
                     Response res = responseMap.get(i);
                     if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Checklist Asset modified successfully.';
                        res.checklistAssetRecords.add(toUpdate[updateIndex]);
                     } else {
                         res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                     }
                     updateIndex++;
                 }
            }
        }
        return new List<Response>(responseMap.values());
    }
    
    // --- UPDATED Search Handler and NEW Helper Method ---
    private static void handleSearch(Request req, Response res) {
        String query = 'SELECT Id, Name, Checklist__c, CreatedDate, LastModifiedDate FROM Checklist_Asset__c';
        List<String> conditions = new List<String>();

        // Sanitized string inputs
        if (String.isNotBlank(req.checklistAssetName)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.checklistAssetName) + '%\'');
        }
        if (String.isNotBlank(req.checklistId)) {
            conditions.add('Checklist__c = \'' + String.escapeSingleQuotes(req.checklistId) + '\'');
        }
        if (String.isNotBlank(req.createdById)) {
            conditions.add('CreatedById = \'' + String.escapeSingleQuotes(req.createdById) + '\'');
        }
        if (String.isNotBlank(req.lastModifiedById)) {
            conditions.add('LastModifiedById = \'' + String.escapeSingleQuotes(req.lastModifiedById) + '\'');
        }
        
        // --- UPDATED: Call the robust date parser ---
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
            List<Checklist_Asset__c> records = Database.query(query);
            res.success = true;
            res.message = 'Search executed successfully. Records found: ' + records.size();
            res.checklistAssetRecords = records;
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}