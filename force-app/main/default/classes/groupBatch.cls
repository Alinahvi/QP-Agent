global with sharing class groupBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT id, Name FROM Learner_Profile__c WHERE GE_Business_Role__c = 'Trainer']);
    }

    global void execute(Database.BatchableContext BC, List<Learner_Profile__c> scope){
        for(Learner_Profile__c g : scope){
            ResponseData rd = MarkAsTrainer.markTrainer(g.Id);
        }
    }

    global void finish(Database.BatchableContext BC){}
}