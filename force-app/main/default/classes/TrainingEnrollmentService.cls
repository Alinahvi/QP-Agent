public with sharing class TrainingEnrollmentService {

    // --- WRAPPER CLASSES (Input/Output for Invocable Method) ---
    public class EnrollUserRequest {
        @InvocableVariable(label='User ID' required=true description='The Salesforce User ID of the employee to enroll.')
        public String userId;

        @InvocableVariable(label='Training Record ID' required=true description='The ID of the Curriculum, Course, or Event (Asset) to enroll in.')
        public Id trainingRecordId;

        @InvocableVariable(label='Training Object Type' required=true description='The type of training: "Curriculum", "Course", or "Event".')
        public String trainingObjectType;

        @InvocableVariable(label='Due Date' description='Optional due date for the training assignment.')
        public Date dueDate;
    }

    public class EnrollUserResponse {
        @InvocableVariable(label='Enrollment Successful')
        public Boolean isSuccess;

        @InvocableVariable(label='Message' description='Status message for the enrollment attempt.')
        public String message;

        @InvocableVariable(label='Assigned Item ID' description='The ID of the created assignment record, if successful.')
        public String assignmentId;
    }

    // --- INVOCABLE METHOD: Enroll User in Training ---
    @InvocableMethod(label='Enroll Employee in Training' description='Enrolls the specified user in the selected training item via AssignmentBatchHelper.')
    public static List<EnrollUserResponse> enrollEmployeeInTraining(List<EnrollUserRequest> requests) {
        EnrollUserRequest request = requests[0];
        EnrollUserResponse response = new EnrollUserResponse();
        response.isSuccess = false; // Default to false

        System.debug(LoggingLevel.INFO, 'TrainingEnrollmentService --- INPUTS --- UserId: ' + request.userId +
                     ', TrainingRecordId: ' + request.trainingRecordId +
                     ', TrainingObjectType: ' + request.trainingObjectType +
                     ', DueDate: ' + request.dueDate);

        try {
            if (String.isBlank(request.userId) || request.trainingRecordId == null || String.isBlank(request.trainingObjectType)) {
                response.message = 'User ID, Training Record ID, and Training Object Type are required.';
                return new List<EnrollUserResponse>{response};
            }

            String sObjectApiName;
            if ('Curriculum'.equalsIgnoreCase(request.trainingObjectType)) {
                sObjectApiName = 'Curriculum__c';
            } else if ('Course'.equalsIgnoreCase(request.trainingObjectType)) {
                sObjectApiName = 'Course__c';
            } else if ('Event'.equalsIgnoreCase(request.trainingObjectType)) { 
                sObjectApiName = 'Asset__c';
            } else {
                response.message = 'Unsupported training object type: ' + request.trainingObjectType + '. Supported types are "Curriculum", "Course", "Event".';
                return new List<EnrollUserResponse>{response};
            }

            Map<String, Object> learningItemMap = new Map<String, Object>{
                'type' => sObjectApiName,
                'Id' => request.trainingRecordId
            };

            Date effectiveDueDate = request.dueDate != null ? request.dueDate : System.today().addDays(30);

            // Call the existing AssignmentBatchHelper method.
            // The 'ResponseData' type below should now correctly refer to your existing ResponseData.cls
            ResponseData helperResponse = AssignmentBatchHelper.assignLearning(
                request.userId,
                learningItemMap,
                true, 
                effectiveDueDate
            );

            if (helperResponse != null) {
                if (!helperResponse.isSuccess) { // Check the isSuccess flag from your ResponseData class
                    response.message = 'Enrollment failed: ' + helperResponse.errMsg; 
                    System.debug(LoggingLevel.WARN, 'Enrollment failed for UserId ' + request.userId + ' on ' + request.trainingRecordId + 
                                 '. Error: ' + helperResponse.errMsg + ' Stack: ' + helperResponse.stack);
                } else {
                    response.isSuccess = true;
                    response.message = 'Successfully enrolled in ' + request.trainingObjectType + '.';
                    // Your ResponseData uses a 'results' map for 'put' operations.
                    if (helperResponse.results != null && helperResponse.results.containsKey('assignmentId')) {
                        Object assignedIdObj = helperResponse.results.get('assignmentId'); 
                        if (assignedIdObj != null) {
                            response.assignmentId = String.valueOf(assignedIdObj);
                            response.message += ' Assignment ID: ' + response.assignmentId;
                        }
                    }
                    System.debug(LoggingLevel.INFO, 'Enrollment successful for UserId ' + request.userId + ' on ' + request.trainingRecordId + '. Assignment ID: ' + response.assignmentId);
                }
            } else {
                 response.message = 'Enrollment process returned an unexpected null response from AssignmentBatchHelper.';
                 System.debug(LoggingLevel.ERROR, 'AssignmentBatchHelper.assignLearning returned null for UserId ' + request.userId + ' on ' + request.trainingRecordId);
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in enrollEmployeeInTraining: ' + e.getMessage() + '\nStackTrace: ' + e.getStackTraceString());
            response.message = 'An unexpected error occurred during enrollment: ' + e.getMessage();
            response.isSuccess = false; 
        }
        return new List<EnrollUserResponse>{response};
    }
}