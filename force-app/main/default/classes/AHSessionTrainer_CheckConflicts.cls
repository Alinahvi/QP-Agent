public with sharing class AHSessionTrainer_CheckConflicts {

    public class CheckConflictsRequest {
        @InvocableVariable(label='Session ID(s)' required=true)
        public List<Id> sessionIds;
        @InvocableVariable(label='Learner Profile ID(s)' required=true)
        public List<Id> learnerProfileIds;
    }

    // NEW: A wrapper class to hold both the trainer and their conflicting event.
    public class ConflictDetail {
        @InvocableVariable(label='Conflicting Trainer' description='The Learner Profile of the trainer who has a conflict.')
        public Learner_Profile__c conflictingTrainer;

        @InvocableVariable(label='Conflicting Event' description='The specific Availability record that conflicts with the session.')
        public Availability__c conflictingEvent;
    }

    // MODIFIED: The response now returns a list of the new ConflictDetail objects.
    public class CheckConflictsResponse {
        @InvocableVariable(label='Conflict Details' description='A list of conflicts, including the trainer and the specific event they have a conflict with.')
        public List<ConflictDetail> conflicts;
    }

    @InvocableMethod(label='AHSessionTrainer - Check for Conflicts' description='Checks if selected trainers have scheduling conflicts with selected sessions.' category='AHSessionTrainer')
    public static List<CheckConflictsResponse> checkConflicts(List<CheckConflictsRequest> requests) {
        CheckConflictsRequest req = requests[0];
        // The map now stores the new ConflictDetail object.
        Map<Id, ConflictDetail> conflictsMap = new Map<Id, ConflictDetail>();

        List<Session__c> sessions = [SELECT Id, Start_Date__c, End_Date__c, Start_Time_Converted__c, End_Time_Converted__c, Session_Type__c FROM Session__c WHERE Id IN :req.sessionIds];
        List<Learner_Profile__c> trainers = [SELECT Id, Name FROM Learner_Profile__c WHERE Id IN :req.learnerProfileIds];

        for (Learner_Profile__c lp : trainers) {
            // MODIFIED: Added the 'Name' field to the query to get the event's name.
            List<Availability__c> events = [SELECT Id, Name, All_Day_Event__c, Start_Date__c, End_Date__c, Type__c FROM Availability__c WHERE Learner_Profile__c =: lp.Id];
            
            for (Session__c session : sessions) {
                Boolean hasConflict = false;
                Availability__c conflictingEvent;

                for (Availability__c event : events) {
                    if (session.Session_Type__c != 'Physical' && event.Type__c == 'No Travel Days') continue;
                    
                    if ((event.All_Day_Event__c && session.Start_Date__c <= event.End_Date__c.date() && session.Start_Date__c >= event.Start_Date__c.date()) || 
                        (event.Start_Date__c <= session.End_Time_Converted__c && session.Start_Time_Converted__c <= event.End_Date__c)) {
                        
                        hasConflict = true;
                        conflictingEvent = event; // Capture the specific conflicting event
                        break;
                    }
                }

                if (hasConflict) {
                    // Create the new ConflictDetail object and add it to our map.
                    ConflictDetail detail = new ConflictDetail();
                    detail.conflictingTrainer = lp;
                    detail.conflictingEvent = conflictingEvent;
                    conflictsMap.put(lp.Id, detail);
                    break; // Move to the next trainer once a conflict is found for this one
                }
            }
        }
        
        CheckConflictsResponse response = new CheckConflictsResponse();
        // The final response is a list of the ConflictDetail objects.
        response.conflicts = conflictsMap.values();
        return new List<CheckConflictsResponse>{response};
    }
}