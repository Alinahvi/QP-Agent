/**
 * @description Handles CRUD operations for Vendor records (Vendors__c).
 * This invocable handler is used to create and manage vendor information.
 */
public with sharing class GAEOA2VendorsHandler {

    // --- INNER REQUEST CLASS (Strongly-Typed) ---
    public class Request {
        @InvocableVariable(label='Action Type' description='Specify the action: Create | Modify | Retrieve | Search | Inactivate' required=true)
        public String actionType;

        @InvocableVariable(label='Vendor ID' description='Salesforce ID of the Vendor record. Required for Modify, Retrieve, or Inactivate.')
        public String vendorId;

        @InvocableVariable(label='Vendor Name' description='The name of the vendor company. Required for Create.')
        public String vendorName;
        
        @InvocableVariable(label='Status' description='The current status of the vendor (e.g., Active, Inactive/Turned Off).')
        public String status;

        @InvocableVariable(label='Program Owner ID' description='ID of the user who is the Program Owner (Enablement Relationship Manager).')
        public String programOwnerId;

        @InvocableVariable(label='Vendor Contact Name' description='Name of the primary contact at the vendor company.')
        public String vendorContactName;

        @InvocableVariable(label='Vendor Contact Email' description='Email address of the primary contact.')
        public String vendorContactEmail;

        // Search-specific fields
        @InvocableVariable(label='Search by Status' description='For Search only. Filter records by a specific status.')
        public String searchStatus;
    }

    // --- INNER RESPONSE CLASS ---
    public class Response {
        @InvocableVariable(label='Success' description='True if the operation was successful.')
        public Boolean success = false;

        @InvocableVariable(label='Message' description='A summary of the operation result.')
        public String message = '';

        @InvocableVariable(label='Vendor Records' description='A list of Vendor records returned by the operation.')
        public List<Vendors__c> vendorRecords = new List<Vendors__c>();
    }

    // --- INVOCABLE METHOD ---
    @InvocableMethod(label='EOA Manage Vendors' description='A bulk-safe method to manage Vendor records.')
    public static List<Response> manageVendors(List<Request> requests) {
        List<Vendors__c> toCreate = new List<Vendors__c>();
        List<Vendors__c> toUpdate = new List<Vendors__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.vendorName)) {
                        res.message = 'Error: Vendor Name is required for creation.';
                    } else {
                        Vendors__c newVendor = new Vendors__c(
                            Name = req.vendorName,
                            Status__c = String.isNotBlank(req.status) ? req.status : 'Active', // Default status
                            Enablement_Relationship_Manager__c = req.programOwnerId,
                            Vendor_Contact__c = req.vendorContactName,
                            Vendor_Email__c = req.vendorContactEmail
                        );
                        toCreate.add(newVendor);
                    }
                }
                when 'Modify', 'Retrieve', 'Inactivate' {
                    if (String.isBlank(req.vendorId)) {
                        res.message = 'Error: Vendor ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.vendorId);
                    }
                }
                when 'Search' {
                    handleSearch(req, res);
                }
                when else {
                    res.message = 'Error: Invalid or missing action type provided.';
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
                        res.message = 'Vendor created successfully.';
                        res.vendorRecords.add(toCreate[createIndex]);
                    } else {
                        res.message = 'Error creating vendor: ' + sr.getErrors()[0].getMessage();
                    }
                    createIndex++;
                }
            }
        }

        if (!idsToProcess.isEmpty()) {
            Map<Id, Vendors__c> vendorsFromDb = new Map<Id, Vendors__c>([
                SELECT Id, Name, Status__c, Enablement_Relationship_Manager__c, Vendor_Contact__c, Vendor_Email__c
                FROM Vendors__c WHERE Id IN :idsToProcess
            ]);

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (req.actionType == 'Modify' || req.actionType == 'Retrieve' || req.actionType == 'Inactivate') {
                     if (String.isBlank(req.vendorId) || !vendorsFromDb.containsKey(req.vendorId)) {
                        if (responseMap.get(i).message == '') {
                           responseMap.get(i).message = 'Error: Vendor with ID ' + req.vendorId + ' not found.';
                        }
                        continue;
                    }

                    Vendors__c vendor = vendorsFromDb.get(req.vendorId);
                    if (req.actionType == 'Modify') {
                        if(String.isNotBlank(req.vendorName)) vendor.Name = req.vendorName;
                        if(String.isNotBlank(req.status)) vendor.Status__c = req.status;
                        if(String.isNotBlank(req.programOwnerId)) vendor.Enablement_Relationship_Manager__c = req.programOwnerId;
                        if(String.isNotBlank(req.vendorContactName)) vendor.Vendor_Contact__c = req.vendorContactName;
                        if(String.isNotBlank(req.vendorContactEmail)) vendor.Vendor_Email__c = req.vendorContactEmail;
                        toUpdate.add(vendor);
                    } else if (req.actionType == 'Inactivate') {
                        // Business Rule: To inactivate, set the status field.
                        vendor.Status__c = 'Inactive/Turned Off';
                        toUpdate.add(vendor);
                    } else if (req.actionType == 'Retrieve') {
                        responseMap.get(i).success = true;
                        responseMap.get(i).message = 'Vendor retrieved successfully.';
                        responseMap.get(i).vendorRecords.add(vendor);
                    }
                }
            }
        }

        if(!toUpdate.isEmpty()){
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            Integer updateIndex = 0;
            for(Integer i = 0; i < requests.size(); i++){
                 Request req = requests.get(i);
                 if((req.actionType == 'Modify' || req.actionType == 'Inactivate') && responseMap.get(i).message == ''){
                     Database.SaveResult sr = updateResults[updateIndex];
                     Response res = responseMap.get(i);
                     if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Vendor ' + req.actionType.toLowerCase() + ' action completed successfully.';
                        res.vendorRecords.add(toUpdate[updateIndex]);
                     } else {
                         res.message = 'Error updating vendor: ' + sr.getErrors()[0].getMessage();
                     }
                     updateIndex++;
                 }
            }
        }
        
        return new List<Response>(responseMap.values());
    }
    
    // --- SEARCH HELPER METHOD ---
    private static void handleSearch(Request req, Response res) {
        String soql = 'SELECT Id, Name, Status__c, Enablement_Relationship_Manager__c, Vendor_Contact__c, Vendor_Email__c, CreatedDate ' + 
                      'FROM Vendors__c';
        
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.vendorName)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.vendorName) + '%\'');
        }
        if (String.isNotBlank(req.searchStatus)) {
            conditions.add('Status__c = \'' + String.escapeSingleQuotes(req.searchStatus) + '\'');
        }
        if (String.isNotBlank(req.programOwnerId)) {
            conditions.add('Enablement_Relationship_Manager__c = \'' + String.escapeSingleQuotes(req.programOwnerId) + '\'');
        }
        
        if(!conditions.isEmpty()){
            soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        soql += ' ORDER BY CreatedDate DESC LIMIT 500';

        try {
            List<Vendors__c> vendors = Database.query(soql);
            res.success = true;
            res.message = 'Vendor search executed successfully. Records found: ' + vendors.size();
            res.vendorRecords = vendors;
        } catch (Exception e) {
            res.message = 'Error during vendor search: ' + e.getMessage();
        }
    }
}