public with sharing class FRASearchAudience {

    /**
     * Invocable method to search Audience records based on provided criteria.
     * @param searchRequests List of search requests with criteria for filtering Audience records.
     * @return List of AudienceSearchResponse including matched records and summary.
     */
    @InvocableMethod(label='GA-FRA Search Audience' description='Searches Audience records based on dynamic user criteria.')
    public static List<AudienceSearchResponse> searchAudiences(List<AudienceSearchRequest> searchRequests) {
        List<AudienceSearchResponse> responses = new List<AudienceSearchResponse>();

        for (AudienceSearchRequest request : searchRequests) {
            AudienceSearchResponse response = new AudienceSearchResponse();
            try {
                String query = 'SELECT Id, OwnerId, Name, RecordTypeId, Filter_Logic__c, Rendering__c, Use_Custom_Filter__c, externalid__c FROM Audience__c';
                if (String.isNotBlank(request.filterCriteria)) {
                    query += ' WHERE ' + request.filterCriteria;
                }
                List<Audience__c> matchedAudiences = Database.query(query);

                response.matchedRecords = matchedAudiences;
                response.summary = 'Found ' + matchedAudiences.size() + ' Audience record(s)' + (String.isNotBlank(request.filterCriteria) ? ' matching criteria: ' + request.filterCriteria : '');

            } catch (Exception e) {
                response.matchedRecords = new List<Audience__c>();
                response.summary = 'Error during query execution: ' + e.getMessage();
                System.debug('Query error: ' + e.getMessage());
            }
            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for searching Audiences.
     */
    public class AudienceSearchRequest {
        @InvocableVariable(label='GA-FRA Filter Criteria' description='Dynamic SOQL WHERE clause to filter Audience records. Leave blank to retrieve all records.' required=false)
        public String filterCriteria;
    }

    /**
     * Inner class representing the response structure including matched records and summary.
     */
    public class AudienceSearchResponse {
        @InvocableVariable(label='GA-FRA Matched Audience Records' description='List of Audience records that matched the criteria.')
        public List<Audience__c> matchedRecords;

        @InvocableVariable(label='GA-FRA Summary' description='Text summary of search results.')
        public String summary;
    }
}