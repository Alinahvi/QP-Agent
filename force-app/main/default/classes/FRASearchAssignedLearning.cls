public with sharing class FRASearchAssignedLearning {

    /**
     * Invocable method to dynamically search Assigned Learning records.
     * Useful for finding assigned learnings based on specific filter criteria.
     * @param searchRequests List containing filter criteria for searching Assigned Learning records.
     * @return List of AssignedLearningSearchResponse with matched records and summaries.
     */
    @InvocableMethod(label='GA-FRA Search Assigned Learning' description='Dynamically searches Assigned Learning records based on provided criteria.')
    public static List<AssignedLearningSearchResponse> searchAssignedLearning(List<AssignedLearningSearchRequest> searchRequests) {
        List<AssignedLearningSearchResponse> responses = new List<AssignedLearningSearchResponse>();

        for (AssignedLearningSearchRequest request : searchRequests) {
            AssignedLearningSearchResponse response = new AssignedLearningSearchResponse();

            try {
                String query = 'SELECT Id, Name, Audience__c, Asset__c, Course__c, Curriculum__c, Due_Date__c, Start_Date__c, Frequency__c, Recur__c ' +
                               'FROM Assigned_Learning__c';

                if (String.isNotBlank(request.filterCriteria)) {
                    query += ' WHERE ' + request.filterCriteria;
                }

                List<Assigned_Learning__c> matchedLearnings = Database.query(query);

                response.matchedRecords = matchedLearnings;
                response.summary = 'Found ' + matchedLearnings.size() + ' Assigned Learning record(s)' +
                                   (String.isNotBlank(request.filterCriteria) ? ' matching criteria: ' + request.filterCriteria : '');

            } catch (Exception e) {
                response.matchedRecords = new List<Assigned_Learning__c>();
                response.summary = 'Error during query execution: ' + e.getMessage();
                System.debug('Query error: ' + e.getMessage());
            }

            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for Assigned Learning searches.
     */
    public class AssignedLearningSearchRequest {

        @InvocableVariable(label='Filter Criteria' description='Dynamic SOQL WHERE clause to filter Assigned Learning records. Leave blank to retrieve all records.' required=false)
        public String filterCriteria;
    }

    /**
     * Inner class representing response structure including matched records and summary.
     */
    public class AssignedLearningSearchResponse {

        @InvocableVariable(label='Matched Assigned Learning Records' description='List of Assigned Learning records matching the criteria.')
        public List<Assigned_Learning__c> matchedRecords;

        @InvocableVariable(label='Summary' description='Summary of search results.')
        public String summary;
    }
}