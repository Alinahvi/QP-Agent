public with sharing class CurriculumDesigner { 

    public static Map<String, Schema.SObjectField> learnerProfileFieldsByName;

    @AuraEnabled(cacheable=true)
    public static string getInitDesignerData(String curriculumId){
        ResponseData rd = new ResponseData();

        try {
            List<Curriculum_Course__c> curriculumCourses = getCurriculumCourses(curriculumId);

            rd.put('curriculumCourses', curriculumCourses);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static string searchCourses(String searchTerm){
        ResponseData rd = new ResponseData();

        try {
            List<List<sObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING Course__c(Id, Name WHERE Status__c = 'Active') LIMIT 5];
            List<Course__c> courses = searchResults[0];

            rd.put('searchResults', courses);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static string save(String jsonString){
        ResponseData rd = new ResponseData();

        try {
            Map<String, Object> parsedJSON = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            List<Object> curriculumCoursesObjs = (List<Object>)parsedJSON.get('curriculumCourses');
            List<Object> deletedCurriculumCourseIds = (List<Object>)parsedJSON.get('deletedCurriculumCourseIds');
            List<Curriculum_Course__c> curriculumCourses = new List<Curriculum_Course__c>();
            List<Curriculum_Course__c> deletedCurriculumCourses = new List<Curriculum_Course__c>();

            for(Object curriculumCourse : curriculumCoursesObjs){
                curriculumCourses.add((Curriculum_Course__c)Utilities.getSobjectByMap((Map<String, Object>)curriculumCourse, 'Curriculum_Course__c'));   
            }

            for(Object deletedCurriculumCourseId : deletedCurriculumCourseIds){
                deletedCurriculumCourses.add(new Curriculum_Course__c( Id = (String)deletedCurriculumCourseId));   
            }

            upsert as user curriculumCourses;
            delete as user deletedCurriculumCourses;

            //requery data to get the lookups
            if(!curriculumCourses.isEmpty()){
                curriculumCourses = getCurriculumCourses(curriculumCourses.get(0).Curriculum__c);
            }

            rd.put('curriculumCourses', curriculumCourses);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    public static List<Curriculum_Course__c> getCurriculumCourses(String curriculumId){
        return [SELECT Id, Course__c, Course__r.Name, Course__r.Description__c, Course__r.Objective__c, Curriculum__c, Order__c, Elective_Course__c, Required__c, Course__r.Status__c,
                Curriculum__r.Sequenced__c, Curriculum__r.Electives_To_Complete__c, Objective__c, Curriculum__r.Allowed_Editor__c
                FROM Curriculum_Course__c
                WHERE Curriculum__c =: curriculumId
                WITH USER_MODE
                ORDER BY Order__c ASC];
    }

    @AuraEnabled
    public static String setCourseOptionalityType(String curriculumCourse, String type) {
        ResponseData rd = new ResponseData();

        try{
            Curriculum_Course__c ca = [SELECT Id, Elective_Course__c, Required__c 
                                        FROM Curriculum_Course__c 
                                        WHERE Id =: curriculumCourse
                                        WITH USER_MODE];
            if(ca == null || String.isEmpty(type)) {
                rd.addError('In correct "Course Asset" Id or Type');
                return rd.getJsonString();
            }

            switch on (type) {
                when 'Elective' {
                    ca.Required__c = FALSE;
                    ca.Elective_Course__c = TRUE;
                }
                when 'Optional' {
                    ca.Required__c = FALSE;
                    ca.Elective_Course__c = FALSE;
                } 
                when else {
                    ca.Required__c = TRUE;
                    ca.Elective_Course__c = FALSE;
                }
            }

            update as user ca;
        } catch(Exception e) {
            rd.addError(e); 
        }
        return rd.getJsonString();
    }

    @AuraEnabled
    public static string updateElectiveCourseCount(String recordId, Integer count){
        ResponseData rd = new ResponseData();
        try {
            if(recordId != null && count != null) {
                Curriculum__c curriculum = [SELECT Id, Electives_To_Complete__c FROM Curriculum__c WHERE Id =: recordId WITH USER_MODE];
                if(curriculum.Electives_To_Complete__c != count) {
                    curriculum.Electives_To_Complete__c = count;
                    update as user curriculum;
                }

                CurriculumCourseTriggerHelper.updateTimeEstimate(recordId);
            } else {
                rd.addError('In correct course Id or elective asset count');
                return rd.getJsonString();
            }
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd.getJsonString();
    }

    @AuraEnabled
    public static ResponseData allowedEditor(Id recordId) {
        ResponseData rd = new ResponseData();
        try{
            rd.put('allowedEditor', false);
            for(Curriculum__c curr : [SELECT Id, Allowed_Editor__c FROM Curriculum__c where Id = :recordId WITH USER_MODE LIMIT 1]) {
                rd.put('allowedEditor', curr.Allowed_Editor__c);
            }                    
        }catch(Exception e){
            rd.addError(e);
        }        
        return rd;
    }
}