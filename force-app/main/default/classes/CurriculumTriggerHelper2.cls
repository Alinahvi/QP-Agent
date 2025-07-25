public with sharing class CurriculumTriggerHelper2 {
    public static void setDefaultNotificationPref(List<Curriculum__c> currList) {
        for(Curriculum__c curr : currList) {
            curr.Send_Assigned_Notification__c = true;
            curr.Send_Overdue_Notification__c = true;
            curr.Send_Reminder_Notification__c = true;
            curr.Send_Escalation_Notification__c = true;
            curr.Send_Recommendation_Notification__c = true;     
        }        
    }

    public static void updatePublishedDate(List<Curriculum__c> newSObjs, Map<Id, Curriculum__c> oldSObjs) {
        for(Curriculum__c newCr : newSObjs) {
            Curriculum__c oldCr = oldSObjs.get(newCr.Id);
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

    public static void createContentEditor(Map<Id, Curriculum__c> newObj) {
        List<Allowed_Content_Editor__c> editorList = new List<Allowed_Content_Editor__c>();
        Map<Id, List<Id>> contentByOwnerId = new Map<Id, List<Id>>();
        Map<Id, List<Id>> contentByPoc = new Map<Id, List<Id>>();
        Map<Id, Id> pocLpByUserId = new Map<Id, Id>();
        for(Curriculum__c cr : [SELECT Id, Owner.Id, Content_POC__c, Content_POC__r.User__r.profileId 
                                FROM Curriculum__c 
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
            editorList.addAll(AssetTriggerHelper2.filterEditorByACTPermission(pocLpByUserId, contentByPoc, 'Curriculum__c'));
        }

        if(!contentByOwnerId.isEmpty()) {
            editorList.addAll(AssetTriggerHelper2.createEditorFromUserId(contentByOwnerId, 'Curriculum__c'));
        }

        try {
            insert as user editorList;
        }catch(Exception e) {
            System.debug('Error while updating Content Editor String ---- '+e.getStackTraceString());
        } 
                
    }

    public static void contentPocOwnerChanged(Map<Id, Curriculum__c> newCr, Map<Id, Curriculum__c> oldCr) {
        Map<Id, Id> contentByRemovedEditor = new Map<Id, Id>();
        Map<Id, List<Id>> contentByOwnerId = new Map<Id, List<Id>>();
        Map<Id, List<Id>> contentByPoc = new Map<Id, List<Id>>();
        Map<Id, Id> pocLpByUserId = new Map<Id, Id>();
        List<Allowed_Content_Editor__c> contentByAddedEditor = new List<Allowed_Content_Editor__c>();
        List<Allowed_Content_Editor__c> editorToDelete = new List<Allowed_Content_Editor__c>();
        
        for(Curriculum__c cr : [SELECT Id, Content_POC__c, Content_POC__r.User__c, Owner.Id, Content_POC__r.User__r.profileId,
                                (SELECT Id, Learner_profile__r.User__c FROM Allowed_Content_Editors__r) 
                                FROM Curriculum__c 
                                WHERE Id IN : newCr.keySet() 
                                WITH USER_MODE]) {
            Curriculum__c old = oldCr.get(cr.Id);
            if(old.Content_POC__c != cr.Content_POC__c) {
                contentByRemovedEditor.put(old.Content_POC__c, cr.Id);
                pocLpByUserId.put(cr.Content_POC__r.User__r.Id, cr.Content_POC__c);
                if(!contentByPoc.containsKey(cr.Content_POC__r.User__r.Id)) {
                    contentByPoc.put(cr.Content_POC__r.User__r.Id, new List<Id>{cr.Id});
                } else {
                    contentByPoc.get(cr.Content_POC__r.User__r.Id).add(cr.Id);
                }                                              
            } 

            if(old.OwnerId != cr.Owner.Id) {
                contentByRemovedEditor.put(old.OwnerId, cr.Id);
                if(!contentByOwnerId.containsKey(cr.Owner.Id)) {
                    contentByOwnerId.put(cr.Owner.Id, new List<Id>{cr.Id});
                } else {
                    contentByOwnerId.get(cr.Owner.Id).add(cr.Id);
                }             
            }

            for(Allowed_Content_Editor__c editor : cr.Allowed_Content_Editors__r) {
                // check if old POC & Owner not the same user, bcz dont' want to remove the Owner's content_editor record
                if(contentByRemovedEditor.containsKey(editor.Learner_profile__r.Id) && 
                    editor.Learner_profile__r.User__c != cr.Owner.Id) {
                    editorToDelete.add(editor);
                } else if(contentByRemovedEditor.containsKey(editor.Learner_profile__r.User__c)) {
                    editorToDelete.add(editor);
                }                
            }
        }

        if(!contentByPoc.isEmpty()) {
            contentByAddedEditor.addAll(AssetTriggerHelper2.filterEditorByACTPermission(pocLpByUserId, contentByPoc, 'Curriculum__c'));
        }

        if(!contentByOwnerId.isEmpty()) {
            contentByAddedEditor.addAll(AssetTriggerHelper2.createEditorFromUserId(contentByOwnerId, 'Curriculum__c'));
        }

        if(!contentByAddedEditor.isEmpty() || !editorToDelete.isEmpty()) {
            AssetTriggerHelper2.insertDeleteEditor(JSON.serialize(contentByAddedEditor), JSON.serialize(editorToDelete));
        }        
    }
}