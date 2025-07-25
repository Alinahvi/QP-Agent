/**
 * Controller Class for the Recommended Learners Component
 * Component goes on Curriculum, Course or Asset record page,
 * and displays the associated learners and audiences that 
 * have been recommended that piece of content
 */
public with sharing class RecommendedLearners {
    /**
     * Fetches the Recommended_Learning__c or Recommended_Audience__c records
     * associated with a given Content SObject
     */
    @AuraEnabled(cacheable=true)
    public static ResponseData getRecommendedLearners(RecommendationPayload payload) {
        ResponseData rd = new ResponseData();
        
        try {
            if (payload.recordId == null) {
                rd.put('recommendedLearnings', new List<Map<String, Object>>());
                return rd;
            }

            String contentObjectType = (payload.recordId).getSObjectType() + '';
 
            if (!RecommendationHelper.VALID_CONTENT_RECORD_TYPES.contains(contentObjectType)) {
                throw new RecommendedLearnersException('Fetching Recommended Learning from Invalid SObject Record Page: ' + contentObjectType);
            }

            List<Id> filteredAudienceIds = payload.idsToProcess;

            Set<String> recommendedLearningFields = new Set<String> {
                'Id', 'Status__c', 'Learner_Profile__c', 'Learner_Profile__r.Name', 'Learner_Profile__r.Primary_Email__c', 'Audience__c', 'Audience__r.Name', 'Learner_Profile__r.User__r.SmallPhotoUrl',
                'Expiration_Date__c', 'CreatedDate'
            };

            String queryFilters = buildQueryFilters(payload);
            String query = '';
            List<Id> currentIds = payload.currentlyDisplayedIds;

            System.debug('************* ' + queryFilters);

            if (payload.currentlyDisplayedIds != null && !payload.currentlyDisplayedIds.isEmpty()) {
                query = 'SELECT ' + String.join(recommendedLearningFields, ',') + ' FROM Recommended_Learning__c ' + queryFilters + ' AND Id NOT IN :currentIds ORDER BY Learner_Profile__r.Name ASC LIMIT 30';
            } else {
                query = 'SELECT ' + String.join(recommendedLearningFields, ',') + ' FROM Recommended_Learning__c' + queryFilters + ' ORDER BY Learner_Profile__r.Name ASC LIMIT 30';

            }

            List<Map<String, Object>> recommendedLearnings = new List<Map<String, Object>>();

            for (Recommended_Learning__c recommendedLearning : Database.query(query, System.AccessLevel.USER_MODE)) {
                Map<String, Object> formattedRecommendedLearning = recommendedLearning.getPopulatedFieldsAsMap().clone();
                
                DateTime expirationDate = DateTime.newInstanceGMT(recommendedLearning.Expiration_Date__c, Time.newInstance(0, 0, 0, 0));
                formattedRecommendedLearning.put('formattedexpirationDate', expirationDate.formatGMT('MM/dd/yyyy'));
                formattedRecommendedLearning.put('formattedRecommendedDate', recommendedLearning.CreatedDate.formatGMT('MM/dd/yyyy'));
                formattedRecommendedLearning.put('avatar', recommendedLearning.Learner_Profile__r.User__r.SmallPhotoUrl);
                formattedRecommendedLearning.put('name', recommendedLearning.Learner_Profile__r.Name);
                formattedRecommendedLearning.put('email', recommendedLearning.Learner_Profile__r.Primary_Email__c);
                formattedRecommendedLearning.put('audienceName', recommendedLearning.Audience__r.Name);
                formattedRecommendedLearning.put('audienceUrl', '/' + recommendedLearning.Audience__c);

                recommendedLearnings.add(formattedRecommendedLearning);
            }

            String totalCountQuery = 'SELECT COUNT() FROM Recommended_Learning__c ' + queryFilters;

            rd.put('recommendedLearnings', recommendedLearnings);
            rd.put('totalRecommendedLearnings', Database.countQuery(totalCountQuery, System.AccessLevel.USER_MODE));
            rd.put('totalFilteredRecommendedLearnings', Database.countQuery('SELECT COUNT() FROM Recommended_Learning__c' + queryFilters, System.AccessLevel.USER_MODE));
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled(cacheable=true)
    public static ResponseData getEnablementPrograms() {
        ResponseData rd = new ResponseData();
        
        try {
            List<Map<String, Object>> enablementProgramOptions = new List<Map<String, Object>>();

            for (Enablement_Learning_Program__c program : [SELECT Id, Name FROM Enablement_Learning_Program__c ORDER BY Name ASC]) {
                enablementProgramOptions.add(new Map<String, Object>{
                    'label' => program.Name,
                    'value' => program.Id
                });
            }

            rd.put('enablementProgramOptions', enablementProgramOptions);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled(cacheable=true)
    public static ResponseData getAudienceFilterOptions(Id recordId) {
        responseData rd = new responseData();

        try {
            if (recordId == null) {
                rd.put('audienceFilterOptions', new List<Map<String, Object>>());
                return rd;        
            }

            String contentRecordType = recordId.getSObjectType() + '';

            if (!(RecommendationHelper.VALID_CONTENT_RECORD_TYPES.contains(contentRecordType))) {
                throw new RecommendedLearnersException('Adding Recommended Learning from Invalid SObject Record Page: ' + contentRecordType);
            }

            String query = 'SELECT Id, Name FROM Audience__c WHERE Id IN (SELECT Audience__c FROM Recommended_Learning__c WHERE ' + contentRecordType + ' = :recordId)'; // AND Status__c = \'Active\')';
            query += ' ORDER BY Name ASC LIMIT 50';

            List<Map<String, Object>> audiences = new List<Map<String, Object>>();

            for (Audience__c audience : Database.query(query, System.AccessLevel.USER_MODE)) {
                audiences.add(new Map<String, Object>{
                    'label' => audience.Name,
                    'value' => audience.Id,
                    'checked' => false
                });
            }
            
            rd.put('audienceFilterOptions', audiences);          
        } catch (Exception e) {
            rd.addError(e);
        }
        return rd;
    }

    /**
     * Creates new Recommended_Learning__c, Recommended_Audience__c & Recommendation_Activity__c records
     * based on a given list of Learner and / or audience Ids
     */
    @AuraEnabled
    public static ResponseData addLearnerRecommendations(RecommendationPayload payload){
        ResponseData rd = new ResponseData();
        
        try {
            String sObjectType = (payload.recordId).getSObjectType() + '';
            List<Id> learnerIdsToProcess = new List<Id>();
            
            if (payload.selectAll != null && payload.selectAll) {
                String queryFilters = buildQueryFilters(payload);
                Set<String> queryFields = new Set<String> { 'Id', 'Status__c', 'Learner_Profile__c', 'Audience__c', 'Curriculum__c', 'Course__c', 'Asset__c', 'Session__c'};
                String query = 'SELECT ' + String.join(queryFields, ',') + ' FROM Recommended_Learning__c ' + queryFilters;

                for(Recommended_Learning__c rl : Database.query(query)){
                    learnerIdsToProcess.add(rl.Learner_Profile__c);
                }
            } else {
                learnerIdsToProcess.addAll(payload.idsToProcess);
            }


            if (!RecommendationHelper.VALID_CONTENT_RECORD_TYPES.contains(sObjectType)) {
                throw new RecommendedLearnersException('Adding Recommended Learning from Invalid SObject Record Page: ' + sObjectType);
            }

            if (!payload.idsToProcess.isEmpty()) {
                System.debug('************* payload ' + payload);
                RecommendationHelper.addLearnersToContent(payload.recordId, learnerIdsToProcess, payload.contentOrg, payload.program, payload.expirationDate, payload.ouLeader);
                RecommendationHelper.performDml();
            }

        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData addAudienceRecommendations(RecommendationPayload payload){
        ResponseData rd = new ResponseData();
        
        try {
            String sObjectType = (payload.recordId).getSObjectType() + '';

            if (!RecommendationHelper.VALID_CONTENT_RECORD_TYPES.contains(sObjectType)) {
                throw new RecommendedLearnersException('Adding Recommended Learning from Invalid SObject Record Page: ' + sObjectType);
            }

            if (!payload.idsToProcess.isEmpty()) {
                Id jobId = RecommendationHelper.addAudiencesToContent(payload.recordId, payload.idsToProcess, payload.contentOrg, payload.program, payload.expirationDate, payload.ouLeader);

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

    @AuraEnabled
    public static ResponseData deactivateLearners(RecommendationPayload payload){
        ResponseData rd = new ResponseData();
        
        try {
            String sObjectType = payload.recordId.getSObjectType() + '';

            if (!RecommendationHelper.VALID_CONTENT_RECORD_TYPES.contains(sObjectType)) {
                throw new RecommendedLearnersException('Deactivating Recommended Learning from Invalid SObject Record Page: ' + sObjectType);
            }

            if (payload.selectAll) {
                List<Id> filteredAudienceIds = payload.idsToProcess;
                
                String queryFilters = buildQueryFilters(payload);

                if (Database.countQuery('SELECT COUNT() FROM Recommended_Learning__c' + queryFilters, System.AccessLevel.USER_MODE) > Utilities.BATCH_THRESHOLD) {
                    rd.put('jobId', Database.executeBatch(new RecommendationsDeactivateBatch(payload)));
                } else {
                    Set<String> queryFields = new Set<String> { 'Id', 'Status__c', 'Learner_Profile__c', 'Audience__c', 'Curriculum__c', 'Course__c', 'Asset__c', 'Session__c'};
                    String query = 'SELECT ' + String.join(queryFields, ',') + ' FROM Recommended_Learning__c' + queryFilters + ' ORDER BY Learner_Profile__r.Name ASC';

                    RecommendationHelper.updateLearnerStatus(payload.recordId, Database.query(query, System.AccessLevel.USER_MODE), 'Inactive');
                }
            } else if (payload.idsToProcess.size() == 1) {
                RecommendationHelper.updateLearnerStatus(payload.recordId, payload.idsToProcess, 'Inactive');

                String detail = RecommendationHelper.recommendedActivityToInsert[0].get('Detail__c').toString();

                if (detail != '') {
                    rd.addError(detail);
                } else {
                    RecommendationHelper.performDml();
                }
            } else if (!(payload.idsToProcess.isEmpty())) {
                RecommendationHelper.updateLearnerStatus(payload.recordId, payload.idsToProcess, 'Inactive');
                RecommendationHelper.performDml();
            }
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    // @AuraEnabled
    // public static ResponseData getBatchProgress(Id jobId){
    //     ResponseData rd = new ResponseData();
        
    //     try {
    //         Boolean inProgress = false;

    //         List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :jobId];

    //         if (jobs.isEmpty()) {
    //             throw new RecommendedLearnersException('Recommendation Batch Job Not Found, Job ID = ' + jobId);
    //         }

    //         switch on jobs[0].Status {
    //             when 'Queued', 'Preparing', 'Holding', 'Processing' {
    //                 inProgress = true;          
    //             }
    //             when 'Completed' {
    //                 inProgress = false;
    //             }
    //             when else {
    //                 throw new RecommendedLearnersException('Recommendation Batch Job ' + jobs[0].Status + ', Job ID = ' + jobId);
    //             }
    //         }

    //         rd.put('inProgress', inProgress);          
    //     } catch (Exception e) {
    //         rd.addError(e);
    //     }
    
    //     return rd;
    // }

    public static String buildQueryFilters(RecommendationPayload payload) {
        String queryFilters = ' WHERE ' + (payload.recordId).getSObjectType() + ' = \'' + payload.recordId + '\'';

        if (!payload.idsToProcess.isEmpty()) {
            queryFilters += ' AND Audience__c IN :filteredAudienceIds';
        }

        if (String.isNotEmpty(payload.searchTerm)) {
            queryFilters += ' AND Learner_Profile__r.Name LIKE \'%' + String.escapeSingleQuotes(payload.searchTerm) + '%\'';
        }   

        if(payload.statuses != null && !payload.statuses.isEmpty()) {

            String statuses = '(\'' + String.join(payload.statuses, '\', \'') + '\')';


            queryFilters += ' AND Status__c IN ' + statuses;
        }

        return queryFilters;
    }

    public class RecommendationPayload extends Utilities.DataTablePayload {
        @AuraEnabled 
        public String contentOrg { get; set; }
        @AuraEnabled
        public String program { get; set; }   
        @AuraEnabled
        public String expirationDate { get; set; }
        @AuraEnabled
        public List<String> statuses { get; set; }
        @AuraEnabled
        public String ouLeader {get; set;}
    }

    public class RecommendedLearnersException extends Exception {}
}