public with sharing class FRAGetAssignedLearningDetails {

    /**
     * Invocable method to retrieve detailed Assigned Learning records based on provided unique IDs.
     * Useful for obtaining complete information about learning assignments.
     * @param requests List of requests containing Assigned Learning IDs.
     * @return List of AssignedLearningDetailsResponse containing full details for each Assigned Learning record.
     */
    @InvocableMethod(label='GA-FRA Get Assigned Learning Details' description='Retrieves full details of Assigned Learning records by unique IDs.')
    public static List<AssignedLearningDetailsResponse> getAssignedLearningDetails(List<AssignedLearningDetailsRequest> requests) {
        List<Id> assignedLearningIds = new List<Id>();
        for (AssignedLearningDetailsRequest request : requests) {
            assignedLearningIds.add(request.assignedLearningId);
        }

        List<Assigned_Learning__c> assignedLearnings = [SELECT Id, Name, Audience__c, Asset__c, Course__c, Curriculum__c,
                                                        Due_Date__c, Start_Date__c, Enablement_Learning_Program__c,
                                                        externalid__c, Frequency__c, Recur__c
                                                        FROM Assigned_Learning__c
                                                        WHERE Id IN :assignedLearningIds];

        List<AssignedLearningDetailsResponse> responses = new List<AssignedLearningDetailsResponse>();

        for (Assigned_Learning__c learning : assignedLearnings) {
            AssignedLearningDetailsResponse response = new AssignedLearningDetailsResponse();
            response.assignedLearningRecord = learning;
            response.summary = 'Retrieved Assigned Learning: ' + learning.Name;

            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for retrieving Assigned Learning details.
     */
    public class AssignedLearningDetailsRequest {

        @InvocableVariable(label='Assigned Learning ID' description='Unique Salesforce ID of the Assigned Learning record.' required=true)
        public Id assignedLearningId;
    }

    /**
     * Inner class representing the response structure containing detailed Assigned Learning records.
     */
    public class AssignedLearningDetailsResponse {

        @InvocableVariable(label='Assigned Learning Record' description='Detailed Assigned Learning record.')
        public Assigned_Learning__c assignedLearningRecord;

        @InvocableVariable(label='Summary' description='Summary of the retrieved Assigned Learning details.')
        public String summary;
    }
}