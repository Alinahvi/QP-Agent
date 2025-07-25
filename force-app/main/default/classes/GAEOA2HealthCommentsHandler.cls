public with sharing class GAEOA2HealthCommentsHandler {

    public class Request {
        @InvocableVariable(label='GA-EOA2 Action Type' description='Specify the action: Create | Modify | Retrieve | Search' required=true)
        public String actionType;
        @InvocableVariable(label='GA-EOA2 Health Comment ID' description='Salesforce Health Comment record ID. Required for Modify and Retrieve actions.')
        public String healthCommentId;

        // --- Health_Comments__c Fields ---
        @InvocableVariable(label='GA-EOA2 Comments' description='Value for the Comments (Comments__c) field.')
        public String comments;
        @InvocableVariable(label='GA-EOA2 Comment Date' description='Value for the Comment Date (Comment_Date__c) field. Format: YYYY-MM-DD')
        public Date commentDate;
        @InvocableVariable(label='GA-EOA2 Project' description='Salesforce ID of the related Project (Project__c).')
        public String projectId;
        @InvocableVariable(label='GA-EOA2 Program' description='Salesforce ID of the related Program (Program__c).')
        public String programId;
        @InvocableVariable(label='GA-EOA2 Epic' description='Salesforce ID of the related Epic (Epic__c).')
        public String epicId;
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
        @InvocableVariable(label='GA-EOA2 Health Comment Records' description='List of Health Comment records from the operation.')
        public List<Health_Comments__c> healthCommentRecords = new List<Health_Comments__c>();
    }

    @InvocableMethod(label='GA-EOA2 Manage Health Comments' description='Handles Create, Modify, Retrieve, and Search actions for Health Comment records.')
    public static List<Response> manageHealthComments(List<Request> requests) {
        List<Health_Comments__c> toCreate = new List<Health_Comments__c>();
        List<Health_Comments__c> toUpdate = new List<Health_Comments__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            responseMap.put(i, new Response());
            Request req = requests.get(i);
            
            switch on req.actionType {
                when 'Create' {
                    toCreate.add(mapRequestToHealthComment(req, new Health_Comments__c()));
                }
                when 'Modify', 'Retrieve' {
                    if (String.isBlank(req.healthCommentId)) {
                        responseMap.get(i).message = 'Error: Health Comment ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.healthCommentId);
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
            String allFieldsQuery = 'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Health_Comments__c').getDescribe().fields.getMap().keySet()), ',') + ' FROM Health_Comments__c WHERE Id IN :idsToProcess';
            Map<Id, Health_Comments__c> commentsFromDb = new Map<Id, Health_Comments__c>((List<Health_Comments__c>)Database.query(allFieldsQuery));

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                Response res = responseMap.get(i);
                
                if (String.isNotBlank(req.healthCommentId) && commentsFromDb.containsKey(req.healthCommentId)) {
                    if (req.actionType == 'Modify') {
                        toUpdate.add(mapRequestToHealthComment(req, commentsFromDb.get(req.healthCommentId)));
                    } else if (req.actionType == 'Retrieve') {
                        res.success = true;
                        res.message = 'Health Comment retrieved successfully.';
                        res.healthCommentRecords.add(commentsFromDb.get(req.healthCommentId));
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

    private static Health_Comments__c mapRequestToHealthComment(Request req, Health_Comments__c comment) {
        if(req.actionType == 'Modify') comment.Id = req.healthCommentId;
        if(req.comments != null) comment.Comments__c = req.comments;
        if(req.commentDate != null) comment.Comment_Date__c = req.commentDate;
        if(req.projectId != null) comment.Project__c = req.projectId;
        if(req.programId != null) comment.Program__c = req.programId;
        if(req.epicId != null) comment.Epic__c = req.epicId;
        if(req.ownerId != null) comment.OwnerId = req.ownerId;
        return comment;
    }

    private static void handleDmlResults(Database.SaveResult[] results, List<Health_Comments__c> records, String action, List<Request> requests, Map<Integer, Response> responseMap) {
        Integer recordIndex = 0;
        for (Integer i = 0; i < requests.size(); i++) {
            if (requests.get(i).actionType == action) {
                if (recordIndex < results.size()) {
                    Database.SaveResult sr = results[recordIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Health Comment ' + action.toLowerCase() + 'd successfully.';
                        res.healthCommentRecords.add(records[recordIndex]);
                    } else {
                        res.message = 'Error: ' + sr.getErrors()[0].getMessage();
                    }
                    recordIndex++;
                }
            }
        }
    }
    
    private static void handleSearch(Request req, Response res) {
        String allFields = String.join(new List<String>(Schema.getGlobalDescribe().get('Health_Comments__c').getDescribe().fields.getMap().keySet()), ',');
        String soql = 'SELECT ' + allFields + ' FROM Health_Comments__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.comments)) {
            conditions.add('Comments__c LIKE \'%' + String.escapeSingleQuotes(req.comments) + '%\'');
        }
        if (String.isNotBlank(req.ownerId)) {
            conditions.add('OwnerId = \'' + String.escapeSingleQuotes(req.ownerId) + '\'');
        }
        if (String.isNotBlank(req.projectId)) {
            conditions.add('Project__c = \'' + String.escapeSingleQuotes(req.projectId) + '\'');
        }
        if (String.isNotBlank(req.programId)) {
            conditions.add('Program__c = \'' + String.escapeSingleQuotes(req.programId) + '\'');
        }
        if (String.isNotBlank(req.epicId)) {
            conditions.add('Epic__c = \'' + String.escapeSingleQuotes(req.epicId) + '\'');
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
            res.healthCommentRecords = Database.query(soql);
            res.success = true;
            res.message = 'Health Comment search executed. Records found: ' + res.healthCommentRecords.size();
        } catch (Exception e) {
            res.message = 'Error during Health Comment search: ' + e.getMessage();
        }
    }
}