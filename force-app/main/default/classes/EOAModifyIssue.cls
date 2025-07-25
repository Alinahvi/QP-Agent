public with sharing class EOAModifyIssue {

    // Invocable method to modify Issue records
    @InvocableMethod(label='GA-EOA Modify Issue Records' description='Modifies existing Issue records based on provided IDs. Supports bulk updates.')
    public static List<EOAModifyIssueResponse> modifyIssues(List<EOAModifyIssueRequest> requests) {
        List<Issue__c> issuesToUpdate = new List<Issue__c>();

        // Prepare Issue records for update
        for (EOAModifyIssueRequest request : requests) {
            Issue__c issue = new Issue__c(Id = request.issueId);
            // Add more fields to update as necessary based on actual schema
            issuesToUpdate.add(issue);
        }

        // Update records and handle potential exceptions gracefully
        Database.SaveResult[] results = Database.update(issuesToUpdate, false);

        List<EOAModifyIssueResponse> responses = new List<EOAModifyIssueResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOAModifyIssueResponse response = new EOAModifyIssueResponse();
            response.success = results[i].isSuccess();
            response.issueId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOAModifyIssueRequest {
        @InvocableVariable(label='GA-EOA Issue ID' required=true description='The Salesforce ID of the Issue record to modify.')
        public Id issueId;

        // Include additional fields as needed, each clearly labeled and documented
    }

    // Response wrapper for invocable method outputs
    public class EOAModifyIssueResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Issue modification was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Issue ID' description='Salesforce ID of the modified Issue record. Null if modification failed.')
        public Id issueId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Issue modification failed. Null if successful.')
        public String errors;
    }
}