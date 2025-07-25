public with sharing class AHSessionTrainer_FindSessionsByEvent {

    public class FindSessionsRequest {
        @InvocableVariable(label='Event Name' description='The name of the Event (Asset) to find sessions for.' required=true)
        public String eventName;
    }

    public class FindSessionsResponse {
        @InvocableVariable(label='Event Asset ID' description='The Salesforce ID of the Event (Asset) that was found.')
        public Id eventAssetId;
        
        @InvocableVariable(label='Found Sessions' description='List of upcoming sessions found for the event.')
        public List<Session__c> sessions;
    }

    @InvocableMethod(label='AHSessionTrainer - Find Sessions By Event' description='Finds all upcoming sessions related to a specific event name.' category='AHSessionTrainer')
    public static List<FindSessionsResponse> findSessions(List<FindSessionsRequest> requests) {
        String eventName = requests[0].eventName;
        FindSessionsResponse response = new FindSessionsResponse();
        response.sessions = new List<Session__c>();

        Id eventRecordTypeId;
        try {
            eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        } catch (Exception e) {
            return new List<FindSessionsResponse>{response};
        }

        List<Asset__c> events = [
            SELECT Id FROM Asset__c 
            WHERE Name = :eventName AND RecordTypeId = :eventRecordTypeId 
            LIMIT 1
        ];

        if (!events.isEmpty()) {
            Id foundEventId = events[0].Id;
            response.eventAssetId = foundEventId;

            // MODIFIED: Added Staffed__c and a subquery for Session Guests to the SELECT clause.
            response.sessions = [
                SELECT Id, Name, Start_Date__c, Start_Time__c, End_Time__c, Time_Zone__c, Session_Type__c,
                       Staffed__c,
                       (SELECT Learner_Profile__r.Name, Role__c, Session_Role_Status__c 
                        FROM Session_Guests__r)
                FROM Session__c 
                WHERE Asset__c = :foundEventId 
                AND Start_Date__c >= TODAY 
                ORDER BY Start_Date__c
            ];
        }

        return new List<FindSessionsResponse>{response};
    }
}