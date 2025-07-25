public with sharing class LearnerProfile {
    public static FINAL Integer LOAD_MORE_AMOUNT = 10;

    @AuraEnabled(cacheable=true)
    public static ResponseData getData(){
        ResponseData rd = new ResponseData();
        
        try {
            List<Map<String, String>> timezonePicklistOptions = Utilities.getPicklistVals(User.TimeZoneSidKey.getDescribe());
            List<Map<String, String>> languagePicklistOptions = Utilities.getPicklistVals(User.LanguageLocaleKey.getDescribe(), true);

            rd.put('timezoneOptions', timezonePicklistOptions);
            rd.put('languageOptions', languagePicklistOptions);

            Learner_Profile__c lp = getLearnerProfile();

            populateSMEData(rd, lp);
            populateCompletedData(rd);
            populateTeamMembers(rd, 0, true);

            rd.put('showSettingsModal', lp.Show_Settings_Modal__c && !lp.Show_Walkthrough_Modal__c);
            rd.put('lp', lp);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public static Learner_Profile__c getLearnerProfile(){
        return [SELECT Id, Name, Business_Title__c, Title__c, Preferred_Language__c, Preferred_Language_Key__c, User__r.TimeZoneSidKey, User__r.MediumPhotoUrl, User__r.FirstName, User__r.LastName, 
                        Show_Settings_Modal__c, Show_Walkthrough_Modal__c, People_Manager__c
                FROM Learner_Profile__c
                WHERE User__c =: UserInfo.getUserId()
                AND Status__c = 'Active'
                LIMIT 1];
    }

    public static void populateSMEData(ResponseData rd, Learner_Profile__c lp){
        List<Skill__c> skills = [SELECT Id, Name
                                    FROM Skill__c
                                    WITH USER_MODE];

        List<Product__c> products = [SELECT Id, Name,
                                            (SELECT Id, Name
                                                FROM Products_L2__r
                                                WHERE External_Id__c != null
                                                ORDER BY Name ASC)
                                     FROM Product__c
                                     WHERE External_Id__c != null
                                     WITH USER_MODE
                                     ORDER BY Name ASC];

        List<Industry__c> industries = [SELECT Id, Name,
                                               (SELECT Id, Name
                                                   FROM Industries_L2__r
                                                   ORDER BY Name ASC)
                                        FROM Industry__c
                                        WITH USER_MODE
                                        ORDER BY Name ASC];

        List<Subject_Matter_Expert_Skill__c> smeSkills = [SELECT Id, Skill__c, Skill__r.Name, Learner_Profile__c
                                                     FROM Subject_Matter_Expert_Skill__c
                                                     WHERE Learner_Profile__c =: lp.Id
                                                     WITH USER_MODE
                                                     ORDER BY Skill__r.Name ASC];

        List<Subject_Matter_Expert_Product__c> smeProducts = [SELECT Id, Product__c, Product__r.Name, Product_L2__r.Name, Learner_Profile__c
                                                              FROM Subject_Matter_Expert_Product__c
                                                              WHERE Learner_Profile__c =: lp.Id
                                                              WITH USER_MODE
                                                              ORDER BY Product__r.Name, Product_L2__r.Name ASC];

        List<Subject_Matter_Expert_Industry__c> smeIndustries = [SELECT Id, Industry__c, Industry__r.Name, Industry_L2__r.Name, Learner_Profile__c
                                                                FROM Subject_Matter_Expert_Industry__c
                                                                WHERE Learner_Profile__c =: lp.Id
                                                                WITH USER_MODE
                                                                ORDER BY Industry__r.Name, Industry_L2__r.Name ASC];
        
        List<Subject_Matter_Interest_Skill__c> smiSkills = [SELECT Id, Skill__c, Skill__r.Name, Learner_Profile__c
                                                     FROM Subject_Matter_Interest_Skill__c
                                                     WHERE Learner_Profile__c =: lp.Id
                                                     WITH USER_MODE
                                                     ORDER BY Skill__r.Name ASC];

        List<Subject_Matter_Interest_Product__c> smiProducts = [SELECT Id, Product__c, Product__r.Name, Product_L2__r.Name, Learner_Profile__c
                                                              FROM Subject_Matter_Interest_Product__c
                                                              WHERE Learner_Profile__c =: lp.Id
                                                              WITH USER_MODE
                                                              ORDER BY Product__r.Name, Product_L2__r.Name ASC];

        List<Subject_Matter_Interest_Industry__c> smiIndustries = [SELECT Id, Industry__c, Industry__r.Name, Industry_L2__r.Name, Learner_Profile__c
                                                                   FROM Subject_Matter_Interest_Industry__c
                                                                   WHERE Learner_Profile__c =: lp.Id
                                                                   WITH USER_MODE
                                                                   ORDER BY Industry__r.Name, Industry_L2__r.Name ASC];
        
        rd.put('skills', skills);
        rd.put('products', products);
        rd.put('industries', industries);
        rd.put('smeSkills', smeSkills);
        rd.put('smeProducts', smeProducts);
        rd.put('smeIndustries', smeIndustries);
        rd.put('smiSkills', smiSkills);
        rd.put('smiProducts', smiProducts);
        rd.put('smiIndustries', smiIndustries);
    }

    public static void populateCompletedData(ResponseData rd){
        Catalog.CatalogPayload payload = new Catalog.CatalogPayload();
        payload.searchKey = '';
        payload.completedRecordsOnly = true;
        payload.typeFilters = new List<String>();
        payload.categoryFilters = new List<String>();
        payload.existingCount = 0;
        payload.queryLimit = LOAD_MORE_AMOUNT;
        payload.filteredContentIds = new Map<String,List<String>>();
        payload.applyFilters = false;
        payload.hasTagFilters = false;

        ResponseData catalogRD = Catalog.getFilteredData(payload);
        rd.put('catalogBuckets', catalogRD.results.get('catalogBuckets'));
        rd.put('hasMoreCompleted', catalogRD.results.get('loadingMore'));
        rd.put('completedOffsets', catalogRD.results.get('offsets'));
    }

    public static void populateTeamMembers(ResponseData rd, Integer offset, Boolean fteOnly){
        /*
            SELECT Id, Name, Title__c, User__r.SmallPhotoUrl, FTE__c
            , (SELECT Id, Due_Date__c, Completed__c FROM Assigned_Curricula__r)
            , (SELECT Id, Due_Date__c, Completed__c FROM Assigned_Courses__r WHERE Assigned_Curriculum__c = null)
            , (SELECT Id, Due_Date__c, Completed__c FROM Assignments__r WHERE Assigned_Curriculum__c = null and Assigned_Course__c = null)
            FROM Learner_Profile__c
            WHERE User__r.ManagerId =: UserInfo.getUserId()
            AND FTE__c = true //conditional
            LIMIT 10 
            ORDER BY Name ASC 
            OFFSET :offset
        */
        
        String userId = UserInfo.getUserId();
        String queryString = 'SELECT Id, Name, Business_Title__c, Title__c, User__r.SmallPhotoUrl, FTE__c ' +
                              ', (SELECT Id, Due_Date__c, Completed__c FROM Assigned_Curricula__r WHERE Inactive__c = false) ' +
                              ', (SELECT Id, Due_Date__c, Completed__c FROM Assigned_Courses__r WHERE Assigned_Curriculum__c = null AND Inactive__c = false) ' +
                              ', (SELECT Id, Due_Date__c, Completed__c FROM Assignments__r WHERE Assigned_Curriculum__c = null and Assigned_Course__c = null AND Inactive__c = false) ' +
                             ' FROM Learner_Profile__c';

        String whereClause = ' WHERE User__r.ManagerId = :userId' +
                             ' AND Status__c = \'Active\'';

        if(fteOnly){
            whereClause += ' AND FTE__c = true';
        }

        queryString += whereClause;
        queryString += ' ORDER BY Name ASC' +
                       ' LIMIT ' + (LOAD_MORE_AMOUNT + 1) +
                       ' OFFSET ' + offset;

        List<Learner_Profile__c> teamMembers = Database.query(queryString);
        List<Map<String, Object>> formattedTeamMembers = new List<Map<String, Object>>();

        Boolean hasMore = teamMembers.size() > LOAD_MORE_AMOUNT;

        if(teamMembers.size() > LOAD_MORE_AMOUNT){
            teamMembers.remove(LOAD_MORE_AMOUNT);
        }

        for(Learner_Profile__c teamMember : teamMembers){
            Map<String, Object> formattedTeamMember = teamMember.getPopulatedFieldsAsMap().clone();

            Integer inProgress = 0;
            Integer completed = 0;
            Integer overdue = 0;

            for(Assigned_Curriculum__c ac : teamMember.Assigned_Curricula__r){
                if(ac.Completed__c){
                    completed++;
                } else if(ac.Due_Date__c < Date.today()){
                    overdue++;
                } else {
                    inProgress++;
                }
            }

            for(Assigned_Course__c ac : teamMember.Assigned_Courses__r){
                if(ac.Completed__c){
                    completed++;
                } else if(ac.Due_Date__c < Date.today()){
                    overdue++;
                } else {
                    inProgress++;
                }
            }

            for(Assignment__c a : teamMember.Assignments__r){
                if(a.Completed__c){
                    completed++;
                } else if(a.Due_Date__c < Date.today()){
                    overdue++;
                } else {
                    inProgress++;
                }
            }

            formattedTeamMember.put('inProgress', inProgress);
            formattedTeamMember.put('completed', completed);
            formattedTeamMember.put('overdue', overdue);

            formattedTeamMembers.add(formattedTeamMember);
        }

        Integer totalTeamMembers = [SELECT count() 
                                    FROM Learner_Profile__c 
                                    WHERE User__r.ManagerId = :userId 
                                    AND Status__c = 'Active'];

        rd.put('totalTeamMembers', totalTeamMembers);
        rd.put('hasMoreTeamMembers', hasMore);
        rd.put('teamMembers', formattedTeamMembers);
    }

    @AuraEnabled(cacheable=true)
    public static ResponseData getTeamMembers(Integer offset, Boolean fteOnly){
        ResponseData rd = new ResponseData();
        
        try {
            populateTeamMembers(rd, offset, fteOnly);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData saveProfileData(String jsonString){
        ResponseData rd = new ResponseData();
        
        try {
            Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
    
            saveUserPrefrences(parsedRes, rd);
            saveSMEData(parsedRes, rd);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public static void saveUserPrefrences(Map<String, Object> parsedRes, ResponseData rd){
        try {
            String userId = UserInfo.getUserId();
            String base64Data = (String)parsedRes.get('base64Data');
            String fileType = (String)parsedRes.get('fileType');
            String fileName = (String)parsedRes.get('fileName');
            String timeZone = (String)parsedRes.get('timezone');
            String preferredLanguage = (String)parsedRes.get('preferredLanguage');
            String preferredLanguageKey = (String)parsedRes.get('preferredLanguageKey');

            update new User(Id = userId, TimeZoneSidKey = timeZone);

            System.debug('**************** ' + base64Data);

            if(base64Data != null){
                Blob imageBlob = EncodingUtil.base64Decode(base64Data);
                ConnectApi.BinaryInput binaryInput = new ConnectApi.BinaryInput(imageBlob, fileType, fileName);
                ConnectApi.UserProfiles.setPhoto(null, userId, binaryInput);
                System.debug('**************** ' + imageBlob);
                System.debug('**************** ' + binaryInput);
            }

            Learner_Profile__c lp = getLearnerProfile();

            lp.Preferred_Language__c = preferredLanguage;
            lp.Preferred_Language_Key__c = preferredLanguageKey;

            update lp;

            rd.put('lp', lp);
        } catch (Exception e) {
            rd.addError(e);
        }
    }

    public static void saveSMEData(Map<String, Object> parsedRes, ResponseData rd){
        try{
            Map<String, Object> smeData = (Map<String, Object>)parsedRes.get('smeData');
            Map<String, Object> smiData = (Map<String, Object>)parsedRes.get('smiData');
            //Processs Skills
            processAreaData((List<Object>)smeData.get('skills'), (List<Object>)smeData.get('deletedSkills'), 'Subject_Matter_Expert_Skill__c');
            processAreaData((List<Object>)smeData.get('products'), (List<Object>)smeData.get('deletedProducts'), 'Subject_Matter_Expert_Product__c');
            processAreaData((List<Object>)smeData.get('industries'), (List<Object>)smeData.get('deletedIndustries'), 'Subject_Matter_Expert_Industry__c');
            processAreaData((List<Object>)smiData.get('skills'), (List<Object>)smiData.get('deletedSkills'), 'Subject_Matter_Interest_Skill__c');
            processAreaData((List<Object>)smiData.get('products'), (List<Object>)smiData.get('deletedProducts'), 'Subject_Matter_Interest_Product__c');
            processAreaData((List<Object>)smiData.get('industries'), (List<Object>)smiData.get('deletedIndustries'), 'Subject_Matter_Interest_Industry__c');

            Learner_Profile__c lp = getLearnerProfile();
 
            populateSMEData(rd, lp);
        } catch (Exception e) {
            rd.addError(e);
        }
    }

    public static void processAreaData(List<Object> areaObjs, List<Object> objIdsToDelete, String sObjectType){
        List<sObject> sObjsToUpsert = new List<sObject>();

        for(Object smeSkillObj : areaObjs){
            Map<String, Object> smeSkillMap = (Map<String, Object>)smeSkillObj;
            sObject smeSkill = Utilities.getSobjectByMap(smeSkillMap, sObjectType);

            sObjsToUpsert.add(smeSkill);
        }

        upsert as user sObjsToUpsert;

        List<sObject> sObjsToDelete = new List<sObject>();

        for(Object deletedSkillId : objIdsToDelete){
            sObject sObjToDelete = (sObject)Type.forName(sObjectType).newInstance();
            sObjToDelete.put('Id', (String)deletedSkillId);
            sObjsToDelete.add(sObjToDelete);
        }

        if(!sObjsToDelete.isEmpty()){
            delete as user sObjsToDelete;
        }
    }
}