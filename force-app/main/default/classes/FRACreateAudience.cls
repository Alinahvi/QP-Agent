public with sharing class FRACreateAudience {

    /**
     * Invocable method to create new Audience records.
     * Audience objects segment groups of individuals (e.g., learners, employees) for targeted actions, filtering, or reporting within Salesforce.
     * Example:
     * Audience Name: "Incentive Compensation for CSG Roles - 5/12/2025"
     * Filter Logic: "(1 AND 2) AND 3 AND 4 AND 5 AND 6"
     * Rendering: TRUE
     * Use Custom Filter: TRUE
     * This method simplifies Audience record creation by providing structured input and managing the creation logic.
     * @param audienceRequests List of Audience creation requests with details for each new record.
     * @return List of IDs of newly created Audience records.
     */
    @InvocableMethod(label='Create Audience' description='Creates new Audience records. Audiences segment individuals for targeted actions, filtering, or reporting.')
    public static List<Id> createAudience(List<AudienceCreateRequest> audienceRequests) {
        List<Id> createdIds = new List<Id>();

        List<Audience__c> audiencesToCreate = new List<Audience__c>();

        for (AudienceCreateRequest request : audienceRequests) {
            audiencesToCreate.add(new Audience__c(
                Name = request.audienceName,
                Filter_Logic__c = request.filterLogic,
                Rendering__c = request.rendering != null ? request.rendering : false,
                Use_Custom_Filter__c = request.useCustomFilter != null ? request.useCustomFilter : false,
                externalid__c = request.externalId
            ));
        }

        insert audiencesToCreate;

        for (Audience__c audience : audiencesToCreate) {
            createdIds.add(audience.Id);
        }

        System.debug('Audience records created successfully.');
        return createdIds;
    }

    /**
     * Inner class representing request parameters for audience creation.
     */
    public class AudienceCreateRequest {

        @InvocableVariable(label='Audience Name' description='The name of the Audience. Example: "Incentive Compensation for CSG Roles - 5/12/2025"' required=true)
        public String audienceName;

        @InvocableVariable(label='Filter Logic' description='Logic used to filter members of the Audience. Example: "(1 AND 2) AND 3 AND 4 AND 5 AND 6"')
        public String filterLogic;

        @InvocableVariable(label='Rendering' description='Flag indicating whether audience rendering is enabled. Example: TRUE')
        public Boolean rendering;

        @InvocableVariable(label='Use Custom Filter' description='Flag specifying if custom filter logic should be applied. Example: TRUE')
        public Boolean useCustomFilter;

        @InvocableVariable(label='External ID' description='External ID for reference purposes.')
        public String externalId;
    }
}