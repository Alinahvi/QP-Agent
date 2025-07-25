public with sharing class AssignedCourseUpdateBatch implements Database.Batchable<SObject> {
    public AssignedCourseUpdateBatch() {

    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Required__c, Elective_Asset__c, Curriculum_Course__r.Required__c, Curriculum_Course__r.Elective_Course__c
            FROM Assigned_Course__c
            WHERE Curriculum_Course__c != Null
            AND Assigned_Curriculum__c != null 
            AND Completed__c = true
            AND Assigned_Curriculum__r.Completed__c = false
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Assigned_Course__c> assignedCourses) {
        for(Assigned_Course__c ac : assignedCourses) {
            ac.Required__c = ac.Curriculum_Course__r.Required__c;
            ac.Elective_Asset__c = ac.Curriculum_Course__r.Elective_Course__c;
        }

        update assignedCourses;
    }

    public void finish(Database.BatchableContext bc) {

    }
}