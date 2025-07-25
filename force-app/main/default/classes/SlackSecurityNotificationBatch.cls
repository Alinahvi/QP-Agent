public with sharing class SlackSecurityNotificationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public SlackSecurityNotificationBatch() {

    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        String cbRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Content_Block').getRecordTypeId();
        return Database.getQueryLocator([SELECT Id, Name, slackid__c, User__r.FirstName, User__r.ManagerId, User__r.Manager.Name, User__r.Manager.FirstName,
                                        (SELECT Id, Asset__r.Name, Due_Date__c, Assigned_Learning__r.Start_Date__c, Assigned_Learning__c,
                                        Asset__r.Description__c, Asset__r.RecordTypeId, Send_Assigned_Notification__c, Send_Overdue_Notification__c,
                                        Send_Reminder_Notification__c, Asset__r.Security_Type__c  
                                        FROM Assignments__r
                                        WHERE Self_Assigned__c = FALSE
                                        AND Inactive__c = false
                                        AND Asset__r.RecordTypeId != :eventRecordTypeId
                                        AND Asset__r.RecordTypeId != :cbRecordTypeId
                                        AND Asset__r.Security_Type__c != NULL
                                        AND Asset__r.Use_Compliance_Notification__c = TRUE
                                        AND (Send_Assigned_Notification__c = TRUE
                                        OR Send_Reminder_Notification__c = TRUE
                                        OR Send_Overdue_Notification__c = TRUE)),
                                        (SELECT Id, Course__r.Name, Assigned_Curriculum__c, Assigned_Curriculum__r.Curriculum__r.Name, Due_Date__c,
                                        Course__r.Description__c, Assigned_Curriculum__r.Curriculum__r.Description__c, Assigned_Learning__r.Start_Date__c,
                                        Send_Assigned_Notification__c, Send_Reminder_Notification__c, Send_Overdue_Notification__c, 
                                        Send_Escalation_Notification__c, Assigned_Curriculum__r.Curriculum__r.Security_Type__c, Course__r.Security_Type__c
                                        FROM Assigned_Courses__r
                                        WHERE Self_Assigned__c = FALSE
                                        AND Is_Compliance_Learning__c = TRUE 
                                        AND Inactive__c = false
                                        AND(Send_Assigned_Notification__c = TRUE
                                        OR Send_Reminder_Notification__c = TRUE
                                        OR Send_Overdue_Notification__c = TRUE))
                                        FROM Learner_Profile__c 
                                        WHERE Status__c = 'Active'
                                        AND slackid__c != NULL
                                        /* AND Id IN ('a5jHu000001DqICIA0', 'a5jHu000001ETmQIAW') */
                                        WITH USER_MODE]);   
    }

    public void execute(Database.BatchableContext BC, List<Learner_Profile__c> scope) {
        SlackNotificationBatchHelper.sendSlackPayload(scope, true);                
    }

    public void finish(Database.BatchableContext BC) {
        Database.executeBatch(new SlackEscalationNotificationBatch(), 2);
    }
}