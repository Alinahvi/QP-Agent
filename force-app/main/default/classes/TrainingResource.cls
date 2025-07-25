public with sharing class TrainingResource {
    private static Boolean isFirstFilter = true;

    public class UserRoleWrapper {
        @AuraEnabled public String selectedUser { get; set; }
        @AuraEnabled public String selectedRole { get; set; }
        @AuraEnabled public String sessionGuestId { get; set; }
    }

    @AuraEnabled// (cacheable=true)
    public static ResponseData initData(String responseId){
        ResponseData rd = new ResponseData();
        try {
            FilterPayload payload = new FilterPayload(responseId);
            Object initLPS = getLPWithFilters(JSON.serialize(payload)).results.get('trainers');
            rd.put('trainers', initLPS);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled(cacheable=true) 
    public static ResponseData getFilterData(){
        ResponseData rd = new ResponseData();

        try {
            //Working Time Zone
            List<Map<String, Object>> wtzOptions = new List<Map<String, Object>>();
            
            for(Working_Time_Zone__c wtz : [SELECT Id, Name, Api_Name__c FROM Working_Time_Zone__c WITH USER_MODE]){
                Map<String, Object> wtzMap = new Map<String, Object>{
                    'label' => wtz.Name,
                    'value' => wtz.Api_Name__c
                };

                wtzOptions.add(wtzMap);
            }
            
            //Working Region
            List<Map<String, Object>> wrOptions = new List<Map<String, Object>>();

            for(Working_Region__c wr : [SELECT Id, Name FROM Working_Region__c WITH USER_MODE]){
                Map<String, Object> wrMap = new Map<String, Object>{
                    'label' => wr.Name,
                    'value' => wr.Name
                };

                wrOptions.add(wrMap);
            }

            //Working Location
            List<Map<String, Object>> wlOptions = new List<Map<String, Object>>();

            for(Working_Location__c wl : [SELECT Id, Name FROM Working_Location__c WITH USER_MODE]){
                Map<String, Object> wlMap = new Map<String, Object>{
                    'label' => wl.Name,
                    'value' => wl.Name
                };

                wlOptions.add(wlMap);
            }

            //Language_Proficiency__c
            List<Map<String, Object>> langOptions = new List<Map<String, Object>>();

            for(Language_Proficiency__c lang : [SELECT Id, Name FROM Language_Proficiency__c WITH USER_MODE]){
                Map<String, Object> langMap = new Map<String, Object>{
                    'label' => lang.Name,
                    'value' => lang.Name
                };

                langOptions.add(langMap);
            }

            rd.put('wtzOptions', wtzOptions);
            rd.put('wrOptions', wrOptions);
            rd.put('wlOptions', wlOptions);
            rd.put('langOptions', langOptions);
        } catch (Exception e) {
            rd.addError(e);
        }
  
        return rd;
    }

    @AuraEnabled// (cacheable=true)
    public static ResponseData getLPWithFilters(String jsonString){
        ResponseData rd = new ResponseData();
        try {
            FilterPayload payload = (FilterPayload) JSON.deserialize(jsonString, FilterPayload.class);

            /* 
                SELECT Id, Name 
                FROM Learner_Profile__c
                WHERE Is_Trainer__c = true AND Status__c = 'Active'
                AND Name LIKE :searchPattern //conditional
                AND User__r.ManagerId = :managerId //condidtional
            */
            isFirstFilter = true;
            List<Learner_Profile__c> lps = new List<Learner_Profile__c>();
            String searchPattern = '%' + payload.searchTerm + '%';

            //set up base query
            String soqlString = 'SELECT Id, Name FROM Learner_Profile__c';
            String whereClause = ' WHERE Is_Trainer__c = true AND Status__c = \'Active\'';

            if(String.isNotBlank(payload.searchTerm)){
                whereClause += ' AND Name LIKE \'' + searchPattern + '\'';
            }

            if(payload.view == 'My Team'){
                whereClause += ' AND User__r.ManagerId = \'' + UserInfo.getUserId() + '\'';
            }

            soqlString += whereClause;

            //SOQL is limited to only 2 sub query joins so we'll need to requery 
            //multiple times to reduce the list as more and more filters are chosen

           if(payload.workingTimeZone != null && !payload.workingTimeZone.isEmpty()){
                lps = getFilteredLPs(soqlString, lps, payload.workingTimeZone, 'Trainer_Working_Time_Zone__c', 'Working_Time_Zone__r.Api_Name__c');
            }

            if(payload.workingRegion != null && !payload.workingRegion.isEmpty()){
                lps = getFilteredLPs(soqlString, lps, payload.workingRegion, 'Trainer_Working_Region__c', 'Working_Region__r.Name');
            }

            if(payload.workingLocation != null && !payload.workingLocation.isEmpty()){
                lps = getFilteredLPs(soqlString, lps, payload.workingLocation, 'Trainer_Working_Location__c', 'Working_Location__r.Name');
            }

            if(payload.languageProficiency != null && !payload.languageProficiency.isEmpty()){
                lps = getFilteredLPs(soqlString, lps, payload.languageProficiency, 'Trainer_Language_Proficiency__c', 'Language_Proficiency__r.Name');
            }

            if(payload.isCertified != null && payload.isCertified){
                lps = getFilteredLPs(soqlString, lps, new List<String>{payload.assetId}, 'Enablement_Program_Certification__c', 'Asset__c');
            }

            //no filters were selected so just run the base line query to get any result
            if(isFirstFilter){
                soqlString += ' ORDER BY Name';
                lps = Database.query(soqlString);
            }

            //Cache.session.put('allLps', lps);
            rd.put('trainers', lps);
        } catch(Exception e){
            rd.addError(e); 
        }

        return rd;
    }

    public static List<Learner_Profile__c> getFilteredLPs(String soqlString, List<Learner_Profile__c> lps, List<String> filters, String filterObject, String filterField){
        String soqlStringCopy = soqlString;

        if(!isFirstFilter){
            soqlStringCopy += ' AND Id IN :lps';
        } else {
            isFirstFilter = false;
        }

        soqlStringCopy += ' AND Id IN (SELECT Learner_Profile__c FROM ' + filterObject + ' WHERE ' + filterField + ' IN :filters)';
        soqlString += ' ORDER BY Name';
        System.debug('************* soqlStringCopy ' + soqlStringCopy);
        return Database.query(soqlStringCopy);
    }

    @AuraEnabled
    public static void upsertRoles(Map<String, List<UserRoleWrapper>> sessionUserRoles){
        List<Session_Guest__c> recordsToUpsert = new List<Session_Guest__c>();
        // List<Availability__c> availabilitySessions = new List<Availability__c>();
        Map<Id, Session__c> sessions = new Map<Id, Session__c>(
            [SELECT Id, Name, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Session__c WHERE Id IN :sessionUserRoles.KeySet()]
        );

        for (String sessionId: sessionUserRoles.keySet()) {
            List<UserRoleWrapper> userRoles = sessionUserRoles.get(sessionId);

            for (UserRoleWrapper uR : userRoles) {
                Session_Guest__c guest = new Session_Guest__c();
                Availability__c avail = new Availability__c();
                guest.Session__c = sessionId;
                guest.Learner_Profile__c = uR.selectedUser;
                guest.Role__c = uR.selectedRole;
                guest.From_Scheduler__c = true;
                guest.Session_Role_Status__c = 'Pending';
                recordsToUpsert.add(guest);

                if(String.isNotEmpty(uR.sessionGuestId)){
                    guest.Id = uR.sessionGuestId;
                }

                // Session__c session = sessions.get(sessionId);
                // avail.Learner_Profile__c = uR.selectedUser;
                // avail.Name = session.Name;
                // avail.Type__c = 'Session';
                // avail.Session__c = session.Id;
                // avail.Start_Date__c = DateTime.newInstance(session.Start_Date__c, session.Start_Time__c);
                // avail.End_Date__c = DateTime.newInstance(session.End_Date__c, session.End_Time__c);
                // availabilitySessions.add(avail);
            }
        }
        upsert recordsToUpsert;
        // upsert availabilitySessions;
    }

    @AuraEnabled
    public static ResponseData checkTrainerConflicts(List<Id> selectedSessionIds) {
        ResponseData rd = new ResponseData();
        Map<Id, List<Id>> sessionConflictMap = new Map<Id, List<Id>>(); 

        try {
            List<Session__c> sessions = [SELECT Id, Start_Date__c, End_Date__c, Start_Time_Converted__c, End_Time_Converted__c, Session_Type__c FROM Session__c WHERE Id IN :selectedSessionIds];

            List<Learner_Profile__c> lps = (List<Learner_Profile__c>)Cache.Session.get('allLps');
            if (lps == null) {
                lps = [SELECT Id, Name FROM Learner_Profile__c WHERE Is_Trainer__c = true AND Status__c = 'Active'];
            }

            for (Learner_Profile__c lp : lps) {
                List<Availability__c> events = [SELECT Id, All_Day_Event__c, Start_Date__c, End_Date__c, Type__c FROM Availability__c WHERE Learner_Profile__c =: lp.Id];
                for (Session__c session : sessions) {
                    Boolean hasConflict = false;
                    
                    for (Availability__c event : events) {
                        // 'No Travel Days' are only applicable for Physical Sessions
                        if(session.Session_Type__c != 'Physical' && event.Type__c == 'No Travel Days') {
                            continue;
                        }
                        //System.debug('Session start: ' + session.Start_Date__c + ' event end: ' + event.End_Date__c.date() + ' event start: ' + event.Start_Date__c.date());
                        if (event.All_Day_Event__c && session.Start_Date__c <= event.End_Date__c.date() && session.Start_Date__c >= event.Start_Date__c.date()) {
                            hasConflict = true;
                        } else if(event.Start_Date__c <= session.End_Time_Converted__c && session.Start_Time_Converted__c <= event.End_Date__c){
                            hasConflict = true;
                        }

                        if (hasConflict) {
                            break;
                        }
                    }

                    if (hasConflict) {
                        
                        if (!sessionConflictMap.containsKey(session.Id)) {
                            sessionConflictMap.put(session.Id, new List<Id>());
                        }
                        sessionConflictMap.get(session.Id).add(lp.Id); 
                    }
                }
            }
            System.debug(sessionConflictMap);
            rd.put('conflicts', sessionConflictMap); 
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd;
    }

    @AuraEnabled(cacheable=true)
    public static ResponseData getPicklistValuesForSessionRole(List<String> sessionTypes) {
        ResponseData rd = new ResponseData();
        Map<String, List<String>> sessionPicklistMap = new Map<String, List<String>>();

        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Session_Guest__c.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fieldMap.get('Role__c').getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        try {
            for (String sessionType : sessionTypes) {
                List<String> filteredValues = new List<String>();
                for (Schema.PicklistEntry entry : picklistValues) {
                    if (sessionType == 'Virtual' && (entry.getLabel() == 'Host' || entry.getLabel() == 'Co-Host')) {
                        filteredValues.add(entry.getLabel());
                    } else if (sessionType == 'Physical' && (entry.getLabel() == 'Facilitator' || entry.getLabel() == 'Producer')) {
                        filteredValues.add(entry.getLabel());
                    } else if (sessionType == 'Hybrid' && (entry.getLabel() != 'Participant')) {
                        filteredValues.add(entry.getLabel());
                    }
                }
                sessionPicklistMap.put(sessionType, filteredValues);
            }
            rd.put('sessionMap', sessionPicklistMap);
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd;
    }

    @AuraEnabled
    public static void clearSessionCache() {
        Cache.Session.remove('allLps');
    }

    public class FilterPayload {
        @AuraEnabled public String assetId { get; set; }
        @AuraEnabled public String searchTerm { get; set; }
        @AuraEnabled public List<String> workingTimeZone { get; set; }
        @AuraEnabled public List<String> workingRegion { get; set; }
        @AuraEnabled public List<String> workingLocation { get; set; }
        @AuraEnabled public List<String> languageProficiency { get; set; }
        @AuraEnabled public Boolean isCertified { get; set; }
        @AuraEnabled public String view { get; set; }

        public FilterPayload(String assetId) {
            this.assetId = assetId;
            searchTerm = '';
            workingTimeZone = new List<String>();
            workingRegion = new List<String>();
            workingLocation = new List<String>();
            languageProficiency = new List<String>();
            isCertified = true;
            view = 'All';
        }
    }
}