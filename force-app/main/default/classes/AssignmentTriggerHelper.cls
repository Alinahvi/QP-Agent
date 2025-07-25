public with sharing class AssignmentTriggerHelper {
    public static Set<String> aCourseWithUpdatedCounts;
    //if an assignment was created/updated make its parent assigned course recalculate itself to make sure the counts are accurate
    public static void updateParentCourseCounts(List<Assignment__c> newAssignments, Boolean completionOnly){
        if(aCourseWithUpdatedCounts == null){
            aCourseWithUpdatedCounts = new Set<String>();
        }

        Set<String> aCourseIds = new Set<String>();

        for(Assignment__c assignment : newAssignments){
            if(!aCourseWithUpdatedCounts.contains(assignment.Assigned_Course__c)){
                aCourseIds.add(assignment.Assigned_Course__c);
            }
        }
        
        if(!aCourseIds.isEmpty()){
            List<Assigned_Course__c> aCourses = [SELECT Id, Completed__c,  Course__r.Electives_To_Complete__c, Number_of_Assets__c, Number_of_Completed_Assets__c, Number_of_Completed_Electives__c, 
                                                        Number_of_Completed_Required_Assets__c, Number_of_Required_Assets__c, Number_of_Required_Electives__c,
                                                     (
                                                        SELECT Id, Completed__c, Elective_Asset__c, Required__c
                                                        FROM Assignments__r
                                                        WHERE Inactive__c = false
                                                     )
                                                  FROM Assigned_Course__c
                                                  WHERE Id =: aCourseIds];
            
            for(Assigned_Course__c aCourse : aCourses){
                if(!completionOnly){
                    aCourse.Number_of_Assets__c = aCourse.Assignments__r.size();
                    aCourse.Number_of_Required_Assets__c = 0;
                    aCourse.Number_of_Required_Electives__c = aCourse.Course__r.Electives_To_Complete__c == null ? 0 : aCourse.Course__r.Electives_To_Complete__c;
                }

                aCourse.Number_of_Completed_Assets__c = 0;
                aCourse.Number_of_Completed_Required_Assets__c = 0;
                aCourse.Number_of_Completed_Electives__c = 0;
        
                for(Assignment__c assignment : aCourse.Assignments__r){
                    if(!completionOnly){
                        if(assignment.Required__c){
                            aCourse.Number_of_Required_Assets__c += 1;
                        }
                    }

                    if(assignment.Completed__c){
                        aCourse.Number_of_Completed_Assets__c += 1;
    
                        if(assignment.Required__c){
                            aCourse.Number_of_Completed_Required_Assets__c += 1;
                        }
    
                        if(assignment.Elective_Asset__c){
                            aCourse.Number_of_Completed_Electives__c += 1;
                        }

                        if(aCourse.Number_of_Completed_Assets__c > aCourse.Number_of_Assets__c){
                            aCourse.Number_of_Completed_Assets__c = aCourse.Number_of_Assets__c;
                        }

                        if(aCourse.Number_of_Completed_Required_Assets__c > aCourse.Number_of_Required_Assets__c){
                            aCourse.Number_of_Completed_Assets__c = aCourse.Number_of_Required_Assets__c;
                        }

                        if(aCourse.Number_of_Completed_Electives__c > aCourse.Number_of_Required_Electives__c){
                            aCourse.Number_of_Completed_Assets__c = aCourse.Number_of_Required_Electives__c;
                        }
                    }
                }

                if(Trigger.operationType != System.TriggerOperation.AFTER_INSERT){
                    aCourseWithUpdatedCounts.add(aCourse.Id);
                }
            }
            
            if(!aCourses.isEmpty()){
                update aCourses;
            }
        }
    }

    public static void updateAssignedCourseCompletionCounts(Map<Id, Assignment__c> oldAssignments, List<Assignment__c> newAssignments){
        List<Assignment__c> assignmentsToCount = new List<Assignment__c>();
        List<Assignment__c> inactiveAssignmentsToCount = new List<Assignment__c>();

        for(Assignment__c assignment : newAssignments){
            Assignment__c oldAssignment = oldAssignments.get(assignment.Id);

            if(assignment.Completed__c && !oldAssignment.Completed__c){
                assignmentsToCount.add(assignment);
            }

            if(!assignment.Inactive__c && oldAssignment.Inactive__c){
                inactiveAssignmentsToCount.add(assignment);
            }
        }

        if(!inactiveAssignmentsToCount.isEmpty()){
            updateParentCourseCounts(inactiveAssignmentsToCount, false);
        }

        if(!assignmentsToCount.isEmpty()){
            updateParentCourseCounts(assignmentsToCount, true);
        }
    }

    public static void checkAutoCompleteNewAssignments(List<Assignment__c> newAssignments){
        List<String> assetIds = new List<String>();
        List<String> lpIds = new List<String>();
        Map<String, List<Assignment__c>> assignmentByLearnerAssetId = new Map<String, List<Assignment__c>>();
        String eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        String skillAssessmentRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Skills_Assessment').getRecordTypeId();
        List<String> allowedDuplicates = new List<String>{eventRecordTypeId, skillAssessmentRecordTypeId};

        for(Assignment__c assignment : newAssignments){
            if(!assignment.Completed__c){
                assetIds.add(assignment.Asset__c);
                lpIds.add(assignment.Learner_Profile__c);
                String key = assignment.Learner_Profile__c + '|' + assignment.Asset__c;

                if(!assignmentByLearnerAssetId.containsKey(key)){
                    assignmentByLearnerAssetId.put(key, new List<Assignment__c>());
                }

                assignmentByLearnerAssetId.get(key).add(assignment);
            }
        }

        List<Assignment__c> completedsiblingAssignments = [SELECT Id, Asset__c, Learner_Profile__c,Completed__c
                                                            FROM Assignment__c
                                                            WHERE Asset__c IN :assetIds
                                                            AND Learner_Profile__c IN :lpIds
                                                            AND Completed__c = true
                                                            AND (Asset__r.RecordTypeId != :allowedDuplicates OR
                                                                 (Asset__r.RecordTypeId = :eventRecordTypeId AND Asset__r.Event_Type__c = 'Course'))];

        for(Assignment__c completedAssignment : completedsiblingAssignments){
            String key = completedAssignment.Learner_Profile__c + '|' + completedAssignment.Asset__c;

            if(assignmentByLearnerAssetId.containsKey(key)){
                for(Assignment__c newAssignment : assignmentByLearnerAssetId.get(key)){
                    newAssignment.Completed__c = true;
                }
            }
        }
    }


    public static void completeSiblingAssignments(List<Assignment__c> newAssignments, Map<Id, Assignment__c> oldAssignments){
        List<String> assetIds = new List<String>();
        List<String> lpIds = new List<String>();
        Map<String, Assignment__c> completedAssignmentByLearnerAssetId = new Map<String, Assignment__c>();

        for(Assignment__c assignment : newAssignments){
            Assignment__c oldAssignment = oldAssignments?.get(assignment.Id);

            if(assignment.Completed__c && !oldAssignment.Completed__c){
                assetIds.add(assignment.Asset__c);
                lpIds.add(assignment.Learner_Profile__c);
                completedAssignmentByLearnerAssetId.put(assignment.Learner_Profile__c + '|' + assignment.Asset__c, assignment);
            }
        }

        List<Assignment__c> incompletesiblingAssignments = [SELECT Id, Asset__c, Learner_Profile__c, Completed__c
                                                             FROM Assignment__c
                                                             WHERE Asset__c IN :assetIds
                                                             AND Learner_Profile__c IN :lpIds
                                                             AND Completed__c = false
                                                             AND Inactive__c = false];

        List<Assignment__c> completedsiblingAssignments = new List<Assignment__c>();

        for(Assignment__c assignment : incompletesiblingAssignments){
            String key = assignment.Learner_Profile__c + '|' + assignment.Asset__c;

            if(completedAssignmentByLearnerAssetId.containsKey(key)){
                assignment.Completed__c = true;
                completedsiblingAssignments.add(assignment);
            }
        }

        if(!completedsiblingAssignments.isEmpty()){
            update completedsiblingAssignments;
        }
    }

    /*
    * Deprecated: moved this to flow, to process in batches
    */
    // public static void sendSoloAssetNotification(List<Assignment__c> newAssignments) {
    //     List<Id> assignmentIds = new List<Id>();
    //     for(Assignment__c asg : newAssignments) {
    //         if(!asg.Self_Assigned__c) {
    //             assignmentIds.add(asg.Id);
    //         }
    //     }
    //     if(!assignmentIds.isEmpty()) {
    //         String eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
    //         Map<String, Object> assignmentMap = new Map<String, Object>();
    //         for(Assignment__c assignment : [SELECT Id, Due_Date__c, Mandatory_Session_Count__c, Asset__r.Name, Learner_Profile__r.Name, 
    //                                         Learner_Profile__r.slackid__c, Asset__r.Description__c
    //                                         FROM Assignment__c
    //                                         WHERE Asset__r.RecordTypeId = :eventRecordTypeId
    //                                         AND Id IN: assignmentIds
    //                                         WITH USER_MODE]) {
    //             assignmentMap.put(assignment.Id, assignment);
    //         }
    //         if(!assignmentMap.isEmpty()) {
    //             Map<String, String> metaInfo = new Map<String, String> {
    //                 'type' => 'Assignment',
    //                 'action' => 'event-register'
    //             };
    //             System.enqueueJob(new SlackQueueableNotification(metaInfo, (Map<String, Object>)assignmentMap));
    //         }            
    //     }       
    // }

    public static void setCompletionDate(List<Assignment__c> newAssignments, Map<Id, Assignment__c> oldAssignments){
        for(Assignment__c assignment : newAssignments){
            Assignment__c oldAssignment = oldAssignments.get(assignment.Id);

            if(assignment.Completed__c && !oldAssignment.Completed__c){
                assignment.Completion_Date__c = Date.today();
            }
        }
    }

    /* Remove ACT 1 references
    public static void removeQuizResponseReference(Map<Id, slj__Assignment__c> oldTriggerObjs){
        try{
            Set<Id> assignmentIds = new Set<Id>();
            List<Quiz_Response__c> updatedQuizResponses = new List<Quiz_Response__c>();
            assignmentIds = oldTriggerObjs.keySet();
            if (!assignmentIds.isEmpty()) {
                List<Quiz_Response__c> quizResponses = [Select Id, Assignment__c from Quiz_Response__c where Assignment__c = :assignmentIds WITH USER_MODE];
                if (null != quizResponses && !quizResponses.isEmpty()) {
                    for (Quiz_Response__c quizResponse : quizResponses) {
                        quizResponse.Assignment__c = null;
                        updatedQuizResponses.add(quizResponse);
                    }
                    update as user updatedQuizResponses;
                }
            }
        } catch(Exception e){
            System.debug('Error::removeQuizResponseReference *********** :: ' + e.getMessage());
            System.debug('Error:: removeQuizResponseReference *********** :: ' + e.getStackTraceString());
        }
    } */

    public static void cleanUpChildRecords(List<Assignment__c> triggerNew, Map<Id, Assignment__c> triggerOldMap){
        List<String> inactiveAssignments = new List<String>();

        for(Assignment__c assignment : triggerNew){
            Assignment__c oldAssignment = triggerOldMap.get(assignment.Id);

            if(assignment.Inactive__c && !oldAssignment.Inactive__c){
                inactiveAssignments.add(assignment.Id);
            }
        }


        List<Quiz_Attempt__c> quizAttempts = [SELECT Id FROM Quiz_Attempt__c WHERE Assignment__c IN :inactiveAssignments];
        List<Quiz_Question_Response__c> quizQuestionResponses = [SELECT Id FROM Quiz_Question_Response__c WHERE Quiz_Attempt__c IN :quizAttempts];
        List<Quiz_Answer_Response__c> quizAnswerResponses = [SELECT Id FROM Quiz_Answer_Response__c WHERE Quiz_Question_Response__c IN :quizQuestionResponses];

        Set<String> incompleteStatuses = new Set<String>{'Registered', 'Waitlisted'};
        List<Assigned_Session__c> assignedSessions = [SELECT Id, Status__c FROM Assigned_Session__c WHERE Assignment__c IN :inactiveAssignments AND Status__c =: incompleteStatuses];

        for(Assigned_Session__c aSession : assignedSessions){
            aSession.Status__c = 'Unregistered';
        }

        if(!quizAnswerResponses.isEmpty()){
            delete quizAnswerResponses;
        }
        
        if(!quizQuestionResponses.isEmpty()){
            delete quizQuestionResponses;
        }

        if(!quizAttempts.isEmpty()){
            delete quizAttempts;
        }

        if(!assignedSessions.isEmpty()){
            update assignedSessions;
        }
    }
}