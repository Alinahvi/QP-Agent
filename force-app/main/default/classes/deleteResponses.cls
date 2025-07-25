global class deleteResponses implements Database.Batchable<sObject> {
    private Id parentId;

    global deleteResponses(Id parentId) {
        this.parentId = parentId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Course__c FROM GetFeedback_Aut__Response__c   WHERE Course__c = :parentId';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<GetFeedback_Aut__Response__c  > childRecords) {
        delete childRecords;
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Child records deleted for parent: ' + parentId);
    }
}