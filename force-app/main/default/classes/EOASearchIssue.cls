public with sharing class EOASearchIssue {

    // Invocable method to search Issue records dynamically
    @InvocableMethod(label='GA-EOA Search Issue Records' description='Dynamically searches Issue records based on provided search criteria. Supports flexible querying.')
    public static List<EOASearchIssueResponse> searchIssues(List<EOASearchIssueRequest> requests) {
        List<EOASearchIssueResponse> responses = new List<EOASearchIssueResponse>();

        for (EOASearchIssueRequest request : requests) {
            String query = 'SELECT Id, Name FROM Issue__c WHERE ' + request.criteria;
            List<Issue__c> issues = Database.query(query);

            EOASearchIssueResponse response = new EOASearchIssueResponse();
            response.issueIds = new List<Id>();
            response.issueNames = new List<String>();
            response.totalIssues = issues.size();

            for (Issue__c issue : issues) {
                response.issueIds.add(issue.Id);
                response.issueNames.add(issue.Name);
            }

            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOASearchIssueRequest {
        @InvocableVariable(label='GA-EOA Search Criteria' required=true description='Dynamic SOQL criteria for searching Issues. Example: "Name LIKE \'%Test%\'".')
        public String criteria;
    }

    // Response wrapper for invocable method outputs
    public class EOASearchIssueResponse {
        @InvocableVariable(label='GA-EOA Issue IDs' description='List of Salesforce IDs for Issue records found.')
        public List<Id> issueIds;

        @InvocableVariable(label='GA-EOA Issue Names' description='List of human-friendly issue names.')
        public List<String> issueNames;

        @InvocableVariable(label='GA-EOA Total Issues' description='Total number of Issue records found.')
        public Integer totalIssues;
    }
}