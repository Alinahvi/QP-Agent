public with sharing class EOASearchHealthComments {

    // Invocable method to search Health Comments records dynamically
    @InvocableMethod(label='GA-EOA Search Health Comments' description='Dynamically searches Health Comments records based on provided search criteria. Supports flexible querying.')
    public static List<EOASearchHealthCommentsResponse> searchHealthComments(List<EOASearchHealthCommentsRequest> requests) {
        List<EOASearchHealthCommentsResponse> responses = new List<EOASearchHealthCommentsResponse>();

        for (EOASearchHealthCommentsRequest request : requests) {
            String query = 'SELECT Id, Comments__c FROM Health_Comments__c WHERE ' + request.criteria;
            List<Health_Comments__c> comments = Database.query(query);

            EOASearchHealthCommentsResponse response = new EOASearchHealthCommentsResponse();
            response.commentIds = new List<Id>();
            response.commentTexts = new List<String>();
            response.totalComments = comments.size();

            for (Health_Comments__c comment : comments) {
                response.commentIds.add(comment.Id);
                response.commentTexts.add(comment.Comments__c);
            }

            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOASearchHealthCommentsRequest {
        @InvocableVariable(label='GA-EOA Search Criteria' required=true description='Dynamic SOQL criteria for searching Health Comments. Example: "Comments__c LIKE \'%Test%\'".')
        public String criteria;
    }

    // Response wrapper for invocable method outputs
    public class EOASearchHealthCommentsResponse {
        @InvocableVariable(label='GA-EOA Health Comments IDs' description='List of Salesforce IDs for Health Comments records found.')
        public List<Id> commentIds;

        @InvocableVariable(label='GA-EOA Health Comments Texts' description='List of human-friendly Health Comments texts.')
        public List<String> commentTexts;

        @InvocableVariable(label='GA-EOA Total Comments' description='Total number of Health Comments records found.')
        public Integer totalComments;
    }
}