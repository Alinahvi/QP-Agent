public with sharing class EOASearchProject {

    // Invocable method to search Project records dynamically
    @InvocableMethod(label='GA-EOA Search Project Records' description='Dynamically searches Project records based on provided search criteria. Supports flexible querying.')
    public static List<EOASearchProjectResponse> searchProjects(List<EOASearchProjectRequest> requests) {
        List<EOASearchProjectResponse> responses = new List<EOASearchProjectResponse>();

        for (EOASearchProjectRequest request : requests) {
            String correctedCriteria = request.criteria.replace('Program__c', 'agf__Program__c');
            String query = 'SELECT Id, Name, agf__Program__c FROM agf__PPM_Project__c WHERE ' + correctedCriteria;
            List<agf__PPM_Project__c> projects = Database.query(query);

            EOASearchProjectResponse response = new EOASearchProjectResponse();
            response.projectIds = new List<Id>();
            response.projectNames = new List<String>();
            response.programIds = new List<Id>();
            response.totalProjects = projects.size();

            for (agf__PPM_Project__c project : projects) {
                response.projectIds.add(project.Id);
                response.projectNames.add(project.Name);
                response.programIds.add(project.agf__Program__c);
            }

            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOASearchProjectRequest {
        @InvocableVariable(label='GA-EOA Search Criteria' required=true description='Dynamic SOQL criteria for searching Projects. Example: "Name LIKE \'%Test%\'".')
        public String criteria;
    }

    // Response wrapper for invocable method outputs
    public class EOASearchProjectResponse {
        @InvocableVariable(label='GA-EOA Project IDs' description='List of Salesforce IDs for Project records found.')
        public List<Id> projectIds;

        @InvocableVariable(label='GA-EOA Project Names' description='List of human-friendly Project names.')
        public List<String> projectNames;

        @InvocableVariable(label='GA-EOA Program IDs' description='List of associated Program IDs.')
        public List<Id> programIds;

        @InvocableVariable(label='GA-EOA Total Projects' description='Total number of Project records found.')
        public Integer totalProjects;
    }
}