public with sharing class GAFRA2AudienceHandler {

    // Request and Response classes remain the same
    public class Request {
        @InvocableVariable(label='Action Type' description='Specify the action to perform: Create | Modify | Retrieve | Search | Inactivate' required=true)
        public String actionType;
        @InvocableVariable(label='Audience ID' description='Unique Salesforce Audience record ID. Required for Modify Retrieve or Inactivate actions. Leave blank for Create and Search.')
        public String audienceId;
        @InvocableVariable(label='Audience Name' description='Name of the Audience. Used for Create and Modify actions or as a keyword in Search actions to find matching audiences.')
        public String audienceName;
        @InvocableVariable(label='Created Date' description='For search operations only. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals.')
        public String createdDate;
        @InvocableVariable(label='Last Modified Date' description='For search operations only. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals.')
        public String lastModifiedDate;
        @InvocableVariable(label='Created By User ID' description='For search operations only. Salesforce User ID of the creator of the record.')
        public String createdById;
        @InvocableVariable(label='Last Modified By User ID' description='For search operations only. Salesforce User ID of the user who last modified the record.')
        public String lastModifiedById;
    }
    public class Response {
        @InvocableVariable(label='Success' description='True if operation succeeded.')
        public Boolean success = false;
        @InvocableVariable(label='Message' description='Human-readable summary of the operation result.')
        public String message = '';
        @InvocableVariable(label='Audience Records' description='List of Audience record details returned for Retrieve Search and Create actions.')
        public List<Audience__c> audienceRecords = new List<Audience__c>();
    }

    @InvocableMethod(label='GA-FRA2 Manage Audience Records' description='A bulk-safe method to manage Audience records. It supports creating, updating, retrieving, and searching for multiple audiences in a single transaction.')
    public static List<Response> manageAudience(List<Request> requests) {
        // The main bulk logic remains the same
        List<Audience__c> toCreate = new List<Audience__c>();
        List<Audience__c> toUpdate = new List<Audience__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.audienceName)) {
                        res.message = 'Error: Audience Name is required for creation.';
                    } else {
                        toCreate.add(new Audience__c(Name = req.audienceName));
                    }
                }
                when 'Modify', 'Retrieve', 'Inactivate' {
                    if (String.isBlank(req.audienceId)) {
                        res.message = 'Error: Audience ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.audienceId);
                    }
                }
                when 'Search' {
                    handleSearch(req, res); // This will now call the upgraded search logic
                }
                when else {
                    res.message = 'Error: Invalid or missing action type.';
                }
            }
        }
        
        // DML logic remains the same...
        if (!toCreate.isEmpty()) {
            Database.SaveResult[] createResults = Database.insert(toCreate, false);
            Integer createIndex = 0;
            for (Integer i = 0; i < requests.size(); i++) {
                if (requests.get(i).actionType == 'Create' && String.isNotBlank(requests.get(i).audienceName)) {
                    Database.SaveResult sr = createResults[createIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Audience created successfully.';
                        res.audienceRecords.add(toCreate[createIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    createIndex++;
                }
            }
        }
        if (!idsToProcess.isEmpty()) {
            Map<Id, Audience__c> audiencesFromDb = new Map<Id, Audience__c>([
                SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById 
                FROM Audience__c WHERE Id IN :idsToProcess
            ]);
            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (String.isBlank(req.audienceId) || !audiencesFromDb.containsKey(req.audienceId)) continue;
                Response res = responseMap.get(i);
                Audience__c aud = audiencesFromDb.get(req.audienceId);
                if (req.actionType == 'Modify') {
                    if (String.isNotBlank(req.audienceName)) {
                        aud.Name = req.audienceName;
                        toUpdate.add(aud);
                    }
                } else if (req.actionType == 'Inactivate') {
                    toUpdate.add(aud);
                } else if (req.actionType == 'Retrieve') {
                    res.success = true;
                    res.message = 'Audience retrieved successfully.';
                    res.audienceRecords.add(aud);
                }
            }
        }
        if(!toUpdate.isEmpty()){
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            Integer updateIndex = 0;
            for(Integer i = 0; i < requests.size(); i++){
                Request req = requests.get(i);
                 if(req.actionType == 'Modify' || req.actionType == 'Inactivate'){
                     if(String.isNotBlank(req.audienceId) && responseMap.get(i).message == ''){
                         Database.SaveResult sr = updateResults[updateIndex];
                         Response res = responseMap.get(i);
                         if (sr.isSuccess()) {
                            res.success = true;
                            res.message = 'Audience ' + req.actionType.toLowerCase() + 'd successfully.';
                            res.audienceRecords.add(toUpdate[updateIndex]);
                         } else {
                             res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                         }
                         updateIndex++;
                     }
                 }
            }
        }
        
        return new List<Response>(responseMap.values());
    }
    
    // --- UPDATED Search Handler ---
    private static void handleSearch(Request req, Response res) {
        String query = 'SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById FROM Audience__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.audienceName)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.audienceName) + '%\'');
        }
        if (String.isNotBlank(req.createdById)) {
            conditions.add('CreatedById = \'' + String.escapeSingleQuotes(req.createdById) + '\'');
        }
        if (String.isNotBlank(req.lastModifiedById)) {
            conditions.add('LastModifiedById = \'' + String.escapeSingleQuotes(req.lastModifiedById) + '\'');
        }

        // --- UPDATED: Call the robust date parser ---
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
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        query += ' ORDER BY LastModifiedDate DESC LIMIT 500';

        try {
            List<Audience__c> auds = Database.query(query);
            res.success = true;
            res.message = 'Audience search executed successfully. Records found: ' + auds.size();
            res.audienceRecords = auds;
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}