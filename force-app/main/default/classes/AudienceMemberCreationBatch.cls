public with sharing class AudienceMemberCreationBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Boolean runAgain;
    public String singleAudienceId;
    public Boolean runSubsequentBatch;
    public static Boolean audienceMemberBatchRunning = false;
    public Map<String, String> lastLearnerIdByAudienceId;

    public AudienceMemberCreationBatch(Boolean runSubsequentBatch, Map<String, String> lastLearnerIdByAudienceId){
        runAgain = false;
        this.runSubsequentBatch = runSubsequentBatch;
        this.lastLearnerIdByAudienceId = lastLearnerIdByAudienceId == null ? new Map<String, String>() : lastLearnerIdByAudienceId;
    }

    public AudienceMemberCreationBatch(Boolean runSubsequentBatch, Map<String, String> lastLearnerIdByAudienceId, String singleAudienceId){
        runAgain = false;
        this.singleAudienceId = singleAudienceId;
        this.runSubsequentBatch = runSubsequentBatch;
        this.lastLearnerIdByAudienceId = lastLearnerIdByAudienceId == null ? new Map<String, String>() : lastLearnerIdByAudienceId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        if(String.isNotEmpty(singleAudienceId)){
            return Database.getQueryLocator([SELECT Id, RecordType.DeveloperName FROM Audience__c WHERE Id =: singleAudienceId]);
        } else {
            Id audienceRecordType = Schema.SObjectType.Audience__c.getRecordTypeInfosByDeveloperName().get('Dynamic_Audience').getRecordTypeId();
            return Database.getQueryLocator([SELECT Id, RecordType.DeveloperName
                                             FROM Audience__c 
                                             WHERE RecordTypeId =: audienceRecordType 
                                             AND Id IN (SELECT Audience__c FROM Assigned_Learning__c WHERE Start_Date__c = TODAY)
                                             WITH USER_MODE]);
        }
    }

    public void execute(Database.BatchableContext BC, List<Audience__c> scope){
        audienceMemberBatchRunning = true;
        Audience__c aud = scope.get(0);
        
        Boolean hasMore = AudienceMemberCreationBatchHelper.createAudienceMembers(aud, lastLearnerIdByAudienceId);

        if(hasMore){
            runAgain = true;
        }else if(String.isEmpty(singleAudienceId) && aud.RecordType.DeveloperName == 'Dynamic_Audience'){
            AudienceMemberCreationBatchHelper.createNextReccurence(aud.Id);
        }
    }

    public void finish(Database.BatchableContext BC){
        if(!runAgain && String.isNotEmpty(singleAudienceId)){
            update as user new Audience__c(Id = singleAudienceId, Rendering__c = false);
        }

        if(runAgain){
            Database.executeBatch(new AudienceMemberCreationBatch(runSubsequentBatch, lastLearnerIdByAudienceId, singleAudienceId), 1);
        } else if(runSubsequentBatch){
            Database.executeBatch(new AssignmentBatch(), 3);
        }
    }
}