public with sharing class EOAModifyFile {

    // Invocable method to modify File records
    @InvocableMethod(label='GA-EOA Modify File Records' description='Modifies existing File records based on provided IDs. Supports bulk updates.')
    public static List<EOAModifyFileResponse> modifyFiles(List<EOAModifyFileRequest> requests) {
        List<driveconnect__File__c> filesToUpdate = new List<driveconnect__File__c>();

        // Prepare File records for update
        for (EOAModifyFileRequest request : requests) {
            driveconnect__File__c file = new driveconnect__File__c(Id = request.fileId);
            // Assign fields for modification based on actual schema
            filesToUpdate.add(file);
        }

        // Update records and handle potential exceptions gracefully
        Database.SaveResult[] results = Database.update(filesToUpdate, false);

        List<EOAModifyFileResponse> responses = new List<EOAModifyFileResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOAModifyFileResponse response = new EOAModifyFileResponse();
            response.success = results[i].isSuccess();
            response.fileId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOAModifyFileRequest {
        @InvocableVariable(label='GA-EOA File ID' required=true description='The Salesforce ID of the File record to modify.')
        public Id fileId;

        // Include additional fields as needed, each clearly labeled and documented
    }

    // Response wrapper for invocable method outputs
    public class EOAModifyFileResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the File modification was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA File ID' description='Salesforce ID of the modified File record. Null if modification failed.')
        public Id fileId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the File modification failed. Null if successful.')
        public String errors;
    }
}