/**
 * @description Handles CRUD operations for Deliverable records in the Enablement Operations App (EOA).
 * This handler uses explicit InvocableVariables for clarity and ease of use by agents.
 * Deliverables represent tangible outputs required to complete an Epic.
 */
public with sharing class GAEOA2DeliverableHandler {

    // --- INNER REQUEST CLASS (Strongly-Typed) ---
    public class Request {
        @InvocableVariable(label='Action Type' description='Specify the action: Create | Modify | Retrieve | Search | Cancel' required=true)
        public String actionType;

        @InvocableVariable(label='Deliverable ID' description='Salesforce ID of the Deliverable. Required for Modify, Retrieve, or Cancel.')
        public String deliverableId;

        @InvocableVariable(label='Related Epic ID' description='ID of the parent Epic. Required for Create.')
        public String relatedEpicId;

        @InvocableVariable(label='Deliverable Title' description='The title or name of the deliverable.')
        public String deliverableTitle;

        @InvocableVariable(label='Deliverable Type' description='The type of deliverable (e.g., ACT Course, vILT, Impact Map).')
        public String deliverableType;

        @InvocableVariable(label='Status' description='The current status of the deliverable (e.g., Discovery, Launched, Cancelled).')
        public String status;

        @InvocableVariable(label='Launch Date' description='The date the deliverable was or will be launched.')
        public Date launchDate;

        @InvocableVariable(label='Design Lead ID' description='ID of the user who is the Design Lead.')
        public String designLeadId;

        @InvocableVariable(label='Target Audience' description='The primary audience for this deliverable (e.g., AE, SE, CSG).')
        public String targetAudience;

        @InvocableVariable(label='Scope of Deliverable' description='The scope of the work (e.g., Net-New, Refresh).')
        public String scopeOfDeliverable;

        @InvocableVariable(label='Deliverable URL' description='A link to the final deliverable asset.')
        public String deliverableUrl;
        
        // --- Conditional Fields Based on Type ---
        @InvocableVariable(label='ACT 2.0 Course ID' description='(Used if Deliverable Type is "ACT Course") Link to the ACT 2.0 Course record.')
        public String act2CourseId;
        
        @InvocableVariable(label='Impact Map Check-In' description='(Used if Deliverable Type is "Impact Map") The phase of the impact map check-in.')
        public String impactMapCheckIn;
        
        @InvocableVariable(label='Impact Map Scope' description='(Used if Deliverable Type is "Impact Map") Whether the scope has changed.')
        public String impactMapScope;

        // Search-specific fields
        @InvocableVariable(label='Created Date Filter' description='For Search only. Formats: YYYY-MM-DD, etc.')
        public String createdDate;
    }

    // --- INNER RESPONSE CLASS (Returns SObjects directly) ---
    public class Response {
        @InvocableVariable(label='Success' description='True if the operation was successful.')
        public Boolean success = false;

        @InvocableVariable(label='Message' description='A summary of the operation result.')
        public String message = '';

        @InvocableVariable(label='Deliverable Records' description='A list of Deliverable records returned by the operation.')
        public List<Deliverable__c> deliverableRecords = new List<Deliverable__c>();
    }

    // --- INVOCABLE METHOD ---
    @InvocableMethod(label='EOA Manage Deliverables' description='A bulk-safe method to manage Deliverable records in the EOA.')
    public static List<Response> manageDeliverables(List<Request> requests) {
        List<Deliverable__c> toCreate = new List<Deliverable__c>();
        List<Deliverable__c> toUpdate = new List<Deliverable__c>();
        Set<Id> idsToProcess = new Set<Id>();
        Map<Integer, Response> responseMap = new Map<Integer, Response>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request req = requests.get(i);
            Response res = new Response();
            responseMap.put(i, res);

            switch on req.actionType {
                when 'Create' {
                    if (String.isBlank(req.relatedEpicId)) {
                        res.message = 'Error: Related Epic ID is required for creation.';
                    } else {
                        Deliverable__c newDeliverable = new Deliverable__c(
                            Related_Epic__c = req.relatedEpicId,
                            Deliverable_Title__c = req.deliverableTitle,
                            Deliverable_Type__c = req.deliverableType,
                            Status__c = String.isNotBlank(req.status) ? req.status : 'Discovery', // Business Rule: Default to Discovery
                            Launch_Date__c = req.launchDate,
                            Design_Lead__c = req.designLeadId,
                            Target_Audience__c = req.targetAudience,
                            Scope_of_Deliverable__c = req.scopeOfDeliverable,
                            Deliverable_URL__c = req.deliverableUrl,
                            ACT2Course__c = req.act2CourseId,
                            Impact_Map__c = req.impactMapCheckIn,
                            Impact_Map_Scope__c = req.impactMapScope
                        );
                        toCreate.add(newDeliverable);
                    }
                }
                when 'Modify', 'Retrieve', 'Cancel' {
                    if (String.isBlank(req.deliverableId)) {
                        res.message = 'Error: Deliverable ID is required for ' + req.actionType + '.';
                    } else {
                        idsToProcess.add(req.deliverableId);
                    }
                }
                when 'Search' {
                    handleDeliverableSearch(req, res);
                }
                when else {
                    res.message = 'Error: Invalid or missing action type provided.';
                }
            }
        }
        
        // --- DML OPERATIONS ---
        if (!toCreate.isEmpty()) {
            Database.SaveResult[] createResults = Database.insert(toCreate, false);
            Integer createIndex = 0;
            for (Integer i = 0; i < requests.size(); i++) {
                if (requests.get(i).actionType == 'Create' && responseMap.get(i).message == '') {
                    Database.SaveResult sr = createResults[createIndex];
                    Response res = responseMap.get(i);
                    if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Deliverable created successfully.';
                        res.deliverableRecords.add(toCreate[createIndex]);
                    } else {
                        res.message = 'Error creating deliverable: ' + sr.getErrors()[0].getMessage();
                    }
                    createIndex++;
                }
            }
        }

        if (!idsToProcess.isEmpty()) {
            Map<Id, Deliverable__c> deliverablesFromDb = new Map<Id, Deliverable__c>([
                SELECT Id, Name, Related_Epic__c, Deliverable_Title__c, Deliverable_Type__c, Status__c, 
                       Launch_Date__c, Design_Lead__c, Target_Audience__c, Scope_of_Deliverable__c, Deliverable_URL__c
                FROM Deliverable__c WHERE Id IN :idsToProcess
            ]);

            for (Integer i = 0; i < requests.size(); i++) {
                Request req = requests.get(i);
                if (req.actionType == 'Modify' || req.actionType == 'Retrieve' || req.actionType == 'Cancel') {
                    if (String.isBlank(req.deliverableId) || !deliverablesFromDb.containsKey(req.deliverableId)) {
                        if (responseMap.get(i).message == '') {
                           responseMap.get(i).message = 'Error: Deliverable with ID ' + req.deliverableId + ' not found.';
                        }
                        continue;
                    }

                    Deliverable__c d = deliverablesFromDb.get(req.deliverableId);
                    if (req.actionType == 'Modify') {
                        if(String.isNotBlank(req.deliverableTitle)) d.Deliverable_Title__c = req.deliverableTitle;
                        if(String.isNotBlank(req.deliverableType)) d.Deliverable_Type__c = req.deliverableType;
                        if(String.isNotBlank(req.status)) d.Status__c = req.status;
                        if(req.launchDate != null) d.Launch_Date__c = req.launchDate;
                        if(String.isNotBlank(req.designLeadId)) d.Design_Lead__c = req.designLeadId;
                        toUpdate.add(d);
                    } else if (req.actionType == 'Cancel') {
                        // Business Rule: To cancel, set the status field to the "Cancelled" picklist value.
                        d.Status__c = 'Cancelled';
                        toUpdate.add(d);
                    } else if (req.actionType == 'Retrieve') {
                        responseMap.get(i).success = true;
                        responseMap.get(i).message = 'Deliverable retrieved successfully.';
                        responseMap.get(i).deliverableRecords.add(d);
                    }
                }
            }
        }

        if(!toUpdate.isEmpty()){
            Database.SaveResult[] updateResults = Database.update(toUpdate, false);
            Integer updateIndex = 0;
            for(Integer i = 0; i < requests.size(); i++){
                 Request req = requests.get(i);
                 if((req.actionType == 'Modify' || req.actionType == 'Cancel') && responseMap.get(i).message == ''){
                     Database.SaveResult sr = updateResults[updateIndex];
                     Response res = responseMap.get(i);
                     if (sr.isSuccess()) {
                        res.success = true;
                        res.message = 'Deliverable ' + req.actionType.toLowerCase() + ' action completed successfully.';
                        res.deliverableRecords.add(toUpdate[updateIndex]);
                     } else {
                         res.message = 'Error updating deliverable: ' + sr.getErrors()[0].getMessage();
                     }
                     updateIndex++;
                 }
            }
        }
        
        return new List<Response>(responseMap.values());
    }
    
    // --- SEARCH HELPER METHOD ---
    private static void handleDeliverableSearch(Request req, Response res) {
        String soql = 'SELECT Id, Name, Related_Epic__c, Deliverable_Title__c, Deliverable_Type__c, Status__c, ' + 
                      'Launch_Date__c, Design_Lead__c, Target_Audience__c, CreatedDate, LastModifiedDate ' + 
                      'FROM Deliverable__c';
        
        List<String> conditions = new List<String>();

        if (String.isNotBlank(req.deliverableTitle)) {
            conditions.add('Deliverable_Title__c LIKE \'%' + String.escapeSingleQuotes(req.deliverableTitle) + '%\'');
        }
        if (String.isNotBlank(req.relatedEpicId)) {
            conditions.add('Related_Epic__c = \'' + String.escapeSingleQuotes(req.relatedEpicId) + '\'');
        }
        if (String.isNotBlank(req.status)) {
            conditions.add('Status__c = \'' + String.escapeSingleQuotes(req.status) + '\'');
        }
        if (String.isNotBlank(req.deliverableType)) {
            conditions.add('Deliverable_Type__c = \'' + String.escapeSingleQuotes(req.deliverableType) + '\'');
        }
        if (String.isNotBlank(req.designLeadId)) {
            conditions.add('Design_Lead__c = \'' + String.escapeSingleQuotes(req.designLeadId) + '\'');
        }
        if (String.isNotBlank(req.targetAudience)) {
            conditions.add('Target_Audience__c = \'' + String.escapeSingleQuotes(req.targetAudience) + '\'');
        }
        if (String.isNotBlank(req.scopeOfDeliverable)) {
            conditions.add('Scope_of_Deliverable__c = \'' + String.escapeSingleQuotes(req.scopeOfDeliverable) + '\'');
        }
        if (String.isNotBlank(req.createdDate)) {
            String dateCondition = GAFRA2Utility.parseDateFilter('CreatedDate', req.createdDate);
            if (String.isNotBlank(dateCondition)) {
                conditions.add(dateCondition);
            }
        }

        if(!conditions.isEmpty()){
            soql += ' WHERE ' + String.join(conditions, ' AND ');
        }
        soql += ' ORDER BY LastModifiedDate DESC LIMIT 500';

        try {
            List<Deliverable__c> deliverables = Database.query(soql);
            res.success = true;
            res.message = 'Deliverable search executed successfully. Records found: ' + deliverables.size();
            res.deliverableRecords = deliverables;
        } catch (Exception e) {
            res.message = 'Error during deliverable search: ' + e.getMessage();
        }
    }
}