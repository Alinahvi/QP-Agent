public with sharing class SkillAssessmentAssessorNotifiction {
    
    @InvocableMethod( label='Skill Assessment Assessor Notification' description='Skill Assessment Assessor Notification' callout='true')
    public static void sendAssessorNotification(List<Assignment__c> skillAssessmentList) {
        Map<Id, Assignment__c> newMap = new Map<Id, Assignment__c>();
        newMap.putAll(skillAssessmentList); 
        String orgURL = new SiteLink().siteUrlWithPrefix;
        List<Integration_Error__c> errorList = new List<Integration_Error__c>();

        for(Assignment__c assignment : [SELECT Id, Asset__r.Name, Assessor__r.SlackId__c, Assessor__r.Name, Assessor__r.User__r.FirstName,
                                        Learner_Profile__r.User__r.FirstName, Learner_Profile__r.User__r.Id, Learner_Profile__r.Name
                                        FROM Assignment__c 
                                        WHERE Id IN :newMap.keySet()
                                        AND Inactive__c = false
                                        WITH USER_MODE]) {
            Map<String, Object> payload = new Map<String, Object>();
            List<Object> blocks = new List<Object>();
            Map<String, Object> blockMap = new Map<String, Object>{
                'userName' => (Object)assignment.Learner_Profile__r.Name, 
                'firstName' => (Object)assignment.Assessor__r.User__r.FirstName,
                'userId' => (Object)assignment.Assessor__r.User__r.Id,
                'lpId' => (Object)assignment.Assessor__r.Id,
                'slackId' => (Object)assignment.Assessor__r.slackid__c
            };
            Map<String, String> message = new Map<String, String>{
                'name' => assignment.Asset__r.Name.escapeJava(),
                'type' => 'Asset',
                'url' => orgURL+'/skills-detail?id='+assignment.Id,
                'managerName' => assignment.Learner_Profile__r.Name
            };
            List<Object> tempList = new List<Object>{(Object)message};
            Map<String, List<Object>> learningByType = new Map<String, List<Object>>{
                'asset' => tempList
            };
            blockMap.put('event', (Object)learningByType);
            blocks.add((Object)blockMap);
            payload.put('block', (Object)blocks);
            Map<String, Object> msg = new Map<String, Object>{
                'notifications' => new Map<String, Object> {
                    'learnerProfileId' => assignment.Assessor__r.Id,
                    'slackUserId' => assignment.Assessor__r.SlackId__c,
                    'notificationMessages' => JSON.serialize(payload), 
                    'notificationType' => 'skill-assessment-assessor-notification'
                }
            };
            String endPoint = Constants.HEROKU_ENDPOINT + '/depositeSlackNotifications';
            Map<String, Object> res = SlackNotificationBatchHelper.postSlackMessage(JSON.serialize(msg), endPoint, 'POST');
            if(!(Boolean)res.get('ok')) {
                errorList.add(new Integration_Error__c(
                    Error_Message__c = (String)res.get('response'),
                    Type__c = 'SKILL-ASSESSMENT-ASSESSOR-NOTIFICATION',
                    Http_Response_Body__c = (String)res.get('response')
                ));
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
}