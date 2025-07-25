public with sharing class AHSessionTrainer_AssignTrainer {

    public class AssignTrainerRequest {
        @InvocableVariable(label='Session ID' required=true)
        public Id sessionId;
        @InvocableVariable(label='Learner Profile ID' required=true)
        public Id learnerProfileId;
        @InvocableVariable(label='Role' required=true)
        public String role;
    }

    // MODIFIED: The response now includes success/error flags and messages.
    public class AssignTrainerResponse {
        @InvocableVariable(label='Success' description='True if the assignment was successful, otherwise false.')
        public Boolean isSuccess;

        @InvocableVariable(label='Result Message' description='A message describing the outcome of the operation.')
        public String resultMessage;
    }

    @InvocableMethod(label='AHSessionTrainer - Assign Trainer to Session' description='Assigns a trainer to a specific session with a designated role.' category='AHSessionTrainer')
    public static List<AssignTrainerResponse> assignTrainerToSession(List<AssignTrainerRequest> requests) {
        AssignTrainerResponse response = new AssignTrainerResponse();

        try {
            // The entire operation is now wrapped in the try block
            Map<String, List<TrainingResource.UserRoleWrapper>> sessionUserRolesMap = new Map<String, List<TrainingResource.UserRoleWrapper>>();
            for (AssignTrainerRequest req : requests) {
                TrainingResource.UserRoleWrapper urw = new TrainingResource.UserRoleWrapper();
                urw.selectedUser = req.learnerProfileId;
                urw.selectedRole = req.role;
                if (!sessionUserRolesMap.containsKey(req.sessionId)) {
                    sessionUserRolesMap.put(req.sessionId, new List<TrainingResource.UserRoleWrapper>());
                }
                sessionUserRolesMap.get(req.sessionId).add(urw);
            }

            if (!sessionUserRolesMap.isEmpty()) {
                TrainingResource.upsertRoles(sessionUserRolesMap);
            }

            // If we reach here without an error, the operation was successful
            response.isSuccess = true;
            response.resultMessage = 'Successfully assigned the trainer to the session.';

        } catch (Exception e) {
            // If any error occurs, we catch it and populate the response with error details.
            // The action itself does not crash.
            response.isSuccess = false;
            response.resultMessage = 'An error occurred while assigning the trainer: ' + e.getMessage();
        }

        // We always return the response object, which contains the outcome.
        return new List<AssignTrainerResponse>{response};
    }
}