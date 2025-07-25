public with sharing class AssessorSlackNotification implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    Map<String, Object> inAppAssetsByAssessorId = new Map<String, Object>();
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String inAppRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('In_App_Assessment').getRecordTypeId();
        return Database.getQueryLocator([SELECT Id, Assessor__c, Assessor__r.slackid__c, Asset__r.Name, Asset__r.Description__c
                                        FROM Assignment__c 
                                        WHERE Self_Assigned__c = FALSE
                                        AND Assessor__c != NULL
                                        AND Inactive__c = false
                                        AND Asset__r.RecordTypeId = :inAppRecordTypeId
                                        AND Assessor__r.slackid__c != NULL
                                        AND createdDate = TODAY
                                        AND Assessor_Type__c IN ('Learning Admin Chooses','Learner\'s Manager')
                                        WITH USER_MODE]);
    }

    public void execute(Database.BatchableContext BC, List<Assignment__c> scope) {
        String orgURL = new SiteLink().siteUrlWithPrefix;
        for(Assignment__c assignment : scope) {
            if(inAppAssetsByAssessorId.containsKey(assignment.Assessor__c)) {
                Map<String, Object> temp = (Map<String, Object>)inAppAssetsByAssessorId.get(assignment.Assessor__c);
                if(!temp.containsKey(assignment.Asset__r.Id)) {
                    temp.put(assignment.Asset__r.Id, (Object)new Map<String, String> {
                        'learningId' => assignment.Asset__r.Id,
                        'name' => String.isBlank(assignment.Asset__r.Name) ? 'None' : assignment.Asset__r.Name.escapeJava(),
                        'description' => String.isBlank(assignment.Asset__r.Description__c) ? 'NA' : assignment.Asset__r.Description__c.escapeJava(),
                        'lpId' => assignment.Assessor__r.Id,
                        'slackId' => assignment.Assessor__r.slackid__c,
                        'url' => orgURL+'/assess'                        
                    });
                }                
            } else {
                inAppAssetsByAssessorId.put(assignment.Assessor__c, (Object)new Map<String, Object> {
                    assignment.Asset__r.Id => (Object)new Map<String, String> {
                        'learningId' => assignment.Asset__r.Id,
                        'name' => String.isBlank(assignment.Asset__r.Name) ? 'None' : assignment.Asset__r.Name.escapeJava(),
                        'description' => String.isBlank(assignment.Asset__r.Description__c) ? 'NA' : assignment.Asset__r.Description__c.escapeJava(),
                        'lpId' => assignment.Assessor__r.Id,
                        'slackId' => assignment.Assessor__r.slackid__c,
                        'url' => orgURL+'/assess'                    
                    }
                });
            }
        }                
    }

    public void finish(Database.BatchableContext BC) {
        if(!inAppAssetsByAssessorId.isEmpty()) {
            Map<String, String> metaInfo = new Map<String, String> {
                'type' => 'In-App-Assessment',
                'action' => 'designated-assessor'
            };
            System.enqueueJob(new SlackQueueableNotification(metaInfo, inAppAssetsByAssessorId));
        }
        Database.executeBatch(new DeactivateRecommendationBatch(), 90);
    }

}