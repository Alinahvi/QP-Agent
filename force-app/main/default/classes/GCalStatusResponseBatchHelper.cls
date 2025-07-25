public with sharing class GCalStatusResponseBatchHelper {
    // public static void updateCalendarResponses(List<GCal_Event__c> gcalEvents){
    //     // isGCalResponseBatch = true;

    //     // Map<String, String> headers = utilities.getGCalHeaders(); 
    //     //EventId|Email
    //     Map<Id, Id> sessionByGcalEventId = new Map<Id, Id>();
    //     Map<String, String> calendarStatusByEventIdAndEmail = new Map<String, String>();
    //     System.debug('***************** gcalEvents ' + gcalEvents);
    //     Map<String, String> headers = new Map <String, String> {
    //         'Content-Type' => 'application/json'
    //     };
    //     for(GCal_Event__c gcalEvent : gcalEvents){
    //         sessionByGcalEventId.put(gcalEvent.Id, gcalEvent.Session__c);
    //         String pageToken;
    //         String endpoint = constants.GCAL_EVENTS_ENDPOINT + '/' + gcalEvent.GCal_Event_Id__c;
    //         String method = 'GET';

    //         HttpResponse res = utilities.makeNCCallout(endPoint, method, headers);
    //         Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    //         List<Object> attendees = (List<Object>)resBody.get('attendees'); 
            
    //         if(attendees == null){
    //             continue;
    //         }

    //         for(Object attendee : attendees){
    //             Map<String, Object> attendeeMap = (Map<String, Object>)attendee;
    //             String responseStatus = (String)attendeeMap.get('responseStatus');
    //             String email = (String)attendeeMap.get('email');
                
    //             calendarStatusByEventIdAndEmail.put(gcalEvent.GCal_Event_Id__c + '|' + email, responseStatus);
    //         }
    //     }

    //     List<Assigned_Session__c> aSessionToUpdate = new List<Assigned_Session__c>();                                     
    //     for(Assigned_Session__c aSession : [SELECT Id, Status__c, GCal_Response__c, GCal_Event__r.GCal_Event_Id__c,
    //                                         Learner_Profile__c, Learner_Profile__r.Name, 
    //                                         Learner_Profile__r.Primary_Email__c 
    //                                         FROM Assigned_Session__c
    //                                         WHERE Session__c IN: sessionByGcalEventId.values()
    //                                         AND GCal_Event__c IN: sessionByGcalEventId.keySet()
    //                                         AND Status__c != 'Attended'
    //                                         WITH USER_MODE]) { 
    //         String key = aSession.GCal_Event__r.GCal_Event_Id__c + '|' + aSession.Learner_Profile__r.Primary_Email__c;
    //         if(calendarStatusByEventIdAndEmail.containsKey(key)){
    //             String newAssignmentStatus;
    //             String statusResponse = calendarStatusByEventIdAndEmail.get(key);
    //             String formattedResponse = null;
    //             switch on statusResponse {
    //                 when 'needsAction' {
    //                     formattedResponse = 'Needs Action';
    //                 }	
    //                 when 'accepted' {
    //                     newAssignmentStatus = 'Registered';
    //                     formattedResponse = 'Accepted';
    //                 }
    //                 when 'declined' {
    //                     newAssignmentStatus = 'Canceled';
    //                     formattedResponse = 'Declined';
    //                 }
    //                 when 'tentative' {
    //                     formattedResponse = 'Tentative';
    //                 }
    //                 when else {
    //                    formattedResponse = null;
    //                 }
    //             }

    //             if(String.isNotEmpty(newAssignmentStatus)) {
    //                 aSession.Status__c = newAssignmentStatus;                    
    //             }
    //             aSession.GCal_Response__c = formattedResponse;
    //             aSessionToUpdate.add(aSession);
    //         }
    //     }
    //     if(!aSessionToUpdate.isEmpty()) {
    //         Database.update(aSessionToUpdate, false);
    //     }        
    //     //Batches can't support more than 1 queueable and we 
    //     //can't use the trigger to do it as we might have more than 200 records which will cause 2 queuables to happen
    //     // System.enqueueJob(new gcalCreateEventQueueable(assignmentTriggerHelper.gcalEventsToRefresh, assignmentTriggerHelper.gcalAssignmentsToRefresh));
    // }
}