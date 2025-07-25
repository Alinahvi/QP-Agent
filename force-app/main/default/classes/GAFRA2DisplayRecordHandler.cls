public with sharing class GAFRA2DisplayRecordHandler {

    public class Request {
        @InvocableVariable(label='Action Type' description='Specify the action: Retrieve' required=true)
        public String actionType;
        @InvocableVariable(label='Record ID' description='The unique ID of the record to retrieve.' required=true)
        public String recordId;
        @InvocableVariable(label='Object Type' description='The Salesforce Object type of the record. Example: Account, Contact, Audience__c' required=true)
        public String objectType;
    }

    public class Response {
        @InvocableVariable(label='Success' description='Indicates if the operation succeeded.')
        public Boolean success = false;
        @InvocableVariable(label='Message' description='A summary of the operation result.')
        public String message = '';
        @InvocableVariable(label='Record' description='The retrieved Salesforce record.')
        public SObject record;
    }

    @InvocableMethod(label='GA-FRA2 Display Record' description='Retrieves and displays details of a record based on its unique ID.')
    public static List<Response> displayRecord(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();
            
            try {
                if (req.actionType == 'Retrieve') {
                    handleRetrieve(req, res);
                } else {
                    res.message = 'Error: Invalid action type. Must be Retrieve.';
                }
            } catch (Exception e) {
                res.message = 'Error: ' + e.getMessage();
            }
            
            responses.add(res);
        }
        
        return responses;
    }

    private static void handleRetrieve(Request req, Response res) {
        try {
            SObject record = Database.query('SELECT FIELDS(STANDARD) FROM ' + req.objectType + ' WHERE Id = \'' + req.recordId + '\' LIMIT 1');
            res.record = record;
            res.success = true;
            res.message = 'Successfully retrieved ' + req.objectType + ' record with ID ' + req.recordId;

        } catch (Exception e) {
            res.record = null;
            res.message = 'Error retrieving record: ' + e.getMessage();
        }
    }
}