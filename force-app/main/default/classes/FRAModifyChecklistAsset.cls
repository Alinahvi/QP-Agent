public with sharing class FRAModifyChecklistAsset {

    /**
     * Invocable method to modify existing Checklist Asset records.
     * Checklist Assets represent resources associated with specific checklists, often used in training sessions or onboarding processes.
     * @param checklistAssetUpdates List containing details for Checklist Asset updates.
     * @return List of confirmation results for each updated Checklist Asset record.
     */
    @InvocableMethod(label='GA-FRA Modify Checklist Asset' description='Updates existing Checklist Asset records based on provided details.')
    public static List<ChecklistAssetUpdateResult> updateChecklistAssets(List<ChecklistAssetUpdateRequest> checklistAssetUpdates) {
        List<ChecklistAssetUpdateResult> results = new List<ChecklistAssetUpdateResult>();

        List<Checklist_Asset__c> assetsToUpdate = new List<Checklist_Asset__c>();

        for (ChecklistAssetUpdateRequest request : checklistAssetUpdates) {
            assetsToUpdate.add(new Checklist_Asset__c(
                Id = request.assetId,
                Name = request.assetName
            ));
        }

        update assetsToUpdate;

        for (Checklist_Asset__c asset : assetsToUpdate) {
            ChecklistAssetUpdateResult result = new ChecklistAssetUpdateResult();
            result.assetId = asset.Id;
            result.message = 'Checklist Asset record updated successfully.';
            results.add(result);
        }

        return results;
    }

    /**
     * Inner class representing request parameters for modifying Checklist Assets.
     */
    public class ChecklistAssetUpdateRequest {

        @InvocableVariable(label='GA-FRA Checklist Asset ID' description='The ID of the Checklist Asset record to update.' required=true)
        public Id assetId;

        @InvocableVariable(label='GA-FRA Asset Name' description='Updated name for the Checklist Asset.')
        public String assetName;
    }

    /**
     * Inner class representing the result of Checklist Asset updates.
     */
    public class ChecklistAssetUpdateResult {

        @InvocableVariable(label='GA-FRA Checklist Asset ID' description='The Salesforce ID of the updated Checklist Asset record.')
        public Id assetId;

        @InvocableVariable(label='GA-FRA Message' description='Confirmation message for the update operation.')
        public String message;
    }
}