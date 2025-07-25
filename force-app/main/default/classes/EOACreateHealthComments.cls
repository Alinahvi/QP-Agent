public with sharing class EOACreateHealthComments {

    // Invocable method to create Health Comments records
    @InvocableMethod(label='GA-EOA Create Health Comments' description='Creates new Health Comments records. Supports bulk operations. Use this method to add new Health Comments into Salesforce.')
    public static List<EOACreateHealthCommentsResponse> createHealthComments(List<EOACreateHealthCommentsRequest> requests) {
        List<Health_Comments__c> commentsToCreate = new List<Health_Comments__c>();

        // Prepare Health Comments records for insertion
        for (EOACreateHealthCommentsRequest request : requests) {
            Health_Comments__c comment = new Health_Comments__c();
            // Assign fields once they are defined clearly
            commentsToCreate.add(comment);
        }

        Database.SaveResult[] results = Database.insert(commentsToCreate, false);
        
        List<EOACreateHealthCommentsResponse> responses = new List<EOACreateHealthCommentsResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOACreateHealthCommentsResponse response = new EOACreateHealthCommentsResponse();
            response.success = results[i].isSuccess();
            response.recordId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper must have at least one defined InvocableVariable
    public class EOACreateHealthCommentsRequest {
        @InvocableVariable(label='GA-EOA Sample Field' required=true description='Sample field needed to enable InvocableMethod. Update once actual fields are defined.')
        public String sampleField;
    }

    // Response wrapper for invocable method outputs
    public class EOACreateHealthCommentsResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Health Comments creation was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Record ID' description='Salesforce ID of the created Health Comments record. Null if creation failed.')
        public Id recordId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Health Comments creation failed. Null if successful.')
        public String errors;
    }
}