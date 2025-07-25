/**
 * @description Manages records for the Scrum Team object (agf__ADM_Scrum_Team__c), which represents
 * a group of individuals working together. This handler manages the first set of core fields for the object.
 * Per the guide, Teams should have defined roles and are associated with Projects.
 */
public with sharing class GAEOA2ScrumTeamHandler1 {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 Team ID' description='Salesforce Team record ID. Required for Modify and Retrieve actions.')
        public String teamId;

        // --- agf__ADM_Scrum_Team__c Fields (Part 1) ---
        @InvocableVariable(label='GA-EOA2 Team Name' description='Value for Team Name (Name).')
        public String teamName;
        @InvocableVariable(label='GA-EOA2 Owner' description='Salesforce ID of the record owner.')
        public String ownerId;
        @InvocableVariable(label='GA-EOA2 Record Type ID' description='Salesforce ID of the record type.')
        public String recordTypeId;
        @InvocableVariable(label='GA-EOA2 Active' description='Value for Active (agf__Active__c).')
        public Boolean active;
        @InvocableVariable(label='GA-EOA2 Overall Status' description='Value for Overall Status (agf__Overall_Status__c).')
        public String overallStatus;
        @InvocableVariable(label='GA-EOA2 Type' description='Value for Type (agf__Type__c).')
        public String type;
        @InvocableVariable(label='GA-EOA2 Start Date' description='Value for Start Date (agf__Start_Date__c). Format: YYYY-MM-DD')
        public Date startDate;
        @InvocableVariable(label='GA-EOA2 End Date' description='Value for End Date (agf__End_Date__c). Format: YYYY-MM-DD')
        public Date endDate;
        @InvocableVariable(label='GA-EOA2 Product Owner' description='Salesforce ID of the Product Owner (agf__Product_Owner__c).')
        public String productOwnerId;
        @InvocableVariable(label='GA-EOA2 Scrum Master' description='Salesforce ID of the Scrum Master (agf__Scrum_Master__c).')
        public String scrumMasterId;
        @InvocableVariable(label='GA-EOA2 Leader' description='Salesforce ID of the Leader (Leader__c).')
        public String leaderId;
        @InvocableVariable(label='GA-EOA2 Business Hours' description='Salesforce ID of the Business Hours (agf__Business_Hours__c).')
        public String businessHoursId;
        @InvocableVariable(label='GA-EOA2 Kanban' description='Value for Kanban (agf__Kanban__c).')
        public Boolean kanban;
        @InvocableVariable(label='GA-EOA2 Board Preference' description='Value for Board Preference (agf__Board_Preference__c).')
        public String boardPreference;
        @InvocableVariable(label='GA-EOA2 External ID' description='Value for External ID (agf__External_ID__c).')
        public String externalId;
        @InvocableVariable(label='GA-EOA2 External Name' description='Value for External Name (agf__External_Name__c).')
        public String externalName;
        @InvocableVariable(label='GA-EOA2 Scrumforce ID' description='Value for Scrumforce ID (agf__Scrumforce_ID__c).')
        public String scrumforceId;

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
        @InvocableVariable(label='GA-EOA2 Team Records' description='List of Team records from the operation.')
        public List<agf__ADM_Scrum_Team__c> teamRecords = new List<agf__ADM_Scrum_Team__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Scrum Teams 1' description='Handles core fields for Create, Modify, Retrieve, and Search actions on Team records.')
    public static List<Response> manageScrumTeams1(List<Request> requests) {
        List<agf__ADM_Scrum_Team__c> toCreate = new List<agf__ADM_Scrum_Team__c>();
        List<agf__ADM_Scrum_Team__c> toUpdate = new List<agf__ADM_Scrum_Team__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            responseMap.put(i, new Response());
            Request req = requests.get(i);
            
            switch on req.actionType {
                when 'Create' {
                    toCreate.add(mapRequestToTeam(req, new agf__ADM_Scrum_Team__c()));
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.teamId)) {
                        responseMap.get(i).message = 'Error: Team ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.teamId);
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
            String allFieldsQuery = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('agf__ADM_Scrum_Team__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM agf__ADM_Scrum_Team__c WHERE Id IN :idsToProcess';
            Map<Id, agf__ADM_Scrum_Team__c> teamsFromDb = new Map<Id, agf__ADM_Scrum_Team__c>((List<agf__ADM_Scrum_Team__c>)Database.query(allFieldsQuery));

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                Response res = responseMap.get(i);
                
                if (String.isNotBlank(req.teamId) && teamsFromDb.containsKey(req.teamId)) {
                    if (req.actionType == 'Modify') {
                        toUpdate.add(mapRequestToTeam(req, teamsFromDb.get(req.teamId)));
                    } else if (req.actionType == 'Retrieve') {
                        res.success = true;
                        res.message = 'Team retrieved successfully.';
                        res.teamRecords.add(teamsFromDb.get(req.teamId));
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

    private static agf__ADM_Scrum_Team__c mapRequestToTeam(Request req, agf__ADM_Scrum_Team__c team) {
        if(req.actionType == 'Modify') team.Id = req.teamId;
        if(req.teamName != null) team.Name = req.teamName;
        if(req.ownerId != null) team.OwnerId = req.ownerId;
        if(req.recordTypeId != null) team.RecordTypeId = req.recordTypeId;
        if(req.active != null) team.agf__Active__c = req.active;
        if(req.overallStatus != null) team.agf__Overall_Status__c = req.overallStatus;
        if(req.type != null) team.agf__Type__c = req.type;
        if(req.startDate != null) team.agf__Start_Date__c = req.startDate;
        if(req.endDate != null) team.agf__End_Date__c = req.endDate;
        if(req.productOwnerId != null) team.agf__Product_Owner__c = req.productOwnerId;
        if(req.scrumMasterId != null) team.agf__Scrum_Master__c = req.scrumMasterId;
        if(req.leaderId != null) team.Leader__c = req.leaderId;
        if(req.businessHoursId != null) team.agf__Business_Hours__c = req.businessHoursId;
        if(req.kanban != null) team.agf__Kanban__c = req.kanban;
        if(req.boardPreference != null) team.agf__Board_Preference__c = req.boardPreference;
        if(req.externalId != null) team.agf__External_ID__c = req.externalId;
        if(req.externalName != null) team.agf__External_Name__c = req.externalName;
        if(req.scrumforceId != null) team.agf__Scrumforce_ID__c = req.scrumforceId;
        return team;
    }

    private static void handleDmlResults(Database.SaveResult[] results, List<agf__ADM_Scrum_Team__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType == action) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Team ' + action.toLowerCase() + 'd successfully.';
                        res.teamRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                }
            }
        }
    }
    
    private static void handleSearch(Request req, Response res) {
        String allFields = String.join(new List<String>(Schema.getGlobalDescribe().get('agf__ADM_Scrum_Team__c').getDescribe().fields.getMap().keySet()), ',');
        String soql = 'SELECT ' + allFields + ' FROM agf__ADM_Scrum_Team__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.teamName)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.teamName) + '%\'');
        }
        if (req.active != null) {
            conditions.add('agf__Active__c = ' + req.active);
        }
        if (String.isNotBlank(req.overallStatus)) {
            conditions.add('agf__Overall_Status__c = \'' + String.escapeSingleQuotes(req.overallStatus) + '\'');
        }
        if (String.isNotBlank(req.type)) {
            conditions.add('agf__Type__c = \'' + String.escapeSingleQuotes(req.type) + '\'');
        }
        if (String.isNotBlank(req.ownerId)) {
            conditions.add('OwnerId = \'' + String.escapeSingleQuotes(req.ownerId) + '\'');
        }
        if (String.isNotBlank(req.recordTypeId)) {
            conditions.add('RecordTypeId = \'' + String.escapeSingleQuotes(req.recordTypeId) + '\'');
        }
        if (String.isNotBlank(req.productOwnerId)) {
            conditions.add('agf__Product_Owner__c = \'' + String.escapeSingleQuotes(req.productOwnerId) + '\'');
        }
        if (String.isNotBlank(req.scrumMasterId)) {
            conditions.add('agf__Scrum_Master__c = \'' + String.escapeSingleQuotes(req.scrumMasterId) + '\'');
        }
        if (String.isNotBlank(req.leaderId)) {
            conditions.add('Leader__c = \'' + String.escapeSingleQuotes(req.leaderId) + '\'');
        }
        if (String.isNotBlank(req.externalId)) {
            conditions.add('agf__External_ID__c = \'' + String.escapeSingleQuotes(req.externalId) + '\'');
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
            res.teamRecords = Database.query(soql);
            res.success = true;
            res.message = 'Team search executed. Records found: ' + res.teamRecords.size();
        } catch (Exception e) {
            res.message = 'Error during Team search: ' + e.getMessage();
        }
    }
}