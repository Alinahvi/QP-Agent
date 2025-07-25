public with sharing class UpdateSettingsModalPrompt implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Show_Settings_Modal__c FROM Learner_Profile__c WHERE Show_Settings_Modal__c != true]);
    }

    public void execute(Database.BatchableContext bc, List<Learner_Profile__c> scope) {
        for (Learner_Profile__c lp : scope) {
            lp.Show_Settings_Modal__c = true;
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc){
        
    }
}