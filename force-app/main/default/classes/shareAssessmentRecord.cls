public with sharing class shareAssessmentRecord {
    
    // @InvocableMethod( label='shareAssessmentRecordAccess' description='Share Assessment Response record with Learner and Manager')
    // public static void shareAssessmentRecordAccess(List<Assessment_Invitation__c> data) { 
    // public static void shareAssessmentRecordAccess(List<Assessment_Response__c> data) {
    //     // Map<Id, Assessment_Invitation__c> invitationMap = new Map<Id, Assessment_Invitation__c>(data);
    //     List<Assessment_Response__Share> shareWithList = new List<Assessment_Response__Share>();
    //     List<Assessment_Question_Response__Share> shareQuestionResponseList = new List<Assessment_Question_Response__Share>();
    //     /* for(Assessment_Response__c assessment : [SELECT Id, Assessment__c, Assessment__r.OwnerId, Assessment_Invitation__c, 
    //                                             Assessment_Invitation__r.Assessor__c, Assessment_Invitation__r.Assessee__c,
    //                                             Assessment_Invitation__r.Type__c,
    //                                             (SELECT Id  
    //                                             FROM Assessment_Question_Responses__r)
    //                                             FROM Assessment_Response__c
    //                                             WHERE Status__c = 'Submitted' 
    //                                             AND Assessment_Invitation__c IN: invitationMap.keySet()]) { */ 
    //     for(Assessment_Response__c assessment : data) {                                             
            
    //         if(assessment.Assessment_Invitation__r.Type__c == 'Employee') {
    //             // shareWithList.add((Assessment_Response__Share)getAssessmentShareRecord(assessment.Id, assessment.Assessment_Invitation__r.Assessor__c, 'Edit'));
    //             Assessment_Response__Share resObj = (Assessment_Response__Share)getAssessmentShareRecord(assessment.Id, assessment.Assessment_Invitation__r.Manager_Invitation__r.Assessor__c, 'Edit');
    //             if(resObj != null) {
    //                 shareWithList.add(resObj);
    //             }
    //             if(!assessment.Assessment_Question_Responses__r.isEmpty()) {
    //                 for(Assessment_Question_Response__c question : assessment.Assessment_Question_Responses__r) {
    //                     // shareQuestionResponseList.add((Assessment_Question_Response__Share)getAssessmentShareRecord(question.Id, assessment.Assessment_Invitation__r.Assessor__c, 'Edit'));
    //                     Assessment_Question_Response__Share quesResObj = (Assessment_Question_Response__Share)getAssessmentShareRecord(question.Id, assessment.Assessment_Invitation__r.Manager_Invitation__r.Assessor__c, 'Edit');
    //                     if(quesResObj != null) {
    //                         shareQuestionResponseList.add(quesResObj);
    //                     }                        
    //                 }                    
    //             }
    //         } else if(assessment.Assessment_Invitation__r.Type__c == 'Manager') {
    //             // shareWithList.add(()withAssessee);
    //             Assessment_Response__Share resObj = (Assessment_Response__Share)getAssessmentShareRecord(assessment.Id, assessment.Assessment_Invitation__r.Assessee__c, 'Read');
    //             if(resObj != null) {
    //                 shareWithList.add(resObj);
    //             }                
    //             if(!assessment.Assessment_Question_Responses__r.isEmpty()) {
    //                 for(Assessment_Question_Response__c question : assessment.Assessment_Question_Responses__r) {
    //                     Assessment_Question_Response__Share quesResObj = (Assessment_Question_Response__Share)getAssessmentShareRecord(question.Id, assessment.Assessment_Invitation__r.Assessee__c, 'Read');
    //                     if(quesResObj != null) {
    //                         shareQuestionResponseList.add(quesResObj);
    //                     }                        
    //                 }                    
    //             }
    //         }  else {
    //             System.debug(':: shareAssessmentRecord :: not an identified Type');
    //         }          
    //     }

    //     if(!shareWithList.isEmpty()) {
    //         try {
    //             System.debug('----- 777777 ------- ' + shareWithList);
    //             insert shareWithList;
    //         } catch(Exception e){
    //             System.debug('*********** shareAssessmentRecord ERROR: ' + e.getMessage() + ' at ' + e.getLineNumber());
    //             System.debug('----------- e.getStackTraceString(): ' + e.getStackTraceString());
    //             ExceptionUtility.logError('ASSESSMENT', 'shareAssessmentRecord', 'Assessment_Response__Share', e.getMessage() + ' at ' + e.getLineNumber());
    //             return;
    //         }
    //     }

    //     if(!shareQuestionResponseList.isEmpty()) {
    //         try {
    //             System.debug('----- 888888 ------- '+shareQuestionResponseList);
    //             insert shareQuestionResponseList;
    //         } catch(Exception e){
    //             System.debug('*********** shareAssessmentQuestionRecord ERROR: ' + e.getMessage() + ' at ' + e.getLineNumber());
    //             System.debug('---------- e.getStackTraceString(): ' + e.getStackTraceString());
    //             ExceptionUtility.logError('ASSESSMENT', 'shareAssessmentRecord', 'Assessment_Question_Response__c', e.getMessage() + ' at ' + e.getLineNumber());
    //             return;
    //         }
    //     }
    // }

    // private static Object getAssessmentShareRecord(Id parentId, Id shareWithId, String access) {
    //     if(shareWithId == null || parentId == null)
    //         return null;
    //     String objectType = parentId.getSObjectType().getDescribe().getName();
    //     if(objectType == 'Assessment_Response__c') {
    //         return new Assessment_Response__Share(
    //             ParentId = parentId,
    //             UserOrGroupId = shareWithId,
    //             AccessLevel = access,
    //             RowCause = 'Manual' 
    //         );
    //     } else {
    //         return new Assessment_Question_Response__Share(
    //             ParentId = parentId,
    //             UserOrGroupId = shareWithId,
    //             AccessLevel = access,
    //             RowCause = 'Manual'
    //         );
    //     }        
    // }
}