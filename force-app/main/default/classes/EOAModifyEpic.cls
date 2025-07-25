public with sharing class EOAModifyEpic {

    // Invocable method to modify Epic records
    @InvocableMethod(label='GA-EOA Modify Epic Records' description='Modifies existing Epic records based on provided IDs. Supports bulk updates.')
    public static List<EOAModifyEpicResponse> modifyEpics(List<EOAModifyEpicRequest> requests) {
        List<agf__ADM_Epic__c> epicsToUpdate = new List<agf__ADM_Epic__c>();

        // Prepare Epic records for update
        for (EOAModifyEpicRequest request : requests) {
            agf__ADM_Epic__c epic = new agf__ADM_Epic__c(Id = request.epicId);
            // Assign fields for modification based on actual schema
            epicsToUpdate.add(epic);
        }

        // Update records and handle potential exceptions gracefully
        Database.SaveResult[] results = Database.update(epicsToUpdate, false);

        List<EOAModifyEpicResponse> responses = new List<EOAModifyEpicResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOAModifyEpicResponse response = new EOAModifyEpicResponse();
            response.success = results[i].isSuccess();
            response.epicId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOAModifyEpicRequest {
        @InvocableVariable(label='GA-EOA Epic ID' required=true description='The Salesforce ID of the Epic record to modify.')
        public Id epicId;

        // Include additional fields as needed, each clearly labeled and documented
    }

    // Response wrapper for invocable method outputs
    public class EOAModifyEpicResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Epic modification was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Epic ID' description='Salesforce ID of the modified Epic record. Null if modification failed.')
        public Id epicId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Epic modification failed. Null if successful.')
        public String errors;
    }
}