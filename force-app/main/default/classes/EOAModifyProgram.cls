public with sharing class EOAModifyProgram {

    // Invocable method to modify Program records
    @InvocableMethod(label='GA-EOA Modify Program Records' description='Modifies existing Program records based on provided IDs. Supports bulk updates.')
    public static List<EOAModifyProgramResponse> modifyPrograms(List<EOAModifyProgramRequest> requests) {
        List<agf__PPM_Program__c> programsToUpdate = new List<agf__PPM_Program__c>();

        // Prepare Program records for update
        for (EOAModifyProgramRequest request : requests) {
            agf__PPM_Program__c program = new agf__PPM_Program__c(Id = request.programId);
            // Assign fields for modification based on actual schema
            programsToUpdate.add(program);
        }

        // Update records and handle potential exceptions gracefully
        Database.SaveResult[] results = Database.update(programsToUpdate, false);

        List<EOAModifyProgramResponse> responses = new List<EOAModifyProgramResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOAModifyProgramResponse response = new EOAModifyProgramResponse();
            response.success = results[i].isSuccess();
            response.programId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOAModifyProgramRequest {
        @InvocableVariable(label='GA-EOA Program ID' required=true description='The Salesforce ID of the Program record to modify.')
        public Id programId;

        // Include additional fields as needed, each clearly labeled and documented
    }

    // Response wrapper for invocable method outputs
    public class EOAModifyProgramResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Program modification was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Program ID' description='Salesforce ID of the modified Program record. Null if modification failed.')
        public Id programId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Program modification failed. Null if successful.')
        public String errors;
    }
}