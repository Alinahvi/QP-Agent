public with sharing class EOAModifyTask {

    // Invocable method to modify Task records
    @InvocableMethod(label='GA-EOA Modify Task Records' description='Modifies existing Task records based on provided IDs. Supports bulk updates.')
    public static List<EOAModifyTaskResponse> modifyTasks(List<EOAModifyTaskRequest> requests) {
        List<agf__ADM_Task__c> tasksToUpdate = new List<agf__ADM_Task__c>();

        // Prepare Task records for update
        for (EOAModifyTaskRequest request : requests) {
            agf__ADM_Task__c task = new agf__ADM_Task__c(Id = request.taskId);
            // Assign fields for modification based on actual schema
            tasksToUpdate.add(task);
        }

        // Update records and handle potential exceptions gracefully
        Database.SaveResult[] results = Database.update(tasksToUpdate, false);

        List<EOAModifyTaskResponse> responses = new List<EOAModifyTaskResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOAModifyTaskResponse response = new EOAModifyTaskResponse();
            response.success = results[i].isSuccess();
            response.taskId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOAModifyTaskRequest {
        @InvocableVariable(label='GA-EOA Task ID' required=true description='The Salesforce ID of the Task record to modify.')
        public Id taskId;

        // Include additional fields as needed, each clearly labeled and documented
    }

    // Response wrapper for invocable method outputs
    public class EOAModifyTaskResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Task modification was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Task ID' description='Salesforce ID of the modified Task record. Null if modification failed.')
        public Id taskId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Task modification failed. Null if successful.')
        public String errors;
    }
}