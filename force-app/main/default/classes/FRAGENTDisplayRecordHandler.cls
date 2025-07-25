/**
 * Handler class for displaying Salesforce records
 * 
 * This class provides the agent-facing interface for displaying record data
 * in a formatted way for easy reading.
 * 
 * Key Features:
 * - Displays record data in human-readable format
 * - Supports custom field selection
 * - Delegates to service layer for business logic
 */
public with sharing class FRAGENTDisplayRecordHandler {

    /**
     * Request wrapper class for record display operations
     */
    public class Request {
        @InvocableVariable(label='Object Type' description='The Salesforce object type to display (e.g., Account, Contact)' required=true)
        public String objectType;
        
        @InvocableVariable(label='Record ID' description='The ID of the record to display' required=true)
        public String recordId;
        
        @InvocableVariable(label='Fields to Display' description='Comma-separated list of field API names to include in the display')
        public String fieldsToDisplay;
    }

    /**
     * Response wrapper class for record display operations
     */
    public class Response {
        @InvocableVariable(label='Success' description='Indicates if the record display operation succeeded.')
        public Boolean success = false;
        
        @InvocableVariable(label='Message' description='A summary of the record display operation result.')
        public String message = '';
        
        @InvocableVariable(label='Record Data' description='The record data as a JSON string.')
        public String recordData = '';
        
        @InvocableVariable(label='Formatted Display' description='Human-readable formatted display of the record.')
        public String formattedDisplay = '';
    }

    /**
     * Main entry point for record display operations
     * 
     * @param requests List of requests to process
     * @return List of responses corresponding to each request
     */
    @InvocableMethod(label='FRAGENT Display Record' description='Display Salesforce record data in a formatted way for easy reading.')
    public static List<Response> displayRecord(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        if (requests == null || requests.isEmpty()) {
            Response errorResponse = new Response();
            errorResponse.success = false;
            errorResponse.message = 'No requests provided.';
            responses.add(errorResponse);
            return responses;
        }
        
        for (Request req : requests) {
            Response res = new Response();
            
            try {
                // Validate request
                if (req == null) {
                    res.message = 'Request object is null.';
                    responses.add(res);
                    continue;
                }
                
                if (String.isBlank(req.objectType)) {
                    res.message = 'Object Type is required.';
                    responses.add(res);
                    continue;
                }
                
                if (String.isBlank(req.recordId)) {
                    res.message = 'Record ID is required.';
                    responses.add(res);
                    continue;
                }
                
                // Get record data
                res.recordData = FRAGENTUtility.getRecordData(req.objectType, req.recordId);
                res.formattedDisplay = FRAGENTUtility.formatRecordForDisplay(req.objectType, req.recordId, req.fieldsToDisplay);
                res.success = true;
                res.message = 'Record data retrieved successfully.';
                
            } catch (Exception e) {
                res.message = 'Error: ' + e.getMessage();
            }
            
            responses.add(res);
        }
        
        return responses;
    }
}