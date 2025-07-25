public with sharing class SessionOwnerRoleNotification {
    
    @InvocableMethod( label='Send Session Owner Role Notification' description='Send Session Owner Role Notification' callout='true')
    public static void sendOwnerRoleNotification(List<Session_Guest__c> newList) {
        Map<Id, Session_Guest__c> sessionGuests = new Map<Id, Session_Guest__c>();
        sessionGuests.putAll((List<Session_Guest__c>)newList);

        sendSessionGuestNotification(sessionGuests);
        
        // List<Slack_Notification_Error__c> errorList = new List<Slack_Notification_Error__c>();
        // List<Session_Guest__c> guestToUpdate = new List<Session_Guest__c>();
        
        // for(Session_Guest__c aSession : [SELECT Id, Role__c, Learner_Profile__r.Name, Slack_Message_ID__c, Learner_Profile__r.SlackId__c, 
        //                                     Learner_Profile__r.User__r.FirstName, Session__r.Start_Date__c, Learner_Profile__r.Manager__c,
        //                                     Session__r.Start_Time__c, Session__r.End_Time__c, Session__r.End_Date__c,
        //                                     Session__r.Name, Session__r.Start_Time_Converted__c, Session__r.End_Time_Converted__c,
        //                                     Session__r.Owner.Name, Session__r.Asset__r.Name, Session__r.Description__c, Session__r.Asset__r.Content_Owner_Organization__c,
        //                                     Session__r.Asset__r.Time_Estimate__c, From_Scheduler__c
        //                                     FROM Session_Guest__c 
        //                                     WHERE Id IN: sessionGuests.keySet()
        //                                     /* AND Learner_Profile__r.SlackId__c != NULL */
        //                                     AND Learner_Profile__r.Status__c = 'Active'
        //                                     WITH USER_MODE]) {
            
        //     if(aSession.Learner_Profile__r.SlackId__c == NULL) {
        //         Slack_Notification_Error__c se = new Slack_Notification_Error__c(
        //             Learner_Profile__c = aSession.Learner_Profile__c,
        //             Request_Body__c =  'Session_Guest_Role',
        //             Response_Body__c = 'Error :: Learner Slack_Id is NULL',
        //             Time_Sent__c =  DateTime.now()
        //         );
        //         errorList.add(se);
        //         continue;
        //     }
        //     Map<String, Object> msg = createDataMap(aSession, aSession.From_Scheduler__c);

        //     String endPoint = Constants.HEROKU_ENDPOINT + '/newSessionGuest';
        //     Map<String, Object> res = SlackNotificationBatchHelper.postSlackMessage(JSON.serialize(msg), endPoint, 'POST');
        //     if((Boolean)res.get('ok')) {
        //         Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(''+res.get('response'));
        //         Map<String, Object> results = (Map<String, Object>)resBody.get('results');
        //         if(results != null) {
        //             String slackMessageId = (String)results.get('ts');
        //             if(String.isNotEmpty(slackMessageId)) {
        //                 Session_Guest__c sg = new Session_Guest__c();
        //                 sg.Id = aSession.Id;
        //                 sg.Slack_Message_ID__c = slackMessageId;
        //                 if(aSession.From_Scheduler__c) {
        //                     sg.Session_Role_Status__c = 'Pending';
        //                 }
        //                 guestToUpdate.add(sg);
        //             }                                        
        //         } else {
        //             Slack_Notification_Error__c se = new Slack_Notification_Error__c(
        //                 Learner_Profile__c = aSession.Learner_Profile__c,
        //                 Request_Body__c =  JSON.serialize(msg),
        //                 Response_Body__c =  JSON.serialize(resBody),
        //                 Time_Sent__c =  DateTime.now()
        //             );
        //             errorList.add(se);
        //         }
        //     }            
        // }

        // if(!guestToUpdate.isEmpty()) {
        //     try {
        //         update as user guestToUpdate;
        //     } catch(Exception e) {
        //         System.debug('Error:: Adding slack error log *********** :: ' + e.getMessage());
        //         System.debug('Error:: Adding slack error log *********** :: ' + e.getStackTraceString());
        //     }
        // }
        
        // if(!errorList.isEmpty()) {
        //     try {
        //         insert as user errorList;
        //     } catch(Exception e) {
        //         System.debug('Error:: Adding slack error log *********** :: ' + e.getMessage());
        //         System.debug('Error:: Adding slack error log *********** :: ' + e.getStackTraceString());
        //     }
        // }
    } 

    @ReadOnly @RemoteAction
    public static void sendSessionGuestNotification(Map<Id, Session_Guest__c> sessionGuests) {
        List<Slack_Notification_Error__c> errorList = new List<Slack_Notification_Error__c>();
        List<Session_Guest__c> guestToUpdate = new List<Session_Guest__c>();
        
        for(Session_Guest__c aSession : [SELECT Id, Role__c, Learner_Profile__r.Name, Slack_Message_ID__c, Learner_Profile__r.SlackId__c, 
                                            Learner_Profile__r.User__r.FirstName, Session__r.Start_Date__c, Learner_Profile__r.Manager__c,
                                            Session__r.Start_Time__c, Session__r.End_Time__c, Session__r.End_Date__c,
                                            Session__r.Name, Session__r.Start_Time_Converted__c, Session__r.End_Time_Converted__c,
                                            Session__r.Owner.Name, Session__r.Asset__r.Name, Session__r.Description__c, Session__r.Asset__r.Content_Owner_Organization__c,
                                            Session__r.Asset__r.Time_Estimate__c, From_Scheduler__c
                                            FROM Session_Guest__c 
                                            WHERE Id IN: sessionGuests.keySet()
                                            /* AND Learner_Profile__r.SlackId__c != NULL */
                                            AND Learner_Profile__r.Status__c = 'Active'
                                            WITH USER_MODE]) {
            
            if(aSession.Learner_Profile__r.SlackId__c == NULL) {
                Slack_Notification_Error__c se = new Slack_Notification_Error__c(
                    Learner_Profile__c = aSession.Learner_Profile__c,
                    Request_Body__c =  'Session_Guest_Role',
                    Response_Body__c = 'Error :: Learner Slack_Id is NULL',
                    Time_Sent__c =  DateTime.now()
                );
                errorList.add(se);
                continue;
            }
            Map<String, Object> msg = createDataMap(aSession, aSession.From_Scheduler__c);

            String endPoint = Constants.HEROKU_ENDPOINT + '/newSessionGuest';
            Map<String, Object> res = SlackNotificationBatchHelper.postSlackMessage(JSON.serialize(msg), endPoint, 'POST');
            if((Boolean)res.get('ok')) {
                Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(''+res.get('response'));
                Map<String, Object> results = (Map<String, Object>)resBody.get('results');
                if(results != null) {
                    String slackMessageId = (String)results.get('ts');
                    if(String.isNotEmpty(slackMessageId)) {
                        Session_Guest__c sg = new Session_Guest__c();
                        sg.Id = aSession.Id;
                        sg.Slack_Message_ID__c = slackMessageId;
                        if(aSession.From_Scheduler__c) {
                            sg.Session_Role_Status__c = 'Pending';
                        }
                        guestToUpdate.add(sg);
                    }                                        
                } else {
                    Slack_Notification_Error__c se = new Slack_Notification_Error__c(
                        Learner_Profile__c = aSession.Learner_Profile__c,
                        Request_Body__c =  JSON.serialize(msg),
                        Response_Body__c =  JSON.serialize(resBody),
                        Time_Sent__c =  DateTime.now()
                    );
                    errorList.add(se);
                }
            }            
        }

        if(!guestToUpdate.isEmpty()) {
            try {
                update as user guestToUpdate;
            } catch(Exception e) {
                System.debug('Error:: Adding slack error log *********** :: ' + e.getMessage());
                System.debug('Error:: Adding slack error log *********** :: ' + e.getStackTraceString());
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

    public Static Map<String, Object> createDataMap(Session_Guest__c aSession, Boolean isTrainerApprovalNotification) {
        String orgURL = new SiteLink().siteUrlWithPrefix;
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
            // 'messageType' => 'sessionRole',
            'managerName' => String.isNotBlank(aSession.Learner_Profile__r.Manager__c) ? aSession.Learner_Profile__r.Manager__c : aSession.Session__r.Owner.Name,
            'role' => aSession.Role__c,
            'owner' => aSession.Session__r.Owner.Name,
            'type' => 'Asset',
            'parentName' => aSession.Session__r.Asset__r.Name.escapeJava(),
            'sessionCount' => 'NA',
            'description' => String.isNotBlank(aSession.Session__r.Description__c) ? aSession.Session__r.Description__c.escapeJava() : 'NA',
            'requiredBy' => aSession.Session__r.Asset__r.Content_Owner_Organization__c,
            'subType' => 'Event',
            'timeEstimate' => aSession.Session__r.Asset__r.Time_Estimate__c,
            // 'url' => orgURL+'/event-detail?id='+aSession.Session__r.Asset__r.Id,
            'contentUrl' => orgURL+'/session-detail?id='+aSession.Session__r.Id,
            'startDate' => aSession.Session__r.Start_Time_Converted__c.formatGMT('MMM dd, yyyy'),
            'startTime' => '<!date^'+startTimeUTC+'^{time}|'+aSession.Session__r.Start_Time_Converted__c.format('h:mm a')+'>',
            'endTime' => '<!date^'+endTimeUTC+'^{time}|'+aSession.Session__r.End_Time_Converted__c.format('h:mm a')+'>'
        };

        if(isTrainerApprovalNotification) {
            String sfUrl = System.URL.getOrgDomainUrl().toExternalForm();
            message.put('messageType', 'notifyTrainer');
            message.put('url', sfUrl+'/lightning/n/Training_Hub');
        } else {
            message.put('url', orgURL+'/event-detail?id='+aSession.Session__r.Asset__r.Id);
            message.put('messageType', 'sessionRole');
        }

        List<Object> tempList = new List<Object>{(Object)message};
        Map<String, List<Object>> learningByType = new Map<String, List<Object>>{
            'asset' => tempList
        };
        blockMap.put('event', (Object)learningByType);
        blocks.add((Object)blockMap);
        payload.put('block', (Object)blocks);

        Map<String, Object> msg = new Map<String, Object>{
            'notifications' => new Map<String, Object> {
                'learnerProfileId' => aSession.Learner_Profile__r.Id,
                'slackUserId' => aSession.Learner_Profile__r.SlackId__c,
                'notificationMessages' => JSON.serialize(payload), 
                'notificationType' => 'event-session'
            }
        };
        return msg;
    }

    
    /* 
    public static Map<String, Object> sendNewSessionGuestDetails() {

    }
    
    public class SessionGuestList {
        @InvocableVariable(label='new SessionGuest Records' description='new SessionGuest Records')
        public List<SObject> newSessionGuest;
        
        @InvocableVariable(label='old SessionGuest Records' description='old SessionGuest Records')
        public List<SObject> oldSessionGuest;
    }
    */
}