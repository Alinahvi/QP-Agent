public with sharing class assessmentLearnerList {
    public String assessmentResponseId{get;set;}
    public String assessmentId{get;set;}
    public String assessmentCohortId{get;set;}
    public String assessorId{get;set;}

    public List<String> getAssessmentLearnerList() {
        List<String> asseseeNames = new List<String>();
 
        List<Assessment_Response__c> responses = [SELECT Id, Assessment_Taker__r.Name, Assessment__c
                                                  FROM Assessment_Response__c 
                                                  WHERE Manager_Response__c =: assessmentResponseId
                                                  WITH USER_MODE
                                                  ORDER BY Assessment_Taker__r.Name ASC];

        for (Assessment_Response__c ar : responses) {
            asseseeNames.add(ar.Assessment_Taker__r.Name);
        }

        return asseseeNames;
    }
}