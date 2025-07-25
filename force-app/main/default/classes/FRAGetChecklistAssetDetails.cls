public with sharing class FRAGetChecklistAssetDetails {

    /**
     * Invocable method to retrieve Checklist Asset records based on provided IDs.
     * Checklist Assets represent resources tied to checklists, typically used within training sessions or onboarding programs.
     * @param assetRequests List containing Checklist Asset IDs to retrieve.
     * @return List of ChecklistAssetDetailsResponse with record details and summaries.
     */
    @InvocableMethod(label='GA-FRA Get Checklist Asset Details' description='Retrieves Checklist Asset records by IDs.')
    public static List<ChecklistAssetDetailsResponse> getChecklistAssetDetails(List<ChecklistAssetDetailsRequest> assetRequests) {
        List<Id> assetIds = new List<Id>();
        for (ChecklistAssetDetailsRequest request : assetRequests) {
            assetIds.add(request.assetId);
        }

        List<Checklist_Asset__c> checklistAssets = [SELECT Id, Name FROM Checklist_Asset__c WHERE Id IN :assetIds];

        List<ChecklistAssetDetailsResponse> responses = new List<ChecklistAssetDetailsResponse>();
        for (Checklist_Asset__c asset : checklistAssets) {
            ChecklistAssetDetailsResponse response = new ChecklistAssetDetailsResponse();
            response.assetRecord = asset;
            response.summary = 'Retrieved Checklist Asset with ID ' + asset.Id + ', Name: ' + asset.Name;

            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for retrieving Checklist Asset details.
     */
    public class ChecklistAssetDetailsRequest {

        @InvocableVariable(label='GA-FRA Checklist Asset ID' description='The Salesforce ID of the Checklist Asset record.' required=true)
        public Id assetId;
    }

    /**
     * Inner class representing the response structure including Checklist Asset records and summaries.
     */
    public class ChecklistAssetDetailsResponse {

        @InvocableVariable(label='GA-FRA Checklist Asset Record' description='Detailed Checklist Asset record.')
        public Checklist_Asset__c assetRecord;

        @InvocableVariable(label='GA-FRA Summary' description='Text summary of Checklist Asset retrieval.')
        public String summary;
    }
}