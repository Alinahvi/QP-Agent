public with sharing class AHSessionTrainer_CreateTimeOff {

    public class CreateTimeOffRequest {
        @InvocableVariable(label='Type' description='The type of time off (e.g., PTO, VTO).' required=true)
        public String type;
        
        // MODIFIED: We now accept the full DateTime string directly from the agent.
        @InvocableVariable(label='Start Date and Time' description='The start date/time in ISO 8601 format.' required=true)
        public String startDateTime;

        @InvocableVariable(label='End Date and Time' description='The end date/time in ISO 8601 format.' required=true)
        public String endDateTime;

        @InvocableVariable(label='All Day Event' required=true)
        public Boolean isAllDay;
    }

    public class CreateTimeOffResponse {
        @InvocableVariable(label='Success')
        public Boolean isSuccess;
        @InvocableVariable(label='Result Message')
        public String resultMessage;
    }

    @InvocableMethod(label='AHSessionTrainer - Create Time Off' description='Creates a new Availability record for a trainer\'s time off.' category='AHSessionTrainer')
    public static List<CreateTimeOffResponse> createTimeOff(List<CreateTimeOffRequest> requests) {
        CreateTimeOffRequest req = requests[0];
        CreateTimeOffResponse response = new CreateTimeOffResponse();

        try {
            List<Learner_Profile__c> profiles = [SELECT Id FROM Learner_Profile__c WHERE User__c = :UserInfo.getUserId() LIMIT 1];

            if (profiles.isEmpty()) {
                response.isSuccess = false;
                response.resultMessage = 'Could not find a Learner Profile associated with the current user.';
                return new List<CreateTimeOffResponse>{response};
            }

            // NEW: Convert the incoming DateTime strings into actual DateTime objects.
            // This is robust and handles the format sent by the agent.
            DateTime finalStartDate = (DateTime)JSON.deserialize('"' + req.startDateTime + '"', DateTime.class);
            DateTime finalEndDate = (DateTime)JSON.deserialize('"' + req.endDateTime + '"', DateTime.class);

            Availability__c newAvailability = new Availability__c(
                Learner_Profile__c = profiles[0].Id,
                Type__c = req.type,
                Start_Date__c = finalStartDate,
                End_Date__c = finalEndDate,
                All_Day_Event__c = req.isAllDay
            );

            insert newAvailability;
            response.isSuccess = true;
            response.resultMessage = 'Successfully created the time off entry.';

        } catch (Exception e) {
            response.isSuccess = false;
            response.resultMessage = 'An error occurred: ' + e.getMessage();
        }

        return new List<CreateTimeOffResponse>{response};
    }
}