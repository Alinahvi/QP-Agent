public with sharing class learnerHome {
    @AuraEnabled
    public static ResponseData getData(){
        ResponseData rd = new ResponseData();
        
        try {
            List<Learner_Profile__c> lps = [SELECT Id, Name, Title__c, Business_Title__c, User__c, User__r.MediumPhotoUrl, Show_Walkthrough_Modal__c
                                            FROM Learner_Profile__c
                                            WHERE User__c =: UserInfo.getUserId()
                                            AND Status__c = 'Active'
                                            WITH USER_MODE];
            if(lps.isEmpty()){
                rd.addError('No Learner Profile found. Please contact support for help');
                return rd;
            }
                                            
            Learner_Profile__c lp = lps.get(0);
            List<sObject> assignedItems = new List<sObject>();
            List<Session__c> assignedSessions = new List<Session__c>();
            List<Map<String, Object>> formattedAssignedItems = new List<Map<String, Object>>();
            List<Map<String, Object>> formattedSelfAssignedItems = new List<Map<String, Object>>();
            List<SessionManager.sessionListItem> formattedAssignedSessions = new List<SessionManager.sessionListItem>();
            Map<String, List<Map<String, Object>>> registeredSessionByAssignmentId = new Map<String, List<Map<String, Object>>>();
            
            assignedItems.addAll([SELECT Id, Due_Date__c, Number_of_Courses__c, Number_of_Completed_Required_Courses__c, Number_of_Required_Courses__c, Number_of_Completed_Electives__c, Number_of_Required_Electives__c, Self_Assigned__c, Content_Distribution_Organization__c, Assigned_Learning__r.OU_Leader__r.Name,
                                         CreatedDate, Curriculum__r.Name, Curriculum__r.Description__c, Curriculum__r.Block_Unenrollment__c, Time_Estimate_Minutes__c, Time_Estimate__c, Completed__c, Recommended_Learning__r.Content_Distribution_Organization__c, Recommended_Learning__r.OU_Leader__r.Name, Curriculum__r.Block_Self_Enrollment__c
                                  FROM Assigned_Curriculum__c
                                  WHERE Learner_Profile__c =: lp.Id
                                  AND Completed__c = false
                                  AND Inactive__c = false
                                  WITH USER_MODE]);

            assignedItems.addAll([SELECT Id,  Due_Date__c, Number_Of_Assets__c, Number_of_Completed_Required_Assets__c, Number_of_Required_Assets__c, Number_of_Completed_Electives__c, Number_of_Required_Electives__c, Self_Assigned__c, Content_Distribution_Organization__c, Assigned_Learning__r.OU_Leader__r.Name,
                                         CreatedDate, Course__r.Name, Course__r.Description__c, Course__r.Block_Unenrollment__c, Time_Estimate_Minutes__c, Time_Estimate__c, Completed__c, Recommended_Learning__r.Content_Distribution_Organization__c, Recommended_Learning__r.OU_Leader__r.Name, Course__r.Block_Self_Enrollment__c
                                  FROM Assigned_Course__c
                                  WHERE Learner_Profile__c =: lp.Id
                                  AND Completed__c = false
                                  AND Inactive__c = false
                                  AND Assigned_Curriculum__c = null
                                  WITH USER_MODE]);

            assignedSessions.addAll([SELECT Id, CreatedDate, Name, Description__c, Objective__c, Session_Type__c, Start_Date__c, Start_Time_Converted__c, End_Time_Converted__c, Time_Zone__c, Region__c,
                                            Share_Url__c, Asset__c,
                                            (
                                                SELECT Id, Status__c, Assignment__c, Registration_Type__c, OU_Leader__c, OU_Leader__r.Name, Content_Distribution_Organization__c
                                                FROM Assigned_Sessions__r
                                                WHERE Learner_Profile__c =: lp.Id
                                                AND Status__c = 'Registered'
                                              )
                                     FROM Session__c 
                                     WHERE Id IN (SELECT Session__c FROM Assigned_Session__c WHERE Learner_Profile__c =: lp.Id AND Status__c = 'Registered')
                                     WITH USER_MODE
                                     ORDER BY Start_Date__c ASC, Start_Time__c ASC]);

            List<Assignment__c> assignments = [SELECT Id, CreatedDate, Asset__c, Asset__r.RecordType.DeveloperName, Due_Date__c, Asset__r.Name, Asset__r.Description__c, Self_Assigned__c, Content_Distribution_Organization__c, Assigned_Learning__r.OU_Leader__r.Name,
                                                      Asset__r.Assessment_Type__c, Asset__r.Mandatory_Session_Count__c, Time_Estimate_Minutes__c, Time_Estimate__c, Completed__c, Recommended_Learning__r.Content_Distribution_Organization__c, Recommended_Learning__r.OU_Leader__r.Name, Mandatory_Session_Count__c,
                                                      (
                                                          SELECT Id, Content_Distribution_Organization__c, OU_Leader__c, OU_Leader__r.Name
                                                          FROM Assigned_Sessions__r
                                                          WHERE Status__c = 'Registered'
                                                          ORDER BY CreatedDate DESC
                                                          LIMIT 1
                                                      )
                                                FROM Assignment__c
                                                WHERE Learner_Profile__c =: lp.Id
                                                AND Completed__c = false
                                                AND Inactive__c = false
                                                AND Assigned_Curriculum__c = null
                                                AND Assigned_Course__c = null
                                                WITH USER_MODE];

            assignedItems.addAll(assignments);

            Set<String> assetIds = new Set<String>();

            for(Assignment__c assignment : assignments){
                if(assignment.Asset__r.RecordType.DeveloperName == 'Event'){
                    assetIds.add(assignment.Asset__c);
                }
            }

            learningItemDetail.totalSessionsByAssetId = new Map<String, Integer>();
            
            for(Asset__c asset : [SELECT Id, 
                                    (
                                        SELECT Id
                                        FROM Sessions__r
                                        WHERE Start_Date__c >= TODAY
                                    )
                                  FROM Asset__c
                                  WHERE Id =: assetIds
                                  WITH USER_MODE]){
                learningItemDetail.totalSessionsByAssetId.put(asset.Id, asset.Sessions__r.size());
            }

            for(sOBject obj : assignedItems){
                Boolean selfAssigned = (Boolean)obj.get('Self_Assigned__c');
                if(selfAssigned){
                    formattedSelfAssignedItems.add(learningItemDetail.formatLearningItem(obj));
                } else {
                    formattedAssignedItems.add(learningItemDetail.formatLearningItem(obj));
                }
                // String sObjType = ((Id)obj.get('Id')).getSObjectType() + '';
                // DateTime createdDate = (DateTime)obj.get('CreatedDate');
                // DateTime dueDate = DateTime.newInstanceGMT((Date)obj.get('Due_Date__c'), Time.newInstance(0, 0, 0, 0));

                // Map<String, Object> itemMap = obj.getPopulatedFieldsAsMap().clone();

                // itemMap.put('formattedAssignedDate', createdDate.formatGMT('MMM dd yyyy'));
                // itemMap.put('formattedDueDate', dueDate.formatGMT('MMM dd yyyy'));
                // if(sObjType == 'Assignment__c'){
                //     Assignment__c assignment = (Assignment__c)obj;
                //     String recordType = assignment.Asset__r.RecordType.DeveloperName;
                //     // Asset__c asset = (Asset__c)obj.getSObject('Asset__r');
                //     itemMap.put('type', recordType);

                //     if(recordType == 'Event'){
                //         Asset__c asset = assetById.get(assignment.Asset__c);
                //         itemMap.put('sessionsAvailiable', asset.Sessions__r.size());
                //     }
                // } else {
                //     itemMap.put('type', sObjType);
                // }

                // formattedAssignedItems.add(itemMap);
            }

            for (Session__c session : assignedSessions) {
                SessionManager.sessionListItem item = new SessionManager.sessionListItem(session);
                // formattedAssignedSessions.add(new SessionManager.sessionListItem(session));
                List<Assigned_Session__c> asg = session.Assigned_Sessions__r ;
                if(asg != null && !asg.isEmpty() && session.Start_Date__c >= System.today()) {
                    Map<String, Object> sessionData = (Map<String, Object>)item.session;
                    List<String> strList = ((String)sessionData.get('startTime')) != null ? ((String)sessionData.get('startTime')).split(' ') : new List<String>();
                    String month = !strList.isEmpty() && strList[0] != null ? strList[0] : '';
                    String day = !strList.isEmpty() && strList[1] != null ? strList[1].replace(',','') : '';
                    for(Assigned_Session__c data : asg) {
                        if(!registeredSessionByAssignmentId.containsKey(data.Assignment__c)) {                            
                            registeredSessionByAssignmentId.put(data.Assignment__c, new List<Map<String, Object>>{
                                new Map<String, Object> {
                                    'sessionId' => sessionData.get('Id'),
                                    'sessionName' => sessionData.get('Name'),
                                    'type' => sessionData.get('Session_Type__c'),
                                    'month' => (Object)month,
                                    'day' => (Object)day
                                }
                            });                           
                        } else {
                            registeredSessionByAssignmentId.get(data.Assignment__c).
                                add(new Map<String, Object> {
                                    'sessionId' => sessionData.get('Id'),
                                    'sessionName' => sessionData.get('Name'),
                                    'type' => sessionData.get('Session_Type__c'),
                                    'month' => (Object)month,
                                    'day' => (Object)day
                                }
                            );
                        }
                    }
                }
                formattedAssignedSessions.add(item); //new SessionManager.sessionListItem(session));
            }

            formattedAssignedItems = setRegisterdSessionsOnEventCard(formattedAssignedItems, registeredSessionByAssignmentId);
            formattedSelfAssignedItems = setRegisterdSessionsOnEventCard(formattedSelfAssignedItems, registeredSessionByAssignmentId);
            
            rd.put('learningItems', formattedAssignedItems);
            rd.put('electiveLearningItems', formattedSelfAssignedItems);
            rd.put('assignedSessions', formattedAssignedSessions);
            // rd.put('totalAssessorAssignments', getTotalAssessorAssignments(lp.Id));            
            // rd.put('inAppToAssess', getAssessorAssignments(lp.Id));
            // rd.put('skillAssessmentsToAssess', getManagerAssessements(lp.Id)); //skill assessments
            rd.put('lp', lp);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public static List<Map<String, Object>> setRegisterdSessionsOnEventCard(List<Map<String, Object>> formatedItem, Map<String, List<Map<String, Object>>> registeredSessionByAssignmentId) {
        for(Map<String, Object> temp : formatedItem) {
            String event = (String)temp.get('recordType');
            String assignmentId = (String)temp.get('Id');
            List<Map<String, Object>> registeredSessions = new List<Map<String, Object>>();
            if(String.isNotBlank(event) && event == 'Event' && 
            String.isNotBlank(assignmentId) && registeredSessionByAssignmentId.containsKey(assignmentId)) {
                registeredSessions.addAll(registeredSessionByAssignmentId.get(assignmentId));                    
            }
            temp.put('registeredSessions', registeredSessions);
        }
        return formatedItem;
    }

    public static List<Assignment__c> getManagerAssessements(String lpId){
        String skillAssessmentRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Skills_Assessment').getRecordTypeId();
        return [SELECT Id, Name, Asset__r.Name, Asset__r.RecordType.DeveloperName, Learner_Profile__r.Name, Learner_Profile__r.User__r.SmallPhotoUrl, Due_Date__c
                FROM Assignment__c
                WHERE Assessor__c =: lpId
                AND Inactive__c = false
                AND Asset__r.RecordTypeId =: skillAssessmentRecordTypeId
                AND CreatedDate >= 2024-12-01T00:00:00.000Z
                AND Id IN (SELECT Assignment__c FROM Assessment_Response__c WHERE Assignment__r.Assessor__c =: lpId AND Manager_Submitted__c = false)
                ORDER BY Due_Date__c ASC];
    }

    public static List<Assignment__c> getAssessorAssignments(String lpId){
        List<Assignment__c> assignmentsToAssess = new List<Assignment__c>();

        if(lpId != null){
            String inAppRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('In_App_Assessment').getRecordTypeId();
            assignmentsToAssess = [SELECT Id, Asset__r.RecordType.Name, Asset__r.Name, Asset__r.RecordType.DeveloperName, Learner_Profile__r.Name, 
                                          Learner_Profile__r.User__r.SmallPhotoUrl, Due_Date__c
                                   FROM Assignment__c
                                   WHERE Assessor__c =: lpId
                                   AND Completed__c = false
                                   AND Inactive__c = false
                                   AND Asset__r.RecordTypeId =: inAppRecordTypeId
                                   WITH USER_MODE
                                   ORDER BY Due_Date__c ASC
                                   LIMIT 5];
        }

        return assignmentsToAssess;
    }

    public static Integer getTotalAssessorAssignments(String lpId){
        Integer totalAssessorAssignments = 0;

        if(lpId != null){
            String inAppRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('In_App_Assessment').getRecordTypeId();
            totalAssessorAssignments = [SELECT COUNT()
                                        FROM Assignment__c
                                        WHERE Assessor__c =: lpId
                                        AND Completed__c = false
                                        AND Inactive__c = false
                                        AND Asset__r.RecordTypeId =: inAppRecordTypeId
                                        WITH USER_MODE];
        }

        return totalAssessorAssignments;
    }
}