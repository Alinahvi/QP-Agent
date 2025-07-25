public with sharing class EOACreateTask {

    // Invocable method to create Task records
    @InvocableMethod(label='GA-EOA Create Task' description='Creates new Task records. Supports bulk operations. Use this method to add new Tasks into Salesforce.')
    public static List<EOACreateTaskResponse> createTasks(List<EOACreateTaskRequest> requests) {
        List<agf__ADM_Task__c> tasksToCreate = new List<agf__ADM_Task__c>();

        // Prepare Task records for insertion
        for (EOACreateTaskRequest request : requests) {
            agf__ADM_Task__c task = new agf__ADM_Task__c();
            task.agf__Subject__c = request.subject;
            task.agf__Status__c = request.status;
            task.agf__Assigned_To__c = request.assignedTo;
            task.agf__Due_By__c = request.dueDate;
            tasksToCreate.add(task);
        }

        Database.SaveResult[] results = Database.insert(tasksToCreate, false);

        List<EOACreateTaskResponse> responses = new List<EOACreateTaskResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOACreateTaskResponse response = new EOACreateTaskResponse();
            response.success = results[i].isSuccess();
            response.recordId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOACreateTaskRequest {
        @InvocableVariable(label='GA-EOA Task Subject' required=true description='Subject or title of the Task.')
        public String subject;

        @InvocableVariable(label='GA-EOA Task Status' description='Status of the Task.')
        public String status;

        @InvocableVariable(label='GA-EOA Assigned To' description='User ID of the person assigned to the Task.')
        public Id assignedTo;

        @InvocableVariable(label='GA-EOA Due Date' description='Due date of the Task.')
        public Date dueDate;
    }

    // Response wrapper for invocable method outputs
    public class EOACreateTaskResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Task creation was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Record ID' description='Salesforce ID of the created Task record. Null if creation failed.')
        public Id recordId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Task creation failed. Null if successful.')
        public String errors;
    }
}