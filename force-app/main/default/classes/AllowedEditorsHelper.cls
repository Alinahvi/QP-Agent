public with sharing class AllowedEditorsHelper {

    public static void checkAllowedEditors(List<Allowed_Content_Editor__c> editorList) {
        List<Id> lpIds = new List<Id>();
        Map<Id, Allowed_Content_Editor__c> editorByAssetId = new Map<Id, Allowed_Content_Editor__c>();
        Map<Id, Allowed_Content_Editor__c> editorByCourseId = new Map<Id, Allowed_Content_Editor__c>();
        Map<Id, Allowed_Content_Editor__c> editorByCurriulumId = new Map<Id, Allowed_Content_Editor__c>();
        Map<Id, Id> lpByUserId = new Map<Id, Id>();

        for(Allowed_Content_Editor__c editor : editorList) {
            if(editor.Asset__c == null && editor.Course__c == null && editor.Curriculum__c == null) {
                editor.addError('Related learning is missing');
            } else {                
                // removed content_editor check from Asset
                // if(editor.Asset__c != null) {
                //     lpIds.add(editor.Learner_Profile__c);
                //     editorByAssetId.put(editor.Asset__c, editor);                    
                // }
                if(editor.Course__c != null) {
                    lpIds.add(editor.Learner_Profile__c); 
                    editorByCourseId.put(editor.Course__c, editor);                    
                } else if(editor.Curriculum__c != null) {
                    lpIds.add(editor.Learner_Profile__c); 
                    editorByCurriulumId.put(editor.Curriculum__c, editor);
                }                
            }
        }

        for(Learner_Profile__c lp : [SELECT Id, User__c 
                                    FROM Learner_Profile__c 
                                    WHERE Id IN :lpIds 
                                    WITH USER_MODE]) {
            lpByUserId.put(lp.User__c, lp.Id);
        }
        
        // removed content_editor check from Asset
        // if(!editorByAssetId.isEmpty() && checkAvailability(editorByAssetId, 'Asset__c')) {
        //     checkDesignerPermission(editorByAssetId, 'Asset__c', lpByUserId);
        //     checkForDuplicateEditor(editorByAssetId, 'Asset__c', lpByUserId);
        // } 
        if(!editorByCourseId.isEmpty() && checkAvailability(editorByCourseId, 'Course__c')) {
            checkDesignerPermission(editorByCourseId, 'Course__c', lpByUserId);
            checkForDuplicateEditor(editorByCourseId, 'Course__c', lpByUserId);
        } else if(!editorByCurriulumId.isEmpty() && checkAvailability(editorByCurriulumId, 'Curriculum__c')) {
            checkDesignerPermission(editorByCurriulumId, 'Curriculum__c', lpByUserId);
            checkForDuplicateEditor(editorByCurriulumId, 'Curriculum__c', lpByUserId);
        }
        
    }

    private static boolean checkAvailability(Map<Id, Allowed_Content_Editor__c> editorByContentId, String objType) {
        
        List<Id> contentId = new List<Id>();
        Boolean flag = true;
        for(Allowed_Content_Editor__c editor : editorByContentId.values()) {
            // removed content_editor check from Asset
            // contentId.add(editor.Asset__c != null ? editor.Asset__c : editor.Course__c != null ? editor.Course__c : 
            // editor.Curriculum__c != null ? editor.Curriculum__c : null);
            contentId.add(editor.Course__c != null ? editor.Course__c : editor.Curriculum__c != null ? editor.Curriculum__c : null);
        }

        Id userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();

        if(!System.isFuture()) {        
            Map<Id, Profile> allowedProfiles = new Map<Id, Profile>([SELECT Id FROM Profile WHERE Name IN ('L2 Support Profile','L1 Support Profile','System Administrator', 'Support Profile')]);
            if(!allowedProfiles.containsKey(profileId)) {
                String contentQuery = 'SELECT Id, Owner.Id, Content_POC__r.User__c FROM '+ objType +
                                ' WHERE Id IN : contentId' +
                                ' AND (Owner.Id = :userId OR Content_POC__r.User__c = :userId)' +
                                ' WITH USER_MODE';

                if(Database.query(contentQuery).isEmpty()) {
                    editorByContentId.values()[0].addError('Only Content Owner or Content POC can add content editors.');
                    return false;
                }
            }
        }   
        String agrQuery = 'SELECT count(Id) editors,  ' + objType + ' type' +
                          ' FROM Allowed_Content_Editor__c' +
                          ' WHERE ' + objType + ' IN : contentId' +
                          ' WITH USER_MODE' +
                          ' GROUP BY ' + objType;

        List<AggregateResult> ars = Database.query(agrQuery);
        for(Integer i = 0; i < ars.size(); i++) {
            AggregateResult ar = ars.get(i);
            if((Integer)ar.get('editors') >= 12) {
                flag = false;
                editorByContentId.get((Id)ar.get('type')).addError('No more than 12 content editors are allowed.');                          
            }
        }
        return flag;
    }

    private static void checkDesignerPermission(Map<Id, Allowed_Content_Editor__c> editorByContentId, String objType, Map<Id, Id> lpByUserId) {
        List<Id> permSetUser = new List<Id>();               
        for(User usr : [SELECT Id, 
                            (SELECT AssigneeId 
                            FROM PermissionsetAssignments 
                            WHERE (PermissionSetGroup.DeveloperName = 'ACT_Designer' OR PermissionSet.Name = 'ACT_Learning_Admin')) 
                        FROM User 
                        WHERE Id IN :lpByUserId.keySet() 
                        AND isActive = TRUE
                        WITH USER_MODE]) {
            if(!usr.PermissionsetAssignments.isEmpty()) {
                permSetUser.add(lpByUserId.get(usr.Id));
            }
        }

        for(Allowed_Content_Editor__c editor : editorByContentId.values()) {
            if(!permSetUser.contains(editor.Learner_Profile__c)) {
                editor.addError('Content editors must be a certified ACT Learning Admin. Please have them complete the training before adding them as a content editor.');
            }
        }
    }

    private static void checkForDuplicateEditor(Map<Id, Allowed_Content_Editor__c> editorByContentId, String objType, Map<Id, Id> lpByUserId) {
        List<Id> contentId = new List<Id>(editorByContentId.keySet());
        List<Id> lp = lpByUserId.values();
        String query = 'SELECT Id, Learner_Profile__c FROM Allowed_Content_Editor__c WHERE ' +
                        objType +
                        ' IN :contentId';
        query += ' AND Learner_Profile__c IN :lp';
        Set<Id> lpIds = new Set<Id>();
        for(sObject sObj : Database.query(query)) {
            lpIds.add((Id)sObj.get('Learner_Profile__c'));
        }
        for(Allowed_Content_Editor__c editor : editorByContentId.values()) {
            if(lpIds.contains(editor.Learner_Profile__c)) {
                editor.addError('Cannot add duplicate content editors.');
            }
        }
    }
    
    public static void updateEditorStringInContent(Map<Id, Allowed_Content_Editor__c> editors) {
        List<Id> contentId = new List<Id>();
        List<Asset__c> assetToUpdate = new List<Asset__c>();
        List<Course__c> courseToUpdate = new List<Course__c>();
        List<Curriculum__c> curriculumToUpdate = new List<Curriculum__c>();
        
        String objType;
        String lpStr = '';
        for(Allowed_Content_Editor__c editor : [SELECT Id, Learner_Profile__r.User__c, Asset__c, Asset__r.Content_Editor_Ids__c, 
                                               Course__c, Course__r.Content_Editor_Ids__c, Curriculum__c, Curriculum__r.Content_Editor_Ids__c
                                               FROM Allowed_Content_Editor__c 
                                               WHERE Id IN : editors.keySet()]) {
            // removed content_editor check from Asset
            // if(editor.Asset__c != null && 
            //     (String.isBlank(editor.Asset__r.Content_Editor_Ids__c) || !editor.Asset__r.Content_Editor_Ids__c.contains(editor.Learner_Profile__r.User__c))) {
            //     contentId.add(editor.Asset__c); 
            //     objType = 'Asset__c';
            //     lpStr += editor.Learner_Profile__r.User__c +',';                 
            // }
            if(editor.Course__c != null && 
                (String.isBlank(editor.Course__r.Content_Editor_Ids__c) || !editor.Course__r.Content_Editor_Ids__c.contains(editor.Learner_Profile__r.User__c))) {
                contentId.add(editor.Course__c);
                objType = 'Course__c';
                lpStr += editor.Learner_Profile__r.User__c +',';                            
            } else if(editor.Curriculum__c != null && 
                (String.isBlank(editor.Curriculum__r.Content_Editor_Ids__c) || !editor.Curriculum__r.Content_Editor_Ids__c.contains(editor.Learner_Profile__r.User__c))) {
                contentId.add(editor.Curriculum__c);
                objType = 'Curriculum__c';
                lpStr += editor.Learner_Profile__r.User__c +',';
            }
                       
            // lpStr += editor.Learner_Profile__r.User__c +',';
        }

        lpStr = lpStr.removeEnd(',');
        if(String.isBlank(lpStr) || contentId.isEmpty()) {
            return;
        }

        String contentQuery = 'SELECT Id, Content_Editor_Ids__c FROM '+ objType +
                              ' WHERE Id IN : contentId';
        List<sObject> sObjList = Database.query(contentQuery);
        for(sObject obj : sObjList) {
            String currentStr = (String)obj.get('Content_Editor_Ids__c');
            if(String.isNotEmpty(currentStr)) {
                currentStr += ','+lpStr;
            } else {
                currentStr = lpStr;
            }
            obj.put('Content_Editor_Ids__c', currentStr);
            // removed content_editor check from Asset
            // if(objType == 'Asset__c') {
            //     assetToUpdate.add((Asset__c)obj);
            // } 
            if(objType == 'Course__c') {
                courseToUpdate.add((Course__c)obj);   
            } else if(objType == 'Curriculum__c') {
                curriculumToUpdate.add((Curriculum__c)obj);
            }
        }
        try {
            // removed content_editor check from Asset
            // if(!assetToUpdate.isEmpty()) {
            //     update as user assetToUpdate;
            // } 
            if(!courseToUpdate.isEmpty()) {
                update as user courseToUpdate;
            } else if(!curriculumToUpdate.isEmpty()) {
                update as user curriculumToUpdate;
            }
        } catch(Exception e) {
            System.debug('Error while updating Content Editor String ---- '+e.getStackTraceString());
        }        
    }
    
    public static void deletedContentEditor(Map<Id, Allowed_Content_Editor__c> editors) {
        Map<Id, Id> assetByEditorId = new Map<Id, Id>();
        Map<Id, Id> courseByEditorId = new Map<Id, Id>();
        Map<Id, Id> curriculumByEditorId = new Map<Id, Id>();

        Map<Id, String> editorStrByassetId = new Map<Id, String>();
        Map<Id, String> editorStrByCourseId = new Map<Id, String>();
        Map<Id, String> editorStrByCrrId = new Map<Id, String>();

        for(Allowed_Content_Editor__c editor : [SELECT Id, Asset__r.Owner.Id, Asset__r.Content_Editor_Ids__c, Course__r.Content_Editor_Ids__c, 
                                               Course__r.Owner.Id, Curriculum__r.Owner.Id, Curriculum__r.Content_Editor_Ids__c, 
                                               Learner_Profile__r.User__c 
                                               FROM Allowed_Content_Editor__c 
                                               WHERE Id IN :editors.keySet()
                                               WITH USER_MODE]) {
            
            // removed content_editor check from Asset
            // if(editor.Asset__r != null && String.isNotEmpty(editor.Asset__r.Content_Editor_Ids__c)) {
            //     if(!editorStrByAssetId.containsKey(editor.Asset__r.Id)) {
            //         editorStrByassetId.put(editor.Asset__r.Id, removeDeletedEditorId(editor.Asset__r.Content_Editor_Ids__c.split(','), editor.Learner_Profile__r.User__c));
            //     } else {
            //         editorStrByassetId.put(editor.Asset__r.Id, removeDeletedEditorId(editorStrByassetId.get(editor.Asset__r.Id).split(','), editor.Learner_Profile__r.User__c));
            //     }                
            // } 
            if(editor.Course__r != null && String.isNotEmpty(editor.Course__r.Content_Editor_Ids__c)) {
                if(!editorStrByCourseId.containsKey(editor.Course__r.Id)) {
                    editorStrByCourseId.put(editor.Course__r.Id, removeDeletedEditorId(editor.Course__r.Content_Editor_Ids__c.split(','), editor.Learner_Profile__r.User__c));
                } else {
                    editorStrByCourseId.put(editor.Course__r.Id, removeDeletedEditorId(editorStrByCourseId.get(editor.Course__r.Id).split(','), editor.Learner_Profile__r.User__c));
                }                                                          
            } else if(editor.Curriculum__r != null && String.isNotEmpty(editor.Curriculum__r.Content_Editor_Ids__c)) {
                if(!editorStrByCrrId.containsKey(editor.Curriculum__r.Id)) {
                    editorStrByCrrId.put(editor.Curriculum__r.Id, removeDeletedEditorId(editor.Curriculum__r.Content_Editor_Ids__c.split(','), editor.Learner_Profile__r.User__c));
                } else {
                    editorStrByCrrId.put(editor.Curriculum__r.Id, removeDeletedEditorId(editorStrByCrrId.get(editor.Curriculum__r.Id).split(','), editor.Learner_Profile__r.User__c));
                }                
            }            
        }
        // removed content_editor check from Asset
        // if(!editorStrByassetId.isEmpty()) {
        //     updateContentString(contentToUpdate(editorStrByassetId), 'Asset__c');            
        // }
        if(!editorStrByCourseId.isEmpty()) {
            updateContentString(contentToUpdate(editorStrByCourseId), 'Course__c');
        }
        if(!editorStrByCrrId.isEmpty()) {
            updateContentString(contentToUpdate(editorStrByCrrId), 'Curriculum__c');
        }        
    }

    public static String removeDeletedEditorId(List<String> strList, String strToRemove) {
        Integer index = strList.indexOf(strToRemove);
        String reducedStr = '';
        if(index >= 0) {
            String removed = strList.remove(index);
            reducedStr = String.join(strList, ',');            
        } else {
            reducedStr = String.join(strList, ',');
        } 
        return reducedStr;
    }

    public static String contentToUpdate(Map<Id, String> editorStrByContentId) {
        List<Object> contentList = new List<Object>();
        for(Id key : editorStrByContentId.KeySet()) {
            String contentObjectType = key.getSObjectType() + '';
            switch on contentObjectType{
                // removed content_editor check from Asset
                // when 'Asset__c' {
                //     contentList.add((Object)new Asset__c(Id = key, Content_Editor_Ids__c = editorStrByContentId.get(key)));
                // }
                when 'Course__c' {
                    contentList.add((Object)new Course__c(Id = key, Content_Editor_Ids__c = editorStrByContentId.get(key)));
                }
                when 'Curriculum__c' {
                    contentList.add((Object)new Curriculum__c(Id = key, Content_Editor_Ids__c = editorStrByContentId.get(key)));
                }
            }
        }
        return JSON.serialize(contentList);
    }
    
    public static void updateContentString(String contentToUpdate, String objType) {
        switch on objType{
            // removed content_editor check from Asset
            // when 'Asset__c' {
            //     List<Asset__c> assetList = (List<Asset__c>)JSON.deserialize(contentToUpdate, List<Asset__c>.class);
            //     try {
            //         update as User assetList;
            //     }catch(Exception e) {
            //         System.debug('Exception :: assetList :: '+e.getStackTraceString() + ' Message :: '+ e.getMessage());
            //     }
            // }
            when 'Course__c' {
                List<Course__c> courseList = (List<Course__c>)JSON.deserialize(contentToUpdate, List<Course__c>.class);
                try {
                    update as User courseList;
                }catch(Exception e) {
                    System.debug('Exception :: courseList :: '+e.getStackTraceString() + ' Message :: '+ e.getMessage());
                }
            }
            when 'Curriculum__c' {
                List<Curriculum__c> crrList = (List<Curriculum__c>)JSON.deserialize(contentToUpdate, List<Curriculum__c>.class);
                try {
                    update as User crrList;
                }catch(Exception e) {
                    System.debug('Exception :: crrList :: '+e.getStackTraceString() + ' Message :: '+ e.getMessage());
                }
            }
        }
    }
}