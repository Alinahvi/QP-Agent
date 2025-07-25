@RestResource(urlMapping='/actMsg/*')
global with sharing class SlackNotificationLog {
    
    @HttpPost global static String doPost() { 
        String requestBody = RestContext.request.requestBody.toString();
        switch on RestContext.request.requestURI.substringAfterLast('/') {
            when 'postSlackLog' { 
                return processSlackLogs(requestBody); 
            }
            when 'userComment' {
                return handleUserComment(requestBody);
            }
            when 'updateDocuLink' {
                return updateDocumentParentId(requestBody);
            }
            when 'trainerSession' {
                return trainerSessionDetails(requestBody); 
            }
            when else { 
                return '';
            }
        }       
    }
    
    // @HttpGet global static String doGet() { 
    //     String requestBody = RestContext.request.requestBody.toString();
    //     System.debug('GET **** requestBody ------ '+requestBody);
    //     switch on RestContext.request.requestURI.substringAfterLast('/') {
    //         when 'trainerSession' {
    //             return trainerSessionDetails(requestBody); 
    //         }
    //         when else { 
    //             return '';
    //         }
    //     }
    // }
    
    public static string processSlackLogs(String requestBody) {
        List<NotificationLog> req = (List<NotificationLog>)JSON.deserialize(requestBody, List<NotificationLog>.class);
        Map<String, Notification_Log__c> actLog = new Map<String, Notification_Log__c>();
        for(NotificationLog log : req) {
            if(!actLog.containskey(log.SlackBlockId)) {
                Notification_Log__c temp = new Notification_Log__c(
                    Assigned_Course__c = log.AssignedLearningType == 'Course' ? log.AssignedLearningId : null,
                    Assigned_Curriculum__c = log.AssignedLearningType == 'Curricula' ? log.AssignedLearningId : null,
                    Assignment__c = log.AssignedLearningType == 'Asset' ? log.AssignedLearningId : null,
                    Error__c = log.IsError,
                    Error_Message__c = log.IsError ? log.ResponseBody : '',
                    Failure_System__c = log.IsError ? 'Heroku' : '',
                    Learner_Profile__c = log.LearnerProfileId,
                    Learning_Type__c = log.AssignedLearningType,
                    Notification_Log_Type__c = log.IsSecurityBlock ? 'Security' : 'Standard',
                    Slack_Block__c = log.SlackBlockId,
                    Slack_Notification_Message__c = log.SlackMessage,
                    Message_Type__c = log.MessageType,
                    Sent_Date__c = String.isNotEmpty(log.UpdatedDate) ? Date.valueOf(log.UpdatedDate.substringBefore('T')) : Date.today()
                );
                actLog.put(log.SlackBlockId, temp);
            }
        }   
        String results = upsertNotificationLog(actLog);
        return results;
    }
    
    public static String upsertNotificationLog(Map<String, Notification_Log__c> slackLog) {
        Map<String, Object> result = new Map<String, Object>();
        if(slackLog.isEmpty()) {
            result.put('ok', (Object)Boolean.valueOf('true'));
            result.put('message', (Object)'empty-string');
            return JSON.serialize(result);
        }

        Map<String, Notification_Log__c> tempMap = slackLog;
        List<Notification_Log__c> upsertList = new List<Notification_Log__c>();
        for(Notification_Log__c log : [SELECT Id, Assigned_Course__c, Assigned_Curriculum__c, Assignment__c, Error__c, Error_Message__c,
                                      Failure_System__c, Learner_Profile__c, Learning_Type__c, Notification_Log_Type__c, Sent_Date__c, Slack_Block__c, Slack_Notification_Message__c
                                      FROM Notification_Log__c
                                      WHERE Slack_Block__c IN: tempMap.KeySet()]) {
            Notification_Log__c nl = slackLog.get(log.Slack_Block__c);
            if(nl != null) {
                nl.Id = log.Id;
                upsertList.add(nl);
                tempMap.remove(log.Slack_Block__c);
            }
        }
        if(!tempMap.isEmpty()) {
            upsertList.addAll(tempMap.values());
        }
        try {
            if(!upsertList.isEmpty()) {
                // upsert as user upsertList;
                Database.upsert(upsertList, false);
            }
            result.put('ok', (Object)Boolean.valueOf('true'));
            result.put('message', (Object)'success');
        } catch (DmlException e) {
            result.put('ok', (Object)Boolean.valueOf('false'));
            result.put('message', (Object)(e.getMessage()+' :: '+e.getStackTraceString()));
            System.debug('upsertNotificationLog :: Upsert Error :: '+ e.getStackTraceString());
        }
        return JSON.serialize(result);
    }

    public static string handleUserComment(String requestBody) {
        Map<String, Object> result = new Map<String, Object>();
        Map<String, Object> commentDetails = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        try {
            List<Case> actCase = [SELECT Id, createdById, Status, Learner_Profile__r.User__c 
                                    FROM Case 
                                    WHERE Slack_Message_ID__c =: (String)commentDetails.get('thread_ts') 
                                    AND Learner_Profile__r.SlackId__c =: (String)commentDetails.get('user')
                                    AND Status NOT IN ('Closed','Closed by User','Closed - No Response')];
            if(!actCase.isEmpty()) {
                CaseComment comment = new CaseComment(
                    CommentBody = (String)commentDetails.get('text'),
                    ParentId = actCase[0].Id,
                    CreatedById = actCase[0].Learner_Profile__r.User__c
                    // CreatedById = actCase[0].createdById
                );
                insert comment;
            }           
        } catch(Exception e) {
            result.put('ok', (Object)Boolean.valueOf('false'));
            result.put('message', e.getMessage() +' ----- ' +e.getStackTraceString());
            return JSON.serialize(result);
        }  

        result.put('ok', (Object)Boolean.valueOf('true'));
        result.put('message', (Object)'success');
        return JSON.serialize(result);
    }

    public static String updateDocumentParentId(String requestBody) {
        Map<String, Object> result = new Map<String, Object>();
        Map<String, Object> caseDetails = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        try {
            List<Case> actCase = [SELECT Id, createdById, Status 
                                    FROM Case 
                                    WHERE Slack_Message_ID__c =: (String)caseDetails.get('thread_ts') 
                                    AND Learner_Profile__r.SlackId__c =: (String)caseDetails.get('user')
                                    AND Status NOT IN ('Closed','Closed by User','Closed - No Response')];
            if(!actCase.isEmpty()) {
                List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
                for(ContentVersion cvr : [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =: (String)caseDetails.get('versionDataId')]) {
                    cdList.add(
                        new ContentDocumentLink(
                            LinkedEntityId = actCase[0].Id,
                            ContentDocumentId = cvr.ContentDocumentId,
                            Visibility = 'AllUsers',
                            shareType = 'V'
                        )
                    );                            
                }
                insert cdList;  
                if(actCase[0].Status == 'Awaiting user response') {
                    updateCaseStatus(actCase[0].Id, 'Review');
                    //     actCase[0].Status = 'Review';
                    //     update actCase;
                }          
            }           
        } catch(Exception e) {
            result.put('ok', (Object)Boolean.valueOf('false'));
            result.put('message', e.getMessage() +' ----- ' +e.getStackTraceString());
            return JSON.serialize(result);
        }        

        result.put('ok', (Object)Boolean.valueOf('true'));
        result.put('message', (Object)'success');
        return JSON.serialize(result);       
    }

    public static string trainerSessionDetails(String requestBody) {
        Map<String, Object> action = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        Map<String, Object> msg = new Map<String, Object>();
        Map<String, Object> result = new Map<String, Object>();
        Session_Guest__c sg;
        for(Session_Guest__c aSession : [SELECT Id, Role__c, Learner_Profile__r.Name, Slack_Message_ID__c, Learner_Profile__r.SlackId__c, 
                                            Learner_Profile__r.User__r.FirstName, Session__r.Start_Date__c, Learner_Profile__r.Manager__c,
                                            Session__r.Start_Time__c, Session__r.End_Time__c, Session__r.End_Date__c,
                                            Session__r.Name, Session__r.Start_Time_Converted__c, Session__r.End_Time_Converted__c,
                                            Session__r.Owner.Name, Session__r.Asset__r.Name, Session__r.Description__c, Session__r.Asset__r.Content_Owner_Organization__c,
                                            Session__r.Asset__r.Time_Estimate__c, From_Scheduler__c, Session_Role_Status__c, Send_Registration_Email__c
                                            FROM Session_Guest__c 
                                            WHERE Slack_Message_ID__c =: (String)action.get('thread_ts')
                                            AND Learner_Profile__r.Status__c = 'Active'
                                            WITH USER_MODE
                                            LIMIT 1]) {
            if(aSession.From_Scheduler__c && (String)action.get('type') == 'accepted') {
                aSession.Session_Role_Status__c = 'Approved';
                aSession.Send_Registration_Email__c = true;        
            } else if(aSession.From_Scheduler__c && (String)action.get('type') == 'declined') {
                aSession.Session_Role_Status__c = 'Declined';                 
            }
            sg = aSession;          
        }
        try {
            if(sg != null) {
                if(sg.From_Scheduler__c/* && ((String)action.get('type') == 'accepted' || (String)action.get('type') == 'declined')*/) {
                    update sg;
                }                
                msg = SessionOwnerRoleNotification.createDataMap(sg, sg.From_Scheduler__c);
                if(!msg.isEmpty()) {
                    result.put('ok', (Object)Boolean.valueOf('true'));
                    result.put('message', (Object)'success');
                    result.put('trainerSession', msg);
                } else {
                    result.put('ok', (Object)Boolean.valueOf('false'));
                    result.put('message', 'No session record got fetched from this ts Id : ' +(String)action.get('thread_ts'));
                }                
            } else {
                result.put('ok', (Object)Boolean.valueOf('false'));
                result.put('message', 'No session record got fetched from this ts Id : ' +(String)action.get('thread_ts'));
            }
        } catch(exception e) {
            result.put('ok', (Object)Boolean.valueOf('false'));
            result.put('message', e.getMessage() +' ----- ' +e.getStackTraceString());            
        } 
        return JSON.serialize(result);       
    }

    @future
    public static void updateCaseStatus(String caseId, String newStatus){   
        try{
            update as user (new Case(Id = caseId, Status = newStatus));
        }catch(Exception e) {
            System.debug('Update case error :::: '+e.getMessage() +' ----- ' +e.getStackTraceString());
        }
    }

    global class NotificationLog {
        global String LearnerProfileId { get; set; }
        global String AssignedLearningId { get; set; }
        global String SlackBlockId { get; set; }
        global String CreatedDate { get; set; }
        global String UpdatedDate { get; set; }
        global String SlackMessage { get; set; }
        global String ResponseBody { get; set; }
        global Boolean IsSecurityBlock { get; set; }
        global Boolean IsError { get; set; }
        global String AssignedLearningType { get; set; }
        global String MessageType { get; set; }
    }
}