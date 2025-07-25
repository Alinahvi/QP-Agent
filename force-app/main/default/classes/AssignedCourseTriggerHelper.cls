public with sharing class AssignedCourseTriggerHelper {
    public static Set<String> aCurricWithUpdatedCounts;
    //if an assigned course was created make the parent curriculum recalculate its children count
    //to make sure we have the correct counts
    public static void updateParentCurricCounts(List<Assigned_Course__c> newACourses, Boolean completionOnly){
        try {
            if(aCurricWithUpdatedCounts == null){
                aCurricWithUpdatedCounts = new Set<String>();
            }

            Set<String> aCurricIds = new Set<String>();
    
            for(Assigned_Course__c ac : newACourses){
                if(!aCurricWithUpdatedCounts.contains(ac.Assigned_Curriculum__c)){
                    aCurricIds.add(ac.Assigned_Curriculum__c);
                }
            }
            
            if(!aCurricIds.isEmpty()){
                List<Assigned_Curriculum__c> aCurrics = [SELECT Id, Curriculum__r.Electives_To_Complete__c, Completed__c, Number_of_Courses__c, Number_of_Completed_Courses__c, Number_of_Required_Courses__c,
                                                                Number_of_Completed_Required_Courses__c, Number_of_Required_Electives__c, Number_of_Completed_Electives__c,
                                                         (
                                                            SELECT Id, Completed__c, Assigned_Curriculum__c, Elective_Asset__c,
                                                                   Required__c
                                                            FROM Assigned_Courses__r
                                                            WHERE Inactive__c = false
                                                         )
                                                      FROM Assigned_Curriculum__c
                                                      WHERE Id =: aCurricIds];
                
                for(Assigned_Curriculum__c aCurric : aCurrics){
                    if(!completionOnly){
                        aCurric.Number_of_Courses__c = aCurric.Assigned_Courses__r.size();
                        aCurric.Number_of_Required_Courses__c = 0;
                        aCurric.Number_of_Required_Electives__c = aCurric.Curriculum__r.Electives_To_Complete__c == null ? 0 : aCurric.Curriculum__r.Electives_To_Complete__c;
                    }

                    aCurric.Number_of_Completed_Required_Courses__c = 0;
                    aCurric.Number_of_Completed_Courses__c = 0;
                    aCurric.Number_of_Completed_Electives__c = 0;
        
                    for(Assigned_Course__c aCourse : aCurric.Assigned_Courses__r){
                        if(!completionOnly){
                            if(aCourse.Required__c){
                                aCurric.Number_of_Required_Courses__c += 1;
                            }
                        }
        
                        if(aCourse.Completed__c){
                            aCurric.Number_of_Completed_Courses__c += 1;
        
                            if(aCourse.Required__c){
                                aCurric.Number_of_Completed_Required_Courses__c += 1;
                            }
        
                            if(aCourse.Elective_Asset__c){
                                aCurric.Number_of_Completed_Electives__c += 1;
                            }

                            if(aCurric.Number_of_Completed_Courses__c > aCurric.Number_of_Courses__c){
                                aCurric.Number_of_Completed_Courses__c = aCurric.Number_of_Courses__c;
                            }

                            if(aCurric.Number_of_Completed_Required_Courses__c > aCurric.Number_of_Required_Courses__c){
                                aCurric.Number_of_Completed_Courses__c = aCurric.Number_of_Required_Courses__c;
                            }

                            if(aCurric.Number_of_Completed_Electives__c > aCurric.Number_of_Required_Electives__c){
                                aCurric.Number_of_Completed_Courses__c = aCurric.Number_of_Required_Electives__c;
                            }
                        }
                    }

                    if(Trigger.operationType != System.TriggerOperation.AFTER_INSERT){
                        aCurricWithUpdatedCounts.add(aCurric.Id);
                    }
                }
                
                if(!aCurrics.isEmpty()){
                    update aCurrics;
                }
            }
        } catch(Exception e){
            
        }
    }

    public static void checkCourseCompletion(Map<Id, Assigned_Course__c> oldCourses, List<Assigned_Course__c> newCourses){
        for(Assigned_Course__c aCourse : newCourses){
            Assigned_Course__c oldACourse = oldCourses.get(aCourse.Id);

            if(oldACourse.Completion_Date__c == null && !oldACourse.Completed__c && 
                (
                    (
                        aCourse.Number_of_Completed_Required_Assets__c >= aCourse.Number_of_Required_Assets__c && 
                        aCourse.Number_of_Completed_Electives__c >= aCourse.Number_of_Required_Electives__c
                    )
                    ||
                    aCourse.Number_of_Completed_Assets__c >= aCourse.Number_of_Assets__c
                )
              ){
                aCourse.Completion_Date__c = Date.today();
                aCourse.Completed__c = true;

            }
        }
    }

    public static void updateAssignedCurricCompletionCounts(Map<Id, Assigned_Course__c> oldCourses, List<Assigned_Course__c> newCourses){
        System.debug('******** updateAssignedCurricCompletionCounts');
        List<Assigned_Course__c> completedCourses = new List<Assigned_Course__c>();
        List<Assigned_Course__c> inactiveCourses = new List<Assigned_Course__c>();
        
        for(Assigned_Course__c aCourse : newCourses){
            Assigned_Course__c oldACourse = oldCourses.get(aCourse.Id);
            if(aCourse.Completed__c && !oldACourse.Completed__c){
                completedCourses.add(aCourse);
            }

            if(!aCourse.Inactive__c && oldACourse.Inactive__c){
                inactiveCourses.add(aCourse);
            }
        }

        if(!inactiveCourses.isEmpty()){
            updateParentCurricCounts(inactiveCourses, false);
        }

        if(!completedCourses.isEmpty()){
            updateParentCurricCounts(completedCourses, true);
        }
    }

    public static void archiveChildrenAssignments(List<Assigned_Course__c> triggerNew, Map<Id, Assigned_Course__c> triggerOldMap){
        List<Assigned_Course__c> archivedAssignedCourses = new List<Assigned_Course__c>();

        for(Assigned_Course__c newACourse : triggerNew){
            Assigned_Course__c oldACourse = triggerOldMap.get(newACourse.Id);

            if(newACourse.Inactive__c && !oldACourse.Inactive__c){
                archivedAssignedCourses.add(newACourse);
            }
        }

        List<Assignment__c> assignmentsToArchive = [SELECT Id, Inactive__c FROM Assignment__c WHERE Assigned_Course__c =: archivedAssignedCourses];

        for(Assignment__c assignment : assignmentsToArchive){
            assignment.Inactive__c = true;
        }

        if(!assignmentsToArchive.isEmpty()){
            update as user assignmentsToArchive;
        }
    }
}