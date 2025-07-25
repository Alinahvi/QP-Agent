public with sharing class SlackEscalationNotificationBatchHelper {
    private static List<Learner_Profile__c> lpListWithLeanrnings = new List<Learner_Profile__c>();
    private static Map<String, Learner_Profile__c> mangerMap = new Map<String, Learner_Profile__c>();
    private static Map<String, Map<String, List<Object>>> escalationNotiByLpAndType = new Map<String, Map<String, List<Object>>>();
    private static Map<String, Object> lpDetailsByLpId = new Map<String, Object>();
    private static Map<String, List<String>> currByLp = new Map<String, List<String>>();
    private static Boolean isSecurityLearning = false;
    private static String orgURL = new SiteLink().siteUrlWithPrefix;

    public static void resetDataMap() {
        mangerMap.clear();
        lpListWithLeanrnings.clear();
        escalationNotiByLpAndType.clear();
        lpDetailsByLpId.clear();
    }

    // manager user id by lp id
    public static void sendEscalationNotification(Map<String, String> lpByUserId, List<Learner_Profile__c> scope) {
        if(!scope.isEmpty()) {
            mangerMap.putAll(scope);
            pendingLearningList(lpByUserId);
        }
    }

    public static void pendingLearningList(Map<String, String> lpByUserId) {
        String eventRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Event').getRecordTypeId();
        String cbRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Content_Block').getRecordTypeId();
        
        for(Learner_Profile__c lp : [SELECT Id, Name, slackid__c, User__r.FirstName, User__r.ManagerId, User__r.Manager.Name, 
                                    User__r.Manager.FirstName,
                                    (SELECT Id, Asset__r.Name, Due_Date__c, Assigned_Learning__r.Start_Date__c, Assigned_Learning__c,
                                    Asset__r.Description__c, Asset__r.RecordTypeId, Send_Escalation_Notification__c, Asset__r.Security_Type__c,
                                    Asset__r.Use_Compliance_Notification__c, Asset__r.Time_Estimate__c, Asset__r.Content_Owner_Organization__c,
                                    Content_Distribution_Organization__c
                                    FROM Assignments__r
                                    WHERE Self_Assigned__c = FALSE
                                    AND Asset__r.RecordTypeId != :eventRecordTypeId
                                    AND Asset__r.RecordTypeId != :cbRecordTypeId
                                    AND Send_Escalation_Notification__c = TRUE
                                    AND Inactive__c = false
                                    LIMIT 50),
                                    (SELECT Id, Course__r.Name, Assigned_Curriculum__c, Assigned_Curriculum__r.Curriculum__r.Name, Due_Date__c,
                                    Course__r.Description__c, Assigned_Curriculum__r.Curriculum__r.Description__c, Assigned_Learning__r.Start_Date__c,
                                    Send_Escalation_Notification__c, Assigned_Curriculum__r.Curriculum__r.Security_Type__c, Course__r.Security_Type__c,
                                    Is_Compliance_Learning__c, Course__r.Content_Owner_Organization__c, Course__r.Time_Estimate__c,
                                    Assigned_Curriculum__r.Curriculum__r.Content_Owner_Organization__c, Assigned_Curriculum__r.Curriculum__r.Time_Estimate__c,
                                    Content_Distribution_Organization__c, Assigned_Curriculum__r.Content_Distribution_Organization__c
                                    FROM Assigned_Courses__r
                                    WHERE Self_Assigned__c = FALSE
                                    AND Send_Escalation_Notification__c = TRUE
                                    AND Inactive__c = false
                                    LIMIT 50)
                                    FROM Learner_Profile__c
                                    WHERE Status__c = 'Active'
                                    AND User__r.ManagerId IN: lpByUserId.keySet()
                                    AND slackid__c != NULL
                                    WITH USER_MODE
                                    LIMIT 100]) {
            
            if(!lp.Assignments__r.isEmpty() || !lp.Assigned_Courses__r.isEmpty()) {
                lpListWithLeanrnings.add(lp);
            }
        }

        if(!lpListWithLeanrnings.isEmpty()) {
            escalationPayload(lpListWithLeanrnings, lpByUserId);
            if(!escalationNotiByLpAndType.isEmpty()) {
                String payload = createSlackPayload();
                if(!String.isEmpty(payload)) {
                    slackNotificationBatchHelper.sendPayload(payload);
                }
            }            
        }        
    }

    public static void escalationPayload(List<Learner_Profile__c> scope, Map<String, String> lpByUserId) {
        for(Learner_Profile__c lp : scope) {
            escalationByType(lp, lpByUserId);
        }
    }

    public static void escalationByType(Learner_Profile__c lp, Map<String, String> lpByUserId) {
        if(lp != null && !lp.Assignments__r.isEmpty()) {
            for(Assignment__c assignment : lp.Assignments__r) {
                if(!lpDetailsByLpId.containsKey(lp.Id)) {
                    Map<String, Object> userDetail = new Map<String, Object>{
                        'userName' => (Object)lp.Name,
                        'firstName' => (Object)lp.User__r.FirstName,
                        'userId' => (Object)lp.User__r.Id,
                        'lpId' => (Object)lp.Id,
                        'slackId' => (Object)lp.slackid__c,
                        'isEscalation' => (Object)Boolean.valueOf('true'),
                        'managerFirstName' => (Object)lp.User__r.Manager.FirstName,
                        'managerName' => (Object)lp.User__r.Manager.Name,
                        'managerLp' => (Object) lpByUserId.get(lp.User__r.ManagerId),
                        'managerSlackId' => mangerMap.get(lpByUserId.get(lp.User__r.ManagerId)).slackid__c
                    };
                    lpDetailsByLpId.put(lp.Id, (Object)userDetail);                
                }
                addLearningByType((Object)assignment, 'assignment', lp.Id, lpByUserId);
            }
        }

        if(lp != null && !lp.Assigned_Courses__r.isEmpty()) {
            for(Assigned_Course__c assignment : lp.Assigned_Courses__r) {
                if(!lpDetailsByLpId.containsKey(lp.Id)) {
                    Map<String, Object> userDetail = new Map<String, Object>{
                        'userName' => (Object)lp.Name,
                        'firstName' => (Object)lp.User__r.FirstName,
                        'userId' => (Object)lp.User__r.Id,
                        'lpId' => (Object)lp.Id,
                        'slackId' => (Object)lp.slackid__c,
                        'isEscalation' => (Object)Boolean.valueOf('true'),
                        'managerFirstName' => (Object)lp.User__r.Manager.FirstName,
                        'managerName' => (Object)lp.User__r.Manager.Name,
                        'managerLp' => (Object) lpByUserId.get(lp.User__r.ManagerId),
                        'managerSlackId' => mangerMap.get(lpByUserId.get(lp.User__r.ManagerId)).slackid__c
                    };
                    lpDetailsByLpId.put(lp.Id, (Object)userDetail);                
                }
                addLearningByType((Object)assignment, 'assigned_learning', lp.Id, lpByUserId);
            }
        }
    }

    public static void addLearningByType(Object obj, String objType, String lpId, Map<String, String> lpByUserId) {
        String type = '';
        Map<String, String> learning = new Map<String, String>();
        Boolean sendEscalationNotification = false;
        if(objType == 'assignment') {
            Assignment__c data = (Assignment__c)obj;
            Boolean isCompliance = (String.isNotEmpty(data.Asset__r.Security_Type__c) && data.Asset__r.Use_Compliance_Notification__c) ? true : false;
            sendEscalationNotification = data.Send_Escalation_Notification__c;
            type = 'asset';
            DateTime dt = DateTime.newInstance(data.Due_Date__c, Time.newInstance(1,1,1,1));
            String dueDate = dt.format('MMM d, YYYY');
            // Learning Id for Solo Asset will be Assignment_Id
            learning.put('learningId', data.Id);
            learning.put('name', data.Asset__r.Name.escapeJava());
            learning.put('url', orgURL);
            learning.put('dueDate', dueDate);
            learning.put('description', String.isNotBlank(data.Asset__r.Description__c) ? data.Asset__r.Description__c.escapeJava() : 'NA');
            learning.put('contentBlockUUID', lpId+'--'+data.Id);
            learning.put('type', 'Asset');
            learning.put('timeEstimate', data.Asset__r.Time_Estimate__c);
            // learning.put('requiredBy', data.Asset__r.Content_Owner_Organization__c);
            learning.put('requiredBy', String.isNotBlank(data.Content_Distribution_Organization__c) ? data.Content_Distribution_Organization__c : 'NA');
            learning.put('isCompliance', String.valueOf(isCompliance));
            learning.put('complianceType', isCompliance ? data.Asset__r.Security_Type__c : 'NA');
            learning.put('learningType', 'Asset');
        } else if(objType == 'assigned_learning') {
            Assigned_Course__c data = (Assigned_Course__c)obj;
            sendEscalationNotification = data.Send_Escalation_Notification__c;           
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
                learning.put('url', orgURL);
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
                learning.put('url', orgURL);
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
        
        if(sendEscalationNotification) {
            learning.put('message', System.Label.Slack_Escalation_Msg);
            learning.put('messageType', 'escalation');
            if(escalationNotiByLpAndType.containsKey(lpId)) {
                Map<String, List<Object>> notiDataByType = escalationNotiByLpAndType.get(lpId);
                if(notiDataByType.containsKey(type)) {
                    notiDataByType.get(type).add((Object)learning);   
                } else {
                    notiDataByType.put(type, new List<Object>{(Object)learning});                        
                }
            } else {
                Map<String, List<Object>> tempMap = new Map<String, List<Object>> {
                    type => new List<Object>{learning}
                };
                escalationNotiByLpAndType.put(lpId, tempMap);                    
            }
        }
    }

    public static String createSlackPayload() {
        if(lpDetailsByLpId.isEmpty()){
            return '';
        }
        Map<String, Object> payload = new Map<String, Object>();
        List<Object> blocks = new List<Object>();        
        for(String lpId : lpDetailsByLpId.keySet()) {
            Map<String, Object> blockMap = (Map<String, Object>)lpDetailsByLpId.get(lpId);
            Map<String, List<Object>> learningByType = escalationNotiByLpAndType.get(lpId);
            if(learningByType != null) {
                blockMap.put('escalated', (Object)learningByType);
            }           
            blocks.add((Object)blockMap);
        }
        payload.put('block', (Object)blocks);
        return JSON.serialize(payLoad);
    }
    
}