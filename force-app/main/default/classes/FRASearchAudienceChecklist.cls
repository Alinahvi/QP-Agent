public with sharing class FRASearchAudienceChecklist {

    /**
     * Invocable method to search Audience Checklist records based on provided criteria.
     * @param searchRequests List of search requests with criteria for filtering Audience Checklist records.
     * @return List of AudienceChecklistSearchResponse including matched records and summaries.
     */
    @InvocableMethod(label='GA-FRA Search Audience Checklist' description='Searches Audience Checklist records based on dynamic user criteria.')
    public static List<AudienceChecklistSearchResponse> searchAudienceChecklists(List<AudienceChecklistSearchRequest> searchRequests) {
        List<AudienceChecklistSearchResponse> responses = new List<AudienceChecklistSearchResponse>();

        for (AudienceChecklistSearchRequest request : searchRequests) {
            AudienceChecklistSearchResponse response = new AudienceChecklistSearchResponse();
            try {
                String query = 'SELECT Id, Audience__c, Checklist__c FROM Audience_Checklist__c';
                if (String.isNotBlank(request.filterCriteria)) {
                    query += ' WHERE ' + request.filterCriteria;
                }

                List<Audience_Checklist__c> matchedChecklists = Database.query(query);

                response.matchedRecords = matchedChecklists;
                response.summary = 'Found ' + matchedChecklists.size() + ' Audience Checklist record(s)' +
                                   (String.isNotBlank(request.filterCriteria) ? ' matching criteria: ' + request.filterCriteria : '');

            } catch (Exception e) {
                response.matchedRecords = new List<Audience_Checklist__c>();
                response.summary = 'Error during query execution: ' + e.getMessage();
                System.debug('Query error: ' + e.getMessage());
            }
            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for searching Audience Checklists.
     */
    public class AudienceChecklistSearchRequest {
        @InvocableVariable(label='GA-FRA Filter Criteria' description='Dynamic SOQL WHERE clause to filter Audience Checklist records. Leave blank to retrieve all records.' required=false)
        public String filterCriteria;
    }

    /**
     * Inner class representing the response structure including matched records and summary.
     */
    public class AudienceChecklistSearchResponse {
        @InvocableVariable(label='GA-FRA Matched Audience Checklist Records' description='List of Audience Checklist records that matched the criteria.')
        public List<Audience_Checklist__c> matchedRecords;

        @InvocableVariable(label='GA-FRA Summary' description='Text summary of search results.')
        public String summary;
    }
}