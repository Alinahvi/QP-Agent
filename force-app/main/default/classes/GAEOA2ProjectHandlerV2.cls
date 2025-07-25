public with sharing class GAEOA2ProjectHandlerV2 {

    // Inner class for request data
    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;

        @InvocableVariable(label='GA-EOA2 Project ID' description='Salesforce Project record ID. Required for Modify, Retrieve actions.')
        public String projectId;
        
        // --- All agf__PPM_Project__c Fields ---
        @InvocableVariable(label='GA-EOA2 Owner ID' description='Value for the Owner ID (OwnerId) field.')
        public String ownerId;
        @InvocableVariable(label='GA-EOA2 Project Name' description='Value for the Project Name (Name) field.')
        public String name;
        @InvocableVariable(label='GA-EOA2 Category' description='Value for the Category (agf__Category__c) field.')
        public String agfCategory;
        @InvocableVariable(label='GA-EOA2 Delivery Scrum Team' description='Value for the Delivery Scrum Team (agf__Delivery_Scrum_Team__c) field.')
        public String agfDeliveryScrumTeam;
        @InvocableVariable(label='GA-EOA2 Development Lead' description='Value for the Development Lead (agf__Development_Lead__c) field.')
        public String agfDevelopmentLead;
        @InvocableVariable(label='GA-EOA2 Path to Green' description='Value for the Path to Green (agf__Path_to_Green__c) field.')
        public String agfPathToGreen;
        @InvocableVariable(label='GA-EOA2 Planned End Date' description='Value for the Planned End Date (agf__Planned_End_Date__c) field. Supported formats: YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public Date agfPlannedEndDate;
        @InvocableVariable(label='GA-EOA2 Planned Start Date' description='Value for the Planned Start Date (agf__Planned_Start_Date__c) field. Supported formats: YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public Date agfPlannedStartDate;
        @InvocableVariable(label='GA-EOA2 Portfolio' description='Value for the Portfolio (agf__Portfolio__c) field.')
        public String agfPortfolio;
        @InvocableVariable(label='GA-EOA2 Product Owner' description='Value for the Product Owner (agf__Product_Owner_Project_Object__c) field.')
        public String agfProductOwnerProjectObject;
        @InvocableVariable(label='GA-EOA2 Program' description='Value for the Program (agf__Program__c) field.')
        public String agfProgram;
        @InvocableVariable(label='GA-EOA2 Project Health' description='Value for the Project Health (agf__Project_Health__c) field.')
        public String agfProjectHealth;
        @InvocableVariable(label='GA-EOA2 Project Management Notes Date' description='Value for the Project Management Notes Date (agf__Project_Management_Notes_Date__c) field. Supported formats: YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public Date agfProjectManagementNotesDate;
        @InvocableVariable(label='GA-EOA2 Project Management Notes' description='Value for the Project Management Notes (agf__Project_Management_Notes__c) field.')
        public String agfProjectManagementNotes;
        @InvocableVariable(label='GA-EOA2 Project Manager' description='Value for the Project Manager (agf__Project_Manager__c) field.')
        public String agfProjectManager;
        @InvocableVariable(label='GA-EOA2 Project Summary' description='Value for the Project Summary (agf__Project_Summary__c) field.')
        public String agfProjectSummary;
        @InvocableVariable(label='GA-EOA2 Slippage Comment' description='Value for the Slippage Comment (agf__Slippage_Comment__c) field.')
        public String agfSlippageComment;
        @InvocableVariable(label='GA-EOA2 Slippage Reason' description='Value for the Slippage Reason (agf__Slippage_Reason__c) field.')
        public String agfSlippageReason;
        @InvocableVariable(label='GA-EOA2 Business Challenge' description='Value for the Business Challenge (Business_Challenge__c) field.')
        public String businessChallenge;
        @InvocableVariable(label='GA-EOA2 Desired Outcome(s) & Objectives' description='Value for the Desired Outcome(s) & Objectives (Desired_Outcome_s_Objectives__c) field.')
        public String desiredOutcomeSObjectives;
        @InvocableVariable(label='GA-EOA2 Enablement POC (Point of Contact)' description='Value for the Enablement POC (Point of Contact) (Enablement_POC_Point_of_Contact__c) field.')
        public String enablementPocPointOfContact;
        @InvocableVariable(label='GA-EOA2 Level of Effort/T-Shirt Size' description='Value for the Level of Effort/T-Shirt Size (Level_of_Effort_T_Shirt_Size__c) field.')
        public String levelOfEffortTShirtSize;
        @InvocableVariable(label='GA-EOA2 OU Benefit' description='Value for the OU Benefit (OU_Benefit__c) field.')
        public String ouBenefit;
        @InvocableVariable(label='GA-EOA2 Scope' description='Value for the Scope (Scope__c) field.')
        public String scope;
        @InvocableVariable(label='GA-EOA2 Success Metrics' description='Value for the Success Metrics (Success_Metrics__c) field.')
        public String successMetrics;
        @InvocableVariable(label='GA-EOA2 Target Audience' description='Value for the Target Audience (Target_Audience__c) field.')
        public String targetAudience;
        @InvocableVariable(label='GA-EOA2 Target Geographic Regions' description='Value for the Target Geographic Regions (Target_Geographic_Regions__c) field.')
        public String targetGeographicRegions;
        @InvocableVariable(label='GA-EOA2 Priority' description='Value for the Priority (Priority__c) field.')
        public Decimal priority;
        @InvocableVariable(label='GA-EOA2 % Complete' description='Value for the % Complete (Percent_Complete__c) field.')
        public Decimal percentComplete;
        @InvocableVariable(label='GA-EOA2 Template' description='Value for the Template (Template__c) field.')
        public String template;
        @InvocableVariable(label='GA-EOA2 Associated Intake' description='Value for the Associated Intake (Associated_Intake__c) field.')
        public String associatedIntake;
        @InvocableVariable(label='GA-EOA2 External ID' description='Value for the External ID (External_ID__c) field.')
        public String externalId;
        @InvocableVariable(label='GA-EOA2 Project Started?' description='Value for the Project Started? (Project_Started__c) field.')
        public Boolean projectStarted;
        @InvocableVariable(label='GA-EOA2 Document Design URL' description='Value for the Document Design URL (Document_Design_URL__c) field.')
        public String documentDesignUrl;
        @InvocableVariable(label='GA-EOA2 Project Score' description='Value for the Project Score (PM_Project_Score__c) field.')
        public Decimal pmProjectScore;
        @InvocableVariable(label='GA-EOA2 Date of Last Health Comment' description='Value for the Date of Last Health Comment (Date_of_Last_Health_Comment__c) field. Supported formats: YYYY-MM-DD, or Salesforce date literals (e.g., TODAY, LAST_N_DAYS:30).')
        public Date dateOfLastHealthComment;
        @InvocableVariable(label='GA-EOA2 Project Summary Score' description='Value for the Project Summary Score (Project_Summary_Score__c) field.')
        public Decimal projectSummaryScore;
        
        // Search-specific fields
        @InvocableVariable(label='GA-EOA2 Created Date' description='For search operations. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals.')
        public String createdDate;
        @InvocableVariable(label='GA-EOA2 Last Modified Date' description='For search operations. Supported formats: YYYY-MM-DD, YYYY-MM-DD:YYYY-MM-DD, or Salesforce date literals.')
        public String lastModifiedDate;
        @InvocableVariable(label='GA-EOA2 Created By User ID' description='For search operations. Salesforce User ID of the creator.')
        public String createdById;
        @InvocableVariable(label='GA-EOA2 Last Modified By User ID' description='For search operations. Salesforce User ID of the last modifier.')
        public String lastModifiedById;
    }
    
    // Inner class for response data
    public class Response {
        @InvocableVariable(label='GA-EOA2 Success' description='True if the operation succeeded.')
        public Boolean success = false;
        @InvocableVariable(label='GA-EOA2 Message' description='Summary of the operation result.')
        public String message = '';
        @InvocableVariable(label='GA-EOA2 Project Records' description='List of Project records from the operation.')
        public List<agf__PPM_Project__c> projectRecords = new List<agf__PPM_Project__c>();
    }

    // Main invocable method
    @InvocableMethod(label='GA-EOA2 Manage Project Records V2' description='A single, bulk-safe method to create, modify, retrieve, and search for Project records.')
    public static List<Response> manageProjects(List<Request> requests) {
        List<agf__PPM_Project__c> toCreate = new List<agf__PPM_Project__c>();
        List<agf__PPM_Project__c> toUpdate = new List<agf__PPM_Project__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.name)) {
                        res.message = 'Error: Project Name is required for creation.';
                    } else {
                        toCreate.add(mapRequestToProject(req, new agf__PPM_Project__c()));
                    }
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.projectId)) {
                        res.message = 'Error: Project ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.projectId);
                    }
                }
                when 'Search' {
                    handleSearch(req, res);
                }
                when else {
                    res.message = 'Error: Invalid or missing action type.';
                }
            }
        }

        if (!toCreate.isEmpty()) {
            Database.SaveResult[] createResults = Database.insert(toCreate, false);
            handleDmlResults(createResults, toCreate, 'Create', requests, responseMap);
        }

        if (!idsToProcess.isEmpty()) {
            Map<Id, agf__PPM_Project__c> projectsFromDb = new Map<Id, agf__PPM_Project__c>([
                SELECT Id, Name, OwnerId, agf__Category__c, agf__Delivery_Scrum_Team__c, agf__Development_Lead__c, agf__Path_to_Green__c, agf__Planned_End_Date__c, agf__Planned_Start_Date__c, agf__Portfolio__c, agf__Product_Owner_Project_Object__c, agf__Program__c, agf__Project_Health__c, agf__Project_Management_Notes_Date__c, agf__Project_Management_Notes__c, agf__Project_Manager__c, agf__Project_Summary__c, agf__Slippage_Comment__c, agf__Slippage_Reason__c, Business_Challenge__c, Desired_Outcome_s_Objectives__c, Enablement_POC_Point_of_Contact__c, Level_of_Effort_T_Shirt_Size__c, OU_Benefit__c, Scope__c, Success_Metrics__c, Target_Audience__c, Target_Geographic_Regions__c, Priority__c, Percent_Complete__c, Template__c, Associated_Intake__c, External_ID__c, Project_Started__c, Document_Design_URL__c, PM_Project_Score__c, Date_of_Last_Health_Comment__c, Project_Summary_Score__c, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById 
                FROM agf__PPM_Project__c WHERE Id IN :idsToProcess
            ]);

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (String.isBlank(req.projectId) || !projectsFromDb.containsKey(req.projectId)) continue;
                
                Response res = responseMap.get(i);
                agf__PPM_Project__c proj = projectsFromDb.get(req.projectId);

                if (req.actionType == 'Modify') {
                    toUpdate.add(mapRequestToProject(req, proj));
                } else if (req.actionType == 'Retrieve') {
                    res.success = true;
                    res.message = 'Project retrieved successfully.';
                    res.projectRecords.add(proj);
                }
            }
        }
        
        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            handleDmlResults(updateResults, toUpdate, 'Modify', requests, responseMap);
        }
        
        return new List<Response>(responseMap.values());
    }

    // Maps request fields to a Project SObject
    private static agf__PPM_Project__c mapRequestToProject(Request req, agf__PPM_Project__c proj) {
        if(req.ownerId != null) proj.OwnerId = req.ownerId;
        if(req.name != null) proj.Name = req.name;
        if(req.agfCategory != null) proj.agf__Category__c = req.agfCategory;
        if(req.agfDeliveryScrumTeam != null) proj.agf__Delivery_Scrum_Team__c = req.agfDeliveryScrumTeam;
        if(req.agfDevelopmentLead != null) proj.agf__Development_Lead__c = req.agfDevelopmentLead;
        if(req.agfPathToGreen != null) proj.agf__Path_to_Green__c = req.agfPathToGreen;
        if(req.agfPlannedEndDate != null) proj.agf__Planned_End_Date__c = req.agfPlannedEndDate;
        if(req.agfPlannedStartDate != null) proj.agf__Planned_Start_Date__c = req.agfPlannedStartDate;
        if(req.agfPortfolio != null) proj.agf__Portfolio__c = req.agfPortfolio;
        if(req.agfProductOwnerProjectObject != null) proj.agf__Product_Owner_Project_Object__c = req.agfProductOwnerProjectObject;
        if(req.agfProgram != null) proj.agf__Program__c = req.agfProgram;
        if(req.agfProjectHealth != null) proj.agf__Project_Health__c = req.agfProjectHealth;
        if(req.agfProjectManagementNotesDate != null) proj.agf__Project_Management_Notes_Date__c = req.agfProjectManagementNotesDate;
        if(req.agfProjectManagementNotes != null) proj.agf__Project_Management_Notes__c = req.agfProjectManagementNotes;
        if(req.agfProjectManager != null) proj.agf__Project_Manager__c = req.agfProjectManager;
        if(req.agfProjectSummary != null) proj.agf__Project_Summary__c = req.agfProjectSummary;
        if(req.agfSlippageComment != null) proj.agf__Slippage_Comment__c = req.agfSlippageComment;
        if(req.agfSlippageReason != null) proj.agf__Slippage_Reason__c = req.agfSlippageReason;
        if(req.businessChallenge != null) proj.Business_Challenge__c = req.businessChallenge;
        if(req.desiredOutcomeSObjectives != null) proj.Desired_Outcome_s_Objectives__c = req.desiredOutcomeSObjectives;
        if(req.enablementPocPointOfContact != null) proj.Enablement_POC_Point_of_Contact__c = req.enablementPocPointOfContact;
        if(req.levelOfEffortTShirtSize != null) proj.Level_of_Effort_T_Shirt_Size__c = req.levelOfEffortTShirtSize;
        if(req.ouBenefit != null) proj.OU_Benefit__c = req.ouBenefit;
        if(req.scope != null) proj.Scope__c = req.scope;
        if(req.successMetrics != null) proj.Success_Metrics__c = req.successMetrics;
        if(req.targetAudience != null) proj.Target_Audience__c = req.targetAudience;
        if(req.targetGeographicRegions != null) proj.Target_Geographic_Regions__c = req.targetGeographicRegions;
        if(req.priority != null) proj.Priority__c = req.priority;
        if(req.percentComplete != null) proj.Percent_Complete__c = req.percentComplete;
        if(req.template != null) proj.Template__c = req.template;
        if(req.associatedIntake != null) proj.Associated_Intake__c = req.associatedIntake;
        if(req.externalId != null) proj.External_ID__c = req.externalId;
        if(req.projectStarted != null) proj.Project_Started__c = req.projectStarted;
        if(req.documentDesignUrl != null) proj.Document_Design_URL__c = req.documentDesignUrl;
        if(req.pmProjectScore != null) proj.PM_Project_Score__c = req.pmProjectScore;
        if(req.dateOfLastHealthComment != null) proj.Date_of_Last_Health_Comment__c = req.dateOfLastHealthComment;
        if(req.projectSummaryScore != null) proj.Project_Summary_Score__c = req.projectSummaryScore;
        return proj;
    }

    // Handles DML results and updates response map
    private static void handleDmlResults(Database.SaveResult[] results, List<agf__PPM_Project__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType == action && (action == 'Create' ? String.isNotBlank(requests.get(i).name) : String.isNotBlank(requests.get(i).projectId))) {
                 if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Project ' + action.toLowerCase() + 'd successfully.';
                        res.projectRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                 }
            }
        }
    }

    // Handles dynamic SOQL search
    private static void handleSearch(Request req, Response res) {
        String soql = 'SELECT Id, Name, OwnerId, agf__Category__c, agf__Delivery_Scrum_Team__c, agf__Development_Lead__c, agf__Path_to_Green__c, agf__Planned_End_Date__c, agf__Planned_Start_Date__c, agf__Portfolio__c, agf__Product_Owner_Project_Object__c, agf__Program__c, agf__Project_Health__c, agf__Project_Management_Notes_Date__c, agf__Project_Management_Notes__c, agf__Project_Manager__c, agf__Project_Summary__c, agf__Slippage_Comment__c, agf__Slippage_Reason__c, Business_Challenge__c, Desired_Outcome_s_Objectives__c, Enablement_POC_Point_of_Contact__c, Level_of_Effort_T_Shirt_Size__c, OU_Benefit__c, Scope__c, Success_Metrics__c, Target_Audience__c, Target_Geographic_Regions__c, Priority__c, Percent_Complete__c, Template__c, Associated_Intake__c, External_ID__c, Project_Started__c, Document_Design_URL__c, PM_Project_Score__c, Date_of_Last_Health_Comment__c, Project_Summary_Score__c, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById FROM agf__PPM_Project__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.name)) {
            conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.name) + '%\'');
        }
        if (String.isNotBlank(req.createdById)) {
            conditions.add('CreatedById = \'' + String.escapeSingleQuotes(req.createdById) + '\'');
        }
        if (String.isNotBlank(req.lastModifiedById)) {
            conditions.add('LastModifiedById = \'' + String.escapeSingleQuotes(req.lastModifiedById) + '\'');
        }
        if (String.isNotBlank(req.ownerId)) {
            conditions.add('OwnerId = \'' + String.escapeSingleQuotes(req.ownerId) + '\'');
        }
        if (String.isNotBlank(req.agfCategory)) {
            conditions.add('agf__Category__c = \'' + String.escapeSingleQuotes(req.agfCategory) + '\'');
        }
        if (String.isNotBlank(req.agfDeliveryScrumTeam)) {
            conditions.add('agf__Delivery_Scrum_Team__c = \'' + String.escapeSingleQuotes(req.agfDeliveryScrumTeam) + '\'');
        }
        if (String.isNotBlank(req.agfDevelopmentLead)) {
            conditions.add('agf__Development_Lead__c = \'' + String.escapeSingleQuotes(req.agfDevelopmentLead) + '\'');
        }
        if (String.isNotBlank(req.agfPortfolio)) {
            conditions.add('agf__Portfolio__c = \'' + String.escapeSingleQuotes(req.agfPortfolio) + '\'');
        }
        if (String.isNotBlank(req.agfProductOwnerProjectObject)) {
            conditions.add('agf__Product_Owner_Project_Object__c = \'' + String.escapeSingleQuotes(req.agfProductOwnerProjectObject) + '\'');
        }
        if (String.isNotBlank(req.agfProgram)) {
            conditions.add('agf__Program__c = \'' + String.escapeSingleQuotes(req.agfProgram) + '\'');
        }
        if (String.isNotBlank(req.agfProjectHealth)) {
            conditions.add('agf__Project_Health__c = \'' + String.escapeSingleQuotes(req.agfProjectHealth) + '\'');
        }
        if (String.isNotBlank(req.agfProjectManager)) {
            conditions.add('agf__Project_Manager__c = \'' + String.escapeSingleQuotes(req.agfProjectManager) + '\'');
        }
        if (String.isNotBlank(req.agfSlippageReason)) {
            conditions.add('agf__Slippage_Reason__c = \'' + String.escapeSingleQuotes(req.agfSlippageReason) + '\'');
        }
        if (String.isNotBlank(req.levelOfEffortTShirtSize)) {
            conditions.add('Level_of_Effort_T_Shirt_Size__c = \'' + String.escapeSingleQuotes(req.levelOfEffortTShirtSize) + '\'');
        }
        if (String.isNotBlank(req.template)) {
            conditions.add('Template__c = \'' + String.escapeSingleQuotes(req.template) + '\'');
        }
        if (String.isNotBlank(req.associatedIntake)) {
            conditions.add('Associated_Intake__c = \'' + String.escapeSingleQuotes(req.associatedIntake) + '\'');
        }
        if (String.isNotBlank(req.externalId)) {
            conditions.add('External_ID__c = \'' + String.escapeSingleQuotes(req.externalId) + '\'');
        }
        if (req.projectStarted != null) {
            conditions.add('Project_Started__c = ' + req.projectStarted);
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
            res.projectRecords = Database.query(soql);
            res.success = true;
            res.message = 'Project search executed. Records found: ' + res.projectRecords.size();
        } catch (Exception e) {
            res.message = 'Error during Project search: ' + e.getMessage();
        }
    }
}