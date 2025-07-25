//Deprecrated 11/13/2024 Stanley Chui. Unfinshed until we have 1-1 relationship between manager and learner
public with sharing class SkillAssessmentReassign {
    @AuraEnabled
    public static ResponseData updateLearnerResponses(String learnerId, String assetId){
        ResponseData rd = new ResponseData();
        
        try {
            Learner_Profile__c lp =[SELECT Id, User__r.ManagerId
                                    FROM Learner_Profile__c 
                                    WHERE Id = :learnerId];

            Learner_Profile__c managerLP = [SELECT Id
                                            FROM Learner_Profile__c 
                                            WHERE User__c = :lp.User__r.ManagerId];

            List<Assessment_Response__c> responses = [SELECT Id, Manager__c, Manager_Response__c
                                                      FROM Assessment_Response__c 
                                                      WHERE Assessment_Taker__c = :learnerId
                                                      AND Is_Manager__c = false
                                                      AND Asset__c = :assetId
                                                      AND Status__c != 'Completed'];
            List<String> managerResponseIds = new List<String>();

            for(Assessment_Response__c response : responses){
                response.Manager__c = managerLP.Id;
                managerResponseIds.add(response.Manager_Response__c);
            }

            update responses;

            List<Assessment_Response__c> managerResponses = [SELECT Id, Assessment_Taker__c
                                                             FROM Assessment_Response__c 
                                                             WHERE Id =: managerResponseIds];

            for(Assessment_Response__c response : managerResponses){
                response.Assessment_Taker__c = managerLP.Id;
            }

            update managerResponses;
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }
}