/**
 * @description Manages records for the Scrum Team object (agf__ADM_Scrum_Team__c), which represents
 * a group of individuals working together. This handler manages the third set of detailed
 * configuration and metric fields for the object.
 */
public with sharing class GAEOA2ScrumTeamHandler3 {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 Team ID' description='Salesforce Team record ID. Required for Modify and Retrieve actions.')
        public String teamId;

        // --- agf__ADM_Scrum_Team__c Fields (Part 3) ---
        @InvocableVariable(label='GA-EOA2 Chatter Groups' description='Value for Chatter Groups (agf__Chatter_Groups__c).')
        public String chatterGroups;
        @InvocableVariable(label='GA-EOA2 Colocation' description='Value for Colocation (agf__Colocation__c).')
        public Double colocation;
        @InvocableVariable(label='GA-EOA2 Copy Record Type Name' description='Value for Copy Record Type Name (agf__Copy_Record_Type_Name__c).')
        public String copyRecordTypeName;
        @InvocableVariable(label='GA-EOA2 Definition of Done Check' description='Value for Definition of Done Check (agf__Definition_of_Done_Check__c).')
        public Boolean definitionOfDoneCheck;
        @InvocableVariable(label='GA-EOA2 Definition of Done' description='Value for Definition of Done (agf__Definition_of_Done__c).')
        public String definitionOfDone;
        @InvocableVariable(label='GA-EOA2 Definition of Ready Check' description='Value for Definition of Ready Check (agf__Definition_of_Ready_Check__c).')
        public Boolean definitionOfReadyCheck;
        @InvocableVariable(label='GA-EOA2 Definition of Ready' description='Value for Definition of Ready (agf__Definition_of_Ready__c).')
        public String definitionOfReady;
        @InvocableVariable(label='GA-EOA2 Distribution Lists' description='Value for Distribution Lists (agf__Distribution_Lists__c).')
        public String distributionLists;
        @InvocableVariable(label='GA-EOA2 Number of new org62 Cases' description='Value for Number of new org62 Cases (agf__Number_of_new_org62_Cases__c).')
        public Double numberOfNewOrg62Cases;
        @InvocableVariable(label='GA-EOA2 PO more than one team' description='Value for PO more than one team (agf__PO_more_than_one_team__c).')
        public Boolean poMoreThanOneTeam;
        @InvocableVariable(label='GA-EOA2 Prefer Board Column Auto Update' description='Value for Prefer Board Column Auto Update (agf__Prefer_Board_Column_Auto_Update__c).')
        public Boolean preferBoardColumnAutoUpdate;
        @InvocableVariable(label='GA-EOA2 SM more than one team' description='Value for SM more than one team (agf__SM_more_than_one_team__c).')
        public Boolean smMoreThanOneTeam;
        @InvocableVariable(label='GA-EOA2 Scrum Meeting Time/Location' description='Value for Scrum Meeting Time/Location (agf__Scrum_Meeting_Time_Location__c).')
        public String scrumMeetingTimeLocation;
        @InvocableVariable(label='GA-EOA2 Scrum Team Domain' description='Value for Scrum Team Domain (agf__Scrum_Team_Domain__c).')
        public String scrumTeamDomain;
        @InvocableVariable(label='GA-EOA2 Story Point Scale' description='Value for Story Point Scale (agf__Story_Point_Scale__c).')
        public String storyPointScale;
        @InvocableVariable(label='GA-EOA2 Team Email Group ID' description='Value for Team Email Group ID (agf__Team_Email_Group_ID__c).')
        public String teamEmailGroupId;
        @InvocableVariable(label='GA-EOA2 Team Homepage' description='Value for Team Homepage (agf__Team_Home_Page__c).')
        public String teamHomepage;
        @InvocableVariable(label='GA-EOA2 Team Queue ID' description='Value for Team Queue ID (agf__Team_Queue_ID__c).')
        public String teamQueueId;
        @InvocableVariable(label='GA-EOA2 Team Size' description='Value for Team Size (agf__Team_Size__c).')
        public Double teamSize;
        @InvocableVariable(label='GA-EOA2 One year tenure on team' description='Value for One year tenure on team (agf__Tenure_on_team__c).')
        public Double tenureOnTeam;
        @InvocableVariable(label='GA-EOA2 Velocity Type' description='Value for Velocity Type (agf__Velocity_Type__c).')
        public String velocityType;
        @InvocableVariable(label='GA-EOA2 Vision' description='Value for Vision (agf__Vision__c).')
        public String vision;

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

    @InvocableMethod(label='GA-EOA2 Manage Scrum Teams 3' description='Handles detailed configuration fields for actions on Team records.')
    public static List<Response> manageScrumTeams3(List<Request> requests) {
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
        if(req.chatterGroups != null) team.agf__Chatter_Groups__c = req.chatterGroups;
        if(req.colocation != null) team.agf__Colocation__c = req.colocation;
        if(req.copyRecordTypeName != null) team.agf__Copy_Record_Type_Name__c = req.copyRecordTypeName;
        if(req.definitionOfDoneCheck != null) team.agf__Definition_of_Done_Check__c = req.definitionOfDoneCheck;
        if(req.definitionOfDone != null) team.agf__Definition_of_Done__c = req.definitionOfDone;
        if(req.definitionOfReadyCheck != null) team.agf__Definition_of_Ready_Check__c = req.definitionOfReadyCheck;
        if(req.definitionOfReady != null) team.agf__Definition_of_Ready__c = req.definitionOfReady;
        if(req.distributionLists != null) team.agf__Distribution_Lists__c = req.distributionLists;
        if(req.numberOfNewOrg62Cases != null) team.agf__Number_of_new_org62_Cases__c = req.numberOfNewOrg62Cases;
        if(req.poMoreThanOneTeam != null) team.agf__PO_more_than_one_team__c = req.poMoreThanOneTeam;
        if(req.preferBoardColumnAutoUpdate != null) team.agf__Prefer_Board_Column_Auto_Update__c = req.preferBoardColumnAutoUpdate;
        if(req.smMoreThanOneTeam != null) team.agf__SM_more_than_one_team__c = req.smMoreThanOneTeam;
        if(req.scrumMeetingTimeLocation != null) team.agf__Scrum_Meeting_Time_Location__c = req.scrumMeetingTimeLocation;
        if(req.scrumTeamDomain != null) team.agf__Scrum_Team_Domain__c = req.scrumTeamDomain;
        if(req.storyPointScale != null) team.agf__Story_Point_Scale__c = req.storyPointScale;
        if(req.teamEmailGroupId != null) team.agf__Team_Email_Group_ID__c = req.teamEmailGroupId;
        if(req.teamHomepage != null) team.agf__Team_Home_Page__c = req.teamHomepage;
        if(req.teamQueueId != null) team.agf__Team_Queue_ID__c = req.teamQueueId;
        if(req.teamSize != null) team.agf__Team_Size__c = req.teamSize;
        if(req.tenureOnTeam != null) team.agf__Tenure_on_team__c = req.tenureOnTeam;
        if(req.velocityType != null) team.agf__Velocity_Type__c = req.velocityType;
        if(req.vision != null) team.agf__Vision__c = req.vision;
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

        if (String.isNotBlank(req.velocityType)) {
            conditions.add('agf__Velocity_Type__c = \'' + String.escapeSingleQuotes(req.velocityType) + '\'');
        }
        if (String.isNotBlank(req.copyRecordTypeName)) {
            conditions.add('agf__Copy_Record_Type_Name__c = \'' + String.escapeSingleQuotes(req.copyRecordTypeName) + '\'');
        }
        if (String.isNotBlank(req.scrumTeamDomain)) {
            conditions.add('agf__Scrum_Team_Domain__c = \'' + String.escapeSingleQuotes(req.scrumTeamDomain) + '\'');
        }
        if (String.isNotBlank(req.storyPointScale)) {
            conditions.add('agf__Story_Point_Scale__c = \'' + String.escapeSingleQuotes(req.storyPointScale) + '\'');
        }
        if (String.isNotBlank(req.teamEmailGroupId)) {
            conditions.add('agf__Team_Email_Group_ID__c = \'' + String.escapeSingleQuotes(req.teamEmailGroupId) + '\'');
        }
        if (String.isNotBlank(req.teamQueueId)) {
            conditions.add('agf__Team_Queue_ID__c = \'' + String.escapeSingleQuotes(req.teamQueueId) + '\'');
        }
        if (req.definitionOfDoneCheck != null) {
            conditions.add('agf__Definition_of_Done_Check__c = ' + req.definitionOfDoneCheck);
        }
        if (req.definitionOfReadyCheck != null) {
            conditions.add('agf__Definition_of_Ready_Check__c = ' + req.definitionOfReadyCheck);
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