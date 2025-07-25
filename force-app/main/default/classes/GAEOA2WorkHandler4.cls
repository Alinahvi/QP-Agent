public with sharing class GAEOA2WorkHandler4 {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Modify | Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 Work ID' description='Salesforce Work record ID. Required for Modify and Retrieve actions.')
        public String workId;
        
        // --- agf__ADM_Work__c Fields Part 4 & Search ---
        @InvocableVariable(label='GA-EOA2 Red Account' description='Value for the Red Account (agf__Red_Account__c) field.')
        public Boolean agfRedAccount;
        @InvocableVariable(label='GA-EOA2 Regressed' description='Value for the Regressed (agf__Regressed__c) field.')
        public Boolean agfRegressed;
        @InvocableVariable(label='GA-EOA2 Related URL' description='Value for the Related URL (agf__Related_URL__c) field.')
        public String agfRelatedUrl;
        @InvocableVariable(label='GA-EOA2 New Related Work' description='Value for the New Related Work (agf__Related_Work__c) field.')
        public String agfRelatedWork;
        @InvocableVariable(label='GA-EOA2 Release' description='Value for the Release (agf__Release__c) field.')
        public String agfRelease;
        @InvocableVariable(label='GA-EOA2 Request Senior Mgr Review' description='Value for the Request Senior Mgr Review (agf__Request_RD_Mgr_Review__c) field.')
        public Boolean agfRequestRdMgrReview;
        @InvocableVariable(label='GA-EOA2 Test Resolution' description='Value for the Test Resolution (agf__Resolution__c) field.')
        public String agfResolution;
        @InvocableVariable(label='GA-EOA2 Resolved By' description='Value for the Resolved By (agf__Resolved_By__c) field.')
        public String agfResolvedBy;
        @InvocableVariable(label='GA-EOA2 Resolved On' description='Value for the Resolved On (agf__Resolved_On__c) field. Supported formats: YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public Datetime agfResolvedOn;
        @InvocableVariable(label='GA-EOA2 Root Cause Analysis' description='Value for the Root Cause Analysis (agf__Root_Cause_Analysis_2__c) field.')
        public String agfRootCauseAnalysis2;
        @InvocableVariable(label='GA-EOA2 S1 App Build Number' description='Value for the S1 App Build Number (agf__S1_App_Build_Number__c) field.')
        public String agfS1AppBuildNumber;
        @InvocableVariable(label='GA-EOA2 Scheduled Build Copy' description='Value for the Scheduled Build Copy (agf__Scheduled_Build_Copy__c) field.')
        public String agfScheduledBuildCopy;
        @InvocableVariable(label='GA-EOA2 Rank in a scheduled build for team' description='Value for the Rank in a scheduled build for team (agf__Scheduled_Build_Rank__c) field.')
        public Decimal agfScheduledBuildRank;
        @InvocableVariable(label='GA-EOA2 Scheduled Build' description='Value for the Scheduled Build (agf__Scheduled_Build__c) field.')
        public String agfScheduledBuild;
        @InvocableVariable(label='GA-EOA2 Scheduled On' description='Value for the Scheduled On (agf__Scheduled_On__c) field. Supported formats: YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public Date agfScheduledOn;
        @InvocableVariable(label='GA-EOA2 Requires Schema Change' description='Value for the Requires Schema Change (agf__Schema__c) field.')
        public Boolean agfSchema;
        @InvocableVariable(label='GA-EOA2 Scrum Team Last Modified' description='Value for the Scrum Team Last Modified (agf__Scrum_Team_Last_Modified__c) field. Supported formats: YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public Datetime agfScrumTeamLastModified;
        @InvocableVariable(label='GA-EOA2 Team' description='Value for the Team (agf__Scrum_Team__c) field.')
        public String agfScrumTeam;
        @InvocableVariable(label='GA-EOA2 Scrumforce ID' description='Value for the Scrumforce ID (agf__Scrumforce_ID__c) field.')
        public String agfScrumforceId;
        @InvocableVariable(label='GA-EOA2 Security' description='Value for the Security (agf__Security__c) field.')
        public Boolean agfSecurity;
        @InvocableVariable(label='GA-EOA2 Senior Management POC' description='Value for the Senior Management POC (agf__Senior_Management_POC__c) field.')
        public String agfSeniorManagementPoc;
        @InvocableVariable(label='GA-EOA2 Severity Copy' description='Value for the Severity Copy (agf__Severity_Copy__c) field.')
        public String agfSeverityCopy;
        @InvocableVariable(label='GA-EOA2 Severity Level' description='Value for the Severity Level (agf__Severity_Level__c) field.')
        public String agfSeverityLevel;
        @InvocableVariable(label='GA-EOA2 Solution Overview' description='Value for the Solution Overview (agf__Solution_Overview__c) field.')
        public String agfSolutionOverview;
        @InvocableVariable(label='GA-EOA2 Rank of this work item in a sprint' description='Value for the Rank of this work item in a sprint (agf__Sprint_Rank__c) field.')
        public Decimal agfSprintRank;
        @InvocableVariable(label='GA-EOA2 Sprint' description='Value for the Sprint (agf__Sprint__c) field.')
        public String agfSprint;
        @InvocableVariable(label='GA-EOA2 Status' description='Value for the Status (agf__Status__c) field.')
        public String agfStatus;
        @InvocableVariable(label='GA-EOA2 Story Points' description='Value for the Story Points (agf__Story_Points__c) field.')
        public Decimal agfStoryPoints;
        @InvocableVariable(label='GA-EOA2 Subscribe to Work' description='Value for the Subscribe to Work (agf__Subscribe_to_Work__c) field.')
        public Boolean agfSubscribeToWork;
        @InvocableVariable(label='GA-EOA2 Performance Engineer' description='Value for the Performance Engineer (agf__System_Test_Engineer__c) field.')
        public String agfSystemTestEngineer;
        @InvocableVariable(label='GA-EOA2 Target Build' description='Value for the Target Build (agf__Target_Build__c) field.')
        public String agfTargetBuild;
        @InvocableVariable(label='GA-EOA2 Tech Writer' description='Value for the Tech Writer (agf__Tech_Writer__c) field.')
        public String agfTechWriter;
        @InvocableVariable(label='GA-EOA2 Template Description' description='Value for the Template Description (agf__Template_Description__c) field.')
        public String agfTemplateDescription;
        @InvocableVariable(label='GA-EOA2 Template Name' description='Value for the Template Name (agf__Template_Name__c) field.')
        public String agfTemplateName;
        @InvocableVariable(label='GA-EOA2 Test Failure Status' description='Value for the Test Failure Status (agf__Test_Failure_Status__c) field.')
        public String agfTestFailureStatus;
        @InvocableVariable(label='GA-EOA2 Rank of work item for team in a theme' description='Value for the Rank of work item for team in a theme (agf__Theme_Rank__c) field.')
        public Decimal agfThemeRank;
        @InvocableVariable(label='GA-EOA2 Theme-Deprecated' description='Value for the Theme-Deprecated (agf__Theme__c) field.')
        public String agfTheme;
        @InvocableVariable(label='GA-EOA2 Rank of work item for trust' description='Value for the Rank of work item for trust (agf__Trust_Rank__c) field.')
        public Decimal agfTrustRank;
        @InvocableVariable(label='GA-EOA2 Type' description='Value for the Type (agf__Type__c) field.')
        public String agfType;
        @InvocableVariable(label='GA-EOA2 UE Engineer' description='Value for the UE Engineer (agf__UE_Engineer__c) field.')
        public String agfUeEngineer;
        @InvocableVariable(label='GA-EOA2 Include in Prioritize View' description='Value for the Include in Prioritize View (agf__Use_Prioritizer__c) field.')
        public Boolean agfUsePrioritizer;
        @InvocableVariable(label='GA-EOA2 User Type (As a...)' description='Value for the User Type (As a...) (agf__User_Type__c) field.')
        public String agfUserType;
        @InvocableVariable(label='GA-EOA2 Was Ever Returned to Support' description='Value for the Was Ever Returned to Support (agf__Was_Ever_Returned_to_Support__c) field.')
        public Boolean agfWasEverReturnedToSupport;
        @InvocableVariable(label='GA-EOA2 test' description='Value for the test (agf__ftest__c) field.')
        public String agfFtest;
        @InvocableVariable(label='GA-EOA2 Test Failures Count' description='Value for the Test Failures Count (agf__of_Test_Failures__c) field.')
        public Decimal agfOfTestFailures;
        @InvocableVariable(label='GA-EOA2 Completion %' description='Value for the Completion % (Completion__c) field.')
        public Decimal completion;
        @InvocableVariable(label='GA-EOA2 Hours' description='Value for the Hours (Hours__c) field.')
        public Decimal hours;
        @InvocableVariable(label='GA-EOA2 Milestone' description='Value for the Milestone (Milestone__c) field.')
        public Boolean milestone;
        @InvocableVariable(label='GA-EOA2 Project' description='Value for the Project (Project__c) field.')
        public String project;
        @InvocableVariable(label='GA-EOA2 Due Date' description='Value for the Due Date (Due_Date__c) field. Supported formats: YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public Date dueDate;
        @InvocableVariable(label='GA-EOA2 Enhancement/Bug Log' description='Value for the Enhancement/Bug Log (Enhancement_Bug_Log__c) field.')
        public String enhancementBugLog;
        @InvocableVariable(label='GA-EOA2 Start Date' description='Value for the Start Date (Start_Date__c) field. Supported formats: YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public Date startDate;
        @InvocableVariable(label='GA-EOA2 Built From Template' description='Value for the Built From Template (Built_From_Template__c) field.')
        public Boolean builtFromTemplate;
        @InvocableVariable(label='GA-EOA2 Components to Deploy' description='Value for the Components to Deploy (Components_to_Deploy__c) field.')
        public String componentsToDeploy;
        @InvocableVariable(label='GA-EOA2 Work Started?' description='Value for the Work Started? (Work_Started__c) field.')
        public Boolean workStarted;
        @InvocableVariable(label='GA-EOA2 Associated Intake' description='Value for the Associated Intake (Associated_Intake__c) field.')
        public String associatedIntake;

        // Search-specific fields
        @InvocableVariable(label='GA-EOA2 Subject for Search' description='Keyword for searching by Subject.')
        public String subjectSearch;
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
        @InvocableVariable(label='GA-EOA2 Work Records' description='List of Work records from the operation.')
        public List<agf__ADM_Work__c> workRecords = new List<agf__ADM_Work__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Work Records (Part 4)' description='Handles Modify for the last subset of Work fields, plus Retrieve and Search.')
    public static List<Response> manageWork4(List<Request> requests) {
        List<agf__ADM_Work__c> toUpdate = new List<agf__ADM_Work__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            responseMap.put(i, new Response());
            Request req = requests.get(i);
            
            switch on req.actionType {
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.workId)) {
                        responseMap.get(i).message = 'Error: Work ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.workId);
                    }
                }
                when 'Search' {
                    handleSearch(req, responseMap.get(i));
                }
                when else {
                    responseMap.get(i).message = 'Error: Invalid action type.';
                }
            }
        }

        if (!idsToProcess.isEmpty()) {
            String allFieldsQuery = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('agf__ADM_Work__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM agf__ADM_Work__c WHERE Id IN :idsToProcess';
            Map<Id, agf__ADM_Work__c> worksFromDb = new Map<Id, agf__ADM_Work__c>((List<agf__ADM_Work__c>)Database.query(allFieldsQuery));

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (req.actionType == 'Modify' && String.isNotBlank(req.workId) && worksFromDb.containsKey(req.workId)) {
                    toUpdate.add(mapRequestToWork(req, worksFromDb.get(req.workId)));
                } else if (req.actionType == 'Retrieve' && String.isNotBlank(req.workId) && worksFromDb.containsKey(req.workId)) {
                    Response res = responseMap.get(i);
                    res.success = true;
                    res.message = 'Work retrieved successfully.';
                    res.workRecords.add(worksFromDb.get(req.workId));
                }
            }
        }
        
        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            handleDmlResults(updateResults, toUpdate, requests, responseMap);
        }
        
        return new List<Response>(responseMap.values());
    }

    private static agf__ADM_Work__c mapRequestToWork(Request req, agf__ADM_Work__c work) {
        work.Id = req.workId;
        if(req.agfRedAccount != null) work.agf__Red_Account__c = req.agfRedAccount;
        if(req.agfRegressed != null) work.agf__Regressed__c = req.agfRegressed;
        if(req.agfRelatedUrl != null) work.agf__Related_URL__c = req.agfRelatedUrl;
        if(req.agfRelatedWork != null) work.agf__Related_Work__c = req.agfRelatedWork;
        if(req.agfRelease != null) work.agf__Release__c = req.agfRelease;
        if(req.agfRequestRdMgrReview != null) work.agf__Request_RD_Mgr_Review__c = req.agfRequestRdMgrReview;
        if(req.agfResolution != null) work.agf__Resolution__c = req.agfResolution;
        if(req.agfResolvedBy != null) work.agf__Resolved_By__c = req.agfResolvedBy;
        if(req.agfResolvedOn != null) work.agf__Resolved_On__c = req.agfResolvedOn;
        if(req.agfRootCauseAnalysis2 != null) work.agf__Root_Cause_Analysis_2__c = req.agfRootCauseAnalysis2;
        if(req.agfS1AppBuildNumber != null) work.agf__S1_App_Build_Number__c = req.agfS1AppBuildNumber;
        if(req.agfScheduledBuildCopy != null) work.agf__Scheduled_Build_Copy__c = req.agfScheduledBuildCopy;
        if(req.agfScheduledBuildRank != null) work.agf__Scheduled_Build_Rank__c = req.agfScheduledBuildRank;
        if(req.agfScheduledBuild != null) work.agf__Scheduled_Build__c = req.agfScheduledBuild;
        if(req.agfScheduledOn != null) work.agf__Scheduled_On__c = req.agfScheduledOn;
        if(req.agfSchema != null) work.agf__Schema__c = req.agfSchema;
        if(req.agfScrumTeamLastModified != null) work.agf__Scrum_Team_Last_Modified__c = req.agfScrumTeamLastModified;
        if(req.agfScrumTeam != null) work.agf__Scrum_Team__c = req.agfScrumTeam;
        if(req.agfScrumforceId != null) work.agf__Scrumforce_ID__c = req.agfScrumforceId;
        if(req.agfSecurity != null) work.agf__Security__c = req.agfSecurity;
        if(req.agfSeniorManagementPoc != null) work.agf__Senior_Management_POC__c = req.agfSeniorManagementPoc;
        if(req.agfSeverityCopy != null) work.agf__Severity_Copy__c = req.agfSeverityCopy;
        if(req.agfSeverityLevel != null) work.agf__Severity_Level__c = req.agfSeverityLevel;
        if(req.agfSolutionOverview != null) work.agf__Solution_Overview__c = req.agfSolutionOverview;
        if(req.agfSprintRank != null) work.agf__Sprint_Rank__c = req.agfSprintRank;
        if(req.agfSprint != null) work.agf__Sprint__c = req.agfSprint;
        if(req.agfStatus != null) work.agf__Status__c = req.agfStatus;
        if(req.agfStoryPoints != null) work.agf__Story_Points__c = req.agfStoryPoints;
        if(req.agfSubscribeToWork != null) work.agf__Subscribe_to_Work__c = req.agfSubscribeToWork;
        if(req.agfSystemTestEngineer != null) work.agf__System_Test_Engineer__c = req.agfSystemTestEngineer;
        if(req.agfTargetBuild != null) work.agf__Target_Build__c = req.agfTargetBuild;
        if(req.agfTechWriter != null) work.agf__Tech_Writer__c = req.agfTechWriter;
        if(req.agfTemplateDescription != null) work.agf__Template_Description__c = req.agfTemplateDescription;
        if(req.agfTemplateName != null) work.agf__Template_Name__c = req.agfTemplateName;
        if(req.agfTestFailureStatus != null) work.agf__Test_Failure_Status__c = req.agfTestFailureStatus;
        if(req.agfThemeRank != null) work.agf__Theme_Rank__c = req.agfThemeRank;
        if(req.agfTheme != null) work.agf__Theme__c = req.agfTheme;
        if(req.agfTrustRank != null) work.agf__Trust_Rank__c = req.agfTrustRank;
        if(req.agfType != null) work.agf__Type__c = req.agfType;
        if(req.agfUeEngineer != null) work.agf__UE_Engineer__c = req.agfUeEngineer;
        if(req.agfUsePrioritizer != null) work.agf__Use_Prioritizer__c = req.agfUsePrioritizer;
        if(req.agfUserType != null) work.agf__User_Type__c = req.agfUserType;
        if(req.agfWasEverReturnedToSupport != null) work.agf__Was_Ever_Returned_to_Support__c = req.agfWasEverReturnedToSupport;
        if(req.agfFtest != null) work.agf__ftest__c = req.agfFtest;
        if(req.agfOfTestFailures != null) work.agf__of_Test_Failures__c = req.agfOfTestFailures;
        if(req.completion != null) work.Completion__c = req.completion;
        if(req.hours != null) work.Hours__c = req.hours;
        if(req.milestone != null) work.Milestone__c = req.milestone;
        if(req.project != null) work.Project__c = req.project;
        if(req.dueDate != null) work.Due_Date__c = req.dueDate;
        if(req.enhancementBugLog != null) work.Enhancement_Bug_Log__c = req.enhancementBugLog;
        if(req.startDate != null) work.Start_Date__c = req.startDate;
        if(req.builtFromTemplate != null) work.Built_From_Template__c = req.builtFromTemplate;
        if(req.componentsToDeploy != null) work.Components_to_Deploy__c = req.componentsToDeploy;
        if(req.workStarted != null) work.Work_Started__c = req.workStarted;
        if(req.associatedIntake != null) work.Associated_Intake__c = req.associatedIntake;
        return work;
    }
    
    private static void handleDmlResults(Database.SaveResult[] results, List<agf__ADM_Work__c> records, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
             Request req = requests.get(i);
             if (req.actionType == 'Modify' && String.isNotBlank(req.workId)) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Work modified successfully.';
                        res.workRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                }
            }
        }
    }

    private static void handleSearch(Request req, Response res) {
        String allFields = String.join(new List<String>(Schema.getGlobalDescribe().get('agf__ADM_Work__c').getDescribe().fields.getMap().keySet()), ',');
        String soql = 'SELECT ' + allFields + ' FROM agf__ADM_Work__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.subjectSearch)) {
            conditions.add('agf__Subject__c LIKE \'%' + String.escapeSingleQuotes(req.subjectSearch) + '%\'');
        }
        if (String.isNotBlank(req.agfStatus)) {
            conditions.add('agf__Status__c = \'' + String.escapeSingleQuotes(req.agfStatus) + '\'');
        }
        if (String.isNotBlank(req.agfType)) {
            conditions.add('agf__Type__c = \'' + String.escapeSingleQuotes(req.agfType) + '\'');
        }
        if (String.isNotBlank(req.agfRelease)) {
            conditions.add('agf__Release__c = \'' + String.escapeSingleQuotes(req.agfRelease) + '\'');
        }
        if (String.isNotBlank(req.agfResolution)) {
            conditions.add('agf__Resolution__c = \'' + String.escapeSingleQuotes(req.agfResolution) + '\'');
        }
        if (String.isNotBlank(req.agfResolvedBy)) {
            conditions.add('agf__Resolved_By__c = \'' + String.escapeSingleQuotes(req.agfResolvedBy) + '\'');
        }
        if (String.isNotBlank(req.agfScheduledBuild)) {
            conditions.add('agf__Scheduled_Build__c = \'' + String.escapeSingleQuotes(req.agfScheduledBuild) + '\'');
        }
        if (String.isNotBlank(req.agfScrumTeam)) {
            conditions.add('agf__Scrum_Team__c = \'' + String.escapeSingleQuotes(req.agfScrumTeam) + '\'');
        }
        if (String.isNotBlank(req.agfSeverityLevel)) {
            conditions.add('agf__Severity_Level__c = \'' + String.escapeSingleQuotes(req.agfSeverityLevel) + '\'');
        }
        if (String.isNotBlank(req.agfSprint)) {
            conditions.add('agf__Sprint__c = \'' + String.escapeSingleQuotes(req.agfSprint) + '\'');
        }
        if (String.isNotBlank(req.project)) {
            conditions.add('Project__c = \'' + String.escapeSingleQuotes(req.project) + '\'');
        }
        if (String.isNotBlank(req.enhancementBugLog)) {
            conditions.add('Enhancement_Bug_Log__c = \'' + String.escapeSingleQuotes(req.enhancementBugLog) + '\'');
        }
        if (String.isNotBlank(req.associatedIntake)) {
            conditions.add('Associated_Intake__c = \'' + String.escapeSingleQuotes(req.associatedIntake) + '\'');
        }
        if (req.milestone != null) {
            conditions.add('Milestone__c = ' + req.milestone);
        }
        if (req.workStarted != null) {
            conditions.add('Work_Started__c = ' + req.workStarted);
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
            res.workRecords = Database.query(soql);
            res.success = true;
            res.message = 'Work search executed. Records found: ' + res.workRecords.size();
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}