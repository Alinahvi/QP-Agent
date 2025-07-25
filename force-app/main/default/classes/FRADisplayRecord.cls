public with sharing class FRADisplayRecord {

    /**
     * Invocable method to retrieve and display a record based on a unique record ID.
     * Useful for showing record details directly within an agent chat context.
     * @param recordRequests List of requests containing the unique record IDs to retrieve.
     * @return List of DisplayRecordResponse with the retrieved record details.
     */
    @InvocableMethod(label='GA-FRA Display Record' description='Retrieves and displays details of a record based on its unique ID.')
    public static List<DisplayRecordResponse> displayRecord(List<DisplayRecordRequest> recordRequests) {
        List<DisplayRecordResponse> responses = new List<DisplayRecordResponse>();

        for (DisplayRecordRequest request : recordRequests) {
            DisplayRecordResponse response = new DisplayRecordResponse();

            try {
                SObject record = Database.query('SELECT FIELDS(STANDARD) FROM ' + request.objectType + ' WHERE Id = \'' + request.recordId + '\' LIMIT 1');
                response.record = record;
                response.summary = 'Successfully retrieved ' + request.objectType + ' record with ID ' + request.recordId;

            } catch (Exception e) {
                response.record = null;
                response.summary = 'Error retrieving record: ' + e.getMessage();
            }

            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing the request parameters for record retrieval.
     */
    public class DisplayRecordRequest {
        @InvocableVariable(label='Record ID' description='The unique ID of the record to retrieve.' required=true)
        public Id recordId;

        @InvocableVariable(label='Object Type' description='The Salesforce Object type of the record. Example: Account, Contact, Audience__c' required=true)
        public String objectType;
    }

    /**
     * Inner class representing the response structure including the retrieved record and a summary.
     */
    public class DisplayRecordResponse {
        @InvocableVariable(label='Retrieved Record' description='The retrieved Salesforce record.')
        public SObject record;

        @InvocableVariable(label='Summary' description='Summary of the retrieval outcome.')
        public String summary;
    }
}