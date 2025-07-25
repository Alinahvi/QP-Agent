public with sharing class EOAModifyProject {

    // Invocable method to modify Project records
    @InvocableMethod(label='GA-EOA Modify Project Records' description='Modifies existing Project records based on provided IDs. Supports bulk updates.')
    public static List<EOAModifyProjectResponse> modifyProjects(List<EOAModifyProjectRequest> requests) {
        List<agf__PPM_Project__c> projectsToUpdate = new List<agf__PPM_Project__c>();

        // Prepare Project records for update
        for (EOAModifyProjectRequest request : requests) {
            agf__PPM_Project__c project = new agf__PPM_Project__c(Id = request.projectId);
            // Assign fields for modification based on actual schema
            projectsToUpdate.add(project);
        }

        // Update records and handle potential exceptions gracefully
        Database.SaveResult[] results = Database.update(projectsToUpdate, false);

        List<EOAModifyProjectResponse> responses = new List<EOAModifyProjectResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOAModifyProjectResponse response = new EOAModifyProjectResponse();
            response.success = results[i].isSuccess();
            response.projectId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOAModifyProjectRequest {
        @InvocableVariable(label='GA-EOA Project ID' required=true description='The Salesforce ID of the Project record to modify.')
        public Id projectId;

        // Include additional fields as needed, each clearly labeled and documented
    }

    // Response wrapper for invocable method outputs
    public class EOAModifyProjectResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Project modification was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Project ID' description='Salesforce ID of the modified Project record. Null if modification failed.')
        public Id projectId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Project modification failed. Null if successful.')
        public String errors;
    }
}