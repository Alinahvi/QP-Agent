public with sharing class Attendees {
    @AuraEnabled(cacheable=true)
    public static ResponseData getGuests(GuestPayload payload) {
        ResponseData rd = new ResponseData();
        try {
            String sObjectType = payload.recordId.getSObjectType() + '';

            if (sObjectType != Session__c.getSObjectType() + '') {
                throw new AttendeesException('Getting Guests from Invalid SObject Record Page: ' + sObjectType);
            }

            List<String> fields = new List<String> {
                'Id', 'Status__c', 'Registration_Type__c', 'Learner_Profile__c', 'Learner_Profile__r.Name', 'Learner_Profile__r.Primary_Email__c', 'Learner_Profile__r.User__r.SmallPhotoUrl'
            };

            String queryFilters = buildQueryFilters(payload);
            String query = '';
            List<Id> currentIds = payload.currentlyDisplayedIds;

            if (payload.currentlyDisplayedIds != null && !payload.currentlyDisplayedIds.isEmpty()) {
                query = 'SELECT ' + String.join(fields, ',') + ' FROM Assigned_Session__c' + queryFilters + ' AND Id NOT IN :currentIds ORDER BY Learner_Profile__r.Name ASC LIMIT 30';
            } else {
                query = 'SELECT ' + String.join(fields, ',') + ' FROM Assigned_Session__c' + queryFilters + ' ORDER BY Learner_Profile__r.Name ASC LIMIT 30';
            }

            List<Map<String, Object>> guests = new List<Map<String, Object>>();

            for (Assigned_Session__c guest : Database.query(query, System.AccessLevel.USER_MODE)) {
                Map<String, Object> formattedGuest = guest.getPopulatedFieldsAsMap().clone();

                formattedGuest.put('avatar', guest.Learner_Profile__r?.User__r?.SmallPhotoUrl);
                formattedGuest.put('name', guest.Learner_Profile__r?.Name);
                formattedGuest.put('email', guest.Learner_Profile__r?.Primary_Email__c);

                guests.add(formattedGuest);
            }

            // String totalCountQuery = 'SELECT COUNT() FROM Assigned_Session__c WHERE Session__c = \'' + payload.recordId + '\'';
            String allAttendeesIdsQuery = 'SELECT Learner_Profile__r.Id FROM Assigned_Session__c WHERE Session__c = \'' + payload.recordId + '\'';
            List<sObject> allAttendees = Database.query(allAttendeesIdsQuery, System.AccessLevel.USER_MODE);
            List<Id> allAttendeesIds = new List<Id>();

            for (sObject attendee : allAttendees) {
                allAttendeesIds.add((Id) attendee.get('Learner_Profile__c'));
            }
            
            rd.put('allAttendeesIds', allAttendeesIds);
            rd.put('guests', guests);
            rd.put('totalGuests', allAttendeesIds.size());
            rd.put('totalFilteredGuests', Database.countQuery('SELECT COUNT() FROM Assigned_Session__c' + queryFilters, System.AccessLevel.USER_MODE));
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public static String buildQueryFilters(GuestPayload payload) {
        String queryFilters = ' WHERE Session__c = \'' + payload.recordId + '\'';

        if (String.isNotEmpty(payload.statusFilter) && payload.statusFilter != 'All'){
            queryFilters += ' AND Status__c = \'' + String.escapeSingleQuotes(payload.statusFilter) + '\'';
        }

        if (String.isNotEmpty(payload.searchTerm)) {
            queryFilters += ' AND Learner_Profile__r.Name LIKE \'%' + String.escapeSingleQuotes(payload.searchTerm) + '%\'';
        }   

        return queryFilters;
    }

    @AuraEnabled
    public static string getData(String sessionId){
        responseData rd = new responseData();
        try {
            Boolean hasAssignLearning = FeatureManagement.checkPermission('Assign_Learning');
            Boolean isTrainerManager = FeatureManagement.checkPermission('Is_Trainer_Manager');
            rd.put('assetId', [SELECT Asset__c FROM Session__c WHERE Id =: sessionId WITH USER_MODE].Asset__c);
            rd.put('allowedPicklistVals', getAllowedStatusVals());
            // rd.put('session', session);
            rd.put('hasAssignLearning', hasAssignLearning);
            rd.put('isTrainerManager', isTrainerManager);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());            
        }

        return rd.getJsonString();
    }

    @AuraEnabled(cacheable=true)
    public static ResponseData getEventStatusValues(){
        responseData rd = new responseData();

        try {
            rd.put('allowedPicklistVals', getAllowedStatusVals());
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd;
    }

    @AuraEnabled(cacheable=true)
    public static ResponseData getEnablementPrograms(){
        return RecommendedLearners.getEnablementPrograms();
    }

    public static List<Map<String, String>> getAllowedStatusVals(){
        Boolean hasAssignLearning = FeatureManagement.checkPermission('Assign_Learning');
        List<Map<String, String>> picklistVals = Utilities.getPicklistVals(Assigned_Session__c.Status__c.getDescribe());
        List<Map<String, String>> allowedPicklistVals = new List<Map<String, String>>();

        if(hasAssignLearning){
            allowedPicklistVals = picklistVals;
        } else {
            List<String> allowedVals = new List<String>{'Attended', 'Exempt', 'Absent'};

            for(Map<String, String> picklistVal : picklistVals){
                if(allowedVals.contains(picklistVal.get('value'))){
                    allowedPicklistVals.add(picklistVal);
                }
            }
        }   

        return allowedPicklistVals;
    }

    // @AuraEnabled
    // public static ResponseData getGuestRoles(String recordId){
    //     ResponseData rd = new ResponseData();
        
    //     try {
    //         List<Session_Guest__c> guestRoles = [SELECT Id, Name, Learner_Profile__c, Learner_Profile__r.Name, 
    //                                                     Learner_Profile__r.Primary_Email__c, Role__c
    //                                               FROM Session_Guest__c
    //                                               WHERE Session__c =: recordId
    //                                               WITH USER_MODE
    //                                               ORDER BY Name ASC];

    //         // List<GCal_Event__c> gcalEvent = [SELECT Id FROM GCal_Event__c WHERE Contains_Owner__c = true LIMIT 1];
    //         // System.debug('*********** ' + !gcalEvent.isEmpty());
    //         // String gcalEventId = '';

    //         // if(!gcalEvent.isEmpty()){
    //         //     gcalEventId = gcalEvent.get(0).Id;
    //         // }

    //         rd.put('guestRoles', guestRoles);
    //         // rd.put('ownerGCalEventId', gcalEventId);
    //     } catch (Exception e) {
    //         rd.addError(e);
    //     }
    
    //     return rd;
    // }

    @AuraEnabled(cacheable=true)
    public static ResponseData getGuestRoles(GuestPayload payload) {
        ResponseData rd = new ResponseData();
        try {
            String sObjectType = payload.recordId.getSObjectType() + '';

            if (sObjectType != Session__c.getSObjectType() + '') {
                throw new AttendeesException('Getting Guest Roles from Invalid SObject Record Page: ' + sObjectType);
            }

            List<String> fields = new List<String> {
                'Id', 'Name', 'Learner_Profile__c', 'Learner_Profile__r.Name', 'Learner_Profile__r.Primary_Email__c', 'Learner_Profile__r.User__r.SmallPhotoUrl', 'Role__c', 'Session_Role_Status__c'
            };

            String queryFilters = ' WHERE Session__c = \'' + payload.recordId + '\'';

            if (String.isNotEmpty(payload.searchTerm)) {
                queryFilters += ' AND Learner_Profile__r.Name LIKE \'%' + String.escapeSingleQuotes(payload.searchTerm) + '%\'';
            }

            String query = '';
            List<Id> currentIds = payload.currentlyDisplayedIds;

            if (payload.currentlyDisplayedIds != null && !payload.currentlyDisplayedIds.isEmpty()) {
                query = 'SELECT ' + String.join(fields, ',') + ' FROM Session_Guest__c' + queryFilters + ' AND Id NOT IN :currentIds ORDER BY Name ASC LIMIT 30';
            } else {
                query = 'SELECT ' + String.join(fields, ',') + ' FROM Session_Guest__c' + queryFilters + ' ORDER BY Name ASC LIMIT 30';
            }

            List<Map<String, Object>> guestRoles = new List<Map<String, Object>>();

            for (Session_Guest__c guestRole : Database.query(query, System.AccessLevel.USER_MODE)) {
                Map<String, Object> formattedGuestRole = guestRole.getPopulatedFieldsAsMap().clone();

                formattedGuestRole.put('avatar', guestRole.Learner_Profile__r?.User__r?.SmallPhotoUrl);
                formattedGuestRole.put('name', guestRole.Learner_Profile__r?.Name);
                formattedGuestRole.put('email', guestRole.Learner_Profile__r?.Primary_Email__c);

                guestRoles.add(formattedGuestRole);
            }

            String totalCountQuery = 'SELECT COUNT() FROM Session_Guest__c WHERE Session__c = \'' + payload.recordId + '\'';

            rd.put('totalFilteredGuests', Database.countQuery('SELECT COUNT() FROM Session_Guest__c' + queryFilters, System.AccessLevel.USER_MODE));
            rd.put('guestRoles', guestRoles);
            rd.put('totalGuests', Database.countQuery(totalCountQuery, System.AccessLevel.USER_MODE));
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }


    // @AuraEnabled
    // public static String setGCalAttendees(List<String> sessionIds){
    //     responseData rd = new responseData();
    //     try {
    //         for(GCal_Event__c gcalEvent : [SELECT Id, Session__c, GCal_Event_Id__c, Contains_Owner__c, Owner.Name, Owner.Email FROM GCal_Event__c WHERE Session__c =: sessionIds]){
    //             if(Limits.getCallouts() == Limits.getLimitCallouts()) {
    //                 rd.addError('Too many sessions to update please make sure there are less than 100 session ids');
    //                 break;
    //             }
                
    //             Map<String, Object> returnPayload = gcalHandler.setGCalAttendees(gcalEvent, new Set<String>{});
    //             if((Boolean)returnPayload.get('success') == false){
    //                 rd.put('body', returnPayload.get('body'));
    //                 rd.addError((String)returnPayload.get('error'));                    
    //             }
    //         }
    //     } catch (Exception e) {
    //         rd.addError(e);
    //     }
    //     return rd.getJSONString();
    // }

    @AuraEnabled
    public static string processAttendees(String jsonString){
        responseData rd = new responseData();
        try {
            List<Assignment__c> assignments = new List<Assignment__c>();
            List<Assigned_Session__c> aSessions = new List<Assigned_Session__c>();

            ProcessAttendeesPayload payload = (ProcessAttendeesPayload) JSON.deserialize(jsonString, ProcessAttendeesPayload.class);

            Set<String> lpIds = new Set<String>();
            Map<String, Assignment__c> assignmentByLPId = new Map<String, Assignment__c>();
            Map<String, Assignment__c> newAssignmentByLPId = new Map<String, Assignment__c>();
            Map<String, Assigned_Session__c> aSessionByLPId = new Map<String, Assigned_Session__c>();
            Map<String, Assignment__c> completedAssignmentByLPId = new Map<String, Assignment__c>();

            for (LpToProcess lp : payload.lps) {
                lpIds.add(lp.id);
            }

            Map<Id, Learner_Profile__c> lps = new Map<Id, Learner_Profile__c>([SELECT Id, Name, User__c
                                                                               FROM Learner_Profile__c
                                                                               WHERE Id =: lpIds
                                                                               AND Status__c = 'Active'
                                                                               WITH USER_MODE]);

            Session__c sessionData = [SELECT Id, Name, Start_Date__c, End_Date__c, Asset__r.Mandatory_Session_Count__c, Asset__r.Event_Type__c
                                      FROM Session__c
                                      WHERE Id =: payload.sessionId
                                      WITH USER_MODE];


            List<Assigned_Session__c> existingAssignedSessions = [SELECT Id, Assignment__c, Assignment__r.Completed__c, Status__c, Registration_Type__c, 
                                                                         Self_Registered__c, Send_Registration_Email__c, Learner_Profile__c, Content_Distribution_Organization__c,
                                                                         Enablement_Learning_Program__c
                                                                  FROM Assigned_Session__c
                                                                  WHERE Session__c =: payload.sessionId
                                                                  AND Learner_Profile__c IN: lpIds];

            

            List<Assignment__c> existingAssignments = [SELECT Id, Learner_Profile__c, Completed__c
                                                       FROM Assignment__c
                                                       WHERE Asset__c =: payload.assetId
                                                       AND Completed__c = false
                                                       AND Learner_Profile__c IN: lpIds
                                                       WITH USER_MODE];

            for(Assigned_Session__c aSession : existingAssignedSessions){
                aSessionByLPId.put(aSession.Learner_Profile__c, aSession);
            }

            for(Assignment__c assignment : existingAssignments){
                assignmentByLPId.put(assignment.Learner_Profile__c, assignment);
            }

            if(sessionData.Asset__r.Event_Type__c == 'Course'){
                List<Assignment__c> completedAssignments = [SELECT Id, Learner_Profile__c, Completed__c
                                                            FROM Assignment__c
                                                            WHERE Asset__c =: payload.assetId
                                                            AND Completed__c = true
                                                            AND Learner_Profile__c IN: lpIds
                                                            WITH USER_MODE];

                for(Assignment__c assignment : completedAssignments){
                    completedAssignmentByLPId.put(assignment.Learner_Profile__c, assignment);
                }
            }

            if(sessionData.Asset__r.Event_Type__c != 'Course'){
                List<Assignment__c> assignmentsToInsert = new List<Assignment__c>();

                for (Learner_Profile__c lp : lps.values()) {
                    //If are starting from nothing make a new, otherwise it means we're updating an existing assigned session
                    if(!assignmentByLPId.containsKey(lp.Id) && !aSessionByLPId.containsKey(lp.Id)){
                        Assignment__c newAssignment = new Assignment__c(
                            Self_Assigned__c = false,
                            Due_Date__c = sessionData.End_Date__c,
                            OwnerId = lp.User__c,
                            Learner_Profile__c = lp.Id,
                            Asset__c = payload.assetId,
                            Mandatory_Session_Count__c = sessionData.Asset__r.Mandatory_Session_Count__c
                        );
    
                        // assignments.add(newAssignment);
                        assignmentByLPId.put(lp.Id, newAssignment);
                        assignmentsToInsert.add(newAssignment);
                    }
                }
    
                if(!assignmentsToInsert.isEmpty()){
                    insert as user assignmentsToInsert;
                }
            }

            List<Map<String, Object>> errors = new List<Map<String, Object>>();

            for (LpToProcess lp : payload.lps) {

                // lpStatusById.containsKey(lp.id) ? lpStatusById.get(data.Learner_Profile__c) : payload.eventStatusValue;
                String status = lp.status != null ? lp.status : payload.eventStatusValue;

                Assigned_Session__c aSession = aSessionByLPId.get(lp.id);
                Assignment__c assignment = assignmentByLPId.get(lp.id);
                String assignmentId = assignment != null ? assignment.Id : aSession?.Assignment__c;

                if(assignmentId == null){
                    String reason = 'An assignment must exist for course events.';

                    if(completedAssignmentByLPId.containsKey(lp.id)){
                        reason = 'This learner has already met the required session count.';
                    }

                    String lpName = lps.get(lp.Id)?.Name;
                    errors.add(new Map<String, Object>{
                        'id' => UUID.randomUUID().toString(),
                        'name' => lpName,
                        'sessionName' => sessionData.Name,
                        'reason' => reason
                    });

                    continue;
                }

                // if(aSession != null && aSession.Status__c == 'Attended'){
                //     continue;
                // }

                if(aSession == null){
                    aSession = new Assigned_Session__c(
                        Assignment__c = assignmentId,
                        Session__c = payload.sessionId,
                        Learner_Profile__c = lp.id,
                        Asset__c = payload.assetId,
                        Status__c = status,
                        Registration_Date_Time__c = System.now()
                    );
                }
            
                if(String.isNotEmpty(payload.cdo)){
                    aSession.Content_Distribution_Organization__c = payload.cdo;
                }

                if(String.isNotEmpty(payload.ouLeader)){
                    aSession.OU_Leader__c = payload.ouLeader;
                }

                if(String.isNotEmpty(payload.enablementProgram)){
                    aSession.Enablement_Learning_Program__c = payload.enablementProgram;
                }

                

                aSession.Self_Registered__c = false;
                aSession.Status__c = status;
                aSession.Registration_Type__c = lp.registrationType;
                aSession.Send_Registration_Email__c = status == 'Registered';
                
                aSessions.add(aSession);
            }
            
            if(!aSessions.isEmpty()) {
                upsert aSessions;                
                // if(eventStatusValue == 'Registered') {
                //     List<Map<String, Object>> newAttendees = new List<Map<String, Object>>();
                //     for(Learner_Profile__c lp : [SELECT Id, Name, Primary_Email__c FROM Learner_Profile__c WHERE Id =: lpIds]){
                //         newAttendees.add(new Map<String, Object>{
                //             'email' => lp.Primary_Email__c,
                //             'displayName' => lp.Name,
                //             'responseStatus' => 'accepted'
                //         });
                //     }
                //     String gcalEventId = GcalHandler.getOpenGCalSlot(sessionId, newAttendees);
                //     gcalEventsToUpdate.add(gcalEventId);
                    
                //     for(Assigned_Session__c session : aSessions) {
                //         session.GCal_Event__c = gcalEventId;
                //         session.GCal_Response__c = 'Accepted';
                //         session.Status__c = 'Registered';
                //         session.Registration_Date_Time__c = System.now();
                //     }
                //     update aSessions;
                // }
                // rd.put('gcalEventsToUpdate', gcalEventsToUpdate);
            }

            rd.put('errors', errors);
        } catch (Exception e) {
            rd.addError(e);
        }
        
        return rd.getJSONString();
    }    

    // @AuraEnabled
    // public static String refreshGCal(List<String> gcalEventIds){
    //     responseData rd = new responseData();
    //     try {
    //         for(GCal_Event__c gcalEvent : [SELECT Id, Session__c, GCal_Event_Id__c, Contains_Owner__c, Owner.Email, Owner.Name 
    //                                         FROM GCal_Event__c 
    //                                         WHERE Id =: gcalEventIds]){
                
    //             if(Limits.getCallouts() == Limits.getLimitCallouts()) {
    //                 rd.addError('Failed to update GCal Events due to callout limit reached please make sure there are less than 50 event Ids.');
    //                 break;
    //             }
    //             Map<String, Object> returnPayload = gcalHandler.setGCalAttendees(gcalEvent, new Set<String>{});
    //             if((Boolean)returnPayload.get('success') == false){
    //                 rd.put('body', returnPayload.get('body'));
    //                 rd.addError((String)returnPayload.get('error'));                    
    //             }
    //         }
    //     } catch (Exception e){
    //         rd.addError(e);
    //     }

    //     return rd.getJSONString();
    // }

    @AuraEnabled
    public static string massUpdateAttendees(String jsonString) {
        responseData rd = new responseData();
        try {
            UpdateAttendeesPayload payload = (UpdateAttendeesPayload) JSON.deserialize(jsonString, UpdateAttendeesPayload.class);

            String searchTerm = String.escapeSingleQuotes(payload.searchTerm);
            Id recordId = (Id) payload.recordId;
            String lastId = '';
            Boolean hasMore = false;
            String wildSearchTerm = '%' + searchTerm + '%';
            List<Assigned_Session__c> attendees = new List<Assigned_Session__c>();

            if (payload.selectAllAttendees) {
                String soqlQuery = 'SELECT Id, Self_Registered__c, Status__c, Registration_Date_Time__c, Registration_Type__c' +
                                   ' FROM Assigned_Session__c';
    
                soqlQuery += generateAttendeesByFilterWhereClause(payload.recordId, String.escapeSingleQuotes(payload.statusFilter), searchTerm, String.escapeSingleQuotes(payload.lastProcessedId));
                soqlQuery += ' ORDER BY Id ASC LIMIT 20';

                attendees = Database.query(soqlQuery);
            } else {                
                attendees = [SELECT Id, Self_Registered__c, Status__c, Registration_Date_Time__c,
                                    Registration_Type__c
                             FROM Assigned_Session__c
                             WHERE Session__c = :payload.recordId
                             AND Learner_Profile__c IN :payload.idsToProcess
                             WITH USER_MODE];
            }
            // Set<String> gcalEventsToUpdate = new Set<String>();
            List<Map<String, Object>> newAttendees = new List<Map<String,Object>>();

            for (Assigned_Session__c attendee : attendees) {
                // if(status == 'Absent') {
                //     gcalEventsToUpdate.add(attendee.GCal_Event__c);
                //     attendee.GCal_Event__c = null;
                // }

                // if(status == 'Canceled') {
                //     gcalEventsToUpdate.add(attendee.GCal_Event__c);
                // }

                // Update Status
                if (String.isNotEmpty(payload.status)) {
                    if (payload.status == 'Registered') {
                        attendee.Self_Registered__c = false;
                        attendee.Registration_Date_Time__c = System.now();
    
                        if (attendee.Status__c != 'Registered') {
                            attendee.Send_Registration_Email__c = true;
                        }
                    }
    
                    attendee.Status__c = payload.status;
                }

                // Update Registration Type
                if (String.isNotEmpty(payload.registrationType)) {
                    attendee.Registration_Type__c = payload.registrationType;
                }
            }

            update as user attendees;

            if (attendees.size() >= 10) {
                hasMore = true;
            }

            if (!attendees.isEmpty()) {
                lastId = attendees.get(attendees.size() - 1).Id;
            }

            rd.put('hasMore', hasMore);
            rd.put('lastProcessedId', lastId);
            // rd.put('gcalEventsToUpdate', gcalEventsToUpdate);
        } catch(Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static string massRemoveAttendees(String jsonString) {
        responseData rd = new responseData();
        try {
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

            Boolean selectAllAttendees = (Boolean) params.get('selectAllAttendees');
            Id recordId = (Id) params.get('recordId');
            String statusFilter = String.escapeSingleQuotes((String) params.get('statusFilter'));
            String searchTerm = String.escapeSingleQuotes((String) params.get('searchTerm'));
            String lastProcessedId = String.escapeSingleQuotes((String) params.get('lastProcessedId'));
            String lastId = '';
            Boolean hasMore = false;
            String wildSearchTerm = '%' + searchTerm + '%';
            List<Assigned_Session__c> attendees;

            if (selectAllAttendees){
                String soqlQuery = 'SELECT Id, Self_Registered__c, Status__c, Learner_Profile__r.User__r.Name, Learner_Profile__r.User__r.Email, Registration_Date_Time__c' +
                                   ' FROM Assigned_Session__c';
    
                soqlQuery += generateAttendeesByFilterWhereClause(recordId, statusFilter, searchTerm, lastProcessedId);
                soqlQuery += ' AND Status__c != \'Unregistered\'';
                soqlQuery += ' ORDER BY Id ASC LIMIT 20';
                attendees = Database.query(soqlQuery);
            } else {
                List<String> idsToProcess = (List<String>) JSON.deserialize((String) JSON.serialize(params.get('idsToProcess')), List<String>.class);
                
                attendees = [SELECT Id, Self_Registered__c, Status__c, Learner_Profile__r.User__r.Name, Learner_Profile__r.User__r.Email, Registration_Date_Time__c
                             FROM Assigned_Session__c
                             WHERE Session__c =: recordId
                             AND Learner_Profile__c =: idsToProcess
                             AND Status__c != 'Unregistered'
                             WITH USER_MODE];
            }

            for (Assigned_Session__c attendee : attendees) {
                attendee.Status__c = 'Unregistered';
            }

            update attendees;

            if (attendees.size() >= 10){
                hasMore = true;
            }

            if (!attendees.isEmpty()){
                lastId = attendees.get(attendees.size() - 1).Id;
            }

            rd.put('hasMore', hasMore);
            rd.put('lastProcessedId', lastId);
        } catch(Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    /**
     * Remove Guest Roles from a Session, except if their role is the Host
     */
    @AuraEnabled
    public static ResponseData removeGuestRoles(GuestPayload payload){
        ResponseData rd = new ResponseData();
        try {
            String sObjectType = payload.recordId.getSObjectType() + '';

            if (sObjectType != Session__c.getSObjectType() + '') {
                throw new AttendeesException('Getting Guests from Invalid SObject Record Page: ' + sObjectType);
            }

            List<Id> selectedIds = payload.idsToProcess;

            String query = 'SELECT Id FROM Session_Guest__c WHERE Session__c = \'' + payload.recordId + '\'  AND Role__c != \'Host\'';

            if (!payload.selectAll) {
                query += ' AND Id IN :selectedIds';
            }

            List<Session_Guest__c> guestRolesToDelete = Database.query(query, System.AccessLevel.USER_MODE);

            rd.put('onlyHost', guestRolesToDelete.isEmpty());

            delete guestRolesToDelete;
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    /**
     * Update Guest Roles from a Session
     */
    @AuraEnabled
    public static ResponseData updateGuestRoles(GuestPayload payload){
        ResponseData rd = new ResponseData();
        try {
            String sObjectType = payload.recordId.getSObjectType() + '';

            if (sObjectType != Session__c.getSObjectType() + '') {
                throw new AttendeesException('Getting Guests from Invalid SObject Record Page: ' + sObjectType);
            }

            List<Id> selectedIds = payload.idsToProcess;

            String query = 'SELECT Id FROM Session_Guest__c WHERE Session__c = \'' + payload.recordId + '\'';

            if (!payload.selectAll) {
                query += ' AND Id IN :selectedIds';
            }
            
            List<Session_Guest__c> guestRolesToUpdate = Database.query(query, System.AccessLevel.USER_MODE);

            for (Session_Guest__c guestRole : guestRolesToUpdate) {
                guestRole.Role__c = payload.statusFilter;
            }

            update guestRolesToUpdate;
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static String searchForGuestLearners(String searchTerm, String sessionId){
        ResponseData rd = new ResponseData();
        
        try {
            String wildSearchTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';

            List<Learner_Profile__c> lps = [SELECT Id, Name, Primary_Email__c, User__r.SmallPhotoUrl
                                            FROM Learner_Profile__c
                                            WHERE Name LIKE :wildSearchTerm
                                            AND Status__c = 'Active'
                                            AND Id NOT IN (SELECT Learner_Profile__c 
                                                           FROM Session_Guest__c 
                                                           WHERE Session__c =: sessionId)
                                            WITH USER_MODE
                                            ORDER BY Name ASC
                                            LIMIT 5];

            rd.put('foundLearnerProfiles', lps);
            rd.put('searchTerm', searchTerm);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd.getJsonString();
    }

    @AuraEnabled
    public static ResponseData reassignZoomHost(String sessionId, String oldHostEmail, String newHostEmail){
        ResponseData rd = new ResponseData();
        
        try {
            Session__c session = [SELECT Id, Zoom_Session_Id__c, Zoom_Type__c
                                  FROM Session__c
                                  WHERE Id =: sessionId
                                  WITH USER_MODE];

            String accessToken = utilities.getZoomAccessToken();

            if(!Test.isRunningTest() && String.isEmpty(accessToken)){
                rd.addError('Failed to authenticate to Zoom');
                return rd;
            }

            Map<String, String> headers = new Map<String, String>{
                'Authorization' => 'Bearer ' + accessToken
            };

            Boolean addedAssistant = SessionManager.assignAssistant(headers, newHostEmail, oldHostEmail, rd);

            if(!addedAssistant){
                return rd;
            }

            String method = 'PATCH';
            String url = session.Zoom_Type__c == 'Meeting' ? constants.ZOOM_BASE_URL + '/meetings' : constants.ZOOM_BASE_URL + '/webinars';
            url += '/' + session.Zoom_Session_Id__c;

            Map<String, Object> body = new Map<String, Object>{
                'schedule_for' =>  newHostEmail
            };

            HttpResponse res = utilities.makeCallout(url, method, JSON.serialize(body), headers);

            if(res.getStatusCode() != 201 && res.getStatusCode() != 204){
                try{
                    Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

                    rd.put('resBody', resBody);
                    rd.addError('Failed to reassign Zoom session: ' + resBody.get('message'));
                } catch(Exception e){
                    rd.put('resBody', res.getBody());
                    rd.addError('Failed to reassign Zoom session');
                }
            }
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData updateZoomSession(String sessionId){
        ResponseData rd = new ResponseData();
        
        try {
            Session__c session = [SELECT Id, Name, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c, Time_Zone__c, Description__c,  
                                         Zoom_Session_Id__c, Zoom_Type__c, Asset__c, Asset__r.Name
                                  FROM Session__c
                                  WHERE Id =: sessionId
                                  WITH USER_MODE];

            SessionManager.createZoomSession(session, rd);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData searchForLearners(String assetId, String sessionId, String searchTerm){
        ResponseData rd = new ResponseData();
        
        try {
            String wildSearchTerm = '%' + searchTerm + '%';

            List<Learner_Profile__c> lps = new List<Learner_Profile__c>();

            String soqlQuery = 'SELECT Id, Name, Primary_Email__c, User__r.SmallPhotoUrl' +
                               ' FROM Learner_Profile__c' +
                               ' WHERE Name LIKE :wildSearchTerm AND Status__c = \'Active\'';

            if(sessionId != null){
                soqlQuery += ' AND Id NOT IN (' +
                                   ' SELECT Learner_Profile__c' +
                                   ' FROM Assigned_Session__c' +
                                   ' WHERE Session__c =: sessionId' +
                              ')';
            }

            soqlQuery += ' WITH USER_MODE' +
                         ' ORDER BY Name ASC' +
                         ' LIMIT 5';
            // lps = [SELECT Id, Name, Primary_Email__c, User__r.SmallPhotoUrl
            //        FROM Learner_Profile__c
            //        WHERE Name LIKE :wildSearchTerm
            //        AND Id NOT IN (
            //                        SELECT Learner_Profile__c 
            //                        FROM Assigned_Session__c
            //                        WHERE Session__c =: sessionId
            //                      )
            //        WITH USER_MODE
            //        ORDER BY Name ASC
            //        LIMIT 5];

            lps = Database.query(soqlQuery);

            rd.put('lps', lps);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled(cacheable=true)
    public static ResponseData exportGuests(String recordId, String statusFilter, String searchTerm) {
        responseData rd = new responseData();

        try {
            String wildSearchTerm = '%' + searchTerm + '%';

            Set<String> fields = new Set<String>{'Id', 'Learner_Profile__r.Name', 'Learner_Profile__r.Primary_Email__c', 'Learner_Profile__r.Manager__c', 'Learner_Profile__r.Manager_Email__c', 'Status__c', 'GCal_Response__c', 
                                                 'Learner_Profile__r.User__r.Manager.Name', 'Learner_Profile__r.User__r.Manager.Email',
                                                 'Learner_Profile__r.Employee_Region__c', 'Learner_Profile__r.Selling_Role__c', 'Learner_Profile__r.Job_Family__c', 'Registration_Type__c'};

            String soqlQuery = 'SELECT ' + String.join(new List<String>(fields), ', ') +
                               ' FROM Assigned_Session__c' +
                               ' WHERE Session__c = :recordId';
                               

            if (String.isNotEmpty(statusFilter) && statusFilter != 'All'){
                soqlQuery += ' AND Status__c = :statusFilter';
            }

            if (String.isNotEmpty(searchTerm)){
                soqlQuery += ' AND Learner_Profile__r.Name LIKE :wildSearchTerm';
            }

            soqlQuery += ' WITH USER_MODE' +
                         ' ORDER BY Learner_Profile__r.User__r.Name';

            String csvData = '';

            for(Assigned_Session__c guest : Database.query(soqlQuery)){
                String newRow = '\r\n{0},{1},{2},{3},{4},{5},{6},{7},{8}';
                Learner_Profile__c lp = guest.Learner_Profile__r;

                List<Object> rowData = new List<Object>{
                    guest.Learner_Profile__r.Name, 
                    guest.Learner_Profile__r.Primary_Email__c, 
                    guest.Status__c,
                    String.isNotEmpty(guest.Learner_Profile__r.Manager__c) ? guest.Learner_Profile__r.Manager__c : '', 
                    String.isNotEmpty(guest.Learner_Profile__r.Manager_Email__c) ? guest.Learner_Profile__r.Manager_Email__c : '', 
                    String.isNotEmpty(guest.Learner_Profile__r.Employee_Region__c) ? guest.Learner_Profile__r.Employee_Region__c : '', 
                    String.isNotEmpty(guest.Learner_Profile__r.Selling_Role__c) ? guest.Learner_Profile__r.Selling_Role__c : '', 
                    String.isNotEmpty(guest.Learner_Profile__r.Job_Family__c) ? guest.Learner_Profile__r.Job_Family__c : '',
                    String.isNotEmpty(guest.Registration_Type__c) ? guest.Registration_Type__c : ''
                };

                newRow = String.format(newRow, rowData);
                csvData += newRow;
            }

            rd.put('csvData', csvData);
        } catch(Exception e){
            rd.addError(e);
        }

        return rd;
    }

    private static String generateAttendeesByFilterWhereClause(String recordId, String statusFilter, String searchTerm, String lastProcessedId){
        String whereClause = ' WHERE Session__c =: recordId';

        if(String.isNotEmpty(statusFilter) && statusFilter != 'All'){
            whereClause += ' AND Status__c = :statusFilter';
        }

        if(String.isNotEmpty(searchTerm)){
            whereClause += ' AND Learner_Profile__r.Name LIKE :wildSearchTerm';
        }

        if(String.isNotEmpty(lastProcessedId)){
            whereClause += ' AND Id > :lastProcessedId';
        }

        return whereClause;
    }

    @AuraEnabled
    public static ResponseData checkZoomUserForLicense(String email, String zoomType, String role){
        ResponseData rd = new ResponseData();

        try {
            Boolean needsLicense = false;
            String endPoint = constants.ZOOM_BASE_URL + '/users/' + email;
            String method = 'GET';
            String accessToken = utilities.getZoomAccessToken();

            Map<String, String> headers = new Map<String, String>{
                'Authorization' => 'Bearer ' + accessToken
            };
            
            if(zoomType == 'Webinar' && role == 'Host'){
                endPoint += '/settings';
            }

            HttpResponse res = utilities.makeCallout(endPoint, method, null, headers);
            
            if(res.getStatusCode() != 200){
                Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                String errMsg = (String)resBody.get('message');
                
                rd.addError(errMsg);
            } else {
                Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                if(zoomType == 'Webinar' && role == 'Host'){
                    Map<String, Object> feature = (Map<String, Object>)resBody.get('feature');
                    needsLicense = (Boolean)feature.get('webinar') == false;

                    if(needsLicense){
                        rd.put('errMsg', 'Webinar plan is missing. You must subscribe to the webinar plan and enable webinars for this user in order to perform this action.');
                    }

                } else {
                    needsLicense = (Integer)resBody.get('type') != 2;

                    if(needsLicense){
                        rd.put('errMsg', 'Unable to assign ' + email + ' because this user is not licensed');
                    }
                }
            }

            rd.put('needsLicense', needsLicense);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public class ProcessAttendeesPayload {
        public List<LpToProcess> lps { get; set; }
        public String sessionId { get; set; }
        public String assetId { get; set; }
        public String eventStatusValue { get; set; }
        public String cdo { get; set; }
        public String enablementProgram { get; set; }
        public String ouLeader {get; set;}
    }

    public class LpToProcess {
        public String id { get; set; }
        public String registrationType { get; set; }
        public String status {get; set;}
    }

    public class UpdateAttendeesPayload {
        public Boolean selectAllAttendees { get; set; }
        public Id recordId { get; set; }
        public String lastProcessedId { get; set; }
        public String emailToSend { get; set; }
        public String statusFilter { get; set; }
        public String searchTerm { get; set; }
        public List<String> idsToProcess { get; set; }
        public String status { get; set; }
        public String registrationType  { get; set; }
    }

    public class GuestPayload extends Utilities.DataTablePayload {
       @AuraEnabled
       public String statusFilter { get; set; }
    }

    public class AttendeesException extends Exception {}
}