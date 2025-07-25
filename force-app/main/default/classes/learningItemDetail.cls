public with sharing class learningItemDetail {
    public static Map<String, Integer> totalSessionsByAssetId = new Map<String, Integer>();
    public static Map<String, List<SessionManager.sessionListItem>> sessionListItemsByAssetId = new Map<String, List<SessionManager.sessionListItem>>();
    //using a map so we have a bulkified version to use for formattedLearningItem
    public static Map<String, List<SessionManager.sessionListItem>> mySessionsByAssetId = new Map<String, List<SessionManager.sessionListItem>>();
    public static Map<String, List<SessionManager.sessionListItem>> waitlistedSessionsByAssetId = new Map<String, List<SessionManager.sessionListItem>>();
    public static Map<String, List<SessionManager.sessionListItem>> attendedSessionsByAssetId = new Map<String, List<SessionManager.sessionListItem>>();
    public static Learner_Profile__c lp;
    public static Boolean isPreview;
    public static String parentId;

    @AuraEnabled
    public static ResponseData getData(Id objId, String parentId, Boolean isPreview){
        ResponseData rd = new ResponseData();

        try {
            learningItemDetail.isPreview = isPreview;
            List<Learner_Profile__c> lps = [SELECT Id, Name, Title__c, User__c
                                            FROM Learner_Profile__c
                                            WHERE User__c =: UserInfo.getUserId()
                                            AND Status__c = 'Active'
                                            WITH USER_MODE];
            if(lps.isEmpty()){
                rd.addError('No Learner Profile found. Please contact support for help');
                return rd;
            }
                                            
            lp = lps.get(0);
            String objType = objId.getSObjectType() + '';

            System.debug('*********** objType ' + objType);

            if(objType == 'Assigned_Curriculum__c' || objType == 'Curriculum__c'){
                rd = getCurriculumData(objId, objType);
                // rd = getAssignedCurriculumData(objId);
            } else if(objType == 'Assigned_Course__c' || objType == 'Course__c'){
                rd = getCourseData(objId, parentId, objType);
                // rd = getAssignedCourseData(objId);
            } else if(objType == 'Session__c'){
                rd = getSessionData(objId);  
            } else if(objType == 'Assignment__c' || objType == 'Asset__c'){
                rd = getAssetData(objId, parentId, objType);
                // rd = getAssignmentData(objId);
            } else if(objType == 'Case') {
                rd = getCaseData(objId);
            }
            
            rd.put('lp', lp);
            rd.put('type', objType);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    // public static ResponseData getAssignedCurriculumData(Id objId){
    //     ResponseData rd = new ResponseData();

    //     List<Assigned_Curriculum__c> learningItems = [SELECT Id, Due_Date__c, Number_of_Courses__c, Number_of_Completed_Required_Courses__c, Number_of_Required_Courses__c,
    //                                                     CreatedDate, Curriculum__r.Name, Curriculum__r.Description__c, Curriculum__r.Objective__c, Time_Estimate_Minutes__c, Time_Estimate__c, Completed__c,
    //                                                     Self_Assigned__c, Learner_Profile__c, Learner_Profile__r.User__c,
    //                                                 (
    //                                                     SELECT Id, Due_Date__c, Number_Of_Assets__c, Number_of_Completed_Required_Assets__c, Number_of_Required_Assets__c,
    //                                                            CreatedDate, Course__r.Name, Course__r.Description__c, Course__r.Objective__c, Time_Estimate_Minutes__c, Time_Estimate__c, Completed__c,
    //                                                            Learner_Profile__c, Learner_Profile__r.User__c, Self_Assigned__c
    //                                                     FROM Assigned_Courses__r
    //                                                     ORDER BY Order__c ASC
    //                                                 )
    //                                              FROM Assigned_Curriculum__c
    //                                              WHERE Id =: objId
    //                                              WITH USER_MODE];

    //     if(learningItems.isEmpty()){
    //         rd.addError('No Assigned Curriculum was found with the Id: ' + objId);
    //         return rd;
    //     }

    //     Assigned_Curriculum__c learningItem = learningItems.get(0);

    //     if(learningItem.Learner_Profile__r.User__c != UserInfo.getUserId()){
    //         rd.addError('You are not the owner of this assigned curriculum');
    //         return rd;
    //     }


    //     Map<String, Object> formattedLearningItem = formatLearningItem(learningItem);
    //     List<Map<String, Object>> formattedChildItems = new List<Map<String, Object>>();

    //     for(Assigned_Course__c aCourse : learningItem.Assigned_Courses__r){
    //         formattedChildItems.add(formatLearningItem(aCourse));
    //     }

    //     rd.put('learningItem', formattedLearningItem);
    //     rd.put('formattedChildItems', formattedChildItems);

    //     return rd;
    // }

    // public static ResponseData getAssignedCourseData(Id objId){
    //     ResponseData rd = new ResponseData();

    //     List<Assigned_Course__c> aCourses = [SELECT Id, Assigned_Curriculum__c, Assigned_Curriculum__r.Curriculum__r.Name, Curriculum_Course__c, Curriculum_Course__r.Objective__c, Due_Date__c, Number_Of_Assets__c, Number_of_Completed_Required_Assets__c, Number_of_Required_Assets__c,
    //                                                 CreatedDate, Course__r.Name, Course__r.Description__c, Course__r.Objective__c, Time_Estimate_Minutes__c, Time_Estimate__c, Completed__c, Course__r.Survey_URL__c, Learner_Profile__c, Learner_Profile__r.User__c, Self_Assigned__c,
    //                                                 (
    //                                                     SELECT Id, CreatedDate, Asset__c, Asset__r.RecordType.DeveloperName, Due_Date__c, Asset__r.Name, Asset__r.Description__c,
    //                                                            Asset__r.Assessment_Type__c, Time_Estimate_Minutes__c, Time_Estimate__c, Completed__c
    //                                                     FROM Assignments__r
    //                                                     ORDER BY Order__c ASC
    //                                                 )
    //                                          FROM Assigned_Course__c
    //                                          WHERE Id =: objId
    //                                          WITH USER_MODE];

    //     if(aCourses.isEmpty()){
    //         rd.addError('No Assigned Course was found with the Id: ' + objId);
    //         return rd;
    //     }

    //     Assigned_Course__c aCourse = aCourses.get(0);

    //     if(aCourse.Learner_Profile__r.User__c != UserInfo.getUserId()){
    //         rd.addError('You are not the owner of this assigned course');
    //         return rd;
    //     }


    //     Map<String, Object> formattedACourse = formatLearningItem(aCourse);
    //     List<Map<String, Object>> formattedAssignments = new List<Map<String, Object>>();
    //     Set<String> assetIds = new Set<String>();

    //     for(Assignment__c assignment : aCourse.Assignments__r){
    //         if(assignment.Asset__r.RecordType.DeveloperName == 'Event'){
    //             assetIds.add(assignment.Asset__c);
    //         }
    //     }

    //     for(Asset__c asset : [SELECT Id, 
    //                                 (
    //                                     SELECT Id
    //                                     FROM Sessions__r
    //                                     WHERE Start_Date__c >= TODAY
    //                                 )
    //                               FROM Asset__c
    //                               WHERE Id =: assetIds
    //                               WITH USER_MODE]){
    //         learningItemDetail.totalSessionsByAssetId.put(asset.Id, asset.Sessions__r.size());
    //     }

    //     for(Assignment__c assignment : aCourse.Assignments__r){
    //         formattedAssignments.add(formatLearningItem(assignment));
    //     }

    //     rd.put('learningItem', formattedACourse);
    //     rd.put('formattedAssignments', formattedAssignments);

    //     return rd;
    // }

    // public static ResponseData getAssignmentData(Id objId){
    //     ResponseData rd = new ResponseData();

    //     sessionListItemsByAssetId = new Map<String, List<SessionManager.sessionListItem>>();
 
    //     List<Assignment__c> learningItems = [SELECT Id, CreatedDate, Asset__c, Asset__r.Name, Asset__r.Mandatory_Session_Count__c, Asset__r.Content__c, Asset__r.Description__c, Asset__r.RecordTypeId, Asset__r.Objective__c,
    //                                                 Asset__r.RecordType.DeveloperName, Asset__r.Assessment_Type__c, Asset__r.Attestation_Text__c, Asset__r.Url__c, Asset__r.Trailhead_Module_Id__c, Asset__r.Trailhead_Namespace__c,
    //                                                 Assigned_Course__c, Assigned_Course__r.Course__r.Name, Assigned_Curriculum__c, Assigned_Learning__c, Course_Asset__c, Course_Asset__r.Objective__c, Due_Date__c, 
    //                                                 Learner_Profile__c, Learner_Profile__r.User__c, Queue_Position__c, Self_Assigned__c, Media__c, Media_Url__c, Asset__r.Media_Type__c, Completed__c, Completion_Date__c,
    //                                                 Time_Estimate_Minutes__c, Time_Estimate__c
    //                                          FROM Assignment__c
    //                                          WHERE Id =: objId
    //                                          WITH USER_MODE];

    //     if(learningItems.isEmpty()){
    //         rd.addError('No Assignment was found with the Id: ' + objId);
    //         return rd;
    //     }

    //     Assignment__c learningItem = learningItems.get(0);

    //     if(learningItem.Learner_Profile__r.User__c != UserInfo.getUserId()){
    //         rd.addError('You are not the owner of this assignment');
    //         return rd;
    //     }

    //     if(learningItem.Asset__r.RecordType.DeveloperName == 'Event'){
    //         getEventData(learningItem.Asset__c);
    //     }


    //     Map<String, Object> formattedLearningItem = formatLearningItem(learningItem);
    //     List<Map<String, Object>> formattedChildItems = new List<Map<String, Object>>();
        
    //     rd.put('learningItem', formattedLearningItem);
    //     rd.put('formattedChildItems', formattedChildItems);

    //     return rd;
    // }

    public static void getEventData(String assetId){
        List<String> allowedStatuses = new List<String>{'Registered'};

        List<Session__c> mySessions = [SELECT Id, Name, Session_Type__c, Physical_Capacity__c, Virtual_Capacity__c, Registered_Guests__c, Total_Capacity__c, Virtual_Registered_Guests__c, Physical_Registered_Guests__c, Start_Date__c, Description__c, Start_Time__c, End_Date__c, End_Time__c, Time_Zone__c,
                                            Start_Time_Converted__c, End_Time_Converted__c, Owner.Name, Address__c, City__c, Country__c,
                                            Zip_Code__c, Url__c, Zoom_Session_Id__c, Zoom_Occurrence_Id__c, Virtual_Type__c, Location__c, 
                                            Asset__r.Name, Asset__r.Mandatory_Session_Count__c, Status__c, Office_Location__r.Name,Office_Location__r.Address__c, Office_Location__r.City__c, Office_Location__r.Country__c, Office_Location__r.Postal_Code__c, Region__c, Room__c, Floor__c, Zoom_Type__c,
                                            (
                                                SELECT Id, Status__c, Registration_Type__c, Queue_Position__c
                                                FROM Assigned_Sessions__r
                                                WHERE Learner_Profile__c =: lp.Id
                                            )
                                       FROM Session__c
                                       WHERE Asset__c =: assetId
                                       AND Id IN (SELECT Session__c
                                                  FROM Assigned_Session__c
                                                  WHERE Status__c =: allowedStatuses
                                                  AND Learner_Profile__c =: lp.Id)
                                       WITH USER_MODE
                                       ORDER BY Start_Date__c ASC, Start_Time__c ASC];

        List<SessionManager.sessionListItem> myFormattedSessions = new List<SessionManager.sessionListItem>();

        for(Session__c session: mySessions){
            myFormattedSessions.add(new SessionManager.sessionListItem(session));
        }

        mySessionsByAssetId.put(assetId, myFormattedSessions);



        List<String> allowedWaitlistedStatuses = new List<String>{'Waitlisted'};

        List<Session__c> waitlistedSessions = [SELECT Id, Name, Session_Type__c, Physical_Capacity__c, Virtual_Capacity__c, Registered_Guests__c, Total_Capacity__c, Virtual_Registered_Guests__c, Physical_Registered_Guests__c, Start_Date__c, Description__c, Start_Time__c, End_Date__c, End_Time__c, Time_Zone__c,
                                            Start_Time_Converted__c, End_Time_Converted__c, Owner.Name, Address__c, City__c, Country__c,
                                            Zip_Code__c, Url__c, Zoom_Session_Id__c, Zoom_Occurrence_Id__c, Virtual_Type__c, Location__c, 
                                            Asset__r.Name, Asset__r.Mandatory_Session_Count__c, Status__c, Office_Location__r.Name, Region__c, Room__c, Floor__c, Zoom_Type__c,
                                            (
                                                SELECT Id, Status__c, Registration_Type__c, Queue_Position__c
                                                FROM Assigned_Sessions__r
                                                WHERE Learner_Profile__c =: lp.Id
                                            )
                                       FROM Session__c
                                       WHERE Asset__c =: assetId
                                       AND Id IN (SELECT Session__c
                                                  FROM Assigned_Session__c
                                                  WHERE Status__c =: allowedWaitlistedStatuses
                                                  AND Learner_Profile__c =: lp.Id)
                                       WITH USER_MODE
                                       ORDER BY Start_Date__c ASC, Start_Time__c ASC];

        List<SessionManager.sessionListItem> waitlistedFormattedSessions = new List<SessionManager.sessionListItem>();

        for(Session__c session: waitlistedSessions){
            waitlistedFormattedSessions.add(new SessionManager.sessionListItem(session));
        }

        waitlistedSessionsByAssetId.put(assetId, waitlistedFormattedSessions);



        List<String> allowedAttendedStatuses = new List<String>{'Attended', 'Exempt'};

        List<Session__c> attendedSessions = [SELECT Id, Name, Session_Type__c, Physical_Capacity__c, Virtual_Capacity__c, Registered_Guests__c, Total_Capacity__c, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c, Time_Zone__c,
                                            Start_Time_Converted__c, End_Time_Converted__c, Owner.Name, Address__c, City__c, Country__c,
                                            Zip_Code__c, Url__c, Zoom_Session_Id__c, Zoom_Occurrence_Id__c, Virtual_Type__c, Location__c, 
                                            Asset__r.Name, Asset__r.Mandatory_Session_Count__c, Status__c, Office_Location__r.Name, Region__c, Room__c, Floor__c, Zoom_Type__c,
                                            (
                                                SELECT Id, Status__c, Registration_Type__c
                                                FROM Assigned_Sessions__r
                                                WHERE Learner_Profile__c =: lp.Id
                                            )
                                       FROM Session__c
                                       WHERE Asset__c =: assetId
                                       AND Id IN (SELECT Session__c
                                                  FROM Assigned_Session__c
                                                  WHERE Status__c =: allowedAttendedStatuses
                                                  AND Learner_Profile__c =: lp.Id)
                                       WITH USER_MODE
                                       ORDER BY Start_Date__c ASC, Start_Time__c ASC];

        List<SessionManager.sessionListItem> attendedFormattedSessions = new List<SessionManager.sessionListItem>();

        for(Session__c session: attendedSessions){
            attendedFormattedSessions.add(new SessionManager.sessionListItem(session));
        }

        attendedSessionsByAssetId.put(assetId, attendedFormattedSessions);

        

        List<SessionManager.sessionListItem> sessionListItems = new List<SessionManager.sessionListItem>();
        List<String> allowedSessionStatuses = new List<String>{'Active'};

        if(isPreview){
            allowedSessionStatuses.add('Draft');
        } 

        mySessions.addAll(waitlistedSessions);

        for(SessionManager.sessionListItem groupSession : SessionManager.getFormattedGroups(assetId, false, mySessions, allowedSessionStatuses)){
            if(groupSession.groupSessions.isEmpty()){
                continue;
            }

            sessionListItems.add(groupSession);
        }

        mySessions.addAll(attendedSessions);

        sessionListItems.addAll(SessionManager.getFormattedSessions(assetId, false, mySessions, allowedSessionStatuses));

        sessionListItemsByAssetId.put(assetId, sessionListItems);

    }

    public static ResponseData getSessionData(Id objId){
        ResponseData rd = new ResponseData();

        List<Map<String, Object>> formattedSiblingSessions = new List<Map<String, Object>>();
        List<String> allowedStatuses = new List<String>{'Registered', 'Waitlisted', 'Attended', 'Exempt'}; 
        List<Session__c> learningContents = [SELECT Id, Name, Physical_Capacity__c, Virtual_Capacity__c, Registered_Guests__c, Total_Capacity__c, Session_Type__c, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c, Time_Zone__c, Virtual_Registered_Guests__c, Physical_Registered_Guests__c,
                                              Start_Time_Converted__c, End_Time_Converted__c, Owner.Name, Address__c, City__c, Country__c,
                                              Zip_Code__c, Url__c, Zoom_Session_Id__c, Zoom_Occurrence_Id__c, Virtual_Type__c, Objective__c, Description__c, Learner_Instructions__c,
                                              Asset__r.Name, Asset__r.Mandatory_Session_Count__c, Status__c, Office_Location__r.Name, Region__c, Room__c, Floor__c, Zoom_Type__c,
                                              Office_Location__r.Address__c, Office_Location__r.City__c, Office_Location__r.State__c, 
                                              Office_Location__r.Postal_Code__c, Office_Location__r.Country__c, Survey_URL__c, Send_Survey_Notification__c, Session_Group__c,Location__c,
                                              (
                                                SELECT Id, Status__c, Assignment__c, Registration_Type__c, Queue_Position__c
                                                FROM Assigned_Sessions__r
                                                WHERE Learner_Profile__c =: lp.Id
                                                AND Status__c =: allowedStatuses
                                              )
                                          FROM Session__c
                                          WHERE Id =: objId
                                          WITH USER_MODE]; 

        if(learningContents.isEmpty()){
            rd.addError('No Session was found with the Id: ' + objId);
            return rd;
        }

        Session__c learningContent = learningContents.get(0);
        Assigned_Session__c assignedItem;

        if(!learningContent.Assigned_Sessions__r.isEmpty()){
            assignedItem = learningContent.Assigned_Sessions__r.get(0);
        }

        if(learningContent.Session_Group__c != null){
            List<Session__c> siblingSessions = [SELECT Id, Name, Start_Date__c, Session_Type__c, Region__c, Location__c, 
                                                       Office_Location__r.City__c, Time_Zone__c, Start_Time_Converted__c, End_Time_Converted__c 
                                                FROM Session__c
                                                WHERE Session_Group__c =: learningContent.Session_Group__c
                                                AND Status__c = 'Active'
                                                AND Start_Date__c >= TODAY
                                                AND Id !=: learningContent.Id
                                                ORDER BY Start_Date__c ASC];

            for(Session__c siblingSession : siblingSessions){
                Map<String, Object> siblingSessionMap = siblingSession.getPopulatedFieldsAsMap().clone();
                formatSessionTimes(siblingSessionMap);
                formattedSiblingSessions.add(siblingSessionMap);
            }
        }

        Map<String, Object> formattedLearningContent = formatLearningItem(learningContent);
        //Need to query for Assignment because we might be assigned it, but not registered
        //so we don't know what assignment to register it to since we have no Assigned_Sessions__r to work with
        List<Assignment__c> assignments = [SELECT Id
                                           FROM Assignment__c
                                           WHERE Learner_Profile__c =: lp.Id
                                           AND Asset__c =: learningContent.Asset__c
                                           WITH USER_MODE];

        if(!assignments.isEmpty()){
            formattedLearningContent.put('assignment', assignments.get(0));
        }
        
        rd.put('learningContent', formattedLearningContent);
        rd.put('assignedItem', assignedItem);
        rd.put('siblingSessions', formattedSiblingSessions);

        return rd;
    }

    public static ResponseData getCaseData(Id objId){
        ResponseData rd = new ResponseData();
        try{
            Map<String, List<Object>> fileData = learningSupport.getRelatedFiles(new Set<Id>{objId});
            Id profileId=userinfo.getProfileId();
            String profileName =[SELECT Id,Name FROM Profile WHERE Id =: profileId].Name;
            Set<String> allowedProfiles = new Set<String>{'Admin', 'Support Profile', 'System Administrator'};

            Case learningItem = [SELECT Id, CaseNumber, Case_Outcome__c, Topic__c, Description, 
                                        Case_Tier__c, Learner_Profile__c, createdDate, Status, 
                                        (SELECT Id, CommentBody, CreatedDate, createdById, createdBy.firstname, 
                                                createdBy.lastname, createdBy.Name 
                                        FROM CaseComments
                                        ORDER BY lastmodifieddate ASC)
                                    FROM Case
                                    WHERE Id =: objId
                                    WITH USER_MODE];

            if(learningItem.Learner_Profile__c != lp.Id && !allowedProfiles.contains(profileName)){
                rd.addError('You are not the owner of this case');
                return rd;
            }

            Map<String, Object> formattedLearningItem = formatLearningItem(learningItem);
            rd.put('learningContent', formattedLearningItem);
            List<CaseComment> comments = learningItem.CaseComments;
            if(!fileData.isEmpty()) {
                rd.put('files', JSON.serialize(fileData.get(objId))); // fileData.get(objId));
            }
            if(!comments.isEmpty()) {
                rd.put('comments', fomattedCaseComment(comments));
            }
        }catch(Exception e){
            rd.addError(e);
        }        
        return rd;        
    }   

    public static ResponseData getCourseData(Id objId, String parentId, String objType) {
        ResponseData rd = new ResponseData();

        try {
            String learningContentId;
            String assignedId;
            List<Map<String, Object>> formattedChildItems = new List<Map<String, Object>>();

            if(objType == 'Course__c'){
                learningContentId = objId;

                List<Assigned_Course__c> aCourses = [SELECT Id 
                                                     FROM Assigned_Course__c
                                                     WHERE Course__c =: objId
                                                     AND Learner_Profile__c =: lp.Id
                                                     AND Assigned_Curriculum__c = null
                                                     AND Inactive__c = false
                                                     WITH USER_MODE];

                if(!aCourses.isEmpty()){
                    assignedId = aCourses.get(0).Id;
                }
            } else {
                assignedId = objId;

                Assigned_Course__c aCourse = [SELECT Course__c
                                              FROM Assigned_Course__c
                                              WHERE Id =: objId
                                              AND Inactive__c = false
                                              WITH USER_MODE];
                
                learningContentId = aCourse.Course__c;
            }

            List<Course__c> parentItems = [SELECT Id, Name, Description__c, Objective__c, Learner_Instructions__c, Survey_URL__c, Electives_To_Complete__c, Sequenced__c,
                                                  Send_Survey_Notification__c
                                           FROM Course__c
                                           WHERE Id =: learningContentId
                                           WITH USER_MODE];

            if(parentItems.isEmpty()){
                rd.addError('No Course was found with the Id: ' + learningContentId);
                return rd;
            }

            Map<String, Object> formattedLearningContent = formatLearningItem(parentItems.get(0));
            Map<String, Object> formattedAssignedItem;

            //We need to get the custom objective from the Curriculum_Course__c object if we're in a preview state
            if(parentId != null){
                List<Curriculum_Course__c> cc = [SELECT Id, Objective__c FROM Curriculum_Course__c WHERE Course__c =: learningContentId AND Curriculum__c =: parentId WITH USER_MODE];
                
                if(!cc.isEmpty()){
                    formattedLearningContent.put('customObjective', cc[0].Objective__c);
                }
            }

            rd.put('learningContent', formattedLearningContent);

            // learning proficiency level
            List<Content_Tag__c> tag = [SELECT Id, Proficiency_Level__c FROM Content_Tag__c WHERE Course__c =: learningContentId AND Proficiency_Level__c != NULL LIMIT 1];
            if(!tag.isEmpty()) {
                rd.put('proficiencyLevel', tag[0].Proficiency_Level__c);
            }

            if(String.isNotEmpty(assignedId)){
                List<Assigned_Course__c> aCourses = [SELECT Id, Assigned_Curriculum__c, Assigned_Curriculum__r.Curriculum__r.Name, Curriculum_Course__c, Curriculum_Course__r.Objective__c, Curriculum_Course__r.Required__c, Curriculum_Course__r.Elective_Course__c, Due_Date__c, Number_Of_Assets__c, Number_of_Completed_Required_Assets__c, Number_of_Required_Assets__c, Number_of_Completed_Assets__c, 
                                                      CreatedDate, Time_Estimate_Minutes__c, Time_Estimate__c, Completed__c, Learner_Profile__c, Learner_Profile__r.User__c, Self_Assigned__c,
                                                      Course__r.Block_Self_Enrollment__c, Course__r.Block_Unenrollment__c, Course__r.Name, Course__r.Send_Survey_Notification__c,
                                                      Assigned_Curriculum__r.Curriculum__r.Block_Self_Enrollment__c, Assigned_Curriculum__r.Curriculum__r.Block_Unenrollment__c, Assigned_Curriculum__r.Curriculum__r.Sequenced__c, Order__c, Number_of_Required_Electives__c, Number_of_Completed_Electives__c,
                                                     (
                                                         SELECT Id, CreatedDate, Asset__c, Asset__r.RecordType.DeveloperName, Due_Date__c, Asset__r.Name, Asset__r.Description__c, Course_Asset__r.Required__c, Course_Asset__r.Elective_Asset__c, Course_Asset__r.Order__c,
                                                             Asset__r.Assessment_Type__c, Time_Estimate_Minutes__c, Time_Estimate__c, Completed__c, Required__c, Elective_Asset__c, Mandatory_Session_Count__c, Completed_Session_Count__c,
                                                             (SELECT Id FROM Assessment_Response__r)
                                                         FROM Assignments__r
                                                         WHERE Inactive__c = false
                                                         ORDER BY Order__c ASC
                                                     )
                                                     FROM Assigned_Course__c
                                                     WHERE Id =: assignedId
                                                     AND Inactive__c = false
                                                     WITH USER_MODE];

                if(aCourses.isEmpty()){
                    rd.put('navToLearningContent', true);
                    // rd.addError('No Assigned Course was found with the Id: ' + assignedId);
                    return rd;
                }

                Assigned_Course__c aCourse = aCourses.get(0);

                if(aCourse.Learner_Profile__r.User__c != UserInfo.getUserId()){
                    rd.put('navToLearningContent', true);
                    // rd.addError('You are not the owner of this assigned course');
                    return rd;
                }

                formattedAssignedItem = formatLearningItem(aCourse);

                Set<String> assetIds = new Set<String>();

                for(Assignment__c assignment : aCourse.Assignments__r){
                    if(assignment.Asset__r.RecordType.DeveloperName == 'Event'){
                        assetIds.add(assignment.Asset__c);
                    }
                }

                for(Asset__c asset : [SELECT Id, 
                                            (
                                                SELECT Id
                                                FROM Sessions__r
                                                WHERE Start_Date__c >= TODAY
                                            )
                                        FROM Asset__c
                                        WHERE Id =: assetIds
                                        WITH USER_MODE]){
                    totalSessionsByAssetId.put(asset.Id, asset.Sessions__r.size());
                }

                for(Assignment__c assignment : aCourse.Assignments__r){
                    formattedChildItems.add(formatLearningItem(assignment));
                }
                
                if(aCourse.Assigned_Curriculum__c != null){
                    Decimal nextOrder = aCourse.Order__c + 1;
                    Decimal prevOrder = aCourse.Order__c - 1;

                    List<Assigned_Course__c> nextSequentialCourses = [SELECT Id
                                                                    FROM Assigned_Course__c 
                                                                    WHERE Assigned_Curriculum__c =: aCourse.Assigned_Curriculum__c
                                                                    AND Id !=: aCourse.Id
                                                                    AND Order__c =: nextOrder
                                                                    AND Inactive__c = false
                                                                    LIMIT 1];

                    if(!nextSequentialCourses.isEmpty()){
                        rd.put('nextSequentialItem', nextSequentialCourses.get(0));
                    }

                    if(prevOrder >= 0){
                        List<Assigned_Course__c> prevSequentialCourses = [SELECT Id
                                                                        FROM Assigned_Course__c 
                                                                        WHERE Assigned_Curriculum__c =: aCourse.Assigned_Curriculum__c
                                                                        AND Id !=: aCourse.Id
                                                                        AND Order__c =: prevOrder
                                                                        AND Inactive__c = false
                                                                        LIMIT 1];

                        if(!prevSequentialCourses.isEmpty()){
                            rd.put('prevSequentialItem', prevSequentialCourses.get(0));
                        }
                    }

                    formattedAssignedItem.put('sequenced', aCourse.Assigned_Curriculum__r.Curriculum__r.Sequenced__c);
                }
            } else {
                List<String> allowedStatuses = new List<String>{'Active'};
            
                if(isPreview){
                    allowedStatuses.add('Draft');
                }

                List<Course_Asset__c> cas = [SELECT Id, Asset__c, Asset__r.RecordType.DeveloperName, Asset__r.Name, Asset__r.Description__c, Asset__r.Time_Estimate__c, Elective_Asset__c, Required__c,
                                                    Asset__r.Assessment_Type__c, Objective__c, Course__c, Course__r.Name
                                              FROM Course_Asset__c
                                              WHERE Course__c =: learningContentId
                                              AND Asset__r.Status__c =: allowedStatuses
                                              WITH USER_MODE
                                              ORDER BY Order__c ASC];

                for(Course_Asset__c ca : cas){
                    formattedChildItems.add(formatLearningItem(ca));
                }
            }
            // add registered session ///
            registeredSessionsOnCourseEvent(lp.Id, formattedChildItems);
            ////
            
            rd.put('assignedItem', formattedAssignedItem);
            rd.put('childItems', formattedChildItems);
        } catch (Exception e) {
            rd.addError(e);            
        }

        return rd;
    }

    public static ResponseData getAssetData(Id objId, String parentId, String objType) {
        ResponseData rd = new ResponseData();

        String learningContentId;
        String assignedId;

        if(objType == 'Asset__c'){
            learningContentId = objId;

            List<Assignment__c> assignments = [SELECT Id, Learner_Profile__c 
                                                FROM Assignment__c
                                                WHERE Asset__c =: objId
                                                AND Learner_Profile__c =: lp.Id
                                                AND Assigned_Course__c = null
                                                AND Inactive__c = false
                                                WITH USER_MODE
                                                ORDER BY CreatedDate DESC];

            if(!assignments.isEmpty()){
                assignedId = assignments.get(0).Id;
            }
        } else {
            assignedId = objId;

            Assignment__c assignment = [SELECT Asset__c, Learner_Profile__c
                                        FROM Assignment__c
                                        WHERE Id =: objId
                                        AND Inactive__c = false
                                        WITH USER_MODE];

            learningContentId = assignment.Asset__c;
        }

        List<Asset__c> parentItems = [SELECT Id, Name, Mandatory_Session_Count__c, Content__c, Description__c, Objective__c, RecordTypeId, Media_Type__c, Show_Num_of_Answers__c,
                                            RecordType.DeveloperName, Assessment_Type__c, Assessor_Type__c, Attestation_Text__c, Url__c, Trailhead_Module_Id__c, Trailhead_Namespace__c,
                                            Learner_Instructions__c, Assessor_Instructions__c
                                      FROM Asset__c
                                      WHERE Id =: learningContentId
                                      WITH USER_MODE];

        if(parentItems.isEmpty()){
            rd.addError('No Asset was found with the Id: ' + learningContentId);
            return rd;
        }

        Asset__c learningContent = parentItems.get(0);
        sessionListItemsByAssetId = new Map<String, List<SessionManager.sessionListItem>>();

        if(learningContent.RecordType.DeveloperName == 'Event'){
            getEventData(learningContent.Id);
        }

        Map<String, Object> formattedLearningContent = formatLearningItem(learningContent);
        Map<String, Object> formattedAssignedItem;

        if(parentId != null){
            List<Course_Asset__c> ca = [SELECT Id, Objective__c FROM Course_Asset__c WHERE Asset__c =: learningContentId AND Course__c =: parentId WITH USER_MODE];
            
            if(!ca.isEmpty()){
                formattedLearningContent.put('customObjective', ca[0].Objective__c);
            }
        }


        rd.put('learningContent', formattedLearningContent);

        // learning proficiency level
        List<Content_Tag__c> tag = [SELECT Id, Proficiency_Level__c FROM Content_Tag__c WHERE Asset__c =: learningContentId AND Proficiency_Level__c != NULL LIMIT 1];
        if(!tag.isEmpty()) {
            rd.put('proficiencyLevel', tag[0].Proficiency_Level__c);
        }

        Assignment__c assignedItem;
        Boolean isSkillAssessment = learningContent.RecordType.DeveloperName == 'Skills_Assessment';

        if(String.isNotEmpty(assignedId)){
            List<Assignment__c> assignedItems = [SELECT Id, Asset__c, Asset__r.Name, Asset__r.RecordType.DeveloperName, CreatedDate, Assigned_Course__c, Assigned_Course__r.Course__r.Name, Assigned_Course__r.Course__r.Sequenced__c, Assigned_Course__r.Order__c, Assigned_Curriculum__c, Assigned_Learning__c, Course__r.Name, Course__r.Survey_URL__c, 
                                                        Course__r.Send_Survey_Notification__c, Course_Asset__c, Course_Asset__r.Objective__c, Course_Asset__r.Required__c, Course_Asset__r.Elective_Asset__c,  Due_Date__c, Learner_Profile__c, Learner_Profile__r.User__c, Queue_Position__c, Self_Assigned__c, Media__c, Media_Url__c, Completed__c, Completion_Date__c, Order__c, Asset__r.Show_Num_of_Answers__c,
                                                        Time_Estimate_Minutes__c, Time_Estimate__c, Asset__r.Block_Unenrollment__c, Assigned_Course__r.Course__r.Block_Unenrollment__c, Mandatory_Session_Count__c, Required__c, Elective_Asset__c,
                                                        Assessor__c, Assessor_Type__c,
                                                        (SELECT Id FROM Assessment_Response__r)
                                                 FROM Assignment__c
                                                 WHERE Id =: assignedId
                                                 AND Inactive__c = false
                                                 WITH USER_MODE];

            if(assignedItems.isEmpty()){
                rd.put('navToLearningContent', true);
                // rd.addError('No Assignment was found with the Id: ' + assignedId);
                return rd;
            }

            assignedItem = assignedItems.get(0);

            if(assignedItem.Learner_Profile__r.User__c != UserInfo.getUserId() && (assignedItem.Asset__r.RecordType.DeveloperName == 'In_App_Assessment' && lp.Id != assignedItem.Assessor__c)){
                rd.put('navToLearningContent', true);
                // rd.addError('You are not the owner of this assignment');
                return rd;
            }

            formattedAssignedItem = formatLearningItem(assignedItem);
            
            if(assignedItem.Assigned_Course__c != null){
                List<Assignment__c> nextAssignments = [SELECT Id, Asset__r.Name, Asset__r.RecordType.DeveloperName, Asset__r.Assessment_Type__c
                                                       FROM Assignment__c 
                                                       WHERE Assigned_Course__c =: assignedItem.Assigned_Course__c
                                                       AND Completed__c = false
                                                       AND Id !=: assignedItem.Id
                                                       AND Inactive__c = false
                                                       ORDER BY Order__c ASC
                                                       LIMIT 1];
                
                if(!nextAssignments.isEmpty()){
                    rd.put('nextAssignment', nextAssignments.get(0));
                }

                Decimal nextOrder = assignedItem.Order__c + 1;
                Decimal prevOrder = assignedItem.Order__c - 1;

                List<Assignment__c> nextSequentialAssignment = [SELECT Id, Asset__r.RecordType.DeveloperName, Asset__r.Assessment_Type__c
                                                                FROM Assignment__c 
                                                                WHERE Assigned_Course__c =: assignedItem.Assigned_Course__c
                                                                AND Id !=: assignedItem.Id
                                                                AND Order__c =: nextOrder
                                                                AND Inactive__c = false
                                                                LIMIT 1];

                if(!nextSequentialAssignment.isEmpty()){
                    rd.put('nextSequentialItem', nextSequentialAssignment.get(0));
                }

                if(prevOrder >= 0){
                    List<Assignment__c> prevSequentialAssignment = [SELECT Id, Asset__r.RecordType.DeveloperName, Asset__r.Assessment_Type__c
                                                                    FROM Assignment__c 
                                                                    WHERE Assigned_Course__c =: assignedItem.Assigned_Course__c
                                                                    AND Id !=: assignedItem.Id
                                                                    AND Order__c =: prevOrder
                                                                    AND Inactive__c = false
                                                                    LIMIT 1];

                    if(!prevSequentialAssignment.isEmpty()){
                        rd.put('prevSequentialItem', prevSequentialAssignment.get(0));
                    }
                } 

                formattedAssignedItem.put('sequenced', assignedItem.Assigned_Course__r.Course__r.Sequenced__c);
            }

            if(assignedItem.Assigned_Curriculum__c != null){
                List<Assigned_Course__c> nextACourses = [SELECT Id, Course__r.Name
                                                         FROM Assigned_Course__c 
                                                         WHERE Assigned_Curriculum__c =: assignedItem.Assigned_Curriculum__c
                                                         AND Completed__c = false
                                                         AND Id !=: assignedItem.Assigned_Course__c
                                                         AND Inactive__c = false
                                                         ORDER BY Order__c ASC
                                                         LIMIT 1];
                
                if(!nextACourses.isEmpty()){
                    rd.put('nextACourse', nextACourses.get(0));
                }
            }
        }

        if(learningContent.RecordType.DeveloperName == 'Assessment' || learningContent.RecordType.DeveloperName == 'Quiz' || learningContent.RecordType.DeveloperName == 'In_App_Assessment'){
            String assignedLearnerId = assignedItem?.Learner_Profile__c;

            //use assignments lpId instead of class lp.Id as the current user could be the assessor and the one that is assigned the assessment
            Map<String, Object> quizData = learningItemDetailQuiz.getQuizData(learningContent.Id, assignedId, assignedLearnerId, false, false);
            formattedLearningContent.put('quizData', quizData);
        }
        
        //If we have a completed skill assessment don't bring it back to the front end as
        //we need to allow the end user to retake the assessment
        if(isSkillAssessment && assignedItem?.Completed__c == true && String.isEmpty(parentId) && objType == 'Asset__c'){
            formattedAssignedItem = null;
        }

        rd.put('assignedItem', formattedAssignedItem);

        return rd;
    }

    public static ResponseData getCurriculumData(Id objId, String objType) {
        ResponseData rd = new ResponseData();

        String learningContentId;
        String assignedId;

        if(objType == 'Curriculum__c'){
            learningContentId = objId;

            List<Assigned_Curriculum__c> aCurrics = [SELECT Id 
                                                     FROM Assigned_Curriculum__c
                                                     WHERE Curriculum__c =: objId
                                                     AND Learner_Profile__c =: lp.Id
                                                     AND Inactive__c = false
                                                     WITH USER_MODE];

            if(!aCurrics.isEmpty()){
                assignedId = aCurrics.get(0).Id;
            }
        } else {
            assignedId = objId;

            Assigned_Curriculum__c aCurric = [SELECT Curriculum__c
                                              FROM Assigned_Curriculum__c
                                              WHERE Id =: objId
                                              AND Inactive__c = false
                                              WITH USER_MODE];

            learningContentId = aCurric.Curriculum__c;
        }

        List<Curriculum__c> parentItems = [SELECT Id, Name, Description__c, Objective__c, Learner_Instructions__c, Electives_To_Complete__c, Sequenced__c
                                           FROM Curriculum__c
                                           WHERE Id =: learningContentId
                                           WITH USER_MODE];

        if(parentItems.isEmpty()){
            rd.addError('No Curriculum was found with the Id: ' + learningContentId);
            return rd;
        }

        Map<String, Object> formattedLearningContent = formatLearningItem(parentItems.get(0));
        Map<String, Object> formattedAssignedItem;
        List<Map<String, Object>> formattedChildItems = new List<Map<String, Object>>();
        rd.put('learningContent', formattedLearningContent);

        // learning proficiency level
        List<Content_Tag__c> tag = [SELECT Id, Proficiency_Level__c FROM Content_Tag__c WHERE Curriculum__c =: learningContentId AND Proficiency_Level__c != NULL LIMIT 1];
        if(!tag.isEmpty()) {
            rd.put('proficiencyLevel', tag[0].Proficiency_Level__c);
        }

        if(String.isNotEmpty(assignedId)){
            List<Assigned_Curriculum__c> assignedItems = [SELECT Id, Due_Date__c, Number_of_Courses__c, Number_of_Completed_Required_Courses__c, Number_of_Required_Courses__c, Number_of_Completed_Courses__c,
                                                                 CreatedDate, Time_Estimate_Minutes__c, Time_Estimate__c, Completed__c, Self_Assigned__c, Learner_Profile__c, Learner_Profile__r.User__c,
                                                                 Curriculum__r.Block_Self_Enrollment__c, Curriculum__r.Block_Unenrollment__c, Curriculum__r.Name, Number_of_Required_Electives__c, Number_of_Completed_Electives__c,
                                                          (
                                                              SELECT Id, Due_Date__c, Number_Of_Assets__c, Number_of_Completed_Required_Assets__c, Number_of_Required_Assets__c, Number_of_Required_Electives__c, Number_of_Completed_Electives__c, Curriculum_Course__r.Order__c,
                                                                     CreatedDate, Course__r.Name, Course__r.Description__c, Course__r.Objective__c, Time_Estimate_Minutes__c, Time_Estimate__c, Completed__c, Curriculum_Course__r.Required__c, Curriculum_Course__r.Elective_Course__c,
                                                                     Learner_Profile__c, Learner_Profile__r.User__c, Self_Assigned__c, Required__c, Elective_Asset__c
                                                              FROM Assigned_Courses__r
                                                              WHERE Inactive__c = false
                                                              ORDER BY Order__c ASC
                                                          )
                                                          FROM Assigned_Curriculum__c
                                                          WHERE Id =: assignedId
                                                          AND Inactive__c = false
                                                          WITH USER_MODE];

            if(assignedItems.isEmpty()){
                rd.put('navToLearningContent', true);
                // rd.addError('No Assigned Curriculum was found with the Id: ' + assignedId);
                return rd;
            }

            Assigned_Curriculum__c assignedItem = assignedItems.get(0);

            if(assignedItem.Learner_Profile__r.User__c != UserInfo.getUserId()){
                rd.put('navToLearningContent', true);
                // rd.addError('You are not the owner of this assigned curriculum');
                return rd;
            }


            formattedAssignedItem = formatLearningItem(assignedItem);

            for(Assigned_Course__c aCourse : assignedItem.Assigned_Courses__r){
                formattedChildItems.add(formatLearningItem(aCourse));
            }
        } else {
            List<String> allowedStatuses = new List<String>{'Active'};
            
            if(isPreview){
                allowedStatuses.add('Draft');
            }

            List<Curriculum_Course__c> ccs = [SELECT Id, Course__c, Course__r.Name, Course__r.Description__c, Course__r.Objective__c, Course__r.Time_Estimate__c, Elective_Course__c, Required__c, Objective__c,
                                                     Curriculum__c, Curriculum__r.Name
                                              FROM Curriculum_Course__c
                                              WHERE Curriculum__c =: learningContentId
                                              AND Course__r.Status__c =: allowedStatuses
                                              WITH USER_MODE
                                              ORDER BY Order__c ASC];

            for(Curriculum_Course__c cc : ccs){
                formattedChildItems.add(formatLearningItem(cc));
            }
        }
        
        rd.put('assignedItem', formattedAssignedItem);
        rd.put('childItems', formattedChildItems);

        return rd;
    }

    public static List<Map<String, Object>> fomattedCaseComment(List<sObject> comments) {
        List<Map<String, Object>> formattedComments = new List<Map<String, Object>>();
        for(sObject caseComment : comments) {
            Map<String, Object> itemMap = caseComment.getPopulatedFieldsAsMap().clone();
            DateTime createdDate = (DateTime)itemMap.get('CreatedDate');
            String commentTime = '';
                                   
            Long currentDate = Datetime.Now().getTime();
            Long oldDate = createdDate.getTime();
            Long milliseconds = currentDate - oldDate;
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            Long hours = minutes / 60;
            Long days = hours / 24;
            
            if(minutes >= 0 && minutes < 15) {
                commentTime = 'just now';
            } else if (minutes >= 15 && minutes < 60) {
                commentTime = 'few minutes ago';
            } else if(hours >= 1 && hours < 24) {
                commentTime = hours + ' hour ago';
            } else if(days == 1) {
                commentTime = 'a day ago';
            } else {
                commentTime = days +' day ago';
            }
            itemMap.put('commentTime', commentTime);
            Name nm = (Name)itemMap.get('CreatedBy');
            String shortendName;
            if(nm.FirstName != null && nm.LastName != null) {
                shortendName = nm.FirstName.subString(0,1) + nm.LastName.subString(0,1);
                itemMap.put('name',  nm.FirstName+' '+nm.LastName);
            } else {
                shortendName = nm.LastName.subString(0,1);
                itemMap.put('name', nm.LastName);
            }              
            itemMap.put('shortendName', shortendName);
            formattedComments.add(itemMap);
        }
        return formattedComments;
    }

    public static Map<String, Object> formatLearningItem(sObject obj){
        String sObjType = ((Id)obj.get('Id')).getSObjectType() + '';
        Map<String, Object> itemMap = obj.getPopulatedFieldsAsMap().clone();
        List<String> assignedItemTypes = new List<String>{'Assigned_Curriculum__c', 'Assigned_Course__c', 'Assignment__c'};

        if(sObjType == 'Case') {
            DateTime createdDate = (DateTime)obj.get('CreatedDate');
            itemMap.put('formattedAssignedDate', createdDate.formatGMT('MMM dd yyyy'));
            String val = (String)obj.get('CaseNumber');
            itemMap.put('name', val);
        } else if(assignedItemTypes.contains(sObjType)){
            DateTime createdDate = (DateTime)obj.get('CreatedDate');

            if(obj.get('Due_Date__c') != null){
                DateTime dueDate = DateTime.newInstanceGMT((Date)obj.get('Due_Date__c'), Time.newInstance(0, 0, 0, 0));
                itemMap.put('formattedDueDate', dueDate.formatGMT('MMM dd, yyyy'));
            }
    
            itemMap.put('formattedAssignedDate', createdDate.formatGMT('MMM dd, yyyy'));
        } else if (sObjType == 'Session__c'){
            formatSessionTimes(itemMap);
        }

        itemMap.put('type', sObjType);

        if(sObjType == 'Assignment__c' || sObjType == 'Asset__c' || sObjType =='Course_Asset__c'){
            Asset__c assetObj;

            if(sObjType == 'Assignment__c'){
                Assignment__c assignment = (Assignment__c)obj;
                assetObj = assignment.Asset__r;
            } else if(sObjType == 'Asset__c'){
                assetObj = (Asset__c)obj;
            } else {
                Course_Asset__c ca = (Course_Asset__c)obj;
                assetObj = ca.Asset__r;
            }

            itemMap.put('recordType', assetObj.RecordType.DeveloperName);

            if(assetObj.RecordType.DeveloperName == 'Event'){
                //session and session groups
                Integer totalSessionsAvailiable = totalSessionsByAssetId.containsKey(assetObj.Id) ? totalSessionsByAssetId.get(assetObj.Id) : 0;
                List<SessionManager.sessionListItem> availiableSessions = sessionListItemsByAssetId.containsKey(assetObj.Id) ? sessionListItemsByAssetId.get(assetObj.Id) : new List<SessionManager.sessionListItem>();
                List<SessionManager.sessionListItem> mySessions = mySessionsByAssetId.containsKey(assetObj.Id) ? mySessionsByAssetId.get(assetObj.Id) : new List<SessionManager.sessionListItem>();
                List<SessionManager.sessionListItem> waitlistedSessions = waitlistedSessionsByAssetId.containsKey(assetObj.Id) ? waitlistedSessionsByAssetId.get(assetObj.Id) : new List<SessionManager.sessionListItem>();
                List<SessionManager.sessionListItem> attendedSessions = attendedSessionsByAssetId.containsKey(assetObj.Id) ? attendedSessionsByAssetId.get(assetObj.Id) : new List<SessionManager.sessionListItem>();

                setEventFilters(itemMap, availiableSessions);

                itemMap.put('totalSessionsAvailiable', totalSessionsAvailiable);
                itemMap.put('availiableSessions', availiableSessions);
                itemMap.put('mySessions', mySessions);
                itemMap.put('waitlistedSessions', waitlistedSessions);
                itemMap.put('attendedSessions', attendedSessions);
            }
        }

        return itemMap;
    }

    private static Set<String> types = new Set<String>();
    private static Set<String> regions = new Set<String>();
    private static Set<String> offices = new Set<String>();
    private static List<Object> typeOptions = new List<Object>();
    private static List<Object> regionOptions = new List<Object>();
    private static List<Object> officeOptions = new List<Object>();

    private static void setEventFilters(Map<String, Object> itemMap, List<SessionManager.sessionListItem> availiableSessions){
        types = new Set<String>();
        regions = new Set<String>();
        offices = new Set<String>();
        typeOptions = new List<Object>{new Map<String, Object>{'label' => 'All', 'value' => 'All'}};
        regionOptions = new List<Object>{new Map<String, Object>{'label' => 'All', 'value' => 'All'}};
        officeOptions = new List<Object>{new Map<String, Object>{'label' => 'All', 'value' => 'All'}};

        for(SessionManager.sessionListItem sessionListItem : availiableSessions){
            if(sessionListItem.groupSessions != null && !sessionListItem.groupSessions.isEmpty()){
                for(Map<String, Object> sessionMap : sessionListItem.groupSessions){
                    createFilterOptions(sessionMap);
                }
            } else {
                createFilterOptions(sessionListItem.session);
            }
        }

        itemMap.put('typeOptions', typeOptions);
        itemMap.put('regionOptions', regionOptions);
        itemMap.put('officeOptions', officeOptions);
    }

    private static void createFilterOptions(Map<String, Object> sessionMap){
        String sessionType = (String)sessionMap.get('Session_Type__c');
        String region = (String)sessionMap.get('Region__c');
        Office_Location__c officeLocation = (Office_Location__c)sessionMap.get('Office_Location__r');
        Map<String, Object> location = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(sessionMap.get('Location__c')));
        // Location__c location = (Location__c)sessionMap.get('Location__c');


        if(sessionType != null && !types.contains(sessionType)){
            types.add(sessionType);
            typeOptions.add(new Map<String, Object>{
                'label' => sessionType,
                'value' => sessionType
            });
        }

        if(region != null && !regions.contains(region)){
            regions.add(region);
            regionOptions.add(new Map<String, Object>{
                'label' => region,
                'value' => region
            });
        }

        // using new-location field
        // if(officeLocation != null && !offices.contains(officeLocation.Id)){
        //     offices.add(officeLocation.Id);
        //     officeOptions.add(new Map<String, Object>{
        //         'label' => officeLocation.City__c,
        //         'value' => officeLocation.Id
        //     });
        // } else if(location != null && !offices.contains((String)location.get('city'))) {
        //     offices.add((String)location.get('city'));
        //     officeOptions.add(new Map<String, Object>{
        //         'label' => (String)location.get('city'),
        //         'value' => (String)location.get('city')
        //     });
        // }
        if(location != null && !offices.contains((String)location.get('city'))) {
            offices.add((String)location.get('city'));
            officeOptions.add(new Map<String, Object>{
                'label' => (String)location.get('city'),
                'value' => (String)location.get('city')
            });
        }
    }

    @AuraEnabled
    public static ResponseData addCaseComment(String commentData) {
        ResponseData rd = new ResponseData();
        try {
            String actRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ACT_Learning_Case_Type').getRecordTypeId();
            Map<String, Object> commentRecord = (Map<String, Object>)JSON.deserializeUntyped(commentData);
            String caseId = (String)commentRecord.get('caseId');
            String commentStr = (String)commentRecord.get('comment');
            Boolean hasAttachment = false;
            List<Object> fileList = (List<Object>)commentRecord.get('uploadedFiles');
            if(!String.isBlank(commentStr)) {
                CaseComment comment = new CaseComment(
                    CommentBody = commentStr,
                    ParentId = caseId
                );

                insert as user comment;                
            }           
            
            if(fileList != null && !fileList.isEmpty()) {
                hasAttachment = true;
                learningSupport.addAttachments(caseId, fileList);                
            }
            if(String.isNotEmpty(commentStr) || hasAttachment) {
                if(!learningSupport.flipCaseStatus(caseId)) {
                    rd.addError('Error occured while adding comment'); 
                }
            }           
        } catch(Exception e) {
            rd.addError(e);
            System.debug('Exception caseManager :: addCaseComment :: '+ e.getMessage() + ':: Line No.:: '+e.getLineNumber()+ ' :: StackTrace :: '+ e.getStackTraceString());
        }
        return rd;
    }

    @AuraEnabled
    public static ResponseData checkCompletion(Id recordId){
        ResponseData rd = new ResponseData();
        
        try {
            String objType = recordId.getSObjectType() + '';
            List<String> allowedObjTypes = new List<String>{'Assignment__c'};

            if(allowedObjTypes.contains(objType)){
                String soqlQuery = 'SELECT Id, Completed__c' +
                                   ' FROM ' + objType +
                                   ' WHERE Id = :recordId';

                List<sObject> records = Database.query(soqlQuery);

                if(!records.isEmpty()){
                    rd.put('completed', (Boolean)records[0].get('Completed__c'));
                }
            }
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData checkAssignedCourseCompleted(String recordId){
        ResponseData rd = new ResponseData();
        
        try {
            List<Assigned_Course__c> ac = [SELECT Id, Completed__c FROM Assigned_Course__c WHERE Id =: recordId];

            if(ac.isEmpty()){
                rd.addError('No Assigned Course was found with the Id: ' + recordId);
                return rd;
            } else {
                rd.put('completed', ac[0].Completed__c);
            }
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    private static void formatSessionTimes(Map<String, Object> itemMap){
        DateTime startTime = (DateTime)itemMap.get('Start_Time_Converted__c');
        DateTime endTime = (DateTime)itemMap.get('End_Time_Converted__c');
        String timezone = UserInfo.getTimeZone().getId();
        String displayTimezone = UserInfo.getTimeZone().getDisplayName().substringBetween(') ', ' (');

        itemMap.put('formattedStartTime', startTime.format('MMM dd, yyyy h:mm a', timezone));
        itemMap.put('formattedEndTime', endTime.format('h:mm a', timezone));
        itemMap.put('userTimeZone', displayTimezone);
    }
    
    public static void registeredSessionsOnCourseEvent(String lpId, List<Map<String, Object>> childItems) {
        Map<String, List<Map<String, Object>>> registeredSessionByEventId = new Map<String, List<Map<String, Object>>>();
        // Map<String, Object> contentById = new Map<String, Object>();
        List<String> eventIds = new List<String>();
        for(Map<String, Object> obj : childItems) {
            if((String)obj.get('recordType') == 'Event') {
                eventIds.add((String)obj.get('Asset__c'));
            }
        }
        if(!eventIds.isEmpty()) {
            for(Session__c session : [SELECT Id, CreatedDate, Name, Description__c, Objective__c, Session_Type__c, Start_Date__c, Start_Time_Converted__c, End_Time_Converted__c, Time_Zone__c, Region__c,
                                        Share_Url__c, Asset__c,
                                        (
                                            SELECT Id, Status__c 
                                            FROM Assigned_Sessions__r 
                                            WHERE Learner_Profile__c =: lpId 
                                            AND Status__c = 'Registered'
                                        )
                                        FROM Session__c 
                                        WHERE Asset__c IN: eventIds
                                        AND Start_Date__c >= TODAY
                                        WITH USER_MODE
                                        ORDER BY Start_Date__c ASC, Start_Time__c ASC]) {
                if(session.Assigned_Sessions__r != null && !session.Assigned_Sessions__r.isEmpty()) {
                    String timezone = UserInfo.getTimeZone().getId();
                    String startTime =  session.Start_Time_Converted__c.format('MMM dd, yyyy h:mm a', timezone);
                    String month = '';
                    String day = '';
                    if(String.isNotBlank(startTime)) {
                        List<String> strList = startTime.split(' ');
                        month = !strList.isEmpty() && strList[0] != null ? strList[0] : '';
                        day = !strList.isEmpty() && strList[1] != null ? strList[1].replace(',','') : '';
                    }
                    if(!registeredSessionByEventId.containsKey(session.Asset__c)) {
                        registeredSessionByEventId.put(session.Asset__c, new List<Map<String, Object>>{
                            new Map<String, Object> {
                                'sessionId' => session.Id,
                                'sessionName' => session.Name,
                                'type' => session.Session_Type__c,
                                'month' => (Object)month,
                                'day' => (Object)day
                            }
                        }); 
                    } else {
                        registeredSessionByEventId.get(session.Asset__c).
                            add(new Map<String, Object> {
                                'sessionId' => session.Id,
                                'sessionName' => session.Name,
                                'type' => session.Session_Type__c,
                                'month' => (Object)month,
                                'day' => (Object)day
                            }
                        );
                    }         
                }
            } 
            for(Map<String, Object> obj : childItems) {
                if((String)obj.get('recordType') == 'Event') {
                    String eventId = (String)obj.get('Asset__c');
                    if(registeredSessionByEventId.containsKey(eventId)) {
                        obj.put('registeredSessions', registeredSessionByEventId.get(eventId));
                    } else {
                        obj.put('registeredSessions', new List<Map<String, Object>>());
                    }
                }
            }       
        }         
    }
}