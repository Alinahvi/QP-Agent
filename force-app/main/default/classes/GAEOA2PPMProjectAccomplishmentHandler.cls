/**
 * @description Handles CRUD operations for Project Accomplishment records (agf__PPM_Project_Accomplishment__c).
 * This invocable handler is used to track specific achievements or milestones for a Project or Epic.
 */
public with sharing class GAEOA2PPMProjectAccomplishmentHandler {

    // --- INNER REQUEST CLASS (Strongly-Typed) ---
    public class Request {
        @InvocableVariable(label='Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;

        @InvocableVariable(label='Accomplishment ID' description='Salesforce ID of the record. Required for Modify or Retrieve.')
        public String accomplishmentId;

        @InvocableVariable(label='Related Project ID' description='ID of the parent Project. Required for Create.')
        public String projectId;
        
        @InvocableVariable(label='Related Epic ID' description='(Optional) ID of the parent Epic.')
        public String epicId;
        
        @InvocableVariable(label='Accomplishment Summary' description='A description of the accomplishment or milestone. Required for Create.')
        public String accomplishmentSummary;
        
        @InvocableVariable(label='Accomplishment Date' description='The date the milestone was achieved.')
        public Date accomplishmentDate;

        @InvocableVariable(label='Accomplishment Type' description='The type of accomplishment (e.g., Planned, Completed).')
        public String accomplishmentType;

        // Search-specific fields
        @InvocableVariable(label='Search by Project ID' description='For Search only. Find all accomplishments for a specific Project.')
        public String searchProjectId;
        
        @InvocableVariable(label='Search by Epic ID' description='For Search only. Find all accomplishments for a specific Epic.')
        public String searchEpicId;
    }

    // --- INNER RESPONSE CLASS ---
    public class Response {
        @InvocableVariable(label='Success' description='True if the operation was successful.')
        public Boolean success = false;

        @InvocableVariable(label='Message' description='A summary of the operation result.')
        public String message = '';

        @InvocableVariable(label='Accomplishment Records' description='A list of Accomplishment records returned by the operation.')
        public List<agf__PPM_Project_Accomplishment__c> accomplishmentRecords = new List<agf__PPM_Project_Accomplishment__c>();
    }

    // --- INVOCABLE METHOD ---
    @InvocableMethod(label='EOA Manage Project Accomplishments' description='A bulk-safe method to manage Project Accomplishment records.')
    public static List<Response> manageProjectAccomplishments(List<Request> requests) {
        List<agf__PPM_Project_Accomplishment__c> toCreate = new List<agf__PPM_Project_Accomplishment__c>();
        List<agf__PPM_Project_Accomplishment__c> toUpdate = new List<agf__PPM_Project_Accomplishment__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.projectId)) {
                        res.message = 'Error: Related Project ID is required for creation.';
                    } else if (String.isBlank(req.accomplishmentSummary)) {
                         res.message = 'Error: Accomplishment Summary is required for creation.';
                    }
                    else {
                        agf__PPM_Project_Accomplishment__c newAccomplishment = new agf__PPM_Project_Accomplishment__c(
                            agf__Project__c = req.projectId,
                            Epic__c = req.epicId, // Custom field you added
                            agf__Accomplishment_Summary__c = req.accomplishmentSummary,
                            agf__Accomplishment_Date__c = req.accomplishmentDate,
                            agf__Accomplishment_Type__c = req.accomplishmentType
                        );
                        toCreate.add(newAccomplishment);
                    }
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.accomplishmentId)) {
                        res.message = 'Error: Accomplishment ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.accomplishmentId);
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
                        res.message = 'Accomplishment created successfully.';
                        res.accomplishmentRecords.add(toCreate[createIndex]);
                    } else {
                        res.message = 'Error creating accomplishment: ' + sr.getErrors()[0].getMessage();
                    }
                    createIndex++;
                }
            }
        }

        if (!idsToProcess.isEmpty()) {
            Map<Id, agf__PPM_Project_Accomplishment__c> accomplishmentsFromDb = new Map<Id, agf__PPM_Project_Accomplishment__c>([
                SELECT Id, Name, agf__Project__c, Epic__c, agf__Accomplishment_Summary__c, agf__Accomplishment_Date__c, agf__Accomplishment_Type__c
                FROM agf__PPM_Project_Accomplishment__c WHERE Id IN :idsToProcess
            ]);

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (req.actionType == 'Modify' || req.actionType == 'Retrieve') {
                     if (String.isBlank(req.accomplishmentId) || !accomplishmentsFromDb.containsKey(req.accomplishmentId)) {
                        if (responseMap.get(i).message == '') {
                           responseMap.get(i).message = 'Error: Accomplishment with ID ' + req.accomplishmentId + ' not found.';
                        }
                        continue;
                    }

                    agf__PPM_Project_Accomplishment__c acc = accomplishmentsFromDb.get(req.accomplishmentId);
                    if (req.actionType == 'Modify') {
                        if(String.isNotBlank(req.accomplishmentSummary)) acc.agf__Accomplishment_Summary__c = req.accomplishmentSummary;
                        if(req.accomplishmentDate != null) acc.agf__Accomplishment_Date__c = req.accomplishmentDate;
                        if(String.isNotBlank(req.accomplishmentType)) acc.agf__Accomplishment_Type__c = req.accomplishmentType;
                        toUpdate.add(acc);
                    } else if (req.actionType == 'Retrieve') {
                        responseMap.get(i).success = true;
                        responseMap.get(i).message = 'Accomplishment retrieved successfully.';
                        responseMap.get(i).accomplishmentRecords.add(acc);
                    }
                }
            }
        }

        if(!toUpdate.isEmpty()){
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            Integer updateIndex = 0;
            for(Integer i = 0; i < requests.size(); i++){
                 Request req = requests.get(i);
                 if(req.actionType == 'Modify' && responseMap.get(i).message == ''){
                     Database.SaveResult sr = updateResults[updateIndex];
                     Response res = responseMap.get(i);
                     if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Accomplishment updated successfully.';
                        res.accomplishmentRecords.add(toUpdate[updateIndex]);
                     } else {
                         res.message = 'Error updating accomplishment: ' + sr.getErrors()[0].getMessage();
                     }
                     updateIndex++;
                 }
            }
        }
        
        return new List<Response>(responseMap.values());
    }
    
    // --- SEARCH HELPER METHOD ---
    private static void handleSearch(Request req, Response res) {
        String soql = 'SELECT Id, Name, agf__Project__c, Epic__c, agf__Accomplishment_Summary__c, agf__Accomplishment_Date__c, agf__Accomplishment_Type__c ' + 
                      'FROM agf__PPM_Project_Accomplishment__c';
        
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.searchProjectId)) {
            conditions.add('agf__Project__c = \'' + String.escapeSingleQuotes(req.searchProjectId) + '\'');
        }
        if (String.isNotBlank(req.searchEpicId)) {
            conditions.add('Epic__c = \'' + String.escapeSingleQuotes(req.searchEpicId) + '\'');
        }

        if(!conditions.isEmpty()){
            soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        soql += ' ORDER BY agf__Accomplishment_Date__c DESC LIMIT 500';

        try {
            List<agf__PPM_Project_Accomplishment__c> results = Database.query(soql);
            res.success = true;
            res.message = 'Accomplishment search executed successfully. Records found: ' + results.size();
            res.accomplishmentRecords = results;
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}