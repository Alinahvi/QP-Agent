public with sharing class LearningAppCaseStatusNotification {
    
    @InvocableMethod( label='Case Status Changed' description='Send slack message when case status is changed.')
    public static void statusChangedNotification(List<caseStatusWrapper> caseData) {
        Map<String, Object> dataMap = new Map<String, Object>();
        Map<Id, Case> newCases = new Map<Id, Case>();
        Map<Id, Case> oldCases = new Map<Id, Case>();
        for(caseStatusWrapper cw : caseData) {
            newCases.putAll((List<Case>)cw.newCaseList);
            oldCases.putAll((List<Case>)cw.oldCaseList);
        }
        for(Case actCase : [SELECT Id, Status, Learner_Profile__r.slackid__c, Slack_Message_ID__c, 
                            RecordTypeId
                            FROM Case 
                            WHERE Id IN: newCases.keySet()
                            AND Slack_Message_ID__c != NULL
                            AND Learner_Profile__r.slackid__c != NULL
                            WITH USER_MODE]) {
            Case oldCase = oldCases.get(actCase.Id);
            String msg = '{"type":"section","text":{"type":"mrkdwn","text":"Case status changed from *{0}* to *{1}*."}}';
            msg = msg.replace('{0}', oldCase.Status);
            msg = msg.replace('{1}', actCase.Status);
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
                'type' => 'Case',
                'action' => 'case-status'
            };
            System.enqueueJob(new SlackQueueableNotification(metaInfo, dataMap));            
        }
    }

    public class caseStatusWrapper {
        @InvocableVariable(label='new Case Records' description='new Case Records')
        public List<SObject> newCaseList;
        
        @InvocableVariable(label='old Case Records' description='old Case Records')
        public List<SObject> oldCaseList;
    }
}