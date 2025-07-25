public with sharing class GAEOA2ADMSprintHandler {

    // Inner classes to define the structure of the request and response
    public class Request {
        @InvocableVariable(label='Action' description='The action to perform (Create, Modify).' required=true)
        public String action;

        @InvocableVariable(label='Sprints' description='A list of Sprint records to process.' required=true)
        public List<SprintWrapper> sprints;
    }

    public class SprintWrapper {
        @InvocableVariable(label='Sprint ID' description='The ID of the Sprint record for modifications.')
        public String Id;
        @InvocableVariable(label='Name' description='The name of the sprint.')
        public String Name;
        @InvocableVariable(label='Start Date' description='The start date of the sprint.')
        public Date startDate;
        @InvocableVariable(label='End Date' description='The end date of the sprint.')
        public Date endDate;
        @InvocableVariable(label='Scrum Team ID' description='The ID of the associated Scrum Team.')
        public String scrumTeamId;
        @InvocableVariable(label='Goals' description='The goals for the sprint.')
        public String goals;
        @InvocableVariable(label='External ID' description='External ID for the sprint.')
        public String externalId;
    }

    public class Response {
        @InvocableVariable(label='Success' description='Indicates whether the operation was successful.')
        public Boolean success = false;
        @InvocableVariable(label='Message' description='Provides a summary of the operation results.')
        public String message = '';
        @InvocableVariable(label='Sprints' description='A list of the processed Sprint records.')
        public List<agf__ADM_Sprint__c> sprints = new List<agf__ADM_Sprint__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Sprints' description='Handles Create and Modify for Sprint records.')
    public static List<Response> manageSprints(List<Request> requests) {
        // Prepare lists for DML operations
        List<agf__ADM_Sprint__c> sprintsToCreate = new List<agf__ADM_Sprint__c>();
        List<agf__ADM_Sprint__c> sprintsToUpdate = new List<agf__ADM_Sprint__c>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        // First loop: Process requests and sort records into lists for DML
        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            if (req.sprints == null || req.sprints.isEmpty()) {
                res.message = 'Error: Sprint data is missing.';
                continue;
            }

            // A single request can contain multiple sprints to process for the *same* action
            for (SprintWrapper wrap : req.sprints) {
                if ('Create'.equalsIgnoreCase(req.action)) {
                    sprintsToCreate.add(fromWrapper(wrap));
                } else if ('Modify'.equalsIgnoreCase(req.action)) {
                    if (String.isBlank(wrap.Id)) {
                        // We can't assign a specific error message to a single wrapper in a bulk context easily,
                        // so we set the response for the whole request to failed.
                        res.message = 'Error: Sprint ID is required for all records in a Modify request.';
                    } else {
                        sprintsToUpdate.add(fromWrapper(wrap));
                    }
                } else {
                    res.message = 'Error: Invalid or missing action type specified: ' + req.action;
                }
            }
             // If an error was found for modify, we should not proceed with the update for this request
            if(res.message.startsWith('Error: Sprint ID is required')){
                sprintsToUpdate.clear();
            }
        }

        // Second part: Perform DML and handle results
        if (!sprintsToCreate.isEmpty()) {
            Database.SaveResult[] createResults = Database.insert(sprintsToCreate, false);
            handleSaveResults(responseMap, requests, sprintsToCreate, createResults, 'Create');
        }
        if (!sprintsToUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(sprintsToUpdate, false);
            handleSaveResults(responseMap, requests, sprintsToUpdate, updateResults, 'Modify');
        }

        return responseMap.values();
    }
    
    // Helper to process DML results and populate response
    private static void handleSaveResults(Map<Integer, Response> responseMap, List<Request> requests, List<agf__ADM_Sprint__c> records, Database.SaveResult[] saveResults, String action) {
        Integer recordIndexOffset = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            if (!action.equalsIgnoreCase(req.action) || req.sprints == null) continue;

            Response res = responseMap.get(i);
            if (res.message.startsWith('Error:')) continue; // Skip processing if request already has an error

            Boolean allSuccess = true;
            List<String> errorMessages = new List<String>();

            for(Integer j = 0; j < req.sprints.size(); j++){
                Integer currentIndex = recordIndexOffset + j;
                if(currentIndex < saveResults.size()){
                    Database.SaveResult sr = saveResults[currentIndex];
                    if (sr.isSuccess()) {
                        res.sprints.add(records[currentIndex]);
                    } else {
                        allSuccess = false;
                        errorMessages.add(sr.getErrors()[0].getMessage());
                    }
                }
            }

            res.success = allSuccess;
            if(allSuccess){
                 res.message = 'All ' + req.sprints.size() + ' sprint(s) ' + action.toLowerCase() + 'd successfully.';
            } else {
                 res.message = 'Errors occurred during ' + action + ' operation: ' + String.join(errorMessages, '; ');
            }
            
            recordIndexOffset += req.sprints.size();
        }
    }

    // Helper to convert wrapper to SObject
    private static agf__ADM_Sprint__c fromWrapper(SprintWrapper wrap) {
        agf__ADM_Sprint__c sprint = new agf__ADM_Sprint__c();
        if (String.isNotBlank(wrap.Id)) {
            sprint.Id = wrap.Id;
        }
        sprint.Name = wrap.Name;
        sprint.agf__Start_Date__c = wrap.startDate;
        sprint.agf__End_Date__c = wrap.endDate;
        sprint.agf__Scrum_Team__c = wrap.scrumTeamId;
        sprint.agf__Goals__c = wrap.goals;
        sprint.agf__External_ID__c = wrap.externalId;
        return sprint;
    }
}