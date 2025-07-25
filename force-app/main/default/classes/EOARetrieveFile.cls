public with sharing class EOARetrieveFile {

    // Invocable method to retrieve File records
    @InvocableMethod(label='GA-EOA Retrieve File Records' description='Retrieves existing File records based on provided IDs. Supports bulk operations.')
    public static List<EOARetrieveFileResponse> retrieveFiles(List<EOARetrieveFileRequest> requests) {
        List<EOARetrieveFileResponse> responses = new List<EOARetrieveFileResponse>();
        Set<Id> fileIds = new Set<Id>();

        // Collect IDs for retrieval
        for (EOARetrieveFileRequest request : requests) {
            fileIds.add(request.fileId);
        }

        // Query File records
        Map<Id, driveconnect__File__c> filesMap = new Map<Id, driveconnect__File__c>([SELECT Id, Name FROM driveconnect__File__c WHERE Id IN :fileIds]);

        // Prepare responses
        for (Id fileId : fileIds) {
            EOARetrieveFileResponse response = new EOARetrieveFileResponse();
            driveconnect__File__c file = filesMap.get(fileId);
            if (file != null) {
                response.fileId = file.Id;
                response.fileName = file.Name;
                response.found = true;
            } else {
                response.fileId = fileId;
                response.found = false;
            }
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOARetrieveFileRequest {
        @InvocableVariable(label='GA-EOA File ID' required=true description='The Salesforce ID of the File record to retrieve.')
        public Id fileId;
    }

    // Response wrapper for invocable method outputs
    public class EOARetrieveFileResponse {
        @InvocableVariable(label='GA-EOA File ID' description='Salesforce ID of the retrieved File record.')
        public Id fileId;

        @InvocableVariable(label='GA-EOA File Name' description='Name of the retrieved File record.')
        public String fileName;

        @InvocableVariable(label='GA-EOA Found' description='Indicates whether the File record was found.')
        public Boolean found;
    }
}