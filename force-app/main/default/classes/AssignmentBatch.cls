public with sharing class AssignmentBatch implements Database.Batchable<SObject>, Database.Stateful {
    public Set<String> learnerIds = new Set<String>();
    public List<String> assignedLearningIds = new List<String>();
    public Set<String> skillAssessmentAssignments = new Set<String>();
    public Boolean continueToNextJob = true;

    public AssignmentBatch() {
        
    }

    public AssignmentBatch(List<String> assignedLearningIds, Boolean continueToNextJob) {
        this.assignedLearningIds = assignedLearningIds;
        this.continueToNextJob = continueToNextJob;
    }

    public Database.QueryLocator start(Database.BatchableContext Bc){
        Set<String> audienceIds = new Set<String>();
        
        if(assignedLearningIds.isEmpty()){
            for(Assigned_Learning__c ta : [SELECT Id, Audience__c
                                           FROM Assigned_Learning__c 
                                           WHERE Start_Date__c = TODAY]) {
                audienceIds.add(ta.Audience__c);
            }
        } else {
            for(Assigned_Learning__c ta : [SELECT Id, Audience__c
                                           FROM Assigned_Learning__c 
                                           WHERE Id =: assignedLearningIds]) {
                audienceIds.add(ta.Audience__c);
            }
        }

        return Database.getQueryLocator([SELECT Id, Audience__c, Learner_Profile__c, Learner_Profile__r.Id, Learner_Profile__r.User__c,
                                                Learner_Profile__r.User__r.ManagerId 
                                         FROM Audience_Member__c 
                                         WHERE Audience__c =: audienceIds
                                         AND Learner_Profile__r.Status__c = 'Active'
                                         ORDER BY Audience__c]);
    }

    public void execute(Database.BatchableContext Bc, List<Audience_Member__c> members){
        Set<String> newSkillAssessmentAssignments = AssignmentBatchHelper.assignLearning(members);

        if(!newSkillAssessmentAssignments.isEmpty()){
            skillAssessmentAssignments.addAll(newSkillAssessmentAssignments);
        }
    }
    
    public void finish(Database.BatchableContext Bc){
        System.debug('*************** finish skillAssessmentAssignments ' + skillAssessmentAssignments);
        if(!skillAssessmentAssignments.isEmpty()){
            Database.executeBatch(new createAssessmentResponseBatchJob(skillAssessmentAssignments, continueToNextJob), 15);
        }

        if(continueToNextJob && skillAssessmentAssignments.isEmpty()){
            Database.executeBatch(new SlackNotificationBatch(), 10);
        }
    }
}