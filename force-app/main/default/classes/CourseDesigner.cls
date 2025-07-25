public with sharing class CourseDesigner { 

    public static Map<String, Schema.SObjectField> learnerProfileFieldsByName;

    @AuraEnabled(cacheable=true)
    public static string getInitDesignerData(String recordId){
        ResponseData rd = new ResponseData();
        try {
            List<Course_Asset__c> courseAssets = getCourseData(recordId);
            List<Map<String, String>> picklistEntrys = getLearningAssetRecordTypes();

            rd.put('recordTypePicklistVals', picklistEntrys);
            rd.put('courseAssets', courseAssets);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    public static List<Map<String, String>> getLearningAssetRecordTypes(){
        List<Map<String, String>> picklistEntrys = new List<Map<String, String>>();

        List<RecordType> rts = [SELECT Id, Name, DeveloperName
                                FROM RecordType
                                WHERE SobjectType = 'Asset__c'
                                WITH USER_MODE
                                ORDER BY Name];

        for(RecordType rt : rts){
            Map<String, String> picklistEntry = new Map<String, String>{
                'label' => rt.Name,
                'value' => rt.Id,
                'developerName' => rt.DeveloperName
            };

            picklistEntrys.add(picklistEntry);
        }

        return picklistEntrys;
    }

    @AuraEnabled
    public static string searchAssets(String searchTerm, String recordType){
        ResponseData rd = new ResponseData();

        try {
            String status = 'Active';
            List<String> restrictedAssessmentTypes = new List<String>{'Skill', 'Video'};
            String whereClause = 'WHERE Assessment_Type__c != :restrictedAssessmentTypes AND Status__c = :status AND ' +
                                 ' ((RecordType.DeveloperName != \'Event\') OR (RecordType.DeveloperName = \'Event\' AND Event_Type__c = \'Course\'))';

            if(String.isNotEmpty(recordType) && recordType != 'All'){
                whereClause += ' AND RecordTypeId = :recordType';
            }

            String soslString = 'FIND \'' + String.escapeSingleQuotes(searchTerm) + '\' RETURNING Asset__c(Id ' + whereClause + ') LIMIT 5';
            // soslString = String.format(soslString, new List<String>{whereClause});
            
            List<Asset__c> soslAssets = (List<Asset__c>)Search.query(soslString)[0];
            //requery so we can get children records
            List<Asset__c> assets = [SELECT Id, Name, Assessment_Type__c, RecordType.Name, RecordType.DeveloperName,
                                            (
                                                SELECT Id, Course__r.Name
                                                FROM Course_Assets__r
                                                WHERE Course__c != null
                                                LIMIT 1
                                            )
                                     FROM Asset__c
                                     WHERE Id =: soslAssets
                                     WITH USER_MODE];

            rd.put('searchResults', assets);
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
            List<Object> experienceAssetObjs = (List<Object>)parsedJSON.get('courseAssets');
            List<Object> deletedCourseAssetIds = (List<Object>)parsedJSON.get('deletedCourseAssetIds');
            List<Course_Asset__c> courseAssets = new List<Course_Asset__c>();
            List<Course_Asset__c> deletedCourseAssets = new List<Course_Asset__c>();

            for(Object experienceAsset : experienceAssetObjs){
                courseAssets.add((Course_Asset__c)Utilities.getSobjectByMap((Map<String, Object>)experienceAsset, 'Course_Asset__c'));   
            }

            for(Object deletedCourseAssetId : deletedCourseAssetIds){
                deletedCourseAssets.add(new Course_Asset__c( Id = (String)deletedCourseAssetId));   
            }

            upsert as user courseAssets;
            delete as user deletedCourseAssets;

            //requery data to get the lookups
            if(!courseAssets.isEmpty()){
                courseAssets = getCourseData(courseAssets.get(0).Course__c);
            }

            rd.put('courseAssets', courseAssets);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    @AuraEnabled
    public static string saveLearningAsset(String jsonString){
        ResponseData rd = new ResponseData();

        try {
            Map<String, Object> parsedJSON = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            String recordType = (String)parsedJSON.get('recordType');
            Map<String, Object> assetMap = (Map<String, Object>)parsedJSON.get('asset');

            //should only be for tasks. For other record types we should know the id
            if(String.isNotEmpty(recordType)){
                String recordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
                assetMap.put('RecordTypeId', recordTypeId);
            }

            Asset__c asset = (Asset__c)Utilities.getSobjectByMap(assetMap, 'Asset__c');

            if(recordType == 'Event'){
                asset.Event_Type__c = 'Course';
            }

            upsert as user asset;

            String recordId = asset.Id;
            String soqlString = 'SELECT ' + String.join(new List<String>(getAssetFields(false)), ', ') +
                                ' FROM Asset__c' +
                                ' WHERE Id = :recordId';
            asset = Database.query(soqlString);

            rd.put('asset', asset);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd.getJsonString();
    }

    public static List<Course_Asset__c> getCourseData(String recordId){
        Set<String> fields = new Set<String>{'Id', 'Course__c', 'Course__r.Sequenced__c', 'Course__r.Electives_To_Complete__c', 'Course__r.Allowed_Editor__c', 
                                             'Asset__c', 'Asset__r.Objective__c', 'Elective_Asset__c', 'Required__c', 'Objective__c'};

        fields.addAll(getAssetFields(true));

        String soqlString = 'SELECT ' + String.join(new List<String>(fields), ', ') +
                            ' FROM Course_Asset__c' +
                            ' WHERE Course__c = :recordId' +
                            ' WITH USER_MODE' +
                            ' ORDER BY Order__c ASC' ;

        return Database.query(soqlString);
    }

    public static Set<String> getAssetFields(Boolean isLookup){
        Set<String> assetFields = new Set<String>{'Name', 'Assessment_Type__c', 'Description__c', 'RecordTypeId', 'RecordType.Name', 'Status__c'};

        if(isLookup){
            Set<String> lookupAssetFields = new Set<String>();

            for(String field : assetFields){
                lookupAssetFields.add('Asset__r.' + field);
            }

            assetFields = lookupAssetFields;
        }

        return assetFields;
    }

    @AuraEnabled
    public static String setAssetOptionalityType(String courseAsset, String type, String recordId) {
        ResponseData rd = new ResponseData();

        try{
            Course_Asset__c ca = [SELECT Id, Elective_Asset__c, Required__c 
                                    FROM Course_Asset__c 
                                    WHERE Id =: courseAsset
                                    WITH USER_MODE];
            if(ca == null || String.isEmpty(type)) {
                rd.addError('In correct "Course Asset" Id or Type');
                return rd.getJsonString();
            }

            switch on (type) {
                when 'Elective' {
                    ca.Required__c = FALSE;
                    ca.Elective_Asset__c = TRUE;
                }
                when 'Optional' {
                    ca.Required__c = FALSE;
                    ca.Elective_Asset__c = FALSE;
                } 
                when else {
                    ca.Required__c = TRUE;
                    ca.Elective_Asset__c = FALSE;
                }
            }

            update as user ca;
        } catch(Exception e) {
            rd.addError(e); 
        }
        return rd.getJsonString();
    }

    @AuraEnabled
    public static string updateElectiveAssetCount(String recordId, Integer count){
        ResponseData rd = new ResponseData();

        try {
            if(recordId != null && count != null) {
                Course__c course = [SELECT Id, Electives_To_Complete__c FROM Course__c WHERE Id =: recordId WITH USER_MODE];
                if(course.Electives_To_Complete__c != count) {
                    course.Electives_To_Complete__c = count;
                    update as user course;
                }

                AssetTriggerHelper2.updateCourseTimeEstimate(recordId);
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
            for(Course__c course : [SELECT Id, Allowed_Editor__c FROM Course__c where Id = :recordId WITH USER_MODE LIMIT 1]) {
                rd.put('allowedEditor', course.Allowed_Editor__c);
            }                    
        }catch(Exception e){
            rd.addError(e);
        }        
        return rd;
    }
    
}