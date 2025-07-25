public with sharing class SlackQueueableNotification implements Queueable, Database.AllowsCallouts {
    public Map<String, Object> dataMap = new Map<String, Object>();
    public Map<String, String> metaInfo = new Map<String, String>();
    public static FINAL String CASE_TYPE_LEARNER = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ACT_Learning_Case_Type').getRecordTypeId();
    // public static FINAL String CASE_TYPE_OPERATIONS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ACT_Operations_Case_Type').getRecordTypeId();
    private static String orgURL = new SiteLink().siteUrlWithPrefix;
    public static List<Slack_Notification_Error__c> errorList = new List<Slack_Notification_Error__c>();
    
    public SlackQueueableNotification(Map<String, String> metaInfo, Map<String, Object> data) {
        this.metaInfo = metaInfo;
        this.dataMap = data;
    }

    public SlackQueueableNotification(Map<String, String> metaInfo) {
        this.metaInfo = metaInfo;        
    }

    public void execute(QueueableContext context) {
        String type = metaInfo.get('type');
        String event = metaInfo.get('action');

        for(String key : dataMap.keySet()) {
            // Callout: Limit 100
            if(Limits.getCallouts() == (Limits.getLimitCallouts()-2)) {
                break;
            }
            
            if(type == 'Case') {
                if(event == 'case-auto-close' || event == 'case-status' || event == 'case-close') {
                    sendCaseThreadMsg((Map<String, String>)dataMap.get(key));
                } else if(event == 'new-case') {
                    sendCaseNotification(key, (List<Case>)dataMap.get(key));
                }
            }
            if(type == 'CaseComment') {
                if(event == 'agent-comment') {
                    sendCaseThreadMsg((Map<String, String>)dataMap.get(key));
                }
            }
            if(type == 'AssignedSession') {
                if(event == 'session-cancelled') {
                    sendSessionCancelledNotification((Assigned_Session__c)dataMap.get(key));                    
                } 
                // else if(event == 'session-attended') {
                //     sendAttendedSurveyNotification((Assigned_Session__c)dataMap.get(key));
                // }
            }
            if(type == 'AssignedCourse') {
                if(event == 'course-survey') {
                    sendCourseSurveyNotification((Assigned_Course__c)dataMap.get(key));                    
                }
            }
            if(type == 'SessionGuest') {
                if(event == 'guest-role-changed') {
                    sendGuestRoleChangedMsg((Map<String, String>)dataMap.get(key));
                } else if(event == 'guest-role-deleted') {
                    sendGuestRoleDeletedMsg((Map<String, String>)dataMap.get(key));
                }
            }
            if(type == 'In-App-Assessment') {
                if(event == 'designated-assessor') {
                    sendAssessorNotification(key, (Map<String, Object>)dataMap.get(key));
                }
            }
            dataMap.remove(key);           
        }

        if(!errorList.isEmpty()) {
            try {
                insert as user errorList;
            } catch(Exception e) {
                System.debug('Error:: Adding slack error log *********** :: ' + e.getMessage());
                System.debug('Error:: Adding slack error log *********** :: ' + e.getStackTraceString());
            }
        }
        if(!dataMap.isEmpty()) {
            System.enqueueJob(new SlackQueueableNotification(metaInfo, dataMap));
        }
    }

    public void sendSessionCancelledNotification(Assigned_Session__c aSession) {
        String payload = SessionSlackNotification.createSessionPayload(aSession, 'sessionCancelled', orgURL);
        Map<String, Object> message = new Map<String, Object>{
            'notifications' => new Map<String, Object> {
                'learnerProfileId' => aSession.Learner_Profile__r.Id,
                'slackUserId' => aSession.Learner_Profile__r.SlackId__c,
                'notificationMessages' => payload, // '['+payload+']',
                'notificationType' => 'event-session'
            }
        };
        postMessage(message, aSession.Learner_Profile__r.Id);
    }

    public void sendCourseSurveyNotification(Assigned_Course__c aCr) {
        String payload = System.Label.Slack_Course_Completed_Survey_Block;
        payload = payload.replace('{0}', aCr.Course__r.Name.escapeJava());
        payload = payload.replace('{1}', aCr.Course__r.Survey_URL__c);
        Map<String, Object> message = new Map<String, Object>{
            'notifications' => new Map<String, Object> {
                'learnerProfileId' => aCr.Learner_Profile__r.Id,
                'slackUserId' => aCr.Learner_Profile__r.SlackId__c,
                'notificationMessages' => '['+payload+']',
                'notificationType' => 'course-survey'
            }
        };
        postMessage(message, aCr.Learner_Profile__r.Id);
    }

    public void sendAssessorNotification(String assessorId, Map<String, Object> assetDetails) {
        String slackId;
        String lpId;

        List<Object> assets = new List<Object>();
        Map<String, List<Object>> block = new Map<String, List<Object>>();
        for(String key : assetDetails.keySet()) {
            Object obj = assetDetails.get(key);
            assets.add(obj);
            Map<String, String> asset = (Map<String, String>)obj;
            if(slackId == null && lpId == null) {
                slackId = asset.get('slackId');
                lpId = asset.get('lpId');
            }            
        }
        if(!assets.isEmpty() && slackId != null && lpId != null) {
            block.put('assets', assets);
            Map<String, Object> payload = new Map<String, Object>{
                'notifications' => new Map<String, Object> {
                    'learnerProfileId' => lpId,
                    'slackUserId' => slackId,
                    'notificationMessages' => JSON.serialize(block),
                    'notificationType' => 'inApp-assessor-notification'
                }
            };
            postMessage(payload, lpId);
        }

    }

    public void sendCaseNotification(String slackId, List<Case> caseList) {
        String payload = System.Label.Slack_New_Case_Text;
        List<Case> caseToUpdate = new List<Case>();
        for(Case actCase : caseList) {
            // payload = payload.replace('{0}', actCase.Topic__c);
            payload = payload.replace('{0}', actCase.CaseNumber);
            payload = payload.replace('{1}', actCase.createdDate.format('MMMMM d, YYYY'));
            
            // payload = payload.replace('{0}', actCase.CaseNumber);
            // payload = payload.replace('{1}', actCase.createdDate.format('MMMMM d, YYYY'));
            // payload = payload.replace('{2}', actCase.Topic__c);
            // String des = String.isEmpty(actCase.Description) ? '' : actCase.Description.escapeJava();
            // payload = payload.replace('{3}', des);
            if(actCase.RecordTypeId == CASE_TYPE_LEARNER) {
                payload = payload.replace('{2}', orgURL+'/support-detail?id='+actCase.Id);
            } else {
                payload = payload.replace('{2}', System.URL.getOrgDomainUrl().toExternalForm()+'/'+actCase.Id);
            }           
            Map<String, Object> message = new Map<String, Object>{
                'notifications' => new Map<String, Object> {
                    'learnerProfileId' => actCase.Learner_Profile__r.Id,
                    'slackUserId' => slackId,
                    'notificationMessages' => '['+payload+']',
                    'notificationType' => 'case'
                }
            };
            String messageId = postMessage(message, actCase.Learner_Profile__r.Id);
            if(!String.isEmpty(messageId)) {
                // actCase.Slack_Message_ID__c = messageId;
                // caseToUpdate.add(actCase);
                caseToUpdate.add(new Case(Id = actCase.Id, Slack_Message_ID__c = messageId));
                
            }
            // reset payload for new message
            payload = System.Label.Slack_New_Case_Text;            
        }
        if(!caseToUpdate.isEmpty()) {
            try {
                // Database.update(caseToUpdate, false, AccessLevel.USER_MODE);
                Update caseToUpdate;
            } catch(Exception e) {
                System.debug('The Case field(s) "' + String.join(e.getDmlFieldNames(0), ', ') + '" are not accessible for update of Case');
                System.debug('Error:: While updating slack message id in case record :: ' + e.getStackTraceString());
            }
        }
    }

    public static void sendGuestRoleChangedMsg(Map<String, String> guestMap) {
        String payload = System.Label.Slack_Session_Guest_Role_Changed;
        payload = payload.replace('{0}', '<@'+guestMap.get('slackId')+'>');
        payload = payload.replace('{1}', guestMap.get('oldRole'));
        payload = payload.replace('{2}', guestMap.get('newRole'));
        
        Map<String, Object> message = new Map<String, Object>{
            'notifications' => new Map<String, Object> {
                'learnerProfileId' => guestMap.get('lpId'),
                'slackUserId' => guestMap.get('slackId'),
                'ts' => guestMap.get('ts'),
                'notificationMessages' => '['+payload+']',
                'notificationType' => 'session-guest'
            }
        };
        
        String endPoint = Constants.HEROKU_ENDPOINT + '/sessionGuestThreadMsg';
        Map<String, Object> res = SlackNotificationBatchHelper.postSlackMessage(JSON.serialize(message), endPoint, 'POST');
        if(!(Boolean)res.get('ok')) {
            Slack_Notification_Error__c se = new Slack_Notification_Error__c(
                Learner_Profile__c =  guestMap.get('lpId'),
                Request_Body__c =  (String)res.get('Session_Role_Changes :: '+'request'),
                Response_Body__c =  (String)res.get('response'),
                Time_Sent__c =  DateTime.now()
            );
            errorList.add(se);              
        }
    }

    public static void sendGuestRoleDeletedMsg(Map<String, String> guestMap) {
        // String payload = System.Label.Slack_Session_Guest_Removed;
        String payload;
        if(guestMap.get('messageType') == 'cancelled') {
            payload = System.Label.Slack_Session_Guest_Cancelled;
            payload = payload.replace('{0}', '<@'+guestMap.get('slackId')+'>');
        } else {
            payload = System.Label.Slack_Session_Guest_Removed;
            payload = payload.replace('{0}', '<@'+guestMap.get('slackId')+'>');
            payload = payload.replace('{1}', guestMap.get('role'));
        }
        
        
        Map<String, Object> message = new Map<String, Object>{
            'notifications' => new Map<String, Object> {
                'learnerProfileId' => guestMap.get('lpId'),
                'slackUserId' => guestMap.get('slackId'),
                'ts' => guestMap.get('ts'),
                'notificationMessages' => '['+payload+']',
                'notificationType' => 'session-guest'
            }
        };

        String endPoint = Constants.HEROKU_ENDPOINT + '/sessionGuestThreadMsg';
        Map<String, Object> res = SlackNotificationBatchHelper.postSlackMessage(JSON.serialize(message), endPoint, 'POST');
        
        if(!(Boolean)res.get('ok')) {
            Slack_Notification_Error__c se = new Slack_Notification_Error__c(
                Learner_Profile__c =  guestMap.get('lpId'),
                Request_Body__c =  (String)res.get('Session_Role_Deleted :: '+'request'),
                Response_Body__c =  (String)res.get('response'),
                Time_Sent__c =  DateTime.now()
            );
            errorList.add(se);              
        }
    }

    public String postMessage(Map<String, Object> payload, String lpId) {
        String slackMessageId;
        String endPoint;

        String type = metaInfo.get('type');
        String event = metaInfo.get('action');

        if(type == 'Case') {
            if(event == 'new-case'){
                endPoint = Constants.HEROKU_ENDPOINT + '/newCase';
            } else {
                endPoint = Constants.HEROKU_ENDPOINT + '/caseThreadMsg';
            }
        } else if(type == 'CaseComment') {
            endPoint = Constants.HEROKU_ENDPOINT + '/caseThreadMsg';
        } else {
            endPoint = Constants.HEROKU_ENDPOINT + '/depositeSlackNotifications';
        }

        Map<String, String> headers = new Map<String, String> {
            'Authentication' => 'Bearer '+ Constants.HEROKU_API_KEY,
            'Content-Type' => 'application/json'
        };
        DateTime sentTime = DateTime.now();
        String body = JSON.serialize(payload);
        try {
            HttpResponse res = Utilities.makeCallout(endPoint, 'POST', body, headers);
            Integer statusCode = res.getStatusCode();
            System.debug('res body ------- '+res.getBody());
            if(statusCode != 200 && statusCode != 201) {
                Slack_Notification_Error__c se = new Slack_Notification_Error__c(
                    Learner_Profile__c = lpId,
                    Request_Body__c =  body,
                    Response_Body__c =  res.getBody(),
                    Time_Sent__c =  sentTime
                );
                errorList.add(se);                
            } else {
                Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                Map<String, Object> results = (Map<String, Object>)resBody.get('results');
                if(results != null) {
                    slackMessageId = (String)results.get('ts');
                }
            }
        } catch(Exception e) {
            System.debug('Error:: Heroku api *********** :: ' + e.getMessage());
            System.debug('Error:: Heroku api *********** :: ' + e.getStackTraceString());
        }
        return slackMessageId;
    }

    public void sendCaseThreadMsg(Map<String, String> data) {
        Map<String, Object> payload = new Map<String, Object>{
            'notifications' => new Map<String, Object> {
                'learnerProfileId' => data.get('lpId'),
                'slackUserId' => data.get('slackId'),
                'ts' => data.get('ts'),
                'notificationMessages' => '['+data.get('message')+']',
                'notificationType' => 'case'
            }
        };
        postMessage(payload, data.get('lpId'));
    }   
    
}