public with sharing class EOACreateEpic {

    // Invocable method to create Epic records
    @InvocableMethod(label='GA-EOA Create Epic' description='Creates new Epic records. Supports bulk operations. Use this method to add new Epics into Salesforce.')
    public static List<EOACreateEpicResponse> createEpics(List<EOACreateEpicRequest> requests) {
        List<agf__ADM_Epic__c> epicsToCreate = new List<agf__ADM_Epic__c>();

        // Prepare Epic records for insertion
        for (EOACreateEpicRequest request : requests) {
            agf__ADM_Epic__c epic = new agf__ADM_Epic__c();
            epic.Name = request.epicName;
            epic.agf__Start_Date__c = request.startDate;
            epic.agf__End_Date__c = request.endDate;
            // Add more fields as necessary based on schema
            epicsToCreate.add(epic);
        }

        Database.SaveResult[] results = Database.insert(epicsToCreate, false);

        List<EOACreateEpicResponse> responses = new List<EOACreateEpicResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOACreateEpicResponse response = new EOACreateEpicResponse();
            response.success = results[i].isSuccess();
            response.recordId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOACreateEpicRequest {
        @InvocableVariable(label='GA-EOA Epic Name' required=true description='Name of the Epic.')
        public String epicName;

        @InvocableVariable(label='GA-EOA Start Date' description='Start date for the Epic.')
        public Date startDate;

        @InvocableVariable(label='GA-EOA End Date' description='End date for the Epic.')
        public Date endDate;
    }

    // Response wrapper for invocable method outputs
    public class EOACreateEpicResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Epic creation was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Record ID' description='Salesforce ID of the created Epic record. Null if creation failed.')
        public Id recordId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Epic creation failed. Null if successful.')
        public String errors;
    }
}