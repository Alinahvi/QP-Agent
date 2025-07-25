public with sharing class SlackEscalationNotificationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public static Boolean isSlackEscalationNotification = true;
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        List<Id> managerIds = new List<Id>();
        List<AggregateResult> ars = [SELECT count(Id), User__r.ManagerId managerId 
                                        FROM Learner_Profile__c 
                                        WHERE Status__c = 'Active' 
                                        AND User__r.ManagerId != null
                                        AND User__r.Manager.isActive = true
                                        /* AND User__r.ManagerId IN ('0052E00000LydH5QAJ','0052E00000L4VTzQAN','0052E00000L5fSWQAZ') */
                                        WITH USER_MODE
                                        GROUP BY User__r.ManagerId 
                                        HAVING count(Id) > 0
                                        ORDER BY count(Id) DESC];
        for(AggregateResult ar : ars) {
            managerIds.add((String)ar.get('managerId'));
        }
        System.debug('Manager Id ------ '+managerIds.size());
        return Database.getQueryLocator([SELECT Id, Name, User__c, slackid__c 
                                        FROM Learner_Profile__c 
                                        WHERE User__c IN: managerIds 
                                        AND Employee_on_Leave__c = FALSE
                                        AND slackid__c != NULL
                                        WITH USER_MODE]);              
    }

    public void execute(Database.BatchableContext BC, List<Learner_Profile__c> scope) {
        for(Learner_Profile__c lp : scope) {
            SlackEscalationNotificationBatchHelper.resetDataMap();
            SlackEscalationNotificationBatchHelper.sendEscalationNotification(new Map<String, String> {
                lp.User__c => lp.Id
            }, new List<Learner_Profile__c>{lp});
        }        
    }

    public void finish(Database.BatchableContext BC) {
        Database.executeBatch(new SessionReminderNotificationBatch(), 90);
    }
}