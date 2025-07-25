public with sharing class Catalog {
    public class CustomException extends Exception {}

    public static final Set<String> validCatalogObjTypes = new Set<String>{ Course__c.getSObjectType() + '', Asset__c.getSObjectType() + '', Curriculum__c.getSObjectType() + '', Session__c.getSObjectType() + ''};
    public static Id learnerProfileId {
        get {
            return [SELECT Id FROM Learner_Profile__c WHERE User__c = :UserInfo.getUserId() WITH USER_MODE LIMIT 1][0].Id;
        }
    }
    public static Id eventRecordTypeId {
        get {
            return Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        }
    }


    /**
     * Retrieves the initial data for the Catalog component if no filters are selected. This will show 4 buckets:
     * 1. Recommendations
     * 2. Courses
     * 3. Events
     * 4. Curricula
     * 
     * @return A ResponseData object containing the initial data for the Catalog component.
     */
    @AuraEnabled
    public static ResponseData getInitialData(){
        ResponseData rd = new ResponseData();

        try {
            List<CatalogBucket> catalogBuckets = new List<CatalogBucket>();

            // Get Recommended Content
            catalogBuckets.add(new CatalogBucket('Recommendation'));

            List<Id> recommendedContentIds = new List<Id>();
            List<Id> recommendationIds = new List<Id>();
            Map<String, Object> recommendedContentByKey = new Map<String, Object>();

            // Find Recommendations
            for (Recommended_Learning__c recommendation : [SELECT Id, Course__c, Asset__c, Curriculum__c, Session__c, Key__c FROM Recommended_Learning__c 
                                                           WHERE Learner_Profile__c = :learnerProfileId 
                                                           AND Status__c = 'Active'
                                                           AND (Course__r.Status__c = 'Active' OR Asset__r.Status__c = 'Active' OR Curriculum__r.Status__c = 'Active' OR Session__r.Status__c = 'Active')
                                                           WITH USER_MODE ORDER BY SEED_Recommended__c DESC, CreatedDate DESC LIMIT 3]) {
                recommendedContentIds.add(String.isNotBlank(recommendation.Course__c) ? recommendation.Course__c : String.isNotBlank(recommendation.Asset__c) ? recommendation.Asset__c : String.isNotBlank(recommendation.Curriculum__c) ? recommendation.Curriculum__c : recommendation.Session__c);
                recommendationIds.add(recommendation.Id);
            }

            // Get Recommended Content
            if (!recommendedContentIds.isEmpty()) {
                for (Curriculum__c curriculum : [SELECT Id, Name, CreatedDate, Description__c, Time_Estimate__c, (SELECT Id, Content_Distribution_Organization__c, OU_Leader__r.Name FROM Recommended_Learnings__r WHERE Id IN :recommendationIds LIMIT 1) 
                                                 FROM Curriculum__c WHERE Id IN :recommendedContentIds WITH USER_MODE]) {
                    // Map<String, Object> curriculumMap = curriculum.getPopulatedFieldsAsMap().clone();
                    Map<String, Object> curriculumMap = learningItemDetail.formatLearningItem(curriculum);
                    curriculumMap.put('type', 'Curriculum__c');
                    recommendedContentByKey.put(RecommendationHelper.getRecommendationKey(learnerProfileId, curriculum.Id), curriculumMap);
                }

                for (Course__c course : [SELECT Id, Name, CreatedDate, Description__c, Time_Estimate__c, (SELECT Id, Content_Distribution_Organization__c, OU_Leader__r.Name FROM Recommended_Learnings__r WHERE Id IN :recommendationIds LIMIT 1) 
                                          FROM Course__c WHERE Id IN :recommendedContentIds WITH USER_MODE]) {
                    // Map<String, Object> courseMap = course.getPopulatedFieldsAsMap().clone();
                    Map<String, Object> courseMap = learningItemDetail.formatLearningItem(course);
                    courseMap.put('type', 'Course__c');
                    recommendedContentByKey.put(RecommendationHelper.getRecommendationKey(learnerProfileId, course.Id), courseMap);
                }

                for (Asset__c asset : [SELECT Id, Name, CreatedDate, Description__c, Assessment_Type__c, RecordType.DeveloperName, Time_Estimate__c, (SELECT Id, Content_Distribution_Organization__c, OU_Leader__r.Name FROM Recommended_Learnings__r WHERE Id IN :recommendationIds LIMIT 1) 
                                         FROM Asset__c WHERE Id IN :recommendedContentIds WITH USER_MODE]) {
                    // Map<String, Object> assetMap = asset.getPopulatedFieldsAsMap().clone();
                    Map<String, Object> assetMap = learningItemDetail.formatLearningItem(asset);
                    assetMap.put('type', 'Asset__c');
                    assetMap.put('recordType', asset.RecordType.DeveloperName);
                    recommendedContentByKey.put(RecommendationHelper.getRecommendationKey(learnerProfileId, asset.Id), assetMap);
                }

                for (Session__c session : [SELECT Id, Name, CreatedDate, Description__c, Start_Time_Converted__c, End_Time_Converted__c, Asset__c, Session_Type__c, 
                                                  Virtual_Registered_Guests__c, Virtual_Capacity__c, Physical_Registered_Guests__c, Physical_Capacity__c,
                                                  (SELECT Id, Content_Distribution_Organization__c, OU_Leader__r.Name FROM Recommended_Learnings__r WHERE Id IN :recommendationIds LIMIT 1) 
                                         FROM Session__c WHERE Id IN :recommendedContentIds WITH USER_MODE]) {
                    // Map<String, Object> assetMap = asset.getPopulatedFieldsAsMap().clone();
                    Map<String, Object> sessionMap = learningItemDetail.formatLearningItem(session);
                    sessionMap.put('type', 'Session__c');
                    recommendedContentByKey.put(RecommendationHelper.getRecommendationKey(learnerProfileId, session.Id), sessionMap);
                }
            }

            System.debug('**************** recommendedContentIds ' + recommendedContentIds);
            
            for (Id recommendedContentId : recommendedContentIds) {
                catalogBuckets[0].items.add(recommendedContentByKey.get(RecommendationHelper.getRecommendationKey(learnerProfileId, recommendedContentId)));
            }

            catalogBuckets[0].itemCount = [SELECT COUNT() FROM Recommended_Learning__c 
                                           WHERE Learner_Profile__c = :learnerProfileId 
                                           AND Status__c = 'Active'
                                           AND (Course__r.Status__c = 'Active' OR Asset__r.Status__c = 'Active' OR Curriculum__r.Status__c = 'Active')
                                           WITH USER_MODE];

            Set<String> types = new Set<String>{ 'Course', 'Event', 'Curriculum'};

            // Get Content
            for (String type : types) {
                CatalogBucket bucket = new CatalogBucket(type);
                Set<Id> filteredRecordIds = new Set<Id>();

                if (Limits.getQueries() < Limits.getLimitQueries()) {
                    String convertedType = type.equals('Event') ? 'Asset' : type;
                    String objType = convertedType + '__c';   

                    if (!validCatalogObjTypes.contains(objType)) {
                        throw new CustomException('Invalid type: ' + objType);
                    }

                    for (SObject record : Database.query(buildQuery(objType), System.AccessLevel.USER_MODE)) {
                        Map<String, Object> recordMap = learningItemDetail.formatLearningItem(record);
                        recordMap.put('type', objType);

                        if(objType == 'Asset__c'){
                            Asset__c asset  = (Asset__c) record;
                            recordMap.put('recordType', asset.RecordType.DeveloperName);
                        }

                        bucket.items.add(recordMap);
                        filteredRecordIds.add((Id) recordMap.get('Id'));
                    }

                    // Query Assigned Courses
                    if (type.equals('Course')) {
                        List<Object> assignedCourses = getAssignedCourses(filteredRecordIds, false, '', new List<String>(), new Map<String, Integer>(), false, new List<String>());

                        for (Object assignedCourse : assignedCourses) {
                            Map<String, Object> assignedCourseMap = (Map<String, Object>) assignedCourse;

                            // Find the existing Course__c record and replace it with the Assigned_Course__c record.
                            for (Object item : bucket.items) {
                                Map<String, Object> itemMap = (Map<String, Object>) item;

                                if (itemMap.get('Id').equals(assignedCourseMap.get('Course__c'))) {
                                    bucket.items.set(bucket.items.indexOf(item), assignedCourseMap);
                                    break;
                                }
                            }
                        }
                    }

                    // Query Assigned Curricula
                    if (type.equals('Curriculum')) {
                        List<Object> assignedCurricula = getAssignedCurriculum(filteredRecordIds, false, '', new List<String>(), new Map<String, Integer>(), false, new List<String>());
                        
                        for (Object assignedCurriculum : assignedCurricula) {
                            Map<String, Object> assignedCurriculumMap = (Map<String, Object>) assignedCurriculum;

                            // Find the existing Curriculum__c record and replace it with the Assigned_Curriculum__c record.
                            for (Object item : bucket.items) {
                                Map<String, Object> itemMap = (Map<String, Object>) item;

                                if (itemMap.get('Id').equals(assignedCurriculumMap.get('Curriculum__c'))) {
                                    bucket.items.set(bucket.items.indexOf(item), assignedCurriculumMap);
                                    break;
                                }
                            }
                        }
                    }

                    // Query Assignments
                    if (type.equals('Event')) {
                        List<Object> assignments = getAssignments(filteredRecordIds, false, '', new List<String>(), false, new List<String>());

                        for (Object assignment : assignments) {
                            Map<String, Object> assignmentMap = (Map<String, Object>) assignment;

                            // Find the existing Asset__c record and replace it with the Assignment__c record.
                            for (Object item : bucket.items) {
                                Map<String, Object> itemMap = (Map<String, Object>) item;

                                if (itemMap.get('Id').equals(assignmentMap.get('Asset__c'))) {
                                    bucket.items.set(bucket.items.indexOf(item), assignmentMap);
                                    break;
                                }
                            }
                        }
                    }

                    bucket.itemCount = getCount(objType);

                    catalogBuckets.add(bucket);
                }
            }

            rd.put('catalogBuckets', catalogBuckets);
        } catch (Exception e) {
            rd.addError(e);
        }

        return rd;
    }

    /**
     * Retrieves the filtered data for the Catalog component based on the provided parameters. This will show 1 bucket (unless no filters are selected):
     * 1. Results
     * 
     * @param payload The payload containing the filter parameters.
     * @return A ResponseData object containing the filtered data for the Catalog component.
     */
    @AuraEnabled
    public static ResponseData getFilteredData(CatalogPayload payload){
        ResponseData rd = new ResponseData();
        try {
            System.debug('*************** ' + payload);
            if (payload.noFiltersSelected()) {
                 return getInitialData();
            }
            
            List<CatalogBucket> catalogBuckets = new List<CatalogBucket>();
            CatalogBucket results = new CatalogBucket('Result');

            if (payload.offsets == null || payload.offsets.isEmpty()) {
                payload.offsets = new Map<String, Integer>{
                    'courseOffset' => 0,
                    'assetOffset' => 0,
                    'curriculumOffset' => 0
                };
            }

            if(payload.applyFilters == null) {
                payload.applyFilters = false;
            }
            if(payload.hasTagFilters == null) {
                payload.hasTagFilters = false;
            }
        
            if(payload.filteredContentIds == null) {
                payload.filteredContentIds = new Map<String, List<String>>();
            }

            Map<String, Integer> newOffsets = new Map<String, Integer>(payload.offsets);
            List<String> categoryFiltersBind = new List<String>();

            for (String filter : payload.categoryFilters) {
                categoryFiltersBind.add(String.escapeSingleQuotes(filter));
            }

            //tag filter bind
            List<String> assetFiltersBind = new List<String>();
            List<String> courseFiltersBind = new List<String>();
            List<String> curriculumFiltersBind = new List<String>();
            // List<String> recommFiltersBinds = new List<String>();
            List<String> contentType = payload.filteredContentIds.get('ContentType');
            
            if(payload.hasTagFilters && contentType != null && contentType.contains('Asset__c')) {
                assetFiltersBind.addAll(payload.filteredContentIds.get('Asset__c'));
            }
            if(payload.hasTagFilters && contentType != null && contentType.contains('Course__c')) {
                courseFiltersBind.addAll(payload.filteredContentIds.get('Course__c'));
            }
            if(payload.hasTagFilters && contentType != null && contentType.contains('Curriculum__c')) {
                curriculumFiltersBind.addAll(payload.filteredContentIds.get('Curriculum__c'));
            }                
            
            Integer courseOffset = payload.offsets.get('courseOffset');
            Integer assetOffset = payload.offsets.get('assetOffset');
            Integer curriculumOffset = payload.offsets.get('curriculumOffset');

            Integer totalCount = 0;
            Set<Id> filteredRecordIds = new Set<Id>();

            checkOffSets(new List<Integer>{courseOffset, assetOffset, curriculumOffset});

            if (payload.onlyRecommended) {
                // Show Only Recommended Content, sorted by the Recommended_Learning__c CreatedDate
                Set<Id> recommendedContentIds = new Set<Id>();
                List<Id> recommendationIds = new List<Id>();
                Map<String, Object> recommendedContentByKey = new Map<String, Object>();
                Boolean addFilterInRecommendation = false;
                List<String> recommendationBind = new List<String>();
                // List<String> eventAssetId = new List<String>();

                if(!payload.filteredContentIds.isEmpty() && 
                    payload.filteredContentIds.get('ContentType').contains('Recommendation__c')) {
                    recommendationBind = payload.filteredContentIds.get('Recommendation__c');
                    addFilterInRecommendation = payload.filteredContentIds.get('ContentType').contains('Recommendation__c') ? true : false;
                }
                
                // System.debug('Filterd Recommendation ------ '+recommendationBind);
                for (Recommended_Learning__c recommendation : Database.query(payload.getRecommendationQueryString(addFilterInRecommendation/*payload.hasTagFilters, payload.filteredContentIds*/), System.AccessLevel.USER_MODE)) {
                    recommendedContentIds.add(String.isNotBlank(recommendation.Course__c) ? recommendation.Course__c : String.isNotBlank(recommendation.Asset__c) ? recommendation.Asset__c : String.isNotBlank(recommendation.Curriculum__c) ? recommendation.Curriculum__c : recommendation.Session__c);
                    recommendationIds.add(recommendation.Id);
                }
                
                if (!recommendedContentIds.isEmpty()) {
                    for (Curriculum__c curriculum : [SELECT Id, Name, CreatedDate, Description__c, Time_Estimate__c, Block_Self_Enrollment__c, (SELECT Id, Content_Distribution_Organization__c, OU_Leader__r.Name FROM Recommended_Learnings__r WHERE Id IN :recommendationIds LIMIT 1) 
                                                     FROM Curriculum__c WHERE Id IN :recommendedContentIds WITH USER_MODE]) {
                        // Map<String, Object> curriculumMap = curriculum.getPopulatedFieldsAsMap().clone();
                        Map<String,Object> curriculumMap = learningItemDetail.formatLearningItem(curriculum);
                        curriculumMap.put('type', 'Curriculum__c');
                        recommendedContentByKey.put(RecommendationHelper.getRecommendationKey(learnerProfileId, curriculum.Id), curriculumMap);
                    }
    
                    for (Course__c course : [SELECT Id, Name, CreatedDate, Description__c, Time_Estimate__c, Block_Self_Enrollment__c, (SELECT Id, Content_Distribution_Organization__c, OU_Leader__r.Name FROM Recommended_Learnings__r WHERE Id IN :recommendationIds LIMIT 1) 
                                              FROM Course__c WHERE Id IN :recommendedContentIds WITH USER_MODE]) {
                        // Map<String, Object> courseMap = course.getPopulatedFieldsAsMap().clone();
                        Map<String,Object> courseMap = learningItemDetail.formatLearningItem(course);
                        courseMap.put('type', 'Course__c');
                        recommendedContentByKey.put(RecommendationHelper.getRecommendationKey(learnerProfileId, course.Id), courseMap);
                    }
    
                    for (Asset__c asset : [SELECT Id, Name, RecordTypeId, RecordType.DeveloperName, CreatedDate, Description__c, Time_Estimate__c, Assessment_Type__c, Block_Self_Enrollment__c, (SELECT Id, Content_Distribution_Organization__c, OU_Leader__r.Name FROM Recommended_Learnings__r WHERE Id IN :recommendationIds LIMIT 1) 
                                             FROM Asset__c WHERE Id IN :recommendedContentIds WITH USER_MODE]) {
                        // Map<String, Object> assetMap = asset.getPopulatedFieldsAsMap().clone();
                        Map<String,Object> assetMap = learningItemDetail.formatLearningItem(asset);
                        assetMap.put('type', 'Asset__c');
                        assetMap.put('recordType', asset.RecordType.DeveloperName);
                        // if(asset.RecordType.DeveloperName == 'Event') {
                        //     eventAssetId.add(asset.Id);
                        // }
                        recommendedContentByKey.put(RecommendationHelper.getRecommendationKey(learnerProfileId, asset.Id), assetMap);
                    }

                    // // add registered session
                    // if(!eventAssetId.isEmpty()) {
                    //     registeredSessionsOnRecomEvent(eventAssetId, learnerProfileId, recommendedContentByKey);                        
                    // }
                    // /////

                    for (Session__c session : [SELECT Id, Name, CreatedDate, Description__c, Start_Time_Converted__c, End_Time_Converted__c, Session_Type__c, Asset__c, 
                                                      Virtual_Registered_Guests__c, Virtual_Capacity__c, Physical_Registered_Guests__c, Physical_Capacity__c,
                                                      (SELECT Id, Content_Distribution_Organization__c, OU_Leader__r.Name FROM Recommended_Learnings__r WHERE Id IN :recommendationIds LIMIT 1) 
                                               FROM Session__c WHERE Id IN :recommendedContentIds WITH USER_MODE]) {
                        // Map<String, Object> assetMap = asset.getPopulatedFieldsAsMap().clone();
                        Map<String, Object> sessionMap = learningItemDetail.formatLearningItem(session);
                        sessionMap.put('type', 'Session__c');
                        recommendedContentByKey.put(RecommendationHelper.getRecommendationKey(learnerProfileId, session.Id), sessionMap);
                    }
                }
    
                // Adjust Offset
                for (Id recommendedContentId : recommendedContentIds) {
                    results.items.add(recommendedContentByKey.get(RecommendationHelper.getRecommendationKey(learnerProfileId, recommendedContentId)));
                }

                if (!newOffsets.containsKey('recommendationOffset')) {
                    newOffsets.put('recommendationOffset', 0);
                }

                newOffsets.put('recommendationOffset', newOffsets.get('recommendationOffset') + results.items.size());

                totalCount = Database.countQuery('SELECT COUNT() FROM Recommended_Learning__c' + payload.getRecommendationQueryFilters(addFilterInRecommendation/*payload.hasTagFilters*/), System.AccessLevel.USER_MODE);
            } else if (payload.completedRecordsOnly) {
                if (payload.typeFilters.isEmpty()) {
                    payload.typeFilters = new List<String>{ 'Course', 'Curriculum', 'Asset' };
                }

                if(payload.applyFilters) {
                    List<String> temp = new List<String>();
                    /* if(payload.filteredContentIds.get('ContentType').contains('Recommendation__c')) {
                        payload.hasTagFilters = true;
                        payload.filteredContentIds = getRecommendedLearningByType(payload.filteredContentIds);                        
                    } */
                    for(String val : payload.filteredContentIds.get('ContentType')) {
                        temp.add(val.removeEnd('__c'));                        
                    }
                    payload.typeFilters = temp;                  
                }
                for (String recordType : payload.typeFilters) {
                    if (recordType.equals('Course')) {
                        List<Object> assignedCourses = getAssignedCourses(new Set<Id>(), true, payload.searchKey, payload.categoryFilters, payload.offsets, payload.hasTagFilters, payload.filteredContentIds.get('Course__c'));
                        results.items.addAll(assignedCourses);
                        totalCount += getCount('Assigned_Course__c', payload.searchKey, payload.categoryFilters, payload.hasTagFilters, payload.filteredContentIds);
                    }

                    if (recordType.equals('Curriculum')) {
                        List<Object> assignedCurricula = getAssignedCurriculum(new Set<Id>(), true, payload.searchKey, payload.categoryFilters, payload.offsets, payload.hasTagFilters, payload.filteredContentIds.get('Curriculum__c'));
                        results.items.addAll(assignedCurricula);
                        totalCount += getCount('Assigned_Curriculum__c', payload.searchKey, payload.categoryFilters, payload.hasTagFilters, payload.filteredContentIds);
                    }

                    if (recordType.equals('Asset')) {
                        List<Object> completedAssets = getCompletedAssets(payload.searchKey, payload.offsets, payload.hasTagFilters, payload.filteredContentIds.get('Asset__c'));
                        results.items.addAll(completedAssets);
                        totalCount += getCount('Assignment__c', payload.searchKey, payload.categoryFilters, payload.hasTagFilters, payload.filteredContentIds);
                    }
                }
                
                // Grab the Completion_Date__c from the Assignment__c record and add it to the Asset__c record for sorting.
                // for (Object item : results.items) {
                //     Map<String, Object> itemMap = (Map<String, Object>)item;

                //     if (itemMap.get('type').equals('Asset__c')) {
                //         List<Assignment__c> assignmentList = (List<Assignment__c>)itemMap.get('Assignments__r');
                //         Map<String,Object> assignmentMap = (Map<String,Object>)assignmentList[0].getPopulatedFieldsAsMap().clone();
                //         itemMap.put('Completion_Date__c', assignmentMap.get('Completion_Date__c'));                                                
                //     }
                // }

                // Sort the items by Completion_Date__c in descending order.
                List<Object> sortedItems = Utilities.sortByField(results.items, 'Completion_Date__c', true);

                results.items = new List<Object>();

                // Trim the results to the query limit
                for (Integer i = 0; i < payload.queryLimit && i < sortedItems.size(); i++) {
                    results.items.add(sortedItems[i]);

                    // Adjust offsets
                    String type = (String) ((Map<String, Object>) results.items[i]).get('type');
                    
                    if (type.equals('Assigned_Course__c')) {
                        type = 'Course__c';
                    }

                    if (type.equals('Assigned_Curriculum__c')) {
                        type = 'Curriculum__c';
                    }

                    String offsetName = type.toLowerCase().removeEnd('__c') + 'Offset';

                    if (!newOffsets.containsKey(offsetName)) {
                        newOffsets.put(offsetName, 0);
                    }

                    newOffsets.put(offsetName, newOffsets.get(offsetName) + 1);
                }
            } else {
                // Get Content
                // List<String> objTypes = payload.isTagFilter/* isTagFiltersAvailable() */ ? payload.filteredContentIds.get('ContentType') : new List<String>(validCatalogObjTypes);
                List<String> objTypes = payload.applyFilters && !payload.filteredContentIds.get('ContentType').contains('Recommendation__c') ? payload.filteredContentIds.get('ContentType') : new List<String>(validCatalogObjTypes);

                System.debug('************ objTypes ' + objTypes);
                for (String type : objTypes) { // validCatalogObjTypes) {
                    //only used in recommended for now
                    if(type == 'Session__c'){
                        continue;
                    }

                    String convertedType = (type.equals('Asset__c') ? 'Event' : type).removeEnd('__c');

                    if (Limits.getQueries() > Limits.getLimitQueries() || !(payload.typeFilters.contains(convertedType) || payload.queryAllTypes)) {
                        continue;
                    }

                    String query = buildFilteredQuery(type, payload.searchKey, payload.categoryFilters, payload.queryLimit, payload.offsets, payload.hasTagFilters, payload.filteredContentIds);
                    for (SObject record : Database.query(query, System.AccessLevel.USER_MODE)) {
                        Map<String, Object> recordMap = record.getPopulatedFieldsAsMap().clone();
                        recordMap.put('type', type);

                        if(type == 'Asset__c'){
                            Asset__c asset  = (Asset__c) record;
                            recordMap.put('recordType', asset.RecordType.DeveloperName);
                        }

                        results.items.add(recordMap);
                        filteredRecordIds.add((Id) recordMap.get('Id'));
                    }
                    totalCount += getCount(type, payload.searchKey, payload.categoryFilters, payload.hasTagFilters, payload.filteredContentIds);
                    
                    // Query Assigned Courses
                    if (type.equals('Course__c')) {
                        List<Object> assignedCourses = getAssignedCourses(filteredRecordIds, payload.completedRecordsOnly, '', new List<String>(), payload.offsets, payload.hasTagFilters, payload.filteredContentIds.get('Course__c'));

                        for (Object assignedCourse : assignedCourses) {
                            Map<String, Object> assignedCourseMap = (Map<String, Object>) assignedCourse;

                            // Find the existing Course__c record and replace it with the Assigned_Course__c record.
                            for (Object item : results.items) {
                                Map<String, Object> itemMap = (Map<String, Object>) item;

                                if (itemMap.get('Id').equals(assignedCourseMap.get('Course__c'))) {
                                    results.items.set(results.items.indexOf(item), assignedCourseMap);
                                    break;
                                }
                            }
                        }
                    }

                    // Query Assigned Curricula
                    if (type.equals('Curriculum__c')) {
                        List<Object> assignedCurricula = getAssignedCurriculum(filteredRecordIds, payload.completedRecordsOnly, '', new List<String>(), payload.offsets, payload.hasTagFilters, payload.filteredContentIds.get('Curriculum__c'));
                        
                        for (Object assignedCurriculum : assignedCurricula) {
                            Map<String, Object> assignedCurriculumMap = (Map<String, Object>) assignedCurriculum;

                            // Find the existing Curriculum__c record and replace it with the Assigned_Curriculum__c record.
                            for (Object item : results.items) {
                                Map<String, Object> itemMap = (Map<String, Object>) item;

                                if (itemMap.get('Id').equals(assignedCurriculumMap.get('Curriculum__c'))) {
                                    results.items.set(results.items.indexOf(item), assignedCurriculumMap);
                                    break;
                                }
                            }
                        }
                    }

                    // Query Assignments
                    if (type.equals('Asset__c')) {
                        List<Object> assignments = getAssignments(filteredRecordIds, false, '', new List<String>(), payload.hasTagFilters, payload.filteredContentIds.get('Asset__c'));

                        for (Object assignment : assignments) {
                            Map<String, Object> assignmentMap = (Map<String, Object>) assignment;

                            // Find the existing Asset__c record and replace it with the Assignment__c record.
                            for (Object item : results.items) {
                                Map<String, Object> itemMap = (Map<String, Object>) item;

                                if (itemMap.get('Id').equals(assignmentMap.get('Asset__c'))) {
                                    results.items.set(results.items.indexOf(item), assignmentMap);
                                    break;
                                }
                            }
                        }
                    }
                }

                // Sort the items by CreatedDate in descending order.
                List<Object> sortedItems = Utilities.sortByField(results.items, 'CreatedDate', true);

                results.items = new List<Object>();

                // Trim the results to the query limit
                for (Integer i = 0; i < payload.queryLimit && i < sortedItems.size(); i++) {
                    results.items.add(sortedItems[i]);

                    // Adjust offsets
                    String type = (String) ((Map<String, Object>) results.items[i]).get('type');
                    
                    if (type.equals('Assigned_Course__c')) {
                        type = 'Course__c';
                    }

                    String offsetName = type.toLowerCase().removeEnd('__c') + 'Offset';

                    if (!newOffsets.containsKey(offsetName)) {
                        newOffsets.put(offsetName, 0);
                    }

                    newOffsets.put(offsetName, newOffsets.get(offsetName) + 1);
                }
            }

            results.itemCount = totalCount;

            if (payload.existingCount + results.items.size() < totalCount) {
                results.hasMore = true;
            }
            
            catalogBuckets.add(results);

            rd.put('catalogBuckets', catalogBuckets);
            rd.put('offsets', newOffsets);
            rd.put('loadingMore', payload.loadingMore);
        } catch (Exception e) {
            System.debug('********* in here2?');
            rd.addError(e);
        }

        return rd;
    }

    // public static void registeredSessionsOnRecomEvent(List<String> eventIds, String lpId, Map<String, Object> contentByLpAndId) {
    //     Map<String, List<Map<String, Object>>> registeredSessionByEventId = new Map<String, List<Map<String, Object>>>();
    //     for(Session__c session : [SELECT Id, CreatedDate, Name, Description__c, Objective__c, Session_Type__c, Start_Date__c, Start_Time_Converted__c, End_Time_Converted__c, Time_Zone__c, Region__c,
    //                                 Share_Url__c, Asset__c,
    //                                 (
    //                                     SELECT Id, Status__c 
    //                                     FROM Assigned_Sessions__r 
    //                                     WHERE Learner_Profile__c =: lpId 
    //                                     AND Status__c = 'Registered'
    //                                 )
    //                                 FROM Session__c 
    //                                 WHERE Asset__c IN: eventIds
    //                                 WITH USER_MODE
    //                                 ORDER BY Start_Date__c ASC, Start_Time__c ASC]) {
    //         if(session.Assigned_Sessions__r != null && !session.Assigned_Sessions__r.isEmpty()) {
    //             String timezone = UserInfo.getTimeZone().getId();
    //             String startTime =  session.Start_Time_Converted__c.format('MMM dd, yyyy h:mm a', timezone);
    //             String month = '';
    //             String day = '';
    //             if(String.isNotBlank(startTime)) {
    //                 List<String> strList = startTime.split(' ');
    //                 month = !strList.isEmpty() && strList[0] != null ? strList[0] : '';
    //                 day = !strList.isEmpty() && strList[1] != null ? strList[1].replace(',','') : '';
    //             }
    //             List<Map<String, Object>> registerdSessions = new List<Map<String, Object>> {
    //                 new Map<String, Object> {
    //                     'sessionId' => session.Id,
    //                     'sessionName' => session.Name,
    //                     'type' => session.Session_Type__c,
    //                     'month' => (Object)month,
    //                     'day' => (Object)day
    //                 }
    //             };
    //             Map<String, Object> content = (Map<String, Object>)contentByLpAndId.get(RecommendationHelper.getRecommendationKey(lpId, session.Asset__c));
    //             content.put('registeredSessions', registerdSessions);           
    //         } else {
    //             // add empty registered session list
    //             if(contentByLpAndId.containsKey(RecommendationHelper.getRecommendationKey(lpId, session.Asset__c))) {
    //                 Map<String, Object> content = (Map<String, Object>)contentByLpAndId.get(RecommendationHelper.getRecommendationKey(lpId, session.Asset__c));
    //                 content.put('registeredSessions', new List<Map<String, Object>>());
    //             }
    //         }
    //     }         
    // }

    /**
     * Builds a query based on the provided object type.
     * 
     * @param type The object type to query.
     */
    private static String buildQuery(String type) {
        return buildFilteredQuery(type, '', new List<String>(), 3, new Map<String, Integer>(), false, new Map<String, List<String>>());
    }

    /**
     * Builds a filtered query based on the provided parameters.
     * 
     * @param type The object type to query.
     * @param searchKey The search key to filter the query results.
     * @param categoryFilters The list of category filters to apply.
     * @param queryLimit The maximum number of records to return in the query.
     * @param offset The offset value for pagination.
     * @return The constructed SOQL query string.
     */
    private static String buildFilteredQuery(String type, String searchKey, List<String> categoryFilters, Integer queryLimit, Map<String, Integer> offsets, Boolean hasTagFilters, Map<String, List<String>> tagFilters) { 
        String queryString = 'SELECT Id, Name, CreatedDate, Description__c, Time_Estimate__c, Block_Self_Enrollment__c';
        System.debug('************* type ' + type);
        if(type == 'Asset__c') {
            queryString += ', RecordType.DeveloperName, Assessment_Type__c';
        }
        
        queryString += ', (SELECT Id, Content_Distribution_Organization__c, OU_Leader__r.Name FROM Recommended_Learnings__r';
        queryString += ' WHERE Learner_Profile__c = :learnerProfileId AND ' + type + ' != null AND Status__c = \'Active\' LIMIT 1) FROM ' + type + ' WHERE Status__c = \'Active\'';
        
        // TODO - Show Blocked Content if it's recommended. This currently only works if Recommendations filter is selected
        queryString += ' AND Block_Self_Enrollment__c = false';
        
        if(hasTagFilters && type == 'Asset__c' && tagFilters.get('ContentType').contains(type)) {
            queryString += ' AND Id IN :assetFiltersBind';
        } else if(hasTagFilters && type == 'Course__c' && tagFilters.get('ContentType').contains(type)) {
            queryString += ' AND Id IN :courseFiltersBind';
        } else if(hasTagFilters && type == 'Curriculum__c' && tagFilters.get('ContentType').contains(type)) {
            queryString += ' AND Id IN :curriculumFiltersBind';
        }        

        if (type == 'Asset__c') {
            // queryString += ' AND recordTypeId = :eventRecordTypeId AND (Event_Type__c = \'Stand Alone\' OR Event_Type__c = \'Recurring\')';
            queryString += ' AND recordTypeId = :eventRecordTypeId AND (Event_Type__c = \'Stand Alone\')';            
        }

        if (String.isNotBlank(searchKey)) {
            queryString += ' AND Name LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\'';
        }

        if (!categoryFilters.isEmpty()) {
            queryString += ' AND Primary_Category__c IN :categoryFiltersBind';
        }

        queryString += ' ORDER BY CreatedDate DESC';

        if (queryLimit != null) {
            queryString += ' LIMIT ' + queryLimit;
        }

        switch on type {
            when 'Course__c' {
                if (offsets.containsKey('courseOffset')) {
                    queryString += ' OFFSET ' + offsets.get('courseOffset');
                }
            }
            when 'Curriculum__c' {
                if (offsets.containsKey('curriculumOffset')) {
                    queryString += ' OFFSET ' + offsets.get('curriculumOffset');
                }
            }
            when 'Asset__c' {
                if (offsets.containsKey('assetOffset')) {
                    queryString += ' OFFSET ' + offsets.get('assetOffset');
                }
            }
            when else {
                throw new CustomException('Invalid type: ' + type);
            }
        }
        
        return queryString;
    }

    private static Integer getCount(String type) {
        switch on type {
            when 'Course__c' {
                return getCourseCount('', new List<String>(), false, new Map<String,List<String>>());
            }
            when 'Asset__c' {
                return getEventCount('', new List<String>(), false, new Map<String,List<String>>());
            }
            when 'Curriculum__c' {
                return getCurriculumCount('', new List<String>(), false, new Map<String,List<String>>());
            }
            when 'Assigned_Course__c' {
                return getAssignedCourseCount('', new List<String>(), false, new List<String>());
            }
            when 'Assigned_Curriculum__c' {
                return getAssignedCurriculumCount('', new List<String>(), false, new List<String>());
            }
            when 'Assignment__c' {
                return getAssignmentCount('', new List<String>(), false, new List<String>());
            }
            when else {
                throw new CustomException('Invalid type: ' + type);
            }
        }
    }

    private static Integer getCount(String type, String searchKey, List<String> categoryFilters) {
        return getCount(type, searchKey, categoryFilters, false, new Map<String, List<String>>());
    }

    private static Integer getCount(String type, String searchKey, List<String> categoryFilters, Boolean hasTagFilters, Map<String, List<String>> filteredContentIds) {
        switch on type {
            when 'Course__c' {
                return getCourseCount(searchKey, categoryFilters, hasTagFilters, filteredContentIds);
            }
            when 'Asset__c' {
                return getEventCount(searchKey, categoryFilters, hasTagFilters, filteredContentIds);
            }
            when 'Curriculum__c' {
                return getCurriculumCount(searchKey, categoryFilters, hasTagFilters, filteredContentIds);
            }
            when 'Assigned_Course__c' {
                return getAssignedCourseCount(searchKey, categoryFilters, hasTagFilters, filteredContentIds.get('Course__c'));
            }
            when 'Assigned_Curriculum__c' {
                return getAssignedCurriculumCount(searchKey, categoryFilters, hasTagFilters, filteredContentIds.get('Curriculum__c'));
            }
            when 'Assignment__c' {
                return getAssignmentCount(searchKey, categoryFilters, hasTagFilters, filteredContentIds.get('Asset__c'));
            }
            when else {
                throw new CustomException('Invalid type: ' + type);
            }
        }
    }

    /**
     * Returns the count of courses based on the search key and category filters.
     * 
     * @param searchKey The search key to filter the course names.
     * @param categoryFilters The list of category filters to filter the courses.
     * @return The count of courses that match the search key and category filters.
     */
    private static Integer getCourseCount(String searchKey, List<String> categoryFilters, Boolean hasTagFilters, Map<String, List<String>> filteredContentIds) {
        String searchKeyBind = '%' + String.escapeSingleQuotes(searchKey) + '%';
        List<String> categoryFiltersBind = categoryFilters;
        Integer courseCount = 0;
        List<String> courseFiltersBind = filteredContentIds.get('Course__c');
        

        String queryString = 'SELECT COUNT() FROM Course__c WHERE Status__c = \'Active\' AND Block_Self_Enrollment__c = false ';
        if (String.isNotBlank(searchKey) && categoryFilters.size() > 0) {
            queryString += 'AND Name LIKE :searchKeyBind AND Primary_Category__c IN :categoryFiltersBind ';
        } else if (String.isNotBlank(searchKey) && categoryFilters.size() == 0) {
            queryString += 'AND Name LIKE :searchKeyBind ';
        } else if (String.isBlank(searchKey) && categoryFilters.size() > 0) {
            queryString += 'AND Primary_Category__c IN :categoryFiltersBind ';
        }

        
        if(hasTagFilters && courseFiltersBind != null) {
            queryString += ' AND Id IN :courseFiltersBind';
        }
        
        courseCount = Database.countQuery(queryString, System.AccessLevel.USER_MODE);

        return courseCount;
    }

    /**
     * Returns the count of assets based on the search key and category filters.
     * 
     * @param searchKey The search key to filter assets by name.
     * @param categoryFilters The list of category filters to filter assets by primary category.
     * @return The count of assets that match the search key and category filters.
     */
    private static Integer getEventCount(String searchKey, List<String> categoryFilters, Boolean hasTagFilters, Map<String, List<String>> filteredContentIds) {
        String searchKeyBind = '%' + String.escapeSingleQuotes(searchKey) + '%';
        List<String> categoryFiltersBind = categoryFilters;
        Integer assetCount = 0;
        List<String> assetFiltersBind = filteredContentIds.get('Asset__c');
        Id eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
 
        // String queryString = 'SELECT COUNT() FROM Asset__c WHERE recordTypeId = :eventRecordTypeId AND (Event_Type__c = \'Stand Alone\' OR Event_Type__c = \'Recurring\') AND Status__c = \'Active\' AND Block_Self_Enrollment__c = false ';
        String queryString = 'SELECT COUNT() FROM Asset__c WHERE recordTypeId = :eventRecordTypeId AND (Event_Type__c = \'Stand Alone\') AND Status__c = \'Active\' AND Block_Self_Enrollment__c = false ';
        // recurring type is Obsolete :: OR Event_Type__c = \'Recurring\'

        if (String.isNotBlank(searchKey) && categoryFilters.size() > 0) {
            queryString += 'AND Name LIKE :searchKeyBind AND Primary_Category__c IN :categoryFiltersBind ';
        } else if (String.isNotBlank(searchKey) && categoryFilters.size() == 0) {
            queryString += 'AND Name LIKE :searchKeyBind ';
        } else if (String.isBlank(searchKey) && categoryFilters.size() > 0) {
            queryString += 'AND Primary_Category__c IN :categoryFiltersBind ';
        }

        
        if(hasTagFilters && assetFiltersBind != null) {
            queryString += ' AND Id IN :assetFiltersBind';
        }

        assetCount = Database.countQuery(queryString, System.AccessLevel.USER_MODE);

        return assetCount;
    }

    /**
     * Returns the count of Curriculum records based on the search key and category filters.
     * 
     * @param searchKey The search key to filter the Curriculum records by name.
     * @param categoryFilters The list of category filters to filter the Curriculum records by primary category.
     * @return The count of Curriculum records that match the search key and category filters.
     */
    private static Integer getCurriculumCount(String searchKey, List<String> categoryFilters, Boolean hasTagFilters, Map<String, List<String>> filteredContentIds) {
        String searchKeyBind = '%' + String.escapeSingleQuotes(searchKey) + '%';
        List<String> categoryFiltersBind = categoryFilters;
        Integer curriculumCount = 0;
        List<String> curriculumFiltersBind = filteredContentIds.get('Curriculum__c');

        String queryString = 'SELECT COUNT() FROM Curriculum__c WHERE Status__c = \'Active\' AND Block_Self_Enrollment__c = false ';
        if (String.isNotBlank(searchKey) && categoryFilters.size() > 0) {
            queryString += 'AND Name LIKE :searchKeyBind AND Primary_Category__c IN :categoryFiltersBind ';
        } else if (String.isNotBlank(searchKey) && categoryFilters.size() == 0) {
            queryString += 'AND Name LIKE :searchKeyBind ';
        } else if (String.isBlank(searchKey) && categoryFilters.size() > 0) {
            queryString += 'AND Primary_Category__c IN :categoryFiltersBind ';
        }

        System.debug('************** ' + hasTagFilters);
        System.debug('************** curriculumFiltersBind ' + curriculumFiltersBind);

        if(hasTagFilters && curriculumFiltersBind != null) {
            queryString += ' AND Id IN :curriculumFiltersBind';
        }

        curriculumCount = Database.countQuery(queryString, System.AccessLevel.USER_MODE);

        return curriculumCount;
    }

    /**
     * Returns the count of assigned courses based on the search key and category filters.
     * 
     * @param searchKey The search key to filter the course names.
     * @param categoryFilters The list of category filters to filter the course primary categories.
     * @return The count of assigned courses.
     */
    private static Integer getAssignedCourseCount(String searchKey, List<String> categoryFilters, Boolean hasTagFilters, List<String> courseFilteredId) {
        String searchKeyBind = '%' + String.escapeSingleQuotes(searchKey) + '%';
        List<String> categoryFiltersBind = categoryFilters;
        Integer assignedCourseCount = 0;
        // List<String> courseFiltersBind = filteredContentIds.get('Course__c');

        String queryString = 'SELECT COUNT() FROM Assigned_Course__c WHERE Learner_Profile__c = :learnerProfileId AND Completed__c = true AND Assigned_Curriculum__c = null AND Inactive__c = false ';
        if (String.isNotBlank(searchKey) && categoryFilters.size() > 0) {
            queryString += 'AND Course__r.Name LIKE :searchKeyBind AND Course__r.Primary_Category__c IN :categoryFiltersBind ';
        } else if (String.isNotBlank(searchKey) && categoryFilters.size() == 0) {
            queryString += 'AND Course__r.Name LIKE :searchKeyBind ';
        } else if (String.isBlank(searchKey) && categoryFilters.size() > 0) {
            queryString += 'AND Course__r.Primary_Category__c IN :categoryFiltersBind ';
        } else if(hasTagFilters) {
            queryString += 'AND Course__c IN :courseFilteredId ';
        }

        assignedCourseCount = Database.countQuery(queryString, System.AccessLevel.USER_MODE);

        return assignedCourseCount;
    }

    /**
     * Returns the count of assigned curriculums based on the search key and category filters.
     * 
     * @param searchKey The search key to filter the curriculums by name.
     * @param categoryFilters The list of category filters to filter the curriculums by primary category.
     * @return The count of assigned curriculums.
     */
    private static Integer getAssignedCurriculumCount(String searchKey, List<String> categoryFilters, Boolean hasTagFilters, List<String> curriculumFilteredId) {
        String searchKeyBind = '%' + String.escapeSingleQuotes(searchKey) + '%';
        List<String> categoryFiltersBind = categoryFilters;
        Integer assignedCurriculumCount = 0;
        
        String queryString = 'SELECT COUNT() FROM Assigned_Curriculum__c WHERE Learner_Profile__c = :learnerProfileId AND Completed__c = true AND Inactive__c = false ';
        if (String.isNotBlank(searchKey) && categoryFilters.size() > 0) {
            queryString += 'AND Curriculum__r.Name LIKE :searchKeyBind AND Curriculum__r.Primary_Category__c IN :categoryFiltersBind ';
        } else if (String.isNotBlank(searchKey) && categoryFilters.size() == 0) {
            queryString += 'AND Curriculum__r.Name LIKE :searchKeyBind ';
        } else if (String.isBlank(searchKey) && categoryFilters.size() > 0) {
            queryString += 'AND Curriculum__r.Primary_Category__c IN :categoryFiltersBind ';
        } else if(hasTagFilters) {
            queryString += 'AND Curriculum__c IN :curriculumFilteredId ';
        }      

        assignedCurriculumCount = Database.countQuery(queryString, System.AccessLevel.USER_MODE);

        return assignedCurriculumCount;
    }

   private static Integer getAssignmentCount(String searchKey, List<String> categoryFilters, Boolean hasTagFilters, List<String> assetFilteredId) {
        String searchKeyBind = '%' + String.escapeSingleQuotes(searchKey) + '%';
        List<String> categoryFiltersBind = categoryFilters;
        Integer assignmentCount = 0;

        String queryString = 'SELECT COUNT() FROM Asset__C WHERE';

        if (searchKey != null && searchKey != '') {
            queryString += ' Name LIKE :searchKeyBind AND';
        }

        if(hasTagFilters) {
            queryString += ' Id IN (SELECT Asset__c FROM Assignment__c WHERE Asset__c In :assetFilteredId AND Learner_Profile__c =: learnerProfileId AND Completed__c = true AND Assigned_Course__c = null AND Assigned_Curriculum__c = null AND Inactive__c = false)';
        } else {
            queryString += ' Id IN (SELECT Asset__c FROM Assignment__c WHERE Learner_Profile__c =: learnerProfileId AND Completed__c = true AND Assigned_Course__c = null AND Assigned_Curriculum__c = null)';
        }
        

        if (categoryFilters.size() > 0) {
            queryString += ' AND Primary_Category__c IN :categoryFiltersBind';
        }

        assignmentCount = Database.countQuery(queryString, System.AccessLevel.USER_MODE);

        return assignmentCount;
    }

    /**
     * Retrieves a list of assigned courses based on the provided filters.
     * 
     * @param filteredCourseIds A set of course IDs to filter the results by.
     * @param onlyCompleted Specifies whether to only include completed courses in the results.
     * @param searchKey The search keyword to filter the course names by.
     * @param categoryFilters A list of category filters to apply to the results.
     * @return A list of assigned courses matching the provided filters.
     */
    private static List<Object> getAssignedCourses(Set<Id> filteredCourseIds, Boolean onlyCompleted, String searchKey, List<String> categoryFilters, Map<String, Integer> offsets, Boolean hasTagFilters, List<String> courseFilteredId) {
        List<Object> assignedCourses = new List<Object>();
        
        List<Learner_Profile__c> lps = [SELECT Id, Name, Title__c, User__c
                                            FROM Learner_Profile__c
                                            WHERE User__c =: UserInfo.getUserId()
                                            AND Status__c = 'Active'
                                            WITH USER_MODE];

        if (!lps.isEmpty()) {
            Id lpId = lps[0].Id;
            String queryString = 'SELECT Id, Course__c, Due_Date__c, Number_Of_Assets__c, Number_of_Completed_Required_Assets__c, Number_of_Required_Assets__c, Number_of_Required_Electives__c, Number_of_Completed_Electives__c, CreatedDate, Course__r.Name, Course__r.Description__c, Time_Estimate_Minutes__c, Time_Estimate__c, Completed__c, Completion_Date__c, Content_Distribution_Organization__c, Assigned_Learning__r.OU_Leader__r.Name, Self_Assigned__c, Course__r.Block_Self_Enrollment__c, Course__r.Block_Unenrollment__c, Assigned_Curriculum__c FROM Assigned_Course__c WHERE Learner_Profile__c =: lpId AND Inactive__c = false ';
            if (!filteredCourseIds.isEmpty()) {
                queryString += 'AND Course__c IN : filteredCourseIds ';
            } else if(hasTagFilters) {
                queryString += 'AND Course__c IN : courseFilteredId ';
            }

            if (String.isNotBlank(searchKey)) {
                queryString += 'AND Course__r.Name LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\' ';
            }
            if (onlyCompleted) {
                queryString += 'AND Completed__c = true AND Assigned_Curriculum__c = null ';
            }
            if (!categoryFilters.isEmpty()) {
                queryString += 'AND Course__r.Primary_Category__c IN :categoryFilters ';
            }
            queryString += 'WITH USER_MODE ORDER BY CreatedDate DESC';

            // TODO - Add offset.
            if (offsets.containsKey('courseOffset')) {
                queryString += ' OFFSET ' + offsets.get('courseOffset');
            }
                                        
            for (Assigned_Course__c ac : Database.query(queryString, System.AccessLevel.USER_MODE)) {
                Map<String,Object> assignedCourseMap = learningItemDetail.formatLearningItem(ac);
                assignedCourseMap.put('type', 'Assigned_Course__c');
                assignedCourses.add(assignedCourseMap);
            }

            // System debug each of the returned Assigned_Course__c
            // for (Object ac : assignedCourses) {
            //     System.debug(ac);
            // }

            return assignedCourses;
        } else {
            return new List<Assigned_Course__c>();
        }
    }

    /**
     * Retrieves the assigned curriculums for the current user.
     * 
     * @param filteredCurriculumIds A set of curriculum IDs to filter the results by.
     * @param onlyCompleted A boolean value indicating whether to only retrieve completed curriculums.
     * @param searchKey A search key to filter the results by curriculum name.
     * @param categoryFilters A list of category filters to filter the results by primary category.
     * @return A list of assigned curriculums as objects.
     */
    private static List<Object> getAssignedCurriculum(Set<Id> filteredCurriculumIds, Boolean onlyCompleted, String searchKey, List<String> categoryFilters, Map<String, Integer> offsets, Boolean hasTagFilters, List<String> curriculumfilteredId) {
        List<Object> assignedCurriculums = new List<Object>();
        
        List<Learner_Profile__c> lps = [SELECT Id, Name, Title__c, User__c
                                            FROM Learner_Profile__c
                                            WHERE User__c =: UserInfo.getUserId()
                                            AND Status__c = 'Active'
                                            WITH USER_MODE];
                                        
        if (!lps.isEmpty()) {
            Id lpId = lps[0].Id;

            String queryString = 'SELECT Id, Curriculum__c, Due_Date__c, Number_Of_Courses__c, Number_of_Completed_Required_Courses__c, Number_of_Required_Courses__c, Number_of_Required_Electives__c, Number_of_Completed_Electives__c, CreatedDate, Curriculum__r.Name, Curriculum__r.Description__c, Time_Estimate_Minutes__c, Time_Estimate__c, Completed__c, Completion_Date__c, Content_Distribution_Organization__c, Assigned_Learning__r.OU_Leader__r.Name, Self_Assigned__c, Curriculum__r.Block_Self_Enrollment__c, Curriculum__r.Block_Unenrollment__c FROM Assigned_Curriculum__c WHERE Learner_Profile__c =: lpId AND Inactive__c = false ';
            if (!filteredCurriculumIds.isEmpty()) {
                queryString += 'AND Curriculum__c IN : filteredCurriculumIds ';
            } else if(hasTagFilters) {
                queryString += 'AND Curriculum__c IN : curriculumfilteredId ';
            }
            if (String.isNotBlank(searchKey)) {
                queryString += 'AND Curriculum__r.Name LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\' ';
            }
            if (onlyCompleted) {
                queryString += 'AND Completed__c = true ';
            }
            if (!categoryFilters.isEmpty()) {
                queryString += 'AND Curriculum__r.Primary_Category__c IN :categoryFilters ';
            }
            queryString += 'WITH USER_MODE ORDER BY CreatedDate DESC';

            // TODO - Add offset.
            if (offsets.containsKey('curriculumOffset')) {
                queryString += ' OFFSET ' + offsets.get('curriculumOffset');
            }
                                 
            List<Map<String,Object>> formattedAssignedCurriculums = new List<Map<String,Object>>();

            for (Assigned_Curriculum__c ac : Database.query(queryString, System.AccessLevel.USER_MODE)) {
                Map<String,Object> assignedCurriculumMap = learningItemDetail.formatLearningItem(ac);
                assignedCurriculumMap.put('type', 'Assigned_Curriculum__c');
                assignedCurriculums.add(assignedCurriculumMap);
            }

            return assignedCurriculums;
        } else {
            return new List<Assigned_Curriculum__c>();
        }
    }

    public static List<Object> getAssignments(Set<Id> filteredAssetIds, Boolean onlyCompleted, String searchKey, List<String> categoryFilters, Boolean hasTagFilters, List<String> assetFilteredId) {
        List<Object> assignments = new List<Object>();

        List<Learner_Profile__c> lps = [SELECT Id, Name, Title__c, User__c
                                            FROM Learner_Profile__c
                                            WHERE User__c =: UserInfo.getUserId()
                                            AND Status__c = 'Active'
                                            WITH USER_MODE];
                                        
        if (!lps.isEmpty()) {
            Id lpId = lps[0].Id;

            String queryString = 'SELECT Id, Asset__c, Due_Date__c, CreatedDate, Asset__r.Name, Asset__r.Description__c, Time_Estimate_Minutes__c, Time_Estimate__c, Completed__c, Content_Distribution_Organization__c, Assigned_Learning__r.OU_Leader__r.Name, Self_Assigned__c, Asset__r.Block_Self_Enrollment__c, Asset__r.Block_Unenrollment__c, Asset__r.RecordType.DeveloperName FROM Assignment__c WHERE Learner_Profile__c =: lpId AND Inactive__c = false ';
            if (!filteredAssetIds.isEmpty()) {
                queryString += 'AND Asset__c IN : filteredAssetIds ';
            } else if(hasTagFilters) {
                queryString += 'AND Asset__c IN : assetFilteredId ';
            }
            if (String.isNotBlank(searchKey)) {
                queryString += 'AND Asset__r.Name LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\' ';
            }
            if (onlyCompleted) {
                queryString += 'AND Completed__c = true ';
            }
            if (!categoryFilters.isEmpty()) {
                queryString += 'AND Asset__r.Primary_Category__c IN :categoryFilters ';
            }
            queryString += 'WITH USER_MODE';

            // TODO - Add offset.
                                 
            List<Map<String,Object>> formattedAssignments = new List<Map<String,Object>>();

            for (Assignment__c assignment : Database.query(queryString, System.AccessLevel.USER_MODE)) {
                Map<String,Object> assignmentMap = learningItemDetail.formatLearningItem(assignment);
                assignmentMap.put('type', 'Assignment__c');
                assignments.add(assignmentMap);
            }

            return assignments;
        } else {
            return new List<Assignment__c>();
        }

    }
    //changed to assignments, but no time to rename everything
    private static List<Object> getCompletedAssets(String searchKey, Map<String, Integer> offsets, Boolean hasTagFilters, List<String> assetFilteredId) {
        List<Object> completedAssets = new List<Object>();

        List<Learner_Profile__c> lps = [SELECT Id, Name, Title__c, User__c
                                            FROM Learner_Profile__c
                                            WHERE User__c =: UserInfo.getUserId()
                                            AND Status__c = 'Active'
                                            WITH USER_MODE];
                                        
        if (!lps.isEmpty()) {
            Id lpId = lps[0].Id;

            List<String> fields = new List<String>{'Id', 'CreatedDate', 'Completion_Date__c', 'Asset__c', 'Asset__r.RecordType.DeveloperName', 'Due_Date__c', 'Asset__r.Name', 'Asset__r.Description__c', 
                                                   'Self_Assigned__c', 'Content_Distribution_Organization__c', 'Assigned_Learning__r.OU_Leader__r.Name', 'Asset__r.Assessment_Type__c', 'Asset__r.Mandatory_Session_Count__c', 
                                                   'Time_Estimate_Minutes__c', 'Time_Estimate__c', 'Completed__c', 'Recommended_Learning__r.Content_Distribution_Organization__c', 'Mandatory_Session_Count__c'};

            /*
                SELECT fields
                FROM Assignment__c 
                WHERE Learner_Profile__c =: lpId
                AND Completed__c = true
                AND Assigned_Course__c = null
                AND Assigned_Curriculum__c = null
                AND Asset__c IN :assetFilteredId //conditonal
                AND Asset__r.Name LIKE :searchKey //conditonal
                WITH USER_MODE
                ORDER BY CreatedDate DESC
                OFFSET :assetOffset //conditional
            */

            String queryString = 'SELECT ' + String.join(fields, ',') +
                                 ' FROM Assignment__c' +
                                 ' WHERE Learner_Profile__c =: lpId' +  
                                 ' AND Completed__c = true' +
                                 ' AND Assigned_Course__c = null' +
                                 ' AND Assigned_Curriculum__c = null';

            if (String.isNotBlank(searchKey)) {
                queryString += ' AND Asset__r.Name LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\' AND';
            }

            if(hasTagFilters) {
                queryString += ' AND Asset__c IN :assetFilteredId';
            }

            queryString += ' WITH USER_MODE' +
                           ' ORDER BY CreatedDate DESC';

            if (offsets.containsKey('assignmentOffset')) {
                queryString += ' OFFSET ' + offsets.get('assignmentOffset');
            }

            // String queryString = 'SELECT Id, Name, CreatedDate, Description__c, Assessment_Type__c, RecordType.DeveloperName, Time_Estimate__c, (SELECT Completion_Date__c FROM Assignments__r) FROM Asset__c WHERE';

            // if (String.isNotBlank(searchKey)) {
            //     queryString += ' Name LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\' AND';
            // }
            // if(hasTagFilters) {
            //     queryString += ' Id IN (SELECT Asset__c FROM Assignment__c WHERE Asset__c In :assetFilteredId AND Learner_Profile__c =: lpId AND Completed__c = true AND Assigned_Course__c = null AND Assigned_Curriculum__c = null) WITH USER_MODE ORDER BY CreatedDate DESC';
            // } else {
            //     queryString += ' Id IN (SELECT Asset__c FROM Assignment__c WHERE Learner_Profile__c =: lpId AND Completed__c = true AND Assigned_Course__c = null AND Assigned_Curriculum__c = null) WITH USER_MODE ORDER BY CreatedDate DESC';
            // }
            

            // // TODO - Add offset.
            // if (offsets.containsKey('assetOffset')) {
            //     queryString += ' OFFSET ' + offsets.get('assetOffset');
            // }

            // for (Assignment__c assignment : Database.query(queryString, System.AccessLevel.USER_MODE)) {
            //     Map<String,Object> assignmentMap = learningItemDetail.formatLearningItem(assignment);
            //     assignmentMap.put('type', 'Assignment__c');
            //     assignments.add(assignmentMap);
            // }
            
            for (Assignment__c assignment : Database.query(queryString, System.AccessLevel.USER_MODE)) {
                Map<String,Object> assignmentMap = learningItemDetail.formatLearningItem(assignment);
                assignmentMap.put('type', 'Assignment__c');
                completedAssets.add(assignmentMap);
            }

            return completedAssets;
        } else {
            return new List<Object>();
        }
    }

    /**
     * Checks the offsets in a list and throws a CustomException if any offset is greater than 2000.
     * 
     * @param offsets The list of offsets to be checked.
     * @throws CustomException If any offset is greater than 2000.
     */
    private static void checkOffSets(List<Integer> offsets) {
        for (Integer offset : offsets) {
            if (offSet > 2000) {
                throw new CustomException('You cannot retrieve more than 2000 records. Please narrow your search criteria.');
            }
        }
    }


    @AuraEnabled
    public static ResponseData filterOptionsByContentTag(String type, String eventId) {
        ResponseData rd = new ResponseData();
        
        Map<String, String> languageMap = new Map<String, String>();
        Map<String, FilterOptions> language = new Map<String, FilterOptions>();
        Map<String, FilterOptions> role = new Map<String, FilterOptions>();
        Map<String, FilterOptions> product = new Map<String, FilterOptions>();
        Map<String, FilterOptions> industry = new Map<String, FilterOptions>();
        Map<String, FilterOptions> sType = new Map<String, FilterOptions>();
        Map<String, FilterOptions> region = new Map<String, FilterOptions>();
        Map<String, FilterOptions> location = new Map<String, FilterOptions>();
        Map<String, FilterOptions> proficiencyLevel = new Map<String, FilterOptions>();
        
        List<String> sessionIds = new List<String>();
        
        
        List<Schema.PicklistEntry> pe = Schema.SObjectType.Content_Tag__c.fields.Language__c.getPicklistValues();
        for(Schema.PicklistEntry ple : pe){
            languageMap.put(ple.getValue(), ple.getLabel());            
        }

        // String queryStr = 'SELECT Id, Asset__c, Asset__r.Status__c, Curriculum__c, Curriculum__r.Status__c, Session__c, Session__r.Status__c, Role__r.Name, Course__c, Course__r.Status__c, Industry__r.Name, Product__r.Name, Language__c, Proficiency_Level__c FROM Content_Tag__c WHERE ';
        String queryStr = 'SELECT Id, Asset__r.recordTypeId, Asset__c, Asset__r.Status__c, Curriculum__c, Curriculum__r.Status__c, Session__c, Session__r.Status__c, Role__r.Name, Course__c, Course__r.Status__c, Industry__r.Name, Product__r.Name, Language__c, Proficiency_Level__c FROM Content_Tag__c WHERE ';
        if(type == 'catalog') {
            queryStr += 'Session__c = NULL AND (Industry__c != NULL OR Product__c != NULL OR Language__c != NULL OR Role__c != Null OR Proficiency_Level__c != Null)';
        } else if(type == 'session' && eventId != null) {
            for(Session__c session : [SELECT Id, Start_Date__c, Session_Type__c, Region__c, 
                                        Office_Location__r.City__c, Location__City__s  
                                        FROM Session__c 
                                        WHERE Asset__c = :eventId 
                                        AND Status__c = 'Active'
                                        AND Start_Date__c >= TODAY
                                        ORDER BY Start_Date__c ASC]) {
                sessionIds.add(session.Id);
                if(String.isNotEmpty(session.Session_Type__c)) {
                    sType.put(session.Session_Type__c, new FilterOptions(session.Session_Type__c, 'checkbox', (Object)false, true));
                }
                if(String.isNotEmpty(session.Region__c)) {
                    region.put(session.Region__c, new FilterOptions(session.Region__c, 'checkbox', (Object)false, true));
                }
                
                // using new-location field
                // if(session.Office_Location__r != null && String.isNotEmpty(session.Office_Location__r.City__c)) {
                //     location.put(session.Office_Location__r.City__c, new FilterOptions(session.Office_Location__r.City__c, 'checkbox', (Object)false, true));
                // } else if(String.isNotEmpty(session.Location__City__s)){
                //     location.put(session.Location__City__s, new FilterOptions(session.Location__City__s, 'checkbox', (Object)false, true));
                // }
                
                if(String.isNotEmpty(session.Location__City__s)){
                    location.put(session.Location__City__s, new FilterOptions(session.Location__City__s, 'checkbox', (Object)false, true));
                }
            }
            queryStr += 'Session__c In :sessionIds AND ';
            queryStr += '(Industry__c != NULL OR Product__c != NULL OR Language__c != NULL OR Role__c != Null)';
        }

        for (Content_Tag__c contentTag : Database.query(queryStr, System.AccessLevel.USER_MODE)) {            
            Boolean isLearningActive = false;
            if(type == 'catalog')  {
                isLearningActive = contentTag.Asset__c != null && contentTag.Asset__r.Status__c == 'Active' 
                                    && contentTag.Asset__r.recordTypeId == eventRecordTypeId ? true
                                    : contentTag.Course__c != null && contentTag.Course__r.Status__c == 'Active' ? true 
                                    : contentTag.Curriculum__c != null && contentTag.Curriculum__r.Status__c == 'Active' ? true 
                                    : false;
            } else {
                isLearningActive = contentTag.Asset__c != null && contentTag.Asset__r.Status__c == 'Active' ? true
                                    : contentTag.Course__c != null && contentTag.Course__r.Status__c == 'Active' ? true 
                                    : contentTag.Curriculum__c != null && contentTag.Curriculum__r.Status__c == 'Active' ? true 
                                    : contentTag.Session__c != null && contentTag.Session__r.Status__c == 'Active' ? true
                                    : false;
            }

            if(!isLearningActive) {
                continue;
            }

            if(String.isNotBlank(contentTag.Language__c)) {
                if(!language.containsKey(languageMap.get(contentTag.Language__c))) {
                    language.put(languageMap.get(contentTag.Language__c), new FilterOptions(languageMap.get(contentTag.Language__c), 'checkbox', (Object)false, true)); 
                }                          
            }
            if(String.isNotBlank(contentTag.Role__r.Name)) {
                if(!role.containsKey(contentTag.Role__r.Name)) {
                    role.put(contentTag.Role__r.Name, new FilterOptions(contentTag.Role__r.Name, 'checkbox', (Object)false, true));
                }
            }
            if(String.isNotBlank(contentTag.Industry__r.Name)) {
                if(!industry.containsKey(contentTag.Industry__r.Name)) {
                    industry.put(contentTag.Industry__r.Name, new FilterOptions(contentTag.Industry__r.Name, 'checkbox', (Object)false, true));
                }
            }
            if(String.isNotBlank(contentTag.Product__r.Name)) {
                if(!product.containsKey(contentTag.Product__r.Name)) {
                    product.put(contentTag.Product__r.Name, new FilterOptions(contentTag.Product__r.Name, 'checkbox', (Object)false, true));
                }
            }
            if(String.isNotBlank(contentTag.Proficiency_Level__c)) {
                if(!proficiencyLevel.containsKey(contentTag.Proficiency_Level__c)) {
                    proficiencyLevel.put(contentTag.Proficiency_Level__c, new FilterOptions(contentTag.Proficiency_Level__c, 'checkbox', (Object)false, true));
                }
            }
        }

        Map<String, FilterOptions> contentType = new Map<String, FilterOptions>{
            // 'Asset' => new FilterOptions('Asset', 'checkbox', (Object)false, true),
            'Course' => new FilterOptions('Course', 'checkbox', (Object)false, true),
            'Curriculum' => new FilterOptions('Curriculum', 'checkbox', (Object)false, true),
            'Events' => new FilterOptions('Events', 'checkbox', (Object)false, true)
                        
            // 'Recommendation' => new FilterOptions('Recommendation', 'checkbox', (Object)false, true)            
        };

        Map<String, FilterOptions> dateRange = new Map<String, FilterOptions> {
            'Start Date' => new FilterOptions('Start Date', 'date', null, true),
            'End Date' => new FilterOptions('End Date', 'date', null, true)
        };

        List<Map<String, Object>> filterData = new List<Map<String, Object>>();
        
        if(type == 'catalog') {
            filterData.add(new Map<String, Object> {
                'section' => (Object)'Content Type',
                'FilterOptions' => (Object)contentType.values(),
                'selectedCount' => getSelectedOptionCount((List<Object>)contentType.values())
            });
        }
        
        if(type == 'session') {
            filterData.add(new Map<String, Object> {
                'section' => (Object)'Date Range',
                'FilterOptions' => (Object)dateRange.values(),
                'selectedCount' => 0 
            });
        }

        if(!industry.isEmpty()) {
            filterData.add(new Map<String, Object> {
                'section' => (Object)'Industry',
                'searchable' => (Object)true,
                'FilterOptions' => sortByLabel(industry.values(), 'label'),
                'searchedText' => '',
                'selectedCount' => getSelectedOptionCount((List<Object>)industry.values()),
                'placeholder' => 'Search by name...'
            });
        }
        
        if(!language.isEmpty()) {
            filterData.add(new Map<String, Object> {
                'section' => (Object)'Language',
                'FilterOptions' => sortByLabel(language.values(), 'label'),
                'selectedCount' => getSelectedOptionCount((List<Object>)language.values())
            });
        }

        if(type == 'session' && !location.isEmpty()) {
            filterData.add(new Map<String, Object> {
                'section' => (Object)'Location',
                'searchable' => (Object)true,
                'FilterOptions' => sortByLabel(location.values(), 'label'),
                'searchedText' => '',
                'selectedCount' => getSelectedOptionCount((List<Object>)location.values()),
                'placeholder' => 'Search by city...'
            });
        }

        if(!product.isEmpty()) {
            filterData.add(new Map<String, Object> {
                'section' => (Object)'Product',
                'searchable' => (Object)true,
                'FilterOptions' => sortByLabel(product.values(), 'label'),
                'searchedText' => '',
                'selectedCount' => getSelectedOptionCount((List<Object>)product.values()),
                'placeholder' => 'Search by name...'
            });
        }

        if(type == 'session' && !region.isEmpty()) {
            filterData.add(new Map<String, Object> {
                'section' => (Object)'Region',
                'FilterOptions' => sortByLabel(region.values(), 'label'),
                'selectedCount' => getSelectedOptionCount((List<Object>)region.values())
            });
        }

        if(!proficiencyLevel.isEmpty()) {
            filterData.add(new Map<String, Object> {
                'section' => (Object)'Proficiency Level',
                'FilterOptions' => sortByLabel(proficiencyLevel.values(), 'label'),
                'selectedCount' => getSelectedOptionCount((List<Object>)proficiencyLevel.values())
            });
        }

        if(!role.isEmpty()) {
            filterData.add(new Map<String, Object> {
                'section' => (Object)'Role',
                'FilterOptions' => sortByLabel(role.values(), 'label'),
                'selectedCount' => getSelectedOptionCount((List<Object>)role.values())
            });
        }        
        
        if(type == 'session' && !sType.isEmpty()) {
            filterData.add(new Map<String, Object> {
                'section' => (Object)'Type',
                'FilterOptions' => sortByLabel(sType.values(), 'label'),
                'selectedCount' => getSelectedOptionCount((List<Object>)sType.values())
            });
        }
        Integer recomCount = [SELECT COUNT() FROM Recommended_Learning__c 
                                WHERE Learner_Profile__c = :learnerProfileId 
                                AND Status__c = 'Active'
                                AND (Course__r.Status__c = 'Active' OR Asset__r.Status__c = 'Active' OR Curriculum__r.Status__c = 'Active')
                                WITH USER_MODE];
        rd.put('filterData', filterData);
        rd.put('showRecommendationToggle', recomCount > 0 ? true : false);
            
        return rd;
    } 
    
    public static Integer getSelectedOptionCount(List<Object> options) {
        Integer count = 0;
        for(Object obj : options) {
            Object checked = ((FilterOptions)obj).value;
            if((Boolean)checked) {
                count++;
            }
        }
        return count;
    }

    public static List<Object> sortByLabel(List<FilterOptions> tagOptions, String sortField) {
        List<Object> objList = (List<Object>)JSON.deserializeUntyped((String)JSON.serialize(tagOptions));
        List<Object> filterList = Utilities.sortByField(objList, sortField, false);
        return filterList; // (List<Object>)JSON.deserialize((String)JSON.serialize(filterList), List<FilterOptions>.class);
    }

    // public static Map<String, List<String>> getRecommendedLearningByType(Map<String, List<String>> filteredContentId){
    //     boolean hasRecommendedEvent = filteredContentId.get('ContentType').contains('Asset__c');
    //     Map<String, List<String>> recomLearnign = new Map<String, List<String>> {
    //         'ContentType' => new List<String> {'Asset__c', 'Course__c', 'Curriculum__c'},
    //         'Asset__c' => new List<String>(),
    //         'Course__c' => new List<String>(),
    //         'Curriculum__c' => new List<String>()
    //     };
    //     List<String> recomId = filteredContentId.get('Recommendation__c');
    //     if(recomId.isEmpty()) {
    //         return recomLearnign;
    //     } 

    //     String query = 'Select Id, Asset__c, Asset__r.recordTypeId, Course__c, Curriculum__c from Recommended_Learning__c where Learner_Profile__c = :learnerProfileId';
    //     query += ' and Id In :recomId and Status__c = \'Active\'';
        

    //     for(Recommended_Learning__c rl : Database.query(query, System.AccessLevel.USER_MODE)) {
    //         if(rl.Asset__c != null && !hasRecommendedEvent) {
    //             recomLearnign.get('Asset__c').add(rl.Asset__c);
    //         } else if(rl.Asset__c != null && hasRecommendedEvent && rl.Asset__r.recordTypeId == eventRecordTypeId) {
    //             recomLearnign.get('Asset__c').add(rl.Asset__c);
    //         } else if(rl.Course__c != null) {
    //             recomLearnign.get('Course__c').add(rl.Course__c);
    //         } else if(rl.Curriculum__c != null) {
    //             recomLearnign.get('Curriculum__c').add(rl.Curriculum__c);
    //         }
    //     }
    //     return recomLearnign;
    // }

    

    /**
     * Parameters and helper methods for the Catalog.getFilteredData method.
     */
    public class CatalogPayload {
        @AuraEnabled 
        public String searchKey { get; set; }

        @AuraEnabled 
        public List<String> typeFilters { 
            get; 
            set {
                typeFilters = new List<String>();

                for (String type : value) {
                    typeFilters.add(String.escapeSingleQuotes(type));
                }
            
            }
        }

        @AuraEnabled 
        public List<String> categoryFilters { get;
            set {
                categoryFilters = new List<String>();

                for (String category : value) {
                    categoryFilters.add(String.escapeSingleQuotes(category));
                }
            }
        }

        @AuraEnabled
        public Integer queryLimit { get; set; }

        @AuraEnabled 
        public Map<String, Integer> offsets { 
            get;
            set {
                offsets = new Map<String, Integer>();

                for (String key : value.keySet()) {
                    offsets.put(String.escapeSingleQuotes(key), value.get(key));
                }
            }
        }

        @AuraEnabled
        public Map<String, List<String>> filteredContentIds {
            get;
            set {
                filteredContentIds = new Map<String, List<String>>();
                for(String key : value.keySet()) {
                    filteredContentIds.put(key, value.get(key));
                }
            }
        }

        @AuraEnabled
        public Boolean applyFilters { get; set; }

        @AuraEnabled
        public Boolean hasTagFilters { get; set; }

        @AuraEnabled
        public Integer existingCount { get; set; }

        @AuraEnabled
        public Boolean completedRecordsOnly { get; set; }

        public Boolean onlyRecommended { get { 
            return this.typeFilters != null && this.typeFilters.contains('Recommendations'); 
        } }
        public Boolean queryAllTypes { get { return this.typeFilters.isEmpty() || (this.onlyRecommended && this.typeFilters.size() == 1); } }
        public Boolean getOnlyEventAssets { get { return this.typeFilters.contains('Event'); } }
        public Boolean loadingMore { 
            get {
                for (Integer offset : this.offsets.values()) {
                    if (offset > 0) {
                        return true;
                    }
                }

                return false;
            }
        }
        
        public Boolean noFiltersSelected() {
            return String.isEmpty(this.searchKey) && this.typeFilters.isEmpty() && this.categoryFilters.isEmpty() && !this.completedRecordsOnly && !this.applyFilters;
        }

        public String getRecommendationQueryString(Boolean hasTagFilters/*, Map<String, List<String>> filteredContentIds*/) {
            String query = 'SELECT Id, Course__c, Asset__c, Curriculum__c, Session__c FROM Recommended_Learning__c';
            query += this.getRecommendationQueryFilters(hasTagFilters);
            query += ' ORDER BY SEED_Recommended__c DESC, CreatedDate DESC';

            if (this.queryLimit != null) {
                query += ' LIMIT ' + this.queryLimit;
            }

            if (this.offsets.containsKey('recommendationOffset')) {
                query += ' OFFSET ' + this.offsets.get('recommendationOffset');
            }
            return query;
        }

        public String getRecommendationQueryFilters(Boolean hasTagFilters/*Map<String, List<String>> filteredContentIds*/) {
            String queryFilters = ' WHERE Learner_Profile__c = :learnerProfileId AND Status__c = \'Active\'';//' AND (';
            // List<Id> recommendationList = filteredContentIds.get('Recommendation__c');
            if(hasTagFilters) {
                queryFilters += ' AND Id IN :recommendationBind';
            }
            queryFilters += ' AND (';
            for (String type : validCatalogObjTypes) {
                String convertedType = (type.equals('Asset__c') ? 'Event' : type).removeEnd('__c');
                String relationType = type.removeEnd('c') + 'r';

                if (!(this.typeFilters.contains(convertedType) || this.queryAllTypes)) {
                    continue;
                }

                queryFilters += ' (' + relationType + '.Status__c = \'Active\'';

                if (type == 'Asset__c' && this.getOnlyEventAssets) {
                    queryFilters += ' AND ' + relationType + '.recordTypeId = :eventRecordTypeId';
                }

                if (String.isNotBlank(this.searchKey)) {
                    queryFilters += ' AND ' + relationType + '.Name LIKE \'%' + String.escapeSingleQuotes(this.searchKey) + '%\'';
                }

                if (!this.categoryFilters.isEmpty()) {
                    queryFilters += ' AND ' + relationType + '.Primary_Category__c IN :categoryFiltersBind';
                }

                queryFilters += ') OR';
            }

            queryFilters = queryFilters.removeEnd(' OR');
            queryFilters += ')';
            queryFilters = queryFilters.removeEnd(' AND ()');

            return queryFilters;
        }        
    }

    /**
     * Wrapper Class for displaying a catalog bucket
     */
    public class CatalogBucket {
        @AuraEnabled
        public String dataType { get; set; }

        @AuraEnabled
        public String title { get; set; }

        @AuraEnabled
        public String label { get; set; }

        @AuraEnabled
        public List<Object> items { get; set; }

        @AuraEnabled
        public Integer itemCount { get; set; }

        @AuraEnabled
        public Boolean isFiltered { get; set; }

        @AuraEnabled
        public Boolean hasMore { get; set; }

        public CatalogBucket() {
            this.items = new List<Object>();
            this.hasMore = false;
        }

        public CatalogBucket(String type) {
            this();
            this.dataType = type.equals('Curriculum') ? 'Curricula' : type;
            this.title = type.equals('Curriculum') ? 'Curricula' : type + 's';
            this.label = 'View All ' + this.title;
            this.isFiltered = this.dataType.equals('Result');
        }
    }

    public class FilterOptions {
        @AuraEnabled
        public String label { get; set; }

        @AuraEnabled
        public String inputType { get; set; }

        @AuraEnabled
        public Object value { get; set; }

        @AuraEnabled
        public Boolean visible { get; set; }

        public FilterOptions(String label, String inputType, Object value, Boolean visible) {
            this.label = label;
            this.inputType = inputType;
            this.value = value;
            this.visible = visible;           
        }
    }
}