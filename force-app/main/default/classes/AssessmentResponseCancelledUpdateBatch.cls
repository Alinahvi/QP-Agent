global class AssessmentResponseCancelledUpdateBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Cancelled__c, Status__c ' + 
                        'FROM Assessment_Response__c ' + 
                        'WHERE (Cancelled__c = false ' + 
                        'AND (Status__c != \'Submitted\' OR Status__c != \'Completed\')) ' + 
                        'OR (Cancelled__c = true AND (Status__c = \'Submitted\' OR Status__c = \'Completed\'))';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Assessment_Response__c> records) {
        for(Assessment_Response__c record : records) {
            if(record.Status__c == 'Submitted' || record.Status__c == 'Completed') {
                record.Cancelled__c = false;
            } else {
                record.Cancelled__c = true;
            }
        }
        update records;
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}