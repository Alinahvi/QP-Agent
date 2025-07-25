public with sharing class RecommendationNotification implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, SlackId__c, Name, User__r.FirstName, 
                                        (SELECT Id, Asset__r.Name, Course__r.Name, Curriculum__r.Name, Content_Distribution_Organization__c,
                                        Asset__r.Time_Estimate__c, Course__r.Time_Estimate__c, Curriculum__r.Time_Estimate__c,
                                        Asset__r.Description__c, Course__r.Description__c, Curriculum__r.Description__c, Asset__r.RecordTypeId,
                                        Asset__r.Assessment_Type__c, Session__r.Name, Session__r.Description__c
                                        FROM Recommended_Learnings__r 
                                        WHERE Status__c = 'Active' 
                                        AND Content_Distribution_Organization__c != 'SEED'
                                        AND createdDate = YESTERDAY
                                        AND Send_Recommendation_Notification__c = true
                                        ORDER BY createdDate DESC
                                        LIMIT 15)
                                        FROM Learner_Profile__c 
                                        WHERE SlackId__c != NULL                                         
                                        AND ID IN (SELECT Learner_Profile__c 
                                        FROM Recommended_Learning__c 
                                        WHERE createdDate = YESTERDAY
                                        AND Content_Distribution_Organization__c != 'SEED'
                                        AND Status__c = 'Active'
                                        AND Learner_Profile__r.Employee_on_Leave__c = FALSE)]);
        
        // :: Test Run Only ::
        /* return Database.getQueryLocator([SELECT Id, SlackId__c, Name, User__r.FirstName, 
        (SELECT Id, Asset__r.Name, Course__r.Name, Curriculum__r.Name, Content_Distribution_Organization__c,
        Asset__r.Time_Estimate__c, Course__r.Time_Estimate__c, Curriculum__r.Time_Estimate__c,
        Asset__r.Description__c, Course__r.Description__c, Curriculum__r.Description__c, Asset__r.RecordTypeId, Asset__r.Assessment_Type__c
        FROM Recommended_Learnings__r 
        WHERE Status__c = 'Active' 
        AND Content_Distribution_Organization__c != 'SEED'
        AND createdDate = TODAY
        AND Send_Recommendation_Notification__c = true
        ORDER BY createdDate DESC
        LIMIT 15)
        FROM Learner_Profile__c 
        WHERE SlackId__c != NULL                                         
        AND ID IN ('a5jHu000001DqICIA0', 'a5jHu000001ETshIAG', 'a5jHu000001EBFWIA4')]); 
        */
    }

    public void execute(Database.BatchableContext BC, List<Learner_Profile__c> scope) {
        List<Integration_Error__c> errorList = new List<Integration_Error__c>();
        Map<String, Object> result = RecommendationNotificationHelper.sendRecommededNotification(scope);
        if(!(Boolean)result.get('ok')) {
            Integration_Error__c error = (Integration_Error__c)result.get('error');
            if(error != null) {
                errorList.add(error);
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

    public void finish(Database.BatchableContext BC) {
        Database.executeBatch(new AssessorSlackNotification(), 70); 
    }

}