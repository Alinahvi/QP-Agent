public with sharing class EOARetrieveIssue {

    // Invocable method to retrieve Issue records
    @InvocableMethod(label='GA-EOA Retrieve Issue Records' description='Retrieves existing Issue records based on provided IDs. Supports bulk operations.')
    public static List<EOARetrieveIssueResponse> retrieveIssues(List<EOARetrieveIssueRequest> requests) {
        List<EOARetrieveIssueResponse> responses = new List<EOARetrieveIssueResponse>();
        Set<Id> issueIds = new Set<Id>();

        // Collect IDs for retrieval
        for (EOARetrieveIssueRequest request : requests) {
            issueIds.add(request.issueId);
        }

        // Query Issue records
        Map<Id, Issue__c> issuesMap = new Map<Id, Issue__c>([SELECT Id, Name FROM Issue__c WHERE Id IN :issueIds]);

        // Prepare responses
        for (Id issueId : issueIds) {
            EOARetrieveIssueResponse response = new EOARetrieveIssueResponse();
            Issue__c issue = issuesMap.get(issueId);
            if (issue != null) {
                response.issueId = issue.Id;
                response.issueNumber = issue.Name;
                response.found = true;
            } else {
                response.issueId = issueId;
                response.found = false;
            }
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOARetrieveIssueRequest {
        @InvocableVariable(label='GA-EOA Issue ID' required=true description='The Salesforce ID of the Issue record to retrieve.')
        public Id issueId;
    }

    // Response wrapper for invocable method outputs
    public class EOARetrieveIssueResponse {
        @InvocableVariable(label='GA-EOA Issue ID' description='Salesforce ID of the retrieved Issue record.')
        public Id issueId;

        @InvocableVariable(label='GA-EOA Issue Number' description='Auto-generated number of the Issue record.')
        public String issueNumber;

        @InvocableVariable(label='GA-EOA Found' description='Indicates whether the Issue record was found.')
        public Boolean found;
    }
}