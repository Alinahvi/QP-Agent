public with sharing class EOAModifyHealthComments {

    // Invocable method to modify Health Comments records
    @InvocableMethod(label='GA-EOA Modify Health Comments' description='Modifies existing Health Comments records based on provided IDs. Supports bulk updates.')
    public static List<EOAModifyHealthCommentsResponse> modifyHealthComments(List<EOAModifyHealthCommentsRequest> requests) {
        List<Health_Comments__c> commentsToUpdate = new List<Health_Comments__c>();

        // Prepare Health Comments records for update
        for (EOAModifyHealthCommentsRequest request : requests) {
            Health_Comments__c comment = new Health_Comments__c(Id = request.commentId);
            // Assign fields for modification based on actual schema
            commentsToUpdate.add(comment);
        }

        // Update records and handle potential exceptions gracefully
        Database.SaveResult[] results = Database.update(commentsToUpdate, false);

        List<EOAModifyHealthCommentsResponse> responses = new List<EOAModifyHealthCommentsResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOAModifyHealthCommentsResponse response = new EOAModifyHealthCommentsResponse();
            response.success = results[i].isSuccess();
            response.commentId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOAModifyHealthCommentsRequest {
        @InvocableVariable(label='GA-EOA Health Comments ID' required=true description='The Salesforce ID of the Health Comments record to modify.')
        public Id commentId;

        // Include additional fields as needed, each clearly labeled and documented
    }

    // Response wrapper for invocable method outputs
    public class EOAModifyHealthCommentsResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Health Comments modification was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Health Comments ID' description='Salesforce ID of the modified Health Comments record. Null if modification failed.')
        public Id commentId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Health Comments modification failed. Null if successful.')
        public String errors;
    }
}