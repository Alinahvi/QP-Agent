public with sharing class FRAModifySession {

    /**
     * Invocable method to modify existing Session records.
     * Allows updating details for training or onboarding sessions.
     * @param sessionUpdateRequests List containing updated details for existing Session records.
     * @return List of SessionUpdateResponse indicating success of updates.
     */
    @InvocableMethod(label='GA-FRA Modify Session' description='Updates existing Session records based on provided details.')
    public static List<SessionUpdateResponse> modifySessions(List<SessionUpdateRequest> sessionUpdateRequests) {
        List<Session__c> sessionsToUpdate = new List<Session__c>();

        for (SessionUpdateRequest request : sessionUpdateRequests) {
            sessionsToUpdate.add(new Session__c(
                Id = request.sessionId,
                Name = request.sessionName,
                Start_Date__c = request.startDate != null ? request.startDate.date() : null,
                End_Date__c = request.endDate != null ? request.endDate.date() : null,
                Description__c = request.description
            ));
        }

        update sessionsToUpdate;

        List<SessionUpdateResponse> responses = new List<SessionUpdateResponse>();
        for (Session__c session : sessionsToUpdate) {
            SessionUpdateResponse response = new SessionUpdateResponse();
            response.sessionId = session.Id;
            response.message = 'Session record updated successfully.';
            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for session updates.
     */
    public class SessionUpdateRequest {

        @InvocableVariable(label='Session ID' description='Unique Salesforce ID of the Session record to update.' required=true)
        public Id sessionId;

        @InvocableVariable(label='Session Name' description='Updated name for the session.')
        public String sessionName;

        @InvocableVariable(label='Start Date' description='Updated start date and time for the session.')
        public Datetime startDate;

        @InvocableVariable(label='End Date' description='Updated end date and time for the session.')
        public Datetime endDate;

        @InvocableVariable(label='Description' description='Updated detailed description or agenda for the session.')
        public String description;
    }

    /**
     * Inner class representing the response structure after updating a session.
     */
    public class SessionUpdateResponse {

        @InvocableVariable(label='Session ID' description='Salesforce ID of the updated Session record.')
        public Id sessionId;

        @InvocableVariable(label='Message' description='Confirmation message indicating the outcome of the update.')
        public String message;
    }
}