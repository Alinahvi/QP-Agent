public with sharing class SlackNotificationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public static Boolean isSlackNotification = true;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        String cbRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Content_Block').getRecordTypeId();
        return Database.getQueryLocator([SELECT Id, Name, slackid__c, User__r.FirstName, User__r.ManagerId, User__r.Manager.Name, User__r.Manager.FirstName
                                        FROM Learner_Profile__c 
                                        WHERE Status__c = 'Active'
                                        AND slackid__c != NULL
                                        WITH USER_MODE]);         
    }

    public void execute(Database.BatchableContext BC, List<Learner_Profile__c> scope) {
        SlackNotificationBatchHelper.sendSlackPayload(scope, false);                
    }

    public void finish(Database.BatchableContext BC) {
        Database.executeBatch(new AssignedEventAssetNotification(), 50);        
    }    
}