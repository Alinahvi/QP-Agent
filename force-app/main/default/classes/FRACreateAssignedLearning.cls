public with sharing class FRACreateAssignedLearning {

    /**
     * Invocable method to create new Assigned Learning records.
     * Assigned Learning records represent learning assignments to specific learners or audiences.
     * @param assignedLearningRequests List containing details for creating new Assigned Learning records.
     * @return List of IDs for newly created Assigned Learning records.
     */
    @InvocableMethod(label='GA-FRA Create Assigned Learning' description='Creates Assigned Learning records for learners or audiences.')
    public static List<Id> createAssignedLearning(List<AssignedLearningRequest> assignedLearningRequests) {
        List<Id> createdIds = new List<Id>();

        List<Assigned_Learning__c> learningsToCreate = new List<Assigned_Learning__c>();

        for (AssignedLearningRequest request : assignedLearningRequests) {
            learningsToCreate.add(new Assigned_Learning__c(
                Audience__c = request.audienceId,
                Asset__c = request.assetId,
                Course__c = request.courseId,
                Curriculum__c = request.curriculumId,
                Due_Date__c = request.dueDate,
                Start_Date__c = request.startDate,
                Enablement_Learning_Program__c = request.enablementProgramId,
                externalid__c = request.externalId,
                Frequency__c = request.frequency,
                Recur__c = request.recur
            ));
        }

        insert learningsToCreate;

        for (Assigned_Learning__c learning : learningsToCreate) {
            createdIds.add(learning.Id);
        }

        System.debug('Assigned Learning records created successfully.');
        return createdIds;
    }

    /**
     * Inner class representing request parameters for Assigned Learning creation.
     */
    public class AssignedLearningRequest {

        @InvocableVariable(label='Audience ID' description='ID of the Audience to assign learning to.')
        public Id audienceId;

        @InvocableVariable(label='Asset ID' description='ID of the Asset associated with this learning.')
        public Id assetId;

        @InvocableVariable(label='Course ID' description='ID of the Course associated with this learning.')
        public Id courseId;

        @InvocableVariable(label='Curriculum ID' description='ID of the Curriculum associated with this learning.')
        public Id curriculumId;

        @InvocableVariable(label='Due Date' description='Due date for completing the assigned learning.')
        public Date dueDate;

        @InvocableVariable(label='Start Date' description='Start date for the assigned learning.')
        public Date startDate;

        @InvocableVariable(label='Enablement Program ID' description='ID of the Enablement Learning Program.')
        public Id enablementProgramId;

        @InvocableVariable(label='External ID' description='External ID for reference purposes.')
        public String externalId;

        @InvocableVariable(label='Frequency' description='Frequency of the assigned learning.')
        public String frequency;

        @InvocableVariable(label='Recur' description='Flag to indicate if the learning assignment recurs.')
        public Boolean recur;
    }
}