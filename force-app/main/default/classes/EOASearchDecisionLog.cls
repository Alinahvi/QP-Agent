public with sharing class EOASearchDecisionLog {

    // Invocable method to search Decision Log records dynamically
    @InvocableMethod(label='GA-EOA Search Decision Log Records' description='Dynamically searches Decision Log records based on provided search criteria. Supports flexible querying.')
    public static List<EOASearchDecisionLogResponse> searchDecisionLogs(List<EOASearchDecisionLogRequest> requests) {
        List<EOASearchDecisionLogResponse> responses = new List<EOASearchDecisionLogResponse>();

        for (EOASearchDecisionLogRequest request : requests) {
            String query = 'SELECT Id, Name FROM Decision_Log__c WHERE ' + request.criteria;
            List<Decision_Log__c> logs = Database.query(query);

            EOASearchDecisionLogResponse response = new EOASearchDecisionLogResponse();
            response.logIds = new List<Id>();
            response.logNumbers = new List<String>();
            response.totalLogs = logs.size();

            for (Decision_Log__c log : logs) {
                response.logIds.add(log.Id);
                response.logNumbers.add(log.Name);
            }

            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOASearchDecisionLogRequest {
        @InvocableVariable(label='GA-EOA Search Criteria' required=true description='Dynamic SOQL criteria for searching Decision Logs. Example: "Name LIKE \'%Test%\'".')
        public String criteria;
    }

    // Response wrapper for invocable method outputs
    public class EOASearchDecisionLogResponse {
        @InvocableVariable(label='GA-EOA Decision Log IDs' description='List of Salesforce IDs for Decision Log records found.')
        public List<Id> logIds;

        @InvocableVariable(label='GA-EOA Decision Log Numbers' description='List of auto-generated numbers for Decision Log records.')
        public List<String> logNumbers;

        @InvocableVariable(label='GA-EOA Total Decision Logs' description='Total number of Decision Log records found.')
        public Integer totalLogs;
    }
}