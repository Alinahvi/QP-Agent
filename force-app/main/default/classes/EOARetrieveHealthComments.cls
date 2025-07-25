public with sharing class EOARetrieveHealthComments {

    // Invocable method to retrieve Health Comments records
    @InvocableMethod(label='GA-EOA Retrieve Health Comments' description='Retrieves existing Health Comments records based on provided IDs. Supports bulk operations.')
    public static List<EOARetrieveHealthCommentsResponse> retrieveHealthComments(List<EOARetrieveHealthCommentsRequest> requests) {
        List<EOARetrieveHealthCommentsResponse> responses = new List<EOARetrieveHealthCommentsResponse>();
        Set<Id> commentIds = new Set<Id>();

        // Collect IDs for retrieval
        for (EOARetrieveHealthCommentsRequest request : requests) {
            commentIds.add(request.commentId);
        }

        // Query Health Comments records
        Map<Id, Health_Comments__c> commentsMap = new Map<Id, Health_Comments__c>([SELECT Id, Name FROM Health_Comments__c WHERE Id IN :commentIds]);

        // Prepare responses
        for (Id commentId : commentIds) {
            EOARetrieveHealthCommentsResponse response = new EOARetrieveHealthCommentsResponse();
            Health_Comments__c comment = commentsMap.get(commentId);
            if (comment != null) {
                response.commentId = comment.Id;
                response.commentNumber = comment.Name;
                response.found = true;
            } else {
                response.commentId = commentId;
                response.found = false;
            }
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOARetrieveHealthCommentsRequest {
        @InvocableVariable(label='GA-EOA Health Comments ID' required=true description='The Salesforce ID of the Health Comments record to retrieve.')
        public Id commentId;
    }

    // Response wrapper for invocable method outputs
    public class EOARetrieveHealthCommentsResponse {
        @InvocableVariable(label='GA-EOA Health Comments ID' description='Salesforce ID of the retrieved Health Comments record.')
        public Id commentId;

        @InvocableVariable(label='GA-EOA Health Comments Number' description='Auto-generated number of the Health Comments record.')
        public String commentNumber;

        @InvocableVariable(label='GA-EOA Found' description='Indicates whether the Health Comments record was found.')
        public Boolean found;
    }
}