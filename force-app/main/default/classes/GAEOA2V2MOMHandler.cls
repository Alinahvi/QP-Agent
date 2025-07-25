public with sharing class GAEOA2V2MOMHandler {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 V2MOM ID' description='Salesforce V2MOM record ID. Required for Modify and Retrieve actions.')
        public String v2momId;

        // --- V2MOM__c Fields ---
        @InvocableVariable(label='GA-EOA2 Owner' description='Salesforce ID of the record owner.')
        public String ownerId;
        @InvocableVariable(label='GA-EOA2 Record Type ID' description='Salesforce ID of the record type.')
        public String recordTypeId;
        @InvocableVariable(label='GA-EOA2 Org' description='Value for Org (Org__c).')
        public String org;
        @InvocableVariable(label='GA-EOA2 Measure Priority' description='Value for Measure Priority (Measure_Priority__c).')
        public Double measurePriority;
        @InvocableVariable(label='GA-EOA2 Measure' description='Value for Measure (Measure__c).')
        public String measure;
        @InvocableVariable(label='GA-EOA2 Method Description' description='Value for Method Description (Method_Description__c).')
        public String methodDescription;
        @InvocableVariable(label='GA-EOA2 Method Name' description='Value for Method Name (Method_Name__c).')
        public String methodName;
        @InvocableVariable(label='GA-EOA2 Method Priority' description='Value for Method Priority (Method_Priority__c).')
        public Double methodPriority;
        @InvocableVariable(label='GA-EOA2 Related Level 4 V2MOM Measure' description='Salesforce ID of the Related Level 4 V2MOM Measure (Related_Level_4_V2MOM_Measure__c).')
        public String relatedLevel4V2MOMMeasureId;
        @InvocableVariable(label='GA-EOA2 V2MOM Owner' description='Salesforce ID of the V2MOM Owner (V2MOM_Owner__c).')
        public String v2momOwnerId;
        @InvocableVariable(label='GA-EOA2 Intake' description='Salesforce ID of the Intake (Intake__c).')
        public String intakeId;
        @InvocableVariable(label='GA-EOA2 Archived' description='Value for Archived (Archived__c).')
        public Boolean archived;
        @InvocableVariable(label='GA-EOA2 Version' description='Value for Version (Version__c).')
        public String version;
        @InvocableVariable(label='GA-EOA2 Method Owner' description='Value for Method Owner (Method_Owner__c). Use semicolons to separate multiple values.')
        public String methodOwner;

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
        @InvocableVariable(label='GA-EOA2 V2MOM Records' description='List of V2MOM records from the operation.')
        public List<V2MOM__c> v2momRecords = new List<V2MOM__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage V2MOMs' description='Handles Create, Modify, Retrieve, and Search actions for V2MOM records.')
    public static List<Response> manageV2MOMs(List<Request> requests) {
        List<V2MOM__c> toCreate = new List<V2MOM__c>();
        List<V2MOM__c> toUpdate = new List<V2MOM__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            responseMap.put(i, new Response());
            Request req = requests.get(i);
            
            switch on req.actionType {
                when 'Create' {
                    toCreate.add(mapRequestToV2MOM(req, new V2MOM__c()));
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.v2momId)) {
                        responseMap.get(i).message = 'Error: V2MOM ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.v2momId);
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
            String allFieldsQuery = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('V2MOM__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM V2MOM__c WHERE Id IN :idsToProcess';
            Map<Id, V2MOM__c> v2momsFromDb = new Map<Id, V2MOM__c>((List<V2MOM__c>)Database.query(allFieldsQuery));

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                Response res = responseMap.get(i);
                
                if (String.isNotBlank(req.v2momId) && v2momsFromDb.containsKey(req.v2momId)) {
                    if (req.actionType == 'Modify') {
                        toUpdate.add(mapRequestToV2MOM(req, v2momsFromDb.get(req.v2momId)));
                    } else if (req.actionType == 'Retrieve') {
                        res.success = true;
                        res.message = 'V2MOM retrieved successfully.';
                        res.v2momRecords.add(v2momsFromDb.get(req.v2momId));
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

    private static V2MOM__c mapRequestToV2MOM(Request req, V2MOM__c v2mom) {
        if(req.actionType == 'Modify') v2mom.Id = req.v2momId;
        if(req.ownerId != null) v2mom.OwnerId = req.ownerId;
        if(req.recordTypeId != null) v2mom.RecordTypeId = req.recordTypeId;
        if(req.org != null) v2mom.Org__c = req.org;
        if(req.measurePriority != null) v2mom.Measure_Priority__c = req.measurePriority;
        if(req.measure != null) v2mom.Measure__c = req.measure;
        if(req.methodDescription != null) v2mom.Method_Description__c = req.methodDescription;
        if(req.methodName != null) v2mom.Method_Name__c = req.methodName;
        if(req.methodPriority != null) v2mom.Method_Priority__c = req.methodPriority;
        if(req.relatedLevel4V2MOMMeasureId != null) v2mom.Related_Level_4_V2MOM_Measure__c = req.relatedLevel4V2MOMMeasureId;
        if(req.v2momOwnerId != null) v2mom.V2MOM_Owner__c = req.v2momOwnerId;
        if(req.intakeId != null) v2mom.Intake__c = req.intakeId;
        if(req.archived != null) v2mom.Archived__c = req.archived;
        if(req.version != null) v2mom.Version__c = req.version;
        if(req.methodOwner != null) v2mom.Method_Owner__c = req.methodOwner;
        return v2mom;
    }

    private static void handleDmlResults(Database.SaveResult[] results, List<V2MOM__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType == action) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'V2MOM ' + action.toLowerCase() + 'd successfully.';
                        res.v2momRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                }
            }
        }
    }
    
    private static void handleSearch(Request req, Response res) {
        String allFields = String.join(new List<String>(Schema.getGlobalDescribe().get('V2MOM__c').getDescribe().fields.getMap().keySet()), ',');
        String soql = 'SELECT ' + allFields + ' FROM V2MOM__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.v2momOwnerId)) {
            conditions.add('V2MOM_Owner__c = \'' + String.escapeSingleQuotes(req.v2momOwnerId) + '\'');
        }
        if (req.archived != null) {
            conditions.add('Archived__c = ' + req.archived);
        }
        if (String.isNotBlank(req.version)) {
            conditions.add('Version__c = \'' + String.escapeSingleQuotes(req.version) + '\'');
        }
        if (String.isNotBlank(req.ownerId)) {
            conditions.add('OwnerId = \'' + String.escapeSingleQuotes(req.ownerId) + '\'');
        }
        if (String.isNotBlank(req.recordTypeId)) {
            conditions.add('RecordTypeId = \'' + String.escapeSingleQuotes(req.recordTypeId) + '\'');
        }
        if (String.isNotBlank(req.org)) {
            conditions.add('Org__c = \'' + String.escapeSingleQuotes(req.org) + '\'');
        }
        if (String.isNotBlank(req.measure)) {
            conditions.add('Measure__c LIKE \'%' + String.escapeSingleQuotes(req.measure) + '%\'');
        }
        if (String.isNotBlank(req.methodName)) {
            conditions.add('Method_Name__c LIKE \'%' + String.escapeSingleQuotes(req.methodName) + '%\'');
        }
        if (String.isNotBlank(req.relatedLevel4V2MOMMeasureId)) {
            conditions.add('Related_Level_4_V2MOM_Measure__c = \'' + String.escapeSingleQuotes(req.relatedLevel4V2MOMMeasureId) + '\'');
        }
        if (String.isNotBlank(req.intakeId)) {
            conditions.add('Intake__c = \'' + String.escapeSingleQuotes(req.intakeId) + '\'');
        }
        if (String.isNotBlank(req.methodOwner)) {
            conditions.add('Method_Owner__c LIKE \'%' + String.escapeSingleQuotes(req.methodOwner) + '%\'');
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
            res.v2momRecords = Database.query(soql);
            res.success = true;
            res.message = 'V2MOM search executed. Records found: ' + res.v2momRecords.size();
        } catch (Exception e) {
            res.message = 'Error during V2MOM search: ' + e.getMessage();
        }
    }
}