public with sharing class CurriculumCourseTriggerHelper {
    public static void updateTimeEstimate(List<Curriculum_Course__c> curricCourses){
        Set<String> curricIds = new Set<String>();

        for(Curriculum_Course__c cc : curricCourses){
            if(cc.Course__c != null){
                curricIds.add(cc.Curriculum__c);
            }
        }
        
        List<Curriculum__c> curricsToUpdate = [SELECT Id, Time_Estimate_Minutes__c, Electives_To_Complete__c,
                                                  (
                                                    SELECT Id, Course__r.Time_Estimate_Minutes__c, Required__c, Elective_Course__c
                                                    FROM Curriculum_Courses__r
                                                  )
                                               FROM Curriculum__c
                                               WHERE Id = :curricIds
                                               WITH USER_MODE];

        calculateTimeEstimate(curricsToUpdate);

        update curricsToUpdate;
    }

    public static void updateTimeEstimate(Id recordId) {
        List<Curriculum__c> curricsToUpdate = [SELECT Id, Time_Estimate_Minutes__c, Electives_To_Complete__c,
                                                  (
                                                    SELECT Id, Course__r.Time_Estimate_Minutes__c, Required__c, Elective_Course__c
                                                    FROM Curriculum_Courses__r
                                                  )
                                               FROM Curriculum__c
                                               WHERE Id = :recordId
                                               WITH USER_MODE];

        calculateTimeEstimate(curricsToUpdate);

        update curricsToUpdate;
    }

    private static void calculateTimeEstimate(List<Curriculum__c> curriculums) {
        for(Curriculum__c curric : curriculums){
            curric.Time_Estimate_Minutes__c = 0;
            List<Integer> courseTimeEstimates = new List<Integer>();
            List<Integer> reversedCourseTimeEstimates = new List<Integer>();
            Integer electivesToComplete = curric.Electives_To_Complete__c == null ? 0 : curric.Electives_To_Complete__c.intValue();

            for(Curriculum_Course__c cc : curric.Curriculum_Courses__r){
                if(cc.Course__r.Time_Estimate_Minutes__c != null && cc.Required__c){
                    curric.Time_Estimate_Minutes__c += cc.Course__r.Time_Estimate_Minutes__c;
                }

                if (cc.Elective_Course__c && cc.Course__r.Time_Estimate_Minutes__c != null) {
                    courseTimeEstimates.add(cc.Course__r.Time_Estimate_Minutes__c.intValue());
                }
            }

            if (electivesToComplete > 0 && !courseTimeEstimates.isEmpty()) {
                courseTimeEstimates.sort();

                for (Integer i = courseTimeEstimates.size() - 1; i >= 0; i--) {
                    reversedCourseTimeEstimates.add(courseTimeEstimates[i]);
                }

                for (Integer i = 0; i < electivesToComplete; i++) {
                    curric.Time_Estimate_Minutes__c += reversedCourseTimeEstimates[i];
                }
            }
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