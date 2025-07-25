public with sharing class EOASearchWork {

    // Invocable method to search Work records dynamically
    @InvocableMethod(label='GA-EOA Search Work Records' description='Dynamically searches Work records based on provided search criteria. Supports flexible querying.')
    public static List<EOASearchWorkResponse> searchWorks(List<EOASearchWorkRequest> requests) {
        List<EOASearchWorkResponse> responses = new List<EOASearchWorkResponse>();

        for (EOASearchWorkRequest request : requests) {
            String query = 'SELECT Id, Name FROM agf__ADM_Work__c WHERE ' + request.criteria;
            List<agf__ADM_Work__c> works = Database.query(query);

            EOASearchWorkResponse response = new EOASearchWorkResponse();
            response.workIds = new List<Id>();
            response.workNames = new List<String>();
            response.totalWorks = works.size();

            for (agf__ADM_Work__c work : works) {
                response.workIds.add(work.Id);
                response.workNames.add(work.Name);
            }

            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOASearchWorkRequest {
        @InvocableVariable(label='GA-EOA Search Criteria' required=true description='Dynamic SOQL criteria for searching Work items. Example: "Name LIKE \'%Test%\'".')
        public String criteria;
    }

    // Response wrapper for invocable method outputs
    public class EOASearchWorkResponse {
        @InvocableVariable(label='GA-EOA Work IDs' description='List of Salesforce IDs for Work records found.')
        public List<Id> workIds;

        @InvocableVariable(label='GA-EOA Work Names' description='Human-friendly names of the Work records.')
        public List<String> workNames;

        @InvocableVariable(label='GA-EOA Total Works' description='Total number of Work records found.')
        public Integer totalWorks;
    }
}