public with sharing class AHSessionTrainer_RemoveTimeOff {

    public class RemoveTimeOffRequest {
        @InvocableVariable(label='Time Off Record ID' description='The ID of the Availability record to delete.' required=true)
        public Id recordId;
    }

    public class RemoveTimeOffResponse {
        @InvocableVariable(label='Success')
        public Boolean isSuccess;
        @InvocableVariable(label='Result Message')
        public String resultMessage;
    }

    @InvocableMethod(label='AHSessionTrainer - Remove Time Off' description='Deletes an existing Availability record.' category='AHSessionTrainer')
    public static List<RemoveTimeOffResponse> removeTimeOff(List<RemoveTimeOffRequest> requests) {
        Id recordIdToDelete = requests[0].recordId;
        RemoveTimeOffResponse response = new RemoveTimeOffResponse();

        try {
            Id userProfileId = [SELECT Id FROM Learner_Profile__c WHERE User__c = :UserInfo.getUserId() LIMIT 1].Id;

            // Security Check: Verify the record belongs to the current user before deleting.
            List<Availability__c> recordsToDelete = [SELECT Id FROM Availability__c WHERE Id = :recordIdToDelete AND Learner_Profile__c = :userProfileId];

            if(recordsToDelete.isEmpty()){
                response.isSuccess = false;
                response.resultMessage = 'Time off entry not found or you do not have permission to remove it.';
            } else {
                delete recordsToDelete;
                response.isSuccess = true;
                response.resultMessage = 'Successfully removed the time off entry.';
            }

        } catch (Exception e) {
            response.isSuccess = false;
            response.resultMessage = 'An error occurred: ' + e.getMessage();
        }
        
        return new List<RemoveTimeOffResponse>{response};
    }
}