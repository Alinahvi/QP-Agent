public with sharing class ModifyAudience {

    /**
     * Invocable method to modify existing Audience records.
     * @param audienceUpdates A list of audience update requests containing the details for each update.
     * @return A list confirming successful updates.
     */
    @InvocableMethod(label='Update Audience' description='Updates Audience records based on provided request details.')
    public static List<AudienceUpdateResult> updateAudience(List<AudienceUpdateRequest> audienceUpdates) {
        List<AudienceUpdateResult> results = new List<AudienceUpdateResult>();

        try {
            List<Audience__c> audiencesToUpdate = new List<Audience__c>();

            for (AudienceUpdateRequest updateRequest : audienceUpdates) {
                audiencesToUpdate.add(new Audience__c(
                    Id = updateRequest.audienceId,
                    Name = updateRequest.audienceName,
                    Filter_Logic__c = updateRequest.filterLogic,
                    Rendering__c = updateRequest.rendering,
                    Use_Custom_Filter__c = updateRequest.useCustomFilter,
                    externalid__c = updateRequest.externalId
                ));
            }

            update audiencesToUpdate;

            for (Audience__c updatedAudience : audiencesToUpdate) {
                AudienceUpdateResult result = new AudienceUpdateResult();
                result.audienceId = updatedAudience.Id;
                result.message = 'Audience record updated successfully.';
                results.add(result);
            }

            System.debug('Audience records updated successfully.');

        } catch (DmlException e) {
            System.debug('Failed to update Audience records: ' + e.getMessage());
            throw new AuraHandledException('Error updating Audience records: ' + e.getMessage());
        }

        return results;
    }

    /**
     * Inner class representing request parameters for audience updates.
     */
    public class AudienceUpdateRequest {
        @InvocableVariable(label='Audience ID' description='The Salesforce ID of the Audience record to update.' required=true)
        public Id audienceId;

        @InvocableVariable(label='Audience Name' description='The updated name for the Audience.')
        public String audienceName;

        @InvocableVariable(label='Filter Logic' description='The updated filter logic used for audience members.')
        public String filterLogic;

        @InvocableVariable(label='Rendering' description='Updated setting indicating if audience rendering is enabled.')
        public Boolean rendering;

        @InvocableVariable(label='Use Custom Filter' description='Updated flag indicating whether a custom filter logic is used.')
        public Boolean useCustomFilter;

        @InvocableVariable(label='External ID' description='The updated external ID reference for the Audience.')
        public String externalId;
    }

    /**
     * Inner class representing the result of audience updates.
     */
    public class AudienceUpdateResult {
        @InvocableVariable(label='Audience ID' description='The Salesforce ID of the updated Audience record.')
        public Id audienceId;

        @InvocableVariable(label='Message' description='Confirmation message of the update operation.')
        public String message;
    }
}