public with sharing class AudienceMemberDeletionBatch implements Database.Batchable<sObject>, Database.Stateful {
    Utilities.DataTablePayload payload;

    public AudienceMemberDeletionBatch(Utilities.DataTablePayload payloadIn) {
        payload = payloadIn;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String queryFilters = AudienceMember.buildQueryFilters(payload);

        String query = 'SELECT Id FROM Audience_Member__c' + queryFilters + ' ORDER BY Learner_Profile__r.Name ASC';
    
        return Database.getQueryLocator(query, System.AccessLevel.USER_MODE);
    }

    public void execute(Database.BatchableContext BC, List<Audience_Member__c> scope) {
       delete as user scope;
    }

    public void finish(Database.BatchableContext BC) {
        // Insert log if want to track the batch job completionx
    }
}