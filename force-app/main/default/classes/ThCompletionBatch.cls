public with sharing class ThCompletionBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public String accessToken = '';
    public Boolean refreshTokenValid = true;
    // public boolean sendSlackNotification = true;
    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(!String.isNotBlank(accessToken)) {
            accessToken = utilities.getAccessTokenFromRefresh();            
        }
        return Database.getQueryLocator([SELECT Id, Name, User__r.Email, User__r.Org62_User_ID__c, Org62_User_ID__c, Last_Trailhead_Sync__c 
                                        FROM Learner_Profile__c
                                        WHERE Status__c = 'Active'
                                        AND User__r.Org62_User_ID__c != NULL
                                        AND Id != 'a5jHu000001EWkEIAW']);
        // return Database.getQueryLocator([SELECT Id, Name, User__r.Email, User__r.Org62_User_ID__c, Org62_User_ID__c, Last_Trailhead_Sync__c, 
        //                                 (
        //                                     SELECT Id, Completion_Date__c, Asset__r.Trailhead_Module_Id__c, Completed__c
        //                                     FROM Assignments__r
        //                                     WHERE Completed__c = false
        //                                     AND Asset__r.Trailhead_Module_Id__c != NULL
        //                                 )
        //                                 FROM Learner_Profile__c
        //                                 WHERE Status__c = 'Active'
        //                                 AND User__r.Org62_User_ID__c != NULL
        //                                 AND Id IN (
        //                                     SELECT Learner_Profile__c 
        //                                     FROM Assignment__c
        //                                     WHERE Completed__c = false
        //                                     AND Asset__r.Trailhead_Module_Id__c != NULL
        //                                     AND CreatedDate != today
        //                                     AND Learner_Profile__c != 'a5jHu000001EWkEIAW'                                                                                        
        //                                 )]); 
    }

    public void execute(Database.BatchableContext BC, List<Learner_Profile__c> scope) {
        if(!refreshTokenValid) {
            return;
        } else {
            if(String.isNotBlank(accessToken)) {
                ThCompletionBatchHelper.checkThCompletion(scope, accessToken);
            } else {
                accessToken = utilities.getAccessTokenFromRefresh();
                ThCompletionBatchHelper.checkThCompletion(scope, accessToken);
            }          
        }        
    }

    public void finish(Database.BatchableContext BC) { 
        accessToken = '';
        // if(sendSlackNotification) {
        //     // Database.executeBatch(new SlackNotificationBatch(), 70);
        // }        
    }

}