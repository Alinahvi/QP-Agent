public with sharing class FRACreateAudienceMember {

    /**
     * Invocable method to create Audience Member records.
     * @param audienceMemberRequests List containing details for new Audience Member records.
     * @return List of IDs of newly created Audience Member records.
     */
    @InvocableMethod(label='GA-FRA Create Audience Member' description='Creates new Audience Member records based on provided details.')
    public static List<Id> createAudienceMembers(List<AudienceMemberCreateRequest> audienceMemberRequests) {
        List<Id> createdIds = new List<Id>();

        try {
            List<Audience_Member__c> membersToCreate = new List<Audience_Member__c>();

            for (AudienceMemberCreateRequest request : audienceMemberRequests) {
                membersToCreate.add(new Audience_Member__c(
                    Audience__c = request.audienceId,
                    Learner_Profile__c = request.learnerProfileId
                ));
            }

            insert membersToCreate;

            for (Audience_Member__c member : membersToCreate) {
                createdIds.add(member.Id);
            }

            System.debug('Audience Member records created successfully.');
            return createdIds;

        } catch (DmlException e) {
            System.debug('Failed to create Audience Member records: ' + e.getMessage());
            throw new AuraHandledException('Error creating Audience Member records: ' + e.getMessage());
        }
    }

    /**
     * Inner class representing request parameters for creating Audience Members.
     */
    public class AudienceMemberCreateRequest {
        @InvocableVariable(label='GA-FRA Audience ID' description='The ID of the Audience to which the member will be added.' required=true)
        public Id audienceId;

        @InvocableVariable(label='GA-FRA Learner Profile ID' description='The ID of the Learner Profile to associate with the Audience.' required=true)
        public Id learnerProfileId;
    }
}