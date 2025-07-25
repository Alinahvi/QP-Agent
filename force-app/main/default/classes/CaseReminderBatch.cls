public with sharing class CaseReminderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public static FINAL String CASE_TYPE_LEARNER = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ACT_Learning_Case_Type').getRecordTypeId();
    public static FINAL String CASE_TYPE_OPERATIONS = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ACT_Operations_Case_Type').getRecordTypeId();
    public Map<String, Object> autoClosedCases = new Map<String, Object>();
    private static String orgURL = new SiteLink().siteUrlWithPrefix;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([SELECT Id, Awaiting_User_Response__c, Slack_Message_ID__c, Survey_URL__c,
                                        Learner_Profile__r.SlackId__c, Awaiting_User_Response_Days__c, Status, RecordTypeId
                                        FROM Case
                                        WHERE Awaiting_User_Response_Days__c > 0
                                        AND Learner_Profile__r.SlackId__c != NULL
                                        AND Slack_Message_ID__c != NULL
                                        AND (RecordTypeId =: CASE_TYPE_OPERATIONS OR RecordTypeId =: CASE_TYPE_LEARNER)
                                        WITH USER_MODE]);
    }

    public void execute(Database.BatchableContext BC, List<Case> scope) {
        List<Case> caseToClosed = new List<Case>();
        Map<String, String> metaInfo = new Map<String, String> {
            'type' => 'Case',
            'action' => 'case-reminder'
        };
        
        SlackQueueableNotification caseNotification = new SlackQueueableNotification(metaInfo);
        String msg;
        String autoClose;
        for(Case actCase : scope) {
            if(actCase.Awaiting_User_Response_Days__c == 1) {
                msg = System.Label.Slack_Case_Reminder_1_Text;
            } else if(actCase.Awaiting_User_Response_Days__c == 2) {
                msg = System.Label.Slack_Case_Reminder_2_Text;
            } else if(actCase.Awaiting_User_Response_Days__c == 3) {
                msg = System.Label.Slack_Case_Reminder_3_Text;
                actCase.Status = 'Closed - No Response';
                caseToClosed.add(new Case(Id = actCase.Id, Status = 'Closed - No Response'));
            }
            msg = msg.replace('{0}', 'Hi '+'<@'+actCase.Learner_Profile__r.SlackId__c+'>');
            Map<String, String> data = new Map<String, String> {
                'message' => msg,
                'slackId' => actCase.Learner_Profile__r.slackid__c,
                'ts' => actCase.Slack_Message_ID__c,
                'lpId' => actCase.Learner_Profile__r.Id
            };
            caseNotification.sendCaseThreadMsg(data);
            if(actCase.Status == 'Closed - No Response') {
                autoClose = System.Label.Slack_Auto_Close_Text;
                autoClose = autoClose.replace('{0}', actCase.Survey_URL__c);
                /*if(actCase.RecordTypeId == CASE_TYPE_LEARNER) {
                    autoClose = autoClose.replace('{0}', orgURL+'/support-detail?id='+actCase.Id);
                } else {
                    autoClose = autoClose.replace('{0}', System.URL.getOrgDomainUrl().toExternalForm() + '/'+actCase.Id);
                }*/
                
                Map<String, String> autoCloseData = new Map<String, String> {
                    'message' => autoClose,
                    'slackId' => actCase.Learner_Profile__r.slackid__c,
                    'ts' => actCase.Slack_Message_ID__c,
                    'lpId' => actCase.Learner_Profile__r.Id
                };
                autoClosedCases.put(actCase.Id, (Object)autoCloseData);
            }
        }

        if(!caseToClosed.isEmpty()) {
            try{
                // update as user caseToClosed;
                update as user Security.stripInaccessible(AccessType.UPDATABLE, caseToClosed).getRecords();
            }catch(DMLException e) {
                System.debug('The Case field(s) "' + String.join(e.getDmlFieldNames(0), ', ') + '" are not accessible for update of Case');
                System.debug('Error while auto close ACT Case :: '+e.getStackTraceString());
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        if(!autoClosedCases.isEmpty()) {
            Map<String, String> metaInfo = new Map<String, String> {
                'type' => 'Case',
                'action' => 'case-auto-close'
            };
            System.enqueueJob(new SlackQueueableNotification(metaInfo, autoClosedCases));            
        }
    }  

}