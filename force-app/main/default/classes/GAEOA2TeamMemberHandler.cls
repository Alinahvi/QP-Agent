/**
 * @description Manages records for the Team Member object (agf__ADM_Scrum_Team_Member__c).
 * This object links a User to a Scrum Team, defining their role and allocation for that team.
 * According to the guide, team membership is foundational to tracking work and capacity.
 */
public with sharing class GAEOA2TeamMemberHandler {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 Team Member ID' description='Salesforce Team Member record ID. Required for Modify and Retrieve actions.')
        public String teamMemberId;

        // --- agf__ADM_Scrum_Team_Member__c Fields ---
        @InvocableVariable(label='GA-EOA2 Team' description='Salesforce ID of the related Team (agf__Scrum_Team__c).')
        public String teamId;
        @InvocableVariable(label='GA-EOA2 Member Name (User)' description='Salesforce ID of the User (agf__Member_Name__c).')
        public String memberNameUserId;
        @InvocableVariable(label='GA-EOA2 Member Name (Text)' description='Value for Member Name (agf__Member_Name_Text__c).')
        public String memberNameText;
        @InvocableVariable(label='GA-EOA2 Role' description='Value for Role (agf__Role__c).')
        public String role;
        @InvocableVariable(label='GA-EOA2 Allocation (%)' description='Value for Allocation (%) (agf__Allocation__c).')
        public Double allocation;
        @InvocableVariable(label='GA-EOA2 Department' description='Value for Department (agf__Department__c).')
        public String department;
        @InvocableVariable(label='GA-EOA2 Functional Area' description='Value for Functional Area (agf__Functional_Area__c).')
        public String functionalArea;
        @InvocableVariable(label='GA-EOA2 External Email' description='Value for External Email (agf__External_Email__c).')
        public String externalEmail;
        @InvocableVariable(label='GA-EOA2 External ID' description='Value for External ID (agf__External_ID__c).')
        public String externalId;
        @InvocableVariable(label='GA-EOA2 Req. Code' description='Value for Req. Code (agf__Req_Code__c).')
        public String reqCode;
        @InvocableVariable(label='GA-EOA2 Record Type ID' description='Salesforce ID of the Record Type (RecordTypeId).')
        public String recordTypeId;
        @InvocableVariable(label='GA-EOA2 Record Type Copy' description='Value for Record Type Copy (agf__Record_Type_Copy__c).')
        public String recordTypeCopy;

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
        @InvocableVariable(label='GA-EOA2 Team Member Records' description='List of Team Member records from the operation.')
        public List<agf__ADM_Scrum_Team_Member__c> teamMemberRecords = new List<agf__ADM_Scrum_Team_Member__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Team Members' description='Handles Create, Modify, Retrieve, and Search actions for Team Member records.')
    public static List<Response> manageTeamMembers(List<Request> requests) {
        List<agf__ADM_Scrum_Team_Member__c> toCreate = new List<agf__ADM_Scrum_Team_Member__c>();
        List<agf__ADM_Scrum_Team_Member__c> toUpdate = new List<agf__ADM_Scrum_Team_Member__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            responseMap.put(i, new Response());
            Request req = requests.get(i);
            
            switch on req.actionType {
                when 'Create' {
                    toCreate.add(mapRequestToMember(req, new agf__ADM_Scrum_Team_Member__c()));
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.teamMemberId)) {
                        responseMap.get(i).message = 'Error: Team Member ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.teamMemberId);
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
            String allFieldsQuery = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('agf__ADM_Scrum_Team_Member__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM agf__ADM_Scrum_Team_Member__c WHERE Id IN :idsToProcess';
            Map<Id, agf__ADM_Scrum_Team_Member__c> membersFromDb = new Map<Id, agf__ADM_Scrum_Team_Member__c>((List<agf__ADM_Scrum_Team_Member__c>)Database.query(allFieldsQuery));

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                Response res = responseMap.get(i);
                
                if (String.isNotBlank(req.teamMemberId) && membersFromDb.containsKey(req.teamMemberId)) {
                    if (req.actionType == 'Modify') {
                        toUpdate.add(mapRequestToMember(req, membersFromDb.get(req.teamMemberId)));
                    } else if (req.actionType == 'Retrieve') {
                        res.success = true;
                        res.message = 'Team Member retrieved successfully.';
                        res.teamMemberRecords.add(membersFromDb.get(req.teamMemberId));
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

    private static agf__ADM_Scrum_Team_Member__c mapRequestToMember(Request req, agf__ADM_Scrum_Team_Member__c member) {
        if (req.actionType == 'Modify') member.Id = req.teamMemberId;
        // The Team relationship can only be set on create, not updated.
        if (req.actionType == 'Create' && req.teamId != null) member.agf__Scrum_Team__c = req.teamId;
        if (req.memberNameUserId != null) member.agf__Member_Name__c = req.memberNameUserId;
        if (req.memberNameText != null) member.agf__Member_Name_Text__c = req.memberNameText;
        if (req.role != null) member.agf__Role__c = req.role;
        if (req.allocation != null) member.agf__Allocation__c = req.allocation;
        if (req.department != null) member.agf__Department__c = req.department;
        if (req.functionalArea != null) member.agf__Functional_Area__c = req.functionalArea;
        if (req.externalEmail != null) member.agf__External_Email__c = req.externalEmail;
        if (req.externalId != null) member.agf__External_ID__c = req.externalId;
        if (req.reqCode != null) member.agf__Req_Code__c = req.reqCode;
        if (req.recordTypeId != null) member.RecordTypeId = req.recordTypeId;
        if (req.recordTypeCopy != null) member.agf__Record_Type_Copy__c = req.recordTypeCopy;
        return member;
    }

    private static void handleDmlResults(Database.SaveResult[] results, List<agf__ADM_Scrum_Team_Member__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType == action) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Team Member ' + action.toLowerCase() + 'd successfully.';
                        res.teamMemberRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                }
            }
        }
    }
    
    private static void handleSearch(Request req, Response res) {
        String allFields = String.join(new List<String>(Schema.getGlobalDescribe().get('agf__ADM_Scrum_Team_Member__c').getDescribe().fields.getMap().keySet()), ',');
        String soql = 'SELECT ' + allFields + ' FROM agf__ADM_Scrum_Team_Member__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.teamId)) {
            conditions.add('agf__Scrum_Team__c = \'' + String.escapeSingleQuotes(req.teamId) + '\'');
        }
        if (String.isNotBlank(req.memberNameUserId)) {
            conditions.add('agf__Member_Name__c = \'' + String.escapeSingleQuotes(req.memberNameUserId) + '\'');
        }
        if (String.isNotBlank(req.role)) {
            conditions.add('agf__Role__c = \'' + String.escapeSingleQuotes(req.role) + '\'');
        }
        if (String.isNotBlank(req.department)) {
            conditions.add('agf__Department__c = \'' + String.escapeSingleQuotes(req.department) + '\'');
        }
        if (String.isNotBlank(req.functionalArea)) {
            conditions.add('agf__Functional_Area__c = \'' + String.escapeSingleQuotes(req.functionalArea) + '\'');
        }
        if (String.isNotBlank(req.externalId)) {
            conditions.add('agf__External_ID__c = \'' + String.escapeSingleQuotes(req.externalId) + '\'');
        }
        if (String.isNotBlank(req.recordTypeId)) {
            conditions.add('RecordTypeId = \'' + String.escapeSingleQuotes(req.recordTypeId) + '\'');
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
            res.teamMemberRecords = Database.query(soql);
            res.success = true;
            res.message = 'Team Member search executed. Records found: ' + res.teamMemberRecords.size();
        } catch (Exception e) {
            res.message = 'Error during Team Member search: ' + e.getMessage();
        }
    }
}