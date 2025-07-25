public with sharing class FRAGetSessionDetails {

    /**
     * Invocable method to retrieve detailed information of Session records by unique IDs.
     * Useful for providing full session details for training or onboarding events.
     * @param sessionRequests List containing unique Session IDs.
     * @return List of SessionDetailsResponse with full details for each Session.
     */
    @InvocableMethod(label='GA-FRA Get Session Details' description='Retrieves detailed information of Session records based on unique IDs.')
    public static List<SessionDetailsResponse> getSessionDetails(List<SessionDetailsRequest> sessionRequests) {
        List<Id> sessionIds = new List<Id>();
        for (SessionDetailsRequest request : sessionRequests) {
            sessionIds.add(request.sessionId);
        }

        List<Session__c> sessions = [SELECT Id, Name, Start_Date__c, End_Date__c, Description__c
                                     FROM Session__c
                                     WHERE Id IN :sessionIds];

        List<SessionDetailsResponse> responses = new List<SessionDetailsResponse>();

        for (Session__c session : sessions) {
            SessionDetailsResponse response = new SessionDetailsResponse();
            response.sessionRecord = session;
            response.summary = 'Retrieved Session: ' + session.Name + ' (Start: ' + session.Start_Date__c + ', End: ' + session.End_Date__c + ')';

            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for retrieving Session details.
     */
    public class SessionDetailsRequest {

        @InvocableVariable(label='Session ID' description='Unique Salesforce ID of the Session record to retrieve.' required=true)
        public Id sessionId;
    }

    /**
     * Inner class representing response structure, including detailed Session records and a summary.
     */
    public class SessionDetailsResponse {

        @InvocableVariable(label='Session Record' description='Detailed Session record retrieved from Salesforce.')
        public Session__c sessionRecord;

        @InvocableVariable(label='Summary' description='Summary description of the retrieved session details.')
        public String summary;
    }
}