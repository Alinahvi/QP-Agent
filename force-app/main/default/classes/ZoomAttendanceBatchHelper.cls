public with sharing class ZoomAttendanceBatchHelper {
    public static String zoomType = 'meetings';
    public static List<Integration_Error__c> errors;
    public static Map<String, Map<String, Object>> participantByEmail;
    public static List<String> userSessionIds;
    public static String sessionId;
    public static String meetingId;
    public static String hostId;

    /*
        Recieves a single of Session__c or Enablement_Activities__c.
        We'll need to get the participant report from the zoom api and then create Session_Attendances for them.
        If the participant email also matches an assignment we need to update the Registration_Status__c to atteneded.
    */
    public static void processReport(List<sObject> zoomEvents){
        try{
            sObject parent = zoomEvents.get(0);
            System.debug('************* parent ' + parent);
            sessionId = (String)parent.get('Id');
            zoomType = (String)parent.get('Zoom_Type__c') == 'Meeting' ? 'meetings' : 'webinars';
            errors = new List<Integration_Error__c>();
            meetingId = (String)parent.get('Zoom_Session_Id__c');
            hostId = (String)parent.get('Zoom_Host_Id__c');
            userSessionIds = new List<String>(); //the unique user session id, not the user_id
            
            Map<String, Map<String, Object>> participantByEmail = getParticipants();
            System.debug('********** participantByEmail ' + participantByEmail);
            //if no participants then the report isn't ready. Uptick the retry to that it'll get processed
            //by the next batch.
            if(participantByEmail.isEmpty()){
                Integer newRetryTotal = 0;
                Object currentRetryTotal = parent.get('Total_Zoom_Report_Retries__c');
    
                if(currentRetryTotal != null){
                    newRetryTotal = Integer.valueOf(currentRetryTotal) + 1;
                }
    
                parent.put('Total_Zoom_Report_Retries__c', newRetryTotal);
                
                update parent;
                return;
            }
    
            List<Session_Attendance__c> attendancesToUpsert = new List<Session_Attendance__c>();
            List<Assigned_Session__c> assignedSessionsToUpdate = new List<Assigned_Session__c>();
            Map<String, Learner_Profile__c> lpByEmail = new Map<String, Learner_Profile__c>();
            Map<String, Learner_Profile__c> assignmentByEmail = new Map<String, Learner_Profile__c>();
            Map<String, Learner_Profile__c> attendnaceByZoomUserSessionId = new Map<String, Learner_Profile__c>();
            List<Session_Attendance__c> attendances = [SELECT Id, Learner_Profile__c, Join_Time__c, Leave_Time__c, Duration_In_Minutes__c, 
                                                              Assignment__c, Zoom_User_Session_Id__c, Email__c, Status__c, Session__c
                                                       FROM Session_Attendance__c
                                                       WHERE Session__c =: sessionId
                                                       AND Zoom_User_Session_Id__c =: userSessionIds
                                                       WITH USER_MODE];

            //if a meeting ended a second time update existing ones to the new values
            for(Session_Attendance__c sa : attendances){
                if(!participantByEmail.containsKey(sa.Email__c)){
                    continue;
                }
    
                Map<String, Object> participant = participantByEmail.get(sa.Email__c);
                Decimal duration = ((Integer)participant.get('duration')) / 60.0;
                participantByEmail.remove(sa.Email__c);
    
                String joinTime = ((String)participant.get('join_time')).replace('T', ' ');
                String leaveTime = ((String)participant.get('leave_time')).replace('T', ' ');
                sa.Join_Time__c = DateTime.valueOfGMT(joinTime);
                sa.Leave_Time__c = DateTime.valueOfGMT(leaveTime);
                sa.Duration_In_Minutes__c = Integer.valueOf(Math.ceil(duration));
            }
    
            for(Learner_Profile__c lp : [SELECT Id, User__c, Primary_Email__c 
                                         FROM Learner_Profile__c 
                                         WHERE Primary_Email__c =: participantByEmail.keySet() 
                                         AND Status__c = 'Active' 
                                         WITH USER_MODE]){
                lpByEmail.put(lp.Primary_Email__c, lp);
            }
    
            //associate assignments to the new participants and mark them as completed
            for(Assigned_Session__c assignedSession : [SELECT Id, Learner_Profile__c, Learner_Profile__r.Primary_Email__c, Learner_Profile__r.User__c,
                                                              Status__c, Session__c, Assignment__c
                                            FROM Assigned_Session__c
                                            WHERE Learner_Profile__c =: lpByEmail.values()
                                            AND Session__c =: sessionId
                                            WITH USER_MODE]){

                if(participantByEmail.containsKey(assignedSession.Learner_Profile__r.Primary_Email__c)){
                    Map<String, Object> participant = participantByEmail.get(assignedSession.Learner_Profile__r.Primary_Email__c);
                    participantByEmail.remove(assignedSession.Learner_Profile__r.Primary_Email__c);
                    String joinTime = ((String)participant.get('join_time')).replace('T', ' ');
                    String leaveTime = ((String)participant.get('leave_time')).replace('T', ' ');
    
                    Session_Attendance__c sa = new Session_Attendance__c(
                        OwnerId = assignedSession.Learner_Profile__r.User__c,
                        Assigned_Session__c = assignedSession.Id,
                        Assignment__c = assignedSession.Assignment__c,
                        Learner_Profile__c = assignedSession.Learner_Profile__c,
                        Join_Time__c = DateTime.valueOfGMT(joinTime),
                        Leave_Time__c = DateTime.valueOfGMT(leaveTime),
                        Duration_In_Minutes__c = ((Integer)participant.get('duration')) / 60,
                        Status__c = 'Valid',
                        Zoom_User_Session_Id__c = (String)participant.get('id'),
                        Email__c = assignedSession.Learner_Profile__r.Primary_Email__c,
                        Session__c = sessionId
                    );
                    
                    assignedSession.Status__c = 'Attended';
                    attendances.add(sa);
                    assignedSessionsToUpdate.add(assignedSession);
                }
            }

            List<Assignment__c> noInviteEventAssignments = new List<Assignment__c>();
            List<Assigned_Session__c> noInviteAssignedSessions = new List<Assigned_Session__c>();
            List<Session_Attendance__c> noInviteSessionAttendances = new List<Session_Attendance__c>();
            // String eaRecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByDeveloperName().get('Enablement_Activity').getRecordTypeId();

            Session__c session = [SELECT Id, Asset__c, Asset__r.Time_Estimate_Minutes__c, Asset__r.Mandatory_Session_Count__c, Asset__r.Assessor_Type__c, Asset__r.RecordType.DeveloperName
                                  FROM Session__c 
                                  WHERE Id =: sessionId];
            
            Map<String, Assignment__c> assignmentByLPId = new Map<String, Assignment__c>();

            for(Assignment__c a : [SELECT Id, Learner_Profile__c 
                                   FROM Assignment__c 
                                   WHERE Learner_Profile__c =: lpByEmail.values()
                                   AND Completed__c = false
                                   AND Asset__c =: session.Asset__c
                                   WITH USER_MODE]){
                assignmentByLPId.put(a.Learner_Profile__c, a);
            }
            
            //remainders will still need to be tracked, but will be marked invalid
            for(String email : participantByEmail.keySet()){
                Map<String, Object> participant = participantByEmail.get(email);
                String joinTime = ((String)participant.get('join_time')).replace('T', ' ');
                String leaveTime = ((String)participant.get('leave_time')).replace('T', ' ');
                Learner_Profile__c lp;
                
                if(lpByEmail.containsKey(email)){
                    lp = lpByEmail.get(email);
                }
    
                Session_Attendance__c sa = new Session_Attendance__c(
                    Learner_Profile__c = lp?.Id,
                    Join_Time__c = DateTime.valueOfGMT(joinTime),
                    Leave_Time__c = DateTime.valueOfGMT(leaveTime),
                    Duration_In_Minutes__c = ((Integer)participant.get('duration')) / 60,
                    Status__c = String.isEmpty(lp?.Id) ? 'No Learner Profile Found' : 'No Assignment Found',
                    Zoom_User_Session_Id__c = (String)participant.get('id'),
                    Email__c = email,
                    Session__c = sessionId
                );
                
                if(String.isNotEmpty(lp?.Id)){
                    sa.OwnerId = lp.User__c;
                    sa.Status__c = 'Valid';
                    attendnaceByZoomUserSessionId.put((String)participant.get('id'), lp);                                                                 
                    Assignment__c assignment = assignmentByLPId.containsKey(lp.Id) ? assignmentByLPId.get(lp.Id) : AssignmentBatchHelper.createStubAssignment(lp, null, null, null, session.Asset__r, null, null, null, true);

                    Assigned_Session__c newAssignedSession = new Assigned_Session__c(
                        Asset__c = session.Asset__c,
                        //OwnerId = lp.User__c,
                        Registration_Date_Time__c = DateTime.now(),
                        Self_Registered__c = true,
                        Session__c = session.Id,
                        Learner_Profile__c = lp.Id,
                        Registration_Type__c = 'Virtual',
                        Status__c = 'Attended'
                    );

                    if(assignment.Id != null){
                        newAssignedSession.Assignment__c = assignment.Id;
                        sa.Assignment__c = assignment.Id;
                    } else {
                        newAssignedSession.Assignment__r = assignment;
                        sa.Assignment__r = assignment;
                        noInviteEventAssignments.add(assignment);
                    }
                    
                    sa.Assigned_Session__r = newAssignedSession;
                    noInviteAssignedSessions.add(newAssignedSession);
                    noInviteSessionAttendances.add(sa);
                }
                
                
                attendances.add(sa);
                //if its an Event and we have a LP mark create an assignment for them
            }
    
            attendancesToUpsert.addAll(attendances);

            if(!noInviteEventAssignments.isEmpty()){
                insert noInviteEventAssignments;
            }

            if(!noInviteAssignedSessions.isEmpty()){
                for(Assigned_Session__c assignedSession : noInviteAssignedSessions){
                    if(assignedSession.Assignment__r != null){
                        assignedSession.Assignment__c = assignedSession.Assignment__r.Id;
                        assignedSession.Assignment__r = null;
                    }
                }

                insert noInviteAssignedSessions;
            }

            if(!noInviteSessionAttendances.isEmpty()){
                for(Session_Attendance__c sa : noInviteSessionAttendances){
                    if(sa.Assignment__r != null){
                        sa.Assignment__c = sa.Assignment__r.Id;
                        sa.Assignment__r = null;
                    }

                    if(sa.Assigned_Session__r != null){
                        sa.Assigned_Session__c = sa.Assigned_Session__r.Id;
                        sa.Assigned_Session__r = null;
                    }
                }

                insert noInviteSessionAttendances;
            }

    
            if(!errors.isEmpty()){
                insert errors;
            }
            
            update assignedSessionsToUpdate;
            upsert attendancesToUpsert;
    
            parent.put('Process_Zoom_Report__c', false);
            parent.put('Total_Zoom_Report_Retries__c', 0);
    
            update parent;
        } catch(Exception e){
            Integration_Error__c errorObj = new Integration_Error__c(
                Type__c = 'Session Attendance',
                Error_Message__c = 'Failed to process Session: ' + sessionId + ' with Meeting Id: ' + meetingId + ' because ' + e.getMessage() + ' at zoomAttendanceBatchHelper',
                Http_Response_Body__c = + e.getStackTraceString()
            );

            insert errorObj;
        }
    }

    public static Map<String, Map<String, Object>> getParticipants(){
        String nextPageToken = '';
        Map<String, Map<String, Object>> participantByEmail = new Map<String, Map<String, Object>>();

        do{
            if(Limits.getCallouts() >= Limits.getLimitCallouts()){
                String objType = 'Session';

                errors.add(new Integration_Error__c(
                    Type__c = 'Session Attendance',
                    Error_Message__c = 'Failed to process all participants for ' + objType + ' ' + sessionId + '. Exceeded 100 callouts'
                ));

                break;
            }

            String url = constants.ZOOM_BASE_URL + '/report/' + zoomType + '/' + meetingId + '/participants?page_size=300';

            if(String.isNotEmpty(nextPageToken)){
                url += '&next_page_token=' + EncodingUtil.urlEncode(nextPageToken, 'UTF-8');
            }

            Map<String, String> headers = new Map<String, String>{
                'Authorization' => 'Bearer ' + utilities.getZoomAccessToken()
            };
            System.debug('************* url ' + url);
            HttpResponse participantListRes = utilities.makeCallout(url, 'GET', headers);
            Set<String> sessionGuestEmails = new Set<String>();

            for(Session_Guest__c sr : [SELECT Id, Learner_Profile__c, Learner_Profile__r.Primary_Email__c
                                      FROM Session_Guest__c
                                      WHERE Session__c =: sessionId
                                      WITH USER_MODE]){
                sessionGuestEmails.add(sr.Learner_Profile__r.Primary_Email__c);
            }

            // debugging
            // for(String key : participantListRes.getHeaderKeys()){
            //     System.debug('******** participantListRes ' + key + ' ' + participantListRes.getHeader(key));
            // }

            if(participantListRes.getStatusCode() == 200){
                Map<String, Object> participantResMap = (Map<String, Object>)JSON.deserializeUntyped(participantListRes.getBody());
                nextPageToken = (String)participantResMap.get('next_page_token');//empty if no more pages
                List<Object> participants = (List<Object>)participantResMap.get('participants');
                System.debug('************* participantResMap ' + participantResMap);
                //key participants by email
                for(Object participantObj : participants){
                    Map<String, Object> participantMap = (Map<String, Object>)participantObj;
                    String email = (String)participantMap.get('user_email');

                    //session roles attedances don't need to be tracked
                    if(sessionGuestEmails.contains(email)){
                        continue;
                    }

                    //if multiple participants with the same email exists then it means they dropped and rejoined
                    //we need to merge them into one participant
                    if(participantByEmail.containsKey(email)){
                        Map<String, Object> existingParticipant = participantByEmail.get(email);
                        String oldJoinTime = ((String)existingParticipant.get('join_time')).replace('T', ' ');
                        String oldLeaveTime = ((String)existingParticipant.get('leave_time')).replace('T', ' ');
                        DateTime oldJoinDT = DateTime.valueOfGMT(oldJoinTime);
                        DateTime oldLeaveDT = DateTime.valueOfGMT(oldLeaveTime);
                        Integer oldDuration = (Integer)existingParticipant.get('duration');
                        String newJoinTime = ((String)participantMap.get('join_time')).replace('T', ' ');
                        String newLeaveTime = ((String)participantMap.get('leave_time')).replace('T', ' ');
                        DateTime newJoinDT = DateTime.valueOfGMT(newJoinTime);
                        DateTime newLeaveDT = DateTime.valueOfGMT(newLeaveTime);
                        Integer newDuration = (Integer)participantMap.get('duration');

                        //take the oldest join time, the newest leave time, and add the durations
                        participantMap.put('join_time', newJoinDT > oldJoinDT ? oldJoinTime : newJoinTime);
                        participantMap.put('leave_time', oldLeaveDT > newLeaveDT ? oldLeaveTime : newLeaveTime);
                        participantMap.put('duration', (oldDuration + newDuration));
                    } else {
                        userSessionIds.add((String)participantMap.get('id'));
                    }

                    participantByEmail.put(email, participantMap);
                }
            } else {
                System.debug('******** participantListRes ' +  participantListRes.getStatusCode());

                for(String key : participantListRes.getHeaderKeys()){
                    System.debug('******** participantListRes ' + key + ' ' + participantListRes.getHeader(key));
                }


                //if there were no participants it results in a 404 so just ignore those
                if(participantListRes.getStatusCode() != 404){
                    String objType = 'Session';
                    errors.add(new Integration_Error__c(
                        Type__c = 'Session Attendance',
                        Error_Message__c = participantListRes.getStatusCode() + ' Failed to process all participants for ' + objType + ': ' + sessionId,
                        Http_Response_Body__c = participantListRes.getBody()
                    ));
                    
                    break;
                }
            }
        } while(String.isNotEmpty(nextPageToken));

        return participantByEmail;
    }
}