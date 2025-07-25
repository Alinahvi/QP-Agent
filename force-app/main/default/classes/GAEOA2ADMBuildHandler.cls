/**
 * @description Handles bulk-safe CRUD operations for Build records (agf__ADM_Build__c).
 * This Invocable Action is designed to be used in Salesforce Flows and other automated processes.
 * It follows a pattern of receiving a list of requests and processing them efficiently.
 */
public with sharing class GAEOA2ADMBuildHandler {

    private static final String SOBJECT_TYPE_LABEL = 'Build';

    /**
     * @description Defines the input parameters for each individual build operation.
     */
    public class Request {
        @InvocableVariable(label='Action Type' description='The operation to perform: Create | Modify | Retrieve | Search' required=true)
        public String actionType;

        @InvocableVariable(label='Build ID' description='The Salesforce ID of the Build record. Required for Modify or Retrieve actions.')
        public String buildId;

        @InvocableVariable(label='Build Name' description='The name of the Build. Used for Create, Modify, or as a search keyword.')
        public String buildName;
        
        @InvocableVariable(label='External ID' description='The external ID for the Build.')
        public String externalId;

        @InvocableVariable(label='Scrumforce ID' description='The Scrumforce ID for the Build.')
        public String scrumforceId;

        @InvocableVariable(label='Release Freeze Date' description='The release freeze date for the Build (YYYY-MM-DD format).')
        public Date releaseFreezeDate;

        @InvocableVariable(label='Created Date' description='For Search actions. Supports YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals (e.g., LAST_N_DAYS:30).')
        public String createdDate;

        @InvocableVariable(label='Last Modified Date' description='For Search actions. Supports YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals.')
        public String lastModifiedDate;
    }

    /**
     * @description Defines the output results for each individual build operation.
     */
    public class Response {
        @InvocableVariable(label='Success' description='True if the operation was successful.')
        public Boolean success = false;

        @InvocableVariable(label='Message' description='A summary of the operation result, or an error message.')
        public String message = '';

        @InvocableVariable(label='Build Records' description='A list of Build records returned by the operation.')
        public List<agf__ADM_Build__c> buildRecords = new List<agf__ADM_Build__c>();
    }

    /**
     * @description Main entry point for managing Build records. Processes a list of requests in a bulk-safe manner.
     * @param requests A list of Request objects, each defining an operation to perform.
     * @return A list of Response objects corresponding to each request.
     */
    @InvocableMethod(label='GA-EOA2 Manage Builds' description='Handles Create, Modify, Retrieve, and Search for Build records.')
    public static List<Response> manageBuilds(List<Request> requests) {
        List<agf__ADM_Build__c> toCreate = new List<agf__ADM_Build__c>();
        List<agf__ADM_Build__c> toUpdate = new List<agf__ADM_Build__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            if (String.isBlank(req.actionType)) {
                res.message = 'Error: Action Type is required.';
                continue;
            }

            switch on req.actionType.toLowerCase() {
                when 'create' {
                    if (String.isBlank(req.buildName)) {
                        res.message = 'Error: Build Name is required for creation.';
                    } else {
                        agf__ADM_Build__c newBuild = new agf__ADM_Build__c(Name = req.buildName);
                        if(String.isNotBlank(req.externalId)) newBuild.agf__External_ID__c = req.externalId;
                        if(String.isNotBlank(req.scrumforceId)) newBuild.agf__Scrumforce_ID__c = req.scrumforceId;
                        if(req.releaseFreezeDate != null) newBuild.agf__Release_Freeze__c = req.releaseFreezeDate;
                        toCreate.add(newBuild);
                    }
                }
                when 'modify', 'retrieve' {
                    if (String.isBlank(req.buildId)) {
                        res.message = 'Error: Build ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.buildId);
                    }
                }
                when 'search' {
                    handleSearch(req, res);
                }
                when else {
                    res.message = 'Error: Invalid action type specified: ' + req.actionType;
                }
            }
        }

        // DML and Query Processing
        if (!toCreate.isEmpty()) {
            processCreates(requests, responseMap, toCreate);
        }

        if (!idsToProcess.isEmpty()) {
            Map<Id, agf__ADM_Build__c> buildsFromDb = new Map<Id, agf__ADM_Build__c>([
                SELECT Id, Name, agf__External_ID__c, agf__Scrumforce_ID__c, agf__Release_Freeze__c, CreatedDate, LastModifiedDate 
                FROM agf__ADM_Build__c WHERE Id IN :idsToProcess
            ]);
            
            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests[i];
                String action = String.isBlank(req.actionType) ? '' : req.actionType.toLowerCase();

                if ((action == 'modify' || action == 'retrieve') && String.isNotBlank(req.buildId) && buildsFromDb.containsKey(req.buildId)) {
                    Response res = responseMap.get(i);
                    agf__ADM_Build__c build = buildsFromDb.get(req.buildId);

                    if (action == 'retrieve') {
                        res.success = true;
                        res.message = SOBJECT_TYPE_LABEL + ' retrieved successfully.';
                        res.buildRecords.add(build);
                    } else { // Modify
                        if(String.isNotBlank(req.buildName)) build.Name = req.buildName;
                        if(String.isNotBlank(req.externalId)) build.agf__External_ID__c = req.externalId;
                        if(String.isNotBlank(req.scrumforceId)) build.agf__Scrumforce_ID__c = req.scrumforceId;
                        if(req.releaseFreezeDate != null) build.agf__Release_Freeze__c = req.releaseFreezeDate;
                        toUpdate.add(build);
                    }
                }
            }
        }
        
        if(!toUpdate.isEmpty()){
            processUpdates(requests, responseMap, toUpdate);
        }

        return new List<Response>(responseMap.values());
    }

    private static void processCreates(List<Request> requests, Map<Integer, Response> responseMap, List<agf__ADM_Build__c> toCreate) {
        Database.SaveResult[] createResults = Database.insert(toCreate, false);
        Integer createIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType.equalsIgnoreCase('Create') && String.isNotBlank(requests.get(i).buildName)) {
                Database.SaveResult sr = createResults[createIndex];
                Response res = responseMap.get(i);
                if (sr.isSuccess()) {
                    res.success = true;
                    res.message = SOBJECT_TYPE_LABEL + ' created successfully.';
                    res.buildRecords.add(toCreate[createIndex]);
                } else {
                    res.message = 'Error creating ' + SOBJECT_TYPE_LABEL + ': ' + sr.getErrors()[0].getMessage();
                }
                createIndex++;
            }
        }
    }

    private static void processUpdates(List<Request> requests, Map<Integer, Response> responseMap, List<agf__ADM_Build__c> toUpdate) {
        Database.SaveResult[] updateResults = Database.update(toUpdate, false);
        Map<Id, Database.SaveResult> updateResultMap = new Map<Id, Database.SaveResult>();
        for(Integer i = 0; i < updateResults.size(); i++) {
            updateResultMap.put(updateResults[i].getId(), updateResults[i]);
        }

        for(Integer i = 0; i < requests.size(); i++){
            Request req = requests.get(i);
             if(req.actionType.equalsIgnoreCase('Modify') && String.isNotBlank(req.buildId) && updateResultMap.containsKey(req.buildId)){
                 Database.SaveResult sr = updateResultMap.get(req.buildId);
                 Response res = responseMap.get(i);
                 if (sr.isSuccess()) {
                    res.success = true;
                    res.message = SOBJECT_TYPE_LABEL + ' modified successfully.';
                    for (agf__ADM_Build__c updatedBuild : toUpdate) {
                        if (updatedBuild.Id == sr.getId()) {
                            res.buildRecords.add(updatedBuild);
                            break;
                        }
                    }
                 } else {
                     res.message = 'Error modifying ' + SOBJECT_TYPE_LABEL + ': ' + sr.getErrors()[0].getMessage();
                 }
             }
        }
    }

    private static void handleSearch(Request req, Response res) {
        String query = 'SELECT Id, Name, agf__External_ID__c, agf__Scrumforce_ID__c, agf__Release_Freeze__c, CreatedDate, LastModifiedDate FROM agf__ADM_Build__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.buildName)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.buildName) + '%\'');
        }
        if (String.isNotBlank(req.externalId)) {
            conditions.add('agf__External_ID__c = \'' + String.escapeSingleQuotes(req.externalId) + '\'');
        }
        if (String.isNotBlank(req.scrumforceId)) {
            conditions.add('agf__Scrumforce_ID__c = \'' + String.escapeSingleQuotes(req.scrumforceId) + '\'');
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
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        query += ' ORDER BY LastModifiedDate DESC LIMIT 500';

        try {
            List<agf__ADM_Build__c> builds = Database.query(query);
            res.success = true;
            res.message = 'Search executed successfully. Records found: ' + builds.size();
            res.buildRecords = builds;
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}