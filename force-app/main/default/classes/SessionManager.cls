public with sharing class SessionManager {
    public static final Integer ZOOM_SESSION_LIMIT = 1000;
    public static Boolean createdHost = false;
    public static Boolean isSessionManagerPage = false;
    private static Integer pageSize = 20; //we're not paginating for now. Just load all the seesions

    // //Init page load of sessions
    @AuraEnabled
    public static String getData(String learningAssetId, List<String> selectedStatus, List<String> selectedRegion, List<String> selectedSessionType, List<String> selectedOfficeLocationCities){
        ResponseData rd = new ResponseData();

        try {
            isSessionManagerPage = true;
            Asset__c eventAsset = [SELECT Id, Status__c, Event_Type__c, Allowed_Editor__c
                                   FROM Asset__c
                                   WHERE Id =: learningAssetId
                                   WITH USER_MODE];

            Boolean hasAssignLearning = FeatureManagement.checkPermission('Assign_Learning');
            getSessions(rd, learningAssetId, '', selectedStatus, selectedRegion, selectedSessionType, selectedOfficeLocationCities, '', true);
            rd.put('event', eventAsset);
            rd.put('hasAssignLearning', hasAssignLearning);
        } catch(Exception e){ 
            rd.addError(e);
        }
        return rd.getJsonString();
    }

    // Get Sessions in a load more call
    @AuraEnabled
    public static String getSessions(String learningAssetId, String searchTerm, List<String> statusFilter, List<String> selectedRegion, List<String> selectedSessionType, List<String> selectedOfficeLocationCities, String startDate){
        ResponseData rd = new ResponseData();

        try {
            isSessionManagerPage = true;
            getSessions(rd, learningAssetId, searchTerm, statusFilter, selectedRegion, selectedSessionType, selectedOfficeLocationCities, startDate, false);
        } catch(Exception e){
            rd.addError(e);
        }
        return rd.getJsonString();
    }

    public static void getSessions(ResponseData rd, String learningAssetId, String searchTerm, List<String> statusFilter, List<String> selectedRegion, List<String> selectedSessionType, List<String> selectedOfficeLocationCities, String startDate, Boolean isOnLoad){
        Integer totalSessions = [SELECT COUNT() FROM Session__c WHERE Asset__c =: learningAssetId];
        List<sessionListItem> sessionListItems = getFormattedSessions(learningAssetId, searchTerm, statusFilter, selectedRegion, selectedSessionType, selectedOfficeLocationCities, startDate);
        sessionListItems.addAll(getFormattedGroups(learningAssetId, searchTerm, statusFilter, selectedRegion, selectedSessionType, selectedOfficeLocationCities, startDate));

        if (isOnLoad) {
            populateOfficeLocationPicklist(sessionListItems, rd);
        }

        rd.put('sessionListItems', sessionListItems);
        rd.put('hasMore', sessionListItems.size() >= pageSize);
        rd.put('totalSessions', totalSessions);
    }

    @AuraEnabled
    public static ResponseData getSession(String sessionId){
        ResponseData rd = new ResponseData();
        
        try {
            Session__c session = [SELECT Id, Name, Session_Type__c, Physical_Capacity__c, Virtual_Capacity__c, Status__c, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c, Time_Zone__c, 
                                         Url__c, Zoom_Type__c, Zoom_Session_Id__c, Zoom_Occurrence_Id__c, Virtual_Type__c, Asset__c, Asset__r.Name,
                                         (
                                            SELECT Id, Role__c, Session_Role_Status__c, Learner_Profile__c, Learner_Profile__r.Name
                                            FROM Session_Guests__r
                                         )
                                  FROM Session__c
                                  WHERE Id =: sessionId
                                  WITH USER_MODE];

            rd.put('session', session);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public static List<sessionListItem> getFormattedGroups(String assetId, String searchTerm, List<String> statusFilter, List<String> selectedRegion, List<String> selectedSessionType, List<String> selectedOfficeLocationCities, String startDate){

        if (statusFilter.contains('All')) {
            statusFilter = getAllSessionStatusValues();
        }

        if (selectedRegion.contains('All')) {
            selectedRegion = getAllSessionRegionValues();
        }

        if (selectedSessionType.contains('All')) {
            selectedSessionType = getAllSessionTypeValues();
        }

        return getFormattedGroups(assetId, true, searchTerm, new List<Session__c>(), statusFilter, selectedRegion, selectedSessionType, selectedOfficeLocationCities, startDate);
    }

    public static List<sessionListItem> getFormattedGroups(String assetId, Boolean isAdmin, List<Session__c> registeredSessions, List<String> allowedStatuses){
        List<String> allFilter = new List<String>{'All'};
        List<String> selectedRegion = getAllSessionRegionValues();
        List<String> selectedSessionType = getAllSessionTypeValues();

        return getFormattedGroups(assetId, isAdmin, '', registeredSessions, allowedStatuses, selectedRegion, selectedSessionType, allFilter, '');
    }

    public static List<sessionListItem> getFormattedGroups(String assetId, Boolean isAdmin, String searchTerm, List<Session__c> registeredSessions, List<String> allowedStatuses, List<String> selectedRegion, List<String> selectedSessionType, List<String> selectedOfficeLocationCities, String startDate){
        List<sessionListItem> formattedGroups = new List<sessionListItem>();
        Set<String> groupFields = new Set<String>{'Id', 'Name', 'Start_Date__c', 'End_Date__c', 'Asset__c', 'Asset__r.Share_Url__c', 'Share_Url__c'};
        Set<String> sessionFields = getSessionFields();
        Date startDateParam = String.isNotEmpty(startDate) ? Date.valueOf(startDate) : null;
        Date startOfFebruary = Date.newInstance(Date.today().year(), 2, 1);


        String childSoqlQuery = 'SELECT ' + String.join(new List<String>(sessionFields), ', ') +  
                                ' ,(SELECT Id, Role__c, Session_Role_Status__c, Learner_Profile__c, Learner_Profile__r.Name FROM Session_Guests__r)' +
                                ' FROM Sessions__r';

        String childWhereClause = ' WHERE Start_Date__c >=: startOfFebruary AND Status__c =: allowedStatuses AND Region__c =: selectedRegion AND Session_Type__c =: selectedSessionType';

        if (!selectedOfficeLocationCities.contains('All')) {
            // using new-location field
            // childWhereClause += ' AND Office_Location__r.City__c IN :selectedOfficeLocationCities';
            childWhereClause += ' AND Location__City__s IN :selectedOfficeLocationCities';
        }

        if(!isAdmin){
            childWhereClause += ' AND Start_Date__c >= TODAY AND Id NOT IN :registeredSessions';
        } else if(startDateParam != null){
            childWhereClause += ' AND Start_Date__c =: startDateParam';
        }

        // if(String.isNotEmpty(searchTerm)){
        //     childWhereClause += ' AND Name LIKE \'%' + searchTerm + '%\'';
        // }

        childSoqlQuery += childWhereClause;
        childSoqlQuery += ' ORDER BY Start_Date__c ASC, Start_Time__c ASC';

        String soqlQuery = 'SELECT ' + String.join(new List<String>(groupFields), ', ') + ', (' + childSoqlQuery + ')' +
                           ' FROM Session_Group__c';

        String whereClause = ' WHERE Asset__c =: assetId';

        if(!isAdmin){
            whereClause += ' AND End_Date__c >= TODAY';
        }

        if(String.isNotEmpty(searchTerm)){
            whereClause += ' AND Name LIKE \'%' + searchTerm + '%\'';
        }

        soqlQuery += whereClause;
        soqlQuery += ' WITH USER_MODE ' + 
                     ' ORDER BY Start_Date__c ASC';

        /*
            SELECT fields
                (
                    SELECT fields
                        (SELECT Id FROM Session_Guests__r WHERE Role__c = \'Host\' AND Session_Role_Status__c = \'Approved\')'
                    FROM Sessions__r
                    WHERE Start_Date__c >= TODAY (added conditionally)
                    AND Id NOT IN :registeredSessions (added conditionally)
                    AND Status__c =: allowedStatuses
                    ORDER BY Start_Date__c ASC, Start_Time__c ASC
                )
            FROM Session_Group__c
            WHERE Asset__c =: assetId
            AND End_Date__c >= TODAY (added conditionally)
            WITH USER_MODE
            ORDER BY Start_Date__c ASC
        */
        List<Session_Group__c> sessionGroups = Database.query(soqlQuery);
        
        for(Session_Group__c sessionGroup : sessionGroups){
            if(sessionGroup.Sessions__r.isEmpty()){
                continue;
            }

            formattedGroups.add(new sessionListItem(sessionGroup));
        }
        
        return formattedGroups;
    }

    public static List<sessionListItem> getFormattedSessions(String assetId, String searchTerm, List<String> statusFilter, List<String> selectedRegion, List<String> selectedSessionType, List<String> selectedOfficeLocationCities, String startDate){
        if (statusFilter.contains('All')) {
            statusFilter = getAllSessionStatusValues();
        }

        if (selectedRegion.contains('All')) {
            selectedRegion = getAllSessionRegionValues();
        }

        if (selectedSessionType.contains('All')) {
            selectedSessionType = getAllSessionTypeValues();
        }

        return getFormattedSessions(assetId, true, searchTerm, new List<Session__c>(), statusFilter, selectedRegion, selectedSessionType, selectedOfficeLocationCities, startDate);
    }

    public static List<sessionListItem> getFormattedSessions(String assetId, Boolean isAdmin, List<Session__c> registeredSessions, List<String> allowedStatuses){
        List<String> allFilter = new List<String>{'All'};
        List<String> selectedRegion = getAllSessionRegionValues();
        List<String> selectedSessionType = getAllSessionTypeValues();

        return getFormattedSessions(assetId, isAdmin, '', registeredSessions, allowedStatuses, selectedRegion, selectedSessionType, allFilter, '');
    }

    public static List<sessionListItem> getFormattedSessions(String assetId, Boolean isAdmin, String searchTerm, List<Session__c> registeredSessions, List<String> allowedStatuses, List<String> selectedRegion, List<String> selectedSessionType, List<String> selectedOfficeLocationCities, String startDate){
        List<sessionListItem> formattedSessions = new List<sessionListItem>();
        Set<String> sessionFields = getSessionFields();
        Date startDateParam = String.isNotEmpty(startDate) ? Date.valueOf(startDate) : null;
        Date startOfFebruary = Date.newInstance(Date.today().year(), 2, 1);

        String soqlQuery = 'SELECT ' + String.join(new List<String>(sessionFields), ', ') +
                           ' ,(SELECT Id, Role__c, Session_Role_Status__c, Learner_Profile__c, Learner_Profile__r.Name FROM Session_Guests__r LIMIT 2000) ' +
                           ' FROM Session__c';

        String whereClause = ' WHERE Asset__c =: assetId AND Session_Group__c = null AND Status__c =: allowedStatuses AND Region__c =: selectedRegion AND Session_Type__c =: selectedSessionType AND Start_Date__c >=: startOfFebruary';

        if (!selectedOfficeLocationCities.contains('All')) {
            // new-location field
            // whereClause += ' AND Office_Location__r.City__c IN :selectedOfficeLocationCities';
            whereClause += ' AND Location__City__s IN :selectedOfficeLocationCities';
        }

        if(!isAdmin){
            whereClause += ' AND Start_Date__c >= TODAY AND Id NOT IN :registeredSessions';
        } else if(startDateParam != null){
            whereClause += ' AND Start_Date__c =: startDateParam';
        }

        if(String.isNotEmpty(searchTerm)){
            whereClause += ' AND Name LIKE \'%' + searchTerm + '%\'';
        }

        soqlQuery += whereClause;
        soqlQuery += ' WITH USER_MODE ' + 
                     ' ORDER BY Start_Date__c ASC, Start_Time__c ASC';

        /*
            SELECT fields 
                (SELECT Id FROM Session_Guests__r WHERE Role__c = \'Host\' AND Session_Role_Status__c = \'Approved\')'
            FROM Session__c
            WHERE Asset__c =: assetId
            AND Session_Group__c = null
            AND Start_Date__c >= TODAY (added conditionally)
            AND Id NOT IN :registeredSessions (added conditionally)
            AND Status__c =: allowedStatuses
            WITH USER_MODE
            ORDER BY Start_Date__c ASC, Start_Time__c ASC
        */

        for(Session__c session : Database.query(soqlQuery)){
            formattedSessions.add(new sessionListItem(session));
        }
        
        return formattedSessions;
    }

    public static Set<String> getSessionFields(){
        Set<String> sessionFields = new Set<String>{'Id', 'Name', 'Description__c', 'Objective__c', 'Session_Type__c', 'Physical_Capacity__c', 'Virtual_Capacity__c', 'Total_Capacity__c', 'Physical_Registered_Guests__c', 'Virtual_Registered_Guests__c','Registered_Guests__c', 
                                                    'Start_Date__c', 'Start_Time__c', 'End_Date__c', 'End_Time__c', 'Time_Zone__c','Learner_Instructions__c',
                                                    'Start_Time_Converted__c', 'End_Time_Converted__c', 'Owner.Name', 'Address__c', 
                                                    'City__c', 'Country__c', 'Zip_Code__c', 'Url__c', 'Zoom_Session_Id__c', 'Zoom_Occurrence_Id__c', 
                                                    'Virtual_Type__c', 'Asset__r.Name', 'Status__c', 'Office_Location__r.Name', 'Office_Location__r.Address__c', 'Office_Location__r.City__c', 'Office_Location__r.Country__c', 'Office_Location__r.Postal_Code__c', 'Region__c', 'Room__c', 'Floor__c', 'Zoom_Type__c',
                                                    'Share_Url__c', 'Location__c', 'Minimum_Staff__c'};

        return sessionFields;
    }

    private static List<String> getAllSessionStatusValues(){
        List<Schema.PicklistEntry> ples = Session__c.Status__c.getDescribe().getPicklistValues();
        List<String> sessionStatusVals = new List<String>();

        for( Schema.PicklistEntry f : ples) {
            sessionStatusVals.add(f.value);
        }

        return sessionStatusVals;
    }

    private static List<String> getAllSessionRegionValues() {
        List<Schema.PicklistEntry> ples = Session__c.Region__c.getDescribe().getPicklistValues();
        List<String> sessionRegionVals = new List<String>();

        for( Schema.PicklistEntry f : ples) {
            sessionRegionVals.add(f.value);
        }

        return sessionRegionVals;
    }

    private static List<String> getAllSessionTypeValues() {
        List<Schema.PicklistEntry> ples = Session__c.Session_Type__c.getDescribe().getPicklistValues();
        List<String> sessionTypeVals = new List<String>();

        for( Schema.PicklistEntry f : ples) {
            sessionTypeVals.add(f.value);
        }

        return sessionTypeVals;
    }

    @AuraEnabled
    public static String getPicklistValues(){
        ResponseData rd = new ResponseData();

        try {
            List<Map<String, String>> sessionTypes = Utilities.getPicklistVals(Session__c.Session_Type__c.getDescribe());
            List<Map<String, String>> statusTypes = Utilities.getPicklistVals(Session__c.Status__c.getDescribe());
            List<Map<String, String>> zoomTypes = Utilities.getPicklistVals(Session__c.Zoom_Type__c.getDescribe());
            List<Map<String, String>> timezones = Utilities.getPicklistVals(Session__c.Time_Zone__c.getDescribe());
            List<Map<String, String>> regions = Utilities.getPicklistVals(Session__c.Region__c.getDescribe());

            rd.put('sessionTypes', sessionTypes);
            rd.put('statusTypes', statusTypes);
            rd.put('zoomTypes', zoomTypes);
            rd.put('timezones', timezones);
            rd.put('regions', regions);
        } catch(Exception e){
            rd.addError(e);
        }
        return rd.getJsonString();
    }

    // @AuraEnabled
    // public static ResponseData ensureHostRoleExists(String sessionId){
    //     ResponseData rd = new ResponseData();
        
    //     try {
    //         rd.put('createdHost', false);

    //         List<Session_Guest__c> sessionGuests = [SELECT Id, Role__c 
    //                                                 FROM Session_Guest__c 
    //                                                 WHERE Session__c =: sessionId
    //                                                 AND Role__c = 'Host'
    //                                                 WITH USER_MODE];

    //         if(sessionGuests.isEmpty()){
    //             Learner_Profile__c lp = [SELECT Id, Name FROM Learner_Profile__c WHERE User__c =: UserInfo.getUserId()];
    //             insert new Session_Guest__c(Name = lp.Name, Learner_Profile__c = lp.Id, Role__c = 'Host', Session__c = sessionId, Send_Registration_Email__c = true);
    //             rd.put('createdHost', true);
    //         }
    //     } catch (Exception e) {
    //         rd.addError(e);
    //     }
    
    //     return rd;
    // }

    @AuraEnabled
    public static String upsertSession(String jsonString){
        ResponseData rd = new ResponseData();

        try {
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Map<String, Object> sessionMap = (Map<String, Object>)params.get('session');
            Boolean isNewGroup = params.containsKey('isNewGroup') ? (Boolean)params.get('isNewGroup') : false;
            Boolean isClonedSession = params.containsKey('isClonedSession') ? (Boolean)params.get('isClonedSession') : false;
            // remove location compound field and fill each location field separately
            Map<String, Object> location = (Map<String, Object>)sessionMap.remove('Location__c');
            //need to pass in another clone of session as we don't want to lose the supporting data in sessionMap
            Map<String, Object> sessionMapClone = (Map<String, Object>) params.get('session');
            sessionMapClone.remove('Total_Capacity__c'); // Remove read-only field
            Session__c session = (Session__c)Utilities.getSobjectByMap(sessionMapClone, 'Session__c');
            Boolean isNew = session.Id == null;
            Boolean isVirtualOnlySave = params.containsKey('isVirtualOnlySave') ? (Boolean)params.get('isVirtualOnlySave') : false;


            if(location != null) {
                session.Location__City__s = (String)location.get('city');
                String countryCode = getCountryCode((String)location.get('country'));
                String stateCode = (String)location.get('stateCode');
                Integer sLength = String.isNotEmpty((String)location.get('state')) ? ((String)location.get('state')).length() : 0;
                session.Location__CountryCode__s = String.isNotEmpty(countryCode) ? countryCode : '';
                session.Location__StateCode__s = sLength == 2 ? (String)location.get('state') : stateCode;
                session.Location__PostalCode__s = (String)location.get('postalCode');
                session.Location__Street__s = (String)location.get('street');                
            }
            if(isNew && isClonedSession) {
                // reset the zoom details if it got added while cloning, let user set it via 'Add Zoom' button
                session.Zoom_Host_Id__c = null;
                session.Zoom_Session_Id__c = null;
                session.Zoom_Type__c = null;
                session.Virtual_Type__c = 'None';
                session.Url__c = null;

                if(session.Session_Type__c == 'Virtual') {
                    session.Floor__c = '';
                    session.Room__c = '';
                    session.Physical_Capacity__c = null;
                } else if(session.Session_Type__c == 'Physical') {
                    session.Virtual_Capacity__c = null;
                }
                
                // if(session.Session_Type__c == 'Virtual') {
                //     session.Floor__c = '';
                //     session.Room__c = '';
                //     // reset the zoom session if it got added while cloning
                //     session.Zoom_Host_Id__c = null;
                //     session.Zoom_Session_Id__c = null;
                //     session.Zoom_Type__c = null;
                //     session.Zoom_Type__c = null;
                //     session.Url__c = null;
                // } else if (session.Session_Type__c == 'Physical') { 
                //     // reset the zoom session if it got added while cloning
                //     session.Zoom_Host_Id__c = null;
                //     session.Zoom_Session_Id__c = null;
                //     session.Zoom_Type__c = null;
                //     session.Url__c = null;
                //     session.Virtual_Type__c = null;
                // }
            }
            

            if(!isVirtualOnlySave){
                //SF will default to 0 if undefined, but null actually means infinite capacity 
                //so we need to explicitly set it
                if (String.isEmpty((String) sessionMap.get('Physical_Capacity__c'))) {
                    session.Physical_Capacity__c = null;
                }

                if (String.isEmpty((String) sessionMap.get('Virtual_Capacity__c'))) {
                    session.Virtual_Capacity__c = null;
                }

                //need to set the times manually as when casting it through the utility function
                //it alters the time as if its in the Users timezone
                List<String> startTimeParts = ((String)sessionMap.get('Start_Time__c')).split(':'); //hh:mm:ss.SSS
                List<String> endTimeParts = ((String)sessionMap.get('End_Time__c')).split(':');
                //we don't allow seconds so ignore them
                session.Start_Time__c = Time.newInstance(Integer.valueOf(startTimeParts.get(0)), Integer.valueOf(startTimeParts.get(1)), 0, 0);
                session.End_Time__c = Time.newInstance(Integer.valueOf(endTimeParts.get(0)), Integer.valueOf(endTimeParts.get(1)), 0, 0);
            }
            
            // List<Zoom_Host__c> deletedHosts = new List<Zoom_Host__c>();
            // List<Zoom_Host__c> newHosts = new List<Zoom_Host__c>();

            // //removed a zoom session from a existing physical location
            List<Session__c> oldSessions = [SELECT Id, Zoom_Session_Id__c, Zoom_Type__c, Virtual_Type__c FROM Session__c WHERE Id =: session.Id];

            if(session.Virtual_Type__c == 'Zoom'){
                String hostEmails = '';

                if(!oldSessions.isEmpty()){
                    Session__c oldSession = oldSessions.get(0);

                    if(oldSession.Zoom_Type__c != session.Zoom_Type__c && oldSession.Zoom_Session_Id__c != null){
                        deleteZoomSession(oldSession, rd);
                        session.Zoom_Session_Id__c = null;
                        session.Zoom_Occurrence_Id__c = null;
                    }
                }

                Boolean succeeded = createZoomSession(session, rd);
    
                if(!succeeded){
                    return rd.getJsonString();
                }
            }

            if(session.Virtual_Type__c != 'Zoom' && !isNew){
                if(!oldSessions.isEmpty()){
                    Session__c oldSession = oldSessions.get(0);

                    if(oldSession.Virtual_Type__c == 'Zoom'){
                        deleteZoomSession(oldSession, rd);
                    }
                }

                clearZoomDetails(session);
            }

            if(session.Virtual_Type__c == 'None'){
                clearZoomDetails(session);
                session.Url__c = null;
            } else if(session.Virtual_Type__c == 'Other'){
                clearZoomDetails(session);
            }

            if(isNewGroup){
                Session_Group__c sessionGroup = new Session_Group__c(
                    Start_Date__c = session.Start_Date__c,
                    End_Date__c = session.End_Date__c,
                    Asset__c = session.Asset__c
                );

                insert as user sessionGroup;

                session.Session_Group__c = sessionGroup.Id;
                rd.put('newGroup', sessionGroup);
            }

            upsert session;

            if(session.Virtual_Type__c == 'Zoom'){
                System.debug('************** createdHost ' + createdHost);
                if(isNew || createdHost){
                    Learner_Profile__c lp = [SELECT Id 
                                             FROM Learner_Profile__c 
                                             WHERE User__c =: UserInfo.getUserId()
                                             AND Status__c = 'Active'
                                             WITH USER_MODE
                                             LIMIT 1];

                    Session_Guest__c sessionGuestHost = new Session_Guest__c(
                        Role__c = 'Host',
                        Send_Registration_Email__c = true,
                        Learner_Profile__c = lp.Id,
                        Session__c = session.Id,
                        Session_Role_Status__c = 'Approved'
                    );
    
                    insert as user sessionGuestHost; 
                }

                // for(Zoom_Host__c host : newHosts){
                //     host.Session__c = session.Id;
                // }

                // if(!deletedHosts.isEmpty()){
                //     delete deletedHosts;
                // }

                // if(!newHosts.isEmpty()){
                //     insert Security.stripInaccessible(AccessType.CREATABLE, newHosts).getRecords();
                // }
            }

            rd.put('sessionId', session.Id);
        } catch(Exception e){
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    public static void clearZoomDetails(Session__c session){
        session.Zoom_Type__c = null;
        session.Zoom_Session_Id__c = null;
        session.Zoom_Occurrence_Id__c = null;
    }

    @AuraEnabled
    public static ResponseData deleteSession(List<String> sessionId){
        ResponseData rd = new ResponseData();

        try {
            List<Session__c> sessionToDelete = [SELECT Id, Virtual_Type__c, Zoom_Session_Id__c, Zoom_Type__c
                                          FROM Session__c
                                          WHERE Id IN: sessionId
                                          WITH USER_MODE];

            // This is handled in a trigger now.
            // if(sessionToDelete.Virtual_Type__c == 'Zoom'){
                //if it fails we stil want to delete the session. they'll just have to manually delete it on the front end
                // deleteZoomSession(sessionToDelete, rd);
            // }

            delete as user sessionToDelete;
        } catch(Exception e){
            rd.addError(e);
        }

        return rd;
    }

    public static Boolean hasPhysicalCapacity(Session__c session) {
        return session.Physical_Capacity__c != null && session.Physical_Capacity__c != 0;
    }

    public static Boolean hasVirtualCapacity(Session__c session) {
        return session.Virtual_Capacity__c != null && session.Virtual_Capacity__c != 0;
    }

    public static Boolean physicalCapacityReached(Session__c session) {
        if (session.Assigned_Sessions__r == null || session.Assigned_Sessions__r.isEmpty()) {
            return false;
        }

        return hasPhysicalCapacity(session) && session.Assigned_Sessions__r.size() >= session.Physical_Capacity__c;
    }

    public static Boolean virtualCapacityReached(Session__c session) {
        if (session.Assigned_Sessions__r == null || session.Assigned_Sessions__r.isEmpty()) {
            return false;
        }

        return hasVirtualCapacity(session) && session.Assigned_Sessions__r.size() >= session.Virtual_Capacity__c;
    }

    public static Boolean deleteZoomSession(Session__c session, ResponseData rd){
        Boolean success = true;
        String endPoint = Constants.ZOOM_BASE_URL + (session.Zoom_Type__c == 'Meeting' ? '/meetings' : '/webinars');
        endPoint += '/' + session.Zoom_Session_Id__c;

        Map<String, String> headers = new Map<String, String>{
            'Authorization' => 'Bearer ' + Utilities.getZoomAccessToken()
        };

        HttpResponse res = Utilities.makeCallout(endPoint, 'DELETE', headers);

        if(res.getStatusCode() != 200 && res.getStatusCode() != 204){
            rd.addError('Failed to delete session on Zoom. Please manually delete it in Zoom.');
            rd.put('res', res.getBody());
            success = false;
        }

        return success;
    }

    public static Boolean createZoomSession(Session__c session, ResponseData rd){
        return createZoomSession(session, rd, '');
    }

    public static Boolean createZoomSession(Session__c session, ResponseData rd, String accessToken){
        Boolean succeeded = false;
        
        if(String.isEmpty(accessToken)){
            accessToken = utilities.getZoomAccessToken();
        }
        String hostEmails = '';
        Asset__c event = [SELECT Id, Name
                          FROM Asset__c
                          WHERE Id =: session.Asset__c
                          WITH USER_MODE];

        if(!Test.isRunningTest() && String.isEmpty(accessToken)){
            rd.addError('Failed to authenticate to Zoom');
            return false;
        }

        Map<String, String> headers = new Map<String, String>{
            'Authorization' => 'Bearer ' + accessToken
        };

        //get the auth option id for our ACT domains
        String authOptionUrl = constants.ZOOM_BASE_URL + '/accounts/me/settings?option=meeting_authentication';
        HttpResponse authRes = utilities.makeCallout(authOptionUrl, 'GET', headers);
        
        if(authRes.getStatusCode() == 400){
            Map<String, Object> paresdAuthRes = (Map<String, Object>)JSON.deserializeUntyped(authRes.getBody());

            if((Integer)paresdAuthRes.get('code') != 200){
                rd.addError('Failed to get Zoom authorization options please contact your System Administrator.');
                rd.put('resBody', authRes.getBody());
                return false;    
            }

        } else if(authRes.getStatusCode() != 200){
            rd.addError('Failed to get Zoom authorization options please contact your System Administrator.');
            rd.put('resBody', authRes.getBody());
            return false;
        }

        Map<String, Object> paresdAuthRes = (Map<String, Object>)JSON.deserializeUntyped(authRes.getBody());
        List<Object> authOptions = (List<Object>)paresdAuthRes.get('authentication_options');
        String domainAuthId;
        if(authOptions != null){
            for(Object authOptionObj : authOptions){
                Map<String, Object> authOption = (Map<String, Object>)authOptionObj;
                
                if((String)authOption.get('name') == 'ACT Domains'){
                    domainAuthId = (String)authOption.get('id');
                }
            }
        }
        
        /* Parse times for duration */
        DateTime startTime = DateTime.newInstanceGMT(session.Start_Date__c, session.Start_Time__c);
        DateTime endTime = DateTime.newInstanceGMT(session.End_Date__c, session.End_Time__c);
        Long durationInMinutes = (endTime.getTime() - startTime.getTime()) / (1000 * 60);

        //Craft the zoom payload
        Map<String, Object> body = new Map<String, Object>{
            'topic' => session.Name, // Session_Name__c,
            'agenda' => session.Description__c,
            'type' => 2, //no registration
            'start_time' => startTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS'),
            'timezone' => session.Time_Zone__c == 'GMT' ? 'UTC' : session.Time_Zone__c,
            'duration' => durationInMinutes
        };

        Map<String, Object> settings = new Map<String, Object>{
            'waiting_room' => false,
            'meeting_authentication' => true,
            'authentication_option' => domainAuthId
        };

        Set<String> coHosts = new Set<String>();
        System.debug('************** ' + session.Id);
        if(session.Id != null){
            for(Session_Guest__c sg : [SELECT Id, Learner_Profile__r.Primary_Email__c 
                                       FROM Session_Guest__c
                                       WHERE Session__c =: session.Id
                                       AND Role__c =: 'Co-Host'
                                       AND Session_Role_Status__c = 'Approved'
                                       WITH USER_MODE]){
                coHosts.add(sg.Learner_Profile__r.Primary_Email__c);
            }
        }

        System.debug('************** coHosts ' + coHosts);
        
        if(!coHosts.isEmpty()){
            hostEmails = String.join(new List<String>(coHosts), ',');
            settings.put('alternative_hosts', hostEmails);
        } else {
            settings.put('alternative_hosts', '');
        }

        //calculate the breakout rooms
        /* if(session.Total_Breakout_Rooms__c != null && session.Total_Breakout_Rooms__c > 0){
            List<Map<String, Object>> rooms = new List<Map<String, Object>>();

            for(Integer i = 1; i <= session.Total_Breakout_Rooms__c; i++){
                rooms.add(new Map<String, Object>{
                    'name' => 'Breakout Room ' + i,
                    'participants' => new List<String>()
                });
            }

            Map<String, Object> breakoutRooms = new Map<String, Object> {
                'enable' => true,
                'rooms' => rooms
            };

            settings.put('breakout_room', breakoutRooms);
        } */

        body.put('settings', settings);

        //create the zoom session
        String url;
        String method;
        
        if(session.Zoom_Session_Id__c == null){
            method = 'POST';
            String email = '';
            
            if(session.Id != null){
                List<Session_Guest__c> hostGuests = [SELECT Id, Learner_Profile__r.Primary_Email__c 
                                                     FROM Session_Guest__c
                                                     WHERE Session__c =: session.Id
                                                     AND Role__c = 'Host'
                                                     AND Session_Role_Status__c = 'Approved'
                                                     WITH USER_MODE
                                                     LIMIT 1];
                if(!hostGuests.isEmpty()){
                    email = hostGuests.get(0).Learner_Profile__r.Primary_Email__c;
                }
            }

            if(String.isEmpty(email)){
                Learner_Profile__c hostLP = [SELECT Id, Primary_Email__c 
                                             FROM Learner_Profile__c 
                                             WHERE User__c =: UserInfo.getUserId()
                                             AND Status__c = 'Active'
                                             WITH USER_MODE
                                             LIMIT 1];
                email = hostLP.Primary_Email__c;
                createdHost = true;
            }

            url = constants.ZOOM_BASE_URL + '/users/' + email;
            url += session.Zoom_Type__c == 'Meeting' ? '/meetings' : '/webinars';
        } else {
            method = 'PATCH';
            url = session.Zoom_Type__c == 'Meeting' ? constants.ZOOM_BASE_URL + '/meetings' : constants.ZOOM_BASE_URL + '/webinars';
            url += '/' + session.Zoom_Session_Id__c;
        }

        HttpResponse res = utilities.makeCallout(url, method, JSON.serialize(body), headers);

        if(res.getStatusCode() == 201 || res.getStatusCode() == 204){
            if(method == 'POST'){
                Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                
                session.Zoom_Session_Id__c = String.valueOf(resBody.get('id'));
                session.Zoom_Occurrence_Id__c = (String)resBody.get('uuid');
                session.Url__c = (String)resBody.get('join_url');
            }

            succeeded = true;
        } else {
            try{
                Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

                rd.put('resBody', resBody);
                rd.addError('Failed to create Zoom session: ' + resBody.get('message'));
            } catch(Exception e){
                rd.put('resBody', res.getBody());
                rd.addError('Failed to create Zoom session');
            }
        }

        return succeeded;
    }

    public static Boolean assignAssistant(Map<String, String> headers, String userEmail, String assistantEmail, responseData rd){
        String endPoint = constants.ZOOM_BASE_URL + '/users/' + userEmail + '/assistants';
        String method = 'POST';
        Map<String, Object> body = new Map<String, Object>{
            'assistants' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'email' => assistantEmail
                }
            }
        };
        Boolean succeeded = false;

        HttpResponse res = utilities.makeCallout(endPoint, method, JSON.serialize(body), headers);
        if(res.getStatusCode() == 201 || res.getStatusCode() == 204){
            succeeded = true;
        } else {
            try{
                Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                System.debug('************** ' + resBody.get('code'));
                //we already added them as a assistant
                if((Integer)resBody.get('code') == 200){
                    succeeded = true;
                } else {
                    rd.put('resBody', resBody);
                    rd.addError('Failed to add assistant to transfer Zoom meeting: ' + resBody.get('message'));
                }
            } catch(Exception e){
                rd.put('resBody', res.getBody());
                rd.addError('Failed to add assistant to transfer Zoom meeting');
            }
        }


        return succeeded;
    }

    private static void populateOfficeLocationPicklist(List<sessionListItem> sessionListItems, ResponseData rd) {
        // use new-location field
        // Set<Map<String, Object>> officeLocationCities = new Set<Map<String, Object>>{};
        // officeLocationCities.add(new Map<String, Object>{
        //     'label' => 'All',
        //     'value' => 'All'
        // });
        
        // for (sessionListItem sli : sessionListItems) {
        //     Office_Location__c office = null;

        //     if (sli.isGroup) {
        //         for (Map<String, Object> session : sli.groupSessions) {
        //             office = (Office_Location__c)session.get('Office_Location__r');

        //             if (office != null) {
        //                 officeLocationCities.add(new Map<String, Object>{
        //                     'label' => office.City__c,
        //                     'value' => office.City__c
        //                 });
        //             }
        //         }
        //     } else {
        //         office = (Office_Location__c)sli.session.get('Office_Location__r');
                
        //         if (office != null) {
        //             officeLocationCities.add(new Map<String, Object>{
        //                 'label' => office.City__c,
        //                 'value' => office.City__c
        //             });
        //         }
        //     }
        // }

        // rd.put('officeLocationCities', officeLocationCities);
        
        Set<Map<String, Object>> officeLocationCities = new Set<Map<String, Object>>{};
        officeLocationCities.add(new Map<String, Object>{
            'label' => 'All',
            'value' => 'All'
        });

        for (sessionListItem sli : sessionListItems) {
            if (sli.isGroup) {
                for (Map<String, Object> session : sli.groupSessions) {
                    if(session.get('Location__c') != null) {
                        Map<String, Object> lm = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(session.get('Location__c')));
                        if(String.isNotBlank((String)lm.get('city'))) {
                            officeLocationCities.add(new Map<String, Object>{
                                'label' => (String)lm.get('city'),// String.isNotBlank((String)lm.get('city')) ? lm.get('city') : '',
                                'value' => (String)lm.get('city') // String.isNotBlank((String)lm.get('city')) ? lm.get('city') : ''
                            });
                        }                        
                    }                                        
                }
            } else {
                // office = (Office_Location__c)sli.session.get('Office_Location__r');
                // location = (Location__c)sli.session.get('Location__c');
                if (sli.session.get('Location__c') != null) {
                    Map<String, Object> lm = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(sli.session.get('Location__c')));
                    if(String.isNotBlank((String)lm.get('city'))) {
                        officeLocationCities.add(new Map<String, Object>{
                            'label' => (String)lm.get('city'),// String.isNotBlank((String)lm.get('city')) ? lm.get('city') : '',
                            'value' => (String)lm.get('city') // String.isNotBlank((String)lm.get('city')) ? lm.get('city') : ''
                        });
                    }
                }
            }
        }

        rd.put('officeLocationCities', officeLocationCities);
    }

    public static String getCountryCode(String countryName) {
        String countryCode='';
        String endPoint = Constants.HEROKU_ENDPOINT + '/countryCode';
        Map<String, String> headers = new Map<String, String> {
            'Authentication' => 'Bearer ' + Constants.HEROKU_API_KEY,
            'Content-Type' => 'application/json'
        };
        Map<String, String> message = new Map<String, String>{
            'countryName' => countryName
        };
        HttpResponse res = Utilities.makeCallout(endPoint, 'POST', JSON.serialize(message), headers);
        Integer statusCode = res.getStatusCode();
        if(statusCode != 200 && statusCode != 201) {
            System.debug('ERROR: ----' +res.getBody());
            insert new Integration_Error__c(Error_Message__c = 'Error while fetching country code', Http_Response_Body__c = res.getBody(), Type__c = 'Location');
        } else {
            Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            if(resBody != null && (Boolean)resBody.get('isSuccess')) {
                countryCode = (String)resBody.get('message');
            } else {
                insert new Integration_Error__c(Error_Message__c = (String)resBody.get('message'), Http_Response_Body__c = 'Error while fetching country code', Type__c = 'Location');
            }
        }
        return countryCode;
    }

    public class sessionListItem {
        @AuraEnabled public Boolean isGroup;
        @AuraEnabled public Map<String, Object> session;
        @AuraEnabled public Map<String, Object> sessionGroup;
        @AuraEnabled public List<Map<String, Object>> groupSessions;
        @AuraEnabled public DateTime startTime; //used for sorting in front end
        
        public sessionListItem(Session_Group__c sessionGroup){
            this.isGroup = true;
            this.groupSessions = new List<Map<String, Object>>();

            for(Session__c session : sessionGroup.Sessions__r){
                groupSessions.add(formatSession(session));
            } 
            
            DateTime startTime = DateTime.newInstanceGMT(sessionGroup.Start_Date__c, Time.newInstance(0, 0, 0, 0));
            DateTime endTime = DateTime.newInstanceGMT(sessionGroup.End_Date__c, Time.newInstance(0, 0, 0, 0));
            
            Map<String, Object> formattedGroup = sessionGroup.getPopulatedFieldsAsMap().clone();
            formattedGroup.put('startDate', startTime.formatGMT('MMM dd, yyyy'));
            formattedGroup.put('endDate', endTime.formatGMT('MMM dd, yyyy'));

            this.startTime = startTime;
            this.sessionGroup = formattedGroup;
        }

        public sessionListItem(Session__c session){
            this.isGroup = false;
            this.session = formatSession(session);

            String sessionTimeZone = String.isNotEmpty(session.Time_Zone__c) ? session.Time_Zone__c : Constants.ORG_TIMEZONE;
            String timezone = isSessionManagerPage ? sessionTimeZone : UserInfo.getTimeZone().getId();

            Integer year = session.Start_Time_Converted__c.yearGmt();
            Integer month = session.Start_Time_Converted__c.monthGmt();
            Integer day = session.Start_Time_Converted__c.dayGmt();
            Integer hours = session.Start_Time_Converted__c.hourGmt();
            Integer minutes = session.Start_Time_Converted__c.minuteGmt();
            Integer seconds = session.Start_Time_Converted__c.secondGmt();
            this.startTime = DateTime.newInstanceGMT(year, month, day, hours, minutes, seconds);
        }
        
        public Map<String, Object> formatSession(Session__c session){
            Map<String, Object> formattedSession = session.getPopulatedFieldsAsMap().clone();
            String sessionTimeZone = String.isNotEmpty(session.Time_Zone__c) ? session.Time_Zone__c : Constants.ORG_TIMEZONE;
            String tz = isSessionManagerPage ? sessionTimeZone : UserInfo.getTimeZone().getId();
            String formattedTimezone = TimeZone.getTimeZone(tz).getDisplayName().substringBetween(') ', ' (');

            formattedSession.put('startTime', session.Start_Time_Converted__c.format('MMM dd, yyyy h:mm a', tz));
            formattedSession.put('endTime', session.End_Time_Converted__c.format('h:mm a', tz));
            formattedSession.put('isSelected', false);

            if(!isSessionManagerPage){
                tz = UserInfo.getTimeZone().getDisplayName().substringBetween(') ', ' (');
            }

            formattedSession.put('userTimeZone', tz);
            formattedSession.put('formattedTimezone', formattedTimezone);
                        
            return formattedSession;
        }
    }

    @AuraEnabled
    public static ResponseData groupSessions(String groupName, List<String> sessionIds){
        ResponseData rd = new ResponseData();

        try {
            List<String> sessionGroupIds = new List<String>();
            Session_Group__c sessionGroup = new Session_Group__c(
                Name = groupName
            );

            List<Session__c> sessions = [SELECT Id, Session_Group__c, Start_Date__c, End_Date__c, Asset__c
                                            FROM Session__c
                                            WHERE Id IN :sessionIds
                                            WITH USER_MODE
                                            ORDER BY Start_Date__c ASC];

            
            sessionGroup.Start_Date__c = sessions[0].Start_Date__c;

            for (Session__c session : sessions) {
                if (sessionGroup.End_Date__c == null || session.End_Date__c > sessionGroup.End_Date__c) {
                    sessionGroup.End_Date__c = session.End_Date__c;
                }
            }

            
            sessionGroup.Asset__c = sessions[0].Asset__c;
            insert as user sessionGroup;

            for (Session__c session : sessions) {
                if (session.Session_Group__c != null) {
                    sessionGroupIds.add(session.Session_Group__c);
                }

                session.Session_Group__c = sessionGroup.Id;
            }

            update as user sessions;

            if (!sessionGroupIds.isEmpty()) {
                List<Session_Group__c> emptySessionGroups = [SELECT Id, (SELECT Id FROM Sessions__r) FROM Session_Group__c WHERE Id IN :sessionGroupIds];
                 for (Session_Group__c emptySessionGroup : emptySessionGroups) {
                    if (emptySessionGroup.Sessions__r.isEmpty()) {
                        delete as user emptySessionGroup;
                    }
                 }
            }

        } catch (Exception e) {
            rd.addError(e);
        }

        return rd;
    }

    @AuraEnabled
    public static ResponseData ungroupSessions(List<String> sessionIds){
        ResponseData rd = new ResponseData();

        try {
            List<Session__c> sessions = [SELECT Id, Session_Group__c
                                         FROM Session__c
                                         WHERE Id IN :sessionIds
                                         WITH USER_MODE];

            List<String> sessionGroupIds = new List<String>();

            for (Session__c session : sessions) {
                sessionGroupIds.add(session.Session_Group__c);
                session.Session_Group__c = null;
            }

            update as user sessions;

            if (!sessionGroupIds.isEmpty()) {
                List<Session_Group__c> sgToUpdate = new List<Session_Group__c>();
                // List<Session_Group__c> emptySessionGroups = [SELECT Id, (SELECT Id FROM Sessions__r) FROM Session_Group__c WHERE Id IN :sessionGroupIds];
                List<Session_Group__c> emptySessionGroups = [SELECT Id, Start_Date__c, End_Date__c ,
                                                                (SELECT Id, Start_Date__c, End_Date__c 
                                                                FROM Sessions__r
                                                                ORDER BY Start_Date__c ASC)
                                                            FROM Session_Group__c 
                                                            WHERE Id IN :sessionGroupIds];
                for (Session_Group__c emptySessionGroup : emptySessionGroups) {
                    if (emptySessionGroup.Sessions__r.isEmpty()) {
                        delete as user emptySessionGroup;
                    } else { // reset the session_group start and end 
                        emptySessionGroup.Start_Date__c = emptySessionGroup.Sessions__r[0].Start_Date__c;
                        emptySessionGroup.End_Date__c = emptySessionGroup.Sessions__r.get(emptySessionGroup.Sessions__r.size() - 1).End_Date__c;
                        sgToUpdate.add(emptySessionGroup);                        
                    }
                }

                if(!sgToUpdate.isEmpty()) {
                    update as user sgToUpdate;
                }
            }

        } catch (Exception e) {
            rd.addError(e);
        }

        return rd;
    }

    @AuraEnabled
    public static ResponseData allowedEditor(Id recordId) {
        ResponseData rd = new ResponseData();
        try{
            rd.put('allowedEditor', false);
            for(Asset__c asset : [SELECT Id, Allowed_Editor__c FROM Asset__c where Id = :recordId WITH USER_MODE LIMIT 1]) {
                rd.put('allowedEditor', asset.Allowed_Editor__c);
            }
                    
        }catch(Exception e){
            rd.addError(e);
        }        
        return rd;
    }
}