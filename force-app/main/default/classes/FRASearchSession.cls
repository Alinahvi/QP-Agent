public with sharing class FRASearchSession {

    /**
     * Invocable method for dynamically searching Session records.
     * Useful for finding sessions based on user-defined criteria.
     * @param searchRequests List containing search criteria for filtering Session records.
     * @return List of SessionSearchResponse containing matched records and summaries.
     */
    @InvocableMethod(label='GA-FRA Search Session' description='Dynamically searches Session records based on provided criteria.')
    public static List<SessionSearchResponse> searchSessions(List<SessionSearchRequest> searchRequests) {
        List<SessionSearchResponse> responses = new List<SessionSearchResponse>();

        for (SessionSearchRequest request : searchRequests) {
            SessionSearchResponse response = new SessionSearchResponse();
            try {
                String query = 'SELECT Id, Name, Start_Date__c, End_Date__c, Description__c FROM Session__c';
                if (String.isNotBlank(request.filterCriteria)) {
                    query += ' WHERE ' + request.filterCriteria;
                }

                List<Session__c> matchedSessions = Database.query(query);
                response.matchedRecords = matchedSessions;
                response.summary = 'Found ' + matchedSessions.size() + ' Session record(s)' +
                                   (String.isNotBlank(request.filterCriteria) ? ' matching criteria: ' + request.filterCriteria : '');

            } catch (Exception e) {
                response.matchedRecords = new List<Session__c>();
                response.summary = 'Error during query execution: ' + e.getMessage();
                System.debug('Query error: ' + e.getMessage());
            }

            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for searching Sessions.
     */
    public class SessionSearchRequest {

        @InvocableVariable(label='Filter Criteria' description='Dynamic SOQL WHERE clause to filter Session records. Leave blank to retrieve all records.' required=false)
        public String filterCriteria;
    }

    /**
     * Inner class representing the response structure, including matched records and summary.
     */
    public class SessionSearchResponse {

        @InvocableVariable(label='Matched Session Records' description='List of Session records that matched the criteria.')
        public List<Session__c> matchedRecords;

        @InvocableVariable(label='Summary' description='Text summary of search results.')
        public String summary;
    }
}