public with sharing class SurveyNotification {
    
    @InvocableMethod( label='Send Survey Notification' description='Send notification to users who are not completed the survey post learning completion' callout='true')
    public static void sendSurveyNotification(List<Assigned_Course__c> newList) {
        Map<String, Assigned_Course__c> aCourse = new Map<String, Assigned_Course__c>();
        aCourse.putAll(newList);
        List<String> userIds = new List<String>();
        List<String> invitationIds = new List<String>();
        Map<String, Assigned_Course__c> aCrByUsrIdCrID = new Map<String, Assigned_Course__c>();
        Map<String, Assigned_Course__c> dataMap = new Map<String, Assigned_Course__c>();
        try {
            for(Assigned_Course__c data : [SELECT Id, Learner_Profile__r.User__c, Learner_Profile__r.SlackId__c, Learner_Profile__r.Name, 
                                        Learner_Profile__r.User__r.FirstName, Course__r.Send_Survey_Notification__c, Course__r.Name,
                                        Course__r.Survey_Invitation__c, Course__r.Survey_URL__c
                                        FROM Assigned_Course__c
                                        WHERE Course__r.Send_Survey_Notification__c = TRUE
                                        AND Inactive__c = false
                                        AND Id IN: aCourse.keySet()
                                        AND Learner_Profile__r.SlackId__c != NULL
                                        WITH USER_MODE]) {
                String key = data.Learner_Profile__r.User__c + '||' + data.Course__r.Id; 
                aCrByUsrIdCrID.put(key, data);
                userIds.add(data.Learner_Profile__r.User__c);
                invitationIds.add(data.Course__r.Survey_Invitation__c);            
            }
            for(SurveyResponse sr : [SELECT Id, SubmitterId, Invitation.ACT2_Course__c
                                    FROM SurveyResponse 
                                    WHERE SubmitterId IN: userIds
                                    AND InvitationId IN: invitationIds  
                                    AND Status = 'Completed'
                                    WITH USER_MODE]){
                String key = sr.SubmitterId + '||' + sr.Invitation.ACT2_Course__c;
                aCrByUsrIdCrID.remove(key);
            }
            if(!aCrByUsrIdCrID.isEmpty()) {
                for(Assigned_Course__c aCr : aCrByUsrIdCrID.values()) {
                    dataMap.put(aCr.Id, aCr);
                }
            }
            if(!dataMap.isEmpty()) {
                Map<String, String> metaInfo = new Map<String, String> {
                    'type' => 'AssignedCourse',
                    'action' => 'course-survey'
                };
                System.enqueueJob(new SlackQueueableNotification(metaInfo, (Map<String, Object>)dataMap));
            }
        }catch(Exception e) {
            insert (new Integration_Error__c(
                Error_Message__c = 'Error while sending Survey_Notification',
                Http_Response_Body__c = 'ERROR :: '+e.getMessage() + ' -- '+e.getStackTraceString() ,
                Type__c = 'SURVEY'
            ));
        }        
    }

}