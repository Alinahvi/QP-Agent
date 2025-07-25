public with sharing class AssignedCurriculumTriggerHelper {
    public static void checkCurricCompletion(Map<Id, Assigned_Curriculum__c> oldCurrics, List<Assigned_Curriculum__c> newCurrics){
        for(Assigned_Curriculum__c aCurric : newCurrics){
            Assigned_Curriculum__c oldACurric = oldCurrics.get(aCurric.Id);

            if(oldACurric.Completion_Date__c == null && !oldACurric.Completed__c &&
                    (
                        (
                            aCurric.Number_of_Completed_Required_Courses__c >= aCurric.Number_of_Required_Courses__c&& 
                            aCurric.Number_of_Completed_Electives__c >= aCurric.Number_of_Required_Electives__c
                        ) ||

                        aCurric.Number_of_Completed_Courses__c >= aCurric.Number_of_Courses__c
                    )
               ){
                aCurric.Completion_Date__c = Date.today();
                aCurric.Completed__c = true;
            }
        }
    }

    public static void archiveChildrenCourses(List<Assigned_Curriculum__c> triggerNew, Map<Id, Assigned_Curriculum__c> triggerOldMap){
        List<Assigned_Curriculum__c> archivedAssignedCurrics = new List<Assigned_Curriculum__c>();

        for(Assigned_Curriculum__c newACurric : triggerNew){
            Assigned_Curriculum__c oldACurric = triggerOldMap.get(newACurric.Id);

            if(newACurric.Inactive__c && !oldACurric.Inactive__c){
                archivedAssignedCurrics.add(newACurric);
            }
        }

        List<Assigned_Course__c> aCoursesToArchive = [SELECT Id, Inactive__c FROM Assigned_Course__c WHERE Assigned_Curriculum__c =: archivedAssignedCurrics];

        for(Assigned_Course__c aCourse : aCoursesToArchive){
            aCourse.Inactive__c = true;
        }

        if(!aCoursesToArchive.isEmpty()){
            update as user aCoursesToArchive;
        }
    }
}