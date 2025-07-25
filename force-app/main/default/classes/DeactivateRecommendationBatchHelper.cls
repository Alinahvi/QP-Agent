public with sharing class DeactivateRecommendationBatchHelper {
    
    public static void deactivateRecommendation(List<Recommended_Learning__c> scope) {
        List<Recommended_Learning__c> recToDeactivate = new List<Recommended_Learning__c>();
        List<Recommendation_Activity__c> recActivity = new List<Recommendation_Activity__c>();
        for(Recommended_Learning__c rl : scope) {
            rl.Status__c = 'Inactive';
            recActivity.add(new Recommendation_Activity__c(
                Activity_Type__c = 'Recommended Learning Deactivated',
                Content_Distribution_Organization__c = rl.Content_Distribution_Organization__c,
                Recommended_Learning__c = rl.Id
            ));
            recToDeactivate.add(rl);
        }

        try {
            if(!recToDeactivate.isEmpty()) {
                update as user recToDeactivate;
            }                        
        } catch(Exception e) {
            System.debug('Error while updating Recommended_Learning__c'+e.getMessage() + ' :: '+e.getStackTraceString());
        }

        try {
            if(!recActivity.isEmpty()) {
                insert as user recActivity;
            }            
        } catch(Exception e) {
            System.debug('Error while creating Recommendation_Activity__c'+e.getMessage() + ' :: '+e.getStackTraceString());
        }
    }
}