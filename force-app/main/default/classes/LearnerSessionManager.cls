public with sharing class LearnerSessionManager {
    public static Boolean hasWaitlisted = false;
    public static Learner_Profile__c lp {
        get {
            return [SELECT Id, User__c
                    FROM Learner_Profile__c
                    WHERE User__c =: UserInfo.getUserId()
                    AND Status__c = 'Active'
                    WITH USER_MODE]; 
        }
    }

    @AuraEnabled
    public static ResponseData registerToAllSessions(String jsonString) {
        ResponseData rd = new ResponseData();
        
        try {
            RegistrationPayload payload = (RegistrationPayload) JSON.deserialize(jsonString, RegistrationPayload.class);
            Id sourceId = payload.sourceId;
            String sObjectType = sourceId.getSObjectType() + '';
            Map<String, String> registrationTypeBySessionId = new Map<String, String>();

            for (SessionRegistration registration : payload.registrations) {
                registrationTypeBySessionId.put(registration.sessionId, registration.registrationType);
            }

            Assignment__c assignment;

            if (sObjectType == 'Asset__c'){
                Learner_Profile__c lp = [SELECT Id, User__c
                                         FROM Learner_Profile__c
                                         WHERE User__c =: UserInfo.getUserId()
                                         AND Status__c = 'Active'
                                         WITH USER_MODE];

                Asset__c asset = [SELECT Id, Event_Type__c, Mandatory_Session_Count__c, Time_Estimate_Minutes__c, Assessor_Type__c, RecordType.DeveloperName,
                                         (
                                            SELECT Id, Course__r.Name
                                            FROM Course_Assets__r
                                            LIMIT 1
                                         )
                                  FROM Asset__c
                                  WHERE Id =: payload.sourceId
                                  WITH USER_MODE];

                List<Assignment__c> assignments = [SELECT Asset__r.Event_Type__c, Mandatory_Session_Count__c,
                                                          (
                                                              SELECT Id
                                                              FROM Assigned_Sessions__r
                                                              WHERE Status__c = 'Registered' OR Status__c = 'WaitListed'
                                                          )
                                                    FROM Assignment__c
                                                    WHERE Asset__c =: payload.sourceId
                                                    AND Completed__c = false
                                                    AND Inactive__c = false
                                                    AND Learner_Profile__c =: lp.Id
                                                    WITH USER_MODE
                                                    ORDER BY CreatedDate DESC
                                                    LIMIT 1];
                if(assignments.isEmpty() && asset.Event_Type__c == 'Course'){
                    String errMsg = 'Please enroll into the course first in order to enroll in this event.'; 

                    if(!asset.Course_Assets__r.isEmpty()){
                        errMsg = ' You must enroll in ' + asset.Course_Assets__r[0].Course__r.Name + ' in order to enroll in this event.';
                    }

                    rd.addError(errMsg);
                    return rd;
                } else if(assignments.isEmpty()){
                    Assignment__c newAssignment = AssignmentBatchHelper.createStubAssignment(lp, null, null, null, asset, null, null, null, false);
                    
                    newAssignment.Self_Assigned__c = true;

                    insert as user newAssignment;
                    //requery for lookup data
                    assignment = getAssignmentData(newAssignment.Id);
                } else {
                    assignment = assignments[0];
                }
            } else if (sObjectType == 'Assignment__c'){
                assignment = assignment = getAssignmentData(sourceId);
            } else {
                rd.addError('Record Id needs to be an Asset or Assignment');
                return rd;
            }

            rd.put('assignedSessions', createAssignedSessions(assignment.Id, registrationTypeBySessionId, true));
            rd.put('hasWaitlisted', hasWaitlisted);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public static Assignment__c getAssignmentData(String assignmentId){
        return [SELECT Asset__r.Event_Type__c, Mandatory_Session_Count__c,
                        (
                            SELECT Id
                            FROM Assigned_Sessions__r
                            WHERE Status__c = 'Registered' OR Status__c = 'WaitListed'
                        )
                FROM Assignment__c
                WHERE Id =: assignmentId
                AND Inactive__c = false
                WITH USER_MODE];
    }

    // public static Id createAssignment() {
    //     Assignment__c newAssignment = new Assignment__c(
    //         Learner_Profile__c = lp.Id,
    //         OwnerId = lp.User__c,
    //         Asset__c=assigned_session[0].Asset__c
    //     );
    // }
    
    public static List<Assigned_Session__c> createAssignedSessions(String assignmentId, Map<String, String> registrationTypeBySessionId, Boolean selfRegistered) {
        hasWaitlisted = false;

        List<Assigned_Session__c> existingAssignedSession = [SELECT Id
                                                             FROM Assigned_Session__c
                                                             WHERE Assignment__c = :assignmentId
                                                             AND Session__c = :registrationTypeBySessionId.keyset()
                                                             AND Learner_Profile__c = :lp.Id
                                                             AND Status__c = 'Registered'
                                                             WITH USER_MODE];

        if (!existingAssignedSession.isEmpty()) {
            throw new Utilities.customException('You are already registered to this session. Please refresh to see the latest data');
        }

        List<Session__c> sessions = [SELECT Id, Physical_Capacity__c, Virtual_Capacity__c, Asset__c, Session_Type__c, Physical_Registered_Guests__c,
                                            Virtual_Registered_Guests__c, Physical_Waitlisters__c, Virtual_Waitlisters__c,
                                            (
                                                SELECT Id 
                                                FROM Assigned_Sessions__r
                                                WHERE Status__c = 'Unregistered'
                                            )
                                     FROM Session__c
                                     WHERE Id IN :registrationTypeBySessionId.keyset()
                                     WITH USER_MODE];

        Map<String, Integer> waitlistBySessionType = new Map<String, Integer>();

        for(Session__c session : [SELECT Id, Physical_Capacity__c, Virtual_Capacity__c, Asset__c, Session_Type__c,
                                                            (
                                                                SELECT Id, Registration_Type__c
                                                                FROM Assigned_Sessions__r
                                                                WHERE Status__c = 'Waitlisted'
                                                            )
                                                   FROM Session__c
                                                   WHERE Id IN :registrationTypeBySessionId.keyset()
                                                   WITH USER_MODE]){
             
            if(session.Session_Type__c == 'Hybrid'){
                Integer physicalWaitlist = 0;
                Integer virtualWaitlist = 0;

                for(Assigned_Session__c aSession : session.Assigned_Sessions__r){
                    if(aSession.Registration_Type__c == 'Physical'){
                        physicalWaitlist++;
                    } else if(aSession.Registration_Type__c == 'Virtual'){
                        virtualWaitlist++;
                    }
                }

                waitlistBySessionType.put(session.Id + '|Physical', physicalWaitlist);
                waitlistBySessionType.put(session.Id + '|Virtual', virtualWaitlist);
            } else {
                waitlistBySessionType.put(session.Id + '|' + session.Session_Type__c, session.Assigned_Sessions__r.size());
            }
        }

                                

        List<Assigned_Session__c> assignedSessions = new List<Assigned_Session__c>();

        for (Session__c session : sessions){
            Assigned_Session__c assignedSession = new Assigned_Session__c(
                Assignment__c = assignmentId,
                Session__c = session.Id,
                Asset__c = session.Asset__c,
                Learner_Profile__c = lp.Id,
                Registration_Date_Time__c = DateTime.now(),
                Self_Registered__c = selfRegistered,
                Status__c = 'Registered',
                Registration_Type__c = registrationTypeBySessionId.get(session.Id)
            );

            if(!session.Assigned_Sessions__r.isEmpty()){
                assignedSession.Id = session.Assigned_Sessions__r[0].Id;
            }

            switch on assignedSession.Registration_Type__c {
                when 'Physical' {
                    if (session.Physical_Capacity__c != null && (session.Physical_Capacity__c - session.Physical_Registered_Guests__c <= 0)) {
                        Integer queuePosition = waitlistBySessionType.get(session.Id + '|Physical') + 1;

                        assignedSession.Queue_Position__c = queuePosition;
                        assignedSession.Status__c = 'Waitlisted';
                        hasWaitlisted = true;

                        waitlistBySessionType.put(session.Id + '|Physical', queuePosition);
                    }
                }
                when 'Virtual' {
                    if (session.Virtual_Capacity__c != null && (session.Virtual_Capacity__c - session.Virtual_Registered_Guests__c <= 0)) {
                        Integer queuePosition = waitlistBySessionType.get(session.Id + '|Virtual') + 1;

                        assignedSession.Queue_Position__c = queuePosition;
                        assignedSession.Status__c = 'Waitlisted';
                        hasWaitlisted = true;

                        waitlistBySessionType.put(session.Id + '|Virtual', queuePosition);
                    }
                }

                // when 'Hybrid' {
                //     if ((assignedSession.Registration_Type__c.equals('Physical') && SessionManager.physicalCapacityReached(session)) || 
                //         (assignedSession.Registration_Type__c.equals('Virtual') && SessionManager.virtualCapacityReached(session))) {

                //         assignedSession.Status__c = 'Waitlisted';
                //         hasWaitlisted = true;
                //     }
                // }
            }

            if (!assignedSession.Status__c.equals('Waitlisted')) {
                assignedSession.Send_Registration_Email__c = true;
            }

            assignedSessions.add(assignedSession);
        }

        upsert as user assignedSessions;

        return assignedSessions;
    }

    @AuraEnabled
    public static ResponseData unregisterToSession(String assignedSessionId){
        ResponseData rd = new ResponseData();
        
        try {
            Assigned_Session__c aSession = [SELECT Id, Status__c FROM Assigned_Session__c WHERE Id =: assignedSessionId WITH USER_MODE];

            aSession.Status__c = 'Unregistered';

            update aSession;
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public class RegistrationPayload {
        public List<SessionRegistration> registrations { get; set; }
        public Id sourceId { get; set; }

    }

    public class SessionRegistration {
        public String sessionId { get; set; }
        public String registrationType { get; set; }
    }
}