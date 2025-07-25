public with sharing class EOARetrieveProgram {

    // Invocable method to retrieve Program records
    @InvocableMethod(label='GA-EOA Retrieve Program Records' description='Retrieves existing Program records based on provided IDs. Supports bulk operations.')
    public static List<EOARetrieveProgramResponse> retrievePrograms(List<EOARetrieveProgramRequest> requests) {
        List<EOARetrieveProgramResponse> responses = new List<EOARetrieveProgramResponse>();
        Set<Id> programIds = new Set<Id>();

        // Collect IDs for retrieval
        for (EOARetrieveProgramRequest request : requests) {
            programIds.add(request.programId);
        }

        // Query Program records
        Map<Id, agf__PPM_Program__c> programsMap = new Map<Id, agf__PPM_Program__c>([SELECT Id, Name FROM agf__PPM_Program__c WHERE Id IN :programIds]);

        // Prepare responses
        for (Id programId : programIds) {
            EOARetrieveProgramResponse response = new EOARetrieveProgramResponse();
            agf__PPM_Program__c program = programsMap.get(programId);
            if (program != null) {
                response.programId = program.Id;
                response.programName = program.Name;
                response.found = true;
            } else {
                response.programId = programId;
                response.found = false;
            }
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOARetrieveProgramRequest {
        @InvocableVariable(label='GA-EOA Program ID' required=true description='The Salesforce ID of the Program record to retrieve.')
        public Id programId;
    }

    // Response wrapper for invocable method outputs
    public class EOARetrieveProgramResponse {
        @InvocableVariable(label='GA-EOA Program ID' description='Salesforce ID of the retrieved Program record.')
        public Id programId;

        @InvocableVariable(label='GA-EOA Program Name' description='Name of the retrieved Program record.')
        public String programName;

        @InvocableVariable(label='GA-EOA Found' description='Indicates whether the Program record was found.')
        public Boolean found;
    }
}