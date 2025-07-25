public with sharing class FRAGetAudienceChecklistDetails {

    /**
     * Invocable method to retrieve Audience Checklist records based on provided IDs.
     * @param requests List containing Audience Checklist IDs to retrieve.
     * @return List of AudienceChecklistResponse including detailed record data and summaries.
     */
    @InvocableMethod(label='GA-FRA Get Audience Checklist Details' description='Retrieves details of Audience Checklist records by IDs.')
    public static List<AudienceChecklistResponse> getAudienceChecklistDetails(List<AudienceChecklistRequest> requests) {
        List<Id> checklistIds = new List<Id>();
        for (AudienceChecklistRequest request : requests) {
            checklistIds.add(request.audienceChecklistId);
        }

        List<Audience_Checklist__c> audienceChecklists = [
            SELECT Id, Audience__c, Checklist__c
            FROM Audience_Checklist__c
            WHERE Id IN :checklistIds
        ];

        List<AudienceChecklistResponse> responses = new List<AudienceChecklistResponse>();
        for (Audience_Checklist__c checklist : audienceChecklists) {
            AudienceChecklistResponse response = new AudienceChecklistResponse();
            response.audienceChecklistRecord = checklist;
            response.summary = 'Audience Checklist ID ' + checklist.Id +
                               ' associated with Audience ID ' + checklist.Audience__c +
                               ' and Checklist ID ' + checklist.Checklist__c;

            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for retrieving Audience Checklist details.
     */
    public class AudienceChecklistRequest {
        @InvocableVariable(label='GA-FRA Audience Checklist ID' description='The Salesforce ID of the Audience Checklist record.' required=true)
        public Id audienceChecklistId;
    }

    /**
     * Inner class representing the response structure including Audience Checklist records and summaries.
     */
    public class AudienceChecklistResponse {
        @InvocableVariable(label='GA-FRA Audience Checklist Record' description='Detailed Audience Checklist record.')
        public Audience_Checklist__c audienceChecklistRecord;

        @InvocableVariable(label='GA-FRA Summary' description='Text summary of Audience Checklist details.')
        public String summary;
    }
}