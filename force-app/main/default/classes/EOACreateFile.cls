public with sharing class EOACreateFile {

    // Invocable method to create File records
    @InvocableMethod(label='GA-EOA Create File' description='Creates new File records. Supports bulk operations. Use this method to add new Files into Salesforce.')
    public static List<EOACreateFileResponse> createFiles(List<EOACreateFileRequest> requests) {
        List<driveconnect__File__c> filesToCreate = new List<driveconnect__File__c>();

        // Prepare File records for insertion
        for (EOACreateFileRequest request : requests) {
            driveconnect__File__c file = new driveconnect__File__c();
            file.Name = request.fileName;
            // Add more fields as necessary based on schema
            filesToCreate.add(file);
        }

        Database.SaveResult[] results = Database.insert(filesToCreate, false);

        List<EOACreateFileResponse> responses = new List<EOACreateFileResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOACreateFileResponse response = new EOACreateFileResponse();
            response.success = results[i].isSuccess();
            response.recordId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOACreateFileRequest {
        @InvocableVariable(label='GA-EOA File Name' required=true description='Name of the File.')
        public String fileName;
    }

    // Response wrapper for invocable method outputs
    public class EOACreateFileResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the File creation was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Record ID' description='Salesforce ID of the created File record. Null if creation failed.')
        public Id recordId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the File creation failed. Null if successful.')
        public String errors;
    }
}