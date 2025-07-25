public with sharing class EOASearchTask {

    // Invocable method to search Task records dynamically
    @InvocableMethod(label='GA-EOA Search Task Records' description='Dynamically searches Task records based on provided search criteria. Supports flexible querying.')
    public static List<EOASearchTaskResponse> searchTasks(List<EOASearchTaskRequest> requests) {
        List<EOASearchTaskResponse> responses = new List<EOASearchTaskResponse>();

        for (EOASearchTaskRequest request : requests) {
            String query = 'SELECT Id, agf__subject__c, agf__Assigned_To__c FROM agf__ADM_Task__c WHERE ' + request.criteria;
            List<agf__ADM_Task__c> tasks = Database.query(query);

            EOASearchTaskResponse response = new EOASearchTaskResponse();
            response.taskIds = new List<Id>();
            response.taskSubjects = new List<String>();
            response.assignedToIds = new List<Id>();
            response.totalTasks = tasks.size();

            for (agf__ADM_Task__c task : tasks) {
                response.taskIds.add(task.Id);
                response.taskSubjects.add(task.agf__subject__c);
                response.assignedToIds.add(task.agf__Assigned_To__c);
            }

            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOASearchTaskRequest {
        @InvocableVariable(label='GA-EOA Search Criteria' required=true description='Dynamic SOQL criteria for searching Tasks. Example: "agf__subject__c LIKE \'%Test%\'".')
        public String criteria;
    }

    // Response wrapper for invocable method outputs
    public class EOASearchTaskResponse {
        @InvocableVariable(label='GA-EOA Task IDs' description='List of Salesforce IDs for Task records found.')
        public List<Id> taskIds;

        @InvocableVariable(label='GA-EOA Task Subjects' description='List of human-friendly task subjects.')
        public List<String> taskSubjects;

        @InvocableVariable(label='GA-EOA Assigned To IDs' description='List of User IDs assigned to the tasks.')
        public List<Id> assignedToIds;

        @InvocableVariable(label='GA-EOA Total Tasks' description='Total number of Task records found.')
        public Integer totalTasks;
    }
}