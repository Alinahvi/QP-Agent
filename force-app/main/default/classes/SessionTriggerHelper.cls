public with sharing class SessionTriggerHelper {
    public static void updateConvertedTimes(List<Session__c> newSessions, Map<Id, Session__c> oldSessionMap) {
        for (Session__c newSession : newSessions) {
            if (newSession.Start_Date__c == null && newSession.Start_Time__c == null) {
                newSession.Start_Time_Converted__c = null;
                newSession.End_Time_Converted__c = null;
            }

            Session__c oldSession = new Session__c();

            if (newSession.Id != null) {
                oldSession = oldSessionMap.get(newSession.Id);
            }

            // String sessionTZ = String.isNotEmpty(newSession.Time_Zone__c) ? newSession.Time_Zone__c : Org_Info__c.getOrgDefaults().Time_Zone__c;
            String sessionTZ = newSession.Time_Zone__c;
            Integer offSetMinutes = Timezone.getTimeZone(sessionTZ).getOffset(newSession.Start_Date__c) / 1000 / 60;

            if (newSession.Time_Zone__c != oldSession.Time_Zone__c || newSession.Start_Date__c != oldSession.Start_Date__c || newSession.Start_Time__c != oldSession.Start_Time__c || 
                newSession.End_Time__c != oldSession.End_Time__c) {
                newSession.Start_Time_Converted__c = DateTime.newInstanceGMT(newSession.Start_Date__c, newSession.Start_Time__c).addMinutes(-offSetMinutes);
                newSession.End_Date__c = newSession.Start_Date__c;
                newSession.End_Time_Converted__c = DateTime.newInstanceGMT(newSession.End_Date__c, newSession.End_Time__c).addMinutes(-offSetMinutes);
            }

            // if (newSession.Time_Zone__c != oldSession.Time_Zone__c || newSession.End_Date__c != oldSession.End_Date__c || newSession.End_Time__c != oldSession.End_Time__c) {
            //     newSession.End_Time_Converted__c = DateTime.newInstanceGMT(newSession.End_Date__c, newSession.End_Time__c).addMinutes(-offSetMinutes);
            // }
        }
    }

    public static void updateSessionTypeFields(List<Session__c> newSessions, Map<Id, Session__c> oldSessionMap) {
        for (Session__c newSession : newSessions) {
            Session__c oldSession = new Session__c();

            if (newSession.Id != null) {
                oldSession = oldSessionMap.get(newSession.Id);
            }

            // Update Session Type Fields
            switch on newSession.Session_Type__c {
                when 'Virtual' {
                    if (oldSession.Session_Type__c == 'Physical' || oldSession.Session_Type__c == 'Hybrid') {
                        // new-location 
                        // newSession.Office_Location__c = null;
                        newSession.Office_Name__c = null;
                        newSession.Room__c = null;
                        newSession.Floor__c = null;
                        newSession.Physical_Capacity__c = null;
                        // new-location
                        newSession.Location__CountryCode__s = null;
                        newSession.Location__StateCode__s = null;
                        newSession.Location__City__s = null;
                        newSession.Location__PostalCode__s = null;
                        newSession.Location__Street__s = null;
                        newSession.Location__Longitude__s = null;
                        newSession.Location__GeocodeAccuracy__s = null;
                        newSession.Location__Latitude__s = null;
                        //
                    }
                }
                when 'Physical' {
                    if (oldSession.Session_Type__c == 'Virtual' || oldSession.Session_Type__c == 'Hybrid') {
                        newSession.Virtual_Type__c = null;
                        newSession.Zoom_Host_Id__c = null;
                        newSession.Zoom_Occurrence_Id__c = null;
                        newSession.Zoom_Session_Id__c = null;
                        newSession.Zoom_Type__c = null;
                        newSession.Url__c = null;
                        newSession.Virtual_Capacity__c = null;
                    }
                }
            }
        } 
    }

    public static void markCancelledSessions(List<Session__c> newSessions, Map<Id, Session__c> oldSessionMap){
        for (Session__c newSession : newSessions) {
            Session__c oldSession = oldSessionMap.get(newSession.Id);

            if (sessionCancelled(newSession, oldSession)) {
                newSession.Cancelling_Assigned_Session__c = true;
            }
        }
    }

    public static void handleSessionUpdates(List<Session__c> newSessions, Map<Id, Session__c> oldSessionMap) {
        Set<Id> cancelledSessions = new Set<Id>();
        List<Session__c> cancelledZoomSessions = new List<Session__c>();
        Set<Id> updatedSessions = new Set<Id>();
        Set<Id> sessionsWithUpdatedTimes = new Set<Id>();
        Set<Id> updatedZoomSessions = new Set<Id>();

        // Find Sessions that need to be notified
        for (Session__c newSession : newSessions) {
            Session__c oldSession = new Session__c();

            if (newSession.Id != null) {
                oldSession = oldSessionMap.get(newSession.Id);
            }

            if (sessionCancelled(newSession, oldSession)) {
                cancelledSessions.add(newSession.Id);
                System.debug('****************** ' + newSession.Zoom_Session_Id__c);
                if(String.isNotEmpty(newSession.Zoom_Session_Id__c)){
                    cancelledZoomSessions.add(newSession);
                }
            } else if (sessionTimeUpdated(newSession, oldSession) || sessionDetailsUpdated(newSession, oldSession)) {
                updatedSessions.add(newSession.Id);
                sessionsWithUpdatedTimes.add(newSession.Id);
                
                if(newSession.Virtual_Type__c == 'Zoom' && String.isNotEmpty(newSession.Zoom_Session_Id__c)){
                    updatedZoomSessions.add(newSession.Id);
                }
            } else if (changedVirtualDetails(newSession, oldSession)){
                updatedSessions.add(newSession.Id);                
            }
            
            // handle location || floor || room change
            if(newSession.Session_Type__c != 'Virtual' && sessionLocationUpdate(newSession, oldSession)) {
                updatedSessions.add(newSession.Id);                            
            }
        }
        
        // Set<Id> sessionsToNotify = new Set<Id>();
        // sessionsToNotify.addAll(cancelledSessions);
        // sessionsToNotify.addAll(updatedSessions);
        
        // Find Related Assigned Sessions
        // List<Assigned_Session__c> assignedSessionsToNotify = [SELECT Id, Send_Updated_Registration_Email__c, Session__c FROM Assigned_Session__c WHERE Session__c IN :sessionsToNotify AND Status__c = 'Registered'];
        // List<Assigned_Session__c> assignedSessionsToDelete = new List<Assigned_Session__c>();
        // // Update Assigned Session Fields
        // for (Assigned_Session__c assignedSession : assignedSessionsToNotify) {
        //     if (cancelledSessions.contains(assignedSession.Session__c)) {
        //         assignedSessionsToDelete.add(assignedSession);
        //     } else if (updatedSessions.contains(assignedSession.Session__c)) {
        //         assignedSession.Send_Updated_Registration_Email__c = true;
        //     }
        // }

        List<Session_Guest__c> guestsToUpdate = [SELECT Id, Send_Updated_Registration_Email__c, Role__c FROM Session_Guest__c WHERE Session__c IN :updatedSessions AND Session__r.Status__c != 'Cancelled'];
        List<Session_Guest__c> guestsToDelete = [SELECT Id, Send_Updated_Registration_Email__c, Role__c FROM Session_Guest__c WHERE Session__c IN :cancelledSessions];

        for(Session_Guest__c sg : guestsToUpdate){
            if(sg.Role__c == 'Host' && SessionManager.createdHost){
                continue;
            }
            
            sg.Send_Updated_Registration_Email__c = true;
        }

        if(!guestsToUpdate.isEmpty()){
            update guestsToUpdate;
        }

        if(!guestsToDelete.isEmpty()){
            delete guestsToDelete;
        }

        if (!updatedSessions.isEmpty() || !cancelledSessions.isEmpty()) {
            System.enqueueJob(new SessionTriggerQueueable(updatedSessions, cancelledSessions));
        }

        System.debug('****************** ' + cancelledZoomSessions);
        if(!cancelledZoomSessions.isEmpty()){
            System.enqueueJob(new DeleteZoomSessionQueueable(cancelledZoomSessions));
        }

        if(!updatedZoomSessions.isEmpty()){
            System.enqueueJob(new UpdateZoomSessionQueueable(updatedZoomSessions));
        }

        if(!sessionsWithUpdatedTimes.isEmpty()){
            List<Availability__c> availabilities = [SELECT Id, Session__r.Start_Time_Converted__c, Session__r.End_Time_Converted__c, Start_Date__c, End_Date__c
                                                      FROM Availability__c 
                                                      WHERE Session__c IN :sessionsWithUpdatedTimes];
            if(!availabilities.isEmpty()){
                for(Availability__c avail : availabilities){
                    avail.Start_Date__c = avail.Session__r.Start_Time_Converted__c;
                    avail.End_Date__c = avail.Session__r.End_Time_Converted__c;
                }

                update availabilities;
            }
        }
    }  

    private static Boolean sessionCancelled(Session__c newSession, Session__c oldSession) {
        return  (newSession.Status__c == 'Cancelled') && (oldSession.Status__c != 'Cancelled');
    }

    private static Boolean sessionDetailsUpdated(Session__c newSession, Session__c oldSession) {
        return  newSession.Name != oldSession.Name ||
                newSession.Objective__c != oldSession.Objective__c || 
                newSession.Learner_Instructions__c != oldSession.Learner_Instructions__c;
    }

    private static Boolean sessionTimeUpdated(Session__c newSession, Session__c oldSession) {
        return  newSession.Time_Zone__c != oldSession.Time_Zone__c ||
                newSession.Start_Date__c != oldSession.Start_Date__c || 
                newSession.Start_Time__c != oldSession.Start_Time__c ||
                newSession.Start_Time_Converted__c != oldSession.Start_Time_Converted__c ||
                newSession.End_Time_Converted__c != oldSession.End_Time_Converted__c;
    }

    private static Boolean changedVirtualDetails(Session__c newSession, Session__c oldSession){
        return newSession.Zoom_Session_Id__c != oldSession.Zoom_Session_Id__c ||
               newSession.Url__c != oldSession.Url__c;
    }

    public static void deleteSessionGuests(List<Session__c> deletedSessions) {
        delete as user [SELECT Id FROM Session_Guest__c WHERE Session__c =: deletedSessions];
    }
	
	public static void setDefaultNotificationPref(List<Session__c> sessionList) {
        for(Session__c session : sessionList) {
            session.Send_Recommendation_Notification__c = true;
            session.Send_Survey_Notification__c = true;                                        
        }        
    }

    public static void setDefaultZoomCapacity(List<Session__c> sessionList) {
        for (Session__c session : sessionList) {
            if (session.Virtual_Type__c == 'Zoom' && !SessionManager.hasVirtualCapacity(session)) {
                session.Virtual_Capacity__c = SessionManager.ZOOM_SESSION_LIMIT;
            }
        }      
    }

    public static void recalculateSessionGroupDates(Set<String> groupIds){
        if(groupIds.isEmpty()){
            return;
        }

        List<Session_Group__c> sessionGroups = [SELECT Id, Start_Date__c, End_Date__c,
                                                    (
                                                        SELECT Id, Start_Date__c
                                                        FROM Sessions__r
                                                        ORDER BY Start_Date__c ASC
                                                    )
                                                FROM Session_Group__c
                                                WHERE Id =: groupIds
                                                WITH USER_MODE];

        for(Session_Group__c sessionGroup : sessionGroups){
            if(sessionGroup.Sessions__r.size() == 1){
                sessionGroup.Start_Date__c = sessionGroup.Sessions__r.get(0).Start_Date__c;
                sessionGroup.End_Date__c = sessionGroup.Sessions__r.get(0).Start_Date__c;
            } else if(sessionGroup.Sessions__r.size() > 1) {
                sessionGroup.Start_Date__c = sessionGroup.Sessions__r.get(0).Start_Date__c;
                sessionGroup.End_Date__c = sessionGroup.Sessions__r.get(sessionGroup.Sessions__r.size() - 1).Start_Date__c;
            }
        }

        update sessionGroups;
    }

    @InvocableMethod( label='Set Session Survey Fields' description='set session survey fields using related survey invitation')
    public static void setSessionSurveyFields(List<Session__c> newList) {
        List<SurveySubject> ss = new List<SurveySubject>();
        List<Survey> sfSurvey = [SELECT Id 
                                    FROM Survey 
                                    WHERE DeveloperName =: Label.ACT2_Session_Survey_Name 
                                    WITH USER_MODE
                                    LIMIT 1];
        Map<String, SurveyInvitation> invitationBySessionId = new Map<String, SurveyInvitation>();
        Map<Id, Session__c> sessionMap = new Map<Id, Session__c>();
        if(sfSurvey.isEmpty()) {
            return;
        }  
        sessionMap.putAll((List<Session__c>)newList);
        // User astroUser = [SELECT Id FROM User WHERE Name = 'Astro\'s Course Tracker'];
        List<Learner_Profile__c> aLps = [SELECT Id, User__c FROM Learner_Profile__c WHERE Name = 'Astro\'s Course Tracker' LIMIT 1];

        if(aLps.isEmpty()) {
            return;
        }

        // Learner_Profile__c aLp = aLps[0];
        
        for(Session__c session : newList) {
            session.Survey__c = sfSurvey[0].Id;
            SurveyInvitation invitation = getSurveyInvitation(session);
            invitation.OwnerId = aLps[0].User__c;
            invitationBySessionId.put(session.Id, invitation);            
        }

        try {
            insert as user invitationBySessionId.values();
        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'e.getMessage(): ' + e.getMessage());
            ExceptionUtility2.logError('SF_SURVEY', 'SessionTriggerHelper' + 'setSessionSurveyFields()', 'SurveyInvitation', e.getMessage());
            return; 
        }

        Map<Id, SurveyInvitation> invitationMap = new Map<Id, SurveyInvitation>([SELECT Id, InvitationLink 
                                                                                        FROM SurveyInvitation 
                                                                                        WHERE Id IN : invitationBySessionId.values()
                                                                                        WITH USER_MODE]);
        for(Session__c session : sessionMap.values()) {
            SurveyInvitation invitation = invitationMap.get(invitationBySessionId.get(session.Id).Id);
            session.Survey_Invitation__c = invitation.Id;
            session.Survey_URL__c = invitation.InvitationLink;
            ss.add(new SurveySubject(Name = session.Name,                
                SubjectId = session.Id,
                ParentId = invitation.Id)
            );        
        }

        try{
            // update as user sessionMap.values();
            update as user Security.stripInaccessible(AccessType.UPDATABLE, sessionMap.values()).getRecords();
            if(!ss.isEmpty()) {
                insert ss;
            }
        }catch(DMLException e) {
            System.debug('The Session__c field(s) "' + String.join(e.getDmlFieldNames(0), ', ') + '" are not accessible for update of Session__c');
            System.debug(LoggingLevel.ERROR, 'Errro while updating Survey Fields :: ' + e.getMessage());
            ExceptionUtility2.logError('SF_SURVEY', 'SessionTriggerHelper' + 'setSessionSurveyFields()', 'SurveyInvitation', e.getMessage());
        }        
    }
    
    private static SurveyInvitation getSurveyInvitation(Session__c session) {
        SurveyInvitation invitation = new SurveyInvitation(
            SurveyId =  session.Survey__c,
            Name = 'Session - ' + session.Name + ' - Invitation' + '-' + Integer.valueof((Math.random() * 1000)),
            ACT2_Session__c = session.Id
        );
        return invitation;
    }

    public static void processWaitListers(List<Session__c> newSessions, Map<Id, Session__c> oldSessionMap) {
        List<String> sessionIdsToProcess = new List<String>();
        //check if we have wait listeres and we have open slots
        for(Session__c newSession : newSessions) {
            Session__c oldSession = oldSessionMap.get(newSession.Id);
            Boolean checkPhysicalWaitlisters = newSession.Physical_Waitlisters__c != 0 && (newSession.Physical_Capacity__c == null || (newSession.Physical_Capacity__c - newSession.Physical_Registered_Guests__c) > 0);
            Boolean checkVirtualWaitlisters = newSession.Virtual_Waitlisters__c != 0 && (newSession.Virtual_Capacity__c == null || (newSession.Virtual_Capacity__c - newSession.Virtual_Registered_Guests__c) > 0);
            if(checkPhysicalWaitlisters || checkVirtualWaitlisters) {
                sessionIdsToProcess.add(newSession.Id);
            }
        }
        
        if(!sessionIdsToProcess.isEmpty()) {
            List<Assigned_Session__c> updatedWaitlisters = updateWaitListerStatus(sessionIdsToProcess);
            if(!updatedWaitlisters.isEmpty()){
                update as user updatedWaitlisters;
            }
        }
    }

    public static List<Assigned_Session__c> updateWaitListerStatus(List<String> sessionIds){
        List<Assigned_Session__c> updatedWaitlisters = new List<Assigned_Session__c>();
        
        for(Session__c session : [SELECT Id, Session_Type__c, Physical_Capacity__c, Virtual_Capacity__c, Physical_Waitlisters__c, 
                                            Virtual_Waitlisters__c, Physical_Registered_Guests__c, Virtual_Registered_Guests__c, 
                                            Total_Physical_Attended__c, Total_Virtual_Attended__c, Total_Physical_Attendees__c, 
                                            Total_Virtual_Attendees__c,
                                            (
                                                SELECT Id, Queue_Position__c, Registration_Type__c, Status__c
                                                FROM Assigned_Sessions__r 
                                                WHERE Status__c = 'Waitlisted'
                                                ORDER BY Queue_Position__c ASC
                                            )
                                    FROM Session__c
                                    WHERE Id IN :sessionIds]) {
            Integer physicalQueuePosition = 1;
            Integer virtualQueuePosition = 1;
            Decimal openPhysicalSlots = session.Physical_Capacity__c != null ? session.Physical_Capacity__c - session.Physical_Registered_Guests__c : null;
            Decimal openVirtualSlots = session.Virtual_Capacity__c != null ? session.Virtual_Capacity__c - session.Virtual_Registered_Guests__c : null;
            System.debug('TFBBBBBBBB: ' + session.Total_Physical_Attendees__c + ' ' + session.Physical_Registered_Guests__c);
            if(openPhysicalSlots <= 0 || openVirtualSlots <= 0){
                continue;
            }
            for(Assigned_Session__c aSession : session.Assigned_Sessions__r){
                if(aSession.Registration_Type__c == 'Virtual' && (openVirtualSlots == null || openVirtualSlots > 0)){
                    registerWaitlister(aSession);

                    if(openVirtualSlots != null){
                        openVirtualSlots--;
                    }
                } else if(aSession.Registration_Type__c == 'Physical' && (openPhysicalSlots == null || openPhysicalSlots > 0)){
                    registerWaitlister(aSession);

                    if(openPhysicalSlots != null){
                        openPhysicalSlots--;
                    }
                } else {
                    if(aSession.Registration_Type__c == 'Virtual') {
                        aSession.Queue_Position__c = virtualQueuePosition;
                        virtualQueuePosition++;
                    } else if(aSession.Registration_Type__c == 'Physical'){
                        aSession.Queue_Position__c = physicalQueuePosition;
                        physicalQueuePosition++;
                    }
                }
            }

            updatedWaitlisters.addAll(session.Assigned_Sessions__r);
        }

        return updatedWaitlisters;
    }

    private static void registerWaitlister(Assigned_Session__c aSession){
        aSession.Status__c = 'Registered';
        aSession.Queue_Position__c = null;
        aSession.Send_Registration_Email__c = true;
    }

    public static void checkForChildrenAssigendSessions(Map<Id, Session__c> newSessionMap) {
        for(Session__c session : [SELECT Id, (SELECT Id FROM Assigned_Sessions__r WHERE Session__c =: newSessionMap.keySet() AND Status__c != 'Unregistered' LIMIT 1) 
                                  FROM Session__c 
                                  WHERE Id IN :newSessionMap.keySet()]) {
            if(session.Assigned_Sessions__r != null && !session.Assigned_Sessions__r.isEmpty()){
                newSessionMap.get(session.Id).addError('This session cannot be deleted. Please remove all guests first');
            }
        }
    }

    public static void updateEventCSAT(List<Session__c> newSessions, Map<Id, Session__c> oldSessionMap) {
        Set<Id> eventId = new Set<Id>();
        try {
            for(Session__c session : newSessions) {
                Session__c oldSession = oldSessionMap.get(session.Id);
                if(session.Session_CSAT__c != oldSession.Session_CSAT__c || 
                    session.Facilitator_CSAT__c != oldSession.Facilitator_CSAT__c ||
                    session.Effectiveness_CSAT__c != oldSession.Effectiveness_CSAT__c) {
                    if(session.Asset__c != null) {
                        eventId.add(session.Asset__c);
                    }                    
                }
            }
            if(!eventId.isEmpty()) {
                List<Asset__c> eventToUpdate = new List<Asset__c>();
                for(Asset__c asset : [SELECT Id, Event_CSAT__c, 
                                        (SELECT Id, Session_CSAT__c, Survey_Response_Count__c 
                                        FROM Sessions__r
                                        WHERE Session_CSAT__c != NULL
                                        AND Survey_Response_Count__c != NULL
                                        AND Status__c In ('Active','Completed'))
                                     FROM Asset__c 
                                     WHERE RecordType.DeveloperName = 'Event'
                                     AND Status__c = 'Active'
                                     AND Id IN: eventId]) {
                    if(!asset.Sessions__r.isEmpty()) {
                        Double newCSATWeight = 0;
                        Integer newResponseCount = 0;
                        for(Session__c session : asset.Sessions__r) {
                            Double CSATWeight = session.Session_CSAT__c * session.Survey_Response_Count__c;
                            newCSATWeight += CSATWeight;
                            newResponseCount += (Integer)session.Survey_Response_Count__c;
                        }
                        Decimal overallCsatScore = newCSATWeight / newResponseCount;
                        eventToUpdate.add(new Asset__c(
                            Id = asset.Id,
                            Event_CSAT__c = overallCsatScore.setScale(2, System.RoundingMode.HALF_UP)
                        ));
                    }                   
                }
                if(!eventToUpdate.isEmpty()) {
                    update eventToUpdate;
                }
            }
        } catch(Exception e) {
            System.debug('Error sessionToUpdate ----- '+e.getMessage()); 
            insert as user (new Integration_Error__c(
                Error_Message__c = 'Error while updating Event csat field',
                Http_Response_Body__c = 'ERROR :: '+e.getMessage() + ' -- '+e.getStackTraceString(),
                Type__c = 'CSAT'
            ));
        } 
    }

    public static String generateSessionDetailUrl(String sessionId, String attendanceCode) {
        String sfUrl = System.URL.getOrgDomainUrl().toExternalForm();

        if(sfUrl.contains('my.salesforce.com')){
            sfUrl = sfUrl.replace('my.salesforce.com', 'my.site.com');
            sfUrl += '/act/event-detail?id=' + sessionId + '&attendanceCode=' + attendanceCode;
        } else {
            sfUrl = null;
        }

        return sfUrl;
    }

    public static void updateSessionContractCount(List<Session__c> newSessions, Map<Id, Session__c> oldSessionMap) {
        
        List<Vendor_Contracts__c> vendorContracts = new List<Vendor_Contracts__c>();
        Set<Id> contractIds = new Set<Id>();
        for(Session__c session : newSessions) {
            if(session.Vendor_Contract__c == null) {
                continue;
            }

            if(oldSessionMap == null) {
                contractIds.add(session.Vendor_Contract__c);
            } else {
                Session__c oldSession = oldSessionMap.get(session.Id);
                if(session.Vendor_Contract__c != oldSession.Vendor_Contract__c) {
                    contractIds.add(session.Vendor_Contract__c);
                }
            }
        }

        if(!contractIds.isEmpty()) {
            for(AggregateResult aRes : [SELECT Count(Id) numCont, Vendor_Contract__c 
                                        FROM Session__c 
                                        WHERE Vendor_Contract__c IN :ContractIds 
                                        GROUP BY Vendor_Contract__c]) {
                vendorContracts.add(
                    new Vendor_Contracts__c(
                        Id = (Id)aRes.get('Vendor_Contract__c'), 
                        of_Sessions__c = ((Integer)aRes.get('numCont'))
                    )
                );
            }
            try {
                // Update VendorContracts;
                update as user vendorContracts;
            } catch(Exception e) {
                System.debug('Error updateSessionContractCount ----- '+e.getMessage()); 
            }
        }
    }

    public static void populateAttendanceCode(List<Session__c> newSessions) {
        for(Session__c session : newSessions) {
            if(Trigger.isInsert && String.isEmpty(session.Attendance_Code_2__c)) {
                session.Attendance_Code_2__c = generateAttendanceCode();
            }
        }
    }

    private static String generateAttendanceCode() {
        String code = '';
        while (code.length() < 6) {
            code += String.valueOf(Math.round(Math.random() * 9));
        }
        return code;
    }

    public static boolean sessionLocationUpdate(Session__c newSession, Session__c oldSession) {
        return (newSession.location_values__c != oldSession.location_values__c);
    }
}