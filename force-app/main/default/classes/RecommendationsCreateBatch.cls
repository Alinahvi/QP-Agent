public with sharing class RecommendationsCreateBatch implements Database.Batchable<sObject>, Database.Stateful {
    Id recordId;
    String contentOrg;
    List<Id> idsToProcess;
    Boolean addToAudience; // If true, adding multiple content to 1 audience. If false, adding 1 content to multiple audiences.
    String expirationDate;
    String ouLeader;

    public RecommendationsCreateBatch(RecommendedLearners.RecommendationPayload payload) {
        recordId = payload.recordId;
        contentOrg = payload.contentOrg;
        idsToProcess = payload.idsToProcess == null ? new List<Id>() : payload.idsToProcess;
        expirationDate = payload.expirationDate;
        ouLeader = payload.ouLeader;

        String recordType = recordId.getSObjectType().getDescribe().getName();

        if (recordType == Audience__c.getSObjectType().getDescribe().getName()) {
            addToAudience = true;
        } else {
            addToAudience = false;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        Set<String> queryFields = new Set<String>{ 'Id', 'Learner_Profile__c', 'Audience__c' };
        String queryFilters = ' WHERE ';

        if (addToAudience) {
            if (!idsToProcess.isEmpty()) {
                queryFilters += 'Audience__c = :recordId';
            }
        } else {
            if (!idsToProcess.isEmpty()) {
                queryFilters += ' Audience__c IN :idsToProcess';
            }       
        }

        queryFilters += ' AND Learner_Profile__r.User__r.IsActive = true';

        String query = 'SELECT ' + String.join(queryFields, ',') + ' FROM Audience_Member__c' + queryFilters;
 
        return Database.getQueryLocator(query, System.AccessLevel.USER_MODE);
    }

    public void execute(Database.BatchableContext BC, List<Audience_Member__c> scope) {
        if (addToAudience) {
            RecommendationHelper.addContentToLearners(scope, idsToProcess, contentOrg, expirationDate, ouLeader);
        } else {
            RecommendationHelper.addContentToLearners(scope, new List<Id>{ recordId }, contentOrg, expirationDate, ouLeader);
        }
    }

    public void finish(Database.BatchableContext BC) {
        insert as user new Recommendation_Activity__c(Activity_Type__c = 'Creation Batch Finished', Detail__c = BC.getJobId());
    }
}