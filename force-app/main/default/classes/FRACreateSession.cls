public with sharing class FRACreateSession {

    /**
     * Invocable method to create new Session records.
     * Sessions represent scheduled training events or onboarding activities.
     * @param sessionRequests List containing details for creating new Session records.
     * @return List of IDs for newly created Session records.
     */
    @InvocableMethod(label='GA-FRA Create Session' description='Creates new Session records for training or onboarding events.')
    public static List<Id> createSessions(List<SessionCreateRequest> sessionRequests) {
        List<Id> createdIds = new List<Id>();

        List<Session__c> sessionsToCreate = new List<Session__c>();

        for (SessionCreateRequest request : sessionRequests) {
            sessionsToCreate.add(new Session__c(
                Name = request.sessionName,
                Start_Date__c = request.startDate.date(),
                End_Date__c = request.endDate.date(),
                Description__c = request.description
            ));
        }

        insert sessionsToCreate;

        for (Session__c session : sessionsToCreate) {
            createdIds.add(session.Id);
        }

        System.debug('Session records created successfully.');
        return createdIds;
    }

    /**
     * Inner class representing request parameters for session creation.
     */
    public class SessionCreateRequest {

        @InvocableVariable(label='Session Name' description='Name of the training or onboarding session.' required=true)
        public String sessionName;

        @InvocableVariable(label='Start Date' description='Start date and time of the session.' required=true)
        public Datetime startDate;

        @InvocableVariable(label='End Date' description='End date and time of the session.' required=true)
        public Datetime endDate;

        @InvocableVariable(label='Description' description='Detailed description or agenda of the session.')
        public String description;
    }
}