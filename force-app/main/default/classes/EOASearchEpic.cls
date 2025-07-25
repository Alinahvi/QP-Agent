public with sharing class EOASearchEpic {

    // Invocable method to search Epic records dynamically
    @InvocableMethod(label='GA-EOA Search Epic Records' description='Dynamically searches Epic records based on provided search criteria. Supports flexible querying.')
    public static List<EOASearchEpicResponse> searchEpics(List<EOASearchEpicRequest> requests) {
        List<EOASearchEpicResponse> responses = new List<EOASearchEpicResponse>();

        for (EOASearchEpicRequest request : requests) {
            String query = 'SELECT Id, Name FROM agf__ADM_Epic__c WHERE ' + request.criteria;
            List<agf__ADM_Epic__c> epics = Database.query(query);

            EOASearchEpicResponse response = new EOASearchEpicResponse();
            response.epicIds = new List<Id>();
            response.epicNames = new List<String>();
            response.totalEpics = epics.size();

            for (agf__ADM_Epic__c epic : epics) {
                response.epicIds.add(epic.Id);
                response.epicNames.add(epic.Name);
            }

            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOASearchEpicRequest {
        @InvocableVariable(label='GA-EOA Search Criteria' required=true description='Dynamic SOQL criteria for searching Epics. Example: "Name LIKE \'%Test%\'".')
        public String criteria;
    }

    // Response wrapper for invocable method outputs
    public class EOASearchEpicResponse {
        @InvocableVariable(label='GA-EOA Epic IDs' description='List of Salesforce IDs for Epic records found.')
        public List<Id> epicIds;

        @InvocableVariable(label='GA-EOA Epic Names' description='List of human-friendly Epic names.')
        public List<String> epicNames;

        @InvocableVariable(label='GA-EOA Total Epics' description='Total number of Epic records found.')
        public Integer totalEpics;
    }
}