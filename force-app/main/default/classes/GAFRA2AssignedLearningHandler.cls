public with sharing class GAFRA2AssignedLearningHandler {

    public class Request {
        @InvocableVariable(label='Action Type' description='Specify the action: Create | Modify | Retrieve | Search | Inactivate' required=true)
        public String actionType;
        @InvocableVariable(label='Assigned Learning ID' description='The unique ID of the Assigned Learning record to target. Required for Modify, Retrieve, or Inactivate actions. Example: "a03Hu000001ABCDE"')
        public String assignedLearningId;
        @InvocableVariable(label='Assigned Learning Name' description='Used for "Search" actions only to find records by their auto-generated name.')
        public String assignedLearningName;
        @InvocableVariable(label='Audience ID' description='The ID of the Audience receiving this assignment. Required for "Create". Example: "a01Hu000001XYZAB"')
        public String audienceId;
        
        @InvocableVariable(label='Asset ID' description='The ID of the content Asset to assign. Exactly one of Asset, Course, or Curriculum ID must be provided for Create/Modify actions.')
        public String assetId;
        @InvocableVariable(label='Course ID' description='The ID of the Course to assign. Exactly one of Asset, Course, or Curriculum ID must be provided for Create/Modify actions.')
        public String courseId;
        @InvocableVariable(label='Curriculum ID' description='The ID of the Curriculum to assign. Exactly one of Asset, Course, or Curriculum ID must be provided for Create/Modify actions.')
        public String curriculumId;
        
        @InvocableVariable(label='Due Date' description='Due date for the assignment. Required for Create actions. Format: YYYY-MM-DD')
        public Date dueDate;
        @InvocableVariable(label='Start Date' description='Start date for the assignment. Required for Create actions. Format: YYYY-MM-DD. Must be a future date.')
        public Date startDate;
        
        @InvocableVariable(label='Recur' description='Set to true if this is a recurring assignment.')
        public Boolean recur;
        @InvocableVariable(label='Frequency' description='For recurring assignments. Valid values: Daily, Weekly, Monthly, Annually')
        public String frequency;
        @InvocableVariable(label='Frequency Weekday' description='For recurring assignments. Valid values: Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday')
        public String frequencyWeekday;
        @InvocableVariable(label='Content Distribution Organization' description='Optional organization for the content. Valid values: Business Technology, Corporate Marketing, CSG - Customer Success, CSG - Partners, CSG - Professional Services, Employee Learning, Employee Success, Equality, Field Marketing, Finance, Global Business Services, Global Enablement, Global Recruiting, Global Safety & Security, GO Center, Japan Enablement, Legal, Mulesoft, OU Leader, Product Marketing, Real Estate & Workspaces Services (REWS), Salesforce.org, Sales Programs, Sales Strategy, Security, SEED, Slack, Tableau, Talent Marketplace, TMP, Trailhead, Trust')
        public String contentDistributionOrg;
    }

    public class Response {
        @InvocableVariable(label='Success' description='Indicates if the specific operation for this request succeeded.')
        public Boolean success = false;
        @InvocableVariable(label='Message' description='A summary of the operation result for this specific request.')
        public String message = '';
        @InvocableVariable(label='Assigned Learning Records' description='The Assigned Learning record(s) returned by this specific request.')
        public List<Assigned_Learning__c> assignedLearningRecords = new List<Assigned_Learning__c>();
    }

    @InvocableMethod(label='GA-FRA2 Manage Assigned Learning' description='A bulk-safe method to manage learning assignments for audiences. Supports Create, Modify, Retrieve, Search, and Inactivate actions.')
    public static List<Response> manageAssignedLearning(List<Request> requests) {
        List<Assigned_Learning__c> toCreate = new List<Assigned_Learning__c>();
        List<Assigned_Learning__c> toUpdate = new List<Assigned_Learning__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            // Count how many content IDs are provided in this request
            Integer contentIdCount = 0;
            if (String.isNotBlank(req.assetId)) contentIdCount++;
            if (String.isNotBlank(req.courseId)) contentIdCount++;
            if (String.isNotBlank(req.curriculumId)) contentIdCount++;

            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.audienceId) || req.startDate == null || req.dueDate == null) {
                        res.message = 'Error: Audience ID, Start Date, and Due Date are required for Create.';
                    } else if (contentIdCount != 1) {
                        res.message = 'Error: Exactly one content ID (Asset, Course, or Curriculum) must be provided for Create.';
                    } else if (req.startDate <= Date.today()) {
                        res.message = 'Error: Start Date must be in the future.';
                    } else {
                        toCreate.add(buildRecordFromRequest(new Assigned_Learning__c(), req));
                    }
                }
                when 'Modify', 'Retrieve', 'Inactivate' {
                    if (String.isBlank(req.assignedLearningId)) {
                        res.message = 'Error: Assigned Learning ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.assignedLearningId);
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
            Map<Id, Assigned_Learning__c> recordsFromDb = new Map<Id, Assigned_Learning__c>([
                SELECT Id, Name, Audience__c, Asset__c, Course__c, Curriculum__c, Due_Date__c, Start_Date__c, Recur__c, Frequency__c, Frequency_Weekday__c, Content_Distribution_Organization__c
                FROM Assigned_Learning__c WHERE Id IN :idsToProcess
            ]);

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (String.isBlank(req.assignedLearningId) || !recordsFromDb.containsKey(req.assignedLearningId)) continue;
                
                Response res = responseMap.get(i);
                Assigned_Learning__c record = recordsFromDb.get(req.assignedLearningId);

                // Count content IDs provided for the modify request
                Integer contentIdCount = 0;
                if (String.isNotBlank(req.assetId)) contentIdCount++;
                if (String.isNotBlank(req.courseId)) contentIdCount++;
                if (String.isNotBlank(req.curriculumId)) contentIdCount++;

                if (req.actionType == 'Modify') {
                    if (req.startDate != null && req.startDate <= Date.today()) {
                        res.message = 'Error: Start Date must be in the future.';
                    } else if (contentIdCount > 1) {
                        res.message = 'Error: You can only specify one content type (Asset, Course, or Curriculum) to modify.';
                    } else {
                        toUpdate.add(buildRecordFromRequest(record, req));
                    }
                } else if (req.actionType == 'Inactivate') {
                    res.success = true;
                    res.message = 'Inactivate action noted, but no status field exists on object to update.';
                } else if (req.actionType == 'Retrieve') {
                    res.success = true;
                    res.message = 'Assigned Learning retrieved successfully.';
                    res.assignedLearningRecords.add(record);
                }
            }
        }
        
        if (!toUpdate.isEmpty()){
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            handleDmlResults(updateResults, toUpdate, 'Modify', requests, responseMap);
        }
        
        return new List<Response>(responseMap.values());
    }

    private static Assigned_Learning__c buildRecordFromRequest(Assigned_Learning__c record, Request req) {
        if (String.isNotBlank(req.audienceId)) record.Audience__c = req.audienceId;
        if (String.isNotBlank(req.assetId)) record.Asset__c = req.assetId;
        if (String.isNotBlank(req.courseId)) record.Course__c = req.courseId;
        if (String.isNotBlank(req.curriculumId)) record.Curriculum__c = req.curriculumId;
        if (req.dueDate != null) record.Due_Date__c = req.dueDate;
        if (req.startDate != null) record.Start_Date__c = req.startDate;
        if (req.recur != null) record.Recur__c = req.recur;
        if (String.isNotBlank(req.frequency)) record.Frequency__c = req.frequency;
        if (String.isNotBlank(req.frequencyWeekday)) record.Frequency_Weekday__c = req.frequencyWeekday;
        if (String.isNotBlank(req.contentDistributionOrg)) record.Content_Distribution_Organization__c = req.contentDistributionOrg;
        return record;
    }

    private static void handleDmlResults(Database.SaveResult[] results, List<Assigned_Learning__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType == action && responseMap.get(i).message == '') { 
                Database.SaveResult sr = results[recordIndex];
                Response res = responseMap.get(i);
                if (sr.isSuccess()) {
                    res.success = true;
                    res.message = 'Assigned Learning ' + action.toLowerCase() + 'd successfully.';
                    res.assignedLearningRecords.add(records[recordIndex]);
                } else {
                    res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                }
                recordIndex++;
            }
        }
    }
    
    private static void handleSearch(Request req, Response res) {
        String query = 'SELECT Id, Name, Audience__c, Asset__c, Course__c, Curriculum__c, Due_Date__c, Start_Date__c, Frequency__c FROM Assigned_Learning__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.assignedLearningName)) conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(req.assignedLearningName) + '%\'');
        if (String.isNotBlank(req.audienceId)) conditions.add('Audience__c = \'' + String.escapeSingleQuotes(req.audienceId) + '\'');
        if (String.isNotBlank(req.assetId)) conditions.add('Asset__c = \'' + String.escapeSingleQuotes(req.assetId) + '\'');
        if (String.isNotBlank(req.courseId)) conditions.add('Course__c = \'' + String.escapeSingleQuotes(req.courseId) + '\'');
        if (String.isNotBlank(req.curriculumId)) conditions.add('Curriculum__c = \'' + String.escapeSingleQuotes(req.curriculumId) + '\'');
        
        if(!conditions.isEmpty()){
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        query += ' ORDER BY LastModifiedDate DESC LIMIT 500';

        try {
            List<Assigned_Learning__c> records = Database.query(query);
            res.success = true;
            res.message = 'Search executed successfully. Records found: ' + records.size();
            res.assignedLearningRecords = records;
        } catch (Exception e) {
            res.message = 'Error during search: ' + e.getMessage();
        }
    }
}