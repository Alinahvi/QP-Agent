public with sharing class EOARetrieveProject {

    // Invocable method to retrieve Project records
    @InvocableMethod(label='GA-EOA Retrieve Project Records' description='Retrieves existing Project records based on provided IDs. Supports bulk operations.')
    public static List<EOARetrieveProjectResponse> retrieveProjects(List<EOARetrieveProjectRequest> requests) {
        List<EOARetrieveProjectResponse> responses = new List<EOARetrieveProjectResponse>();
        Set<Id> projectIds = new Set<Id>();

        // Collect IDs for retrieval
        for (EOARetrieveProjectRequest request : requests) {
            projectIds.add(request.projectId);
        }

        // Query Project records
        Map<Id, agf__PPM_Project__c> projectsMap = new Map<Id, agf__PPM_Project__c>([SELECT Id, Name FROM agf__PPM_Project__c WHERE Id IN :projectIds]);

        // Prepare responses
        for (Id projectId : projectIds) {
            EOARetrieveProjectResponse response = new EOARetrieveProjectResponse();
            agf__PPM_Project__c project = projectsMap.get(projectId);
            if (project != null) {
                response.projectId = project.Id;
                response.projectName = project.Name;
                response.found = true;
            } else {
                response.projectId = projectId;
                response.found = false;
            }
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOARetrieveProjectRequest {
        @InvocableVariable(label='GA-EOA Project ID' required=true description='The Salesforce ID of the Project record to retrieve.')
        public Id projectId;
    }

    // Response wrapper for invocable method outputs
    public class EOARetrieveProjectResponse {
        @InvocableVariable(label='GA-EOA Project ID' description='Salesforce ID of the retrieved Project record.')
        public Id projectId;

        @InvocableVariable(label='GA-EOA Project Name' description='Name of the retrieved Project record.')
        public String projectName;

        @InvocableVariable(label='GA-EOA Found' description='Indicates whether the Project record was found.')
        public Boolean found;
    }
}