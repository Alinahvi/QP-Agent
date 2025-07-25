public with sharing class DesignatedAssessorNotification {
    
    @InvocableMethod( label='Send Assessor Notification When Learner Chooses' description='Send Assessor Notification When Learner Chooses')
    public static void sendAssessorAssignedNotification(List<Assignment__c> newList) {
        String orgURL = new SiteLink().siteUrlWithPrefix;
        String inAppRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('In_App_Assessment').getRecordTypeId();
        Map<String, Object> inAppAssetsByAssessorId = new Map<String, Object>();
        Map<Id, Assignment__c> updatedMap = new Map<Id, Assignment__c>();
        updatedMap.putAll(newList);
        
        for(Assignment__c assignment : [SELECT Id, Assessor__c, Assessor__r.slackid__c, Asset__r.Name, Asset__r.Description__c
                                        FROM Assignment__c 
                                        WHERE Assessor__c != NULL
                                        AND Asset__r.RecordTypeId = :inAppRecordTypeId
                                        AND Assessor__r.slackid__c != NULL
                                        AND Inactive__c = false
                                        AND Id In: updatedMap.keySet()
                                        WITH USER_MODE]) {
            if(inAppAssetsByAssessorId.containsKey(assignment.Assessor__c)) {
                Map<String, Object> temp = (Map<String, Object>)inAppAssetsByAssessorId.get(assignment.Assessor__c);
                if(!temp.containsKey(assignment.Asset__r.Id)) {
                    temp.put(assignment.Asset__r.Id, (Object)new Map<String, String> {
                        'learningId' => assignment.Asset__r.Id,
                        'name' => assignment.Asset__r.Name,
                        'description' => assignment.Asset__r.Description__c,
                        'lpId' => assignment.Assessor__r.Id,
                        'slackId' => assignment.Assessor__r.slackid__c,
                        'url' => orgURL+'/assess'
                    });
                }                
            } else {
                inAppAssetsByAssessorId.put(assignment.Assessor__c, (Object)new Map<String, Object> {
                    assignment.Asset__r.Id => (Object)new Map<String, String> {
                        'learningId' => assignment.Asset__r.Id,
                        'name' => assignment.Asset__r.Name,
                        'description' => assignment.Asset__r.Description__c,
                        'lpId' => assignment.Assessor__r.Id,
                        'slackId' => assignment.Assessor__r.slackid__c,
                        'url' => orgURL+'/assess'
                    }
                });
            }
        }
        
        if(!inAppAssetsByAssessorId.isEmpty()) {
            Map<String, String> metaInfo = new Map<String, String> {
                'type' => 'In-App-Assessment',
                'action' => 'designated-assessor'
            };
            System.enqueueJob(new SlackQueueableNotification(metaInfo, inAppAssetsByAssessorId));
        }
    }    
}