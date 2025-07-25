public with sharing class SessionAttendedNotification {
    @InvocableMethod( label='Send Session Attended Notification' description='Send Session Attended Notification' callout='true')
    public static void sendSessionAttendedNotification(List<SessionWrapper> sessionData) {
        Map<Id, Assigned_Session__c> newMap = new Map<Id, Assigned_Session__c>();
        List<Id> attendedIds = new List<Id>();

        for(SessionWrapper cw : sessionData) {
            newMap.putAll((List<Assigned_Session__c>)cw.newAssignedSessionList);           
        }

        for(Assigned_Session__c aSession : newMap.values()) {
            if(aSession.Status__c == 'Attended') {
                attendedIds.add(aSession.Id);
            }           
        }

        if(!attendedIds.isEmpty()) {
            attendedSurveyNotification(attendedIds);
        }

    }

    public static void attendedSurveyNotification(List<Id> aSessionId) {
        List<Slack_Notification_Error__c> errorList = new List<Slack_Notification_Error__c>();
        Map<String, Object> assignmentMap = new Map<String, Object>();
        for(Assigned_Session__c aSession : [SELECT Id, Status__c, Learner_Profile__r.Name, Learner_Profile__r.SlackId__c, 
                                            Learner_Profile__r.User__r.FirstName, Session__r.Start_Date__c, 
                                            Session__r.Start_Time__c, Session__r.End_Time__c, Session__r.End_Date__c,
                                            Session__r.Name, Session__r.Start_Time_Converted__c, Session__r.End_Time_Converted__c,
                                            Session__r.Survey_URL__c
                                            FROM Assigned_Session__c 
                                            WHERE ID IN: aSessionId
                                            AND Learner_Profile__r.SlackId__c != NULL
                                            AND Session__r.Send_Survey_Notification__c = TRUE
                                            WITH USER_MODE]) {
            // assignmentMap.put(aSession.Id, aSession);
            String payload = System.Label.Slack_Session_Attended_Survey_Block;
            /*payload = payload.replace('{0}', 
                        String.isEmpty(aSession.Learner_Profile__r.User__r.FirstName) ? 
                        aSession.Learner_Profile__r.Name : aSession.Learner_Profile__r.User__r.FirstName);*/
            payload = payload.replace('{0}', aSession.Session__r.Name.escapeJava());
            payload = payload.replace('{1}', aSession.Session__r.Survey_URL__c);
            
            Map<String, Object> message = new Map<String, Object>{
                'notifications' => new Map<String, Object> {
                    'learnerProfileId' => aSession.Learner_Profile__r.Id,
                    'slackUserId' => aSession.Learner_Profile__r.SlackId__c,
                    'notificationMessages' => '['+payload+']',
                    'notificationType' => 'session'
                }
            };
            List<Slack_Notification_Error__c> se = SessionSlackNotification.postLearningMessage(message);
            if(!se.isEmpty()) {
                errorList.addAll(se);
            }
        }

        if(!errorList.isEmpty()) {
            try {
                insert as user errorList;
            } catch(Exception e) {
                System.debug('Error:: Adding slack error log *********** :: ' + e.getMessage());
                System.debug('Error:: Adding slack error log *********** :: ' + e.getStackTraceString());
            }
        }        
    }

    public class SessionWrapper {
        
        @InvocableVariable(label='Records of new assigned_sessions' description='Records for new assigned_sessions')
        public List<SObject> newAssignedSessionList;       
        
    }
}