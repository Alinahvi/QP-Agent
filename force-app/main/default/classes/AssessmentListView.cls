public with sharing class AssessmentListView {
    @AuraEnabled
    public static ResponseData getData(){
        ResponseData rd = new ResponseData();
        
        try {
            Learner_Profile__c lp = [SELECT Id
                                     FROM Learner_Profile__c
                                     WHERE User__c =: UserInfo.getUserId()
                                     AND Status__c = 'Active'
                                     WITH USER_MODE];
            String inAppRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('In_App_Assessment').getRecordTypeId();
            List<Assignment__c> assignmentsToAssess = [SELECT Id, CreatedDate, Due_Date__c, Asset__r.RecordType.Name, Asset__r.RecordType.DeveloperName, Asset__r.Name, Learner_Profile__r.Name, 
                                                              Learner_Profile__r.User__r.SmallPhotoUrl, Self_Assigned__c
                                                       FROM Assignment__c
                                                       WHERE Assessor__c =: lp.Id
                                                       AND Asset__r.RecordTypeId =: inAppRecordTypeId
                                                       AND Completed__c = false
                                                       AND Inactive__c = false
                                                       WITH USER_MODE
                                                       ORDER BY Due_Date__c ASC];

            List<Map<String, Object>> formattedAssessments = new List<Map<String, Object>>();

            for(Assignment__c assessment : assignmentsToAssess){
                formattedAssessments.add(formatAssessment(assessment));
            }

            rd.put('assessments', formattedAssessments); 
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    } 

    public static Map<String, Object> formatAssessment(Assignment__c assessment){
        Map<String, Object> formattedAssessment = assessment.getPopulatedFieldsAsMap().clone();

        if(!assessment.Self_Assigned__c) { 
            DateTime dueDate = DateTime.newInstanceGMT((Date)assessment.get('Due_Date__c'), Time.newInstance(0, 0, 0, 0));
            formattedAssessment.put('formattedDueDate', dueDate.formatGMT('MM/dd/yyyy'));
        }
        return formattedAssessment;
    }
}