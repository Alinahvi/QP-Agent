public with sharing class EOACreateIssue {

    // Invocable method to create Issue records
    @InvocableMethod(label='GA-EOA Create Issue Records' description='Creates new Issue records. Supports bulk operations. Use this method to add new Issues into Salesforce.')
    public static List<EOACreateIssueResponse> createIssues(List<EOACreateIssueRequest> requests) {
        List<Issue__c> issuesToCreate = new List<Issue__c>();

        // Prepare Issue records for insertion
        for (EOACreateIssueRequest request : requests) {
            Issue__c issue = new Issue__c();
            // Issue Number is auto-generated and not writable; no other fields provided explicitly in metadata
            // Add more fields here as necessary based on the actual schema if available
            issuesToCreate.add(issue);
        }

        // Insert records and handle potential exceptions gracefully
        Database.SaveResult[] results = Database.insert(issuesToCreate, false);
        
        List<EOACreateIssueResponse> responses = new List<EOACreateIssueResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOACreateIssueResponse response = new EOACreateIssueResponse();
            response.success = results[i].isSuccess();
            response.recordId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOACreateIssueRequest {
        @InvocableVariable(label='GA-EOA Issue Name' required=true description='The name or title of the Issue.')
        public String name;

        // Include additional fields as needed, each clearly labeled and documented
    }

    // Response wrapper for invocable method outputs
    public class EOACreateIssueResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Issue creation was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Record ID' description='Salesforce ID of the created Issue record. Null if creation failed.')
        public Id recordId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Issue creation failed. Null if successful.')
        public String errors;
    }
}