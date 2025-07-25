public with sharing class AssignLearning {
    private static Map<String, Schema.SObjectField> lpFields;

    @AuraEnabled
    public static ResponseData getData(Id recordId){
        ResponseData rd = new ResponseData();
        
        try {
            rd = getAssignedLearnings(recordId);
            String sObjectType = recordId.getSObjectType() + '';
    
            if(sObjectType == 'Audience__c'){
                Audience__c aud = [SELECT Id, RecordType.DeveloperName FROM Audience__c WHERE Id =: recordId WITH USER_MODE];
                rd.put('audRecordType', aud.RecordType.DeveloperName);
            }
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData getAssignedLearnings(Id recordId){
        ResponseData rd = new ResponseData();
        
        try {
            String sObjectType = recordId.getSObjectType() + '';
            Set<String> fields = new Set<String>{'Id', 'Name', 'Asset__c', 'Course__c', 'Curriculum__c', 'Audience__c', 'Audience__r.Name', 'Audience__r.RecordType.DeveloperName', 'Frequency__c', 'Recur__c',
                                                 'Learning_Name__c', 'Start_Date__c', 'Due_Date__c', 'Custom_Course_Due_Dates__c', 'Learning_Type__c', 'Content_Distribution_Organization__c',
                                                 'Enablement_Learning_Program__c, Enablement_Learning_Program__r.Name', 'OU_Leader__c'};
            String soqlString = 'SELECT ' + String.join(new List<String>(fields), ', ') + 
                                ' FROM Assigned_Learning__c' + 
                                ' WHERE ' + sObjectType + ' = :recordId AND Start_Date__c > TODAY' + 
                                ' WITH USER_MODE' +
                                ' ORDER BY Start_Date__c ASC';
            System.debug('************* recordId ' + recordId);
            List<Assigned_Learning__c> als = Database.query(soqlString);
            // List<Map<String, Object>> formattedAls = new List<Map<String, Object>>();
            // setCustomCourseDueDates(als);



            rd.put('assignedLearnings', als);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled(cacheable=true)
    public static ResponseData getCurricCourses(String curriculumId){
        ResponseData rd = new ResponseData();
        
        try {
            List<Curriculum_Course__c> curricCourses = [SELECT Id, Curriculum__c, Course__c, Course__r.Name
                                                        FROM Curriculum_Course__c
                                                        WHERE Curriculum__c =: curriculumId
                                                        WITH USER_MODE
                                                        ORDER BY Order__c];
            rd.put('curricCourses', curricCourses);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }
  
    // private static void setCustomCourseDueDates(List<Assigned_Learning__c> als){
    //     Map<String, Set<String>> curricCourseByCurricId = new Map<String, Set<String>>();
    //     List<String> curriculumIds = new List<String>();

    //     for(Assigned_Learning__c al : als){
    //         if(al.Curriculum__c != null){
    //             curriculumIds.add(al.Curriculum__c);
    //         }
    //     }

    //     for(Curriculum_Course__c curricExp : [SELECT Id, Curriculum__c, Course__c 
    //                                               FROM Curriculum_Course__c
    //                                               WHERE Curriculum__c =: curriculumIds
    //                                               ORDER BY Order__c]){

    //         if(!curricCourseByCurricId.containsKey(curricExp.Curriculum__c)){
    //             curricCourseByCurricId.put(curricExp.Curriculum__c, new Set<String>());
    //         }

    //         curricCourseByCurricId.get(curricExp.Curriculum__c).add(curricExp.Course__c);
    //     }

    //     //merge the saved ones vs the existing ones
    //     for(Assigned_Learning__c al : als){
    //         if(al.Curriculum__c != null){
    //             Set<String> existingCourses = curricCourseByCurricId.containsKey(al.Curriculum__c) ? curricCourseByCurricId.get(al.Curriculum__c) : new Set<String>();
    //             Map<String, Object> currentCustomCourseDates = new Map<String, Object>();
    //             Map<String, Object> mergedCustomCourseDates = new Map<String, Object>();

    //             if(String.isNotEmpty(al.Custom_Course_Due_Dates__c)){
    //                 currentCustomCourseDates = (Map<String, Object>)JSON.deserializeUntyped(al.Custom_Course_Due_Dates__c);
    //             }

    //             for(String courseId : existingCourses){
    //                 Date dueDate = currentCustomCourseDates.containsKey(courseId) ? Date.valueOf(currentCustomCourseDates.get(courseId)) : al.Due_Date__c;
    //                 mergedCustomCourseDates.put(courseId, dueDate);
    //             }

    //             al.Custom_Course_Due_Dates__c = JSON.serialize(mergedCustomCourseDates);
    //         }
    //     }
    // }

    @AuraEnabled
    public static ResponseData searchForItems(String searchTerm, String startingType){
        ResponseData rd = new ResponseData();
        
        try {
            List<searchResult> searchResults = new List<searchResult>();
            if(startingType == 'Audience__c'){
                searchResults.addAll(searchForLearning(searchTerm));
            } else {
                searchResults.addAll(searchForAudiences(searchTerm));
            }    

            rd.put('searchTerm', searchTerm);   
            rd.put('searchResults', searchResults);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd;
    }

    public static List<searchResult> searchForAudiences(String searchTerm){
        List<List<sObject>> searchResults = [FIND :searchTerm
                                             IN Name Fields
                                             RETURNING Audience__c(Id, Name, OwnerId, RecordType.DeveloperName)
                                             WITH USER_MODE
                                             LIMIT 5];

        List<searchResult> formattedSearchResults = new List<searchResult>();

        for(List<sObject> resultList : searchResults){
            for(sObject result : resultList){
                formattedSearchResults.add(new searchResult(result));
            }
        }

        addUserInfo(formattedSearchResults);

        return formattedSearchResults;
    }

    public static List<searchResult> searchForLearning(String searchTerm){
        List<List<sObject>> searchResults = [FIND :searchTerm
                                             IN Name Fields
                                             RETURNING Curriculum__c(Id, Name, OwnerId WHERE Status__c = 'Active' LIMIT 5), 
                                                       Course__c(Id, Name, OwnerId WHERE Status__c = 'Active' LIMIT 5), 
                                                       Asset__c(Id, Name, OwnerId WHERE Status__c = 'Active' AND RecordType.DeveloperName != 'Content_Block' AND Event_Type__c != 'Course' LIMIT 5)
                                             WITH USER_MODE];

        List<searchResult> formattedSearchResults = new List<searchResult>();

        for(List<sObject> resultList : searchResults){
            for(sObject result : resultList){
                formattedSearchResults.add(new searchResult(result));
            }
        }

        addUserInfo(formattedSearchResults);

        return formattedSearchResults;
    }

    private static void addUserInfo(List<searchResult> searchResults){
        Map<String, List<searchResult>> searchResultByOwnerId = new Map<String, List<searchResult>>();

        for(searchResult sr : searchResults){
            if(!searchResultByOwnerId.containsKey(sr.ownerId)){
                searchResultByOwnerId.put(sr.ownerId, new List<searchResult>());
            }

            searchResultByOwnerId.get(sr.ownerId).add(sr);
        }

        for(User u : [SELECT Id, Name, SmallPhotoUrl FROM User WHERE Id =: searchResultByOwnerId.keySet() WITH USER_MODE]){
            for(searchResult sr : searchResultByOwnerId.get(u.Id)){
                sr.addUserInfo(u);
            }
        }
    }

    @AuraEnabled
    public static ResponseData createAssignedLearnings(String jsonString){
        ResponseData rd = new ResponseData();
        
        try {
            Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            List<Assigned_Learning__c> newAssignedLearnings = new List<Assigned_Learning__c>();

            for(Object obj : (List<Object>)parsedRes.get('newAssignedLearnings')){
                newAssignedLearnings.add((Assigned_Learning__c)utilities.getSobjectByMap((Map<String, Object>)obj, 'Assigned_Learning__c'));
            }

            insert as user newAssignedLearnings;
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled(cacheable=true)
    public static ResponseData getEnablementPrograms(){
        return RecommendedLearners.getEnablementPrograms();
    }

    public class searchResult {
        @AuraEnabled public String name;
        @AuraEnabled public String ownerId;
        @AuraEnabled public String ownerName;
        @AuraEnabled public String ownerPhotoUrl;
        @AuraEnabled public String type;
        @AuraEnabled public String id;
        @AuraEnabled public Object recordType;

        public searchResult(sObject item){
            name = (String)item.get('Name');
            id = (String)item.get('Id');
            ownerId = (String)item.get('OwnerId');
            type = item.getSObjectType() + '';
            if(type == 'Audience__c'){
                recordType = item.getSObject('RecordType');
            }
        }

        public void addUserInfo(User u){
            ownerName = u.Name;
            ownerPhotoUrl = u.SmallPhotoUrl;
        }
    }
}