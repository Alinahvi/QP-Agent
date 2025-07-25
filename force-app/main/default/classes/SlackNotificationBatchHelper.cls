public with sharing class SlackNotificationBatchHelper {
    
    private static Map<String, Map<String, List<Object>>> assignedNotiByLpAndType = new Map<String, Map<String, List<Object>>>();
    private static Map<String, Map<String, List<Object>>> reminderNotiByLpAndType = new Map<String, Map<String, List<Object>>>();
    private static Map<String, Map<String, List<Object>>> overdueNotiByLpAndType = new Map<String, Map<String, List<Object>>>();
    private static Map<String, Object> lpDetailsByLpId = new Map<String, Object>();
    private static Map<String, List<String>> currByLp = new Map<String, List<String>>();
    private static Boolean isSecurityLearning = false;
    private static String orgURL = new SiteLink().siteUrlWithPrefix;
    // private static Map<Id, String> queryParamByAssetTypeId = new Map<Id, String>();
    private static Map<Id, Map<String, String>> queryParamByAssetTypeId = new Map<Id, Map<String, String>>();

    public static void sendSlackPayload(List<Learner_Profile__c> scope, Boolean securityLearning) {
        isSecurityLearning = securityLearning;
        // queryParamByAssetTypeId.put(Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId(), '/event-detail?id=');
        // queryParamByAssetTypeId.put(Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Media').getRecordTypeId(), '/media-detail?id=');
        Schema.DescribeSObjectResult objResult = Asset__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> objRecordType = objResult.getRecordTypeInfos();
        for(Schema.RecordTypeInfo type : objRecordType) {
            Map<String, String> recordTypeMap;
            switch on (type.getDeveloperName()) {
                when 'Event' {
                    recordTypeMap = new Map<String, String>{
                        'name' => type.getName(),
                        'path' => '/event-detail?id='
                    };                   
                }
                when 'Media' {
                    recordTypeMap = new Map<String, String>{
                        'name' => type.getName(),
                        'path' => '/media-detail?id='
                    };                   
                }
                when 'Trailhead_Module' {
                    recordTypeMap = new Map<String, String>{
                        'name' => type.getName(),
                        'path' => '/trailhead-module-detail?id='
                    };               
                }
                when 'In_App_Assessment' {
                    recordTypeMap = new Map<String, String>{
                        'name' => type.getName(),
                        'path' => '/in-app-assessment-detail?id='
                    };
                }
                when else {
                    recordTypeMap = new Map<String, String>{
                        'name' => type.getName(),
                        'path' => orgURL
                    };
                }
            }
            queryParamByAssetTypeId.put(type.getRecordTypeId(), recordTypeMap);           
        }
      
        // for(Learner_Profile__c lp : scope) {
        //     learningByNotificationType(lp);
        // }
        String eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        String cbRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Content_Block').getRecordTypeId();
        for(Learner_Profile__c lp : [SELECT Id, Name, slackid__c, User__r.FirstName, User__r.ManagerId, User__r.Manager.Name, User__r.Manager.FirstName,
                                    (SELECT Id, Asset__r.Name, Due_Date__c, Assigned_Learning__r.Start_Date__c, Assigned_Learning__c,
                                    Asset__r.Description__c, Asset__r.RecordTypeId, Send_Assigned_Notification__c, Send_Overdue_Notification__c,
                                    Send_Reminder_Notification__c, Asset__r.Security_Type__c, Asset__r.Content_Owner_Organization__c,
                                    Asset__r.Time_Estimate__c, Asset__r.Use_Compliance_Notification__c, Asset__r.Assessment_Type__c, 
                                    Content_Distribution_Organization__c
                                    FROM Assignments__r
                                    WHERE Self_Assigned__c = FALSE
                                    AND Asset__r.RecordTypeId != :cbRecordTypeId
                                    AND (Send_Assigned_Notification__c = TRUE 
                                    OR Send_Reminder_Notification__c = TRUE
                                    OR Send_Overdue_Notification__c = TRUE)),
                                    (SELECT Id, Course__r.Name, Assigned_Curriculum__c, Assigned_Curriculum__r.Curriculum__r.Name, Due_Date__c,
                                    Course__r.Description__c, Assigned_Curriculum__r.Curriculum__r.Description__c, Assigned_Learning__r.Start_Date__c,
                                    Send_Assigned_Notification__c, Send_Reminder_Notification__c, Send_Overdue_Notification__c, 
                                    Send_Escalation_Notification__c, Assigned_Curriculum__r.Curriculum__r.Security_Type__c, Course__r.Security_Type__c,
                                    Course__r.Content_Owner_Organization__c, Assigned_Curriculum__r.Curriculum__r.Content_Owner_Organization__c,
                                    Course__r.Time_Estimate__c, Assigned_Curriculum__r.Curriculum__r.Time_Estimate__c, Is_Compliance_Learning__c,
                                    Content_Distribution_Organization__c, Assigned_Curriculum__r.Content_Distribution_Organization__c
                                    FROM Assigned_Courses__r
                                    WHERE Self_Assigned__c = FALSE
                                    AND(Send_Assigned_Notification__c = TRUE
                                    OR Send_Reminder_Notification__c = TRUE
                                    OR Send_Overdue_Notification__c = TRUE)) 
                                    FROM Learner_Profile__c 
                                    WHERE Id IN: scope
                                    WITH USER_MODE]) {
            learningByNotificationType(lp);
        }

        if(!assignedNotiByLpAndType.isEmpty() || !reminderNotiByLpAndType.isEmpty() || !overdueNotiByLpAndType.isEmpty()) {
            // Updated: we are not sending the entire batch of users and there consolidated msg,
            // rather we are now sending per user consolidated msg using the below method
            // sendSlackMsg();
            
            String payload = createSlackPayload();
            if(!String.isEmpty(payload)) {
                sendPayload(payload);
            }
        }        
    }   

    public static void learningByNotificationType(Learner_Profile__c lp) {
       
        if(lp != null && !lp.Assignments__r.isEmpty()) {
            if(!lpDetailsByLpId.containsKey(lp.Id)) {
                Map<String, String> userDetail = new Map<String, String>{
                    'userName' => lp.Name,
                    'firstName' => lp.User__r.FirstName,
                    'userId' => lp.User__r.Id,
                    'lpId' => lp.Id,
                    'slackId' => lp.slackid__c
                };
                lpDetailsByLpId.put(lp.Id, (Object)userDetail);                
            }
            for(Assignment__c assignment : lp.Assignments__r) {
                addLearningByType((Object)assignment, 'assignment', lp.Id);
            }
        }

        if(lp != null && !lp.Assigned_Courses__r.isEmpty()) {
            if(!lpDetailsByLpId.containsKey(lp.Id)) {
                Map<String, String> userDetail = new Map<String, String>{
                    'userName' => lp.Name,
                    'firstName' => lp.User__r.FirstName,
                    'userId' => lp.User__r.Id,
                    'lpId' => lp.Id,
                    'slackId' => lp.slackid__c
                };
                lpDetailsByLpId.put(lp.Id, (Object)userDetail);                
            }
            for(Assigned_Course__c assignment : lp.Assigned_Courses__r) {
                addLearningByType((Object)assignment, 'assigned_learning', lp.Id);
            }
        }        
    }

    public static void addLearningByType(Object obj, String objType, String lpId) {
        String type = '';
        Map<String, String> learning = new Map<String, String>();
        Boolean sendAssignedNotification = false;
        Boolean sendReminderNotification = false;
        Boolean sendOverdueNotification = false;
        
        if(objType == 'assignment') {
            Assignment__c data = (Assignment__c)obj;
            Boolean isCompliance = (String.isNotEmpty(data.Asset__r.Security_Type__c) && data.Asset__r.Use_Compliance_Notification__c) ? true : false;
            sendAssignedNotification = data.Send_Assigned_Notification__c;
            sendReminderNotification = data.Send_Reminder_Notification__c;
            sendOverdueNotification = data.Send_Overdue_Notification__c;
            type = 'asset';
            DateTime dt = DateTime.newInstance(data.Due_Date__c, Time.newInstance(1,1,1,1));
            String dueDate = dt.format('MMM d, YYYY');
            // Learning Id if Solo Asset will be Assignment_Id
            learning.put('learningId', data.Id); 
            // learning.put('name', data.Asset__r.Name);
            learning.put('name', data.Asset__r.Name.escapeJava()); // escape special char on name
            String assetType;
            String contentUrl;
            if(queryParamByAssetTypeId.containsKey(data.Asset__r.RecordTypeId)) {
                Map<String, String> tempMap = queryParamByAssetTypeId.get(data.Asset__r.RecordTypeId);
                assetType = tempMap.get('name');
                if(assetType == 'Assessment' || assetType == 'Quiz') {
                    contentUrl = orgURL +'/quiz-assessment-detail?id='+data.Asset__r.Id; //+tempMap.get('path')+data.Asset__r.Id;
                } /* else if(assetType == 'In_App_Assessment'){
                    contentUrl = orgURL +'/peer-assessment-detail?id='+data.Asset__r.Id; //+tempMap.get('path')+data.Asset__r.Id;
                }*/ else {
                    contentUrl = orgURL+tempMap.get('path')+data.Asset__r.Id;
                }
            } else {
                assetType = 'Asset';
                contentUrl = orgURL;
            }
            learning.put('subType', assetType);
            learning.put('url', contentUrl);        
            learning.put('dueDate', dueDate);
            learning.put('description', String.isNotBlank(data.Asset__r.Description__c) ? data.Asset__r.Description__c.escapeJava() : 'NA');
            learning.put('contentBlockUUID', lpId+'--'+data.Id);
            learning.put('isCompliance', String.valueOf(isCompliance));
            learning.put('complianceType', isCompliance ? data.Asset__r.Security_Type__c : 'NA');
            learning.put('timeEstimate', data.Asset__r.Time_Estimate__c);
            learning.put('type', 'Asset');
            // learning.put('requiredBy', data.Asset__r.Content_Owner_Organization__c);
            learning.put('requiredBy', String.isNotBlank(data.Content_Distribution_Organization__c) ? data.Content_Distribution_Organization__c : 'NA');
            learning.put('learningType', 'Asset');
        } else if(objType == 'assigned_learning') {
            Assigned_Course__c data = (Assigned_Course__c)obj;
            sendAssignedNotification = data.Send_Assigned_Notification__c;
            sendReminderNotification = data.Send_Reminder_Notification__c;
            sendOverdueNotification = data.Send_Overdue_Notification__c;
            if(data.Assigned_Curriculum__c != null) { 
                // multiple courses can be part of a curriculum avoid duplicate curriculum entry
                if(currByLp.containsKey(lpId)) {
                    if(currByLp.get(lpId).contains(data.Assigned_Curriculum__r.Curriculum__r.Id)) {
                        return;
                    } else {
                        currByLp.get(lpId).add(data.Assigned_Curriculum__r.Curriculum__r.Id);
                    }
                } else {
                    currByLp.put(lpId, new List<String>{data.Assigned_Curriculum__r.Curriculum__r.Id});
                }
                type = 'curriculum';
                learning.put('learningId', data.Assigned_Curriculum__r.Id);
                learning.put('name', data.Assigned_Curriculum__r.Curriculum__r.Name.escapeJava());
                learning.put('url', orgURL+'/curriculum-detail?id='+data.Assigned_Curriculum__r.Id);
                learning.put('description', String.isNotBlank(data.Assigned_Curriculum__r.Curriculum__r.Description__c) ? data.Assigned_Curriculum__r.Curriculum__r.Description__c.escapeJava() : 'NA');
                learning.put('contentBlockUUID', lpId+'--'+data.Assigned_Curriculum__r.Id);
                learning.put('type', 'Curriculum');
                learning.put('isCompliance', String.valueOf(data.Is_Compliance_Learning__c));
                learning.put('complianceType', data.Is_Compliance_Learning__c ? data.Assigned_Curriculum__r.Curriculum__r.Security_Type__c : 'NA');
                learning.put('timeEstimate', data.Assigned_Curriculum__r.Curriculum__r.Time_Estimate__c);
                // learning.put('requiredBy', data.Assigned_Curriculum__r.Curriculum__r.Content_Owner_Organization__c);
                learning.put('requiredBy', String.isNotBlank(data.Assigned_Curriculum__r.Content_Distribution_Organization__c) ? 
                data.Assigned_Curriculum__r.Content_Distribution_Organization__c : 'NA');
                learning.put('learningType', 'Curricula');
            } else {
                type = 'course';
                learning.put('learningId', data.Id);
                learning.put('name', data.Course__r.Name.escapeJava());
                learning.put('url', orgURL+'/course-detail?id='+data.Id); 
                learning.put('description', String.isNotBlank(data.Course__r.Description__c) ? data.Course__r.Description__c.escapeJava() : 'NA');
                learning.put('contentBlockUUID', lpId+'--'+data.Id);
                learning.put('type', 'Course');
                learning.put('isCompliance', String.valueOf(data.Is_Compliance_Learning__c));
                learning.put('complianceType', data.Is_Compliance_Learning__c ? data.Course__r.Security_Type__c : 'NA');
                learning.put('timeEstimate', data.Course__r.Time_Estimate__c);
                // learning.put('requiredBy', data.Course__r.Content_Owner_Organization__c);
                learning.put('requiredBy', String.isNotBlank(data.Content_Distribution_Organization__c) ? data.Content_Distribution_Organization__c : 'NA');
                learning.put('learningType', 'Course');
            }
            DateTime dt = DateTime.newInstance(data.Due_Date__c, Time.newInstance(1,1,1,1));
            String dueDate = dt.format('MMM d, YYYY');
            learning.put('dueDate', dueDate);            
        } 

        if(sendAssignedNotification) {
            learning.put('message', System.Label.Slack_Assigned_Msg);
            learning.put('messageType', 'assigned');
            if(assignedNotiByLpAndType.containsKey(lpId)) {
                Map<String, List<Object>> notiDataByType = assignedNotiByLpAndType.get(lpId);
                if(notiDataByType.containsKey(type)) {
                    notiDataByType.get(type).add((Object)learning);   
                } else {
                    notiDataByType.put(type, new List<Object>{(Object)learning});                        
                }
            } else {
                Map<String, List<Object>> tempMap = new Map<String, List<Object>> {
                    type => new List<Object>{learning}
                };
                assignedNotiByLpAndType.put(lpId, tempMap);                    
            }
        } else if(sendReminderNotification) {
            learning.put('message', System.Label.Slack_Reminder_Msg);
            learning.put('messageType', 'reminder');
            if(reminderNotiByLpAndType.containsKey(lpId)) {
                Map<String, List<Object>> notiDataByType = reminderNotiByLpAndType.get(lpId);
                if(notiDataByType.containsKey(type)) {
                    notiDataByType.get(type).add((Object)learning);   
                } else {
                    notiDataByType.put(type, new List<Object>{(Object)learning});                        
                }
            } else {
                Map<String, List<Object>> tempMap = new Map<String, List<Object>> {
                    type => new List<Object>{learning}
                };
                reminderNotiByLpAndType.put(lpId, tempMap);                    
            }
        } else if(sendOverdueNotification) {
            learning.put('message', System.Label.Slack_Overdue_Msg);
            learning.put('messageType', 'overdue');
            if(overdueNotiByLpAndType.containsKey(lpId)) {
                Map<String, List<Object>> notiDataByType = overdueNotiByLpAndType.get(lpId);
                if(notiDataByType.containsKey(type)) {
                    notiDataByType.get(type).add((Object)learning);   
                } else {
                    notiDataByType.put(type, new List<Object>{(Object)learning});                        
                }
            } else {
                Map<String, List<Object>> tempMap = new Map<String, List<Object>> {
                    type => new List<Object>{learning}
                };
                overdueNotiByLpAndType.put(lpId, tempMap);                    
            }
        }
    }

    // public static void sendSlackMsg() {
    //     if(lpDetailsByLpId.isEmpty()){
    //         return;
    //     }
        
    //     List<Slack_Notification_Error__c> errorList = new List<Slack_Notification_Error__c>();
    //     String endPoint = Constants.HEROKU_ENDPOINT + '/depositeSlackNotifications';
    //     for(String lpId : lpDetailsByLpId.keySet()) {
    //         List<Object> blocks = new List<Object>();
    //         Map<String, Object> payload = new Map<String, Object>();
    //         payLoad.put('isSecurityBlock', (Object)isSecurityLearning);

    //         Map<String, String> tempMap = (Map<String, String>)lpDetailsByLpId.get(lpId);
    //         Map<String, Object> blockMap = new Map<String, Object>{
    //             'userName' => (Object)tempMap.get('userName'),
    //             'firstName' => (Object)tempMap.get('firstName'),
    //             'userId' => (Object)tempMap.get('userId'),
    //             'lpId' => (Object)tempMap.get('lpId'),
    //             'slackId' => (Object)tempMap.get('slackId')
    //         };
    //         Map<String, List<Object>> learningByType = assignedNotiByLpAndType.get(lpId);
    //         if(learningByType != null) {
    //             blockMap.put('assigned', (Object)learningByType);
    //         }
    //         learningByType = reminderNotiByLpAndType.get(lpId);
    //         if(learningByType != null) {
    //             blockMap.put('reminder', (Object)learningByType);
    //         }
    //         learningByType = overdueNotiByLpAndType.get(lpId);
    //         if(learningByType != null) {
    //             blockMap.put('overdue', (Object)learningByType);
    //         }
    //         blocks.add((Object)blockMap);
    //         payload.put('block', (Object)blocks);
    //         Map<String, Object> message = new Map<String, Object>{
    //             'notifications' => new Map<String, Object> {
    //                 'learnerProfileId' => 'lpKey',      // placeholder for consolidated message only
    //                 'slackUserId' => 'slackId',         // placeholder for consolidated message only
    //                 'notificationMessages' => JSON.serialize(payload), // payload
    //                 'notificationType' => 'learning'
    //             }
    //         };
    //         Map<String, Object> result = postSlackMessage(JSON.serialize(message), endPoint, 'POST');
    //         if(!result.isEmpty() && !(Boolean)result.get('ok')) {
    //             Slack_Notification_Error__c se = new Slack_Notification_Error__c(
    //                 Learner_Profile__c = lpId,
    //                 Request_Body__c =  ''+result.get('request'),
    //                 Response_Body__c = ''+ result.get('response'),
    //                 Time_Sent__c =  DateTime.now()
    //             );
    //             errorList.add(se); 
    //         }            
            
    //     }
    //     if(!errorList.isEmpty()) {
    //         try {
    //             insert as user errorList;
    //         }catch(Exception e) {
    //             System.debug('Error:: Adding slack error log *********** :: ' + e.getMessage());
    //             System.debug('Error:: Adding slack error log *********** :: ' + e.getStackTraceString());
    //         }
    //     }
    // }

    public static String createSlackPayload() {
        if(lpDetailsByLpId.isEmpty()){
            return '';
        }
        Map<String, Object> payload = new Map<String, Object>();
        payLoad.put('isSecurityBlock', (Object)isSecurityLearning);
                
        List<Object> blocks = new List<Object>();        
        for(String lpId : lpDetailsByLpId.keySet()) {
            Map<String, String> tempMap = (Map<String, String>)lpDetailsByLpId.get(lpId);
            Map<String, Object> blockMap = new Map<String, Object>{
                'userName' => (Object)tempMap.get('userName'),
                'firstName' => (Object)tempMap.get('firstName'),
                'userId' => (Object)tempMap.get('userId'),
                'lpId' => (Object)tempMap.get('lpId'),
                'slackId' => (Object)tempMap.get('slackId')
            };
            Map<String, List<Object>> learningByType = assignedNotiByLpAndType.get(lpId);
            if(learningByType != null) {
                blockMap.put('assigned', (Object)learningByType);
            }
            learningByType = reminderNotiByLpAndType.get(lpId);
            if(learningByType != null) {
                blockMap.put('reminder', (Object)learningByType);
            }
            learningByType = overdueNotiByLpAndType.get(lpId);
            if(learningByType != null) {
                blockMap.put('overdue', (Object)learningByType);
            }
            blocks.add((Object)blockMap);
        }
        payload.put('block', (Object)blocks);
        return JSON.serialize(payLoad);
    }

    public static Boolean sendPayload(String payload) {
        String endPoint = Constants.HEROKU_ENDPOINT + '/depositeSlackNotifications'; 
        Map<String, String> headers = new Map<String, String> {
            'Authentication' => 'Bearer ' + Constants.HEROKU_API_KEY,
            'Content-Type' => 'application/json'
        };
        List<Slack_Notification_Error__c> errorList = new List<Slack_Notification_Error__c>();
        Map<String, Object> message = new Map<String, Object>{
            'notifications' => new Map<String, Object> {
                'learnerProfileId' => 'lpKey',
                'slackUserId' => 'slackId',
                'notificationMessages' => payload,
                'notificationType' => 'learning'
            }
        };
                
        try{
            String body = JSON.serialize(message);
            HttpResponse res = Utilities.makeCallout(endPoint, 'POST', body, headers);
            Integer statusCode = res.getStatusCode();
            System.debug('Status Code ------- '+res.getStatusCode());
            System.debug('res body ------- '+res.getBody());
            if(statusCode != 200 && statusCode != 201) {
                System.debug('ERROR: ----' +res.getBody());
            }
        }catch(Exception e) {
            System.debug('Error:: Heroku api *********** :: ' + e.getMessage());
            System.debug('Error:: Heroku api *********** :: ' + e.getStackTraceString());
        }  
        
        return true;
    }    

    public static String createCourseEventPayload(Assignment__c assignment) {
        Map<String, Object> payload = new Map<String, Object>();
        List<Object> blocks = new List<Object>();
        Map<String, Object> blockMap = new Map<String, Object>{
            'userName' => (Object)assignment.Learner_Profile__r.Name, // (Object)tempMap.get('userName'),
            'firstName' => (Object)assignment.Learner_Profile__r.User__r.FirstName,
            'userId' => (Object)assignment.Learner_Profile__r.User__r.Id,
            'lpId' => (Object)assignment.Learner_Profile__r.Id,
            'slackId' => (Object)assignment.Learner_Profile__r.slackid__c
        };
        
        DateTime dt = DateTime.newInstance(assignment.Due_Date__c, Time.newInstance(1,1,1,1));
        String dueDate = dt.format('MMM d, YYYY');

        Map<String, String> message = new Map<String, String>{
            'name' => assignment.Asset__r.Name.escapeJava(),
            'messageType' => 'courseEvent',
            'type' => 'Asset',
            'sessionCount' => ''+assignment.Mandatory_Session_Count__c,
            'description' => String.isNotBlank(assignment.Asset__r.Description__c) ? assignment.Asset__r.Description__c.escapeJava() : 'NA',
            // 'requiredBy' => assignment.Asset__r.Content_Owner_Organization__c,
            'requiredBy' => String.isNotBlank(assignment.Assigned_Course__r.Content_Distribution_Organization__c) ? assignment.Assigned_Course__r.Content_Distribution_Organization__c : 'NA', // String.isNotBlank(assignment.Content_Distribution_Organization__c) ? assignment.Content_Distribution_Organization__c : 'NA',
            'dueDate' => dueDate,
            'subType' => 'Event',
            'timeEstimate' => assignment.Asset__r.Time_Estimate__c,
            'url' => orgURL+'/event-detail?id='+assignment.Asset__r.Id,
            'contentUrl' => orgURL+'/course-detail?id='+assignment.Course__r.Id
        };

        // if(assignment.Assigned_Course__r != null && String.isNotBlank(assignment.Assigned_Course__r.Content_Distribution_Organization__c)) {
        //     message.put('requiredBy', assignment.Assigned_Course__r.Content_Distribution_Organization__c);
        // } else {
        //     message.put('requiredBy', String.isNotBlank(assignment.Content_Distribution_Organization__c) ? assignment.Content_Distribution_Organization__c : 'NA');
        // }

        List<Object> tempList = new List<Object>{(Object)message};
        Map<String, List<Object>> learningByType = new Map<String, List<Object>>{
            'asset' => tempList
        };
        blockMap.put('event', (Object)learningByType);
        blocks.add((Object)blockMap);
        payload.put('block', (Object)blocks);
        return (JSON.serialize(payload));
    }

    // public static String createSoloAssetPayload(Assignment__c assignment) {
    //     String soloAssetStr = '[{"type":"section","text":{"type":"mrkdwn","text":"Hi *{0}* :wave:"}},{"type":"section","text":{"type":"mrkdwn","text":"You have been assigned the following Event from *Astro\'s Course Tracker*."}},{"type":"context","elements":[{"type":"mrkdwn","text":"*Event Name:* {1}\n*Description:* {2}\n"}]},{"type":"section","text":{"type":"mrkdwn","text":"Head over to Astro\'s Course Tracker to view all available sessions and register to any required sessions as soon as possible. "},"accessory":{"type":"button","text":{"type":"plain_text","text":"Register ","emoji":true},"value":"click_me_123","action_id":"button-action","url":"{3}"}},{"type":"section","text":{"type":"mrkdwn","text":"Have questions? Contact <#C01SFA61CP4>"}}]';
        
    //     soloAssetStr = soloAssetStr.replace('{0}', assignment.Learner_Profile__r.Name);
    //     soloAssetStr = soloAssetStr.replace('{1}', assignment.Asset__r.Name);
    //     soloAssetStr = soloAssetStr.replace('{2}', String.isNotBlank(assignment.Asset__r.Description__c) ? assignment.Asset__r.Description__c.escapeJava() : 'NA');
    //     soloAssetStr = soloAssetStr.replace('{3}', orgURL + '/event-detail?id='+assignment.Id);// + '/' + assignment.Asset__r.Id);
        
    //     return soloAssetStr;        
    // }   

    public static Map<String, Object> postSlackMessage(String body, String endPoint, String httpType) {
        Map<String, Object> result = new Map<String, Object>();
        
        Map<String, String> headers = new Map<String, String> {
            'Authentication' => 'Bearer '+ Constants.HEROKU_API_KEY,
            'Content-Type' => 'application/json'
        };

        try {
            HttpResponse res = Utilities.makeCallout(endPoint, httpType, body, headers);
            Integer statusCode = res.getStatusCode();
            if(statusCode != 200 && statusCode != 201) {
                result.put('ok', (Object)FALSE);
            } else {
                result.put('ok', (Object)TRUE);                
            }
            result.put('request', (Object)body);
            result.put('response', (Object)res.getBody());
        }catch(Exception e) {
            result.put('ok', (Object)FALSE);
            result.put('response', (Object)(e.getMessage()+ '--' + e.getStackTraceString()));
            result.put('request', (Object)body);
                        
            System.debug('Error:: Heroku api *********** :: ' + e.getMessage());
            System.debug('Error:: Heroku api *********** :: ' + e.getStackTraceString());
        }
        return result;
    } 

}