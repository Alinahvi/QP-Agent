/**
 * @description Handles CRUD operations for Vendor Spend Reclaimed records (Vendor_Spend_Reclaimed__c).
 * This invocable handler is used to track cost savings from vendor negotiations or cancellations.
 * The 'Name' field for this object is an Auto-Number and is set by the system.
 */
public with sharing class GAEOA2VendorSpendReclaimedHandler {

    // --- INNER REQUEST CLASS (Strongly-Typed and Corrected) ---
    public class Request {
        @InvocableVariable(label='Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;

        @InvocableVariable(label='Spend Reclaimed ID' description='Salesforce ID of the record. Required for Modify or Retrieve.')
        public String spendReclaimedId;
        
        // The Name field is an auto-number, so we don't provide it on create.
        // @InvocableVariable(label='Record Name'...) // This has been removed.

        @InvocableVariable(label='Related Vendor ID' description='ID of the Vendor this reclaimed spend is associated with. Required for Create.')
        public String vendorId;

        @InvocableVariable(label='Type' description='The type of savings (e.g., Negotiation, Reduction, Turned Off).')
        public String type;

        @InvocableVariable(label='Money Saved' description='The amount of money saved or reclaimed. Required for Create.')
        public Double moneySaved;

        @InvocableVariable(label='Fiscal Year' description='The fiscal year in which the savings were realized (e.g., FY24).')
        public String fiscalYear;

        @InvocableVariable(label='Additional Info' description='Any additional details about how the savings were achieved.')
        public String additionalInfo;

        // Search-specific fields
        @InvocableVariable(label='Search by Vendor ID' description='For Search only. Find all reclaimed spend for a specific Vendor.')
        public String searchVendorId;
        
        @InvocableVariable(label='Search by Fiscal Year' description='For Search only. Find all savings for a specific fiscal year.')
        public String searchFiscalYear;
    }

    // --- INNER RESPONSE CLASS ---
    public class Response {
        @InvocableVariable(label='Success' description='True if the operation was successful.')
        public Boolean success = false;

        @InvocableVariable(label='Message' description='A summary of the operation result.')
        public String message = '';

        @InvocableVariable(label='Vendor Spend Reclaimed Records' description='A list of records returned by the operation.')
        public List<Vendor_Spend_Reclaimed__c> spendReclaimedRecords = new List<Vendor_Spend_Reclaimed__c>();
    }

    // --- INVOCABLE METHOD ---
    @InvocableMethod(label='EOA Manage Vendor Spend Reclaimed' description='A bulk-safe method to manage Vendor Spend Reclaimed records.')
    public static List<Response> manageVendorSpendReclaimed(List<Request> requests) {
        List<Vendor_Spend_Reclaimed__c> toCreate = new List<Vendor_Spend_Reclaimed__c>();
        List<Vendor_Spend_Reclaimed__c> toUpdate = new List<Vendor_Spend_Reclaimed__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            switch on req.actionType {
                when 'Create' {
                    // CORRECTED: Check for Vendor ID and Money Saved, not Name.
                    if (String.isBlank(req.vendorId) || req.moneySaved == null) {
                        res.message = 'Error: Vendor ID and Money Saved are required for creation.';
                    } else {
                        Vendor_Spend_Reclaimed__c newSpend = new Vendor_Spend_Reclaimed__c(
                            // CORRECTED: Removed assignment to "Name" field.
                            Vendor__c = req.vendorId,
                            Type__c = req.type,
                            Money_Saved__c = req.moneySaved,
                            Fiscal_Year__c = req.fiscalYear,
                            Additional_Info__c = req.additionalInfo
                        );
                        toCreate.add(newSpend);
                    }
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.spendReclaimedId)) {
                        res.message = 'Error: Spend Reclaimed ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.spendReclaimedId);
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
                        res.message = 'Vendor Spend Reclaimed record created successfully.';
                        res.spendReclaimedRecords.add(toCreate[createIndex]);
                    } else {
                        res.message = 'Error creating record: ' + sr.getErrors()[0].getMessage();
                    }
                    createIndex++;
                }
            }
        }

        if (!idsToProcess.isEmpty()) {
            Map<Id, Vendor_Spend_Reclaimed__c> recordsFromDb = new Map<Id, Vendor_Spend_Reclaimed__c>([
                SELECT Id, Name, Vendor__c, Type__c, Money_Saved__c, Fiscal_Year__c, Additional_Info__c
                FROM Vendor_Spend_Reclaimed__c WHERE Id IN :idsToProcess
            ]);

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (req.actionType == 'Modify' || req.actionType == 'Retrieve') {
                     if (String.isBlank(req.spendReclaimedId) || !recordsFromDb.containsKey(req.spendReclaimedId)) {
                        if (responseMap.get(i).message == '') {
                           responseMap.get(i).message = 'Error: Record with ID ' + req.spendReclaimedId + ' not found.';
                        }
                        continue;
                    }

                    Vendor_Spend_Reclaimed__c record = recordsFromDb.get(req.spendReclaimedId);
                    if (req.actionType == 'Modify') {
                        // CORRECTED: Do not allow modification of the Name field.
                        if(String.isNotBlank(req.type)) record.Type__c = req.type;
                        if(req.moneySaved != null) record.Money_Saved__c = req.moneySaved;
                        if(String.isNotBlank(req.fiscalYear)) record.Fiscal_Year__c = req.fiscalYear;
                        if(String.isNotBlank(req.additionalInfo)) record.Additional_Info__c = req.additionalInfo;
                        toUpdate.add(record);
                    } else if (req.actionType == 'Retrieve') {
                        responseMap.get(i).success = true;
                        responseMap.get(i).message = 'Record retrieved successfully.';
                        responseMap.get(i).spendReclaimedRecords.add(record);
                    }
                }
            }
        }

        if(!toUpdate.isEmpty()){
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            Integer updateIndex = 0;
            for(Integer i = 0; i < requests.size(); i++){
                 Request req = requests.get(i);
                 if(req.actionType == 'Modify' && responseMap.get(i).message == ''){
                     Database.SaveResult sr = updateResults[updateIndex];
                     Response res = responseMap.get(i);
                     if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Record updated successfully.';
                        res.spendReclaimedRecords.add(toUpdate[updateIndex]);
                     } else {
                         res.message = 'Error updating record: ' + sr.getErrors()[0].getMessage();
                     }
                     updateIndex++;
                 }
            }
        }
        
        return new List<Response>(responseMap.values());
    }
    
    // --- SEARCH HELPER METHOD ---
    private static void handleSearch(Request req, Response res) {
        String soql = 'SELECT Id, Name, Vendor__c, Vendor__r.Name, Type__c, Money_Saved__c, Fiscal_Year__c, CreatedDate ' +
                      'FROM Vendor_Spend_Reclaimed__c';
        
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.searchVendorId)) {
            conditions.add('Vendor__c = \'' + String.escapeSingleQuotes(req.searchVendorId) + '\'');
        }
        if (String.isNotBlank(req.searchFiscalYear)) {
            conditions.add('Fiscal_Year__c = \'' + String.escapeSingleQuotes(req.searchFiscalYear) + '\'');
        }
        
        if(!conditions.isEmpty()){
            soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        soql += ' ORDER BY CreatedDate DESC LIMIT 500';

        try {
            List<Vendor_Spend_Reclaimed__c> records = Database.query(soql);
            res.success = true;
            res.message = 'Search executed successfully. Records found: ' + records.size();
            res.spendReclaimedRecords = records;
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}