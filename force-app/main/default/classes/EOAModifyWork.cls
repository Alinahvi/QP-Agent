public with sharing class EOAModifyWork {

    // Invocable method to modify Work records
    @InvocableMethod(label='GA-EOA Modify Work Records' description='Modifies existing Work records based on provided IDs. Supports bulk updates.')
    public static List<EOAModifyWorkResponse> modifyWorks(List<EOAModifyWorkRequest> requests) {
        List<agf__ADM_Work__c> worksToUpdate = new List<agf__ADM_Work__c>();

        // Prepare Work records for update
        for (EOAModifyWorkRequest request : requests) {
            agf__ADM_Work__c work = new agf__ADM_Work__c(Id = request.workId);
            // Assign fields for modification based on actual schema
            worksToUpdate.add(work);
        }

        // Update records and handle potential exceptions gracefully
        Database.SaveResult[] results = Database.update(worksToUpdate, false);

        List<EOAModifyWorkResponse> responses = new List<EOAModifyWorkResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOAModifyWorkResponse response = new EOAModifyWorkResponse();
            response.success = results[i].isSuccess();
            response.workId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOAModifyWorkRequest {
        @InvocableVariable(label='GA-EOA Work ID' required=true description='The Salesforce ID of the Work record to modify.')
        public Id workId;

        // Include additional fields as needed, each clearly labeled and documented
    }

    // Response wrapper for invocable method outputs
    public class EOAModifyWorkResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Work modification was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Work ID' description='Salesforce ID of the modified Work record. Null if modification failed.')
        public Id workId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Work modification failed. Null if successful.')
        public String errors;
    }
}