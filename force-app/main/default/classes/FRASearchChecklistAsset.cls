public with sharing class FRASearchChecklistAsset {

    /**
     * Invocable method to dynamically search Checklist Asset records based on provided filter criteria.
     * Checklist Assets are resources associated with checklists, frequently used in training sessions or onboarding programs.
     * Use this method to find specific assets matching dynamic conditions.
     * @param searchRequests List of search requests with criteria for filtering Checklist Asset records.
     * @return List of ChecklistAssetSearchResponse including matched records and summaries.
     */
    @InvocableMethod(label='GA-FRA Search Checklist Asset' description='Searches Checklist Asset records dynamically based on provided filter criteria.')
    public static List<ChecklistAssetSearchResponse> searchChecklistAssets(List<ChecklistAssetSearchRequest> searchRequests) {
        List<ChecklistAssetSearchResponse> responses = new List<ChecklistAssetSearchResponse>();

        for (ChecklistAssetSearchRequest request : searchRequests) {
            ChecklistAssetSearchResponse response = new ChecklistAssetSearchResponse();
            try {
                String query = 'SELECT Id, Name FROM Checklist_Asset__c';
                if (String.isNotBlank(request.filterCriteria)) {
                    query += ' WHERE ' + request.filterCriteria;
                }

                List<Checklist_Asset__c> matchedAssets = Database.query(query);

                response.matchedRecords = matchedAssets;
                response.summary = 'Found ' + matchedAssets.size() + ' Checklist Asset record(s)' +
                                   (String.isNotBlank(request.filterCriteria) ? ' matching criteria: ' + request.filterCriteria : '');

            } catch (Exception e) {
                response.matchedRecords = new List<Checklist_Asset__c>();
                response.summary = 'Error during query execution: ' + e.getMessage();
                System.debug('Query error: ' + e.getMessage());
            }
            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for searching Checklist Assets.
     */
    public class ChecklistAssetSearchRequest {

        @InvocableVariable(label='GA-FRA Filter Criteria' description='Dynamic SOQL WHERE clause to filter Checklist Asset records. Leave blank to retrieve all records.' required=false)
        public String filterCriteria;
    }

    /**
     * Inner class representing the response structure including matched records and summary.
     */
    public class ChecklistAssetSearchResponse {

        @InvocableVariable(label='GA-FRA Matched Checklist Asset Records' description='List of Checklist Asset records that matched the criteria.')
        public List<Checklist_Asset__c> matchedRecords;

        @InvocableVariable(label='GA-FRA Summary' description='Text summary of search results.')
        public String summary;
    }
}