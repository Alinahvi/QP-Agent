public with sharing class AssignedSessionTriggerHelper {
    public static void checkCompletedAssignedSession(Map<Id, Assigned_Session__c> oldMap, Map<Id, Assigned_Session__c> newMap) {
        List<String> assignmentIds = new List<String>();

        for(Assigned_Session__c aSession : newMap.values()) {
            Assigned_Session__c oldASession = oldMap?.get(aSession.Id);

            if(aSession.Status__c == 'Attended' || aSession.Status__c == 'Exempt'){
                if(oldASession == null) {
                    assignmentIds.add(aSession.Assignment__c);
                } else if (aSession.Status__c != oldASession.Status__c) {
                    assignmentIds.add(aSession.Assignment__c);
                }

            }
        }
        
        if(!assignmentIds.isEmpty()) {
            List<Assignment__c> assignmentToUpdate = new List<Assignment__c>();

            for(Assignment__c assignment : [SELECT Id, Asset__c, Mandatory_Session_Count__c, Completed_Session_Count__c,
                                            Completed__c, Completion_Date__c
                                            FROM Assignment__c 
                                            WHERE Id =: assignmentIds
                                            WITH USER_MODE]) {
                if(assignment.Completed_Session_Count__c == null) {
                    assignment.Completed_Session_Count__c = 1;
                } else {
                    assignment.Completed_Session_Count__c++;
                }

                Decimal mandatorySessionCount = assignment.Mandatory_Session_Count__c != null ? assignment.Mandatory_Session_Count__c : 1;
                                                
                if(assignment.Completed_Session_Count__c >= mandatorySessionCount && assignment.Completed__c == false) {
                    assignment.Completed__c = true;
                }

                assignmentToUpdate.add(assignment);
            }

            if(!assignmentToUpdate.isEmpty()) {
                try {
                    update as user assignmentToUpdate;
                } catch(Exception e) {
                    System.debug('Exception :: AssignedSessionTriggerHelper :: checkCompletedAssignedSession :: ' + e.getStackTraceString());
                    System.debug('Exception :: Line No ::  ' + e.getLineNumber());
                }    
            }
        }       
    }

    public static void sendCancelledSessionNotification(Map<Id, Assigned_Session__c> oldMap) {
        Map<String, Assigned_Session__c> assignmentMap = new Map<String, Assigned_Session__c>();
        List<Id> aSessionIds = new List<Id>();
        for(Assigned_Session__c data : oldMap.values()) {
            if(!data.Self_Registered__c && data.Status__c == 'Registered') {
                aSessionIds.add(data.Id);
            }
        }

        if(!aSessionIds.isEmpty()) {
            for(Assigned_Session__c aSession : [SELECT Id, Status__c, Learner_Profile__r.Name, Learner_Profile__r.SlackId__c, 
                                                Learner_Profile__r.User__r.FirstName, Session__r.Start_Date__c, 
                                                Session__r.Start_Time__c, Session__r.End_Time__c, Session__r.End_Date__c,
                                                Session__r.Name, Session__r.Start_Time_Converted__c, Session__r.End_Time_Converted__c,
                                                Asset__r.Name, Session__r.Description__c, Asset__r.Content_Owner_Organization__c,
                                                Asset__r.Time_Estimate__c
                                                FROM Assigned_Session__c 
                                                WHERE ID IN: aSessionIds
                                                AND Learner_Profile__r.SlackId__c != NULL
                                                WITH USER_MODE]) {
                assignmentMap.put(aSession.Id, aSession);
            }
            Map<String, String> metaInfo = new Map<String, String> {
                'type' => 'AssignedSession',
                'action' => 'session-cancelled'
            };

            if(System.isQueueable()){
                new SlackQueueableNotification(metaInfo, (Map<String, Object>)assignmentMap).execute(null);
            } else {
                System.enqueueJob(new SlackQueueableNotification(metaInfo, (Map<String, Object>)assignmentMap));
            }
        }        
       
    }

    public static void createLearningHistories(List<Assigned_Session__c> triggerNew, Map<Id, Assigned_Session__c> triggerOld) {
        List<Learning_History__c> learningHistories = new List<Learning_History__c>();

        List<Assigned_Session__c> aSessionsWithData = [SELECT Id, Status__c, Content_Distribution_Organization__c, 
                                                        Registration_Date_Time__c, Self_Registered__c, OU_Leader__c, Assignment__r.Self_Assigned__c
                                                        FROM Assigned_Session__c 
                                                        WHERE Id IN: triggerNew
                                                        WITH USER_MODE];
        
        for(Assigned_Session__c aSession : aSessionsWithData) {
            Assigned_Session__c oldASession = triggerOld.get(aSession.Id);

            if(aSession.Status__c == 'Unregistered' && oldASession.Status__c != 'Unregistered') {
                System.debug('*************** aSessionsWithData ' + aSession.Assignment__r.Self_Assigned__c);

                Learning_History__c learningHistory = new Learning_History__c(
                    Assigned_Session__c = aSession.Id,
                    Assigning_Org__c = aSession.Content_Distribution_Organization__c,
                    Assigned_On__c = aSEssion.Registration_Date_Time__c.dateGMT(),
                    Unenrollment_Date__c = Date.today(),
                    Self_Assigned__c = aSession.Assignment__r.Self_Assigned__c
                );

                if(aSession.Content_Distribution_Organization__c == 'OU Leader'){
                    learningHistory.Leader__c = aSession.OU_Leader__c;
                }

                learningHistories.add(learningHistory);
            }
        }

        if(!learningHistories.isEmpty()) {
            insert learningHistories;
        }
    }
    
    /*
    * Depricated: moved session attended code from trigger to flow - ACT: Session Attended Notification 
    */
    // public static void sendAttendedSurveyNotification(Map<Id, Assigned_Session__c> newMap) {
    //     sendAttendedSurveyNotification(newMap, null);
    // }

    // public static void sendAttendedSurveyNotification(Map<Id, Assigned_Session__c> newMap, Map<Id, Assigned_Session__c> oldMap) {
    //     List<Id> attendedIds = new List<Id>();
    //     for(Assigned_Session__c aSession : newMap.values()) {
    //         if(aSession.Status__c == 'Attended' && oldMap == null) {
    //             attendedIds.add(aSession.Id);
    //         } else if(aSession.Status__c == 'Attended' && (oldMap.get(aSession.Id).Status__c) != aSession.Status__c){
    //             attendedIds.add(aSession.Id);
    //         }
    //     }
        
    //     if(!attendedIds.isEmpty()) {
    //         attendedSurveyNotification(attendedIds);
    //     }
    // }
    
    // public static void attendedSurveyNotification(List<Id> aSessionId) {
    //     Map<String, Object> assignmentMap = new Map<String, Object>();
    //     for(Assigned_Session__c aSession : [SELECT Id, Status__c, Learner_Profile__r.Name, Learner_Profile__r.SlackId__c, 
    //                                         Learner_Profile__r.User__r.FirstName, Session__r.Start_Date__c, 
    //                                         Session__r.Start_Time__c, Session__r.End_Time__c, Session__r.End_Date__c,
    //                                         Session__r.Name, Session__r.Start_Time_Converted__c, Session__r.End_Time_Converted__c,
    //                                         Session__r.Survey_URL__c
    //                                         FROM Assigned_Session__c 
    //                                         WHERE ID IN: aSessionId
    //                                         AND Learner_Profile__r.SlackId__c != NULL
    //                                         AND Session__r.Send_Survey_Notification__c = TRUE
    //                                         WITH USER_MODE]) {
    //         assignmentMap.put(aSession.Id, aSession);
    //     }
        
    //     Map<String, String> metaInfo = new Map<String, String> {
    //         'type' => 'AssignedSession',
    //         'action' => 'session-attended'
    //     };

    //     System.enqueueJob(new SlackQueueableNotification(metaInfo, (Map<String, Object>)assignmentMap));
    // }

    // public static void checkForRegistrationChange(Map<Id, Assigned_Session__c> oldMap, List<Assigned_Session__c> newSessions) {
    //     List<String> openSessionIds = new List<String>();

    //     for(Assigned_Session__c aSession : newSessions) {
    //         Assigned_Session__c oldASession = oldMap.get(aSession.Id);

    //         if(aSession.Status__c != 'Registered' && oldASession.Status__c == 'Registered')) {
    //             //grab from old session in case we're unregsitering
    //             openSessionIds.add(oldASession.Session__c);
    //         }
    //     }

    //     if(!openSessionIds.isEmpty()) {
    //         registerWaitlisters(openSessionIds)
    //     }
    // }

    // public static void checkForRegistrationChange(List<Assigned_Session__c> deletedSessions) {
    //     List<String> openSessionIds = new List<String>();

    //     for(Assigned_Session__c aSession : deletedSessions) {
    //         if(aSession.Status__c == 'Registered') {
    //             //grab from old session in case we're unregsitering
    //             openSessionIds.add(aSession.Session__c);
    //         }
    //     }
    //     System.debug('*************** ' + openSessionIds);
    //     if(!openSessionIds.isEmpty()) {
    //         registerWaitlisters(openSessionIds);
    //     }
    // }

    // public static void registerWaitlisters(List<String> openSessionIds) {
    //     Map<String, Decimal> openSlotsBySessionAndType = new Map<String, Decimal>();

    //     for(Session__c session : [SELECT Id, Session_Type__c, Physical_Capacity__c, Virtual_Capacity__c,
    //                                     (SELECT Id FROM Assigned_Sessions__r WHERE Status__c = 'Registered') 
    //                               FROM Session__c 
    //                               WHERE Id IN: openSessionIds
    //                               WITH USER_MODE]) {
    //         System.debug('*************** session ' + session.Assigned_Sessions__r.size());
    //         System.debug('*************** session ' + session.Assigned_Sessions__r);
    //         if(session.Session_Type__c == 'Virtual' || session.Session_Type__c == 'Hybrid') {
    //             String virtualKey = session.Id + '|' + 'Virtual';
    //             if(session.Virtual_Capacity__c != null){
    //                 openSlotsBySessionAndType.put(virtualKey, session.Virtual_Capacity__c - session.Assigned_Sessions__r.size());
    //             } else {
    //                 openSlotsBySessionAndType.put(virtualKey, null);
    //             }
    //         }
            
    //         if(session.Session_Type__c == 'Physical' || session.Session_Type__c == 'Hybrid'){
    //             String physicalKey = session.Id + '|' + 'Physical';

    //             if(session.Physical_Capacity__c != null){
    //                 openSlotsBySessionAndType.put(physicalKey, session.Physical_Capacity__c - session.Assigned_Sessions__r.size());
    //             } else {
    //                 openSlotsBySessionAndType.put(physicalKey, null);
    //             }
    //         }
    //     }
    //     System.debug('*************** openSlotsBySessionAndType ' + openSlotsBySessionAndType);
    //     List<Assigned_Session__c> updatedAssignedSessions = new List<Assigned_Session__c>();
        
    //     for(Session__c session : [SELECT Id, Session_Type__c, Physical_Capacity__c, Virtual_Capacity__c,
    //                                     (
    //                                         SELECT Id, Queue_Position__c, Registration_Type__c, Status__c
    //                                         FROM Assigned_Sessions__r 
    //                                         WHERE Status__c = 'Waitlisted'
    //                                         ORDER BY Queue_Position__c ASC
    //                                     ) 
    //                               FROM Session__c 
    //                               WHERE Id IN: openSessionIds
    //                               WITH USER_MODE]) {

    //         Integer physicalQueuePosition = 1;
    //         Integer virtualQueuePosition = 1;

    //         for(Assigned_Session__c aSession : session.Assigned_Sessions__r){
    //             String key = session.Id + '|' + aSession.Registration_Type__c;
    //             Decimal openSlots = openSlotsBySessionAndType.get(key);
    //             System.debug('*************** key ' + key);
    //             System.debug('*************** openSlots ' + openSlots);
    //             // if(aSession.Registration_Type__c == 'Virtual') {
    //             //     key = session.Id + 'Virtual';
    //             //     openSlots = openSlotsBySession.get(virtualKey);
    //             // } else if(aSession.Registration_Type__c == 'Physical'){
    //             //     key = session.Id + 'Physical';
    //             //     openSlots = openSlotsBySession.get(physicalKey);
    //             // }

    //             if(openSlotsBySessionAndType.containsKey(key) && (openSlots == null || openSlots > 0)){
    //                 aSession.Status__c = 'Registered';
    //                 aSession.Queue_Position__c = null;
    //                 aSession.Send_Registration_Email__c = true;

    //                 if(openSlots != null){
    //                     openSlotsBySessionAndType.put(key, openSlots - 1);
    //                 }
    //             } else { // we hit capacity so redo the queue
    //                 if(aSession.Registration_Type__c == 'Virtual') {
    //                     aSession.Queue_Position__c = virtualQueuePosition;
    //                     virtualQueuePosition++;
    //                 } else if(aSession.Registration_Type__c == 'Physical'){
    //                     aSession.Queue_Position__c = physicalQueuePosition;
    //                     physicalQueuePosition++;
    //                 }
    //             }
    //         }

    //         updatedAssignedSessions.addAll(session.Assigned_Sessions__r);
    //     }

    //     System.debug('*************** updatedAssignedSessions ' + updatedAssignedSessions);
    //     //update updatedAssignedSessions;
    // }
}