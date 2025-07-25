public with sharing class AssignedEventAssetNotification implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        return Database.getQueryLocator([SELECT Id, Due_Date__c, Mandatory_Session_Count__c, Asset__r.Name, Learner_Profile__r.Name, 
                                        Learner_Profile__r.slackid__c, Asset__r.Description__c, Course__r.Name,
                                        Asset__r.Content_Owner_Organization__c, Course__r.Content_Owner_Organization__c,
                                        Curriculum__r.Content_Owner_Organization__c, Time_Estimate__c,
                                        Course__r.Time_Estimate__c, Asset__r.Time_Estimate__c, Learner_Profile__r.User__r.FirstName,
                                        Content_Distribution_Organization__c, Assigned_Course__r.Content_Distribution_Organization__c
                                        FROM Assignment__c
                                        WHERE createdDate = TODAY
                                        AND Inactive__c = false
                                        AND Asset__r.RecordTypeId =: eventRecordTypeId
                                        AND Self_Assigned__c = FALSE
                                        AND Learner_Profile__r.slackid__c != NULL
                                        AND Course__c != NULL
                                        WITH USER_MODE]);
        // TEST RUN ONLY
        /* return Database.getQueryLocator([SELECT Id, Due_Date__c, Mandatory_Session_Count__c, Asset__r.Name, Learner_Profile__r.Name, 
                                        Learner_Profile__r.slackid__c, Asset__r.Description__c, Course__r.Name,
                                        Asset__r.Content_Owner_Organization__c, Course__r.Content_Owner_Organization__c,
                                        Curriculum__r.Content_Owner_Organization__c, Time_Estimate__c,
                                        Course__r.Time_Estimate__c, Asset__r.Time_Estimate__c, Learner_Profile__r.User__r.FirstName
                                        FROM Assignment__c
                                        WHERE Asset__r.RecordTypeId =: eventRecordTypeId
                                        AND Learner_Profile__r.slackid__c != NULL
                                        AND Course__c != NULL
                                        AND Learner_Profile__r.Id IN ('a5jHu000001DqICIA0', 'a5jHu000001ETshIAG', 'a5jHu000001EBFWIA4')
                                        WITH USER_MODE]); */
    }

    public void execute(Database.BatchableContext BC, List<Assignment__c> scope) {
        sendEventNotification(scope);                
    }

    public static void sendEventNotification(List<Assignment__c> data) {
        List<Slack_Notification_Error__c> errorList = new List<Slack_Notification_Error__c>();
        for(Assignment__c assignment : data) {    
            String slackMessage = SlackNotificationBatchHelper.createCourseEventPayload(assignment);
            Map<String, Object> payload = new Map<String, Object>{
                'notifications' => new Map<String, Object> {
                    'learnerProfileId' => assignment.Learner_Profile__r.Id,
                    'slackUserId' => assignment.Learner_Profile__r.slackid__c,
                    'notificationMessages' => slackMessage,
                    'notificationType' => 'event-session'
                }
            };
        
            String endPoint = Constants.HEROKU_ENDPOINT + '/depositeSlackNotifications';
            Map<String, Object> result = SlackNotificationBatchHelper.postSlackMessage(JSON.serialize(payload), endPoint, 'POST');
            if(!result.isEmpty() && !(Boolean)result.get('ok')) {
                Slack_Notification_Error__c se = new Slack_Notification_Error__c(
                    Learner_Profile__c = assignment.Learner_Profile__r.Id,
                    Request_Body__c =  ''+result.get('request'),
                    Response_Body__c = ''+ result.get('response'),
                    Time_Sent__c =  DateTime.now()
                );
                errorList.add(se); 
            }            
        }

        if(!errorList.isEmpty()) {
            try {
                insert as user errorList;
            }catch(Exception e) {
                System.debug('Error:: Adding slack error log *********** :: ' + e.getMessage());
                System.debug('Error:: Adding slack error log *********** :: ' + e.getStackTraceString());
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        Database.executeBatch(new SlackEscalationNotificationBatch(), 50);
    }  
}