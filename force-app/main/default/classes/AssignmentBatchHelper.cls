public with sharing class AssignmentBatchHelper {
    public static List<Audience_Member__c> members;
    public static Set<String> learnerIds;
    public static Set<String> audienceIds;
    public static Map<String, List<Learner_Profile__c>> learnersByAudienceId;
    public static Map<String, Learner_Profile__c> managerLPsByUserId;
    public static Map<String, List<Assigned_Learning__c>> alsByAudienceId;
    public static Map<String, String> alIdByLearningId; // ta by Solo Learning Assets or Learning Exp Id;
    public static Map<String, Curriculum__c> curricToAssignById;
    public static Map<String, Course__c> courseToAssignById;
    public static Map<String, Asset__c> assetToAssignById;
    public static Set<String> skillAssessmentAssetIds;
    public static Set<String> skillAssessmentAssignmentIds;
    //Solo Assigned Learning Assets
    public static Map<String, Assignment__c> existingSoloAssignmentsByLPAndLAId; //LP.Id|A.Id
    public static Map<String, Assigned_Course__c> existingAssignedCourseByLPAndCourseId; //LP.Id|ALE.Id
    public static Map<String, Assigned_Curriculum__c> existingAssignedCurricByLPAndCurricId; //LP.Id|ALE.Id
    public static Set<String> assignedItems; //LP|Id used to prevent duplicates if multiple audiences assign the ssame thing
    public static List<Assigned_Curriculum__c> aCurricsToUpsert;
    public static List<Assigned_Course__c> aCoursesToUpsert;
    public static List<Assignment__c> assignmentsToUpsert;
    public static List<String> curricIds = new List<String>();
    public static List<String> courseIds = new List<String>();
    public static List<String> assetIds = new List<String>();

    public static Set<String> assignLearning(List<Audience_Member__c> mems){
        try {
            members = mems;
            // System.debug('**************** assignLearning ' +  members);
            initItems();
            getLearningData();
            getDuplicates();
            createAssignedRecords();
            performDML();
        } catch (Exception e){
            System.debug('**************** e ' + e.getMessage());
            System.debug('**************** e ' + e.getStackTraceString());

            insert new Integration_Error__c(Error_Message__c = e.getMessage(), Http_Response_Body__c = e.getStackTraceString(), Type__c = 'AssignmentBatchHelper');
        }

        return skillAssessmentAssignmentIds;
    }

    public static void performDML(){
        List<Integration_Error__c> errors = new List<Integration_Error__c>();
        Map<String, Set<String>> failedLearningByLearner = new Map<String, Set<String>>();
        
        if(!aCurricsToUpsert.isEmpty()){
            List<Database.UpsertResult> srs = Database.upsert(aCurricsToUpsert, false);
            
            for(Integer i = 0; i < srs.size(); i++){
                Database.UpsertResult sr = srs.get(i);
                
                if(!sr.isSuccess()){
                    Assigned_Curriculum__c failedCurric = aCurricsToUpsert.get(i);

                    if(!failedLearningByLearner.containsKey(failedCurric.Learner_Profile__c)){
                        failedLearningByLearner.put(failedCurric.Learner_Profile__c, new Set<String>());
                    }

                    failedLearningByLearner.get(failedCurric.Learner_Profile__c).add(failedCurric.Curriculum__c);
                    errors.add(createDMLError(failedCurric, sr, failedCurric.Learner_Profile__c, failedCurric.Curriculum__c));
                }
            }
        }

        List<Assigned_Course__c> cleanedACoursesToUpsert = new List<Assigned_Course__c>();
        
        for(Assigned_Course__c ac : aCoursesToUpsert){
            if(ac.Assigned_Curriculum__r != null){
                if(failedLearningByLearner.containsKey(ac.Learner_Profile__c) && failedLearningByLearner.get(ac.Learner_Profile__c).contains(ac.Assigned_Curriculum__r.Curriculum__c)){
                    continue;
                }

                ac.Assigned_Curriculum__c = ac.Assigned_Curriculum__r.Id;
                ac.Assigned_Curriculum__r = null;
            }

            cleanedACoursesToUpsert.add(ac);
        }

        if(!cleanedACoursesToUpsert.isEmpty()){
            List<Database.UpsertResult> srs = Database.upsert(cleanedACoursesToUpsert, false);
            
            for(Integer i = 0; i < srs.size(); i++){
                Database.UpsertResult sr = srs.get(i);
                
                if(!sr.isSuccess()){ 
                    Assigned_Course__c failedCourse = cleanedACoursesToUpsert.get(i);

                    if(!failedLearningByLearner.containsKey(failedCourse.Learner_Profile__c)){
                        failedLearningByLearner.put(failedCourse.Learner_Profile__c, new Set<String>());
                    }

                    failedLearningByLearner.get(failedCourse.Learner_Profile__c).add(failedCourse.Course__c);
                    errors.add(createDMLError(failedCourse, sr, failedCourse.Learner_Profile__c, failedCourse.Course__c));
                }
            }
        }

        List<Assignment__c> cleanedAssignmentsToUpsert = new List<Assignment__c>();

        for(Assignment__c assignment : assignmentsToUpsert){
            if(assignment.Assigned_Curriculum__r != null){
                if(failedLearningByLearner.containsKey(assignment.Learner_Profile__c) && failedLearningByLearner.get(assignment.Learner_Profile__c).contains(assignment.Curriculum__c)){
                    continue;
                }


                assignment.Assigned_Curriculum__c = assignment.Assigned_Curriculum__r.Id;
                assignment.Assigned_Curriculum__r = null;
            }

            if(assignment.Assigned_Course__r != null){
                if(failedLearningByLearner.containsKey(assignment.Learner_Profile__c) && failedLearningByLearner.get(assignment.Learner_Profile__c).contains(assignment.Course__c)){
                    continue;
                }

                assignment.Assigned_Course__c = assignment.Assigned_Course__r.Id;
                assignment.Assigned_Course__r = null;
            }

            cleanedAssignmentsToUpsert.add(assignment);
        }

        if(!cleanedAssignmentsToUpsert.isEmpty()){
            List<Database.UpsertResult> srs = Database.upsert(cleanedAssignmentsToUpsert, false);
            
            for(Integer i = 0; i < srs.size(); i++){
                Database.UpsertResult sr = srs.get(i);
                
                if(!sr.isSuccess()){
                    Assignment__c failedAssignment = cleanedAssignmentsToUpsert.get(i);

                    if(!failedLearningByLearner.containsKey(failedAssignment.Learner_Profile__c)){
                        failedLearningByLearner.put(failedAssignment.Learner_Profile__c, new Set<String>());
                    }

                    failedLearningByLearner.get(failedAssignment.Learner_Profile__c).add(failedAssignment.Asset__c);
                    errors.add(createDMLError(failedAssignment, sr, failedAssignment.Learner_Profile__c, failedAssignment.Asset__c));
                } else {
                    Assignment__c successfulAssignment = cleanedAssignmentsToUpsert.get(i);

                    System.debug('*************** skillAssessmentAssetIds ' + skillAssessmentAssetIds);

                    if(skillAssessmentAssetIds.contains(successfulAssignment.Asset__c)){
                        skillAssessmentAssignmentIds.add(successfulAssignment.Id);
                    }
                }
            }
        }

        if(!errors.isEmpty()){
            insert errors;
        }
    }

    private static Integration_Error__c createDMLError(sObject failedObj, Database.UpsertResult sr, Id learnerId, Id learningItem){
        String message = 'Failed to upsert ' + failedObj.getSObjectType() + ' for Learner: ' + learnerId + ' and ' + learningItem.getSObjectType() + ': ' + learningItem;
        String debug = '';

        for(Database.Error err : sr.getErrors()) {
            debug += err.getStatusCode() + ': ' + err.getMessage() + ' fields ' + err.getFields() + '\n\n';
        }

        debug += JSON.serialize(failedObj);

        return new Integration_Error__c(
            Error_Message__c = message,
            Http_Response_Body__c = debug,
            Type__c = 'AssignmentBatchHelper'
        );
    }

    // Overloaded assignedLearning to be used by front end without Audience_Members.
    @AuraEnabled
    public static ResponseData assignLearning(String userId, Object learningItem, Boolean selfAssigned, Date dueDate) {
        ResponseData rd = new ResponseData();

        try {
            Learner_Profile__c learnerProfile = getLearnerProfile(userId);
            Map<String, Object> learningItemMap = (Map<String, Object>)learningItem;
            String itemType = (String)learningItemMap.get('type');
            String recordId = (String)learningItemMap.get('Id');

            initItems();

            learnerIds.add(learnerProfile.Id);

            Learner_Profile__c managerLP = getLearnerProfile(learnerProfile.User__r.ManagerId);

            managerLPsByUserId.put(managerLP.User__c, managerLP);

            switch on itemType {
                when 'Curriculum__c' {
                    curricIds.add(recordId);
                }
                when 'Course__c' {
                    courseIds.add(recordId);
                }
                when 'Asset__c' {
                    assetIds.add(recordId);
                }
            }

            getRecordData();
            getDuplicates();

            switch on itemType {
                when 'Curriculum__c' {
                    Curriculum__c curric = curricToAssignById.get(recordId);
                    Assigned_Curriculum__c existingACurric = existingAssignedCurricByLPAndCurricId.get(learnerProfile.Id + '|' + recordId);
                    if(existingACurric == null || existingACurric.Inactive__c || existingACurric.Self_Assigned__c){
                        createAssignedCurric(learnerProfile, existingACurric, curric, dueDate, null, null, true);
                    }
                }
                when 'Course__c' {
                    Course__c course = courseToAssignById.get(recordId);
                    Assigned_Course__c existingACourse = existingAssignedCourseByLPAndCourseId.get(learnerProfile.Id + '|' + recordId);
                    
                    if(existingACourse == null || existingACourse.Inactive__c || existingACourse.Self_Assigned__c){
                        createAssignedCourse(learnerProfile, existingACourse, course, dueDate, null, true);
                    }
                }
                when 'Asset__c' {
                    Asset__c asset = assetToAssignById.get(recordId);
                    Assignment__c existingAssignment = existingSoloAssignmentsByLPAndLAId.get(learnerProfile.Id + '|' + recordId);

                    if(existingAssignment == null || existingAssignment.Inactive__c || existingAssignment.Self_Assigned__c){
                        createAssignment(learnerProfile, existingAssignment, asset, dueDate, null, true);
                    }
                }
            }

            performDML();

            String assignedItemId = '';
            switch on itemType {
                when 'Curriculum__c' {
                    assignedItemId = aCurricsToUpsert[0].Id;
                }
                when 'Course__c' {
                    assignedItemId = aCoursesToUpsert[0].Id;
                }
                when 'Asset__c' {
                    assignedItemId = assignmentsToUpsert[0].Id;
                }
            }

            Set<String> assignmentIds = new Set<String>();

            for(Assignment__c assignment : assignmentsToUpsert){
                if(assetToAssignById.get(assignment.Asset__c).RecordType.DeveloperName == 'Skills_Assessment'){
                    assignmentIds.add(assignment.Id);
                }
            }

            if(!assignmentIds.isEmpty()){
                createAssessmentResponseBatchJob cont = new createAssessmentResponseBatchJob(assignmentIds, false);
                
                List<Assignment__c> assignmentsWithData = [SELECT Id, Asset__c, Asset__r.Assessment__c, Learner_Profile__c, Learner_Profile__r.Name, Learner_Profile__r.User__r.ManagerId,
                                                                    Learner_Profile__r.Job_Code__c, Learner_Profile__r.Manager_Email__c, Learner_Profile__r.Primary_Email__c, Learner_Profile__r.User__c,
                                                                    Due_Date__c
                                                           FROM Assignment__c
                                                           WHERE Id =: assignmentIds];
                cont.createAssessmentResponses(assignmentsWithData);
            }

            rd.put('assignmentId', assignedItemId);
        } catch (Exception e) {
            rd.addError(e.getMessage());
            System.debug('**************** e ' + e.getMessage());
            System.debug('**************** e ' + e.getStackTraceString());
        }

        return rd;
    }

    public static void initItems(){
        learnersByAudienceId = new Map<String, List<Learner_Profile__c>>();
        learnerIds = new Set<String>();
        audienceIds = new Set<String>();
        alsByAudienceId = new Map<String, List<Assigned_Learning__c>>();
        alIdByLearningId = new Map<String, String>();
        curricToAssignById = new Map<String, Curriculum__c>();
        courseToAssignById = new Map<String, Course__c>();
        assetToAssignById = new Map<String, Asset__c>();
        existingSoloAssignmentsByLPAndLAId = new Map<String, Assignment__c>();
        existingAssignedCourseByLPAndCourseId = new Map<String, Assigned_Course__c>();
        existingAssignedCurricByLPAndCurricId = new Map<String, Assigned_Curriculum__c>();
        assignedItems = new Set<String>();
        aCurricsToUpsert = new List<Assigned_Curriculum__c>();
        aCoursesToUpsert = new List<Assigned_Course__c>();
        assignmentsToUpsert = new List<Assignment__c>();
        curricIds = new List<String>();
        courseIds = new List<String>();
        assetIds = new List<String>();
        managerLPsByUserId = new Map<String, Learner_Profile__c>();
        skillAssessmentAssetIds = new Set<String>();
        skillAssessmentAssignmentIds = new Set<String>();
    }

    public static Learner_Profile__c getLearnerProfile(String userId){
        return [SELECT Id, User__c, User__r.ManagerId
                FROM Learner_Profile__c
                WHERE User__c =: userId
                AND Status__c = 'Active'
                WITH USER_MODE];
    }

    public static void getLearningData(){
        List<String> managerUserIds = new List<String>();

        for(Audience_Member__c am : members){
            learnerIds.add(am.Learner_Profile__c);
            audienceIds.add(am.Audience__c);
            managerUserIds.add(am.Learner_Profile__r.User__r.ManagerId);
           
            if(!learnersByAudienceId.containsKey(am.Audience__c)){
                learnersByAudienceId.put(am.Audience__c, new List<Learner_Profile__c>());
            }

            learnersByAudienceId.get(am.Audience__c).add(am.Learner_Profile__r);
        }

        for(Learner_Profile__c lp : [SELECT Id, User__c FROM Learner_Profile__c WHERE User__c =: managerUserIds WITH USER_MODE]){
            managerLPsByUserId.put(lp.User__c, lp);
        }

        for(Assigned_Learning__c al : [SELECT Id, Due_Date__c, Curriculum__c, Course__c, Asset__c, Audience__c, Custom_Course_Due_Dates__c
                                       FROM Assigned_Learning__c
                                       WHERE Audience__c =: learnersByAudienceId.keySet()
                                       AND Start_Date__c = TODAY
                                       WITH USER_MODE
                                       ORDER BY Due_Date__c DESC, CreatedDate DESC]){


            if(!alsByAudienceId.containsKey(al.Audience__c)){
                alsByAudienceId.put(al.Audience__c, new List<Assigned_Learning__c>());
            }

            // Check for duplicate assigned learnings
            Boolean duplicateFound = false;

            for (Assigned_Learning__c previousAl : alsByAudienceId.get(al.Audience__c)) {
                if (al.Audience__c == previousAl.Audience__c &&
                    ((al.Curriculum__c != null && al.Curriculum__c == previousAl.Curriculum__c) ||
                     (al.Course__c != null && al.Course__c == previousAl.Course__c) ||
                     (al.Asset__c != null && al.Asset__c == previousAl.Asset__c))) {
                    duplicateFound = true;
                }
            }

            if (duplicateFound) {
                continue;
            }

            alsByAudienceId.get(al.Audience__c).add(al);

            if(al.Curriculum__c != null && !alIdByLearningId.containsKey(al.Curriculum__c)){
                alIdByLearningId.put(al.Curriculum__c, al.Id);
                curricIds.add(al.Curriculum__c);
            }

            if(al.Course__c != null && !alIdByLearningId.containsKey(al.Course__c)){
                alIdByLearningId.put(al.Course__c, al.Id);
                courseIds.add(al.Course__c);
            }

            if(al.Asset__c != null && !alIdByLearningId.containsKey(al.Asset__c)){
                alIdByLearningId.put(al.Asset__c, al.Id);
                assetIds.add(al.Asset__c);
            }

        }

        getRecordData();
    }

    public static void getRecordData(){
         if(!curricIds.isEmpty()){
            curricToAssignById = new Map<String, Curriculum__c>([SELECT Id, Name, Time_Estimate_Minutes__c,
                                                                 (
                                                                     SELECT Id, Order__c, Curriculum__c, Course__c, Required__c, Elective_Course__c
                                                                     FROM Curriculum_Courses__r
                                                                     ORDER BY Order__c ASC
                                                                 )
                                                                 FROM Curriculum__c
                                                                 WHERE Id =: curricIds
                                                                 WITH USER_MODE]);

            for(Curriculum__c curric : curricToAssignById.values()){
                for(Curriculum_Course__c cc : curric.Curriculum_Courses__r){
                    courseIds.add(cc.Course__c);
                }
            }
        }

        if(!courseIds.isEmpty()){
            courseToAssignById = new Map<String, Course__c>([SELECT Id, Name, Time_Estimate_Minutes__c,
                                                             (
                                                                 SELECT Id, Order__c, Course__c, Asset__c, Required__c, Elective_Asset__c
                                                                 FROM Course_Assets__r
                                                                 ORDER BY Order__c ASC
                                                             )
                                                             FROM Course__c
                                                             WHERE Id =: courseIds
                                                             WITH USER_MODE]);

            for(Course__c course : courseToAssignById.values()){
                for(Course_Asset__c ca : course.Course_Assets__r){
                    assetIds.add(ca.Asset__c);
                }
            }
        }

        if(!assetIds.isEmpty()){
            assetToAssignById = new Map<String, Asset__c>([SELECT Id, Name, Assessor_Type__c, Assessor__c, RecordType.DeveloperName, Time_Estimate_Minutes__c, Mandatory_Session_Count__c
                                                           FROM Asset__c
                                                           WHERE Id =: assetIds
                                                           WITH USER_MODE]);

            for(Asset__c asset : assetToAssignById.values()){
                System.debug('************ ' + asset.RecordType.DeveloperName);
                if(asset.RecordType.DeveloperName == 'Skills_Assessment'){
                    skillAssessmentAssetIds.add(asset.Id);
                }
            }
        }
    }

    public static void getDuplicates(){
        if(!curricToAssignById.isEmpty()){
            for(Assigned_Curriculum__c ac : [SELECT Id, Learner_Profile__c, Curriculum__c, Self_Assigned__c, Completed__c, Inactive__c,
                                             (
                                                SELECT Id, Course__c, Self_Assigned__c, Due_Date__c, Assigned_Learning__c, Inactive__c
                                                FROM Assigned_Courses__r
                                             ),
                                             (
                                                SELECT Id, Asset__c, Asset__r.Time_Estimate_Minutes__c, Asset__r.Mandatory_Session_Count__c, Course__c, Self_Assigned__c, Due_Date__c, Assigned_Learning__c, Inactive__c
                                                FROM Assignments__r
                                             )
                                             FROM Assigned_Curriculum__c
                                             WHERE Learner_Profile__c =: learnerIds
                                             AND Curriculum__c =: curricToAssignById.keySet()
                                             WITH USER_MODE]){
                existingAssignedCurricByLPAndCurricId.put(ac.Learner_Profile__c + '|' + ac.Curriculum__c, ac);
            }
        }

        if(!courseToAssignById.isEmpty()){
            for(Assigned_Course__c aCourse : [SELECT Id, Learner_Profile__c, Course__c, Self_Assigned__c, Completed__c, Assigned_Curriculum__r.Name, Inactive__c,
                                                (
                                                    SELECT Id, Asset__c, Assigned_Course__c, Assigned_Course__r.Name, Course__c, Self_Assigned__c, Due_Date__c, Assigned_Learning__c, Inactive__c
                                                    FROM Assignments__r
                                                )
                                              FROM Assigned_Course__c
                                              WHERE Learner_Profile__c =: learnerIds
                                              AND Course__c =: courseToAssignById.keySet()
                                              AND Assigned_Curriculum__c = null
                                              WITH USER_MODE]){
                existingAssignedCourseByLPAndCourseId.put(aCourse.Learner_Profile__c + '|' + aCourse.Course__c, aCourse);
            }
        }

        if (!assetToAssignById.isEmpty()){
            // String assessmentRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
            String quizRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Quiz').getRecordTypeId();
            String inappRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('In_App_Assessment').getRecordTypeId();
            String eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
            String skillRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Skills_Assessment').getRecordTypeId();
            List<String> allowedDuplicates = new List<String>{eventRecordTypeId, quizRecordTypeId, inappRecordTypeId, skillRecordTypeId};

            for (Assignment__c a : [SELECT Id, Learner_Profile__c, Self_Assigned__c, Completed__c, Due_Date__c,
                                           Assigned_Learning__c, Asset__c, Course_Asset__c, Order__c, Time_Estimate_Minutes__c, Mandatory_Session_Count__c,
                                           Curriculum__c, Assigned_Curriculum__c, Assigned_Curriculum__r.Name, Course__c, Assigned_Course__c, Assigned_Course__r.Name,
                                           Inactive__c
                                   FROM Assignment__c
                                   WHERE Learner_Profile__c =: learnerIds
                                   AND Asset__c =: assetToAssignById.keySet()
                                   AND Assigned_Course__c = null
                                   AND (Asset__r.RecordTypeId !=: allowedDuplicates OR (Asset__r.RecordTypeId =: allowedDuplicates AND Completed__c = false))
                                   WITH USER_MODE]){
                existingSoloAssignmentsByLPAndLAId.put(a.Learner_Profile__c + '|' + a.Asset__c, a);
            }
        }
    }

    public static void createAssignedRecords(){
        for(String audienceId : alsByAudienceId.keySet()){
            if(learnersByAudienceId.containsKey(audienceId) && learnersByAudienceId.containsKey(audienceId)){
                List<Assigned_Learning__c> als = alsByAudienceId.get(audienceId);
                List<Learner_Profile__c> lps = learnersByAudienceId.get(audienceId);

                for(Assigned_Learning__c al : als){
                    Map<String, Object> customDueDateByCourseId = new Map<String, Object>();

                    if(al.Curriculum__c != null && String.isNotEmpty(al.Custom_Course_Due_Dates__c)){
                        try{
                            customDueDateByCourseId = (Map<String, Object>)JSON.deserializeUntyped(al.Custom_Course_Due_Dates__c);
                        } catch(Exception e){
                            //just use the TA due date as a fall back
                        }
                    }

                    for (Learner_Profile__c lp : lps) {
                        if (al.Curriculum__c != null) {
                            Assigned_Curriculum__c existingACurric = existingAssignedCurricByLPAndCurricId.get(lp.Id + '|' + al.Curriculum__c);

                            if (existingACurric == null || existingACurric.Inactive__c || existingACurric.Self_Assigned__c) {
                                Assigned_Curriculum__c newAssignedCurriculum = createAssignedCurric(lp, existingACurric, curricToAssignById.get(al.Curriculum__c), al.Due_Date__c, customDueDateByCourseId, al, false);
                                existingAssignedCurricByLPAndCurricId.put(newAssignedCurriculum.Learner_Profile__c + '|' + newAssignedCurriculum.Curriculum__c, newAssignedCurriculum);
                            }
                        } else if (al.Course__c != null) {
                            Assigned_Course__c existingCourse = existingAssignedCourseByLPAndCourseId.get(lp.Id + '|' + al.Course__c);
                            System.debug('************* existingCourse ' + existingCourse);
                            if (existingCourse == null || existingCourse.Inactive__c || existingCourse.Self_Assigned__c) {
                                Assigned_Course__c newAssignedCourse = createAssignedCourse(lp, existingCourse, courseToAssignById.get(al.Course__c), al.Due_Date__c, al, false);
                                existingAssignedCourseByLPAndCourseId.put(newAssignedCourse.Learner_Profile__c + '|' + newAssignedCourse.Course__c, newAssignedCourse);
                            }
                        } else if (al.Asset__c != null) {
                            Assignment__c existingAssignment = existingSoloAssignmentsByLPAndLAId.get(lp.Id + '|' + al.Asset__c);

                            if (existingAssignment == null || existingAssignment.Inactive__c || existingAssignment.Self_Assigned__c) {
                                Assignment__c newAssignment = createAssignment(lp, existingAssignment, assetToAssignById.get(al.Asset__c), al.Due_Date__c, al, false);
                                existingSoloAssignmentsByLPAndLAId.put(newAssignment.Learner_Profile__c + '|' + newAssignment.Asset__c, newAssignment);
                            }
                        }
                    }
                }
            }
        }
    }

    public static Map<String, Assigned_Course__c> existingACoursesByCourseId;
    public static Map<String, Assignment__c> existingAssignmentsByCourseAssetId;

    public static Assigned_Curriculum__c createAssignedCurric(Learner_Profile__c lp, Assigned_Curriculum__c existingACurric, Curriculum__c curric, Date dueDate, Map<String, Object> customDueDateByCourseId, Assigned_Learning__c assignedLearning, Boolean selfAssigned){
        existingACoursesByCourseId = new Map<String, Assigned_Course__c>();
        existingAssignmentsByCourseAssetId = new Map<String, Assignment__c>();

        if(existingACurric != null){
            for(Assigned_Course__c aCourse : existingACurric.Assigned_Courses__r){
                existingACoursesByCourseId.put(aCourse.Course__c, aCourse);
            }

            for(Assignment__c assignment : existingACurric.Assignments__r){
                existingAssignmentsByCourseAssetId.put(assignment.Course__c + '|' + assignment.Asset__c, assignment);
            }
        }

        Assigned_Curriculum__c aCurric = createStubACurric(lp, existingACurric, curric, dueDate, assignedLearning, selfAssigned);

        for(Curriculum_Course__c curricCourse : curric.Curriculum_Courses__r){
            Course__c course = courseToAssignById.get(curricCourse.Course__c);
            Assigned_Course__c existingACourse = existingACoursesByCourseId.get(course.Id);
            Date courseDueDate = dueDate;

            if(customDueDateByCourseId != null && customDueDateByCourseId.containsKey(course.Id)){
                courseDueDate = Date.valueOf((String)customDueDateByCourseId.get(course.Id));
            }

            createAssignedCourse(lp, aCurric, existingACourse, course, curricCourse, courseDueDate, assignedLearning, selfAssigned);
        }

        assignedItems.add(lp.Id + '|' + curric.Id);
        aCurricsToUpsert.add(aCurric);
        return aCurric;
    }

    public static Assigned_Curriculum__c createStubACurric(Learner_Profile__c lp, Assigned_Curriculum__c existingACurric, Curriculum__c curric, Date dueDate, Assigned_Learning__c assignedLearning, Boolean selfAssigned){
        Assigned_Curriculum__c aCurric = new Assigned_Curriculum__c();

        if(existingACurric != null){
            aCurric.Id = existingACurric.Id;
        }

        aCurric.Self_Assigned__c = selfAssigned;
        aCurric.Due_Date__c = dueDate;
        aCurric.Curriculum__c = curric.Id;
        aCurric.OwnerId = lp.User__c;
        aCurric.Learner_Profile__c = lp.Id;
        aCurric.Assigned_Learning__c = assignedLearning?.Id;
        aCurric.Time_Estimate_Minutes__c = curric.Time_Estimate_Minutes__c;
        aCurric.Inactive__c = false;
        aCurric.Assigned_On__c = Date.today();

        return aCurric;
    }

    public static Assigned_Course__c createAssignedCourse(Learner_Profile__c lp, Course__c course, Date dueDate, Assigned_Learning__c assignedLearning, Boolean selfAssigned){
        return createAssignedCourse(lp, null, null, course, null, dueDate, assignedLearning, selfAssigned);
    }

    public static Assigned_Course__c createAssignedCourse(Learner_Profile__c lp, Assigned_Course__c existingACourse, Course__c course, Date dueDate, Assigned_Learning__c assignedLearning, Boolean selfAssigned){
        return createAssignedCourse(lp, null, existingACourse, course, null, dueDate, assignedLearning, selfAssigned);
    }

    public static Assigned_Course__c createAssignedCourse(Learner_Profile__c lp, Assigned_Curriculum__c parentACurric, Assigned_Course__c existingACourse, Course__c course, Curriculum_Course__c curricCourse, Date dueDate, Assigned_Learning__c assignedLearning, Boolean selfAssigned){
        if(parentACurric == null){
            existingAssignmentsByCourseAssetId = new Map<String, Assignment__c>();
        }

        if(existingACourse != null){
            for(Assignment__c a : existingACourse.Assignments__r){
                existingAssignmentsByCourseAssetId.put(a.Course__c + '|' + a.Asset__c, a);
            }
        }


        Assigned_Course__c aCourse = createStubACourse(lp, parentACurric, existingACourse, course, curricCourse, dueDate, assignedLearning, selfAssigned);

        for(Course_Asset__c ca : course.Course_Assets__r){
            Assignment__c existingAssignment = existingAssignmentsByCourseAssetId.get(ca.Course__c + '|' + ca.Asset__c);
            createAssignment(lp, parentACurric, aCourse, existingAssignment, assetToAssignById.get(ca.Asset__c), ca, dueDate, assignedLearning, selfAssigned);
        }

        aCoursesToUpsert.add(aCourse);

        return aCourse;
    }

    public static Assigned_Course__c createStubACourse(Learner_Profile__c lp, Assigned_Curriculum__c parentACurric, Assigned_Course__c existingACourse, Course__c course, Curriculum_Course__c curricCourse, Date dueDate, Assigned_Learning__c assignedLearning, Boolean selfAssigned){
        // Assigned_Course__c aCourse = existingACourse != null ? existingACourse : new Assigned_Course__c();
        Assigned_Course__c aCourse = new Assigned_Course__c();

        if(existingACourse != null){
            aCourse.Id = existingACourse.Id;
        }

        if (curricCourse != null) {
            aCourse.Required__c = curricCourse.Required__c;
            aCourse.Elective_Asset__c = curricCourse.Elective_Course__c;
        }

        aCourse.Self_Assigned__c = selfAssigned;
        aCourse.Due_Date__c = dueDate;
        aCourse.Course__c = course.Id;
        aCourse.OwnerId = lp.User__c;
        aCourse.Learner_Profile__c = lp.Id;
        aCourse.Assigned_Learning__c = assignedLearning?.Id;
        aCourse.Curriculum_Course__c = curricCourse?.Id;
        aCourse.Order__c = curricCourse?.Order__c;
        aCourse.Time_Estimate_Minutes__c = course.Time_Estimate_Minutes__c;
        aCourse.Inactive__c = false;
        aCourse.Assigned_On__c = Date.today();
        
        if(parentACurric != null){
            aCourse.Assigned_Curriculum__r = parentACurric;
        }

        return aCourse;
    }
   
    //Constructor for creating a brand new solo assignment
    public static Assignment__c createAssignment(Learner_Profile__c lp, Asset__c asset, Date dueDate, Assigned_Learning__c assignedLearning, Boolean selfAssigned){
        return createAssignment(lp, null, null, null, asset, null, dueDate, assignedLearning, selfAssigned);
    }
    //Constructor for creating a solo assignment that has an existing self assigned
    public static Assignment__c createAssignment(Learner_Profile__c lp, Assignment__c existingAssignment, Asset__c asset, Date dueDate, Assigned_Learning__c assignedLearning, Boolean selfAssigned){
        return createAssignment(lp, null, null, existingAssignment, asset, null, dueDate, assignedLearning, selfAssigned);
    }

    public static Assignment__c createAssignment(Learner_Profile__c lp, Assigned_Curriculum__c parentACurric, Assigned_Course__c parentACourse, Assignment__c existingAssignment, Asset__c asset, Course_Asset__c ca, Date dueDate, Assigned_Learning__c assignedLearning, Boolean selfAssigned){
        Assignment__c assignment = createStubAssignment(lp, parentACurric, parentACourse, existingAssignment, asset, ca, dueDate, assignedLearning, selfAssigned);

        assignmentsToUpsert.add(assignment);
        return assignment;
    }

    public static Assignment__c createStubAssignment(Learner_Profile__c lp, Assigned_Curriculum__c parentACurric, Assigned_Course__c parentACourse, Assignment__c existingAssignment, Asset__c asset, Course_Asset__c ca,  Date dueDate, Assigned_Learning__c assignedLearning, Boolean selfAssigned){
        // Assignment__c assignment = existingAssignment != null ? existingAssignment : new Assignment__c();
        Assignment__c assignment = new Assignment__c();

        if(existingAssignment != null){
            assignment.Id = existingAssignment.Id;
        }

        if (ca != null) {
            assignment.Required__c = ca.Required__c;
            assignment.Elective_Asset__c = ca.Elective_Asset__c;
        }

        assignment.Self_Assigned__c = selfAssigned;
        assignment.Due_Date__c = dueDate;
        assignment.OwnerId = lp.User__c;
        assignment.Learner_Profile__c = lp.Id;
        assignment.Assigned_Learning__c = assignedLearning?.Id;
        assignment.Asset__c = asset.Id;
        assignment.Course_Asset__c = ca?.Id;
        assignment.Order__c = ca?.Order__c;
        assignment.Time_Estimate_Minutes__c = asset.Time_Estimate_Minutes__c;
        assignment.Mandatory_Session_Count__c = asset.Mandatory_Session_Count__c;
        assignment.Assessor_Type__c = asset.Assessor_Type__c;
        assignment.Inactive__c = false;
        assignment.Assigned_On__c = Date.today();

        if(parentACurric != null){
            assignment.Curriculum__c = parentACurric.Curriculum__c;
            assignment.Assigned_Curriculum__r = parentACurric;
        }

        if(parentACourse != null){
            assignment.Course__c = parentACourse.Course__c;
            assignment.Assigned_Course__r = parentACourse;
        }

        if(asset.RecordType.DeveloperName == 'In_App_Assessment'){
            if(asset.Assessor_Type__c == 'Learning Admin Chooses'){
                assignment.Assessor__c = asset.Assessor__c;
            } else if(asset.Assessor_Type__c == 'Learner\'s Manager'){
                assignment.Assessor__c = managerLPsByUserId.get(lp.User__r.ManagerId).Id;
            }
        }
        
        
        return assignment;
    }
}