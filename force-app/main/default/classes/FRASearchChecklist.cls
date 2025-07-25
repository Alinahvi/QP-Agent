public with sharing class FRASearchChecklist {

    /**
     * Invocable method to search Checklist records based on provided criteria.
     * @param searchRequests List of search requests with criteria for filtering Checklist records.
     * @return List of ChecklistSearchResponse including matched records and summaries.
     */
    @InvocableMethod(label='GA-FRA Search Checklist' description='Searches Checklist records based on dynamic user criteria.')
    public static List<ChecklistSearchResponse> searchChecklists(List<ChecklistSearchRequest> searchRequests) {
        List<ChecklistSearchResponse> responses = new List<ChecklistSearchResponse>();

        for (ChecklistSearchRequest request : searchRequests) {
            ChecklistSearchResponse response = new ChecklistSearchResponse();
            try {
                String query = 'SELECT Id, Name FROM Checklist__c';
                if (String.isNotBlank(request.filterCriteria)) {
                    query += ' WHERE ' + request.filterCriteria;
                }

                List<Checklist__c> matchedChecklists = Database.query(query);

                response.matchedRecords = matchedChecklists;
                response.summary = 'Found ' + matchedChecklists.size() + ' Checklist record(s)' +
                                   (String.isNotBlank(request.filterCriteria) ? ' matching criteria: ' + request.filterCriteria : '');

            } catch (Exception e) {
                response.matchedRecords = new List<Checklist__c>();
                response.summary = 'Error during query execution: ' + e.getMessage();
                System.debug('Query error: ' + e.getMessage());
            }
            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for searching Checklists.
     */
    public class ChecklistSearchRequest {
        @InvocableVariable(label='GA-FRA Filter Criteria' description='Dynamic SOQL WHERE clause to filter Checklist records. Leave blank to retrieve all records.' required=false)
        public String filterCriteria;
    }

    /**
     * Inner class representing the response structure including matched records and summary.
     */
    public class ChecklistSearchResponse {
        @InvocableVariable(label='GA-FRA Matched Checklist Records' description='List of Checklist records that matched the criteria.')
        public List<Checklist__c> matchedRecords;

        @InvocableVariable(label='GA-FRA Summary' description='Text summary of search results.')
        public String summary;
    }
}