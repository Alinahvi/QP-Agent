public with sharing class GAFRA2AudienceMemberHandler {

    // Request and Response classes remain the same
    public class Request {
        @InvocableVariable(label='Action Type' description='Defines the operation for this specific request object. Format: A string literal. Example: "Create"' required=true)
        public String actionType;
        @InvocableVariable(label='Audience Member ID' description='The unique record ID to target for Modify, Retrieve, or Inactivate actions. Format: Salesforce 18-character ID string. Example: "a7kHu000001ERwxIAG"')
        public String audienceMemberId;
        @InvocableVariable(label='Audience ID' description='The Audience record ID to link or filter by. Required for "Create" action. Format: Salesforce 18-character ID string. Example: "a6GD7000000S6dGMAS"')
        public String audienceId;
        @InvocableVariable(label='Learner Profile ID' description='The Learner Profile record ID to link or filter by. Required for "Create" action. Format: Salesforce 18-character ID string. Example: "a5jHu000001ERwwIAG"')
        public String learnerProfileId;
        @InvocableVariable(label='Manually Added' description='The value for the "Manually Added" checkbox field. Format: JSON boolean (true or false, without quotes). Example: true')
        public Boolean manuallyAdded;
        @InvocableVariable(label='Created Date' description='Search only. Filters records by their Created Date. WARNING: Each "Search" request executes an independent database query. Format: A string literal. Example: "2023-10-26" or "LAST_N_DAYS:30"')
        public String createdDate;
        @InvocableVariable(label='Last Modified Date' description='Search only. Filters records by their Last Modified Date. WARNING: Each "Search" request executes an independent database query. Format: A string literal. Example: "YESTERDAY"')
        public String lastModifiedDate;
        @InvocableVariable(label='Created By User ID' description='Search only. Filters by the ID of the user who created the record. WARNING: Each "Search" request executes an independent database query. Format: Salesforce 18-character ID string. Example: "005Hu000001ERwyIAG"')
        public String createdById;
        @InvocableVariable(label='Last Modified By User ID' description='Search only. Filters by the ID of the user who last modified the record. WARNING: Each "Search" request executes an independent database query. Format: Salesforce 18-character ID string. Example: "005Hu000001ERwzIAG"')
        public String lastModifiedById;
    }
    public class Response {
        @InvocableVariable(label='Success' description='Indicates if the specific operation for this request succeeded. Format: Boolean (true/false).')
        public Boolean success = false;
        @InvocableVariable(label='Message' description='A summary of the operation result for this specific request. Format: Text string.')
        public String message = '';
        @InvocableVariable(label='Audience Member Records' description='The Audience Member record(s) returned by this specific request. Format: A list of Audience_Member__c sObjects.')
        public List<Audience_Member__c> audienceMemberRecords = new List<Audience_Member__c>();
    }

    @InvocableMethod(label='GA-FRA2 Manage Audience Member Records' description='A bulk-safe method to manage Audience Member records. The input must be a JSON array where each object is a self-contained request. The method returns a JSON array of responses in the same order as the input requests.')
    public static List<Response> manageAudienceMember(List<Request> requests) {
        // The main bulk logic remains the same
        List<Audience_Member__c> toCreate = new List<Audience_Member__c>();
        List<Audience_Member__c> toUpdate = new List<Audience_Member__c>();
        Map<Request, Response> responseMap = new Map<Request, Response>();
        Map<String, Request> createKeyToRequestMap = new Map<String, Request>();
        for (Request req : requests) {
            Response res = new Response();
            responseMap.put(req, res);
            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.audienceId) || String.isBlank(req.learnerProfileId)) {
                        res.message = 'Error: Audience ID and Learner Profile ID are required for Create.';
                        continue;
                    }
                    String key = req.audienceId + '-' + req.learnerProfileId;
                    Audience_Member__c audMember = new Audience_Member__c(
                        Audience__c = req.audienceId,
                        Learner_Profile__c = req.learnerProfileId,
                        Manually_Added__c = (req.manuallyAdded == null) ? false : req.manuallyAdded
                    );
                    toCreate.add(audMember);
                    createKeyToRequestMap.put(key, req);
                }
                when 'Modify', 'Inactivate', 'Retrieve' {
                    if (String.isBlank(req.audienceMemberId)) {
                        res.message = 'Error: Audience Member ID is required for ' + req.actionType + '.';
                    }
                }
                when 'Search' {
                    handleSearch(req, res); // This will now call the upgraded search logic
                }
                when else {
                    res.message = 'Error: Action type not implemented or invalid.';
                }
            }
        }
        
        // DML logic remains the same...
        if (!toCreate.isEmpty()) {
            Set<Id> audienceIdsForCheck = new Set<Id>();
            Set<Id> learnerProfileIdsForCheck = new Set<Id>();
            for(Audience_Member__c am : toCreate) {
                audienceIdsForCheck.add(am.Audience__c);
                learnerProfileIdsForCheck.add(am.Learner_Profile__c);
            }
            for (Audience_Member__c existingMember : [SELECT Id, Audience__c, Learner_Profile__c FROM Audience_Member__c WHERE Audience__c IN :audienceIdsForCheck AND Learner_Profile__c IN :learnerProfileIdsForCheck]) {
                String existingKey = existingMember.Audience__c + '-' + existingMember.Learner_Profile__c;
                if (createKeyToRequestMap.containsKey(existingKey)) {
                    Request reqToFail = createKeyToRequestMap.get(existingKey);
                    responseMap.get(reqToFail).message = 'Error: Audience Member already exists for this Learner Profile and Audience.';
                    createKeyToRequestMap.remove(existingKey);
                }
            }
        }
        List<Audience_Member__c> finalToCreate = new List<Audience_Member__c>();
        for (Audience_Member__c am : toCreate) {
            if(createKeyToRequestMap.containsKey(am.Audience__c + '-' + am.Learner_Profile__c)) {
                finalToCreate.add(am);
            }
        }
        if (!finalToCreate.isEmpty()) {
            try {
                insert finalToCreate;
                for (Audience_Member__c createdMember : finalToCreate) {
                    String key = createdMember.Audience__c + '-' + createdMember.Learner_Profile__c;
                    Request req = createKeyToRequestMap.get(key);
                    if (req != null) {
                        Response res = responseMap.get(req);
                        res.success = true;
                        res.message = 'Audience Member created successfully.';
                        res.audienceMemberRecords.add(createdMember);
                    }
                }
            } catch (DmlException e) {
                for(Request req : createKeyToRequestMap.values()){
                    responseMap.get(req).message = 'Error creating Audience Members: ' + e.getMessage();
                }
            }
        }
        Set<Id> idsToProcess = new Set<Id>();
        for (Request req : requests) {
            if (String.isNotBlank(req.audienceMemberId) && (req.actionType == 'Modify' || req.actionType == 'Inactivate' || req.actionType == 'Retrieve')) {
                idsToProcess.add(req.audienceMemberId);
            }
        }
        if (!idsToProcess.isEmpty()) {
            Map<Id, Audience_Member__c> membersFromDb = new Map<Id, Audience_Member__c>([SELECT Id, Audience__c, Learner_Profile__c, Manually_Added__c FROM Audience_Member__c WHERE Id IN :idsToProcess]);
            for (Request req : requests) {
                if (!membersFromDb.containsKey(req.audienceMemberId)) continue;
                Response res = responseMap.get(req);
                Audience_Member__c member = membersFromDb.get(req.audienceMemberId);
                if (req.actionType == 'Modify') {
                    if (req.audienceId != null) member.Audience__c = req.audienceId;
                    if (req.learnerProfileId != null) member.Learner_Profile__c = req.learnerProfileId;
                    if (req.manuallyAdded != null) member.Manually_Added__c = req.manuallyAdded;
                    toUpdate.add(member);
                } else if (req.actionType == 'Inactivate') {
                    toUpdate.add(member);
                } else if (req.actionType == 'Retrieve') {
                    res.success = true;
                    res.message = 'Audience Member retrieved successfully.';
                    res.audienceMemberRecords.add(member);
                }
            }
        }
        if (!toUpdate.isEmpty()) {
            try {
                update toUpdate;
                for (Audience_Member__c updatedMember : toUpdate) {
                    for(Request req : requests) {
                        if(req.audienceMemberId == updatedMember.Id) {
                           Response res = responseMap.get(req);
                           res.success = true;
                           res.message = 'Audience Member ' + req.actionType.toLowerCase() + 'd successfully.';
                           res.audienceMemberRecords.add(updatedMember);
                           break; 
                        }
                    }
                }
            } catch (DmlException e) {
                for (Audience_Member__c memberToUpdate : toUpdate) {
                    for(Request req : requests) {
                        if(req.audienceMemberId == memberToUpdate.Id) {
                            responseMap.get(req).message = 'Error updating Audience Member: ' + e.getMessage();
                            break;
                        }
                    }
                }
            }
        }
        
        return responseMap.values();
    }
    
    // --- UPDATED Search Handler ---
    private static void handleSearch(Request req, Response res) {
        String query = 'SELECT Id, Audience__c, Learner_Profile__c, Manually_Added__c FROM Audience_Member__c';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.audienceId)) conditions.add('Audience__c = \'' + String.escapeSingleQuotes(req.audienceId) + '\'');
        if (String.isNotBlank(req.learnerProfileId)) conditions.add('Learner_Profile__c = \'' + String.escapeSingleQuotes(req.learnerProfileId) + '\'');
        if (String.isNotBlank(req.createdById)) conditions.add('CreatedById = \'' + String.escapeSingleQuotes(req.createdById) + '\'');
        if (String.isNotBlank(req.lastModifiedById)) conditions.add('LastModifiedById = \'' + String.escapeSingleQuotes(req.lastModifiedById) + '\'');
        
        // --- ADDED: Call the robust date parser ---
        if (String.isNotBlank(req.createdDate)) {
            conditions.add(GAFRA2Utility.parseDateFilter('CreatedDate', req.createdDate));
        }
        if (String.isNotBlank(req.lastModifiedDate)) {
            conditions.add(GAFRA2Utility.parseDateFilter('LastModifiedDate', req.lastModifiedDate));
        }

        if (conditions.isEmpty()) {
            res.message = 'Error: No search criteria provided.';
        } else {
            try {
                query += ' WHERE ' + String.join(conditions, ' AND ');
                query += ' ORDER BY LastModifiedDate DESC LIMIT 500';
                res.audienceMemberRecords = Database.query(query);
                res.success = true;
                res.message = 'Audience Members search executed successfully. Records found: ' + res.audienceMemberRecords.size();
            } catch (QueryException e) {
                res.message = 'Error during search: ' + e.getMessage();
            }
        }
    }
}