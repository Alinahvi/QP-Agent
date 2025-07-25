public with sharing class CourseAssetTriggerHelper {
    public static void updateTimeEstimate(List<Course_Asset__c> newCourseAssets, Map<Id, Course_Asset__c> oldCourseAssets, System.TriggerOperation operationType) {
        switch on Trigger.operationType {
            when AFTER_INSERT {
                updateTimeEstimate(newCourseAssets);               
            }

            // when AFTER_UPDATE {
            //     // Only run if time estimate is updated
            //     List<Course_Asset__c> updatedCourseAssets = new List<Course_Asset__c>();

            //     for (Course_Asset__c courseAsset : newCourseAssets) {
            //         if (oldCourseAssets.containsKey(courseAsset.Id) && oldCourseAssets.get(courseAsset.Id).Asset__r.Time_Estimate_Minutes__c != courseAsset.Asset__r.Time_Estimate_Minutes__c) {
            //             updatedCourseAssets.add(courseAsset);
            //         }
            //     }

            //     if (!updatedCourseAssets.isEmpty()) {
            //         updateTimeEstimate(updatedCourseAssets);               
            //     }
            // }

            when AFTER_UPDATE {
                // Only run if Required__c is updated.
                // This is for when the Learning Admin changes from Optional/Elective to Required and vice versa.
                List<Course_Asset__c> updatedCourseAssets = new List<Course_Asset__c>();

                for (Course_Asset__c courseAsset : newCourseAssets) {
                    if (oldCourseAssets.containsKey(courseAsset.Id) && oldCourseAssets.get(courseAsset.Id).Required__c != courseAsset.Required__c) {
                        updatedCourseAssets.add(courseAsset);
                    }
                }

                if (!updatedCourseAssets.isEmpty()) {
                    updateTimeEstimate(updatedCourseAssets);               
                }
            }

            when AFTER_DELETE {
                updateTimeEstimate(oldCourseAssets.values());               
            }
        }
    }

    public static void updateTimeEstimate(List<Course_Asset__c> courseAssets) {
        Set<String> courseIds = new Set<String>();

        for (Course_Asset__c ca : courseAssets) {
            if (ca.Course__c != null) {
                courseIds.add(ca.Course__c);
            }
        }

        List<Course__c> coursesToUpdate = [SELECT Id, Time_Estimate_Minutes__c, Electives_To_Complete__c,
                                                  (
                                                    SELECT Id, Asset__r.Time_Estimate_Minutes__c, Required__c, Elective_Asset__c
                                                    FROM Course_Assets__r
                                                  )
                                           FROM Course__c
                                           WHERE Id =: courseIds
                                           WITH USER_MODE];

        AssetTriggerHelper2.calculateTimeEstimate(coursesToUpdate);

        if (!coursesToUpdate.isEmpty()) {
            update coursesToUpdate;
            // List<Course__c> sanitizedCourses = new List<Course__c>();

            // for(Course__c course : coursesToUpdate){
            //     Map<String, Object> sanitizedCourseMap = course.getPopulatedFieldsAsMap().clone();
            //     Course__c sanitizedCourse = (Course__c)Utilities.getSobjectByMap(sanitizedCourseMap, 'Course__c');
            //     sanitizedCourses.add(sanitizedCourse);
            // }

            // Database.update(sanitizedCourses, true, AccessLevel.USER_MODE);
        }

        List<Curriculum_Course__c> ccs = [SELECT Id, Curriculum__c, Course__c
                                          FROM Curriculum_Course__c
                                          WHERE Course__c =: coursesToUpdate
                                          WITH USER_MODE];

        if (!ccs.isEmpty()) {
            CurriculumCourseTriggerHelper.updateTimeEstimate(ccs);
        }
    }

    // public static void setDefaultNotificationPref(List<Course__c> courseList) {
    //     for(Course__c course : courseList) {
    //         course.Send_Assigned_Notification__c = true;
    //         course.Send_Overdue_Notification__c = true;
    //         course.Send_Reminder_Notification__c = true;
    //         course.Send_Survey_Notification__c = true;
    //     }        
    // }
}