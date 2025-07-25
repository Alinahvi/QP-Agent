public with sharing class DeactivateRecommendationBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Asset__c, Course__c, Curriculum__c, Audience__c, Expiration_Date__c,
                                        Session__c, Status__c, Content_Distribution_Organization__c 
                                        FROM Recommended_Learning__c
                                        WHERE Status__c = 'Active'
                                        AND Expiration_Date__c = TODAY
                                        WITH USER_MODE]);
    }

    public void execute(Database.BatchableContext BC, List<Recommended_Learning__c> scope) {
        DeactivateRecommendationBatchHelper.deactivateRecommendation(scope);                
    }

    public void finish(Database.BatchableContext BC) {
        Database.executeBatch(new ThCompletionBatch(), 10);
    }
}