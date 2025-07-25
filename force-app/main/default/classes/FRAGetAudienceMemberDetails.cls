public with sharing class FRAGetAudienceMemberDetails {

    /**
     * Invocable method to retrieve Audience Member records based on provided IDs, including summary.
     * @param requests List containing Audience Member IDs to retrieve.
     * @return List of AudienceMemberDetailsResponse with record details and summary.
     */
    @InvocableMethod(label='GA-FRA Get Audience Member Details' description='Retrieves Audience Member details by IDs with summaries.')
    public static List<AudienceMemberDetailsResponse> getAudienceMemberDetails(List<AudienceMemberRequest> requests) {
        List<Id> audienceMemberIds = new List<Id>();
        for (AudienceMemberRequest request : requests) {
            audienceMemberIds.add(request.audienceMemberId);
        }

        List<Audience_Member__c> audienceMembers = [SELECT Id, Audience__c, Learner_Profile__c
                                                    FROM Audience_Member__c
                                                    WHERE Id IN :audienceMemberIds];

        List<AudienceMemberDetailsResponse> responses = new List<AudienceMemberDetailsResponse>();
        for (Audience_Member__c member : audienceMembers) {
            AudienceMemberDetailsResponse response = new AudienceMemberDetailsResponse();
            response.audienceMemberRecord = member;
            response.summary = 'Audience Member with ID ' + member.Id +
                               ' is associated with Audience ID ' + member.Audience__c +
                               ' and Learner Profile ID ' + member.Learner_Profile__c + '.';

            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for retrieving Audience Member details.
     */
    public class AudienceMemberRequest {
        @InvocableVariable(label='GA-FRA Audience Member ID' description='The Salesforce ID of the Audience Member record.' required=true)
        public Id audienceMemberId;
    }

    /**
     * Inner class representing the response structure with details and summary.
     */
    public class AudienceMemberDetailsResponse {
        @InvocableVariable(label='GA-FRA Audience Member Record' description='Detailed Audience Member record.')
        public Audience_Member__c audienceMemberRecord;

        @InvocableVariable(label='GA-FRA Summary' description='Text summary of Audience Member details.')
        public String summary;
    }
}