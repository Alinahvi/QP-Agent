global class deleteChildRecords implements Database.Batchable<sObject> {
    private Id parentId;

    global deleteChildRecords(Id parentId) {
        this.parentId = parentId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String recordTypeName = 'ACT Case';
        String query = 'SELECT Id, recordtype.name FROM case WHERE recordtype.name = :recordTypeName';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<case> childRecords) {
        delete childRecords;
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Child records deleted for parent: ' + parentId);
    }
}