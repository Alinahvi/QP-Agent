public with sharing class RecommendationsDeactivateBatch implements Database.Batchable<sObject>, Database.Stateful {
    Id recordId;
    String searchTerm;
    List<Id> filteredAudienceIds;

    public RecommendationsDeactivateBatch(RecommendedLearners.RecommendationPayload payload) {
        recordId = payload.recordId;
        searchTerm = payload.searchTerm;
        filteredAudienceIds = payload.idsToProcess == null ? new List<Id>() : payload.idsToProcess;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        Set<String> queryFields = new Set<String> { 'Id', 'Status__c', 'Learner_Profile__c', 'Audience__c', 'Curriculum__c', 'Course__c', 'Asset__c' };

        String queryFilters = ' WHERE ' + recordId.getSObjectType() + ' = :recordId';

        if (!filteredAudienceIds.isEmpty()) {
            queryFilters += ' AND Audience__c IN :filteredAudienceIds';
        }

        if (String.isNotEmpty(searchTerm)) {
            queryFilters += ' AND Learner_Profile__r.Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
        }   

        String query = 'SELECT ' + String.join(queryFields, ',') + ' FROM Recommended_Learning__c' + queryFilters + ' ORDER BY Learner_Profile__r.Name ASC';
    
        return Database.getQueryLocator(query, System.AccessLevel.USER_MODE);
    }

    public void execute(Database.BatchableContext BC, List<Recommended_Learning__c> scope) {
        RecommendationHelper.updateLearnerStatus(recordId, scope, 'Inactive');
    }

    public void finish(Database.BatchableContext BC) {
        insert as user new Recommendation_Activity__c(Activity_Type__c = 'Deactivation Batch Finished', Detail__c = BC.getJobId());
    }
}