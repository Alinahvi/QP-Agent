public with sharing class FRAModifyAudienceChecklist {

    /**
     * Invocable method to modify Audience Checklist records.
     * @param audienceChecklistUpdates List containing details for Audience Checklist updates.
     * @return List of results confirming successful updates.
     */
    @InvocableMethod(label='GA-FRA Modify Audience Checklist' description='Updates existing Audience Checklist records based on provided details.')
    public static List<AudienceChecklistUpdateResult> updateAudienceChecklists(List<AudienceChecklistUpdateRequest> audienceChecklistUpdates) {
        List<AudienceChecklistUpdateResult> results = new List<AudienceChecklistUpdateResult>();

        try {
            List<Audience_Checklist__c> checklistsToUpdate = new List<Audience_Checklist__c>();

            for (AudienceChecklistUpdateRequest updateRequest : audienceChecklistUpdates) {
                checklistsToUpdate.add(new Audience_Checklist__c(
                    Id = updateRequest.audienceChecklistId,
                    Audience__c = updateRequest.audienceId,
                    Checklist__c = updateRequest.checklistId
                ));
            }

            update checklistsToUpdate;

            for (Audience_Checklist__c updatedChecklist : checklistsToUpdate) {
                AudienceChecklistUpdateResult result = new AudienceChecklistUpdateResult();
                result.audienceChecklistId = updatedChecklist.Id;
                result.message = 'Audience Checklist record updated successfully.';
                results.add(result);
            }

            System.debug('Audience Checklist records updated successfully.');

        } catch (DmlException e) {
            System.debug('Failed to update Audience Checklist records: ' + e.getMessage());
            throw new AuraHandledException('Error updating Audience Checklist records: ' + e.getMessage());
        }

        return results;
    }

    /**
     * Inner class representing request parameters for modifying Audience Checklists.
     */
    public class AudienceChecklistUpdateRequest {
        @InvocableVariable(label='GA-FRA Audience Checklist ID' description='The Salesforce ID of the Audience Checklist record to update.' required=true)
        public Id audienceChecklistId;

        @InvocableVariable(label='GA-FRA Audience ID' description='Updated Audience ID to associate with the checklist.')
        public Id audienceId;

        @InvocableVariable(label='GA-FRA Checklist ID' description='Updated Checklist ID to associate with the Audience.')
        public Id checklistId;
    }

    /**
     * Inner class representing the result of Audience Checklist updates.
     */
    public class AudienceChecklistUpdateResult {
        @InvocableVariable(label='GA-FRA Audience Checklist ID' description='The Salesforce ID of the updated Audience Checklist record.')
        public Id audienceChecklistId;

        @InvocableVariable(label='GA-FRA Message' description='Confirmation message for the update operation.')
        public String message;
    }
}