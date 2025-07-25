/**
 * @description Manages records for the Scrum Team object (agf__ADM_Scrum_Team__c), which represents
 * a group of individuals working together. This handler manages the second set of organizational
 * and reporting fields for the object.
 */
public with sharing class GAEOA2ScrumTeamHandler2 {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 Team ID' description='Salesforce Team record ID. Required for Modify and Retrieve actions.')
        public String teamId;

        // --- agf__ADM_Scrum_Team__c Fields (Part 2) ---
        @InvocableVariable(label='GA-EOA2 Cloud LU' description='Salesforce ID of the Cloud (agf__Cloud_LU__c).')
        public String cloudLuId;
        @InvocableVariable(label='GA-EOA2 Department' description='Value for Department (agf__Cloud__c).')
        public String department;
        @InvocableVariable(label='GA-EOA2 Division' description='Value for Division (agf__Division__c).')
        public String division;
        @InvocableVariable(label='GA-EOA2 Domain' description='Value for Domain (agf__Domain__c).')
        public String domain;
        @InvocableVariable(label='GA-EOA2 Product Area' description='Value for Product Area (agf__Product_Area__c).')
        public String productArea;
        @InvocableVariable(label='GA-EOA2 Product Line' description='Value for Product Line TO BE DELETED (agf__Product_Line__c).')
        public String productLine;
        @InvocableVariable(label='GA-EOA2 Org' description='Value for Org (GE_Org__c).')
        public String geOrg;
        @InvocableVariable(label='GA-EOA2 Business Unit' description='Value for Business Unit (GE_Business_Unit__c).')
        public String geBusinessUnit;
        @InvocableVariable(label='GA-EOA2 Capitalizable' description='Value for Capitalizable (agf__Capex_Enabled__c).')
        public Boolean capexEnabled;
        @InvocableVariable(label='GA-EOA2 Capitalization Lead' description='Salesforce ID of the Capitalization Lead (agf__Capex_Lead__c).')
        public String capexLeadId;
        @InvocableVariable(label='GA-EOA2 Exclude from IT Capacity Reports' description='Value for Exclude from IT Capacity Reports (agf__Exclude_Capacity_Reports__c).')
        public Boolean excludeCapacityReports;
        @InvocableVariable(label='GA-EOA2 Include Lightning Platform Freeze' description='Value for Include Lightning Platform Freeze (agf__Include_Lightning_Platform_Freeze__c).')
        public Boolean includeLightningPlatformFreeze;
        @InvocableVariable(label='GA-EOA2 Release Coverage Needed' description='Value for Release Coverage Needed (agf__Release_Coverage_Needed__c).')
        public Boolean releaseCoverageNeeded;
        @InvocableVariable(label='GA-EOA2 Rollup Reporting Group' description='Value for Rollup Reporting Group TO BE DELETED (agf__Rollup_Reporting_Group__c).')
        public String rollupReportingGroup;
        @InvocableVariable(label='GA-EOA2 Status Change Notify' description='Value for Status Change Notify (agf__Status_Change_Notify__c).')
        public Boolean statusChangeNotify;
        @InvocableVariable(label='GA-EOA2 Status Report Sections' description='Value for Status Report Sections (agf__Status_Report_Format__c).')
        public String statusReportFormat;
        @InvocableVariable(label='GA-EOA2 Enablement Delivery Team' description='Value for Enablement Delivery Team (Enablement_Delivery_Team__c).')
        public Boolean enablementDeliveryTeam;
        @InvocableVariable(label='GA-EOA2 Is COE Enablement Team' description='Value for Is COE Enablement Team (Is_COE_Enablement_Team__c).')
        public Boolean isCoeEnablementTeam;
        @InvocableVariable(label='GA-EOA2 Is CSG Enablement Team' description='Value for Is CSG Enablement Team (Is_CSG_Enablement_Team__c).')
        public Boolean isCsgEnablementTeam;

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

    @InvocableMethod(label='GA-EOA2 Manage Scrum Teams 2' description='Handles organizational and reporting fields for actions on Team records.')
    public static List<Response> manageScrumTeams2(List<Request> requests) {
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
        if(req.cloudLuId != null) team.agf__Cloud_LU__c = req.cloudLuId;
        if(req.department != null) team.agf__Cloud__c = req.department;
        if(req.division != null) team.agf__Division__c = req.division;
        if(req.domain != null) team.agf__Domain__c = req.domain;
        if(req.productArea != null) team.agf__Product_Area__c = req.productArea;
        if(req.productLine != null) team.agf__Product_Line__c = req.productLine;
        if(req.geOrg != null) team.GE_Org__c = req.geOrg;
        if(req.geBusinessUnit != null) team.GE_Business_Unit__c = req.geBusinessUnit;
        if(req.capexEnabled != null) team.agf__Capex_Enabled__c = req.capexEnabled;
        if(req.capexLeadId != null) team.agf__Capex_Lead__c = req.capexLeadId;
        if(req.excludeCapacityReports != null) team.agf__Exclude_Capacity_Reports__c = req.excludeCapacityReports;
        if(req.includeLightningPlatformFreeze != null) team.agf__Include_Lightning_Platform_Freeze__c = req.includeLightningPlatformFreeze;
        if(req.releaseCoverageNeeded != null) team.agf__Release_Coverage_Needed__c = req.releaseCoverageNeeded;
        if(req.rollupReportingGroup != null) team.agf__Rollup_Reporting_Group__c = req.rollupReportingGroup;
        if(req.statusChangeNotify != null) team.agf__Status_Change_Notify__c = req.statusChangeNotify;
        if(req.statusReportFormat != null) team.agf__Status_Report_Format__c = req.statusReportFormat;
        if(req.enablementDeliveryTeam != null) team.Enablement_Delivery_Team__c = req.enablementDeliveryTeam;
        if(req.isCoeEnablementTeam != null) team.Is_COE_Enablement_Team__c = req.isCoeEnablementTeam;
        if(req.isCsgEnablementTeam != null) team.Is_CSG_Enablement_Team__c = req.isCsgEnablementTeam;
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

        if (String.isNotBlank(req.department)) {
            conditions.add('agf__Cloud__c = \'' + String.escapeSingleQuotes(req.department) + '\'');
        }
        if (String.isNotBlank(req.division)) {
            conditions.add('agf__Division__c = \'' + String.escapeSingleQuotes(req.division) + '\'');
        }
        if (String.isNotBlank(req.domain)) {
            conditions.add('agf__Domain__c = \'' + String.escapeSingleQuotes(req.domain) + '\'');
        }
        if (String.isNotBlank(req.productArea)) {
            conditions.add('agf__Product_Area__c = \'' + String.escapeSingleQuotes(req.productArea) + '\'');
        }
        if (String.isNotBlank(req.cloudLuId)) {
            conditions.add('agf__Cloud_LU__c = \'' + String.escapeSingleQuotes(req.cloudLuId) + '\'');
        }
        if (String.isNotBlank(req.geOrg)) {
            conditions.add('GE_Org__c = \'' + String.escapeSingleQuotes(req.geOrg) + '\'');
        }
        if (String.isNotBlank(req.geBusinessUnit)) {
            conditions.add('GE_Business_Unit__c = \'' + String.escapeSingleQuotes(req.geBusinessUnit) + '\'');
        }
        if (String.isNotBlank(req.capexLeadId)) {
            conditions.add('agf__Capex_Lead__c = \'' + String.escapeSingleQuotes(req.capexLeadId) + '\'');
        }
        if (req.capexEnabled != null) {
            conditions.add('agf__Capex_Enabled__c = ' + req.capexEnabled);
        }
        if (req.enablementDeliveryTeam != null) {
            conditions.add('Enablement_Delivery_Team__c = ' + req.enablementDeliveryTeam);
        }
        if (req.isCoeEnablementTeam != null) {
            conditions.add('Is_COE_Enablement_Team__c = ' + req.isCoeEnablementTeam);
        }
        if (req.isCsgEnablementTeam != null) {
            conditions.add('Is_CSG_Enablement_Team__c = ' + req.isCsgEnablementTeam);
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