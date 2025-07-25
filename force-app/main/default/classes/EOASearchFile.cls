public with sharing class EOASearchFile {

    // Invocable method to search File records dynamically
    @InvocableMethod(label='GA-EOA Search File Records' description='Dynamically searches File records based on provided search criteria. Supports flexible querying.')
    public static List<EOASearchFileResponse> searchFiles(List<EOASearchFileRequest> requests) {
        List<EOASearchFileResponse> responses = new List<EOASearchFileResponse>();

        for (EOASearchFileRequest request : requests) {
            String query = 'SELECT Id, Name FROM driveconnect__File__c WHERE ' + request.criteria + ' LIMIT 100';
            List<driveconnect__File__c> files = Database.query(query);

            for (driveconnect__File__c file : files) {
                EOASearchFileResponse response = new EOASearchFileResponse();
                response.fileId = file.Id;
                response.fileName = file.Name;
                responses.add(response);
            }
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOASearchFileRequest {
        @InvocableVariable(label='GA-EOA Search Criteria' required=true description='Dynamic SOQL criteria for searching Files. Example: "Name LIKE \'%Test%\'".')
        public String criteria;
    }

    // Response wrapper for invocable method outputs
    public class EOASearchFileResponse {
        @InvocableVariable(label='GA-EOA File ID' description='Salesforce ID of the File record found.')
        public Id fileId;

        @InvocableVariable(label='GA-EOA File Name' description='Name of the File record.')
        public String fileName;
    }
}