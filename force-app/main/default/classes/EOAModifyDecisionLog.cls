public with sharing class EOAModifyDecisionLog {

    // Invocable method to modify Decision Log records
    @InvocableMethod(label='GA-EOA Modify Decision Log Records' description='Modifies existing Decision Log records based on provided IDs. Supports bulk updates.')
    public static List<EOAModifyDecisionLogResponse> modifyDecisionLogs(List<EOAModifyDecisionLogRequest> requests) {
        List<Decision_Log__c> logsToUpdate = new List<Decision_Log__c>();

        // Prepare Decision Log records for update
        for (EOAModifyDecisionLogRequest request : requests) {
            Decision_Log__c log = new Decision_Log__c(Id = request.logId);
            // Assign fields for modification based on actual schema
            logsToUpdate.add(log);
        }

        // Update records and handle potential exceptions gracefully
        Database.SaveResult[] results = Database.update(logsToUpdate, false);

        List<EOAModifyDecisionLogResponse> responses = new List<EOAModifyDecisionLogResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOAModifyDecisionLogResponse response = new EOAModifyDecisionLogResponse();
            response.success = results[i].isSuccess();
            response.logId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOAModifyDecisionLogRequest {
        @InvocableVariable(label='GA-EOA Decision Log ID' required=true description='The Salesforce ID of the Decision Log record to modify.')
        public Id logId;

        // Include additional fields as needed, each clearly labeled and documented
    }

    // Response wrapper for invocable method outputs
    public class EOAModifyDecisionLogResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Decision Log modification was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Decision Log ID' description='Salesforce ID of the modified Decision Log record. Null if modification failed.')
        public Id logId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Decision Log modification failed. Null if successful.')
        public String errors;
    }
}