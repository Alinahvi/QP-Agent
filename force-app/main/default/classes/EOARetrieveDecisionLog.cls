public with sharing class EOARetrieveDecisionLog {

    // Invocable method to retrieve Decision Log records
    @InvocableMethod(label='GA-EOA Retrieve Decision Log Records' description='Retrieves existing Decision Log records based on provided IDs. Supports bulk operations.')
    public static List<EOARetrieveDecisionLogResponse> retrieveDecisionLogs(List<EOARetrieveDecisionLogRequest> requests) {
        List<EOARetrieveDecisionLogResponse> responses = new List<EOARetrieveDecisionLogResponse>();
        Set<Id> logIds = new Set<Id>();

        // Collect IDs for retrieval
        for (EOARetrieveDecisionLogRequest request : requests) {
            logIds.add(request.logId);
        }

        // Query Decision Log records
        Map<Id, Decision_Log__c> logsMap = new Map<Id, Decision_Log__c>([SELECT Id, Name FROM Decision_Log__c WHERE Id IN :logIds]);

        // Prepare responses
        for (Id logId : logIds) {
            EOARetrieveDecisionLogResponse response = new EOARetrieveDecisionLogResponse();
            Decision_Log__c log = logsMap.get(logId);
            if (log != null) {
                response.logId = log.Id;
                response.logNumber = log.Name;
                response.found = true;
            } else {
                response.logId = logId;
                response.found = false;
            }
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOARetrieveDecisionLogRequest {
        @InvocableVariable(label='GA-EOA Decision Log ID' required=true description='The Salesforce ID of the Decision Log record to retrieve.')
        public Id logId;
    }

    // Response wrapper for invocable method outputs
    public class EOARetrieveDecisionLogResponse {
        @InvocableVariable(label='GA-EOA Decision Log ID' description='Salesforce ID of the retrieved Decision Log record.')
        public Id logId;

        @InvocableVariable(label='GA-EOA Decision Log Number' description='Auto-generated number of the Decision Log record.')
        public String logNumber;

        @InvocableVariable(label='GA-EOA Found' description='Indicates whether the Decision Log record was found.')
        public Boolean found;
    }
}