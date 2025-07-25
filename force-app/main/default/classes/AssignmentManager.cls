public with sharing class AssignmentManager {
    /**
     * The assigned object by content object type.
     */
    public static final Map<String, String> ASSIGNED_OBJ_BY_CONTENT = new Map<String, String> {
        'Course__c' => 'Assigned_Course__c',
        'Curriculum__c' => 'Assigned_Curriculum__c',
        'Asset__c' => 'Assignment__c'
    };

    /**
     * Fetches the assigned learners for a given content record.
     * @param payload - The payload containing the recordId, page, and search term.
     * @return ResponseData - The response data containing the assigned learners and total counts.
     */
    @AuraEnabled(cacheable=true)
    public static ResponseData getAssignedLearners(AssignmentPayload payload) {
        ResponseData rd = new ResponseData();

        try {
            if (payload.recordId == null) {
                rd.put('assignedLearners', new List<Map<String, Object>>());
                return rd;
            }

            String contentObjectType = (payload.recordId).getSObjectType() + '';
            String assignmentObj = ASSIGNED_OBJ_BY_CONTENT.get(contentObjectType);
 
            if (!RecommendationHelper.VALID_CONTENT_RECORD_TYPES.contains(contentObjectType)) {
                throw new AssignedLearnersException('Fetching Assigned Learning from Invalid SObject Record Page: ' + contentObjectType);
            }

            List<Id> filteredAudienceIds = payload.idsToProcess;

            // Build assigned learner query
            Set<String> assignedLearnerFields = new Set<String> {
                'Id', 'Learner_Profile__c', 'Learner_Profile__r.Name', 'Learner_Profile__r.Primary_Email__c', 'Learner_Profile__r.User__r.SmallPhotoUrl', 
                'Completed__c', 'Inactive__c', 'Assigned_Learning__r.Audience__r.Name', 'Assigned_Learning__r.Audience__r.Id', 'Assigned_Learning__r.Due_Date__c', 'Assigned_Learning__r.Start_Date__c'
            };

            String queryFilters = buildQueryFilters(payload);
            String query = '';
            List<Id> currentIds = payload.currentlyDisplayedIds;

            if (payload.currentlyDisplayedIds != null && !payload.currentlyDisplayedIds.isEmpty()) {
                query = 'SELECT ' + String.join(assignedLearnerFields, ',') + ' FROM ' + assignmentObj + queryFilters + ' AND Id NOT IN :currentIds ORDER BY Learner_Profile__r.Name ASC LIMIT 30';
            } else {
                query = 'SELECT ' + String.join(assignedLearnerFields, ',') + ' FROM ' + assignmentObj + queryFilters + ' ORDER BY Learner_Profile__r.Name ASC LIMIT 30';
            }

            List<Map<String, Object>> assignedLearners = new List<Map<String, Object>>();

            // Format assigned learner fields
            for (SObject assignedLearner : Database.query(query, System.AccessLevel.USER_MODE)) {
                Map<String, Object> formattedAssignedLearner = assignedLearner.getPopulatedFieldsAsMap().clone();

                Learner_Profile__c learnerProfile = (Learner_Profile__c) assignedLearner.getSObject('Learner_Profile__r');
                Assigned_Learning__c assignedLearning = (Assigned_Learning__c) assignedLearner.getSObject('Assigned_Learning__r');
                String status = 'Assigned';

                if(assignedLearner.get('Completed__c') != null && (Boolean) assignedLearner.get('Completed__c')) {
                    status = 'Completed';
                } else if (assignedLearner.get('Inactive__c') != null && (Boolean)assignedLearner.get('Inactive__c')) {
                    status = 'Unenrolled';
                }

                formattedAssignedLearner.put('avatar', learnerProfile.User__r?.SmallPhotoUrl);
                formattedAssignedLearner.put('name', learnerProfile.Name);
                formattedAssignedLearner.put('email', learnerProfile.Primary_Email__c);
                formattedAssignedLearner.put('audienceName', assignedLearning?.Audience__r?.Name);
                formattedAssignedLearner.put('status', status);
                formattedAssignedLearner.put('audienceUrl', '/' + assignedLearning?.Audience__r?.Id);
                formattedAssignedLearner.put('dueOn', assignedLearning?.Due_Date__c.format());
                formattedAssignedLearner.put('assignedOn', assignedLearning?.Start_Date__c.format());

                assignedLearners.add(formattedAssignedLearner);
            }

            Boolean isCourse = contentObjectType == Course__c.getSObjectType() + '';
            Boolean isAsset = contentObjectType == Asset__c.getSObjectType() + '';    

            // Build count query
            String totalCountQuery = 'SELECT COUNT() FROM ' + assignmentObj + ' ' + queryFilters;
            
            if (isCourse) {
                totalCountQuery += ' AND Assigned_Curriculum__c = null';
            }
    
            if (isAsset) {
                totalCountQuery += ' AND Assigned_Curriculum__c = null AND Assigned_Course__c = null';
            }
            
            rd.put('assignedLearners', assignedLearners);
            rd.put('totalAssignedLearners', Database.countQuery(totalCountQuery, System.AccessLevel.USER_MODE));
            rd.put('totalFilteredAssignedLearners', Database.countQuery('SELECT COUNT() FROM ' + assignmentObj + queryFilters, System.AccessLevel.USER_MODE));
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    /**
     * Fetches the audience filter options for a given content record.
     * @param recordId - The recordId of the content record.
     * @return ResponseData - The response data containing the audience filter options.
     */
    @AuraEnabled(cacheable=true)
    public static ResponseData getAudienceFilterOptions(Id recordId) {
        responseData rd = new responseData();

        try {
            if (recordId == null) {
                rd.put('audienceFilterOptions', new List<Map<String, Object>>());
                return rd;        
            }

            String contentRecordType = recordId.getSObjectType() + '';
            
            if (!(RecommendationHelper.VALID_CONTENT_RECORD_TYPES.contains(contentRecordType))) {
                throw new AssignedLearnersException('Fetching Audience Filter Options from Invalid SObject Record Page: ' + contentRecordType);
            }

            String query = 'SELECT Id, Name FROM Audience__c WHERE Id IN (SELECT Audience__c FROM Assigned_Learning__c WHERE ' + contentRecordType + ' = :recordId)'; // AND Status__c = \'Active\')';
            query += ' ORDER BY Name ASC LIMIT 50';

            List<Map<String, Object>> audiences = new List<Map<String, Object>>();

            for (Audience__c audience : Database.query(query, System.AccessLevel.USER_MODE)) {
                audiences.add(new Map<String, Object>{
                    'label' => audience.Name,
                    'value' => audience.Id,
                    'checked' => false
                });
            }
            
            rd.put('audienceFilterOptions', audiences);          
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd;
    }

    /**
     * Updates the status of the assigned learners for a given content record.
     * @param payload - The payload containing the recordId, idsToProcess, status, and selectAll.
     * @return ResponseData - The response data containing the job id if the update is batched.
     */
    @AuraEnabled
    public static ResponseData updateLearners(AssignmentPayload payload){
        ResponseData rd = new ResponseData();

        try {
            if (payload.recordId == null) {
                rd.addError('Parameter `recordId` is required.');
                return rd;
            }

            String contentObjectType = (payload.recordId).getSObjectType() + '';
            String assignmentObj = ASSIGNED_OBJ_BY_CONTENT.get(contentObjectType);
            List<Id> assignedItemIds = payload.idsToProcess;
 
            String status = payload.status?.toLowerCase();
            String query = '';

            if (payload.selectAll) {
                List<Id> filteredAudienceIds = payload.idsToProcess;
                
                String queryFilters = buildQueryFilters(payload);

                if (Database.countQuery('SELECT COUNT() FROM ' + assignmentObj + queryFilters, System.AccessLevel.USER_MODE) > Utilities.BATCH_THRESHOLD) {
                    rd.put('jobId', Database.executeBatch(new AssignmentUpdateStatusBatch(payload)));
                    return rd;
                } else {
                    query = 'SELECT Id, Completed__c, Inactive__c FROM ' + assignmentObj + queryFilters;
                }
            } else if (!(payload.idsToProcess.isEmpty())) {
                query = 'SELECT Id, Completed__c, Inactive__c' + ' FROM ' + assignmentObj + ' WHERE Id IN :assignedItemIds';
            }

            List<SObject> assignedParents = Database.query(query, System.AccessLevel.USER_MODE);

            processAssignmentStatusUpdate(assignedParents, payload);            
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    /**
     * Processes the status update of the assigned learners for a given content record.
     * @param assignedParents - The assigned parents to process.
     * @param payload - The payload containing the recordId, idsToProcess, and status.
     */
    public static void processAssignmentStatusUpdate(List<SObject> assignedParents, AssignmentPayload payload){
        String contentObjectType = (payload.recordId).getSObjectType() + '';
        String assignmentObj = ASSIGNED_OBJ_BY_CONTENT.get(contentObjectType);
        List<Id> assignedItemIds = new List<Id>();

        for (SObject assignedParent : assignedParents) {
            assignedItemIds.add(assignedParent.Id);
        }

        String status = payload.status?.toLowerCase();

        if (status == 'cancelled') {
            List<sObject> itemsToCancel = new List<sObject>();
            List<String> cancelledItemIds= new List<String>();

            //child items will be deleted via trigger
            for (sObject assignedParent : assignedParents) {
                if(!(Boolean)assignedParent.get('Inactive__c') && !(Boolean)assignedParent.get('Completed__c')) {
                    assignedParent.put('Inactive__c', true);
                    cancelledItemIds.add((String)assignedParent.get('Id'));
                    itemsToCancel.add(assignedParent);
                }
            }

            if(!itemsToCancel.isEmpty()) {
                update as user itemsToCancel;
                
                List<Learning_History__c> lhs = UnenrollLearning.generateLearningHistories(cancelledItemIds, null, null);
    
                insert as user lhs;
            }
        } else { //else update bottom up which cascades upwards
            String lookupLocation = assignmentObj == 'Assignment__c' ? 'Id' : assignmentObj;
            String assignQuery = 'SELECT Id, Completed__c FROM Assignment__c WHERE ' + lookupLocation + ' IN :assignedItemIds';

            List<sObject> assignments = Database.query(assignQuery);

            for (sObject assignment : assignments) {
                assignment.put('Completed__c', true);
            }

            update as user assignments;
        }
    }

    /**
     * Builds the query filters for the assigned learners.
     * @param payload - The payload containing the recordId, selectAll, idsToProcess, and searchTerm.
     * @return String - The query filters.
     */
    public static String buildQueryFilters(Utilities.DataTablePayload payload) {
        SObjectType sObjType = payload.recordId.getSobjectType();
        Boolean isCourse = sObjType == Course__c.getSObjectType();
        Boolean isAsset = sObjType == Asset__c.getSObjectType();
        AssignmentPayload assignmentPayload = (AssignmentPayload) payload;

        String queryFilters = ' WHERE ' + (payload.recordId).getSObjectType() + ' = \'' + payload.recordId + '\'';

        if (isCourse) {
            queryFilters += ' AND Assigned_Curriculum__c = null';
        }

        if (isAsset) {
            queryFilters += ' AND Assigned_Curriculum__c = null AND Assigned_Course__c = null';
        }

        if (!payload.idsToProcess.isEmpty()) {
            queryFilters += ' AND Assigned_Learning__r.Audience__c IN :filteredAudienceIds';
        }

        if (String.isNotEmpty(payload.searchTerm)) {
            queryFilters += ' AND Learner_Profile__r.Name LIKE \'%' + String.escapeSingleQuotes(payload.searchTerm) + '%\'';
        } 
        
        if(assignmentPayload.status != null && String.isNotEmpty(assignmentPayload.status)) {
            queryFilters += ' AND Completed__c = ' + String.escapeSingleQuotes(assignmentPayload.status);
        }


        return queryFilters;
    }

    public class AssignmentPayload extends Utilities.DataTablePayload {
        @AuraEnabled public String status { get; set; }
    }

    public class AssignedLearnersException extends Exception {}
}