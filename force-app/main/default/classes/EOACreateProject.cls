public with sharing class EOACreateProject {

    // Invocable method to create Project records
    @InvocableMethod(label='GA-EOA Create Project' description='Creates new Project records. Supports bulk operations. Use this method to add new Projects into Salesforce.')
    public static List<EOACreateProjectResponse> createProjects(List<EOACreateProjectRequest> requests) {
        List<agf__PPM_Project__c> projectsToCreate = new List<agf__PPM_Project__c>();

        // Prepare Project records for insertion
        for (EOACreateProjectRequest request : requests) {
            agf__PPM_Project__c project = new agf__PPM_Project__c();
            project.Name = request.projectName;
            project.agf__Planned_Start_Date__c = request.plannedStartDate;
            project.agf__Planned_End_Date__c = request.plannedEndDate;
            // Add more fields as necessary based on schema
            projectsToCreate.add(project);
        }

        Database.SaveResult[] results = Database.insert(projectsToCreate, false);

        List<EOACreateProjectResponse> responses = new List<EOACreateProjectResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOACreateProjectResponse response = new EOACreateProjectResponse();
            response.success = results[i].isSuccess();
            response.recordId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOACreateProjectRequest {
        @InvocableVariable(label='GA-EOA Project Name' required=true description='Name of the Project.')
        public String projectName;

        @InvocableVariable(label='GA-EOA Planned Start Date' description='Planned start date for the Project.')
        public Date plannedStartDate;

        @InvocableVariable(label='GA-EOA Planned End Date' description='Planned end date for the Project.')
        public Date plannedEndDate;
    }

    // Response wrapper for invocable method outputs
    public class EOACreateProjectResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Project creation was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Record ID' description='Salesforce ID of the created Project record. Null if creation failed.')
        public Id recordId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Project creation failed. Null if successful.')
        public String errors;
    }
}