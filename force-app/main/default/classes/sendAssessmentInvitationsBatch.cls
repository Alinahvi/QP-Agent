//Deprecated for now. We dont' send communications
global with sharing class sendAssessmentInvitationsBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return null;
        // return Database.getQueryLocator([SELECT Id, Send_Notification__c 
        //                                  FROM Assessment_Invitation__c
        //                                  WHERE Send_Date__c = TODAY
        //                                    AND Last_Sent_Date__c < TODAY
        //                                    AND Send_Notification__c = false
        //                                    AND Assessment__r.Status__c = 'Active']);
    }

    global void execute(Database.BatchableContext BC, List<Assessment_Response__c> scope){

    }

    // global void execute(Database.BatchableContext BC, List<Assessment_Invitation__c> scope){
    //     for(Assessment_Invitation__c ai : scope) {
    //         ai.Send_Notification__c = true;
    //     }
    //     update scope;
    // }

    global void finish(Database.BatchableContext BC){}
}