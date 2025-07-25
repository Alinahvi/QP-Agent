public with sharing class EOACreateProgram {

    // Invocable method to create Program records
    @InvocableMethod(label='GA-EOA Create Program' description='Creates new Program records. Supports bulk operations. Use this method to add new Programs into Salesforce.')
    public static List<EOACreateProgramResponse> createPrograms(List<EOACreateProgramRequest> requests) {
        List<agf__PPM_Program__c> programsToCreate = new List<agf__PPM_Program__c>();

        // Prepare Program records for insertion
        for (EOACreateProgramRequest request : requests) {
            agf__PPM_Program__c program = new agf__PPM_Program__c();
            program.Name = request.programName;
            program.agf__Start_Date__c = request.startDate;
            program.agf__End_Date__c = request.endDate;
            program.agf__Program_Goals__c = request.programGoals;
            program.agf__Program_Health__c = request.programHealth;
            // Add more fields as necessary based on schema
            programsToCreate.add(program);
        }

        Database.SaveResult[] results = Database.insert(programsToCreate, false);

        List<EOACreateProgramResponse> responses = new List<EOACreateProgramResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOACreateProgramResponse response = new EOACreateProgramResponse();
            response.success = results[i].isSuccess();
            response.recordId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOACreateProgramRequest {
        @InvocableVariable(label='GA-EOA Program Name' required=true description='Name of the Program.')
        public String programName;

        @InvocableVariable(label='GA-EOA Start Date' description='Start date for the Program.')
        public Date startDate;

        @InvocableVariable(label='GA-EOA End Date' description='End date for the Program.')
        public Date endDate;

        @InvocableVariable(label='GA-EOA Program Goals' description='Goals of the Program.')
        public String programGoals;

        @InvocableVariable(label='GA-EOA Program Health' description='Health status of the Program.')
        public String programHealth;
    }

    // Response wrapper for invocable method outputs
    public class EOACreateProgramResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Program creation was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Record ID' description='Salesforce ID of the created Program record. Null if creation failed.')
        public Id recordId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Program creation failed. Null if successful.')
        public String errors;
    }
}