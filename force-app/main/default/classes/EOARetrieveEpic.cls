public with sharing class EOARetrieveEpic {

    // Invocable method to retrieve Epic records
    @InvocableMethod(label='GA-EOA Retrieve Epic Records' description='Retrieves existing Epic records based on provided IDs. Supports bulk operations.')
    public static List<EOARetrieveEpicResponse> retrieveEpics(List<EOARetrieveEpicRequest> requests) {
        List<EOARetrieveEpicResponse> responses = new List<EOARetrieveEpicResponse>();
        Set<Id> epicIds = new Set<Id>();

        // Collect IDs for retrieval
        for (EOARetrieveEpicRequest request : requests) {
            epicIds.add(request.epicId);
        }

        // Query Epic records
        Map<Id, agf__ADM_Epic__c> epicsMap = new Map<Id, agf__ADM_Epic__c>([SELECT Id, Name FROM agf__ADM_Epic__c WHERE Id IN :epicIds]);

        // Prepare responses
        for (Id epicId : epicIds) {
            EOARetrieveEpicResponse response = new EOARetrieveEpicResponse();
            agf__ADM_Epic__c epic = epicsMap.get(epicId);
            if (epic != null) {
                response.epicId = epic.Id;
                response.epicName = epic.Name;
                response.found = true;
            } else {
                response.epicId = epicId;
                response.found = false;
            }
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOARetrieveEpicRequest {
        @InvocableVariable(label='GA-EOA Epic ID' required=true description='The Salesforce ID of the Epic record to retrieve.')
        public Id epicId;
    }

    // Response wrapper for invocable method outputs
    public class EOARetrieveEpicResponse {
        @InvocableVariable(label='GA-EOA Epic ID' description='Salesforce ID of the retrieved Epic record.')
        public Id epicId;

        @InvocableVariable(label='GA-EOA Epic Name' description='Name of the retrieved Epic record.')
        public String epicName;

        @InvocableVariable(label='GA-EOA Found' description='Indicates whether the Epic record was found.')
        public Boolean found;
    }
}