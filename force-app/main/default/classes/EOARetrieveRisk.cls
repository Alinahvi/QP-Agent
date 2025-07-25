public with sharing class EOARetrieveRisk {

    // Invocable method to retrieve Risk records
    @InvocableMethod(label='GA-EOA Retrieve Risk Records' description='Retrieves existing Risk records based on provided IDs. Supports bulk operations.')
    public static List<EOARetrieveRiskResponse> retrieveRisks(List<EOARetrieveRiskRequest> requests) {
        List<EOARetrieveRiskResponse> responses = new List<EOARetrieveRiskResponse>();
        Set<Id> riskIds = new Set<Id>();

        // Collect IDs for retrieval
        for (EOARetrieveRiskRequest request : requests) {
            riskIds.add(request.riskId);
        }

        // Query Risk records
        Map<Id, Risk__c> risksMap = new Map<Id, Risk__c>([SELECT Id, Name FROM Risk__c WHERE Id IN :riskIds]);

        // Prepare responses
        for (Id riskId : riskIds) {
            EOARetrieveRiskResponse response = new EOARetrieveRiskResponse();
            Risk__c risk = risksMap.get(riskId);
            if (risk != null) {
                response.riskId = risk.Id;
                response.riskNumber = risk.Name;
                response.found = true;
            } else {
                response.riskId = riskId;
                response.found = false;
            }
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOARetrieveRiskRequest {
        @InvocableVariable(label='GA-EOA Risk ID' required=true description='The Salesforce ID of the Risk record to retrieve.')
        public Id riskId;
    }

    // Response wrapper for invocable method outputs
    public class EOARetrieveRiskResponse {
        @InvocableVariable(label='GA-EOA Risk ID' description='Salesforce ID of the retrieved Risk record.')
        public Id riskId;

        @InvocableVariable(label='GA-EOA Risk Number' description='Auto-generated number of the Risk record.')
        public String riskNumber;

        @InvocableVariable(label='GA-EOA Found' description='Indicates whether the Risk record was found.')
        public Boolean found;
    }
}