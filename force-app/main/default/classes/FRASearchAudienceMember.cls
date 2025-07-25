public with sharing class FRASearchAudienceMember {

    /**
     * Invocable method to search Audience Member records based on provided criteria.
     * This search is specifically intended for finding a learner within an audience. 
     * Primarily, searches should be performed using the Learner Profile ID.
     * Ensure the Learner Profile ID is obtained either through a previous learner profile search or is already known and available.
     * @param searchRequests List of search requests with criteria for filtering Audience Member records.
     * @return List of AudienceMemberSearchResponse including matched records and summaries.
     */
    @InvocableMethod(label='GA-FRA Search Audience Member' description='Searches Audience Member records, primarily by Learner Profile ID, to identify learners within a specific audience.')
    public static List<AudienceMemberSearchResponse> searchAudienceMembers(List<AudienceMemberSearchRequest> searchRequests) {
        List<AudienceMemberSearchResponse> responses = new List<AudienceMemberSearchResponse>();

        for (AudienceMemberSearchRequest request : searchRequests) {
            AudienceMemberSearchResponse response = new AudienceMemberSearchResponse();
            try {
                String query = 'SELECT Id, Audience__c, Learner_Profile__c FROM Audience_Member__c';
                if (String.isNotBlank(request.filterCriteria)) {
                    query += ' WHERE ' + request.filterCriteria;
                }

                List<Audience_Member__c> matchedMembers = Database.query(query);

                response.matchedRecords = matchedMembers;
                response.summary = 'Found ' + matchedMembers.size() + ' Audience Member record(s)' +
                                   (String.isNotBlank(request.filterCriteria) ? ' matching criteria: ' + request.filterCriteria : '');

            } catch (Exception e) {
                response.matchedRecords = new List<Audience_Member__c>();
                response.summary = 'Error during query execution: ' + e.getMessage();
                System.debug('Query error: ' + e.getMessage());
            }
            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for searching Audience Members.
     */
    public class AudienceMemberSearchRequest {
        @InvocableVariable(label='GA-FRA Filter Criteria' description='Dynamic SOQL WHERE clause to filter Audience Member records. Primarily use Learner_Profile__c for accurate results. Leave blank to retrieve all records.' required=false)
        public String filterCriteria;
    }

    /**
     * Inner class representing the response structure including matched records and summary.
     */
    public class AudienceMemberSearchResponse {
        @InvocableVariable(label='GA-FRA Matched Audience Member Records' description='List of Audience Member records that matched the criteria.')
        public List<Audience_Member__c> matchedRecords;

        @InvocableVariable(label='GA-FRA Summary' description='Text summary of search results.')
        public String summary;
    }
}