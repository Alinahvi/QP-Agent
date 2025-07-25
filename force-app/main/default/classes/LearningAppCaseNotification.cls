public with sharing class LearningAppCaseNotification {
    public static FINAL String CASE_TYPE_LEARNER = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ACT_Learning_Case_Type').getRecordTypeId();
    public static FINAL String CASE_ADMIN_OPERATIONS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ACT_Operations_Case_Type').getRecordTypeId();
    public static FINAL String CASE_ENABLEMENT_OPERATIONS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enablement_Operations_General').getRecordTypeId();
    public static Boolean contextFlag = false;
    public static String orgURL = new SiteLink().siteUrlWithPrefix;

    public static void sendNewCaseNotification(Map<Id, Case> newCase) {
        Map<Id, Case> caseMap = new Map<Id, Case>();
        for(Case actCase : newCase.values()) {
            if(actCase.recordTypeId == CASE_ADMIN_OPERATIONS || actCase.recordTypeId == CASE_TYPE_LEARNER 
                || actCase.recordTypeId == CASE_ENABLEMENT_OPERATIONS) {
                caseMap.put(actCase.Id, actCase);
            }
        }

        if(!caseMap.isEmpty()) {
            sendNotification(caseMap);            
        }
    }

    public static void sendNotification(Map<Id, Case> caseMap) {
        Map<String, List<Case>> casesBySlackId = new Map<String, List<Case>>();
        List<Id> lpId = new List<Id>();
        List<Id> caseId = new List<Id>();
        for(Case actCase : caseMap.values()) {
            if(actCase.Learner_Profile__c != null && 
                (actCase.recordTypeId == CASE_ADMIN_OPERATIONS || actCase.recordTypeId == CASE_TYPE_LEARNER 
                    || actCase.recordTypeId == CASE_ENABLEMENT_OPERATIONS) ) {
                lpId.add(actCase.Learner_Profile__c);
                caseId.add(actCase.Id);
            }            
        }
        for(Learner_Profile__c lp : [SELECT Id, slackid__c, 
                                        (SELECT Id, CaseNumber, Description, createdDate, Slack_Message_ID__c,
                                        Topic__c, Learner_Profile__r.User__r.FirstName, RecordTypeId
                                        FROM Cases__r 
                                        /* WHERE (RecordTypeId =: caseTypeLearner OR RecordTypeId =: caseTypeOperations)
                                        // AND createdDate = TODAY 
                                        AND Id IN: caseId */
                                        WHERE Id IN: caseId
                                        AND Slack_Message_ID__c = NULL)
                                    FROM Learner_Profile__c 
                                    WHERE ID IN: lpId
                                    AND slackid__c != NULL
                                    AND Status__c = 'Active'
                                    WITH USER_MODE]) {
            // Case newCase = caseMap.get(caseByLpId.get(lp.Id));
            if(!lp.Cases__r.isEmpty()) {
                casesBySlackId.put(lp.slackid__c, lp.Cases__r);
            }
        }
        if(!casesBySlackId.isEmpty()) {
            Map<String, String> metaInfo = new Map<String, String> {
                'type' => 'Case',
                'action' => 'new-case'
            };
            System.enqueueJob(new SlackQueueableNotification(metaInfo, (Map<String, Object>)casesBySlackId));
        }
    } 
    
    public static void caseStatusChanged(Map<Id, Case> newMap, Map<Id, Case> oldMap) {
        for(String key : newMap.keySet()) {
            Case newCase = newMap.get(key);
            Case oldCase = oldMap.get(key);
            if(newCase.recordTypeId == CASE_ADMIN_OPERATIONS || newCase.recordTypeId == CASE_TYPE_LEARNER 
                || newCase.recordTypeId == CASE_ENABLEMENT_OPERATIONS) {
                if(newCase.Status != oldCase.Status && newCase.Status == 'Awaiting user response') {
                    newCase.Awaiting_User_Response__c = System.today();                   
                }
            }
        }         
    }
    
    public static void setCaseTierAndLp(List<Case> newCases) {
        Map<String, List<Case>> casesByOwnerId = new Map<String, List<Case>>();
        // List<Group> queue = [SELECT Id, developerName FROM Group WHERE Type = 'Queue' AND DeveloperNAME IN ('ACT_Tier_1_Support_Queue','ACT_Tier_2_Support_Queue')];
        // Map<String, String> queueIdByDevName = new Map<String, String>();
        // for(Group grp : queue) {
        //     queueIdByDevName.put(grp.developerName, grp.Id);
        // }

        // default to Tier-1 queue
        List<Group> queue = [SELECT Id, developerName FROM Group WHERE Type = 'Queue' AND DeveloperNAME IN ('ACT_Tier_1_Support_Queue')];

        for(Case newCase : newCases) {
            List<Case> caseList = casesByOwnerId.get(newCase.OwnerId);
            if(caseList == null) {
                caseList = new List<Case>{newCase};
                casesByOwnerId.put(newCase.OwnerId, caseList);
            } else {
                caseList.add(newCase);
            }
        }
        for(Learner_profile__c lp : [SELECT Id, name, User__c FROM Learner_Profile__c WHERE User__c IN: casesByOwnerId.keySet()]) {
            for(Case newCase : casesByOwnerId.get(lp.User__c)) {
                // If Case created from support tab don't add case tier, its already handled
                if(newCase.Case_Tier__c != null && newCase.Learner_Profile__c != null) {
                    continue;
                } 
                if(newCase.recordTypeId == CASE_ADMIN_OPERATIONS || newCase.recordTypeId == CASE_TYPE_LEARNER 
                || newCase.recordTypeId == CASE_ENABLEMENT_OPERATIONS) {
                    // if(newCase.Topic__c == 'Skills Assessment'  || newCase.Topic__c == 'Access and Permissions' || newCase.Topic__c == 'Report a Bug') {
                    //     newCase.Case_Tier__c = 'Tier 2';
                    //     newCase.OwnerId = queueIdByDevName.get('ACT_Tier_2_Support_Queue');
                    // } else {
                    //     newCase.Case_Tier__c = 'Tier 1';
                    //     newCase.OwnerId = queueIdByDevName.get('ACT_Tier_1_Support_Queue');
                    // }
                    newCase.OwnerId = queue[0].Id;
                    newCase.Case_Tier__c = 'Tier 1';
                    newCase.Learner_Profile__c = lp.Id;
                }
            }
        }        
    }
    
    @InvocableMethod( label='Agent Comments on Case' description='Send slack message when agent put comments on the case.')
    public static void caseCommentNotification(List<CaseComment> comments) {
        Map<Id, CaseComment> caseCommentByCaseId = new Map<Id, CaseComment>();
        Map<String, Object> dataMap = new Map<String, Object>();
        String msg = System.Label.Slack_CaseComment_Text;

        for(CaseComment comment : comments) {
            if(!caseCommentByCaseId.containsKey(comment.ParentId)) {
                caseCommentByCaseId.put(comment.ParentId, comment);
            }
        }               
        for(Case actCase : [SELECT Id, Slack_Message_ID__c, Learner_Profile__r.SlackId__c, RecordTypeId
                            FROM Case 
                            WHERE ID IN: caseCommentByCaseId.keySet()
                            AND Learner_Profile__r.SlackId__c != NULL
                            AND Slack_Message_ID__c != NULL
                            WITH USER_MODE]) {
            msg = msg.replace('{0}', 'Hi '+'<@'+actCase.Learner_Profile__r.SlackId__c+'>');
            msg = msg.replace('{1}', caseCommentByCaseId.get(actCase.Id).CommentBody.escapeJava());
            Map<String, String> data = new Map<String, String> {
                'message' => msg,
                'slackId' => actCase.Learner_Profile__r.slackid__c,
                'ts' => actCase.Slack_Message_ID__c,
                'lpId' => actCase.Learner_Profile__r.Id
            };
            dataMap.put(actCase.Id, (Object)data);
        }
        if(!dataMap.isEmpty())  {
            Map<String, String> metaInfo = new Map<String, String> {
                'type' => 'CaseComment',
                'action' => 'agent-comment'
            };
            System.enqueueJob(new SlackQueueableNotification(metaInfo, dataMap));            
        }
    }

    public static void caseClosedByAgent(Map<Id, Case> newMap, Map<Id, Case> oldMap) {
        List<Id> closedCaseId = new List<Id>();
        Map<String, Object> dataMap = new Map<String, Object>();
        for(String key : newMap.keySet()) {
            Case newCase = newMap.get(key);
            Case oldCase = oldMap.get(key);
            if(newCase.recordTypeId == CASE_ADMIN_OPERATIONS || newCase.recordTypeId == CASE_TYPE_LEARNER 
                || newCase.recordTypeId == CASE_ENABLEMENT_OPERATIONS) {
                if(newCase.Status != oldCase.Status && newCase.Status == 'Closed' 
                && newCase.OwnerId == newCase.LastModifiedById) {
                    closedCaseId.add(newCase.Id);                   
                }
            }
        }
        if(!closedCaseId.isEmpty()) {
            String autoClose;
            for(Case actCase : [SELECT Id, Slack_Message_ID__c, Learner_Profile__r.SlackId__c, RecordTypeId, Survey_URL__c
                                FROM Case 
                                WHERE ID IN: closedCaseId
                                AND Learner_Profile__r.SlackId__c != NULL
                                AND Slack_Message_ID__c != NULL
                                WITH USER_MODE]) {
                if(String.isEmpty(actCase.Survey_URL__c)){
                    continue;
                }
                autoClose = System.Label.Slack_Auto_Close_Text;
                autoClose = autoClose.replace('{0}', actCase.Survey_URL__c);
                                
                Map<String, String> data = new Map<String, String> {
                    'message' => autoClose,
                    'slackId' => actCase.Learner_Profile__r.slackid__c,
                    'ts' => actCase.Slack_Message_ID__c,
                    'lpId' => actCase.Learner_Profile__r.Id
                };
                dataMap.put(actCase.Id, (Object)data);
            }
        }
        if(!dataMap.isEmpty())  {
            Map<String, String> metaInfo = new Map<String, String> {
                'type' => 'Case',
                'action' => 'case-close'
            };
            System.enqueueJob(new SlackQueueableNotification(metaInfo, dataMap));            
        }
    }
}