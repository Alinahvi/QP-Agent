public with sharing class GAEOA2ProgramHandler {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 Program ID' description='Salesforce Program record ID. Required for Modify and Retrieve actions.')
        public String programId;

        // --- agf__PPM_Program__c Fields ---
        @InvocableVariable(label='GA-EOA2 Program Name' description='Value for the Program Name (Name) field.')
        public String programName;
        @InvocableVariable(label='GA-EOA2 Start Date' description='Value for the Start Date (agf__Start_Date__c) field. Format: YYYY-MM-DD')
        public Date startDate;
        @InvocableVariable(label='GA-EOA2 End Date' description='Value for the End Date (agf__End_Date__c) field. Format: YYYY-MM-DD')
        public Date endDate;
        @InvocableVariable(label='GA-EOA2 Program Goals' description='Value for the Program Goals (agf__Program_Goals__c) field.')
        public String programGoals;
        @InvocableVariable(label='GA-EOA2 Program Health' description='Value for the Program Health (agf__Program_Health__c) field.')
        public String programHealth;
        @InvocableVariable(label='GA-EOA2 Program Health Comments' description='Value for the Program Health Comments (agf__Program_Health_Comments__c) field.')
        public String programHealthComments;
        @InvocableVariable(label='GA-EOA2 Program Summary' description='Value for the Program Summary (agf__Program_Summary__c) field.')
        public String programSummary;
        @InvocableVariable(label='GA-EOA2 Additional Program Details' description='Value for Additional Program Details (Additional_Program_Details__c).')
        public String additionalProgramDetails;
        @InvocableVariable(label='GA-EOA2 Last Program Health Comment' description='Value for Last Program Health Comment (Last_Program_Health_Comment__c).')
        public String lastProgramHealthComment;
        @InvocableVariable(label='GA-EOA2 Health Comment Date' description='Value for Health Comment Date (Health_Comment_Date__c). Format: YYYY-MM-DD')
        public Date healthCommentDate;
        @InvocableVariable(label='GA-EOA2 Associated Quip Document' description='Value for Associated Quip Document (Associated_Quip_Document__c).')
        public String associatedQuipDocument;
        @InvocableVariable(label='GA-EOA2 Executive Sponsor' description='Salesforce ID of the Executive Sponsor (agf__Executive_Sponsor__c).')
        public String executiveSponsorId;
        @InvocableVariable(label='GA-EOA2 Portfolio' description='Salesforce ID of the Portfolio (agf__Portfolio__c).')
        public String portfolioId;
        @InvocableVariable(label='GA-EOA2 Program Manager' description='Salesforce ID of the Program Manager (agf__Program_Manager__c).')
        public String programManagerId;
        @InvocableVariable(label='GA-EOA2 V2MOM' description='Salesforce ID of the V2MOM (V2MOM__c).')
        public String v2momId;
        @InvocableVariable(label='GA-EOA2 Owner' description='Salesforce ID of the record owner.')
        public String ownerId;

        // --- Search Fields ---
        @InvocableVariable(label='GA-EOA2 Created Date' description='For search operations. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals.')
        public String createdDate;
        @InvocableVariable(label='GA-EOA2 Last Modified Date' description='For search operations. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals.')
        public String lastModifiedDate;
    }

    public class Response {
        @InvocableVariable(label='GA-EOA2 Success' description='True if the operation succeeded.')
        public Boolean success = false;
        @InvocableVariable(label='GA-EOA2 Message' description='Summary of the operation result.')
        public String message = '';
        @InvocableVariable(label='GA-EOA2 Program Records' description='List of Program records from the operation.')
        public List<agf__PPM_Program__c> programRecords = new List<agf__PPM_Program__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Programs' description='Handles Create, Modify, Retrieve, and Search actions for Program records.')
    public static List<Response> managePrograms(List<Request> requests) {
        List<agf__PPM_Program__c> toCreate = new List<agf__PPM_Program__c>();
        List<agf__PPM_Program__c> toUpdate = new List<agf__PPM_Program__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            responseMap.put(i, new Response());
            Request req = requests.get(i);
            
            switch on req.actionType {
                when 'Create' {
                    toCreate.add(mapRequestToProgram(req, new agf__PPM_Program__c()));
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.programId)) {
                        responseMap.get(i).message = 'Error: Program ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.programId);
                    }
                }
                when 'Search' {
                    handleSearch(req, responseMap.get(i));
                }
                when else {
                    responseMap.get(i).message = 'Error: Invalid action type specified.';
                }
            }
        }
        
        if (!toCreate.isEmpty()) {
            Database.SaveResult[] createResults = Database.insert(toCreate, false);
            handleDmlResults(createResults, toCreate, 'Create', requests, responseMap);
        }
        
        if (!idsToProcess.isEmpty()) {
            String allFieldsQuery = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('agf__PPM_Program__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM agf__PPM_Program__c WHERE Id IN :idsToProcess';
            Map<Id, agf__PPM_Program__c> programsFromDb = new Map<Id, agf__PPM_Program__c>((List<agf__PPM_Program__c>)Database.query(allFieldsQuery));

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                Response res = responseMap.get(i);
                
                if (req.actionType == 'Modify' || req.actionType == 'Retrieve') {
                    if (String.isNotBlank(req.programId)) {
                        if (programsFromDb.containsKey(req.programId)) {
                            if (req.actionType == 'Modify') {
                                toUpdate.add(mapRequestToProgram(req, programsFromDb.get(req.programId)));
                            } else if (req.actionType == 'Retrieve') {
                                res.success = true;
                                res.message = 'Program retrieved successfully.';
                                res.programRecords.add(programsFromDb.get(req.programId));
                            }
                        } else {
                            res.message = 'Error: Program with ID ' + req.programId + ' not found or you do not have permission to access it.';
                        }
                    }
                }
            }
        }

        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            handleDmlResults(updateResults, toUpdate, 'Modify', requests, responseMap);
        }
        
        return new List<Response>(responseMap.values());
    }

    private static agf__PPM_Program__c mapRequestToProgram(Request req, agf__PPM_Program__c program) {
        if(req.actionType == 'Modify') program.Id = req.programId;
        if(req.programName != null) program.Name = req.programName;
        if(req.startDate != null) program.agf__Start_Date__c = req.startDate;
        if(req.endDate != null) program.agf__End_Date__c = req.endDate;
        if(req.programGoals != null) program.agf__Program_Goals__c = req.programGoals;
        if(req.programHealth != null) program.agf__Program_Health__c = req.programHealth;
        if(req.programHealthComments != null) program.agf__Program_Health_Comments__c = req.programHealthComments;
        if(req.programSummary != null) program.agf__Program_Summary__c = req.programSummary;
        if(req.additionalProgramDetails != null) program.Additional_Program_Details__c = req.additionalProgramDetails;
        if(req.lastProgramHealthComment != null) program.Last_Program_Health_Comment__c = req.lastProgramHealthComment;
        if(req.healthCommentDate != null) program.Health_Comment_Date__c = req.healthCommentDate;
        if(req.associatedQuipDocument != null) program.Associated_Quip_Document__c = req.associatedQuipDocument;
        if(req.executiveSponsorId != null) program.agf__Executive_Sponsor__c = req.executiveSponsorId;
        if(req.portfolioId != null) program.agf__Portfolio__c = req.portfolioId;
        if(req.programManagerId != null) program.agf__Program_Manager__c = req.programManagerId;
        if(req.v2momId != null) program.V2MOM__c = req.v2momId;
        if(req.ownerId != null) program.OwnerId = req.ownerId;
        return program;
    }

    private static void handleDmlResults(Database.SaveResult[] results, List<agf__PPM_Program__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType == action) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Program ' + action.toLowerCase() + 'd successfully.';
                        res.programRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                }
            }
        }
    }
    
    private static void handleSearch(Request req, Response res) {
        String allFields = String.join(new List<String>(Schema.getGlobalDescribe().get('agf__PPM_Program__c').getDescribe().fields.getMap().keySet()), ',');
        String soql = 'SELECT ' + allFields + ' FROM agf__PPM_Program__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.programName)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.programName) + '%\'');
        }
        if (String.isNotBlank(req.programHealth)) {
            conditions.add('agf__Program_Health__c = \'' + String.escapeSingleQuotes(req.programHealth) + '\'');
        }
        if (String.isNotBlank(req.ownerId)) {
            conditions.add('OwnerId = \'' + String.escapeSingleQuotes(req.ownerId) + '\'');
        }
        if (String.isNotBlank(req.executiveSponsorId)) {
            conditions.add('agf__Executive_Sponsor__c = \'' + String.escapeSingleQuotes(req.executiveSponsorId) + '\'');
        }
        if (String.isNotBlank(req.portfolioId)) {
            conditions.add('agf__Portfolio__c = \'' + String.escapeSingleQuotes(req.portfolioId) + '\'');
        }
        if (String.isNotBlank(req.programManagerId)) {
            conditions.add('agf__Program_Manager__c = \'' + String.escapeSingleQuotes(req.programManagerId) + '\'');
        }
        if (String.isNotBlank(req.v2momId)) {
            conditions.add('V2MOM__c = \'' + String.escapeSingleQuotes(req.v2momId) + '\'');
        }
        if (String.isNotBlank(req.createdDate)) {
            String dateCondition = GAFRA2Utility.parseDateFilter('CreatedDate', req.createdDate);
            if(String.isNotBlank(dateCondition)) {
                conditions.add(dateCondition);
            }
        }
        if (String.isNotBlank(req.lastModifiedDate)) {
            String dateCondition = GAFRA2Utility.parseDateFilter('LastModifiedDate', req.lastModifiedDate);
            if(String.isNotBlank(dateCondition)) {
                conditions.add(dateCondition);
            }
        }
        
        if (!conditions.isEmpty()) {
            soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        soql += ' ORDER BY LastModifiedDate DESC LIMIT 500';

        try {
            res.programRecords = Database.query(soql);
            res.success = true;
            res.message = 'Program search executed. Records found: ' + res.programRecords.size();
        } catch (Exception e) {
            res.message = 'Error during Program search: ' + e.getMessage();
        }
    }
}