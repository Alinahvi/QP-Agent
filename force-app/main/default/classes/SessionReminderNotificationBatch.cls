public with sharing class SessionReminderNotificationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Status__c, Learner_Profile__r.Name, Learner_Profile__r.SlackId__c, 
                                        Learner_Profile__r.User__r.FirstName, Session__r.Start_Date__c, 
                                        Session__r.Start_Time__c, Session__r.End_Time__c, Session__r.End_Date__c,
                                        Session__r.Name, Session__r.Start_Time_Converted__c, Session__r.End_Time_Converted__c,
                                        Asset__r.Name, Assignment__c, Session__r.Description__c, Asset__r.Content_Owner_Organization__c,
                                        Asset__r.Time_Estimate__c
                                        FROM Assigned_Session__c 
                                        WHERE Send_Reminder_Notification__c = TRUE
                                        AND Learner_Profile__r.SlackId__c != NULL
                                        AND Learner_Profile__r.Status__c = 'Active'
                                        WITH USER_MODE]);
        /*
        // Test Run                               
        return Database.getQueryLocator([SELECT Id, Status__c, Learner_Profile__r.Name, Learner_Profile__r.SlackId__c, 
        Learner_Profile__r.User__r.FirstName, Session__r.Start_Date__c, 
        Session__r.Start_Time__c, Session__r.End_Time__c, Session__r.End_Date__c,
        Session__r.Name, Session__r.Start_Time_Converted__c, Session__r.End_Time_Converted__c,
        Asset__r.Name, Assignment__c, Session__r.Description__c, Asset__r.Content_Owner_Organization__c,
        Asset__r.Time_Estimate__c
        FROM Assigned_Session__c 
        WHERE Learner_Profile__r.SlackId__c != NULL
        AND Learner_Profile__r.Id IN ('a5jHu000001DqICIA0', 'a5jHu000001ETshIAG', 'a5jHu000001EBFWIA4')
        WITH USER_MODE]);
        */
    }

    public void execute(Database.BatchableContext BC, List<Assigned_Session__c> scope) {
        List<Slack_Notification_Error__c> errorList = new List<Slack_Notification_Error__c>();
        SiteLink sl = new SiteLink();
        String orgURL = sl.siteUrlWithPrefix;
        
        for(Assigned_Session__c aSession : scope) {
            String payload = SessionSlackNotification.createSessionPayload(aSession, 'sessionReminder', orgURL);
            Map<String, Object> message = new Map<String, Object>{
                'notifications' => new Map<String, Object> {
                    'learnerProfileId' => aSession.Learner_Profile__r.Id,
                    'slackUserId' => aSession.Learner_Profile__r.SlackId__c,
                    'notificationMessages' => payload,
                    'notificationType' => 'event-session'
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

    public void finish(Database.BatchableContext BC) {
        Database.executeBatch(new RecommendationDataCloudBatch(), 1000);
    } 
}