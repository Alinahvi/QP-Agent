public with sharing class AssignmentUpdateBatch implements Database.Batchable<SObject> {
    public AssignmentUpdateBatch() {

    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Required__c, Elective_Asset__c, Course_Asset__r.Required__c, Course_Asset__r.Elective_Asset__c
            FROM Assignment__c
            WHERE Course_Asset__c != Null
            AND Completed__c = true
            AND ((Assigned_Course__c != null AND Assigned_Course__r.Completed__c = false)
            OR (Assigned_Curriculum__c != null AND Assigned_Curriculum__r.Completed__c = false))
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Assignment__c> assignments) {
        for(Assignment__c a : assignments) {
            a.Required__c = a.Course_Asset__r.Required__c;
            a.Elective_Asset__c = a.Course_Asset__r.Elective_Asset__c;
        }

        update assignments;
    }

    public void finish(Database.BatchableContext bc) {

    }
}