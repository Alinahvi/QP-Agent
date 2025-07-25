public with sharing class AssetTriggerHelper2 {
    public static void setMandatorySesssions(List<Asset__c> newAssets){
        String eventRTId = Schema.SObjectType.Asset__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();

        for(Asset__c newAsset : newAssets){
            Boolean needsMinimum = newAsset.Event_Type__c == 'Course' || newAsset.Event_Type__c == 'Stand Alone';
            Boolean hasNoMinimum = newAsset.Mandatory_Session_Count__c <= 0  || newAsset.Mandatory_Session_Count__c == null;
            
            if(newAsset.RecordTypeId == eventRTId && 
              needsMinimum &&
              hasNoMinimum){
                newAsset.Mandatory_Session_Count__c = 1;
            }
        }
    }


    public static void setDefaultNotificationPref(List<Asset__c> assetList) {
        Id eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        Id contentBlockTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Content_Block').getRecordTypeId();
        for(Asset__c asset : assetList) {
            if(asset.RecordTypeId == eventRecordTypeId) {
                asset.Send_Assigned_Notification__c = true;
                asset.Send_Recommendation_Notification__c = true;
            } else if(asset.RecordTypeId == contentBlockTypeId) {
                asset.Send_Assigned_Notification__c = false;  
                asset.Send_Overdue_Notification__c = false;
                asset.Send_Reminder_Notification__c = false;
                asset.Send_Survey_Notification__c = false;    
                asset.Send_Escalation_Notification__c = false;
                asset.Send_Recommendation_Notification__c = false;
            } else {
                asset.Send_Assigned_Notification__c = true;  
                asset.Send_Overdue_Notification__c = true;
                asset.Send_Reminder_Notification__c = true;
                asset.Send_Escalation_Notification__c = true;
                asset.Send_Recommendation_Notification__c = true;
                // asset.Send_Survey_Notification__c = true;                  
            }
        }        
    }

    public static void updateCourseTimeEstimate(List<Asset__c> newAssets, Map<Id, Asset__c> oldAssets) {
        List<Asset__c> updatedAssets = new List<Asset__c>();
        Set<Id> updatedAssetIds = new Set<Id>();

        for (Asset__c asset : newAssets) {
            if (oldAssets.containsKey(asset.Id) && oldAssets.get(asset.Id).Time_Estimate_Minutes__c != asset.Time_Estimate_Minutes__c) {
                updatedAssets.add(asset);
                updatedAssetIds.add(asset.Id);
            }
        }

        if (updatedAssets.isEmpty()) {
            return;               
        }

        List<Course_Asset__c> courseAssets = [SELECT Id, Asset__c, Course__c FROM Course_Asset__c WHERE Asset__c IN :updatedAssetIds WITH USER_MODE];
        Set<Id> courseIds = new Set<Id>();

        for (Course_Asset__c courseAsset : courseAssets) {
            courseIds.add(courseAsset.Course__c);
        }

        List<Course__c> coursesToUpdate = [SELECT Id, Time_Estimate_Minutes__c, Electives_To_Complete__c,
                                                  (
                                                    SELECT Id, Asset__r.Time_Estimate_Minutes__c, Required__c, Elective_Asset__c
                                                    FROM Course_Assets__r
                                                  )
                                           FROM Course__c
                                           WHERE Id IN :courseIds
                                           WITH USER_MODE];     

        calculateTimeEstimate(coursesToUpdate);

        if (!coursesToUpdate.isEmpty()) {
            update coursesToUpdate;
        }
 
        List<Curriculum_Course__c> ccs = [SELECT Id, Curriculum__c, Course__c
                                          FROM Curriculum_Course__c
                                          WHERE Course__c = :coursesToUpdate
                                          WITH USER_MODE];

        if (!ccs.isEmpty()) {
            CurriculumCourseTriggerHelper.updateTimeEstimate(ccs);
        }
    }

    public static void updateCourseTimeEstimate(Id courseId) {
        List<Course__c> coursesToUpdate = [SELECT Id, Time_Estimate_Minutes__c, Electives_To_Complete__c,
                                                    (
                                                    SELECT Id, Asset__r.Time_Estimate_Minutes__c, Required__c, Elective_Asset__c
                                                    FROM Course_Assets__r
                                                    )
                                            FROM Course__c
                                            WHERE Id = :courseId
                                            WITH USER_MODE];     

        calculateTimeEstimate(coursesToUpdate);

        update coursesToUpdate;
    }

    public static void validateSEEDReadiness(List<sObject> newSObjs) {
        validateSEEDReadiness(newSObjs, new Map<Id, sObject>());
    }

    public static void validateSEEDReadiness(List<sObject> newSObjs, Map<Id, sObject> oldSObjs) {
        String objType = newSObjs[0].getSObjectType() + '';
        Map<Id, sObject> sObjIdsToValidate = new Map<Id, sObject>();

        for(sObject sObj : newSObjs){
            sObject oldSObj = oldSObjs.get((Id)sObj.get('Id'));
            Boolean isSEEDReady = (Boolean)sObj.get('SEED_Ready__c');
            Boolean oldIsSeedReady = oldSObj == null ? false : (Boolean)oldSObj.get('SEED_Ready__c');

            if(isSEEDReady && oldIsSeedReady != isSEEDReady){
                sObjIdsToValidate.put((Id)sObj.get('Id'), sObj);
            }
        }

        if(!sObjIdsToValidate.isEmpty()){
            List<Id> sObjIds = new List<Id>(sObjIdsToValidate.keySet());
            String soqlString = 'SELECT Id,' +
                                    ' (' +
                                        'SELECT Id' +
                                        ' FROM Content_Tags__r' +
                                        ' WHERE Growth_Factor_L2__c != null' +
                                        ' OR Skill__c != null' +
                                        ' LIMIT 1' +
                                    ')' +
                                ' FROM ' + objType + 
                                ' WHERE Id IN :sObjIds';
    
            List<sObject> sObjsWithTags = Database.query(soqlString);
    
            for(sObject sObj : sObjsWithTags){
                if(sObj.getSObjects('Content_Tags__r') == null || sObj.getSObjects('Content_Tags__r').isEmpty()){
                    sObject sObjToValidate = sObjIdsToValidate.get((Id)sObj.get('Id'));
                    sObjToValidate.addError('SEED_Ready__c', 'You must have at least one content tag with a Growth Factor L2 or Skill to mark this SEED ready.');
                }
            }
        }
    }

    public static void calculateTimeEstimate(List<Course__c> courses) {
        for (Course__c course : courses) {
            course.Time_Estimate_Minutes__c = 0;
            List<Integer> electivesTimeEstimates = new List<Integer>();
            List<integer> reversedElectivesTimeEstimates = new List<integer>();
            Integer electivesToComplete = course.Electives_To_Complete__c == null ? 0 : course.Electives_To_Complete__c.intValue();

            for (Course_Asset__c ca : course.Course_Assets__r) {
                if (ca.Asset__r.Time_Estimate_Minutes__c != null && ca.Required__c) {
                    course.Time_Estimate_Minutes__c += ca.Asset__r.Time_Estimate_Minutes__c;
                }

                if (ca.Elective_Asset__c && ca.Asset__r.Time_Estimate_Minutes__c != null) {
                    electivesTimeEstimates.add(ca.Asset__r.Time_Estimate_Minutes__c.intValue());
                }
            }

            if (electivesToComplete > 0 && !electivesTimeEstimates.isEmpty()) {
                electivesTimeEstimates.sort();

                for (Integer i = electivesTimeEstimates.size() - 1; i >= 0; i--) {
                    reversedElectivesTimeEstimates.add(electivesTimeEstimates[i]);
                }
                
                Integer totalElectivesToCount = Math.min(electivesToComplete, reversedElectivesTimeEstimates.size());

                for (Integer i = 0; i < totalElectivesToCount; i++) {
                    course.Time_Estimate_Minutes__c += reversedElectivesTimeEstimates[i];
                }
            }
        }
    }

    public static void updatePublishedDate(List<Asset__c> newSObjs) {
        updatePublishedDate(newSObjs, new Map<Id, Asset__c>());
    }

    public static void updatePublishedDate(List<Asset__c> newSObjs, Map<Id, Asset__c> oldSObjs) {
        for(Asset__c newCr : newSObjs) {
            Asset__c oldCr = oldSObjs.get(newCr.Id);
            if(oldCr != null) {
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
            } else {
                if(newCr.Status__c == 'Active') {
                    newCr.Published_Date__c = System.today();
                } 
            }            
        }
    }

    public static void createContentEditor(Map<Id, Asset__c> newObj) {
        String eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        List<Allowed_Content_Editor__c> editorList = new List<Allowed_Content_Editor__c>();
        Map<Id, List<Id>> contentByOwnerId = new Map<Id, List<Id>>();
        Map<Id, List<Id>> contentByPoc = new Map<Id, List<Id>>();
        Map<Id, Id> pocLpByUserId = new Map<Id, Id>();
        for(Asset__c cr : [SELECT Id, Owner.Id, Content_POC__c, Content_POC__r.User__r.profileId, 
                           Content_Editor_Ids__c
                           FROM Asset__c 
                           WHERE Id IN :newObj.keySet()
                           AND RecordTypeId != :eventRecordTypeId]) {
            
            if(cr.Content_POC__c != null && cr.Content_POC__r.User__c != cr.Owner.Id) {
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
            editorList.addAll(filterEditorByACTPermission(pocLpByUserId, contentByPoc, 'Asset__c'));
        }

        if(!contentByOwnerId.isEmpty()) {
            editorList.addAll(createEditorFromUserId(contentByOwnerId, 'Asset__c'));
        }

        try {
            insert as user editorList;
        }catch(Exception e) {
            System.debug('Error while updating Content Editor String ---- '+e.getStackTraceString());
        }                
    }

    public static void contentPocOwnerChanged(Map<Id, Asset__c> newAsset, Map<Id, Asset__c> oldAsset) {
        Map<Id, Id> contentByRemovedEditor = new Map<Id, Id>();
        Map<Id, List<Id>> contentByOwnerId = new Map<Id, List<Id>>();
        Map<Id, List<Id>> contentByPoc = new Map<Id, List<Id>>();
        Map<Id, Id> pocLpByUserId = new Map<Id, Id>();
        List<Allowed_Content_Editor__c> contentByAddedEditor = new List<Allowed_Content_Editor__c>();
        List<Allowed_Content_Editor__c> editorToDelete = new List<Allowed_Content_Editor__c>();
        String eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        for(Asset__c asset : [SELECT Id, Content_POC__c, Content_POC__r.User__c, Owner.Id, Content_POC__r.User__r.profileId,
                             (SELECT Id, Learner_profile__r.User__c FROM Allowed_Content_Editors__r) 
                             FROM Asset__c
                             WHERE Id IN : newAsset.keySet()
                             AND RecordTypeId != :eventRecordTypeId
                             WITH USER_MODE]) {
            Asset__c old = oldAsset.get(asset.Id);
            if(old.Content_POC__c != asset.Content_POC__c) {               
                contentByRemovedEditor.put(old.Content_POC__c, asset.Id);                                  
                pocLpByUserId.put(asset.Content_POC__r.User__r.Id, asset.Content_POC__c);
                if(!contentByPoc.containsKey(asset.Content_POC__r.User__r.Id)) {
                    contentByPoc.put(asset.Content_POC__r.User__r.Id, new List<Id>{asset.Id});
                } else {
                    contentByPoc.get(asset.Content_POC__r.User__r.Id).add(asset.Id);
                }            
                                    
            } 
            
            if(old.OwnerId != asset.Owner.Id) {
                contentByRemovedEditor.put(old.OwnerId, asset.Id); 
                if(!contentByOwnerId.containsKey(asset.Owner.Id)) {
                    contentByOwnerId.put(asset.Owner.Id, new List<Id>{asset.Id});
                } else {
                    contentByOwnerId.get(asset.Owner.Id).add(asset.Id);
                }               
            }
            
            for(Allowed_Content_Editor__c editor : asset.Allowed_Content_Editors__r) {
                // check if old POC & Owner not the same user, bcz don't want to remove the Owner's content_editor record
                if(contentByRemovedEditor.containsKey(editor.Learner_profile__r.Id) && 
                    editor.Learner_profile__r.User__c != asset.Owner.Id) {
                    editorToDelete.add(editor);
                } else if(contentByRemovedEditor.containsKey(editor.Learner_profile__r.User__c)) {
                    editorToDelete.add(editor);
                }                
            }
        }

        if(!contentByPoc.isEmpty()) {
            contentByAddedEditor.addAll(filterEditorByACTPermission(pocLpByUserId, contentByPoc, 'Asset__c'));
        }

        if(!contentByOwnerId.isEmpty()) {
            contentByAddedEditor.addAll(createEditorFromUserId(contentByOwnerId, 'Asset__c'));
        }

        if(!contentByAddedEditor.isEmpty() || !editorToDelete.isEmpty()) {
            insertDeleteEditor(JSON.serialize(contentByAddedEditor), JSON.serialize(editorToDelete));
        }                        
    }

    @future
    public static void insertDeleteEditor(String editorToCreate, String editorToDelete) {
        List<Allowed_Content_Editor__c> createEditors = (List<Allowed_Content_Editor__c>)JSON.deserialize(editorToCreate, List<Allowed_Content_Editor__c>.class);
        List<Allowed_Content_Editor__c> deleteEditors = (List<Allowed_Content_Editor__c>)JSON.deserialize(editorToDelete, List<Allowed_Content_Editor__c>.class);
        if(createEditors != null && !createEditors.isEmpty()) {
            try {
                insert createEditors;
            }catch(Exception e){
                System.debug('Exception :: assetList :: '+e.getStackTraceString() + ' Message :: '+ e.getMessage());
            }
        }

        if(deleteEditors != null && !deleteEditors.isEmpty()) {
            try {
                delete deleteEditors;
            }catch(Exception e){
                System.debug('Exception :: assetList :: '+e.getStackTraceString() + ' Message :: '+ e.getMessage());
            }
        }        
    }

    public static List<Allowed_Content_Editor__c> createEditorFromUserId(Map<Id, List<Id>> contentByUserId, String objType) {
        List<Allowed_Content_Editor__c> editorList = new List<Allowed_Content_Editor__c>();        
        for(Learner_Profile__c lp : [SELECT Id, User__c 
                                    FROM Learner_profile__c 
                                    WHERE User__c IN :contentByUserId.keySet() 
                                    WITH USER_MODE]) {
            List<Id> contentIds = contentByUserId.get(lp.User__c);
            if(contentIds != null && !contentIds.isEmpty()) {
                for(Id contentId : contentIds) {
                    Allowed_Content_Editor__c temp = new Allowed_Content_Editor__c(Learner_Profile__c = lp.Id);
                    switch on objType {
                        when 'Asset__c' {
                            temp.Asset__c = contentId;
                        }
                        when 'Course__c' {
                            temp.Course__c = contentId;
                        }
                        when 'Curriculum__c' {
                            temp.Curriculum__c = contentId;
                        }
                    }
                    editorList.add(temp);                    
                }
            }
        } 
        return editorList;        
    }

    public static List<Allowed_Content_Editor__c> filterEditorByACTPermission(Map<Id, Id> lpByUserId, Map<Id, List<Id>> contentByUserId, String objType) {
        List<Allowed_Content_Editor__c> editorList = new List<Allowed_Content_Editor__c>();
        for(PermissionsetAssignment psa : [SELECT Id, AssigneeId
                                            FROM PermissionsetAssignment 
                                            WHERE (PermissionSetGroup.DeveloperName = 'ACT_Designer' OR PermissionSet.Name = 'ACT_Learning_Admin') 
                                            AND AssigneeId IN: contentByUserId.keySet()]) {
            List<Id> contentIds = contentByUserId.get(psa.AssigneeId);
            Id lpId = lpByUserId.get(psa.AssigneeId);
            if(contentIds != null && !contentIds.isEmpty() && lpId != null) {
                for(Id contentId : contentIds) {
                    Allowed_Content_Editor__c temp = new Allowed_Content_Editor__c(Learner_Profile__c = lpId);
                    switch on objType {
                        when 'Asset__c' {
                            temp.Asset__c = contentId;
                        }
                        when 'Course__c' {
                            temp.Course__c = contentId;
                        }
                        when 'Curriculum__c' {
                            temp.Curriculum__c = contentId;
                        }
                    }
                    editorList.add(temp);
                }
            }
        }
        return editorList;
    }

    public static void validateUserPermission(List<sObject> newSObjs, String objType) {
        Map<Id, List<sObject>> contentByUserId = new Map<Id, List<sObject>>();
        for(sObject obj : newSObjs) {
            Id userId;         
            switch on objType {
                when 'Asset__c' {
                    userId = ((Asset__c)obj).OwnerId;
                }
                when 'Course__c' {
                    userId = ((Course__c)obj).OwnerId;
                }
                when 'Curriculum__c' {
                    userId = ((Curriculum__c)obj).OwnerId;
                }
            }
            
            if(!contentByUserId.containsKey(userId)) {
                contentByUserId.put(userId, new List<sObject>{obj});
            } else {
                contentByUserId.get(userId).add(obj);
            }
        }
        for(PermissionsetAssignment psa : [SELECT AssigneeId
                                            FROM PermissionsetAssignment 
                                            WHERE (PermissionSetGroup.DeveloperName = 'ACT_Designer' OR PermissionSet.Name = 'ACT_Learning_Admin') 
                                            AND AssigneeId IN: contentByUserId.keySet()]) {
            contentByUserId.remove(psa.AssigneeId);
        }
        if(!contentByUserId.isEmpty()) {
            for(Id key : contentByUserId.keySet()) {
                for(sObject content : contentByUserId.get(key)) {
                    content.addError('Content owner must be a certified ACT Learning Admin. Please have them complete the training before adding them as a content owner.');
                }
            }
        }
    }
     
}