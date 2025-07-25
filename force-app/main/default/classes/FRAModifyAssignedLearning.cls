public with sharing class FRAModifyAssignedLearning {

    /**
     * Invocable method to update existing Assigned Learning records.
     * Allows updates to details of learning assignments.
     * @param assignedLearningUpdates List containing updated details for existing Assigned Learning records.
     * @return List of AssignedLearningUpdateResponse indicating update outcomes.
     */
    @InvocableMethod(label='GA-FRA Modify Assigned Learning' description='Updates existing Assigned Learning records based on provided details.')
    public static List<AssignedLearningUpdateResponse> modifyAssignedLearning(List<AssignedLearningUpdateRequest> assignedLearningUpdates) {
        List<Assigned_Learning__c> learningsToUpdate = new List<Assigned_Learning__c>();

        for (AssignedLearningUpdateRequest request : assignedLearningUpdates) {
            learningsToUpdate.add(new Assigned_Learning__c(
                Id = request.assignedLearningId,
                Due_Date__c = request.dueDate,
                Start_Date__c = request.startDate,
                Frequency__c = request.frequency,
                Recur__c = request.recur
            ));
        }

        update learningsToUpdate;

        List<AssignedLearningUpdateResponse> responses = new List<AssignedLearningUpdateResponse>();
        for (Assigned_Learning__c learning : learningsToUpdate) {
            AssignedLearningUpdateResponse response = new AssignedLearningUpdateResponse();
            response.assignedLearningId = learning.Id;
            response.message = 'Assigned Learning updated successfully.';
            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for Assigned Learning updates.
     */
    public class AssignedLearningUpdateRequest {

        @InvocableVariable(label='Assigned Learning ID' description='Unique Salesforce ID of the Assigned Learning record to update.' required=true)
        public Id assignedLearningId;

        @InvocableVariable(label='Due Date' description='Updated due date for the learning assignment.')
        public Date dueDate;

        @InvocableVariable(label='Start Date' description='Updated start date for the learning assignment.')
        public Date startDate;

        @InvocableVariable(label='Frequency' description='Updated frequency for the learning assignment.')
        public String frequency;

        @InvocableVariable(label='Recur' description='Updated recurrence flag for the learning assignment.')
        public Boolean recur;
    }

    /**
     * Inner class representing response structure after updating Assigned Learning.
     */
    public class AssignedLearningUpdateResponse {

        @InvocableVariable(label='Assigned Learning ID' description='Salesforce ID of the updated Assigned Learning record.')
        public Id assignedLearningId;

        @InvocableVariable(label='Message' description='Confirmation message indicating the outcome of the update.')
        public String message;
    }
}