public with sharing class FRACreateChecklist {

    /**
     * Invocable method to create new Checklist records.
     * @param checklistRequests List of Checklist creation requests containing details for each new record.
     * @return List of IDs of newly created Checklist records.
     */
    @InvocableMethod(label='GA-FRA Create Checklist' description='Creates new Checklist records based on provided details.')
    public static List<Id> createChecklists(List<ChecklistCreateRequest> checklistRequests) {
        List<Id> createdIds = new List<Id>();

        try {
            List<Checklist__c> checklistsToCreate = new List<Checklist__c>();

            for (ChecklistCreateRequest request : checklistRequests) {
                checklistsToCreate.add(new Checklist__c(
                    Name = request.checklistName
                ));
            }

            insert checklistsToCreate;

            for (Checklist__c checklist : checklistsToCreate) {
                createdIds.add(checklist.Id);
            }

            System.debug('Checklist records created successfully.');
            return createdIds;

        } catch (DmlException e) {
            System.debug('Failed to create Checklist records: ' + e.getMessage());
            throw new AuraHandledException('Error creating Checklist records: ' + e.getMessage());
        }
    }

    /**
     * Inner class representing request parameters for creating Checklists.
     */
    public class ChecklistCreateRequest {
        @InvocableVariable(label='GA-FRA Checklist Name' description='The name of the Checklist to be created.' required=true)
        public String checklistName;
    }
}