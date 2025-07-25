public with sharing class EventManager { 
    public static Integer assignmentDeleteLimit = 1000;
    public static Integer assignedSessionsDeleteLimit = 8000;

    @AuraEnabled
    public static string getEventData(String recordId){
        ResponseData rd = new ResponseData();

        try {
            Asset__c la = [SELECT Id, Time_Zone__c
                           FROM Asset__c
                           WHERE Id =: recordId
                           WITH USER_MODE];

            List<Map<String, String>> timezones = Utilities.getPicklistVals(Session__c.Time_Zone__c.getDescribe());

            rd.put('asset', recordId);
            rd.put('timezones', timezones);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static ResponseData deleteAssignedSessionsByAsset(String assetId){
        ResponseData rd = new ResponseData();
        
        try {
            List<Assigned_Session__c> assignedSessionsToUnregister = new List<Assigned_Session__c>();
            List<Assignment__c> assignments = [SELECT Id,
                                                    (
                                                        SELECT Id, Status__c
                                                        FROM Assigned_Sessions__r
                                                    )
                                               FROM Assignment__c
                                               WHERE Asset__c =: assetId
                                               AND Completed__c = false
                                               AND Assigned_Course__c = null
                                               WITH USER_MODE
                                               LIMIT :assignmentDeleteLimit];

            rd.put('hasMore', assignments.size() == assignmentDeleteLimit);

            for(Assignment__c a : assignments){
                a.Inactive__c = true;

                for(Assigned_Session__c aSession : a.Assigned_Sessions__r){
                    aSession.Status__c = 'Unregistered';
                    assignedSessionsToUnregister.add(aSession);
                }
            }
            
            update as user assignedSessionsToUnregister;
            update assignments;
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData getSessions(String assetId){
        ResponseData rd = new ResponseData();
        
        try {
            rd.put('sessions', [SELECT Id
                                FROM Session__c
                                WHERE Asset__c =: assetId
                                AND Status__c = 'Active'
                                WITH USER_MODE]);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData cancelSessions(String assetId, String cancelReason, String cancelDetails){
        ResponseData rd = new ResponseData();
        
        try {
            List<String> sessionIds = new List<String>();
            List<String> allowedStatuses = new List<String>{'Draft', 'Active'};
            List<Session__c> sessions = [SELECT Id, Status__c, Cancelled_Reason__c, Cancelled_Reason_Details__c
                                         FROM Session__c 
                                         WHERE Asset__c =: assetId 
                                         AND Status__c =: allowedStatuses
                                         WITH USER_MODE];

            for (Session__c session : sessions) {
                session.Status__c = 'Cancelled';
                session.Cancelled__c = true;
                session.Cancelled_Reason__c = cancelReason;
                session.Cancelled_Reason_Details__c = cancelDetails;
                sessionIds.add(session.Id);
            }

            update as user sessions;
            rd.put('sessionIds', sessionIds);
        } catch (Exception e) {
            System.debug('Exception -------- '+e);
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData removeSessionGuest(List<String> sessionIds) {
        ResponseData rd = new ResponseData();
        try {
            List<Session__c> sessionToUpdate = new List<Session__c>();
            for(Session__c session : [SELECT Id, Zoom_Session_Id__c, Zoom_Type__c, Virtual_Type__c, Zoom_Occurrence_Id__c 
                                        FROM Session__c 
                                        WHERE Id =: sessionIds 
                                        AND Virtual_Type__c = 'Zoom'
                                        AND Zoom_Type__c != NULL
                                        AND Zoom_Session_Id__c != NULL]) {
                
                sessionManager.deleteZoomSession(session, new ResponseData());
            }
            
        } catch(Exception e) {
            insert as user new Integration_Error__c(
                Error_Message__c = 'Error while deleting zoom host when Session is cancelled or Event is cancelled',
                Http_Response_Body__c = 'ERROR :: '+e.getMessage() + ' -- '+e.getStackTraceString() ,
                Type__c = 'Zoom Meeting/Webinar Session cancel'
            );
        }

        try {
            List<Session_Guest__c> sessionGuest = [SELECT Id FROM Session_Guest__c WHERE Session__c =: sessionIds];
            if(!sessionGuest.isEmpty()) {
                delete sessionGuest;
            }
        }catch(Exception e) {
            rd.addError(e);
        }       
        return rd;
    }

    /**
     * NOTE : Assigned Session cancellation emails will be sent out via Session trigger, then deleted via Assigned Session record-triggered Flow
     */

    // @AuraEnabled
    // public static ResponseData deleteAssignedSessionsBySession(String sessionId){
    //     ResponseData rd = new ResponseData();
        
    //     try {
    //         List<Assigned_Session__c> assignedSessions = [SELECT Id
    //                                                       FROM Assigned_Session__c
    //                                                       WHERE Session__c =: sessionId
    //                                                       AND Status__c = 'Registered'
    //                                                       WITH USER_MODE
    //                                                       LIMIT :assignedSessionsDeleteLimit];

    //         rd.put('hasMore', assignedSessions.size() >= assignedSessionsDeleteLimit);

    //         for (Assigned_Session__c assignedSession : assignedSessions) {
    //             assignedSession.Send_Cancelled_Email__c = true;
    //         }

    //         update as user assignedSessions;
    //     } catch (Exception e) {
    //         rd.addError(e);
    //     }
    
    //     return rd;
    // }
}