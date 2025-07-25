public with sharing class learningSupport {
    public static FINAL String CASE_TYPE_LEARNER = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ACT_Learning_Case_Type').getRecordTypeId();
    
    @AuraEnabled
    public static ResponseData getCaseData() {
        ResponseData rd = new ResponseData();
        try {
            List<Map<String, Object>> formattedCaseItems = new List<Map<String, Object>>();
            List<Learner_Profile__c> lps = [SELECT Id, Name, Title__c, User__c, SlackId__c
                                            FROM Learner_Profile__c
                                            WHERE User__c =: UserInfo.getUserId()
                                            AND Status__c = 'Active'
                                            WITH USER_MODE];
            if(lps.isEmpty() || String.isEmpty(CASE_TYPE_LEARNER)) {
                rd.addError('No Learner Profile or Related Case Type found. Please contact support for help');
                return rd;
            }

            Learner_Profile__c lp = lps.get(0);
            List<sObject> caseList = [SELECT Id, Learner_Profile__r.SlackId__c, createdDate, Topic__c, Slack_Message_ID__c, 
                                      Description, Status, CaseNumber
                                      FROM Case
                                      WHERE RecordTypeId =: CASE_TYPE_LEARNER
                                      AND Learner_Profile__c =: lp.Id
                                      WITH USER_MODE
                                      ORDER BY  lastmodifieddate DESC];

            for(sObject obj : caseList) {
                formattedCaseItems.add(learningItemDetail.formatLearningItem(obj));
            }
            rd.put('learningItems', formattedCaseItems);
            rd.put('lp', lp);
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd;    
    }

    @AuraEnabled
    public static ResponseData createNewCase(String caseData){
        ResponseData rd = new ResponseData();
        try {
            if(String.isEmpty(CASE_TYPE_LEARNER)) {
                rd.addError('No related Case Type found. Please contact support for help');
                return rd;
            }
            Map<String, Object> caseRecord = (Map<String, Object>)JSON.deserializeUntyped(caseData);
            // List<Group> queue = [SELECT Id, developerName FROM Group WHERE Type = 'Queue' AND DeveloperNAME IN ('ACT_Tier_1_Support_Queue','ACT_Tier_2_Support_Queue')];
            // default to Tier - 1 queue
            List<Group> queue = [SELECT Id, developerName FROM Group WHERE Type = 'Queue' AND DeveloperNAME IN ('ACT_Tier_1_Support_Queue')];
            // Map<String, String> queueIdByDevName = new Map<String, String>();
            // for(Group grp : queue) {
            //     queueIdByDevName.put(grp.developerName, grp.Id);
            // }
            // String caseTier = '';
            // String topic = (String)caseRecord.get('topic');
            String caseOwner = queue[0].Id;
            // String caseOwner = '';
            
            // if(topic == 'Skills Assessment' || topic == 'Access and Permissions' || topic == 'Report a Bug') {
            //     caseTier = 'Tier 2';
            //     caseOwner = queueIdByDevName.get('ACT_Tier_2_Support_Queue');
            // } else {
            //     caseTier = 'Tier 1';
            //     caseOwner = queueIdByDevName.get('ACT_Tier_1_Support_Queue');
            // }
            Case actCase =  new Case(
                // Topic__c = topic,
                Description = ((String)caseRecord.get('description')),
                Learner_Profile__c = (String)caseRecord.get('lp'),
                recordTypeId = CASE_TYPE_LEARNER,
                Case_Tier__c = 'Tier 1',
                OwnerId = caseOwner
            );
            
            // AssignmentRule caseAssignmentRule = [SELECT Id 
            //                                         FROM AssignmentRule 
            //                                         WHERE SobjectType = 'Case' AND Active = true 
            //                                         LIMIT 1];
            // if(caseAssignmentRule != null) {
            //     Database.DMLOptions dmlOpts = new Database.DMLOptions();
            //     dmlOpts.assignmentRuleHeader.assignmentRuleId = caseAssignmentRule.id;
            //     actCase.setOptions(dmlOpts);
            // }
            insert as user actCase;
            List<Object> fileList = (List<Object>)caseRecord.get('file');
            if(fileList != null && !fileList.isEmpty()) {
                addAttachments(actCase.Id, fileList);
            }
            List<Case> newCase = [SELECT Id, CaseNumber, Status, Topic__c, Description, Slack_Message_ID__c,
                                 Learner_Profile__r.User__r.FirstName, createdDate, Learner_Profile__r.slackid__c
                                 FROM Case 
                                 WHERE Id =: actCase.Id
                                 WITH USER_MODE];
            rd.put('case', newCase[0]);            
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd;
    }

    public static Boolean addAttachments(Id caseId, List<Object> files) {
        Boolean isSuccess = false;
        if(files.isEmpty()) {
            return isSuccess;
        }
        try {
            List<Map<String, Object>> data = new List<Map<String, Object>>();
            for(Object obj : files) {
                data.add((Map<String, Object>)obj);            
            }

            List<ContentVersion> cvList = new List<ContentVersion>();
            for(Map<String, Object> fileData : data) {
                String fileContent = (String)fileData.get('base64');
                String fileName = (String)fileData.get('fileName');
                cvList.add(
                    new ContentVersion(
                        ContentLocation = 'S',
                        VersionData = EncodingUtil.base64Decode(fileContent),
                        Title = fileName,
                        PathOnClient = fileName
                ));
            }
            insert as user cvList;

            List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
            for(ContentVersion cv : [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =: cvList]) {
                cdList.add(
                    new ContentDocumentLink(
                        LinkedEntityId = caseId,
                        ContentDocumentId = cv.ContentDocumentId,
                        Visibility = 'AllUsers',
                        shareType = 'V'
                ));                            
            }
            insert as user cdList;
                        
            isSuccess = true;
        }catch(Exception e) {
            System.debug('Exception caseCreation :: addAttachments :: '+ e.getMessage() + ':: Line No.:: '+e.getLineNumber()+ ' :: StackTrace :: '+ e.getStackTraceString());
        }       
        return isSuccess;
    } 

    public static Map<String, List<Object>> getRelatedFiles(Set<Id> caseIds) {
        Map<Id, Id> caseByDocumentId = new Map<Id, Id>();
        Map<String, List<fileData>> fileData = new Map<String, List<fileData>>();
        if(caseIds.isEmpty()) {
            return fileData;
        }
         
        for(ContentDocumentLink document : [SELECT ContentDocumentId, LinkedEntityId 
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId 
                                            IN: caseIds 
                                            AND LinkedEntity.Type='Case']) {
            caseByDocumentId.put(document.ContentDocumentId, document.LinkedEntityId);
        }
        
        for(ContentVersion cv : [SELECT Id, Title, ContentDocumentId, FileExtension 
                                FROM ContentVersion 
                                WHERE ContentDocumentId IN: caseByDocumentId.keySet()
                                ORDER BY lastmodifieddate DESC]) {
            Id caseId = caseByDocumentId.get(cv.ContentDocumentId);
            if(caseId != null) {
                if(fileData.get(caseId) == null) {
                    fileData.put(caseId, new List<fileData>());
                }
                String previewLink = '';
                String fileTypeIcon = '';
                String downloadLink = '';
                if(cv.FileExtension == 'png' || cv.FileExtension == 'jpg' || cv.FileExtension == 'jpeg') {
                    previewLink = System.URL.getSalesforceBaseUrl().toExternalForm()+'/act/sfc/servlet.shepherd/document/download/'+cv.ContentDocumentId; 
                    fileTypeIcon = 'doctype:image'; 
                } else if(cv.FileExtension == 'pdf') {
                    previewLink = 'https://readiness--c.documentforce.com/servlet/servlet.ImageServer?id=0152E000003y18U&oid=00D800000012boG';
                    fileTypeIcon = 'doctype:pdf'; 
                } else{
                    previewLink = 'https://readiness--c.documentforce.com/servlet/servlet.ImageServer?id=0152E000003y18U&oid=00D800000012boG';
                    fileTypeIcon = 'doctype:unknown'; 
                }
                
                downloadLink = System.URL.getSalesforceBaseUrl().toExternalForm()+'/act/sfc/servlet.shepherd/document/download/'+cv.ContentDocumentId;

                fileData.get(caseId).add(
                    new fileData(cv.ContentDocumentId, cv.Title, previewLink, fileTypeIcon, downloadLink, cv.FileExtension)
                ); 
            }
                                  
        }
        return (Map<String, List<Object>>)fileData; 
    }

    @AuraEnabled
    public static ResponseData closeCase(String caseId) {
        ResponseData rd = new ResponseData();
        try {            
            if(caseId == null){
                rd.addError('Case Id is null.');
                return rd;
            }
            List<Case> closeCase = [SELECT Id, /*Learner_Profile__r.SlackId__c,*/ createdDate, Topic__c, Slack_Message_ID__c, 
                                    Description, Status, CaseNumber 
                                    FROM Case 
                                    WHERE Id =: caseId
                                    WITH USER_MODE];
            if(!closeCase.isEmpty()) {
                closeCase[0].Status = 'Closed by User';
            }
            update as user Security.stripInaccessible(AccessType.UPDATABLE, closeCase).getRecords();
            rd.put('case', learningItemDetail.formatLearningItem((sObject)closeCase[0]));    
        } catch (DMLException e) {
            rd.addError(e);
            System.debug('The Case field(s) "' + String.join(e.getDmlFieldNames(0), ', ') + '" are not accessible for update of Case');
            System.debug('Exception learningSupport :: closeCase :: '+ e.getMessage() + ':: Line No.:: '+e.getLineNumber()+ ' :: StackTrace :: '+ e.getStackTraceString());
        }
        return rd;
    }

    public static boolean flipCaseStatus(String caseId) {
        try {
            List<Case> caseToUpdate = new List<Case>();
            if(caseId == null){
                return false;
            }
            List<Case> caseList = [SELECT Id, Status
                                    FROM Case 
                                    WHERE Id =: caseId
                                    WITH USER_MODE];
            if(!caseList.isEmpty()) {
                if(caseList[0].Status == 'Awaiting user response') {
                    caseList[0].Status = 'Review'; 
                    caseToUpdate.add(caseList[0]);
                }                
            }
            if(!caseToUpdate.isEmpty()) {
                update as user caseToUpdate;
            }
            return true;
        }catch(Exception e) {
            System.debug('Exception learningSupport :: flipCaseStaus :: '+ e.getMessage() + ':: Line No.:: '+e.getLineNumber()+ ' :: StackTrace :: '+ e.getStackTraceString());
            return false;
        }
    }

    class fileData {
        String documentId;
        String fileName;
        String previewLink; 
        String fileTypeIcon; 
        String downloadLink;
        String fileExtention;
        
        fileData(String Id, String name, String preview, String fileIcon, String download, string fileExt) {
            documentId = Id;
            fileName = name;
            previewLink = preview;
            fileTypeIcon = fileIcon;
            downloadLink = download;
            fileExtention = fileExt;
        }
    }
}