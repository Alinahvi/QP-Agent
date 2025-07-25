public with sharing class EOACreateWork {

    // Invocable method to create Work records
    @InvocableMethod(label='GA-EOA Create Work' description='Creates new Work records. Supports bulk operations. Use this method to add new Work items into Salesforce.')
    public static List<EOACreateWorkResponse> createWorks(List<EOACreateWorkRequest> requests) {
        List<agf__ADM_Work__c> worksToCreate = new List<agf__ADM_Work__c>();

        // Prepare Work records for insertion
        for (EOACreateWorkRequest request : requests) {
            agf__ADM_Work__c work = new agf__ADM_Work__c();
            work.agf__Description__c = request.description;
            work.agf__Priority__c = request.priority;
            work.agf__Due_Date__c = request.dueDate;
            // Add more fields as necessary based on schema
            worksToCreate.add(work);
        }

        Database.SaveResult[] results = Database.insert(worksToCreate, false);

        List<EOACreateWorkResponse> responses = new List<EOACreateWorkResponse>();
        for (Integer i = 0; i < results.size(); i++) {
            EOACreateWorkResponse response = new EOACreateWorkResponse();
            response.success = results[i].isSuccess();
            response.recordId = results[i].isSuccess() ? results[i].getId() : null;
            response.errors = results[i].isSuccess() ? null : results[i].getErrors()[0].getMessage();
            responses.add(response);
        }

        return responses;
    }

    // Request wrapper for invocable method inputs
    public class EOACreateWorkRequest {
        @InvocableVariable(label='GA-EOA Work Description' required=true description='Description of the Work item.')
        public String description;

        @InvocableVariable(label='GA-EOA Work Priority' description='Priority of the Work item.')
        public String priority;

        @InvocableVariable(label='GA-EOA Due Date' description='Due date of the Work item.')
        public Date dueDate;
    }

    // Response wrapper for invocable method outputs
    public class EOACreateWorkResponse {
        @InvocableVariable(label='GA-EOA Success' description='Indicates if the Work creation was successful.')
        public Boolean success;

        @InvocableVariable(label='GA-EOA Record ID' description='Salesforce ID of the created Work record. Null if creation failed.')
        public Id recordId;

        @InvocableVariable(label='GA-EOA Error Message' description='Error details if the Work creation failed. Null if successful.')
        public String errors;
    }
}