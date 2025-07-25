/**
 * @description Handles CRUD operations for Vendor Contract records (Vendor_Contracts__c).
 * This invocable handler is used to create and manage contracts with external vendors.
 */
public with sharing class GAEOA2VendorContractsHandler {

    // --- INNER REQUEST CLASS (Strongly-Typed) ---
    public class Request {
        @InvocableVariable(label='Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;

        @InvocableVariable(label='Vendor Contract ID' description='Salesforce ID of the record. Required for Modify or Retrieve.')
        public String contractId;

        @InvocableVariable(label='Contract Name' description='The official name of the contract. Required for Create.')
        public String contractName;
        
        @InvocableVariable(label='Vendor Name ID' description='The ID of the related Vendor (Account). Required for Create.')
        public String vendorId;

        @InvocableVariable(label='Contract Type' description='Type of contract (e.g., Master, SOW, SPA).')
        public String contractType;

        @InvocableVariable(label='Contract Start Date' description='The start date of the contract term.')
        public Date startDate;

        @InvocableVariable(label='Contract End Date' description='The end date of the contract term.')
        public Date endDate;

        @InvocableVariable(label='Total Contract Value' description='The total monetary value of the contract.')
        public Decimal totalValue;

        @InvocableVariable(label='PO Number' description='The Purchase Order number associated with this contract.')
        public String poNumber;

        // Search-specific fields
        @InvocableVariable(label='Search by Vendor ID' description='For Search only. Find all contracts for a specific Vendor.')
        public String searchVendorId;
        
        @InvocableVariable(label='Search by Contract Type' description='For Search only. Find contracts of a specific type.')
        public String searchContractType;
    }

    // --- INNER RESPONSE CLASS ---
    public class Response {
        @InvocableVariable(label='Success' description='True if the operation was successful.')
        public Boolean success = false;

        @InvocableVariable(label='Message' description='A summary of the operation result.')
        public String message = '';

        @InvocableVariable(label='Vendor Contract Records' description='A list of Vendor Contract records returned by the operation.')
        public List<Vendor_Contracts__c> vendorContracts = new List<Vendor_Contracts__c>();
    }

    // --- INVOCABLE METHOD ---
    @InvocableMethod(label='EOA Manage Vendor Contracts' description='A bulk-safe method to manage Vendor Contract records.')
    public static List<Response> manageVendorContracts(List<Request> requests) {
        List<Vendor_Contracts__c> toCreate = new List<Vendor_Contracts__c>();
        List<Vendor_Contracts__c> toUpdate = new List<Vendor_Contracts__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.contractName) || String.isBlank(req.vendorId)) {
                        res.message = 'Error: Contract Name and Vendor ID are required for creation.';
                    } else {
                        Vendor_Contracts__c newContract = new Vendor_Contracts__c(
                            Name = req.contractName,
                            Vendor_Name__c = req.vendorId,
                            Contract_Type__c = req.contractType,
                            Contract_Start_Date__c = req.startDate,
                            Contract_End_Date__c = req.endDate,
                            Contract_Value__c = req.totalValue,
                            PO__c = req.poNumber
                        );
                        toCreate.add(newContract);
                    }
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.contractId)) {
                        res.message = 'Error: Contract ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.contractId);
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
                        res.message = 'Vendor Contract created successfully.';
                        res.vendorContracts.add(toCreate[createIndex]);
                    } else {
                        res.message = 'Error creating contract: ' + sr.getErrors()[0].getMessage();
                    }
                    createIndex++;
                }
            }
        }

        if (!idsToProcess.isEmpty()) {
            Map<Id, Vendor_Contracts__c> contractsFromDb = new Map<Id, Vendor_Contracts__c>([
                SELECT Id, Name, Vendor_Name__c, Contract_Type__c, Contract_Start_Date__c, Contract_End_Date__c, Contract_Value__c, PO__c
                FROM Vendor_Contracts__c WHERE Id IN :idsToProcess
            ]);

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (req.actionType == 'Modify' || req.actionType == 'Retrieve') {
                     if (String.isBlank(req.contractId) || !contractsFromDb.containsKey(req.contractId)) {
                        if (responseMap.get(i).message == '') {
                           responseMap.get(i).message = 'Error: Contract with ID ' + req.contractId + ' not found.';
                        }
                        continue;
                    }

                    Vendor_Contracts__c contract = contractsFromDb.get(req.contractId);
                    if (req.actionType == 'Modify') {
                        if(String.isNotBlank(req.contractName)) contract.Name = req.contractName;
                        if(String.isNotBlank(req.contractType)) contract.Contract_Type__c = req.contractType;
                        if(req.startDate != null) contract.Contract_Start_Date__c = req.startDate;
                        if(req.endDate != null) contract.Contract_End_Date__c = req.endDate;
                        if(req.totalValue != null) contract.Contract_Value__c = req.totalValue;
                        toUpdate.add(contract);
                    } else if (req.actionType == 'Retrieve') {
                        responseMap.get(i).success = true;
                        responseMap.get(i).message = 'Contract retrieved successfully.';
                        responseMap.get(i).vendorContracts.add(contract);
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
                        res.message = 'Contract updated successfully.';
                        res.vendorContracts.add(toUpdate[updateIndex]);
                     } else {
                         res.message = 'Error updating contract: ' + sr.getErrors()[0].getMessage();
                     }
                     updateIndex++;
                 }
            }
        }
        
        return new List<Response>(responseMap.values());
    }
    
    // --- SEARCH HELPER METHOD ---
    private static void handleSearch(Request req, Response res) {
        String soql = 'SELECT Id, Name, Vendor_Name__c, Vendor_Name__r.Name, Contract_Type__c, Contract_Start_Date__c, Contract_End_Date__c, ' + 
                      'Contract_Value__c, Contract_Status__c, CreatedDate ' + 
                      'FROM Vendor_Contracts__c';
        
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.searchVendorId)) {
            conditions.add('Vendor_Name__c = \'' + String.escapeSingleQuotes(req.searchVendorId) + '\'');
        }
        if (String.isNotBlank(req.searchContractType)) {
            conditions.add('Contract_Type__c = \'' + String.escapeSingleQuotes(req.searchContractType) + '\'');
        }
        if (String.isNotBlank(req.contractName)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.contractName) + '%\'');
        }

        if(!conditions.isEmpty()){
            soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        soql += ' ORDER BY CreatedDate DESC LIMIT 500';

        try {
            List<Vendor_Contracts__c> contracts = Database.query(soql);
            res.success = true;
            res.message = 'Vendor Contract search executed successfully. Records found: ' + contracts.size();
            res.vendorContracts = contracts;
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}