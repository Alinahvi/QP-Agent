public with sharing class GAEOA2FileHandler {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 File Record ID' description='Salesforce File record ID. Required for Modify and Retrieve actions.')
        public String fileId;

        // --- driveconnect__File__c Fields ---
        @InvocableVariable(label='GA-EOA2 File Name' description='Value for the File Name (Name) field.')
        public String fileName;
        @InvocableVariable(label='GA-EOA2 Title' description='Value for the Title (driveconnect__Title__c) field.')
        public String title;
        @InvocableVariable(label='GA-EOA2 Description' description='Value for the Description (driveconnect__Description__c) field.')
        public String description;
        @InvocableVariable(label='GA-EOA2 File Location' description='Value for the File Location (driveconnect__File_Location__c) field.')
        public String fileLocation;
        @InvocableVariable(label='GA-EOA2 File URL' description='Value for the File URL (driveconnect__File_URL__c) field.')
        public String fileURL;
        @InvocableVariable(label='GA-EOA2 Record ID' description='Value for the related Record ID (driveconnect__Record_Id__c) field.')
        public String recordId;
        @InvocableVariable(label='GA-EOA2 Object' description='Value for the related Object (driveconnect__Object__c) field.')
        public String objectName;
        @InvocableVariable(label='GA-EOA2 Marked for Delete' description='Value for Marked for Delete (driveconnect__Marked_for_Delete__c) field.')
        public Boolean markedForDelete;
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
        @InvocableVariable(label='GA-EOA2 File Records' description='List of File records from the operation.')
        public List<driveconnect__File__c> fileRecords = new List<driveconnect__File__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Files' description='Handles Create, Modify, Retrieve, and Search actions for File records.')
    public static List<Response> manageFiles(List<Request> requests) {
        List<driveconnect__File__c> toCreate = new List<driveconnect__File__c>();
        List<driveconnect__File__c> toUpdate = new List<driveconnect__File__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            responseMap.put(i, new Response());
            Request req = requests.get(i);
            
            switch on req.actionType {
                when 'Create' {
                    toCreate.add(mapRequestToFile(req, new driveconnect__File__c()));
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.fileId)) {
                        responseMap.get(i).message = 'Error: File ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.fileId);
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
            String allFieldsQuery = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('driveconnect__File__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM driveconnect__File__c WHERE Id IN :idsToProcess';
            Map<Id, driveconnect__File__c> filesFromDb = new Map<Id, driveconnect__File__c>((List<driveconnect__File__c>)Database.query(allFieldsQuery));

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                Response res = responseMap.get(i);
                
                if (String.isNotBlank(req.fileId) && filesFromDb.containsKey(req.fileId)) {
                    if (req.actionType == 'Modify') {
                        toUpdate.add(mapRequestToFile(req, filesFromDb.get(req.fileId)));
                    } else if (req.actionType == 'Retrieve') {
                        res.success = true;
                        res.message = 'File retrieved successfully.';
                        res.fileRecords.add(filesFromDb.get(req.fileId));
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

    private static driveconnect__File__c mapRequestToFile(Request req, driveconnect__File__c file) {
        if(req.actionType == 'Modify') file.Id = req.fileId;
        if(req.fileName != null) file.Name = req.fileName;
        if(req.title != null) file.driveconnect__Title__c = req.title;
        if(req.description != null) file.driveconnect__Description__c = req.description;
        if(req.fileLocation != null) file.driveconnect__File_Location__c = req.fileLocation;
        if(req.fileURL != null) file.driveconnect__File_URL__c = req.fileURL;
        if(req.recordId != null) file.driveconnect__Record_Id__c = req.recordId;
        if(req.objectName != null) file.driveconnect__Object__c = req.objectName;
        if(req.markedForDelete != null) file.driveconnect__Marked_for_Delete__c = req.markedForDelete;
        if(req.ownerId != null) file.OwnerId = req.ownerId;
        return file;
    }

    private static void handleDmlResults(Database.SaveResult[] results, List<driveconnect__File__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType == action) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'File ' + action.toLowerCase() + 'd successfully.';
                        res.fileRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                }
            }
        }
    }
    
    private static void handleSearch(Request req, Response res) {
        String allFields = String.join(new List<String>(Schema.getGlobalDescribe().get('driveconnect__File__c').getDescribe().fields.getMap().keySet()), ',');
        String soql = 'SELECT ' + allFields + ' FROM driveconnect__File__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.fileName)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.fileName) + '%\'');
        }
        if (String.isNotBlank(req.title)) {
            conditions.add('driveconnect__Title__c LIKE \'%' + String.escapeSingleQuotes(req.title) + '%\'');
        }
        if (String.isNotBlank(req.recordId)) {
            conditions.add('driveconnect__Record_Id__c = \'' + String.escapeSingleQuotes(req.recordId) + '\'');
        }
        if (String.isNotBlank(req.ownerId)) {
            conditions.add('OwnerId = \'' + String.escapeSingleQuotes(req.ownerId) + '\'');
        }
        if (String.isNotBlank(req.fileLocation)) {
            conditions.add('driveconnect__File_Location__c = \'' + String.escapeSingleQuotes(req.fileLocation) + '\'');
        }
        if (String.isNotBlank(req.objectName)) {
            conditions.add('driveconnect__Object__c = \'' + String.escapeSingleQuotes(req.objectName) + '\'');
        }
        if (req.markedForDelete != null) {
            conditions.add('driveconnect__Marked_for_Delete__c = ' + req.markedForDelete);
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
            res.fileRecords = Database.query(soql);
            res.success = true;
            res.message = 'File search executed. Records found: ' + res.fileRecords.size();
        } catch (Exception e) {
            res.message = 'Error during File search: ' + e.getMessage();
        }
    }
}