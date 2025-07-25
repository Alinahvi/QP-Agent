/**
 * @description Handles CRUD operations for Team Dependency records (agf__ADM_Team_Dependency__c).
 * This object is used to track dependencies between different teams, where one team
 * (the provider) must deliver something for another team (the dependent) to proceed.
 */
public with sharing class GAEOA2TeamDependencyHandler {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 Team Dependency ID' description='Salesforce Team Dependency record ID. Required for Modify and Retrieve actions.')
        public String teamDependencyId;

        // --- agf__ADM_Team_Dependency__c Fields ---
        @InvocableVariable(label='GA-EOA2 Deliverable' description='Value for Deliverable (agf__Deliverable__c).')
        public String deliverable;
        @InvocableVariable(label='GA-EOA2 Needed by (date)' description='Value for Needed by (date) (agf__Deliver_By__c).')
        public Date deliverBy;
        @InvocableVariable(label='GA-EOA2 Dependency Status' description='Value for Dependency Status (agf__Dependency_Status__c).')
        public String dependencyStatus;
        @InvocableVariable(label='GA-EOA2 Dependency Size' description='Value for Dependency Size (agf__Dependency_Size__c).')
        public String dependencySize;
        @InvocableVariable(label='GA-EOA2 Notes' description='Value for Notes (agf__Notes__c).')
        public String notes;
        @InvocableVariable(label='GA-EOA2 Expectations' description='Value for Expectations (Expectations__c).')
        public String expectations;
        @InvocableVariable(label='GA-EOA2 Hours' description='Value for Hours (Hours__c).')
        public Double hours;
        @InvocableVariable(label='GA-EOA2 External ID' description='Value for External ID (agf__External_ID__c).')
        public String externalId;
        @InvocableVariable(label='GA-EOA2 Team Providing Deliverable' description='Salesforce ID of the Team Providing Deliverable (agf__Provider_Team__c).')
        public String providerTeamId;
        @InvocableVariable(label='GA-EOA2 Team With Dependency' description='Salesforce ID of the Team With Dependency (agf__Dependent_Team__c).')
        public String dependentTeamId;
        @InvocableVariable(label='GA-EOA2 Work For Deliverable' description='Salesforce ID of the Work For Deliverable (agf__Provider_User_Story__c).')
        public String providerUserStoryId;
        @InvocableVariable(label='GA-EOA2 Work With Dependency' description='Salesforce ID of the Work With Dependency (agf__Dependent_User_Story__c).')
        public String dependentUserStoryId;
        @InvocableVariable(label='GA-EOA2 Epic' description='Salesforce ID of the Epic (agf__Epic__c).')
        public String epicId;
        @InvocableVariable(label='GA-EOA2 Project' description='Salesforce ID of the Project (Project__c).')
        public String projectId;
        @InvocableVariable(label='GA-EOA2 Program' description='Salesforce ID of the Program (Program__c).')
        public String programId;
        @InvocableVariable(label='GA-EOA2 Target Build' description='Salesforce ID of the Target Build (agf__Target_Build__c).')
        public String targetBuildId;
        @InvocableVariable(label='GA-EOA2 Associated with Program' description='Salesforce ID of the Associated with Program (agf__Associated_with_Program__c).')
        public String associatedWithProgramId;
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
        @InvocableVariable(label='GA-EOA2 Team Dependency Records' description='List of Team Dependency records from the operation.')
        public List<agf__ADM_Team_Dependency__c> teamDependencyRecords = new List<agf__ADM_Team_Dependency__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Team Dependencies' description='Handles Create, Modify, Retrieve, and Search actions for Team Dependency records.')
    public static List<Response> manageTeamDependencies(List<Request> requests) {
        List<agf__ADM_Team_Dependency__c> toCreate = new List<agf__ADM_Team_Dependency__c>();
        List<agf__ADM_Team_Dependency__c> toUpdate = new List<agf__ADM_Team_Dependency__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            responseMap.put(i, new Response());
            Request req = requests.get(i);
            
            switch on req.actionType {
                when 'Create' {
                    toCreate.add(mapRequestToDependency(req, new agf__ADM_Team_Dependency__c()));
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.teamDependencyId)) {
                        responseMap.get(i).message = 'Error: Team Dependency ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.teamDependencyId);
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
            String allFieldsQuery = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('agf__ADM_Team_Dependency__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM agf__ADM_Team_Dependency__c WHERE Id IN :idsToProcess';
            Map<Id, agf__ADM_Team_Dependency__c> dependenciesFromDb = new Map<Id, agf__ADM_Team_Dependency__c>((List<agf__ADM_Team_Dependency__c>)Database.query(allFieldsQuery));

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                Response res = responseMap.get(i);
                
                if (String.isNotBlank(req.teamDependencyId) && dependenciesFromDb.containsKey(req.teamDependencyId)) {
                    if (req.actionType == 'Modify') {
                        toUpdate.add(mapRequestToDependency(req, dependenciesFromDb.get(req.teamDependencyId)));
                    } else if (req.actionType == 'Retrieve') {
                        res.success = true;
                        res.message = 'Team Dependency retrieved successfully.';
                        res.teamDependencyRecords.add(dependenciesFromDb.get(req.teamDependencyId));
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

    private static agf__ADM_Team_Dependency__c mapRequestToDependency(Request req, agf__ADM_Team_Dependency__c dep) {
        if(req.actionType == 'Modify') dep.Id = req.teamDependencyId;
        if(req.deliverable != null) dep.agf__Deliverable__c = req.deliverable;
        if(req.deliverBy != null) dep.agf__Deliver_By__c = req.deliverBy;
        if(req.dependencyStatus != null) dep.agf__Dependency_Status__c = req.dependencyStatus;
        if(req.dependencySize != null) dep.agf__Dependency_Size__c = req.dependencySize;
        if(req.notes != null) dep.agf__Notes__c = req.notes;
        if(req.expectations != null) dep.Expectations__c = req.expectations;
        if(req.hours != null) dep.Hours__c = req.hours;
        if(req.externalId != null) dep.agf__External_ID__c = req.externalId;
        if(req.providerTeamId != null) dep.agf__Provider_Team__c = req.providerTeamId;
        if(req.dependentTeamId != null) dep.agf__Dependent_Team__c = req.dependentTeamId;
        if(req.providerUserStoryId != null) dep.agf__Provider_User_Story__c = req.providerUserStoryId;
        if(req.dependentUserStoryId != null) dep.agf__Dependent_User_Story__c = req.dependentUserStoryId;
        if(req.epicId != null) dep.agf__Epic__c = req.epicId;
        if(req.projectId != null) dep.Project__c = req.projectId;
        if(req.programId != null) dep.Program__c = req.programId;
        if(req.targetBuildId != null) dep.agf__Target_Build__c = req.targetBuildId;
        if(req.associatedWithProgramId != null) dep.agf__Associated_with_Program__c = req.associatedWithProgramId;
        if(req.ownerId != null) dep.OwnerId = req.ownerId;
        return dep;
    }

    private static void handleDmlResults(Database.SaveResult[] results, List<agf__ADM_Team_Dependency__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType == action) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Team Dependency ' + action.toLowerCase() + 'd successfully.';
                        res.teamDependencyRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                }
            }
        }
    }
    
    private static void handleSearch(Request req, Response res) {
        String allFields = String.join(new List<String>(Schema.getGlobalDescribe().get('agf__ADM_Team_Dependency__c').getDescribe().fields.getMap().keySet()), ',');
        String soql = 'SELECT ' + allFields + ' FROM agf__ADM_Team_Dependency__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.dependencyStatus)) {
            conditions.add('agf__Dependency_Status__c = \'' + String.escapeSingleQuotes(req.dependencyStatus) + '\'');
        }
        if (String.isNotBlank(req.providerTeamId)) {
            conditions.add('agf__Provider_Team__c = \'' + String.escapeSingleQuotes(req.providerTeamId) + '\'');
        }
        if (String.isNotBlank(req.dependentTeamId)) {
            conditions.add('agf__Dependent_Team__c = \'' + String.escapeSingleQuotes(req.dependentTeamId) + '\'');
        }
        if (String.isNotBlank(req.ownerId)) {
            conditions.add('OwnerId = \'' + String.escapeSingleQuotes(req.ownerId) + '\'');
        }
        if (String.isNotBlank(req.deliverable)) {
            conditions.add('agf__Deliverable__c LIKE \'%' + String.escapeSingleQuotes(req.deliverable) + '%\'');
        }
        if (String.isNotBlank(req.dependencySize)) {
            conditions.add('agf__Dependency_Size__c = \'' + String.escapeSingleQuotes(req.dependencySize) + '\'');
        }
        if (String.isNotBlank(req.providerUserStoryId)) {
            conditions.add('agf__Provider_User_Story__c = \'' + String.escapeSingleQuotes(req.providerUserStoryId) + '\'');
        }
        if (String.isNotBlank(req.dependentUserStoryId)) {
            conditions.add('agf__Dependent_User_Story__c = \'' + String.escapeSingleQuotes(req.dependentUserStoryId) + '\'');
        }
        if (String.isNotBlank(req.epicId)) {
            conditions.add('agf__Epic__c = \'' + String.escapeSingleQuotes(req.epicId) + '\'');
        }
        if (String.isNotBlank(req.projectId)) {
            conditions.add('Project__c = \'' + String.escapeSingleQuotes(req.projectId) + '\'');
        }
        if (String.isNotBlank(req.programId)) {
            conditions.add('Program__c = \'' + String.escapeSingleQuotes(req.programId) + '\'');
        }
        if (String.isNotBlank(req.targetBuildId)) {
            conditions.add('agf__Target_Build__c = \'' + String.escapeSingleQuotes(req.targetBuildId) + '\'');
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
            res.teamDependencyRecords = Database.query(soql);
            res.success = true;
            res.message = 'Team Dependency search executed. Records found: ' + res.teamDependencyRecords.size();
        } catch (Exception e) {
            res.message = 'Error during Team Dependency search: ' + e.getMessage();
        }
    }
}