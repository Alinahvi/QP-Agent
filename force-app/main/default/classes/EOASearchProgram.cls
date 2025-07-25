public with sharing class EOASearchProgram {

    // Invocable method to search Program records dynamically
    @InvocableMethod(label='GA-EOA Search Program Records' description='Dynamically searches Program records based on provided search criteria. If criteria is blank, all records are returned. Supports flexible querying.')
    public static List<EOASearchProgramResponse> searchPrograms(List<EOASearchProgramRequest> requests) {
        List<EOASearchProgramResponse> responses = new List<EOASearchProgramResponse>();

        for (EOASearchProgramRequest request : requests) {
            String baseQuery = 'SELECT Id, Name FROM agf__PPM_Program__c';
            String query;

            // Check for blank criteria
            if (String.isBlank(request.criteria)) {
                query = baseQuery;
            } else {
                query = baseQuery + ' WHERE ' + request.criteria;
            }

            List<agf__PPM_Program__c> programs = Database.query(query);

            // Summarize results in response
            EOASearchProgramResponse summaryResponse = new EOASearchProgramResponse();
            summaryResponse.found = !programs.isEmpty();
            summaryResponse.programCount = programs.size();
            summaryResponse.programIds = new List<Id>();
            summaryResponse.programNames = new List<String>();

            for (agf__PPM_Program__c program : programs) {
                summaryResponse.programIds.add(program.Id);
                summaryResponse.programNames.add(program.Name);
            }

            responses.add(summaryResponse);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOASearchProgramRequest {
        @InvocableVariable(label='GA-EOA Search Criteria' required=false description='Dynamic SOQL criteria for searching Programs. Leave blank to return all records. Example: "Name LIKE \'%Test%\'".')
        public String criteria;
    }

    // Response wrapper for invocable method outputs
    public class EOASearchProgramResponse {
        @InvocableVariable(label='GA-EOA Found' description='Indicates whether any Program records were found.')
        public Boolean found;

        @InvocableVariable(label='GA-EOA Program Count' description='Total number of Program records found.')
        public Integer programCount;

        @InvocableVariable(label='GA-EOA Program IDs' description='List of Salesforce IDs for the Program records found.')
        public List<Id> programIds;

        @InvocableVariable(label='GA-EOA Program Names' description='List of Program record names found.')
        public List<String> programNames;
    }
}