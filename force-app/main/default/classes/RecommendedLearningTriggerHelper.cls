public with sharing class RecommendedLearningTriggerHelper {
    public static void setSeedRecommended(List<Recommended_Learning__c> recommendedLearnings) {
        Map<String, Date> startDateBySessionId = getSessionStartDate(recommendedLearnings);
        Map<Id, List<Recommended_Learning__c>> recBySessionId = new Map<Id, List<Recommended_Learning__c>>();
        for (Recommended_Learning__c rec : recommendedLearnings) {            
            if (rec.Content_Distribution_Organization__c == 'SEED') {
                rec.SEED_Recommended__c = true;
                // Seed auto expiration date is + 30 days post learning is recommended                
                if(rec.Session__c == null && rec.Status__c == 'Active' && 
                    (Trigger.operationType == System.TriggerOperation.BEFORE_INSERT || 
                    Trigger.operationType == System.TriggerOperation.BEFORE_UPDATE)) {
                    rec.Expiration_Date__c = Date.today() + 30;
                }
            } 
            if(!startDateBySessionId.isEmpty() && rec.Status__c == 'Active' && rec.Session__c != null && 
                (Trigger.operationType == System.TriggerOperation.BEFORE_INSERT || Trigger.operationType == System.TriggerOperation.BEFORE_UPDATE)) {
                rec.Expiration_Date__c = startDateBySessionId.get(rec.Session__c);                
            }
        }        
    }

    public static void setRecommendationLookups(List<SObject> newAssignedRecords) {
        Map<String, SObject> assignedRecordsByKey = new Map<String, SObject>();

        for (SObject assignedRecord : newAssignedRecords) {
            assignedRecordsByKey.put(RecommendationHelper.getRecommendationKey(assignedRecord), assignedRecord);
        }

        System.debug('********************** assignedRecordsByKey ' + assignedRecordsByKey);

        for (Recommended_Learning__c recommendedLearning : [SELECT Id, Key__c FROM Recommended_Learning__c 
                                                            WHERE Key__c IN :assignedRecordsByKey.keySet()
                                                            AND Status__c = 'Active' WITH USER_MODE
                                                            ORDER BY CreatedDate ASC]) {

            sObject assignedRecord = assignedRecordsByKey.get(recommendedLearning.Key__c);
            System.debug('********************** assignedRecord ' + assignedRecord);
            if (assignedRecord == null || String.isNotEmpty(String.valueOf(assignedRecord.get('Recommended_Learning__c')))) {
                continue;
            }
            System.debug('********************** recommendedLearning.Id ' + recommendedLearning.Id);
            assignedRecordsByKey.get(recommendedLearning.Key__c).put('Recommended_Learning__c', recommendedLearning.Id);
        }
    }

    public static void updateRecommendations(List<SObject> assignedRecords, String status) {
        List<String> recommendedLearningIds = new List<String>();

        for (SObject assignedRecord : assignedRecords) {
            if (String.isEmpty(String.valueOf(assignedRecord.get('Recommended_Learning__c')))) {
                continue;
            }

            recommendedLearningIds.add(String.valueOf(assignedRecord.get('Recommended_Learning__c')));
        }
        
        if (!recommendedLearningIds.isEmpty()) {
            RecommendationHelper.updateRecommendationStatus(recommendedLearningIds, status);
        }
    }

    public static void updateRecommendations(List<SObject> newAssignedRecords, Map<Id, SObject> oldAssignedRecords, String status) {
        List<Id> recommendedLearningIds = new List<Id>();

        for (SObject assignedRecord : newAssignedRecords) {
            if (String.isEmpty(String.valueOf(assignedRecord.get('Recommended_Learning__c')))) {
                continue;
            }

            String sObjType = assignedRecord.getSObjectType() + '';
            SObject oldAssignedRecord = oldAssignedRecords.get(assignedRecord.Id);

            switch on status {
                when 'Learning Assigned'{
                    if (!(Boolean) assignedRecord.get('Inactive__c') && (Boolean) oldAssignedRecord.get('Inactive__c')) {
                        recommendedLearningIds.add(String.valueOf(assignedRecord.get('Recommended_Learning__c')));
                    }
                }
                when 'Learning Completed' {
                    if(sObjType == 'Assigned_Session__c'){
                        List<String> passingStatuses = new List<String>{'Attended', 'Exempt'};
                        String sessionStatus = (String)assignedRecord.get('Status__c');
                        String oldSessionStatus = (String)oldAssignedRecord.get('Status__c');
                        
                        if(passingStatuses.contains(sessionStatus) && oldSessionStatus != sessionStatus){
                            recommendedLearningIds.add(String.valueOf(assignedRecord.get('Recommended_Learning__c')));
                        }

                    } else if ((Boolean) assignedRecord.get('Completed__c') && !(Boolean) oldAssignedRecord.get('Completed__c')) {
                        recommendedLearningIds.add(String.valueOf(assignedRecord.get('Recommended_Learning__c')));
                    }
                }
                when 'Active' {
                    if ((Boolean) assignedRecord.get('Inactive__c') && !(Boolean) oldAssignedRecord.get('Inactive__c')) {
                        recommendedLearningIds.add(String.valueOf(assignedRecord.get('Recommended_Learning__c')));
                    }
                }
            }
        }

        if (!recommendedLearningIds.isEmpty()) {
            RecommendationHelper.updateRecommendationStatus(recommendedLearningIds, status);
        }
    }

    public static Map<String, Date> getSessionStartDate(List<Recommended_Learning__c> newRm) {
        Set<Id> sessionId = new Set<Id>();
        Map<String, Date> startDateBySessionId = new Map<String, Date>();
        for(Recommended_Learning__c rl : newRm) {
            if(rl.Session__c != null) {
                sessionId.add(rl.Session__c);
            }
        }
        if(!sessionId.isEmpty()) {
            for(Session__c session : [SELECT Id, Start_Date__c FROM Session__c WHERE Id IN: sessionId]) {
                startDateBySessionId.put(session.Id, session.Start_Date__c);
            }
        }
        return startDateBySessionId;
    }  
    
}