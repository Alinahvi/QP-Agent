public with sharing class AssignmentUpdateStatusBatch implements Database.Batchable<sObject>, Database.Stateful  {
    AssignmentManager.AssignmentPayload payload;

    public AssignmentUpdateStatusBatch(AssignmentManager.AssignmentPayload payloadIn) {
        payload = payloadIn;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String contentObjectType = (payload.recordId).getSObjectType() + '';
        String assignmentObj = AssignmentManager.ASSIGNED_OBJ_BY_CONTENT.get(contentObjectType);
        String queryFilters = AssignmentManager.buildQueryFilters(payload);

        return Database.getQueryLocator('SELECT Id, Completed__c, Inactive__c FROM ' + assignmentObj + queryFilters, System.AccessLevel.USER_MODE);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        AssignmentManager.processAssignmentStatusUpdate(scope, payload);
    }

    public void finish(Database.BatchableContext BC) {
        // Insert log if want to track the batch job completionx
    }
}