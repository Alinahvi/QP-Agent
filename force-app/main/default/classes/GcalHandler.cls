public with sharing class GcalHandler {
    
    // @AuraEnabled
    // public static String upsertGCalEvents(Id parentId, Integer offset) {
    //     ResponseData rd = new ResponseData();
    //     try {
    //         Boolean hasMore = false;
    //         String url;
    //         String tz;
    //         String description;
    //         String objective;
    //         Date startDate;
    //         Date endDate;
    //         Time startingTime;
    //         Time endingTime;
    //         String cancelledReasonDetail;
    //         String cancelledReason;
    //         String sessionStatus;
    //         String assestName = '';
    //         String address;
    //         String param = '' ;//= 'events';

    //         Session__c parent = [SELECT Id, Url__c, Time_Zone__c, Start_Date__c, Start_Time__c, Start_Time_Converted__c,
    //                                 End_Date__c, End_Time__c, End_Time_Converted__c, Description__c, Address__c, City__c,
    //                                 Country__c, Zip_Code__c, Asset__r.Name, Status__c, Cancelled_Reason__c, 
    //                                 Cancelled_Reason_Details__c
    //                             FROM Session__c
    //                             WHERE Id =: parentId
    //                             WITH USER_MODE];

    //         assestName = parent.Asset__r.Name;
    //         parentId = parent.Id;
    //         url = parent.Url__c;
    //         tz = parent.Time_Zone__c;
    //         startDate = parent.Start_Date__c;
    //         endDate = parent.End_Date__c;
    //         startingTime = parent.Start_Time__c;
    //         endingTime = parent.End_Time__c;
    //         description = parent.Description__c;
    //         sessionStatus = parent.Status__c;
    //         cancelledReasonDetail = parent.Cancelled_Reason_Details__c;
    //         cancelledReason = parent.Cancelled_Reason__c;
    //         address = parent.Country__c +', '+ parent.Address__c +', '+ parent.City__c+', '+ parent.Zip_Code__c;

    //         Integer offSetMinutes = TimeZone.getTimeZone(tz).getOffset(startDate) / 1000 / 60;
    //         DateTime startTime = DateTime.newInstanceGMT(startDate, startingTime).addMinutes(-offSetMinutes);
    //         DateTime endTime = DateTime.newInstanceGMT(endDate, endingTime).addMinutes(-offSetMinutes);

    //         List<GCal_Event__c> gcalEvents = new List<GCal_Event__c>();

    //         Map<String, String> headers = new Map <String, String> {
    //             'Content-Type' => 'application/json'
    //         };

    //         String soqlQuery = 'SELECT Id, GCal_Event_Id__c' + ' FROM GCal_Event__c' +
    //                             ' WHERE Session__c = :parentId' +
    //                             ' WITH USER_MODE' +
    //                             ' LIMIT 90' +
    //                             ' OFFSET ' + offset;
    
    //         // soqlQuery = String.format(soqlQuery, new List<String>{sObjectType});
    //         gcalEvents = Database.query(soqlQuery);

    //         Map<String, Object> payload = new Map<String, Object>{
    //             'start' => new Map<String, Object>{
    //                 'dateTime' => startTime,
    //                 'timeZone' => 'GMT'
    //             },
    //             'end' => new Map<String, Object>{
    //                 'dateTime' => endTime,
    //                 'timeZone' => 'GMT'
    //             },
    //             'summary' => assestName,
    //             // 'description' => description,
    //             'guestsCanInviteOthers' => false
    //         };

    //         if(sessionStatus != 'Cancelled') {
    //             payload.put('description', objective);
    //         } else {
    //             String reason = cancelledReason += String.isNotEmpty(cancelledReasonDetail) ? ' : '+cancelledReasonDetail : '';
    //             payload.put('description', reason );
    //         }

    //         if(url != null) {
    //             payload.put('location', url);
    //         } else if(address != null){
    //             payload.put('location', address);
    //         }

    //         if(gcalEvents.isEmpty()){
    //             String method = 'POST';                
    //             //add the creator to the event
    //             // List<Map<String, Object>> attendees = new List<Map<String, Object>>{
    //             //     new Map<String, Object> {
    //             //         'email' => UserInfo.getUserEmail(),
    //             //         'displayName' => UserInfo.getName(),
    //             //         'responseStatus' => 'accepted'
    //             //     }
    //             // };
    //             // payload.put('attendees', attendees);
    //             String endPoint = Constants.GCAL_EVENTS_ENDPOINT; // Constants.GCAL_NAMED_CREDENTIAL + Constants.GCAL_EVENTS_ENDPOINT;
    //             HttpResponse res = Utilities.makeNCCallout(endPoint, method, JSON.serialize(payload), headers);
                
    //             if(res.getStatusCode() == 201 || res.getStatusCode() == 200) {
    //                 Map<String, Object> body = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    //                 GCal_Event__c gcalEvent = new GCal_Event__c(
    //                     GCal_Event_Id__c = (String)body.get('id'),
    //                     Contains_Owner__c = true
    //                 );
    //                 gcalEvent.Session__c = parentId;
    //                 insert gcalEvent;
    //             } else {
    //                 rd.put('resBody', res.getbody());
    //                 rd.addError('Failed to create GCal Event');
    //             }
    //         } else {
    //             String method = 'PATCH';
    //             for(GCal_Event__c gcalEvent : gcalEvents){
    //                 if(sessionStatus != 'Cancelled') {
    //                     param = Constants.GCAL_EVENTS_ENDPOINT+'/'+gcalEvent.GCal_Event_Id__c+'?sendUpdates=all';
    //                 } else {
    //                     param = Constants.GCAL_EVENTS_ENDPOINT+'/' + gcalEvent.GCal_Event_Id__c;
    //                 }

    //                 HttpResponse res = utilities.makeNCCallout(param, method, JSON.serialize(payload), headers);
    //                 if(res.getStatusCode() != 201 && res.getStatusCode() != 200){
    //                     System.debug('Error Msg ------- '+res.getbody());
    //                     rd.put('endPoint', param);
    //                     rd.put('resBody', res.getbody());
    //                     rd.addError('Failed to update GCal Event');
    //                 } else {
    //                     if(Limits.getCallouts() == Limits.getLimitCallouts()) {
    //                         hasMore = true;
    //                         break;
    //                     }
    //                 }
    //             }
    //         }
    //         rd.put('hasMore', hasMore);
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }        
    //     return rd.getJsonString();
    // }

    // public static String getOpenGCalSlot(String sessionId, List<Map<String, Object>> newAttendees){
    //     String newGCalEventId = '';
    //     List<AggregateResult> openGCalEvents = [SELECT COUNT(Id), GCal_Event__c eventId
    //                                                     FROM Assigned_Session__c
    //                                                     WHERE Session__c =: sessionId
    //                                                     AND GCal_Event__c != null
    //                                                     WITH USER_MODE
    //                                                     GROUP BY GCal_Event__c
    //                                                     HAVING COUNT(Id) < :constants.GCAL_EVENT_ATTENDEE_LIMIT
    //                                                     ORDER BY COUNT(Id) ASC];
    
    //     if(openGCalEvents.isEmpty()){
    //         List<GCal_Event__c> firstEvents = [SELECT Id,
    //                                     (
    //                                         SELECT Id 
    //                                         FROM AssignedSessions__r
    //                                         LIMIT :constants.GCAL_EVENT_ATTENDEE_LIMIT
    //                                     )
    //                                     FROM GCal_Event__c
    //                                     WHERE Session__c =: sessionId
    //                                     AND Contains_Owner__c = true
    //                                     WITH USER_MODE];
    
    //         GCal_Event__c firstEvent = firstEvents.isEmpty() ? null : firstEvents.get(0);
    //         //double check the first event since if this is a brand new event it won't have any AssignedSessions
    //         //so it won't get picked up by the aggregate
    //         if(firstEvent != null && firstEvent.AssignedSessions__r.size() < constants.GCAL_EVENT_ATTENDEE_LIMIT){
    //             newGCalEventId = firstEvent.Id;
    //         } else {
    //             newGCalEventId = createGCalsession(sessionId, newAttendees);                
    //         }
    //     } else {
    //         AggregateResult ar = openGCalEvents.get(0);
    //         newGCalEventId = (String)ar.get('eventId');            
    //     }
    
    //     return newGCalEventId;
    // }

    // public static String createGCalsession(String sessionId, List<Map<String, Object>> newAttendees){
    //     Session__c session = [SELECT Id, Name, Url__c, Time_Zone__c, Start_Date__c, Objective__c, Asset__c, Asset__r.Name,
    //                                             End_Date__c, Start_Time__c, End_Time__c, Description__c,
    //                                             Cancelled_Reason__c, Cancelled_Reason_Details__c
    //                                     FROM Session__c
    //                                     WHERE Id =: sessionId
    //                                     WITH USER_MODE];
    
    //     return createGCalsession(session, session.Name, newAttendees);
    // }
    
    // public static String createGCalsession(sObject parentObj, String sessionName, List<Map<String, Object>> attendees){
    //     String newGCalEventId;
    //     Map<String, String> headers = new Map <String, String> {
    //         'Content-Type' => 'application/json'
    //     };
    //     String parentId = (String)parentObj.get('Id');
    //     String url = (String)parentObj.get('Url__c');
    //     String tz = (String)parentObj.get('Time_Zone__c');
    //     String description = (String)parentObj.get( 'Description__c');
        
    //     Date startDate = (Date)parentObj.get('Start_Date__c');
    //     Date endDate = (Date)parentObj.get('End_Date__c');
    //     Time startingTime = (Time)parentObj.get('Start_Time__c');
    //     Time endingTime = (Time)parentObj.get('End_Time__c');
    
    //     Integer offSetMinutes = TimeZone.getTimeZone(tz).getOffset(startDate) / 1000 / 60;
    //     DateTime startTime = DateTime.newInstanceGMT(startDate, startingTime).addMinutes(-offSetMinutes);
    //     DateTime endTime = DateTime.newInstanceGMT(endDate, endingTime).addMinutes(-offSetMinutes);
        
    //     Map<String, Object> payload = new Map<String, Object>{
    //         'start' => new Map<String, Object>{
    //             'dateTime' => startTime,
    //             'timeZone' => 'GMT'
    //         },
    //         'end' => new Map<String, Object>{
    //             'dateTime' => endTime,
    //             'timeZone' => 'GMT'
    //         },
    //         'summary' => sessionName,
    //         'description' => description,
    //         'location' => url,
    //         'attendees' => attendees,
    //         'guestsCanInviteOthers' => false
    //     };
    
    //     String method = 'POST';        
    //     HttpResponse res = utilities.makeNCCallout(Constants.GCAL_EVENTS_ENDPOINT, method, JSON.serialize(payload), headers);
    //     System.debug('createGCalEvent ----------------- '+res.getBody());
    //     if(res.getStatusCode() == 201 || res.getStatusCode() == 200){
    //         Map<String, Object> body = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    //         GCal_Event__c gcalEvent = new GCal_Event__c(
    //             GCal_Event_Id__c = (String)body.get('id')
    //         );
    //         gcalEvent.Session__c = parentId;
            
    //         insert gcalEvent;
    //         newGCalEventId = gcalEvent.Id;
    //     }
    
    //     return newGCalEventId;
    // }   

    // public static String createGCalEvent(String sessionId, List<Map<String, Object>> newAttendees){
    //     Session__c event = [SELECT Id, Name, Url__c, Time_Zone__c, Start_Date__c, Objective__c, Asset__c, Asset__r.Name,
    //                                             End_Date__c, Start_Time__c, End_Time__c, Description__c,
    //                                             Cancelled_Reason__c, Cancelled_Reason_Details__c
    //                                     FROM Session__c
    //                                     WHERE Id =: sessionId
    //                                     WITH USER_MODE];

    //     return createGCalEvent(event, event.Asset__r.Name, newAttendees);
    // }

    // public static String createGCalEvent(sObject parentObj, String eventName, List<Map<String, Object>> attendees){
    //     String newGCalEventId;
    //     Map<String, String> headers = new Map <String, String> {
    //         'Content-Type' => 'application/json'
    //     };
    //     String parentId = (String)parentObj.get('Id');
    //     String url = (String)parentObj.get('Url__c');
    //     String tz = (String)parentObj.get('Time_Zone__c');
    //     String description = (String)parentObj.get( 'Description__c');
        
    //     Date startDate = (Date)parentObj.get('Start_Date__c');
    //     Date endDate = (Date)parentObj.get('End_Date__c');
    //     Time startingTime = (Time)parentObj.get('Start_Time__c');
    //     Time endingTime = (Time)parentObj.get('End_Time__c');

    //     Integer offSetMinutes = TimeZone.getTimeZone(tz).getOffset(startDate) / 1000 / 60;
    //     DateTime startTime = DateTime.newInstanceGMT(startDate, startingTime).addMinutes(-offSetMinutes);
    //     DateTime endTime = DateTime.newInstanceGMT(endDate, endingTime).addMinutes(-offSetMinutes);
        
    //     Map<String, Object> payload = new Map<String, Object>{
    //         'start' => new Map<String, Object>{
    //             'dateTime' => startTime,
    //             'timeZone' => 'GMT'
    //         },
    //         'end' => new Map<String, Object>{
    //             'dateTime' => endTime,
    //             'timeZone' => 'GMT'
    //         },
    //         'summary' => eventName,
    //         'description' => description,
    //         'location' => url,
    //         'attendees' => attendees,
    //         'guestsCanInviteOthers' => false
    //     };

    //     String method = 'POST';        
    //     HttpResponse res = utilities.makeNCCallout(Constants.GCAL_EVENTS_ENDPOINT, method, JSON.serialize(payload), headers);
    //     System.debug('createGCalEvent ----------------- '+res.getBody());
    //     if(res.getStatusCode() == 201 || res.getStatusCode() == 200){
    //         Map<String, Object> body = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    //         GCal_Event__c gcalEvent = new GCal_Event__c(
    //             GCal_Event_Id__c = (String)body.get('id')
    //         );
    //         gcalEvent.Session__c = parentId;
            
    //         insert gcalEvent;
    //         newGCalEventId = gcalEvent.Id;
    //     }

    //     return newGCalEventId;
    // }

    // @AuraEnabled
    // public static String createGoogleMeet(String jsonString){
    //     ResponseData rd = new ResponseData();
    //     try {
    //         Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
    //         String sessionId = (String)dataMap.get('sessionId');
    //         List<GCal_Event__c> gcalEvents = [SELECT Id, GCal_Event_Id__c 
    //                                             FROM GCal_Event__c 
    //                                             WHERE Session__c =: sessionId
    //                                             WITH USER_MODE];

    //         List<Session__c> sessions = [SELECT Id, Name, Url__c, Google_Meet_Id__c, Virtual_Type__c, 
    //                                         Objective__c, Description__c
    //                                         FROM Session__c
    //                                         WHERE Id =: sessionId
    //                                         AND Virtual_Type__c = 'Google Meet'
    //                                         AND Google_Meet_Id__c = ''
    //                                         WITH USER_MODE];

    //         if(!gcalEvents.isEmpty() && !sessions.isEmpty()) {
    //             Map<String, Object> errors = new Map<String, Object>();
    //             Session__c session = sessions.get(0);
    //             Map<String, Object> payload = new Map<String, Object>{
    //                 'conferenceData' => new Map<String, Object> {
    //                     'createRequest' => new Map<String, Object>{
    //                         'requestId' => session.Id
    //                     }
    //                 }
    //             };
    //             Map<String, String> headers = new Map <String, String> {
    //                 'Content-Type' => 'application/json'
    //             };
                
    //             String endPoint = Constants.GCAL_EVENTS_ENDPOINT + '/' + gcalEvents[0].GCal_Event_Id__c + '?conferenceDataVersion=1';
    //             HttpResponse res = utilities.makeNCCallout(endPoint, 'PATCH', JSON.serialize(payload), headers);
    //             if(res.getStatusCode() != 201 && res.getStatusCode() != 200){
    //                 System.debug('Google Meet Error ::::: '+res.getbody());
    //                 rd.addError('Failed to create Google Meet conference');
    //                 rd.put('res', res.getBody());
    //                 return rd.getJsonString();                 
    //             } else {
    //                 Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    //                 String meetUrl = (String)resBody.get('hangoutLink'); 
    //                 session.Google_Meet_Id__c = sessionId;
    //                 if(String.isNotEmpty(meetUrl)) {
    //                     session.Url__c = meetUrl;                        
    //                 }
    //                 update session;
    //             }
    //         }            
    //     } catch (Exception e) {
    //         rd.addError(e);
    //     }
    //     return rd.getJsonString();
    // }

    // public static Map<String, Object> setGCalAttendees(GCal_Event__c gcalEvent, Set<String> usersToForceAttend){
    //     Map<String, Object> returnPayload = new Map<String, Object>{
    //         'success' => true,
    //         'error' => ''
    //     };
    
    //     Map<String, String> headers = new Map <String, String> {
    //         'Content-Type' => 'application/json'
    //     };
        
    //     String gcalEventId = gcalEvent.GCal_Event_Id__c;
        
    //     if(gcalEventId == null){
    //         returnPayload.put('success', false);
    //         returnPayload.put('error', 'Unable to update your Google Calender to this GCal Event as there is no GCal Event Id.');
    //     }
    
    //     Boolean succeeded = false;
    //     String endPoint = Constants.GCAL_EVENTS_ENDPOINT + '/' + gcalEventId + '?sendUpdates=all';
    //     HttpResponse getRes = utilities.makeNCCallout(endPoint, 'GET', headers);
    //     System.debug('GCAL ::: --------- '+getRes.getBody());
    //     Map<String, Object> eventBody = (Map<String, Object>)JSON.deserializeUntyped(getRes.getBody());
    //     List<Object> attendeesFromGcal = (List<Object>)eventBody.get('attendees');
    //     Map<String, String> attendeeStatusByEmail = new Map<String, String>();
    
    //     if(attendeesFromGcal != null){
    //         for(Object attendeeObj : attendeesFromGcal){
    //             Map<String, Object> attendee = (Map<String, Object>)attendeeObj;
    
    //             if(String.isNotEmpty((String)attendee.get('responseStatus'))){
    //                 attendeeStatusByEmail.put((String)attendee.get('email'), (String)attendee.get('responseStatus'));
    //             }
    //         }
    //     }
    //     List<Map<String, Object>> attendees = new List<Map<String, Object>>();
    //     Set<String> allowedStatuses = new Set<String>{'Registered', 'Attended', 'Absent'};
    
    //     if(gcalEvent.Contains_Owner__c){
    //         // we no longer add the owner as default, but we still use contains owners for session guests
    //         // attendees.add(new Map<String, Object>{
    //         //     'email' => gcalEvent.Owner.Email,
    //         //     'displayName' => gcalEvent.Owner.Name,
    //         //     'responseStatus' => 'accepted'
    //         // });

    //         for(Session_Guest__c sg : [SELECT Id, Learner_Profile__r.Name, Learner_Profile__r.Primary_Email__c
    //                                FROM Session_Guest__c
    //                                WHERE Session__c =: gcalEvent.Session__c
    //                                WITH USER_MODE]){
    //             String status = 'needsAction';
                
    //             if(attendeeStatusByEmail.containsKey(sg.Learner_Profile__r.Primary_Email__c)){
    //                 status = attendeeStatusByEmail.get(sg.Learner_Profile__r.Primary_Email__c);
    //             }
                
    //             attendees.add(new Map<String, Object>{
    //                 'email' => sg.Learner_Profile__r.Primary_Email__c,
    //                 'displayName' => sg.Learner_Profile__r.Name,
    //                 'responseStatus' => status
    //             });            
    //         }
    //     }
        
    //     //rebuild attendees list as theres no way to only add attendees in a PATCH
    //     for(Assigned_Session__c a : [SELECT Id, Learner_Profile__r.Name, Learner_Profile__r.Primary_Email__c, Learner_Profile__r.User__c,
    //                                   Session__c, Status__c, GCal_Response__c
    //                            FROM Assigned_Session__c
    //                            WHERE Status__c =: allowedStatuses
    //                            // AND Cancelled__c = false
    //                            AND GCal_Event__r.GCal_Event_Id__c =: gcalEventId
    //                            WITH USER_MODE]){
    //         String eventStatus = a.Status__c;
    //         String status = 'needsAction';
            
    //         if(attendeeStatusByEmail.containsKey(a.Learner_Profile__r.Primary_Email__c)){
    //             status = attendeeStatusByEmail.get(a.Learner_Profile__r.Primary_Email__c);
    //             // if a user uses event's REGISTER button to register instead for gcal invite
    //             if(status == 'needsAction' && eventStatus == 'Registered') {
    //                 status = 'accepted';
    //             }                
    //         } else if(eventStatus == 'Registered'){
    //             status = 'accepted';                
    //         } else if(eventStatus == 'Invited') { 
    //             status = 'needsAction';                
    //         }
            
    //         attendees.add(new Map<String, Object>{
    //             'email' => a.Learner_Profile__r.Primary_Email__c,
    //             'displayName' => a.Learner_Profile__r.Name,
    //             'responseStatus' => status
    //         });            
    //     }
        
    //     Map<String, Object> payload = new Map<String, Object>{
    //        'attendees' => attendees
    //     };
    //     HttpResponse res = utilities.makeNCCallout(endPoint, 'PATCH', JSON.serialize(payload), headers);
    //     if(res.getStatusCode() != 201 && res.getStatusCode() != 200){
    //         returnPayload.put('body', res.getbody());
    //         returnPayload.put('success', false);
    //         returnPayload.put('error', 'Failed to update GCal Event with attendee');            
    //     }
    
    //     return returnPayload;
    // }

    // @AuraEnabled
    // public static ResponseData deleteGCalEvents(Id parentId){
    //     ResponseData rd = new ResponseData();

    //     try {
    //         Boolean hasMore = false;
    //         String sObjectType = parentId.getSObjectType() + '';
    //         String soqlQuery = 'SELECT Id, GCal_Event_Id__c' +
    //                            ' FROM GCal_Event__c' +
    //                            ' WHERE {0} = :parentId' +
    //                            ' LIMIT 90';

    //         soqlQuery = String.format(soqlQuery, new List<String>{sObjectType});
    //         List<GCal_Event__c> gcalEvents = Database.query(soqlQuery);
    //         List<GCal_Event__c> gcalEventsToDelete = new List<GCal_Event__c>();
    //         Map<String, Object> errors = new Map<String, Object>();
    //         Map<String, String> headers = new Map <String, String> {
    //             'Content-Type' => 'application/json'
    //         };

    //         for(GCal_Event__c gcalEvent : gcalEvents){
    //             if(gcalEvent.GCal_Event_Id__c == null){
    //                 gcalEventsToDelete.add(gcalEvent);
    //                 continue;
    //             }

    //             String endPoint = Constants.GCAL_EVENTS_ENDPOINT + '/' + gcalEvent.GCal_Event_Id__c + '?sendUpdates=all';
    //             HttpResponse res = Utilities.makeNCCallout(endPoint, 'DELETE', headers);
                
    //             if(res.getStatusCode() != 204){
    //                 errors.put(gcalEvent.Id, res.getBody());
    //                 rd.addError('Failed to delete event from calendar');
    //             } else {
    //                 gcalEventsToDelete.add(gcalEvent);
    //             }

    //             if(Limits.getCallouts() == Limits.getLimitCallouts()){
    //                 hasMore = true;
    //             }
    //         }

    //         rd.put('hasMore', hasMore);

    //         if(!errors.isEmpty()){
    //             rd.put('errors', errors);
    //         }
            
    //         if(!gcalEventsToDelete.isEmpty()){
    //             delete gcalEventsToDelete;
    //         }
    //     } catch(Exception e){
    //         rd.addError(e);
    //     }

    //     return rd;
    // }
}