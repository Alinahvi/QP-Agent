global with sharing class SessionSlackNotification {
    
    @InvocableMethod( label='Send Session Registration Notification' description='Send Session Registration Notification' callout='true')
    global static void sendRegisteredNotification(List<Assigned_Session__c> newList) {
        Map<Id, Assigned_Session__c> sessionMap = new Map<Id, Assigned_Session__c>();
        sessionMap.putAll((List<Assigned_Session__c>)newList);
        sendSlackRegistrationNotification(sessionMap);        
    }

     
    
    @ReadOnly @RemoteAction
    global static void sendSlackRegistrationNotification(Map<Id, Assigned_Session__c> sessionMap) {
        List<Slack_Notification_Error__c> errorList = new List<Slack_Notification_Error__c>();
        SiteLink sl = new SiteLink();
        String orgURL = sl.siteUrlWithPrefix;
        for(Assigned_Session__c aSession : [SELECT Id, Status__c, Learner_Profile__r.Name, Learner_Profile__r.SlackId__c, 
                                            Learner_Profile__r.User__r.FirstName, Session__r.Start_Date__c, 
                                            Session__r.Start_Time__c, Session__r.End_Time__c, Session__r.End_Date__c,
                                            Session__r.Name, Session__r.Start_Time_Converted__c, Session__r.End_Time_Converted__c,
                                            Asset__r.Name, Assignment__c, Session__r.Description__c, Asset__r.Content_Owner_Organization__c,
                                            Asset__r.Time_Estimate__c
                                            FROM Assigned_Session__c 
                                            WHERE Id IN: sessionMap.keySet()
                                            AND Learner_Profile__r.SlackId__c != NULL
                                            WITH USER_MODE]) {

            String payload = createSessionPayload(aSession, 'sessionRegistration', orgURL);           
            Map<String, Object> msg = new Map<String, Object>{
                'notifications' => new Map<String, Object> {
                    'learnerProfileId' => aSession.Learner_Profile__r.Id,
                    'slackUserId' => aSession.Learner_Profile__r.slackid__c,
                    'notificationMessages' => payload,
                    'notificationType' => 'event-session'
                }
            };

            List<Slack_Notification_Error__c> se = postLearningMessage(msg);
            if(!se.isEmpty()) {
                errorList.addAll(se);
            }
        }
        
        if(!errorList.isEmpty()) {
            try {
                insert as user errorList;
            } catch(Exception e) {
                System.debug('Error:: Adding slack error log *********** :: ' + e.getMessage());
                System.debug('Error:: Adding slack error log *********** :: ' + e.getStackTraceString());
            }
        }
    }

    public static String createSessionPayload(Assigned_Session__c aSession, String msgType, String orgURL) {
        Map<String, Object> payload = new Map<String, Object>();
        List<Object> blocks = new List<Object>();
        Map<String, Object> blockMap = new Map<String, Object>{
            'userName' => (Object)aSession.Learner_Profile__r.Name, 
            'firstName' => (Object)aSession.Learner_Profile__r.User__r.FirstName,
            'userId' => (Object)aSession.Learner_Profile__r.User__r.Id,
            'lpId' => (Object)aSession.Learner_Profile__r.Id,
            'slackId' => (Object)aSession.Learner_Profile__r.slackid__c
        };
        // convert time to utc
        String startTimeUTC = ''+(aSession.Session__r.Start_Time_Converted__c.getTime()/1000);
        String endTimeUTC = ''+(aSession.Session__r.End_Time_Converted__c.getTime()/1000);

        Map<String, String> message = new Map<String, String>{
            'name' => aSession.Session__r.Name.escapeJava(),
            'messageType' => msgType,
            'type' => 'Asset',
            'parentName' => aSession.Asset__r.Name.escapeJava(),
            'sessionCount' => 'NA',
            'description' => String.isNotBlank(aSession.Session__r.Description__c) ? aSession.Session__r.Description__c.escapeJava() : 'NA',
            'requiredBy' => aSession.Asset__r.Content_Owner_Organization__c,
            'subType' => 'Event',
            'timeEstimate' => aSession.Asset__r.Time_Estimate__c,
            'url' => orgURL+'/event-detail?id='+aSession.Asset__r.Id,
            'contentUrl' => orgURL+'/session-detail?id='+aSession.Session__r.Id,
            'startDate' => aSession.Session__r.Start_Time_Converted__c.formatGMT('MMM dd, yyyy'),
            'startTime' => '<!date^'+startTimeUTC+'^{time}|'+aSession.Session__r.Start_Time_Converted__c.format('h:mm a')+'>',
            'endTime' => '<!date^'+endTimeUTC+'^{time}|'+aSession.Session__r.End_Time_Converted__c.format('h:mm a')+'>'
        };

        List<Object> tempList = new List<Object>{(Object)message};
        Map<String, List<Object>> learningByType = new Map<String, List<Object>>{
            'asset' => tempList
        };
        blockMap.put('event', (Object)learningByType);
        blocks.add((Object)blockMap);
        payload.put('block', (Object)blocks);

        return JSON.serialize(payload);
    }

    public static List<Slack_Notification_Error__c> postLearningMessage(Map<String, Object> payload) {
        List<Slack_Notification_Error__c> errorList = new List<Slack_Notification_Error__c>();
        Map<String, Object> temp = (Map<String, Object>)payload.get('notifications');
        String lpId = (String)temp.get('learnerProfileId');
        String endPoint = Constants.HEROKU_ENDPOINT + '/depositeSlackNotifications';
        
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
            } 
        } catch(Exception e) {
            System.debug('Error:: Heroku api *********** :: ' + e.getMessage());
            System.debug('Error:: Heroku api *********** :: ' + e.getStackTraceString());
        }
        return errorList;        
    }

}