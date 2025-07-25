public with sharing class TrainingUnenrollmentService {

    // Defines the inputs the Flow will provide
    public class UnenrollRequest {
        @InvocableVariable(label='Assigned Learning ID' required=true description='The ID of the Assigned_Curriculum__c, Assigned_Course__c, or Assignment__c record.')
        public String assignedLearningId;

        @InvocableVariable(label='Unenrollment Reason' description='(Optional) The reason for unenrolling.')
        public String unenrollReason;
        
        @InvocableVariable(label='Unenrollment Comment' description='(Optional) Additional comments for unenrolling.')
        public String unenrollComment;
    }

    // Defines the outputs the Flow will receive
    public class UnenrollResponse {
        @InvocableVariable(label='Unenrollment Successful')
        public Boolean isSuccess;

        @InvocableVariable(label='Message')
        public String message;
    }

    @InvocableMethod(label='Unenroll Current User from Training' description='Unenrolls the currently running user from an assigned training item.')
    public static List<UnenrollResponse> unenrollCurrentUserFromTraining(List<UnenrollRequest> requests) {
        UnenrollRequest request = requests[0];
        UnenrollResponse response = new UnenrollResponse();

        // Construct the JSON string that the existing UnenrollLearning class expects.
        // It needs an 'Id', 'unenrollReason', and 'unenrollComment'.
        Map<String, Object> unenrollData = new Map<String, Object>{
            'Id' => request.assignedLearningId,
            'unenrollReason' => request.unenrollReason,
            'unenrollComment' => request.unenrollComment
        };
        String unenrollJSONStr = JSON.serialize(unenrollData);

        try {
            // Call the existing method in UnenrollLearning.cls.
            // This method uses UserInfo.getUserId() internally, so it works perfectly for this persona.
            ResponseData rd = UnenrollLearning.unenrollUserLearning(unenrollJSONStr);
            
            // Interpret the ResponseData object and prepare the output for the Flow
            response.isSuccess = rd.isSuccess;
            if (!rd.isSuccess) {
                // Use the errMsg property from the ResponseData class you provided
                response.message = rd.errMsg; 
            } else {
                response.message = 'You have been successfully unenrolled from the learning item.';
            }

        } catch (Exception e) {
            response.isSuccess = false;
            response.message = 'An unexpected error occurred during unenrollment: ' + e.getMessage();
        }

        return new List<UnenrollResponse>{ response };
    }
}