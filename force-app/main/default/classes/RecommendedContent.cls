public with sharing class RecommendedContent {
    @AuraEnabled(cacheable=true)
    public static ResponseData getRecommendedContent(RecommendedLearners.RecommendationPayload payload) {
        ResponseData rd = new ResponseData();
        
        try {
            String contentObjectType = payload.recordId.getSObjectType() + '';
 
            if (!contentObjectType.equals(Audience__c.getSObjectType() + '')) {
                throw new RecommendedContentException('Fetching Recommended Content from Invalid SObject Record Page: ' + contentObjectType);
            }

            List<Map<String, Object>> recommendedAudiences = new List<Map<String, Object>>();

            for (Recommended_Audience__c recommendedAudience : [SELECT Id, Curriculum__c, Curriculum__r.Name, Course__c, Course__r.Name, Asset__c, Asset__r.Name, Audience__c, Audience__r.Name, Content_Distribution_Organization__c,
                                                                       Enablement_Learning_Program__c, Enablement_Learning_Program__r.Name
                                                                FROM Recommended_Audience__c WHERE Audience__c = :payload.recordId WITH USER_MODE ORDER BY CreatedDate DESC LIMIT 50 ]) {
                Map<String, Object> formattedRecommendedAudience = recommendedAudience.getPopulatedFieldsAsMap().clone();

                if (recommendedAudience.Curriculum__c != null) {
                    formattedRecommendedAudience.put('type', 'Curriculum');
                    formattedRecommendedAudience.put('name', recommendedAudience.Curriculum__r.Name);
                    formattedRecommendedAudience.put('contentId', recommendedAudience.Curriculum__c);
                    formattedRecommendedAudience.put('itemIcon', 'utility:education');
                    formattedRecommendedAudience.put('itemIconClass', 'msj-item-icon_curriculum slds-p-around_x-small');
                } else if (recommendedAudience.Course__c != null) {
                    formattedRecommendedAudience.put('type', 'Course');
                    formattedRecommendedAudience.put('name', recommendedAudience.Course__r.Name);
                    formattedRecommendedAudience.put('contentId', recommendedAudience.Course__c);
                    formattedRecommendedAudience.put('itemIcon', 'utility:knowledge_base');
                    formattedRecommendedAudience.put('itemIconClass', 'msj-item-icon_course slds-p-around_x-small');
                } else if (recommendedAudience.Asset__c != null) {
                    formattedRecommendedAudience.put('type', 'Asset');
                    formattedRecommendedAudience.put('name', recommendedAudience.Asset__r.Name);
                    formattedRecommendedAudience.put('contentId', recommendedAudience.Asset__c);
                    formattedRecommendedAudience.put('itemIcon', 'utility:puzzle');
                    formattedRecommendedAudience.put('itemIconClass', 'msj-item-icon_asset slds-p-around_x-small');
                }

                formattedRecommendedAudience.put('audienceName', String.isNotEmpty(recommendedAudience.Audience__c) ? recommendedAudience.Audience__r.Name : '');
                formattedRecommendedAudience.put('itemIconSize', 'x-small');
                formattedRecommendedAudience.put('iconContainerClass', 'msj-item-icon ' + formattedRecommendedAudience.get('itemIconClass'));
                
                recommendedAudiences.add(formattedRecommendedAudience);
            }
            
            rd.put('recommendedAudiences', recommendedAudiences);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData addRecommendedContent(RecommendedLearners.RecommendationPayload payload){
        ResponseData rd = new ResponseData();
        
        try {
            String sObjectType = payload.recordId.getSObjectType() + '';

            if (!sObjectType.equals(Audience__c.getSObjectType() + '')) {
                throw new RecommendedContentException('Adding Recommended Audience from Invalid SObject Record Page: ' + sObjectType);
            }

            if (!payload.idsToProcess.isEmpty()) {
                Id jobId = RecommendationHelper.addContentToAudience(payload.recordId, payload.idsToProcess, payload.contentOrg, payload.program, payload.expirationDate, payload.ouLeader);

                rd.put('jobId', jobId);

                if (jobId == null) {
                    RecommendationHelper.performDml();
                }
            }

        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public class RecommendedContentException extends Exception {}
}