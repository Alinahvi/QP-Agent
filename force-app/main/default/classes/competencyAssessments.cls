public with sharing class competencyAssessments {
    // @AuraEnabled
    // public static String getIncompleteAssessments() {
    //     responseData rd = new responseData();

    //     try{
    //         dmlManager.checkAccess(getIncompleteAssessmentsAccessMap);

    //         List<IncompleteAssessment> incompleteAssessments = new List<IncompleteAssessment>();
    //         Set<Id> assesseeUserIds = new Set<Id>();

    //         for(Assessment_Invitation__c ai : [SELECT Id, Assessment__r.Name, Type__c, Assessment_Taker__c,
    //                                               (SELECT Id 
    //                                                FROM Assessment_Response__r)
    //                                            FROM Assessment_Invitation__c
    //                                            WHERE Assessor__c = :UserInfo.getUserId()
    //                                              AND Send_Date__c <= TODAY
    //                                            ORDER BY Send_Date__c ASC]) {

    //             if(ai.Assessment_Response__r.isEmpty()) {
    //                 //no response so incomplete
    //                 incompleteAssessments.add(new IncompleteAssessment(ai));
    //                 //need assessee user ids to find learners to get name
    //                 assesseeUserIds.add(ai.Assessment_Taker__c);
    //             }
    //         }

    //         Map<Id, String> nameByUserId = new Map<Id, String>();
    //         //get learner names for invitations
    //         for(slj__Learner_Profile__c lp : [SELECT Name, slj__User__c
    //                                           FROM slj__Learner_Profile__c
    //                                           WHERE slj__User__c = :assesseeUserIds]) {
    //             nameByUserId.put(lp.slj__User__c, lp.Name);
    //         }

    //         for(IncompleteAssessment i : incompleteAssessments) {
    //             i.addAssesseeName(nameByUserId);
    //         }

    //         rd.put('incompleteAssessments', incompleteAssessments);

    //         //for list view nav
    //         String sObjType = constants.NAMESPACE_API + 'Assessment_Response__c';
    //         ListView lv = [SELECT Id FROM ListView WHERE SObjectType = :sObjType AND DeveloperName = 'My_Self_Assessments'];

    //         rd.put('listViewId', lv.Id);
    //         rd.put('nsApi', constants.NAMESPACE_API);
    //     } catch(Exception e) {
    //         rd.addError(e);
    //     }

    //     return rd.getJsonString();
    // }

    // private class IncompleteAssessment {
    //     @AuraEnabled public String id;
    //     @AuraEnabled public String name;
    //     @AuraEnabled public String type;
    //     @AuraEnabled public String assesseeName;

    //     private Id assesseeId;

    //     private IncompleteAssessment(Assessment_Invitation__c ai) {
    //         this.id = ai.Id;
    //         this.name = ai.Assessment__r.Name;
    //         this.type = ai.Type__c == 'Employee' ? 'Self Assessment' : 'Manager Assessment';
    //         this.assesseeId = ai.Assessment_Taker__c;
    //     }

    //     public void addAssesseeName(Map<Id, String> nameByUserId) {
    //         this.assesseeName = nameByUserId.get(this.assesseeId);
    //     }
    // }

    // private static FINAL Map<String, Map<String, List<String>>> getIncompleteAssessmentsAccessMap = new Map<String, Map<String, List<String>>>{
    //     'Assessment_Invitation__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id', 'Type__c', 'Assessment_Taker__c', 'Assessor__c', 'Send_Date__c'
    //         }
    //     },
    //     'Assessment__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Name'
    //         }
    //     },
    //     'Assessment_Response__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id'
    //         }
    //     },
    //     'Learner_Profile__c' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Name', 'User__c'
    //         }
    //     },
    //     'ListView' => new Map<String, List<String>>{
    //         'Read' => new List<String>{
    //             'Id'
    //         }
    //     }
    // };
}