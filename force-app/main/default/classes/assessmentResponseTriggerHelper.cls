public with sharing class assessmentResponseTriggerHelper {
    
    @InvocableMethod(label='shareAssessmentRecordOnSubmit' description='Share Assessment Response record with Learner and Manager, when both have submitted there response')
    public static void shareAssessmentOnSubmit(List<Assessment_Response__c> data) {
        // Map<Id, Assessment_Response__c> respByInvitation = new Map<Id, Assessment_Response__c>(data);
        // if(!respByInvitation.isEmpty()) {
        //     System.debug('----- 111111 ------- ');
        //     Map<Id, Id> empResIdByManInv = new Map<Id, Id>();
        //     Map<Id, Id> manResIdByInv = new Map<Id, Id>();
            
        //     Map<Id, Assessment_Response__c> responseMap = new Map<Id, Assessment_Response__c>();
        //     Map<Id, Assessment_Response__c> managerResponse = new Map<Id, Assessment_Response__c>();
        //     Map<Id, Assessment_Response__c> employeeResponse = new Map<Id, Assessment_Response__c>();
            
        //     List<Assessment_Response__c> shareResponse = new List<Assessment_Response__c>();
 
        //     for(Assessment_Response__c response : [SELECT Id, Status__c, Assessment_Invitation__c, Assessment_Invitation__r.Manager_Invitation__c, 
        //                                             Assessment_Invitation__r.Type__c, Assessment_Invitation__r.Assessor__c, 
        //                                             Assessment_Invitation__r.Assessee__c,
        //                                             (SELECT Id FROM Assessment_Question_Responses__r)                                                        
        //                                             FROM Assessment_Response__c
        //                                             WHERE Status__c = 'Submitted' 
        //                                             AND Id IN: respByInvitation.keySet()]) {

        //         if(response.Assessment_Invitation__r.Type__c == 'Employee' && response.Assessment_Invitation__r.Manager_Invitation__c != null) {
        //             empResIdByManInv.put(response.Assessment_Invitation__r.Manager_Invitation__c, response.Id);
        //             System.debug('----- 2222222 ------- ');                    
        //         } else {
        //             manResIdByInv.put(response.Assessment_Invitation__c, response.Id);
        //             System.debug('----- 333333 ------- ');   
        //         }
        //         responseMap.put(response.Id, response);                
        //     }

        //     if(!manResIdByInv.isEmpty()) {
        //         for(Assessment_Response__c response : [SELECT Id, Status__c, Assessment_Invitation__c, Assessment_Invitation__r.Type__c, 
        //                                                 Assessment_Invitation__r.Assessor__c, Assessment_Invitation__r.Assessee__c,
        //                                                 Assessment_Invitation__r.Manager_Invitation__c, Assessment_Invitation__r.Manager_Invitation__r.Assessor__c,
        //                                                 (SELECT Id FROM Assessment_Question_Responses__r)                                                        
        //                                                 FROM Assessment_Response__c
        //                                                 WHERE Assessment_Invitation__r.Manager_Invitation__c IN: manResIdByInv.keySet()
        //                                                 AND Status__c = 'Submitted'
        //                                                 AND Assessment_Invitation__r.Type__c = 'Employee']) {
        //             employeeResponse.put(response.Assessment_Invitation__r.Manager_Invitation__c, response);
        //             System.debug('----- Employee Response 444444 ------- ' + response);
        //             // responseMap.put(response.Id, response); 
        //         }                
        //     }

        //     if(!empResIdByManInv.isEmpty()) {
        //         for(Assessment_Response__c response : [SELECT Id, Status__c, Assessment_Invitation__c, Assessment_Invitation__r.Type__c, 
        //                                                 Assessment_Invitation__r.Assessor__c, Assessment_Invitation__r.Assessee__c,
        //                                                 Assessment_Invitation__r.Manager_Invitation__c, Assessment_Invitation__r.Manager_Invitation__r.Assessor__c,
        //                                                 (SELECT Id FROM Assessment_Question_Responses__r)                                                        
        //                                                 FROM Assessment_Response__c
        //                                                 WHERE Assessment_Invitation__c IN: empResIdByManInv.keySet()
        //                                                 AND Status__c = 'Submitted'
        //                                                 AND Assessment_Invitation__r.Type__c = 'Manager']) {
        //             managerResponse.put(response.Assessment_Invitation__c, response);
        //             System.debug('----- Manager Response 55555 ------- '+ response);
        //             // responseMap.put(response.Id, response); 
        //         } 
        //     }

        //     for(Assessment_Response__c assessment : responseMap.values()) {
        //         if(assessment.Assessment_Invitation__r.Type__c == 'Employee') {
        //             Assessment_Response__c managerRes = managerResponse.get(assessment.Assessment_Invitation__r.Manager_Invitation__c);
        //             if(managerRes != null) {
        //                 shareResponse.add(assessment);
        //                 shareResponse.add(managerRes);
        //             }
        //         } else {
        //             Assessment_Response__c employeeRes = employeeResponse.get(assessment.Assessment_Invitation__c);
        //             if(employeeRes != null) {
        //                 shareResponse.add(assessment);
        //                 shareResponse.add(employeeRes);
        //             }
        //         }
        //     }

            
        //     try {
        //         if(!shareResponse.isEmpty()) {
        //             System.debug('----- 6666666 ------- ');
        //             shareAssessmentRecord.shareAssessmentRecordAccess(shareResponse);
        //         }                                
        //     } catch(Exception e){
        //         System.debug('*********** shareAssessmentResponsePostDueDate ERROR: ' + e.getMessage() + ' at ' + e.getLineNumber());
        //         System.debug(LoggingLevel.FINEST, 'e.getStackTraceString(): ' + e.getStackTraceString());
        //         return;
        //     }
        // }
    }   

    //Deprecated since we're not handling emails for skills
    //used to handle if the manager and employee are grouped in a bulk, but split over multiple transactions
    // public static Set<String> processedResponses;
    
    // public static void sendAreaOfInterestsEmail(List<Assessment_Response__c> newResponses, Map<Id, Assessment_Response__c> oldResponseById){
    //     if(processedResponses == null){
    //         processedResponses = new Set<String>();
    //     }


    //     List<String> employeeResponseIds = new List<String>();
    //     List<String> managerResponseIds = new List<String>();
        
    //     for(Assessment_Response__c ar : newResponses){
    //         Assessment_Response__c oldAR = oldResponseById.get(ar.Id);
    //         if(ar.Status__c == 'Submitted' && ar.Status__c != oldAR.Status__c){
    //             if(ar.Is_Manager__c){
    //                 managerResponseIds.add(ar.Id);
    //             } else {
    //                 employeeResponseIds.add(ar.Id);
    //             }
    //         }
    //     }

    //     if(!employeeResponseIds.isEmpty() || !managerResponseIds.isEmpty()){
    //         List<Assessment_Response__c> employeeResponses =[SELECT Id, Assessment_Taker__c, Assessment_Taker__r.slj__Email__c, Assessment_Taker__r.slj__User__c
    //                                                          FROM Assessment_Response__c
    //                                                          WHERE (Id =: employeeResponseIds OR Manager_Response__c =: managerResponseIds)
    //                                                          AND Status__c = 'Submitted'
    //                                                          AND Manager_Response__r.Status__c = 'Completed'
    //                                                          AND Id NOT IN :processedResponses
    //                                                          WITH USER_MODE];
                                                             
    //         if(!employeeResponses.isEmpty()){
    //             Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
    //             String orgEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'astrocoursetracker@salesforce.com'].Id;
    //             String emailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Area_of_Interests_Notification'].Id;

    //             for (Assessment_Response__c ar : employeeResponses) {
    //                 processedResponses.add(ar.Id);

    //                 Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

    //                 message.setTargetObjectId(ar.Assessment_Taker__r.slj__User__c);
    //                 message.setUseSignature(false); 
    //                 message.setBccSender(false); 
    //                 message.setSaveAsActivity(false);
    //                 message.setTemplateID(emailTemplateId);
    //                 message.setWhatId(ar.Id);
    //                 message.setOrgWideEmailAddressId(orgEmailId);
    //                 message.toAddresses = new List<String>{ar.Assessment_Taker__r.slj__Email__c};

    //                 //add email to list
    //                 messages.add(message);
    //             }

    //             Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    //             System.debug('***************** results ' + results);
    //         }
    //     }     
    // }
    

    public static void markCompletedResponses(List<Assessment_Response__c> newResponses, Map<Id, Assessment_Response__c> oldResponseById){
        List<String> reviewIds = new List<String>();
        
        for(Assessment_Response__c ar : newResponses){
            Boolean hasSkillOne = String.isNotEmpty(ar.Review_Skill_One__c);
            
            if(hasSkillOne){
                ar.Status__c = 'Completed';
                ar.Completion_Date__c = Date.today();
            }
        }
    }
}