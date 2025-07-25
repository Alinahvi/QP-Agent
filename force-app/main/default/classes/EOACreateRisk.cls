public with sharing class EOACreateRisk {

    // Invocable method to create Risk records
    @InvocableMethod(label='GA-EOA Create Risk' description='Creates new Risk records. Supports bulk operations. Use this method to add new Risks into Salesforce.')
    public static List<EOACreateRiskResponse> createRisks(List<EOACreateRiskRequest> requests) {
        List<Risk__c> risksToCreate = new List<Risk__c>();

        // Prepare Risk records for insertion
        for (EOACreateRiskRequest request : requests) {
            Risk__c risk = new Risk__c();
            risk.Identified_On__c = request.identifiedOn;
            risk.Impact__c = request.impact;
            risk.Impact_Description__c = request.impactDescription;
            risk.Mitigation_Strategy__c = request.mitigationStrategy;
            risk.Probability__c = request.probability;
            risk.Status__c = request.status;
            risk.Target_Close_Date__c = request.targetCloseDate;
            // Add more fields as necessary based on schema
            risksToCreate.add(risk);
        }

        Database.SaveResult[] results = Database.insert(risksToCreate, false);

        List<EOACreateRiskResponse> responses = new List<EOACreateRiskResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOACreateRiskResponse response = new EOACreateRiskResponse();
            response.success = results[i].isSuccess();
            response.recordId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOACreateRiskRequest {
        @InvocableVariable(label='GA-EOA Identified On' required=true description='The date the Risk was identified.')
        public Date identifiedOn;

        @InvocableVariable(label='GA-EOA Impact' description='Impact level of the Risk.')
        public String impact;

        @InvocableVariable(label='GA-EOA Impact Description' description='Detailed description of the Risk impact.')
        public String impactDescription;

        @InvocableVariable(label='GA-EOA Mitigation Strategy' description='Strategy to mitigate the Risk.')
        public String mitigationStrategy;

        @InvocableVariable(label='GA-EOA Probability' description='Probability level of the Risk.')
        public String probability;

        @InvocableVariable(label='GA-EOA Status' description='Current status of the Risk.')
        public String status;

        @InvocableVariable(label='GA-EOA Target Close Date' description='Target close date for resolving the Risk.')
        public Date targetCloseDate;
    }

    // Response wrapper for invocable method outputs
    public class EOACreateRiskResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Risk creation was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Record ID' description='Salesforce ID of the created Risk record. Null if creation failed.')
        public Id recordId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Risk creation failed. Null if successful.')
        public String errors;
    }
}