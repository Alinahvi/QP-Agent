public with sharing class EOARetrieveWork {

    // Invocable method to retrieve Work records
    @InvocableMethod(label='GA-EOA Retrieve Work Records' description='Retrieves existing Work records based on provided IDs. Supports bulk operations.')
    public static List<EOARetrieveWorkResponse> retrieveWorks(List<EOARetrieveWorkRequest> requests) {
        List<EOARetrieveWorkResponse> responses = new List<EOARetrieveWorkResponse>();
        Set<Id> workIds = new Set<Id>();

        // Collect IDs for retrieval
        for (EOARetrieveWorkRequest request : requests) {
            workIds.add(request.workId);
        }

        // Query Work records
        Map<Id, agf__ADM_Work__c> worksMap = new Map<Id, agf__ADM_Work__c>([SELECT Id, Name FROM agf__ADM_Work__c WHERE Id IN :workIds]);

        // Prepare responses
        for (Id workId : workIds) {
            EOARetrieveWorkResponse response = new EOARetrieveWorkResponse();
            agf__ADM_Work__c work = worksMap.get(workId);
            if (work != null) {
                response.workId = work.Id;
                response.workName = work.Name;
                response.found = true;
            } else {
                response.workId = workId;
                response.found = false;
            }
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOARetrieveWorkRequest {
        @InvocableVariable(label='GA-EOA Work ID' required=true description='The Salesforce ID of the Work record to retrieve.')
        public Id workId;
    }

    // Response wrapper for invocable method outputs
    public class EOARetrieveWorkResponse {
        @InvocableVariable(label='GA-EOA Work ID' description='Salesforce ID of the retrieved Work record.')
        public Id workId;

        @InvocableVariable(label='GA-EOA Work Name' description='Auto-generated name of the Work record.')
        public String workName;

        @InvocableVariable(label='GA-EOA Found' description='Indicates whether the Work record was found.')
        public Boolean found;
    }
}