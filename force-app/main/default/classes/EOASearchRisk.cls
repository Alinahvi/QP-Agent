public with sharing class EOASearchRisk {

    // Invocable method to search Risk records dynamically
    @InvocableMethod(label='GA-EOA Search Risk Records' description='Dynamically searches Risk records based on provided search criteria. Supports flexible querying.')
    public static List<EOASearchRiskResponse> searchRisks(List<EOASearchRiskRequest> requests) {
        List<EOASearchRiskResponse> responses = new List<EOASearchRiskResponse>();

        for (EOASearchRiskRequest request : requests) {
            String query = 'SELECT Id, Risk_Name__c FROM Risk__c WHERE ' + request.criteria;
            List<Risk__c> risks = Database.query(query);

            EOASearchRiskResponse response = new EOASearchRiskResponse();
            response.riskIds = new List<Id>();
            response.riskNames = new List<String>();
            response.totalRisks = risks.size();

            for (Risk__c risk : risks) {
                response.riskIds.add(risk.Id);
                response.riskNames.add(risk.Risk_Name__c);
            }

            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOASearchRiskRequest {
        @InvocableVariable(label='GA-EOA Search Criteria' required=true description='Dynamic SOQL criteria for searching Risks. Example: "Risk_Name__c LIKE \'%Test%\'".')
        public String criteria;
    }

    // Response wrapper for invocable method outputs
    public class EOASearchRiskResponse {
        @InvocableVariable(label='GA-EOA Risk IDs' description='List of Salesforce IDs for Risk records found.')
        public List<Id> riskIds;

        @InvocableVariable(label='GA-EOA Risk Names' description='List of human-friendly risk names.')
        public List<String> riskNames;

        @InvocableVariable(label='GA-EOA Total Risks' description='Total number of Risk records found.')
        public Integer totalRisks;
    }
}