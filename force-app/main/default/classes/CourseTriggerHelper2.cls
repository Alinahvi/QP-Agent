public with sharing class CourseTriggerHelper2 {
    public static void setDefaultNotificationPref(List<Course__c> courseList) {
        for(Course__c course : courseList) {
            course.Send_Assigned_Notification__c = true;
            course.Send_Overdue_Notification__c = true;
            course.Send_Reminder_Notification__c = true;
            course.Send_Survey_Notification__c = true;
            course.Send_Escalation_Notification__c = true;
            course.Send_Recommendation_Notification__c = true;
        }        
    }

    @InvocableMethod( label='Set Course Survey Fields' description='set course survey fields using related survey invitation')
    public static void setCourseSurveyFields(List<Course__c> newList) {
        List<SurveySubject> ss = new List<SurveySubject>();
        List<Survey> sfSurvey = [SELECT Id 
                                 FROM Survey 
                                 WHERE DeveloperName =: Label.ACT_Course_Survey_Name 
                                 WITH USER_MODE
                                 LIMIT 1];        
        Map<String, SurveyInvitation> invitationByCourseId = new Map<String, SurveyInvitation>();
        Map<Id, Course__c> courseMap = new Map<Id, Course__c>();

        if(sfSurvey.isEmpty()) {
            return;
        }     
        courseMap.putAll((List<Course__c>)newList);

        List<Learner_Profile__c> aLps = [SELECT Id, User__c FROM Learner_Profile__c WHERE Name = 'Astro\'s Course Tracker'];
        if(aLps.isEmpty()) {
            return;
        }

        for(Course__c course : newList) {
            course.Survey__c = sfSurvey[0].Id;
            SurveyInvitation invitation = getSurveyInvitation(course);
            invitation.OwnerId = aLps[0].User__c;
            invitationByCourseId.put(course.Id, invitation);            
        }

        try {
            insert as user invitationByCourseId.values();            
        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'e.getMessage(): ' + e.getMessage());
            ExceptionUtility2.logError('SF_SURVEY', 'CourseTriggerHelper2 :: ' + 'setCourseSurveyFields()', 'SurveyInvitation', e.getMessage());
            return; 
        }
        Map<Id, SurveyInvitation> invitationMap = new Map<Id, SurveyInvitation>([SELECT Id, InvitationLink 
                                                                                        FROM SurveyInvitation 
                                                                                        WHERE Id IN : invitationByCourseId.values()
                                                                                        WITH USER_MODE]);
        for(Course__c course : courseMap.values()) {
            SurveyInvitation invitation = invitationMap.get(invitationByCourseId.get(course.Id).Id);
            course.Survey_Invitation__c = invitation.Id;
            course.Survey_URL__c = invitation.InvitationLink;
            ss.add(new SurveySubject(Name = course.Name,                
                SubjectId = course.Id,
                ParentId = invitation.Id)
            );
        }

        try {
            // update as user Security.stripInaccessible(AccessType.UPDATABLE, courseMap.values()).getRecords();
            update courseMap.values();
            if(!ss.isEmpty()) {
                insert ss;
            }
        } catch(Exception  e) {
            // System.debug('The Course__c field(s) "' + String.join(e.getDmlFieldNames(0), ', ') + '" are not accessible for update of Course__c');
            System.debug(LoggingLevel.ERROR, 'Errro while updating Survey Fields :: ' + e.getMessage());
            ExceptionUtility2.logError('SF_SURVEY', 'CourseTriggerHelper2' + 'setCourseSurveyFields()', 'SurveyInvitation', e.getMessage());
        }
    }

    private static SurveyInvitation getSurveyInvitation(Course__c course) {
        SurveyInvitation invitation = new SurveyInvitation(
            SurveyId =  course.Survey__c,
            Name = 'Course - ' + course.Name + ' - Invitation' + '-' + Integer.valueof((Math.random() * 1000)),
            ACT2_Course__c = course.Id
        );
        return invitation;
    }

    public static void updatePublishedDate(List<Course__c> newSObjs, Map<Id, Course__c> oldSObjs) {
        for(Course__c newCr : newSObjs) {
            Course__c oldCr = oldSObjs.get(newCr.Id);
            if(newCr.Status__c == 'Active' && oldCr.Status__c != 'Active') {
                newCr.Published_Date__c = System.today();
            } 
            if(oldCr.Status__c == 'Active' && newCr.Status__c != 'Active' && newCr.Status__c != 'Archived') {
                newCr.Published_Date__c = null;
            } 
            if(newCr.Status__c == 'Archived' && oldCr.Status__c != 'Archived') {
                newCr.Archived_Date__c = System.today();
            } 
            if(oldCr.Status__c == 'Archived' && newCr.Status__c != 'Archived') {
                newCr.Archived_Date__c = null;
                newCr.Archived_Reason__c = null;
            }           
        }
    }

    public static void createContentEditor(Map<Id, Course__c> newObj) {
        List<Allowed_Content_Editor__c> editorList = new List<Allowed_Content_Editor__c>();
        Map<Id, List<Id>> contentByOwnerId = new Map<Id, List<Id>>();
        Map<Id, List<Id>> contentByPoc = new Map<Id, List<Id>>();
        Map<Id, Id> pocLpByUserId = new Map<Id, Id>();
        for(Course__c cr : [SELECT Id, Owner.Id, Content_POC__c, Content_POC__r.User__r.profileId 
                           FROM Course__c 
                           WHERE Id IN :newObj.keySet() 
                           WITH USER_MODE]) {
            
            if(cr.Content_POC__c != null && cr.Content_POC__r.User__r.Id != cr.Owner.Id) {
                pocLpByUserId.put(cr.Content_POC__r.User__r.Id, cr.Content_POC__c);
                if(!contentByPoc.containsKey(cr.Content_POC__r.User__r.Id)) {
                    contentByPoc.put(cr.Content_POC__r.User__r.Id, new List<Id>{cr.Id});
                } else {
                    contentByPoc.get(cr.Content_POC__r.User__r.Id).add(cr.Id);
                }
            }

            if(!contentByOwnerId.containsKey(cr.Owner.Id)) {
                contentByOwnerId.put(cr.Owner.Id, new List<Id>{cr.Id});
            } else {
                contentByOwnerId.get(cr.Owner.Id).add(cr.Id);
            }            
        }

        if(!contentByPoc.isEmpty()) {
            editorList.addAll(AssetTriggerHelper2.filterEditorByACTPermission(pocLpByUserId, contentByPoc, 'Course__c'));
        }

        if(!contentByOwnerId.isEmpty()) {
            editorList.addAll(AssetTriggerHelper2.createEditorFromUserId(contentByOwnerId, 'Course__c'));
        }

        try {
            insert as user editorList;
        }catch(Exception e) {
            System.debug('Error while updating Content Editor String ---- '+e.getStackTraceString());
        }              
    }

    public static void contentPocOwnerChanged(Map<Id, Course__c> newCourse, Map<Id, Course__c> oldCourse) {
        Map<Id, Id> contentByRemovedEditor = new Map<Id, Id>();
        List<Allowed_Content_Editor__c> contentByAddedEditor = new List<Allowed_Content_Editor__c>();
        List<Allowed_Content_Editor__c> editorToDelete = new List<Allowed_Content_Editor__c>();
        Map<Id, List<Id>> contentByOwnerId = new Map<Id, List<Id>>();
        Map<Id, List<Id>> contentByPoc = new Map<Id, List<Id>>();
        Map<Id, Id> pocLpByUserId = new Map<Id, Id>();
        
        for(Course__c course : [SELECT Id, Content_POC__c, Content_POC__r.User__c, Owner.Id, Content_POC__r.User__r.profileId,
                            (SELECT Id, Learner_profile__r.User__c FROM Allowed_Content_Editors__r) 
                            FROM Course__c 
                            WHERE Id IN : newCourse.keySet()]) {
            Course__c old = oldCourse.get(course.Id);
            if(old.Content_POC__c != course.Content_POC__c) {
                contentByRemovedEditor.put(old.Content_POC__c, course.Id);
                pocLpByUserId.put(course.Content_POC__r.User__r.Id, course.Content_POC__c);
                if(!contentByPoc.containsKey(course.Content_POC__r.User__r.Id)) {
                    contentByPoc.put(course.Content_POC__r.User__r.Id, new List<Id>{course.Id});
                } else {
                    contentByPoc.get(course.Content_POC__r.User__r.Id).add(course.Id);
                }                         
            } 
            if(old.OwnerId != course.Owner.Id) {
                contentByRemovedEditor.put(old.OwnerId, course.Id);
                if(!contentByOwnerId.containsKey(course.Owner.Id)) {
                    contentByOwnerId.put(course.Owner.Id, new List<Id>{course.Id});
                } else {
                    contentByOwnerId.get(course.Owner.Id).add(course.Id);
                }             
            }

            for(Allowed_Content_Editor__c editor : course.Allowed_Content_Editors__r) {
                // check if old POC & Owner not the same user, bcz dont' want to remove the Owner's content_editor record
                if(contentByRemovedEditor.containsKey(editor.Learner_profile__r.Id) && 
                    editor.Learner_profile__r.User__c != course.Owner.Id) {
                    editorToDelete.add(editor);
                } else if(contentByRemovedEditor.containsKey(editor.Learner_profile__r.User__c)) {
                    editorToDelete.add(editor);
                }                
            }
        }     

        if(!contentByPoc.isEmpty()) {
            contentByAddedEditor.addAll(AssetTriggerHelper2.filterEditorByACTPermission(pocLpByUserId, contentByPoc, 'Course__c'));
        }

        if(!contentByOwnerId.isEmpty()) {
            contentByAddedEditor.addAll(AssetTriggerHelper2.createEditorFromUserId(contentByOwnerId, 'Course__c'));
        }

        if(!contentByAddedEditor.isEmpty() || !editorToDelete.isEmpty()) {
            AssetTriggerHelper2.insertDeleteEditor(JSON.serialize(contentByAddedEditor), JSON.serialize(editorToDelete));
        }        
    }
}