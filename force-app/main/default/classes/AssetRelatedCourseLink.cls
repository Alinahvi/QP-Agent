public with sharing class AssetRelatedCourseLink {
    @AuraEnabled(cacheable=true)
    public static ResponseData getRelatedLookupTables(Id recordId){
        switch on recordId.getSObjectType().getDescribe().getName() {
            when 'Asset__c'{
                return getRelatedFromAssetId(recordId);
            }
            when 'Course__c' {
                return getRelatedFromCourseId(recordId);
            }
            when 'Session__c' {
                return getRelatedFromSessionId(recordId);
            }
            when else{
                ResponseData rd = new ResponseData();
                rd.addError('Invalid record type: ' + recordId.getSObjectType().getDescribe().getName());
                return rd;
            }
        }
    }

    private static ResponseData getRelatedFromAssetId(Id assetId) {
        ResponseData rd = new ResponseData();

        try {
            Set<Id> courseIds = new Set<Id>();
            rd.put('courses', null);
            rd.put('curricula', null);

            List<AggregateResult> courseAssetList = [
                SELECT Course__c, Course__r.Name
                FROM Course_Asset__c
                WHERE Asset__c = :assetId
                GROUP BY Course__c, Course__r.Name
                ORDER BY Course__r.Name ASC
            ];

            if(!courseAssetList.isEmpty()){
                rd.put('courses', courseAssetList);

                for(AggregateResult courseAsset : courseAssetList){
                    courseIds.add((Id)courseAsset.get('Course__c'));
                }

                List<AggregateResult> curriculumCourseList = [
                    SELECT Curriculum__c, Curriculum__r.Name
                    FROM Curriculum_Course__c
                    WHERE Course__c IN :courseIds
                    GROUP BY Curriculum__c, Curriculum__r.Name
                    ORDER BY Curriculum__r.Name ASC
                ];

                if(!curriculumCourseList.isEmpty()){
                    rd.put('curricula', curriculumCourseList);
                }
            }
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd;
    }

    private static ResponseData getRelatedFromCourseId(Id courseId) {
        ResponseData rd = new ResponseData();

        try {
            rd.put('courses', null);
            rd.put('curricula', null);

            List<AggregateResult> curriculumCourseList = [
                SELECT Curriculum__c, Curriculum__r.Name
                FROM Curriculum_Course__c
                WHERE Course__c = :courseId
                GROUP BY Curriculum__c, Curriculum__r.Name
                ORDER BY Curriculum__r.Name ASC
            ];

            if(!curriculumCourseList.isEmpty()){
                rd.put('curricula', curriculumCourseList);
            }
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd;
    }

    private static ResponseData getRelatedFromSessionId(Id sessionId) {
        ResponseData rd = new ResponseData();

        try {
            Session__c session = [SELECT Id, Asset__c, Asset__r.Name
                                  FROM Session__c
                                  WHERE Id =: sessionId
                                  WITH USER_MODE];

            rd = getRelatedFromAssetId(session.Asset__c);
            rd.put('events', new List<Asset__c>{session.Asset__r});
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd;
    }
}