public with sharing class FRACreateAudienceChecklist {

    /**
     * Invocable method to create new Audience Checklist records.
     * @param audienceChecklistRequests List of Audience Checklist creation requests containing details for each new record.
     * @return List of IDs of newly created Audience Checklist records.
     */
    @InvocableMethod(label='GA-FRA Create Audience Checklist' description='Creates Audience Checklist records based on provided details.')
    public static List<Id> createAudienceChecklists(List<AudienceChecklistCreateRequest> audienceChecklistRequests) {
        List<Id> createdIds = new List<Id>();

        List<Audience_Checklist__c> checklistsToCreate = new List<Audience_Checklist__c>();

        for (AudienceChecklistCreateRequest request : audienceChecklistRequests) {
            checklistsToCreate.add(new Audience_Checklist__c(
                Audience__c = request.audienceId,
                Checklist__c = request.checklistId
            ));
        }

        try {
            insert checklistsToCreate;

            for (Audience_Checklist__c checklist : checklistsToCreate) {
                createdIds.add(checklist.Id);
            }

            System.debug('Audience Checklist records created successfully.');

        } catch (DmlException e) {
            System.debug('Failed to create Audience Checklist records: ' + e.getMessage());
            // Optionally handle differently or log this error instead of throwing
        }

        return createdIds;
    }

    /**
     * Inner class representing request parameters for creating Audience Checklists.
     */
    public class AudienceChecklistCreateRequest {
        @InvocableVariable(label='GA-FRA Audience ID' description='The ID of the Audience to associate with this checklist.' required=true)
        public Id audienceId;

        @InvocableVariable(label='GA-FRA Checklist ID' description='The ID of the Checklist to associate with the Audience.' required=true)
        public Id checklistId;
    }
}