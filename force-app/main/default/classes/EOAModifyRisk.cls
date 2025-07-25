public with sharing class EOAModifyRisk {

    // Invocable method to modify Risk records
    @InvocableMethod(label='GA-EOA Modify Risk Records' description='Modifies existing Risk records based on provided IDs. Supports bulk updates.')
    public static List<EOAModifyRiskResponse> modifyRisks(List<EOAModifyRiskRequest> requests) {
        List<Risk__c> risksToUpdate = new List<Risk__c>();

        // Prepare Risk records for update
        for (EOAModifyRiskRequest request : requests) {
            Risk__c risk = new Risk__c(Id = request.riskId);
            // Assign fields for modification based on actual schema
            risksToUpdate.add(risk);
        }

        // Update records and handle potential exceptions gracefully
        Database.SaveResult[] results = Database.update(risksToUpdate, false);

        List<EOAModifyRiskResponse> responses = new List<EOAModifyRiskResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOAModifyRiskResponse response = new EOAModifyRiskResponse();
            response.success = results[i].isSuccess();
            response.riskId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOAModifyRiskRequest {
        @InvocableVariable(label='GA-EOA Risk ID' required=true description='The Salesforce ID of the Risk record to modify.')
        public Id riskId;

        // Include additional fields as needed, each clearly labeled and documented
    }

    // Response wrapper for invocable method outputs
    public class EOAModifyRiskResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Risk modification was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Risk ID' description='Salesforce ID of the modified Risk record. Null if modification failed.')
        public Id riskId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Risk modification failed. Null if successful.')
        public String errors;
    }
}