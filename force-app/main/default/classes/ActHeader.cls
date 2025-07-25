public with sharing class ActHeader {

    @AuraEnabled
    public static ResponseData getData(){
        ResponseData rd = new ResponseData();
        
        try {
            List<Learner_Profile__c> lps = [SELECT Id, Show_Walkthrough_Modal__c, Show_Settings_Modal__c, Preferred_Language__c, Business_Title__c 
                                            FROM Learner_Profile__c 
                                            WHERE User__c =: UserInfo.getUserId() 
                                            AND Status__c = 'Active'
                                            LIMIT 1];

            if(lps.isEmpty()) {
                rd.addError('No Learner Profile found for current user');
                return rd;
            }
            
            Learner_Profile__c lp = lps[0];
            List<Map<String, String>> timezonePicklistOptions = Utilities.getPicklistVals(User.TimeZoneSidKey.getDescribe());
            List<Map<String, String>> languagePicklistOptions = Utilities.getPicklistVals(User.LanguageLocaleKey.getDescribe(), true);
            List<String> allowedAdminPerms = new List<String>{'ACT_Learning_Admin', 'Enablement_Operations_User', 'ACT_Designer', 'JavaPSG'};
            List<PermissionSetAssignment> psas = [SELECT PermissionSet.Name 
                                                  FROM PermissionSetAssignment 
                                                  WHERE AssigneeId =: UserInfo.getUserId()
                                                  AND PermissionSet.Name IN :allowedAdminPerms];

            rd.put('hasDesignerPerms', !psas.isEmpty());
            rd.put('timezoneOptions', timezonePicklistOptions);
            rd.put('languageOptions', languagePicklistOptions);
            rd.put('preferredLanguage', lp.Preferred_Language__c);
            rd.put('showSettingsModal', lp.Show_Settings_Modal__c && !lp.Show_Walkthrough_Modal__c);
            rd.put('lpId', lp.Id);
            rd.put('title', lp.Business_Title__c);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData saveUserPrefrences(String jsonString){
        ResponseData rd = new ResponseData();
        
        try {
            Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            String userId = UserInfo.getUserId();
            String base64Data = (String)parsedRes.get('base64Data');
            String fileType = (String)parsedRes.get('fileType');
            String fileName = (String)parsedRes.get('fileName');
            String timeZone = (String)parsedRes.get('timezone');
            String preferredLanguage = (String)parsedRes.get('preferredLanguage');
            update new User(Id = userId, TimeZoneSidKey = timeZone);

            Learner_Profile__c lp = [SELECT Id, Preferred_Language__c 
                                    FROM Learner_Profile__c 
                                    WHERE User__c =: userId 
                                    AND Status__c = 'Active'
                                    LIMIT 1][0];

            if(lp.Preferred_Language__c != preferredLanguage) {
                update new Learner_Profile__c(Id = lp.Id, Preferred_Language__c = preferredLanguage);
            }

            if(base64Data != null){
                Blob imageBlob = EncodingUtil.base64Decode(base64Data);
                ConnectApi.BinaryInput binaryInput = new ConnectApi.BinaryInput(imageBlob, fileType, fileName);
                ConnectApi.UserProfiles.setPhoto(null, userId, binaryInput);
            }
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    // @AuraEnabled
    // public static void saveUserPrefrences(Id userId, String base64Data, String fileType, String fileName) {
    //     Blob imageBlob = EncodingUtil.base64Decode(base64Data);
    //     ConnectApi.BinaryInput binaryInput = new ConnectApi.BinaryInput(imageBlob, fileType, fileName);
    //     ConnectApi.UserProfiles.setPhoto(null, userId, binaryInput);
    // }

    @AuraEnabled
    public static List<Map<String, String>> getTimezonePicklistValues(String objectName, String fieldName) {
        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
        Schema.DescribeFieldResult fieldDescribe = sobjectDescribe.fields.getMap().get(fieldName).getDescribe();
        List<Map<String, String>> picklistOptions = Utilities.getPicklistVals(fieldDescribe);
        return picklistOptions;
    }

    @AuraEnabled
    public static List<String> getUserPermissionSets(Id userId) {
        List<String> permissionSetNames = new List<String>();
        for (PermissionSetAssignment psa : [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userId]) {
            permissionSetNames.add(psa.PermissionSet.Name);
        }
        return permissionSetNames;
    }

    @AuraEnabled
    public static ResponseData handleThSync(String userId){
        ResponseData rd = new ResponseData();
        List<Learner_Profile__c> lp = [SELECT Id, Name, Last_Trailhead_Sync__c, User__r.Org62_User_ID__c,
                                        (
                                            SELECT Id, Completion_Date__c, Asset__r.Trailhead_Module_Id__c, Completed__c
                                            FROM Assignments__r
                                            WHERE Completed__c = false
                                            AND Inactive__c = false
                                            AND Asset__r.Trailhead_Module_Id__c != NULL                                            
                                        )
                                        FROM Learner_Profile__c
                                        WHERE User__c = :userId
                                        AND User__r.Org62_User_ID__c != NULL]; // UserInfo.getUserId()];
        if(lp.isEmpty()) {
            rd.addError('Not a valid trailhead Id');
            return rd;
        }

        if(!lp[0].Assignments__r.isEmpty()) {
            Integer syncInterval = 15;
            Datetime temp = DateTime.now();
            DateTime nextSyncTime = lp[0].Last_Trailhead_Sync__c != null ? lp[0].Last_Trailhead_Sync__c.addMinutes(syncInterval) : temp.addMinutes(-5);
            if(nextSyncTime < DateTime.now()) {
                return ThCompletionBatchHelper.refreshThCompletion(lp);
            } else{
                rd.addError(String.format(Label.th_sync_interval, new List<String>{String.valueOf(syncInterval), nextSyncTime.format('h:mm a', UserInfo.getTimeZone().toString())}));
            }
        } else {
            rd.put('noIncompleteTHAssignments', Label.th_noIncomplete_assignment);
        }
        return rd;
    }

    @AuraEnabled
    public static ResponseData prepareAlertList(String lpId) {
        ResponseData rd = new ResponseData();
        try {
            List<notificationListItem> notificationList = new List<notificationListItem>();
            List<Assignment__c> managerAssessment = learnerHome.getManagerAssessements(lpId);
            if(!managerAssessment.isEmpty()) {
                notificationList.addAll(notificationList(managerAssessment));
            }     
            List<Assignment__c> assessorAssignment = getAssessorAssignments(lpId);
            if(!assessorAssignment.isEmpty()) {
                notificationList.addAll(notificationList(assessorAssignment));
            }
            rd.put('notificationList', notificationList);
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd;
    }

    public static List<Assignment__c> getAssessorAssignments(String lpId) {
        List<Assignment__c> assignmentsToAssess = new List<Assignment__c>();
        if(lpId != null) {
            String inAppRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('In_App_Assessment').getRecordTypeId();
            assignmentsToAssess = [SELECT Id, Asset__r.RecordType.Name, Asset__r.Name, Asset__r.RecordType.DeveloperName, Learner_Profile__r.Name, 
                                          Learner_Profile__r.User__r.SmallPhotoUrl, Due_Date__c
                                   FROM Assignment__c
                                   WHERE Assessor__c =: lpId
                                   AND Completed__c = false
                                   AND Asset__r.RecordTypeId =: inAppRecordTypeId
                                   WITH USER_MODE
                                   ORDER BY Due_Date__c ASC];
        }
        return assignmentsToAssess;
    }

    public static List<notificationListItem> notificationList(List<Assignment__c> assignments) {
        List<notificationListItem> notificationList = new List<notificationListItem>();
        for(Assignment__c assignment : assignments) {
            notificationList.add(new notificationListItem(assignment));
        }
        return notificationList;
    }    

    public class notificationListItem {
        @AuraEnabled public String label;
        @AuraEnabled public String itemId;
        @AuraEnabled public Date dueDate;
        @AuraEnabled public String learnerName;
        @AuraEnabled public String type;

        public notificationListItem(Assignment__c assignment) {
            label = alertLabel(assignment);
            itemId = assignment.Id;
            dueDate = assignment.Due_Date__c;
            type = assignment.Asset__r.RecordType.DeveloperName;
            learnerName = assignment.Learner_Profile__r.Name;
        }

        public String alertLabel(Assignment__c assignment) {
            String label = '';
            if(assignment.Asset__r.RecordType.DeveloperName == 'In_App_Assessment') {
                label = 'You have a In-App Assessment to complete - \''+ assignment.Asset__r.Name + '\' for ';
            } else if(assignment.Asset__r.RecordType.DeveloperName == 'Skills_Assessment') {
                label = 'You have a Skills Assessment to complete - \''+ assignment.Asset__r.Name + '\' for ';
            }
            return label;
        }
    }
}