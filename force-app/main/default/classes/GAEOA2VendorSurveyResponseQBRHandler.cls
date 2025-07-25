/**
 * @description Handles CRUD operations for Vendor Survey Response QBR records.
 * This invocable handler creates and manages survey responses linked to a specific vendor for QBRs.
 * The 'Name' field for this object is an Auto-Number and is set by the system.
 */
public with sharing class GAEOA2VendorSurveyResponseQBRHandler {

    // --- INNER REQUEST CLASS (Strongly-Typed) ---
    public class Request {
        @InvocableVariable(label='Action Type' description='Specify the action: Create | Retrieve | Search' required=true)
        public String actionType;

        @InvocableVariable(label='Survey Response ID' description='Salesforce ID of the record. Required for Retrieve.')
        public String responseId;
        
        @InvocableVariable(label='Related Vendor ID' description='ID of the Vendor for whom this survey response is being created. Required for Create.')
        public String vendorId;

        // Note: There are no other standard fields to set on creation or modification besides the owner,
        // so the actions are simplified. Custom fields could be added here if needed.

        // Search-specific fields
        @InvocableVariable(label='Search by Vendor ID' description='For Search only. Find all QBR survey responses for a specific Vendor.')
        public String searchVendorId;
    }

    // --- INNER RESPONSE CLASS ---
    public class Response {
        @InvocableVariable(label='Success' description='True if the operation was successful.')
        public Boolean success = false;

        @InvocableVariable(label='Message' description='A summary of the operation result.')
        public String message = '';

        @InvocableVariable(label='Survey Response Records' description='A list of QBR Survey Response records returned by the operation.')
        public List<Vendor_Survey_Response_QBR__c> surveyResponseRecords = new List<Vendor_Survey_Response_QBR__c>();
    }

    // --- INVOCABLE METHOD ---
    @InvocableMethod(label='EOA Manage Vendor QBR Survey Responses' description='A bulk-safe method to manage Vendor QBR Survey Response records.')
    public static List<Response> manageVendorSurveyResponses(List<Request> requests) {
        List<Vendor_Survey_Response_QBR__c> toCreate = new List<Vendor_Survey_Response_QBR__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.vendorId)) {
                        res.message = 'Error: Related Vendor ID is required for creation.';
                    } else {
                        Vendor_Survey_Response_QBR__c newResponse = new Vendor_Survey_Response_QBR__c(
                            // The Name field is an auto-number and will be set by Salesforce.
                            Vendor_Name_for_QBR__c = req.vendorId
                        );
                        toCreate.add(newResponse);
                    }
                }
                when 'Retrieve' {
                    if (String.isBlank(req.responseId)) {
                        res.message = 'Error: Survey Response ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.responseId);
                    }
                }
                when 'Search' {
                    handleSearch(req, res);
                }
                when else {
                    res.message = 'Error: Invalid or missing action type provided. Supported actions are Create, Retrieve, Search.';
                }
            }
        }
        
        // --- DML OPERATIONS ---
        if (!toCreate.isEmpty()) {
            Database.SaveResult[] createResults = Database.insert(toCreate, false);
            Integer createIndex = 0;
            for (Integer i = 0; i < requests.size(); i++) {
                if (requests.get(i).actionType == 'Create' && responseMap.get(i).message == '') {
                    Database.SaveResult sr = createResults[createIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Vendor QBR Survey Response created successfully.';
                        res.surveyResponseRecords.add(toCreate[createIndex]);
                    } else {
                        res.message = 'Error creating survey response: ' + sr.getErrors()[0].getMessage();
                    }
                    createIndex++;
                }
            }
        }

        if (!idsToProcess.isEmpty()) {
            Map<Id, Vendor_Survey_Response_QBR__c> recordsFromDb = new Map<Id, Vendor_Survey_Response_QBR__c>([
                SELECT Id, Name, Vendor_Name_for_QBR__c, CreatedDate
                FROM Vendor_Survey_Response_QBR__c WHERE Id IN :idsToProcess
            ]);

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (req.actionType == 'Retrieve') {
                     if (String.isBlank(req.responseId) || !recordsFromDb.containsKey(req.responseId)) {
                        if (responseMap.get(i).message == '') {
                           responseMap.get(i).message = 'Error: Survey Response with ID ' + req.responseId + ' not found.';
                        }
                        continue;
                    }
                    
                    Vendor_Survey_Response_QBR__c record = recordsFromDb.get(req.responseId);
                    responseMap.get(i).success = true;
                    responseMap.get(i).message = 'Survey Response retrieved successfully.';
                    responseMap.get(i).surveyResponseRecords.add(record);
                }
            }
        }
        
        return new List<Response>(responseMap.values());
    }
    
    // --- SEARCH HELPER METHOD ---
    private static void handleSearch(Request req, Response res) {
        String soql = 'SELECT Id, Name, Vendor_Name_for_QBR__c, Vendor_Name_for_QBR__r.Name, CreatedDate ' +
                      'FROM Vendor_Survey_Response_QBR__c';
        
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.searchVendorId)) {
            conditions.add('Vendor_Name_for_QBR__c = \'' + String.escapeSingleQuotes(req.searchVendorId) + '\'');
        }
        
        if(!conditions.isEmpty()){
            soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        soql += ' ORDER BY CreatedDate DESC LIMIT 500';

        try {
            List<Vendor_Survey_Response_QBR__c> records = Database.query(soql);
            res.success = true;
            res.message = 'Search executed successfully. Records found: ' + records.size();
            res.surveyResponseRecords = records;
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}