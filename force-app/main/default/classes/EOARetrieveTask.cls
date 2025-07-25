public with sharing class EOARetrieveTask {

    // Invocable method to retrieve Task records
    @InvocableMethod(label='GA-EOA Retrieve Task Records' description='Retrieves existing Task records based on provided IDs. Supports bulk operations.')
    public static List<EOARetrieveTaskResponse> retrieveTasks(List<EOARetrieveTaskRequest> requests) {
        List<EOARetrieveTaskResponse> responses = new List<EOARetrieveTaskResponse>();
        Set<Id> taskIds = new Set<Id>();

        // Collect IDs for retrieval
        for (EOARetrieveTaskRequest request : requests) {
            taskIds.add(request.taskId);
        }

        // Query all fields dynamically
        String query = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('agf__ADM_Task__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM agf__ADM_Task__c WHERE Id IN :taskIds';
        List<agf__ADM_Task__c> tasks = Database.query(query);
        Map<Id, agf__ADM_Task__c> tasksMap = new Map<Id, agf__ADM_Task__c>(tasks);

        // Prepare responses
        for (Id taskId : taskIds) {
            EOARetrieveTaskResponse response = new EOARetrieveTaskResponse();
            agf__ADM_Task__c task = tasksMap.get(taskId);
            if (task != null) {
                response.taskRecord = task;
                response.found = true;
            } else {
                response.taskRecord = null;
                response.found = false;
            }
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOARetrieveTaskRequest {
        @InvocableVariable(label='GA-EOA Task ID' required=true description='The Salesforce ID of the Task record to retrieve.')
        public Id taskId;
    }

    // Response wrapper for invocable method outputs
    public class EOARetrieveTaskResponse {
        @InvocableVariable(label='GA-EOA Task Record' description='The retrieved Task record with all fields.')
        public agf__ADM_Task__c taskRecord;

        @InvocableVariable(label='GA-EOA Found' description='Indicates whether the Task record was found.')
        public Boolean found;
    }
}