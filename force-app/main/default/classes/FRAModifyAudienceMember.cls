public with sharing class FRAModifyAudienceMember {

    /**
     * Invocable method to modify Audience Member records.
     * @param audienceMemberUpdates List containing details for Audience Member updates.
     * @return List of confirmation results for each updated Audience Member record.
     */
    @InvocableMethod(label='GA-FRA Modify Audience Member' description='Modifies existing Audience Member records based on provided details.')
    public static List<AudienceMemberUpdateResult> updateAudienceMembers(List<AudienceMemberUpdateRequest> audienceMemberUpdates) {
        List<AudienceMemberUpdateResult> results = new List<AudienceMemberUpdateResult>();

        try {
            List<Audience_Member__c> membersToUpdate = new List<Audience_Member__c>();

            for (AudienceMemberUpdateRequest updateRequest : audienceMemberUpdates) {
                membersToUpdate.add(new Audience_Member__c(
                    Id = updateRequest.audienceMemberId,
                    Audience__c = updateRequest.audienceId,
                    Learner_Profile__c = updateRequest.learnerProfileId
                ));
            }

            update membersToUpdate;

            for (Audience_Member__c updatedMember : membersToUpdate) {
                AudienceMemberUpdateResult result = new AudienceMemberUpdateResult();
                result.audienceMemberId = updatedMember.Id;
                result.message = 'Audience Member record updated successfully.';
                results.add(result);
            }

            System.debug('Audience Member records updated successfully.');

        } catch (DmlException e) {
            System.debug('Failed to update Audience Member records: ' + e.getMessage());
            throw new AuraHandledException('Error updating Audience Member records: ' + e.getMessage());
        }

        return results;
    }

    /**
     * Inner class representing request parameters for modifying Audience Members.
     */
    public class AudienceMemberUpdateRequest {
        @InvocableVariable(label='GA-FRA Audience Member ID' description='The ID of the Audience Member record to update.' required=true)
        public Id audienceMemberId;

        @InvocableVariable(label='GA-FRA Audience ID' description='Updated Audience ID to associate with this member.')
        public Id audienceId;

        @InvocableVariable(label='GA-FRA Learner Profile ID' description='Updated Learner Profile ID to associate with this Audience Member.')
        public Id learnerProfileId;
    }

    /**
     * Inner class representing the result of Audience Member updates.
     */
    public class AudienceMemberUpdateResult {
        @InvocableVariable(label='GA-FRA Audience Member ID' description='The Salesforce ID of the updated Audience Member record.')
        public Id audienceMemberId;

        @InvocableVariable(label='GA-FRA Message' description='Confirmation message for the update operation.')
        public String message;
    }
}