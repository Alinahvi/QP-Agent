public with sharing class FRACreateChecklistAsset {

    /**
     * Invocable method to create Checklist Asset records.
     * @param checklistAssetRequests List of Checklist Asset creation requests containing details for each new record.
     * @return List of IDs of newly created Checklist Asset records.
     */
    @InvocableMethod(label='GA-FRA Create Checklist Asset' description='Creates new Checklist Asset records based on provided details.')
    public static List<Id> createChecklistAssets(List<ChecklistAssetCreateRequest> checklistAssetRequests) {
        List<Id> createdIds = new List<Id>();

        try {
            List<Checklist_Asset__c> assetsToCreate = new List<Checklist_Asset__c>();

            for (ChecklistAssetCreateRequest request : checklistAssetRequests) {
                assetsToCreate.add(new Checklist_Asset__c(
                    Name = request.assetName
                ));
            }

            insert assetsToCreate;

            for (Checklist_Asset__c asset : assetsToCreate) {
                createdIds.add(asset.Id);
            }

            System.debug('Checklist Asset records created successfully.');
            return createdIds;

        } catch (DmlException e) {
            System.debug('Failed to create Checklist Asset records: ' + e.getMessage());
            throw new AuraHandledException('Error creating Checklist Asset records: ' + e.getMessage());
        }
    }

    /**
     * Inner class representing request parameters for creating Checklist Assets.
     */
    public class ChecklistAssetCreateRequest {
        @InvocableVariable(label='GA-FRA Asset Name' description='The name of the Checklist Asset to be created.' required=true)
        public String assetName;
    }
}