public with sharing class FRAGetAudienceDetails {

    /**
     * Invocable method to retrieve comprehensive Audience records based on provided IDs, along with detailed summaries.
     * Use this method to fetch all relevant information related to specific Audience records for reporting, filtering, or targeted actions.
     * @param requests List containing Audience IDs to retrieve.
     * @return List of AudienceDetailsResponse including comprehensive record details and descriptive summaries.
     */
    @InvocableMethod(label='GA-FRA GetAudienceDetails' description='Retrieves comprehensive details of Audience records by IDs, including detailed summaries.')
    public static List<AudienceDetailsResponse> getAudienceDetails(List<AudienceRequest> requests) {
        List<Id> audienceIds = new List<Id>();
        for (AudienceRequest request : requests) {
            audienceIds.add(request.audienceId);
        }

        List<Audience__c> audiences = [SELECT Id, OwnerId, Name, RecordTypeId, Filter_Logic__c, Rendering__c, Use_Custom_Filter__c, externalid__c
                                        FROM Audience__c
                                        WHERE Id IN :audienceIds];

        List<AudienceDetailsResponse> responses = new List<AudienceDetailsResponse>();
        for (Audience__c audience : audiences) {
            AudienceDetailsResponse response = new AudienceDetailsResponse();
            response.audienceRecord = audience;
            response.summary = 'Audience "' + audience.Name + '" with ID ' + audience.Id +
                               ', owned by ' + audience.OwnerId +
                               ', record type ID ' + audience.RecordTypeId +
                               ', filter logic "' + audience.Filter_Logic__c + '"' +
                               ', rendering is ' + (audience.Rendering__c ? 'enabled' : 'disabled') +
                               ', custom filter is ' + (audience.Use_Custom_Filter__c ? 'enabled' : 'disabled') +
                               ', external ID "' + audience.externalid__c + '".';

            responses.add(response);
        }

        return responses;
    }

    /**
     * Inner class representing request parameters for retrieving Audience details.
     */
    public class AudienceRequest {
        @InvocableVariable(label='GA-FRA Audience ID' description='The Salesforce ID of the Audience record to retrieve.' required=true)
        public Id audienceId;
    }

    /**
     * Inner class representing the response structure with detailed Audience record and comprehensive summary.
     */
    public class AudienceDetailsResponse {
        @InvocableVariable(label='GA-FRA Audience Record' description='Comprehensive details of the Audience record.')
        public Audience__c audienceRecord;

        @InvocableVariable(label='GA-FRA Summary' description='Detailed summary describing key information about the Audience.')
        public String summary;
    }
}