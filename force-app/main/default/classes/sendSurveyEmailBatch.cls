global with sharing class sendSurveyEmailBatch implements Database.Batchable<sObject> {
    public String objType = 'course';

    public sendSurveyEmailBatch(String objType){
        this.objType = objType;
    }


    global Database.QueryLocator start(Database.BatchableContext BC){
        return null;    
    }

    global void execute(Database.BatchableContext BC, List<sObject> assignedItems) {
        
    }

    global void finish(Database.BatchableContext BC){

    }
}