public with sharing class GAEOA2EpicHandler {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 Epic ID' description='Salesforce Epic record ID. Required for Modify and Retrieve actions.')
        public String epicId;

        // --- agf__ADM_Epic__c Fields ---
        @InvocableVariable(label='GA-EOA2 Epic Name' description='Value for the Epic Name (Name) field.')
        public String epicName;
        @InvocableVariable(label='GA-EOA2 Description' description='Value for the Description (agf__Description__c) field.')
        public String description;
        @InvocableVariable(label='GA-EOA2 Start Date' description='Value for the Start Date (agf__Start_Date__c) field. Format: YYYY-MM-DD')
        public Date startDate;
        @InvocableVariable(label='GA-EOA2 End Date' description='Value for the End Date (agf__End_Date__c) field. Format: YYYY-MM-DD')
        public Date endDate;
        @InvocableVariable(label='GA-EOA2 Category' description='Value for the Category (agf__Category__c) field.')
        public String category;
        @InvocableVariable(label='GA-EOA2 Health' description='Value for the Health (agf__Health__c) field.')
        public String health;
        @InvocableVariable(label='GA-EOA2 T-Shirt Size' description='Value for the T-Shirt Size (agf__T_Shirt_Size__c) field.')
        public String tShirtSize;
        @InvocableVariable(label='GA-EOA2 Design Complete' description='Value for the Design Complete (agf__Design_Complete__c) field.')
        public String designComplete;
        @InvocableVariable(label='GA-EOA2 Tech Design Complete' description='Value for the Tech Design Complete (agf__Tech_Design_Complete__c) field.')
        public String techDesignComplete;
        @InvocableVariable(label='GA-EOA2 Test Design Complete' description='Value for the Test Design Complete (agf__Test_Design_Complete__c) field.')
        public String testDesignComplete;
        @InvocableVariable(label='GA-EOA2 Committed By Team' description='Value for Committed By Team (agf__Committed_By_Team__c).')
        public Boolean committedByTeam;
        @InvocableVariable(label='GA-EOA2 Create Matching Work Item' description='Value for Create Matching Work Item (Create_Matching_Work_Item__c).')
        public Boolean createMatchingWorkItem;
        @InvocableVariable(label='GA-EOA2 Milestone' description='Value for Milestone (Milestone__c).')
        public Boolean milestone;
        @InvocableVariable(label='GA-EOA2 Built From Template' description='Value for Built From Template (Built_From_Template__c).')
        public Boolean builtFromTemplate;
        @InvocableVariable(label='GA-EOA2 Contains Deliverable' description='Value for Contains Deliverable (Contains_Deliverable__c).')
        public Boolean containsDeliverable;
        @InvocableVariable(label='GA-EOA2 Priority' description='Value for Priority (agf__Priority__c).')
        public Double priority;
        @InvocableVariable(label='GA-EOA2 Length of Learning' description='Value for Length of Learning (Length_of_Learning__c).')
        public Double lengthOfLearning;
        @InvocableVariable(label='GA-EOA2 Project' description='Salesforce ID of the related Project (agf__Project__c).')
        public String projectId;
        @InvocableVariable(label='GA-EOA2 Team' description='Salesforce ID of the related Team (agf__Team__c).')
        public String teamId;
        @InvocableVariable(label='GA-EOA2 Design Lead' description='Salesforce ID of the Design Lead (agf__Design_Lead__c).')
        public String designLeadId;
        @InvocableVariable(label='GA-EOA2 Development Lead' description='Salesforce ID of the Development Lead (agf__Development_Lead__c).')
        public String developmentLeadId;
        @InvocableVariable(label='GA-EOA2 Quality Lead' description='Salesforce ID of the Quality Lead (agf__Quality_Lead__c).')
        public String qualityLeadId;
        @InvocableVariable(label='GA-EOA2 Performance Lead' description='Salesforce ID of the Performance Lead (agf__Performance_Lead__c).')
        public String performanceLeadId;
        @InvocableVariable(label='GA-EOA2 Scheduled Build' description='Salesforce ID of the Scheduled Build (agf__Scheduled_Build__c).')
        public String scheduledBuildId;
        @InvocableVariable(label='GA-EOA2 Associated Intake' description='Salesforce ID of the Associated Intake (Associated_Intake__c).')
        public String associatedIntakeId;
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
        @InvocableVariable(label='GA-EOA2 Epic Records' description='List of Epic records from the operation.')
        public List<agf__ADM_Epic__c> epicRecords = new List<agf__ADM_Epic__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Epics' description='Handles Create, Modify, Retrieve, and Search actions for Epic records.')
    public static List<Response> manageEpics(List<Request> requests) {
        List<agf__ADM_Epic__c> toCreate = new List<agf__ADM_Epic__c>();
        List<agf__ADM_Epic__c> toUpdate = new List<agf__ADM_Epic__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            responseMap.put(i, new Response());
            Request req = requests.get(i);
            
            switch on req.actionType {
                when 'Create' {
                    toCreate.add(mapRequestToEpic(req, new agf__ADM_Epic__c()));
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.epicId)) {
                        responseMap.get(i).message = 'Error: Epic ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.epicId);
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
            String allFieldsQuery = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('agf__ADM_Epic__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM agf__ADM_Epic__c WHERE Id IN :idsToProcess';
            Map<Id, agf__ADM_Epic__c> epicsFromDb = new Map<Id, agf__ADM_Epic__c>((List<agf__ADM_Epic__c>)Database.query(allFieldsQuery));

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                Response res = responseMap.get(i);
                
                if (String.isNotBlank(req.epicId) && epicsFromDb.containsKey(req.epicId)) {
                    if (req.actionType == 'Modify') {
                        toUpdate.add(mapRequestToEpic(req, epicsFromDb.get(req.epicId)));
                    } else if (req.actionType == 'Retrieve') {
                        res.success = true;
                        res.message = 'Epic retrieved successfully.';
                        res.epicRecords.add(epicsFromDb.get(req.epicId));
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

    private static agf__ADM_Epic__c mapRequestToEpic(Request req, agf__ADM_Epic__c epic) {
        if(req.actionType == 'Modify') epic.Id = req.epicId;
        if(req.epicName != null) epic.Name = req.epicName;
        if(req.description != null) epic.agf__Description__c = req.description;
        if(req.startDate != null) epic.agf__Start_Date__c = req.startDate;
        if(req.endDate != null) epic.agf__End_Date__c = req.endDate;
        if(req.category != null) epic.agf__Category__c = req.category;
        if(req.health != null) epic.agf__Health__c = req.health;
        if(req.tShirtSize != null) epic.agf__T_Shirt_Size__c = req.tShirtSize;
        if(req.designComplete != null) epic.agf__Design_Complete__c = req.designComplete;
        if(req.techDesignComplete != null) epic.agf__Tech_Design_Complete__c = req.techDesignComplete;
        if(req.testDesignComplete != null) epic.agf__Test_Design_Complete__c = req.testDesignComplete;
        if(req.committedByTeam != null) epic.agf__Committed_By_Team__c = req.committedByTeam;
        if(req.createMatchingWorkItem != null) epic.Create_Matching_Work_Item__c = req.createMatchingWorkItem;
        if(req.milestone != null) epic.Milestone__c = req.milestone;
        if(req.builtFromTemplate != null) epic.Built_From_Template__c = req.builtFromTemplate;
        if(req.containsDeliverable != null) epic.Contains_Deliverable__c = req.containsDeliverable;
        if(req.priority != null) epic.agf__Priority__c = req.priority;
        if(req.lengthOfLearning != null) epic.Length_of_Learning__c = req.lengthOfLearning;
        if(req.projectId != null) epic.agf__Project__c = req.projectId;
        if(req.teamId != null) epic.agf__Team__c = req.teamId;
        if(req.designLeadId != null) epic.agf__Design_Lead__c = req.designLeadId;
        if(req.developmentLeadId != null) epic.agf__Development_Lead__c = req.developmentLeadId;
        if(req.qualityLeadId != null) epic.agf__Quality_Lead__c = req.qualityLeadId;
        if(req.performanceLeadId != null) epic.agf__Performance_Lead__c = req.performanceLeadId;
        if(req.scheduledBuildId != null) epic.agf__Scheduled_Build__c = req.scheduledBuildId;
        if(req.associatedIntakeId != null) epic.Associated_Intake__c = req.associatedIntakeId;
        if(req.ownerId != null) epic.OwnerId = req.ownerId;
        return epic;
    }

    private static void handleDmlResults(Database.SaveResult[] results, List<agf__ADM_Epic__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType == action) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Epic ' + action.toLowerCase() + 'd successfully.';
                        res.epicRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                }
            }
        }
    }
    
    private static void handleSearch(Request req, Response res) {
        String allFields = String.join(new List<String>(Schema.getGlobalDescribe().get('agf__ADM_Epic__c').getDescribe().fields.getMap().keySet()), ',');
        String soql = 'SELECT ' + allFields + ' FROM agf__ADM_Epic__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.epicName)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.epicName) + '%\'');
        }
        if (String.isNotBlank(req.category)) {
            conditions.add('agf__Category__c = \'' + String.escapeSingleQuotes(req.category) + '\'');
        }
        if (String.isNotBlank(req.health)) {
            conditions.add('agf__Health__c = \'' + String.escapeSingleQuotes(req.health) + '\'');
        }
        if (String.isNotBlank(req.ownerId)) {
            conditions.add('OwnerId = \'' + String.escapeSingleQuotes(req.ownerId) + '\'');
        }
        if (String.isNotBlank(req.projectId)) {
            conditions.add('agf__Project__c = \'' + String.escapeSingleQuotes(req.projectId) + '\'');
        }
        if (String.isNotBlank(req.teamId)) {
            conditions.add('agf__Team__c = \'' + String.escapeSingleQuotes(req.teamId) + '\'');
        }
        if (String.isNotBlank(req.tShirtSize)) {
            conditions.add('agf__T_Shirt_Size__c = \'' + String.escapeSingleQuotes(req.tShirtSize) + '\'');
        }
        if (String.isNotBlank(req.designLeadId)) {
            conditions.add('agf__Design_Lead__c = \'' + String.escapeSingleQuotes(req.designLeadId) + '\'');
        }
        if (String.isNotBlank(req.developmentLeadId)) {
            conditions.add('agf__Development_Lead__c = \'' + String.escapeSingleQuotes(req.developmentLeadId) + '\'');
        }
        if (String.isNotBlank(req.qualityLeadId)) {
            conditions.add('agf__Quality_Lead__c = \'' + String.escapeSingleQuotes(req.qualityLeadId) + '\'');
        }
        if (String.isNotBlank(req.performanceLeadId)) {
            conditions.add('agf__Performance_Lead__c = \'' + String.escapeSingleQuotes(req.performanceLeadId) + '\'');
        }
        if (String.isNotBlank(req.scheduledBuildId)) {
            conditions.add('agf__Scheduled_Build__c = \'' + String.escapeSingleQuotes(req.scheduledBuildId) + '\'');
        }
        if (String.isNotBlank(req.associatedIntakeId)) {
            conditions.add('Associated_Intake__c = \'' + String.escapeSingleQuotes(req.associatedIntakeId) + '\'');
        }
        if (req.milestone != null) {
            conditions.add('Milestone__c = ' + req.milestone);
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
            res.epicRecords = Database.query(soql);
            res.success = true;
            res.message = 'Epic search executed. Records found: ' + res.epicRecords.size();
        } catch (Exception e) {
            res.message = 'Error during Epic search: ' + e.getMessage();
        }
    }
}