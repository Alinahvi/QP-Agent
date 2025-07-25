public with sharing class FRAModifyChecklist {

    /**
     * Invocable method to modify Checklist records.
     * @param checklistUpdates List containing details for Checklist updates.
     * @return List of results confirming successful updates.
     */
    @InvocableMethod(label='GA-FRA Modify Checklist' description='Updates existing Checklist records based on provided details.')
    public static List<ChecklistUpdateResult> updateChecklists(List<ChecklistUpdateRequest> checklistUpdates) {
        List<ChecklistUpdateResult> results = new List<ChecklistUpdateResult>();

        try {
            List<Checklist__c> checklistsToUpdate = new List<Checklist__c>();

            for (ChecklistUpdateRequest updateRequest : checklistUpdates) {
                checklistsToUpdate.add(new Checklist__c(
                    Id = updateRequest.checklistId,
                    Name = updateRequest.checklistName
                ));
            }

            update checklistsToUpdate;

            for (Checklist__c updatedChecklist : checklistsToUpdate) {
                ChecklistUpdateResult result = new ChecklistUpdateResult();
                result.checklistId = updatedChecklist.Id;
                result.message = 'Checklist record updated successfully.';
                results.add(result);
            }

            System.debug('Checklist records updated successfully.');

        } catch (DmlException e) {
            System.debug('Failed to update Checklist records: ' + e.getMessage());
            throw new AuraHandledException('Error updating Checklist records: ' + e.getMessage());
        }

        return results;
    }

    /**
     * Inner class representing request parameters for modifying Checklists.
     */
    public class ChecklistUpdateRequest {
        @InvocableVariable(label='GA-FRA Checklist ID' description='The Salesforce ID of the Checklist record to update.' required=true)
        public Id checklistId;

        @InvocableVariable(label='GA-FRA Checklist Name' description='Updated name for the Checklist.')
        public String checklistName;
    }

    /**
     * Inner class representing the result of Checklist updates.
     */
    public class ChecklistUpdateResult {
        @InvocableVariable(label='GA-FRA Checklist ID' description='The Salesforce ID of the updated Checklist record.')
        public Id checklistId;

        @InvocableVariable(label='GA-FRA Message' description='Confirmation message for the update operation.')
        public String message;
    }
}