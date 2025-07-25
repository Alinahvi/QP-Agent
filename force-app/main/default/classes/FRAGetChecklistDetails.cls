public with sharing class FRAGetChecklistDetails {

    /**
     * Invocable method to retrieve Checklist records based on provided IDs.
     * @param requests List containing Checklist IDs to retrieve.
     * @return List of ChecklistDetailsResponse with detailed record data and summaries.
     */
    @InvocableMethod(label='GA-FRA Get Checklist Details' description='Retrieves Checklist records by IDs.')
    public static List<ChecklistDetailsResponse> getChecklistDetails(List<ChecklistDetailsRequest> requests) {
        List<Id> checklistIds = new List<Id>();
        for (ChecklistDetailsRequest request : requests) {
            checklistIds.add(request.checklistId);
        }

        List<Checklist__c> checklists = [
            SELECT Id, Name
            FROM Checklist__c
            WHERE Id IN :checklistIds
        ];

        List<ChecklistDetailsResponse> responses = new List<ChecklistDetailsResponse>();
        for (Checklist__c checklist : checklists) {
            ChecklistDetailsResponse response = new ChecklistDetailsResponse();
            response.checklistRecord = checklist;
            response.summary = 'Retrieved Checklist with ID ' + checklist.Id + ', Name: ' + checklist.Name;
            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for retrieving Checklist details.
     */
    public class ChecklistDetailsRequest {
        @InvocableVariable(label='GA-FRA Checklist ID' description='The Salesforce ID of the Checklist record.' required=true)
        public Id checklistId;
    }

    /**
     * Inner class representing the response structure including Checklist records and summaries.
     */
    public class ChecklistDetailsResponse {
        @InvocableVariable(label='GA-FRA Checklist Record' description='Detailed Checklist record.')
        public Checklist__c checklistRecord;

        @InvocableVariable(label='GA-FRA Summary' description='Text summary of Checklist retrieval.')
        public String summary;
    }
}