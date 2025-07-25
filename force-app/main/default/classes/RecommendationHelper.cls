/**
 * Helper Class for Recommended Learning (Recommended_Learning__c, Recommended_Audience__c & Recommendation_Activity__c)
 */
public with sharing class RecommendationHelper {
    /**
     * Batch Threshold for Audience_Member__c records
     */
    public static final Integer BATCH_THRESHOLD = 300;

    /**
     * Defines the Default Value for new Recommended_Learning__c records
     */
    public static final String DEFAULT_RECOMMENDATION_STATUS = 'Active';

    /**
     * Valid Content SObjects with Recommendations
     */
    public static final Set<String> VALID_CONTENT_RECORD_TYPES {
        get {
            return new Set<String>{ Curriculum__c.getSObjectType() + '', Course__c.getSObjectType() + '', Asset__c.getSObjectType() + '', Session__c.getSObjectType() + '' };
        }        
    }

    public static String contentOrg { get; set; }

    public static Map<Id, Recommended_Learning__c> existingRecommendedLearningsByLearnerId = new Map<Id, Recommended_Learning__c>();
    public static Map<Id, List<Recommended_Learning__c>> recommendedLearningsToInsertByLearnerId = new Map<Id, List<Recommended_Learning__c>>();
    public static List<Recommended_Learning__c> recommendedLearningsToUpdate = new List<Recommended_Learning__c>();
    public static List<Recommended_Audience__c> recommendedAudiencesToInsert = new List<Recommended_Audience__c>();
    public static List<Recommendation_Activity__c> recommendedActivityToInsert = new List<Recommendation_Activity__c>();
    public static Set<String> duplicateRecommendationKeys = new Set<String>();
    public static Map<Id, Recommended_Audience__c> recommendedAudiencesWithNewLearnersByLearnerId = new Map<Id, Recommended_Audience__c>();
    public static List<Database.UpsertResult> recommendationResults = new List<Database.UpsertResult>();

    /**
     * Creates Recommendations for a piece of Content based on a List of Audience Ids.
     */
    public static Id addAudiencesToContent(Id contentId, List<Id> audienceIds, String contentOrgIn, String programId, String expirationDate, String ouLeader) {
        contentOrg = contentOrgIn;

        String contentRecordType = contentId.getSObjectType() + '';

        if (!VALID_CONTENT_RECORD_TYPES.contains(contentRecordType)) {
            throw new RecommendedLearningException('Adding Recommended Learning from Invalid SObject Record Page: ' + contentRecordType);
        }

        Map<Id, Recommended_Audience__c> existingRecommendedAudiencesByAudienceId = new Map<Id, Recommended_Audience__c>();

        for (Recommended_Audience__c recommendedAudience : getRecommendedAudiencesFromContentId(contentId, audienceIds)) {
            // reset the content-org if its changed
            if(recommendedAudience.Content_Distribution_Organization__c != contentOrgIn && String.isNotBlank(contentOrgIn)) {
                recommendedAudience.Content_Distribution_Organization__c = contentOrgIn;
            }
            existingRecommendedAudiencesByAudienceId.put(recommendedAudience.Audience__c, recommendedAudience);
        }

        // Create Audience Recommendations
        for (Id audienceId : audienceIds) {
            // Log Creation Attempt if Exisitng Audience
            if (existingRecommendedAudiencesByAudienceId.keyset().contains(audienceId)) {
                addActivity(existingRecommendedAudiencesByAudienceId.get(audienceId), 'Recommended Audience Created', 'Recommendation Already Exists, Creation Skipped');
                continue;
            }

            // Create New Recommended Audience
            Recommended_Audience__c newRecommendedAudience = new Recommended_Audience__c(Audience__c = audienceId, Content_Distribution_Organization__c = contentOrg, Enablement_Learning_Program__c = programId);
            newRecommendedAudience.put(contentRecordType, contentId);

            recommendedAudiencesToInsert.add(newRecommendedAudience);

            addActivity(newRecommendedAudience, 'Recommended Audience Created');
        }

        // Create Learner Recommendations
        Map<Id, List<Id>> learnerIdsByAudienceId = new Map<Id, List<Id>>();

        // Start Batch if over 1000 Audience Members
        if ([SELECT COUNT() FROM Audience_Member__c WHERE Audience__c IN :audienceIds WITH USER_MODE] > Utilities.BATCH_THRESHOLD) {
            RecommendedLearners.RecommendationPayload batchPayload = new RecommendedLearners.RecommendationPayload();
            batchPayload.recordId = contentId;
            batchPayload.idsToProcess = audienceIds;
            batchPayload.contentOrg = contentOrg;
            batchPayload.expirationDate = expirationDate;

            return Database.executeBatch(new RecommendationsCreateBatch(batchPayload), 1000);
        }

        for (Audience_Member__c audienceMember : [SELECT Id, Learner_Profile__c, Audience__c FROM Audience_Member__c WHERE Audience__c IN :audienceIds WITH USER_MODE]) {
            if (!learnerIdsByAudienceId.containsKey(audienceMember.Audience__c)) {
                learnerIdsByAudienceId.put(audienceMember.Audience__c, new List<Id>{ audienceMember.Learner_Profile__c });
            } else {
                learnerIdsByAudienceId.get(audienceMember.Audience__c).add(audienceMember.Learner_Profile__c);
            }
        }

        if (!learnerIdsByAudienceId.isEmpty()) {
            // Map Recommended Audiences where Learners were added to their associated Learner Ids 
            Map<Id, Recommended_Audience__c> recommendedAudiencesByAudienceId = new Map<Id, Recommended_Audience__c>();

            for (Recommended_Audience__c recommendedAudience : recommendedAudiencesToInsert) {
                if (learnerIdsByAudienceId.containsKey(recommendedAudience.Audience__c)) {
                    for (Id learnerId : learnerIdsByAudienceId.get(recommendedAudience.Audience__c)) {
                        recommendedAudiencesWithNewLearnersByLearnerId.put(learnerId, recommendedAudience);
                    }
                }
            }

            for (Id audienceId : learnerIdsByAudienceId.keySet()) {
                addLearnersToContent(contentId, learnerIdsByAudienceId.get(audienceId), contentOrg, audienceId, programId, expirationDate, ouLeader);
            }
        }

        return null;
    }

    /**
     * Creates Recommendations for an Audience based on a List of Content Ids.
     */
    public static Id addContentToAudience(Id audienceId, List<Id> contentIds, String contentOrgIn, String programId, String expirationDate, String ouLeader) {
        contentOrg = contentOrgIn;

        String audienceRecordType = audienceId.getSObjectType() + '';

        if (!audienceRecordType.equals(Audience__c.getSObjectType() + '')) {
            throw new RecommendedLearningException('Adding Recommended Learning from Invalid SObject Record Page: ' + audienceRecordType);
        }

        Map<Id, Recommended_Audience__c> existingRecommendedAudiencesByContentId = new Map<Id, Recommended_Audience__c>();

        for (Recommended_Audience__c recommendedAudience : getRecommendedAudiencesFromContentIds(contentIds, audienceId)) {
            // reset the content-org if its changed
            if(recommendedAudience.Content_Distribution_Organization__c != contentOrgIn && String.isNotBlank(contentOrgIn)) {
                recommendedAudience.Content_Distribution_Organization__c = contentOrgIn;
            }
            if (recommendedAudience.Curriculum__c != null) {
                existingRecommendedAudiencesByContentId.put(recommendedAudience.Curriculum__c, recommendedAudience);
            } else if (recommendedAudience.Course__c != null) {
                existingRecommendedAudiencesByContentId.put(recommendedAudience.Course__c, recommendedAudience);
            } else if (recommendedAudience.Asset__c != null) {
                existingRecommendedAudiencesByContentId.put(recommendedAudience.Asset__c, recommendedAudience);
            }
        }

        // Create Audience Recommendations
        for (Id contentId : contentIds) {
            // Log Creation Attempt if Exisitng Audience
            if (existingRecommendedAudiencesByContentId.keyset().contains(contentId)) {
                addActivity(existingRecommendedAudiencesByContentId.get(contentId), 'Recommended Audience Created', 'Recommendation Already Exists, Creation Skipped');
                continue;
            }

            // Create New Recommended Audience
            Recommended_Audience__c newRecommendedAudience = new Recommended_Audience__c(Audience__c = audienceId, Content_Distribution_Organization__c = contentOrg, Enablement_Learning_Program__c = programId, OU_Leader__c = String.isEmpty(ouLeader) ? null : ouLeader);
            newRecommendedAudience.put(contentId.getSObjectType() + '', contentId);

            recommendedAudiencesToInsert.add(newRecommendedAudience);

            addActivity(newRecommendedAudience, 'Recommended Audience Created');
        }

        Integer audienceMemberCount = [SELECT COUNT() FROM Audience_Member__c WHERE Audience__c = :audienceId WITH USER_MODE];

        if (audienceMemberCount * contentIds.size() > Utilities.BATCH_THRESHOLD) {
            // Create Learner Recommendations
            RecommendedLearners.RecommendationPayload batchPayload = new RecommendedLearners.RecommendationPayload();
            batchPayload.recordId = audienceId;
            batchPayload.idsToProcess = contentIds;
            batchPayload.contentOrg = contentOrg;
            batchPayload.expirationDate = expirationDate;
            batchPayload.ouLeader = ouLeader;
            performDml();

            return Database.executeBatch(new RecommendationsCreateBatch(batchPayload), 1000);
        }

        List<Id> learnerIds = new List<Id>();

        for (Audience_Member__c audienceMember : [SELECT Id, Learner_Profile__c FROM Audience_Member__c WHERE Audience__c = :audienceId WITH USER_MODE]) {
            learnerIds.add(audienceMember.Learner_Profile__c);
        }

        if (!learnerIds.isEmpty()) {
            addLearnersToContent(contentIds, learnerIds, contentOrg, audienceId, programId, expirationDate, ouLeader);
        }
        
        return null;
    }

    /**
     * Adds Content to Learners based on Audience_Member__c records. Called from RecommendationsCreateBatch
     */
    public static void addContentToLearners(List<Audience_Member__c> audienceMembers, List<Id> contentIds, String contentOrgIn, String expirationDate, String ouLeader) {
        contentOrg = contentOrgIn;

        Map<Id, List<Id>> learnerIdsByAudienceId = new Map<Id, List<Id>>();

        for (Audience_Member__c audienceMember : audienceMembers) {
            if (!learnerIdsByAudienceId.containsKey(audienceMember.Audience__c)) {
                learnerIdsByAudienceId.put(audienceMember.Audience__c, new List<Id>{ audienceMember.Learner_Profile__c });
            } else {
                learnerIdsByAudienceId.get(audienceMember.Audience__c).add(audienceMember.Learner_Profile__c);
            }
        }

        for (Id audienceId : learnerIdsByAudienceId.keySet()) {
            addLearnersToContent(contentIds, learnerIdsByAudienceId.get(audienceId), contentOrg, audienceId, null, expirationDate, ouLeader); 
        }

        performDml();
    }

    public static void addLearnersToContent(Id contentId, List<Id> learnerIds, String contentOrgIn, String expirationDate, String ouLeader) {
        addLearnersToContent(contentId, learnerIds, contentOrgIn, null, null, expirationDate, ouLeader);
    }

    public static void addLearnersToContent(Id contentId, List<Id> learnerIds, String contentOrgIn, Id programId, String expirationDate, String ouLeader) {
        addLearnersToContent(contentId, learnerIds, contentOrgIn, null, programId, expirationDate, ouLeader);
    }

    // public static void addLearnersToContent(Id contentId, List<Id> learnerIds, String contentOrgIn, Id audienceId, Id programId, String expirationDate, String ouLeader) {
    //     addLearnersToContent(contentId, learnerIds, contentOrgIn, audienceId, programId, expirationDate, ouLeader);
    // }

    // public static void addLearnersToContent(List<Id> contentIds, List<Id> learnerIds, String contentOrgIn, Id audienceId, String programId, String expirationDate, String ouLeader) {
    //     addLearnersToContent(contentIds, learnerIds, contentOrgIn, audienceId, programId, expirationDate, ouLeader);
    // }
    
    public static void addLearnersToContent(Id contentId, List<Id> learnerIds, String contentOrgIn, Id audienceId, Id programId, String expirationDate, String ouLeader) {
        contentOrg = contentOrgIn;

        for (Recommended_Learning__c recommendedLearning : getRecommendedLearningsFromContentId(contentId, learnerIds)) {
            // reset the content-org if its changed
            if(recommendedLearning.Content_Distribution_Organization__c != contentOrgIn && String.isNotBlank(contentOrgIn)) {
                recommendedLearning.Content_Distribution_Organization__c = contentOrgIn;
            }
            Date newDate = String.isNotBlank(expirationDate) ? Date.valueOf(expirationDate) : null;
            // reset expiration date is it changed
            if(newDate != null && recommendedLearning.Expiration_Date__c != newDate) {
                recommendedLearning.Expiration_Date__c = newDate;
            }
            existingRecommendedLearningsByLearnerId.put(recommendedLearning.Learner_Profile__c, recommendedLearning);
        }

        String contentRecordType = contentId.getSObjectType() + '';

        if (!VALID_CONTENT_RECORD_TYPES.contains(contentRecordType)) {
            throw new RecommendedLearningException('Adding Recommended Learning from Invalid SObject Record Page: ' + contentRecordType);
        }

        Boolean isAllowedDupe = getIsDupeAllowed(contentId);
        Set<String> openAssignmentKeys = new Set<String>();

        // Can create duplicate recommendations for previously completed events with no open assignments
        if (isAllowedDupe) {
            openAssignmentKeys.addAll(getOpenAssignmentKeys(contentId, learnerIds));
        }

        System.debug('******************** isAllowedDupe ' + isAllowedDupe);
        System.debug('******************** openAssignmentKeys ' + openAssignmentKeys);

        Set<String> learnerKeysToCreate = new Set<String>();

        for (Id learnerId : learnerIds) {
            String key = getRecommendationKey(learnerId, contentId);

            // Log Creation Attempt if Exisitng Learning that isn't a Non-Completed Event
            if (existingRecommendedLearningsByLearnerId.keyset().contains(learnerId)) {
                Recommended_Learning__c existingRecommendedLearning = existingRecommendedLearningsByLearnerId.get(learnerId);

                if ((!isAllowedDupe || openAssignmentKeys.contains(key))) {
                    if (contentOrg.equals('SEED')) {
                        existingRecommendedLearning.Content_Distribution_Organization__c = 'SEED';
                        recommendedLearningsToUpdate.add(existingRecommendedLearning);
                    }
                    
                    if (existingRecommendedLearning.Status__c == 'Inactive') {
                        updateLearnerStatus(new List<Id>{ learnerId }, 'Active');
                    } else {
                        addActivity(existingRecommendedLearning, 'Recommended Learning Created', 'Recommendation Already Exists, Creation Skipped');
                    }
    
                    continue;
                } else {
                    duplicateRecommendationKeys.add(key);
                }
            }

            learnerKeysToCreate.add(key);
        }

        Map<String, Recommended_Learning__c> duplicateDisallowedByKey = new Map<String, Recommended_Learning__c>();
        Set<String> duplicateDisllowedStatuses = new Set<String>{ 'Active', 'Inactive', 'Learning Assigned' };

        for (Recommended_Learning__c recommendedLearning : [SELECT Id, Learner_Profile__c, Curriculum__c, Course__c, Asset__c, Status__c, Session__c 
                                                            FROM Recommended_Learning__c 
                                                            WHERE Key__c IN :duplicateRecommendationKeys 
                                                            AND Status__c IN :duplicateDisllowedStatuses
                                                            WITH USER_MODE]) {

            duplicateDisallowedByKey.put(getRecommendationKey(recommendedLearning), recommendedLearning);
        }

        for (String key : learnerKeysToCreate) {
            Id learnerId = key.split('-')[0];

            // Prevent disallowed duplicate recommendations
            if (duplicateRecommendationKeys.contains(key) && duplicateDisallowedByKey.containsKey(key)) {
                Recommended_Learning__c existingRecommendedLearning = duplicateDisallowedByKey.get(key);

                if (contentOrg.equals('SEED')) {
                    existingRecommendedLearning.Content_Distribution_Organization__c = 'SEED';
                    recommendedLearningsToUpdate.add(existingRecommendedLearning);
                }
                
                if (existingRecommendedLearning.Status__c == 'Inactive') {
                    updateLearnerStatus(new List<Id>{ learnerId }, 'Active');
                } else {
                    addActivity(existingRecommendedLearning, 'Recommended Learning Created', 'Recommendation Already Exists, Creation Skipped');
                }

                continue;
            }
            
            // Create Recommended Learning
            Recommended_Learning__c newRecommendedLearning = new Recommended_Learning__c(
                Learner_Profile__c = learnerId, 
                Status__c = DEFAULT_RECOMMENDATION_STATUS,
                Audience__c = audienceId,
                Content_Distribution_Organization__c = contentOrg, // added for CDO change,
                Enablement_Learning_Program__c = programId,
                OU_Leader__c = String.isEmpty(ouLeader) ? null : ouLeader
            );

            if(String.isNotBlank(expirationDate)) {
                newRecommendedLearning.Expiration_Date__c = Date.valueOf(expirationDate);
            }  
            
            newRecommendedLearning.put(contentRecordType, contentId);

            if (recommendedLearningsToInsertByLearnerId.containsKey(learnerId)) {
                recommendedLearningsToInsertByLearnerId.get(learnerId).add(newRecommendedLearning);
            } else {
                recommendedLearningsToInsertByLearnerId.put(learnerId, new List<Recommended_Learning__c>{ newRecommendedLearning });
            }

            addActivity(newRecommendedLearning, 'Recommended Learning Created');
        }
    }

    public static void addLearnersToContent(List<Id> contentIds, List<Id> learnerIds, String contentOrgIn, Id audienceId, String programId, String expirationDate, String ouLeader) {
        contentOrg = contentOrgIn;

        for (Id contentId : contentIds) {
            String contentRecordType = contentId.getSObjectType() + '';

            if (!VALID_CONTENT_RECORD_TYPES.contains(contentRecordType)) {
                throw new RecommendedLearningException('Adding Recommended Learning from Invalid SObject Record Page: ' + contentRecordType);
            }
        }

        for (Recommended_Learning__c recommendedLearning : getRecommendedLearningsFromContentIds(contentIds, learnerIds)) {
            // reset the content-org if its changed
            if(recommendedLearning.Content_Distribution_Organization__c != contentOrgIn && String.isNotBlank(contentOrgIn)) {
                recommendedLearning.Content_Distribution_Organization__c = contentOrgIn;
            }
            Date newDate = String.isNotBlank(expirationDate) ? Date.valueOf(expirationDate) : null;
            // reset expiration date is it changed
            if(newDate != null && recommendedLearning.Expiration_Date__c != newDate) {
                recommendedLearning.Expiration_Date__c = newDate;
            }
            existingRecommendedLearningsByLearnerId.put(recommendedLearning.Learner_Profile__c, recommendedLearning);
        }

        Set<Id> allowedDupeIds = getAllowedDupeIds(contentIds);
        Set<String> openAssignmentKeys = new Set<String>();

        // Can create duplicate recommendations for previously completed events with no open assignments
        if (!allowedDupeIds.isEmpty()) {
            openAssignmentKeys.addAll(getOpenAssignmentKeys(contentIds, learnerIds));
        }

        Set<String> learnerKeysToCreate = new Set<String>();

        for (Id learnerId : learnerIds) {
            for (Id contentId : contentIds) {
                String key = getRecommendationKey(learnerId, contentId);
                Boolean isAllowedDupe = allowedDupeIds.contains(contentId);
                String contentRecordType = contentId.getSObjectType() + '';

                // Log Creation Attempt if Exisitng Learning and isn't a Non-Completed Event
                if (existingRecommendedLearningsByLearnerId.keyset().contains(learnerId)) {
                    Recommended_Learning__c existingRecommendedLearning = existingRecommendedLearningsByLearnerId.get(learnerId);

                    if ((!isAllowedDupe || openAssignmentKeys.contains(key))) {
                        if (contentOrg.equals('SEED')) {
                            existingRecommendedLearning.Content_Distribution_Organization__c = 'SEED';
                            recommendedLearningsToUpdate.add(existingRecommendedLearning);
                        }

                        if (existingRecommendedLearning.Status__c == 'Inactive') {
                            updateLearnerStatus(new List<Id>{ learnerId }, 'Active');
                        } else { 
                            addActivity(existingRecommendedLearning, 'Recommended Learning Created', 'Recommendation Already Exists, Creation Skipped');
                        }

                        continue;
                    } else {
                        duplicateRecommendationKeys.add(key);
                    }
                }

                learnerKeysToCreate.add(key);
            }
        }

        Map<String, Recommended_Learning__c> duplicateDisallowedByKey = new Map<String, Recommended_Learning__c>();
        Set<String> duplicateDisllowedStatuses = new Set<String>{ 'Active', 'Inactive', 'Learning Assigned' };

        for (Recommended_Learning__c recommendedLearning : [SELECT Id, Learner_Profile__c, Curriculum__c, Course__c, Asset__c, Status__c 
                                                            FROM Recommended_Learning__c 
                                                            WHERE Key__c IN :duplicateRecommendationKeys 
                                                            AND Status__c IN :duplicateDisllowedStatuses
                                                            WITH USER_MODE]) {

            duplicateDisallowedByKey.put(getRecommendationKey(recommendedLearning), recommendedLearning);
        }

        for (String key : learnerKeysToCreate) {
            Id learnerId = key.split('-')[0];
            Id contentId = key.split('-')[1];

            if (learnerId == null || contentId == null) {
                continue;
            }
            
            String contentRecordType = contentId.getSObjectType() + '';

            // Prevent disallowed duplicate recommendations
            if (duplicateRecommendationKeys.contains(key) && duplicateDisallowedByKey.containsKey(key)) {
                Recommended_Learning__c existingRecommendedLearning = duplicateDisallowedByKey.get(key);

                if (contentOrg.equals('SEED')) {
                    existingRecommendedLearning.Content_Distribution_Organization__c = 'SEED';
                    recommendedLearningsToUpdate.add(existingRecommendedLearning);
                }
                
                if (existingRecommendedLearning.Status__c == 'Inactive') {
                    updateLearnerStatus(new List<Id>{ learnerId }, 'Active');
                } else {
                    addActivity(existingRecommendedLearning, 'Recommended Learning Created', 'Recommendation Already Exists, Creation Skipped');
                }

                continue;
            }

            // Create Recommended Learning
            Recommended_Learning__c newRecommendedLearning = new Recommended_Learning__c(
                Learner_Profile__c = learnerId, 
                Status__c = DEFAULT_RECOMMENDATION_STATUS,
                Audience__c = audienceId,
                Content_Distribution_Organization__c = contentOrg, // added for CDO change
                Enablement_Learning_Program__c = programId,
                OU_Leader__c = String.isEmpty(ouLeader) ? null : ouLeader
            );
            
            if(String.isNotBlank(expirationDate)) {
                newRecommendedLearning.Expiration_Date__c = Date.valueOf(expirationDate);
            }  

            newRecommendedLearning.put(contentRecordType, contentId);

            if (recommendedLearningsToInsertByLearnerId.containsKey(learnerId)) {
                recommendedLearningsToInsertByLearnerId.get(learnerId).add(newRecommendedLearning);
            } else {
                recommendedLearningsToInsertByLearnerId.put(learnerId, new List<Recommended_Learning__c>{ newRecommendedLearning });
            }

            addActivity(newRecommendedLearning, 'Recommended Learning Created');
        }
    }

    public static void addSeedRecommendations(List<RecommendationDataCloudHelper.DataCloudRecommendation> recommendations) {
        contentOrg = 'SEED';

        List<String> keys = new List<String>();
        List<Id> contentIds = new List<Id>();
        List<Id> learnerIds = new List<Id>();
        List<Id> nudgerIds = new List<Id>();
        List<Integration_Error__c> errors = new List<Integration_Error__c>();

        for (RecommendationDataCloudHelper.DataCloudRecommendation recommendation : recommendations) {
            keys.add(recommendation.key);
            contentIds.add(recommendation.contentId);
            learnerIds.add(recommendation.learnerId);
        }

        Map<String, Recommended_Learning__c> existingRecommendedLearningsByKey = new Map<String, Recommended_Learning__c>();

        for (Recommended_Learning__c recommendedLearning : [SELECT Id, Learner_Profile__c, Curriculum__c, Course__c, Asset__c, Status__c, 
                                                                   Expiration_Date__c, Nudged__c, Nudged_By__c 
                                                            FROM Recommended_Learning__c 
                                                            WHERE Key__c IN :keys WITH USER_MODE]) {
            existingRecommendedLearningsByKey.put(getRecommendationKey(recommendedLearning), recommendedLearning);
        }

        for (RecommendationDataCloudHelper.DataCloudRecommendation recommendation : recommendations) {
            Id learnerId = recommendation.learnerId;
            Id contentId = recommendation.contentId;

            if (contentId == null) {
                String errorMessage = 'Error processing Data Cloud Recommendation: No Content Id Found';
                System.debug(errorMessage);
                errors.add(new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Recommendations'));
                continue;
            }

            String contentRecordType = contentId.getSObjectType() + '';

            if (!VALID_CONTENT_RECORD_TYPES.contains(contentRecordType)) {
                String errorMessage = 'Error processing Data Cloud Recommendation: Invalid Content SObject Type: ' + contentRecordType;
                System.debug(errorMessage);
                errors.add(new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Recommendations'));
                continue;
            }

            // Log Creation Attempt if Exisitng Learning. Only doing Course recommendations from SEED
            if (existingRecommendedLearningsByKey.keyset().contains(getRecommendationKey(learnerId, contentId))) {
                Recommended_Learning__c existingRecommendedLearning = existingRecommendedLearningsByKey.get(getRecommendationKey(learnerId, contentId));

                existingRecommendedLearning.Content_Distribution_Organization__c = 'SEED';
                // existingRecommendedLearning.From_FLM__c = recommendation.flmPush;
                recommendedLearningsToUpdate.add(existingRecommendedLearning);

                if(recommendation.isNudge){
                    Date newExpiration = existingRecommendedLearning.Expiration_Date__c == null ? Date.today().addDays(30) : existingRecommendedLearning.Expiration_Date__c.addDays(30);
                    existingRecommendedLearning.Nudged__c = true;
                    existingRecommendedLearning.Expiration_Date__c = newExpiration;
                    existingRecommendedLearning.Nudged_By__c = recommendation.nudgerId;
                }

                if (existingRecommendedLearning.Status__c == 'Inactive') {
                    updateLearnerStatus(new List<Id>{ learnerId }, 'Active');
                } else {
                    if(recommendation.isNudge){
                        addActivity(existingRecommendedLearning, 'Recommended Learning Created', 'Recomendation Learning was nudged', recommendation.nudgerId);
                    } else {
                        addActivity(existingRecommendedLearning, 'Recommended Learning Created', 'Recommendation Already Exists, Creation Skipped', recommendation.nudgerId);
                    }
                }

                continue;
            }

            // Create Recommended Learning
            Recommended_Learning__c newRecommendedLearning = new Recommended_Learning__c(
                Learner_Profile__c = learnerId, 
                Status__c = DEFAULT_RECOMMENDATION_STATUS,
                Content_Distribution_Organization__c = contentOrg,
                Nudged__c = recommendation.isNudge,
                Nudged_By__c = recommendation.nudgerId,
                SEED_Source__c = recommendation.recommendationType
                // From_FLM__c = recommendation.flmPush
            );
            
            newRecommendedLearning.put(contentRecordType, contentId);

            if (recommendedLearningsToInsertByLearnerId.containsKey(learnerId)) {
                recommendedLearningsToInsertByLearnerId.get(learnerId).add(newRecommendedLearning);
            } else {
                recommendedLearningsToInsertByLearnerId.put(learnerId, new List<Recommended_Learning__c>{ newRecommendedLearning });
            }

            addActivity(newRecommendedLearning, 'Recommended Learning Created', null, recommendation.nudgerId);

            // Add recommendation to existing list to prevent duplicates
            existingRecommendedLearningsByKey.put(getRecommendationKey(newRecommendedLearning), newRecommendedLearning);
        }

        RecommendationHelper.performDml();

        for (Database.UpsertResult result : recommendationResults) {
            if (!result.isSuccess()) {
                // Compile error message string from result errors
                String errorMessage = '';
                for (Database.Error error : result.getErrors()) {
                    errorMessage += error.getMessage() + '\n';
                }

                // Create integration error
                errors.add(new Integration_Error__c(Error_Message__c = errorMessage.left(255), Type__c = 'Data Cloud Recommendations'));
            }
        }

        if (!errors.isEmpty()) {
            Database.insert(errors, System.AccessLevel.USER_MODE);
        }
    }


    public static void updateRecommendationStatus(List<Id> recommendedLearningIds, String status) {
        for (Recommended_Learning__c recommendedLearning : [SELECT Id, Learner_Profile__c, Curriculum__c, Course__c, Asset__c, Session__c, Status__c FROM Recommended_Learning__c WHERE Id IN :recommendedLearningIds AND Status__c != 'Inactive' WITH USER_MODE]) {
            existingRecommendedLearningsByLearnerId.put(recommendedLearning.Learner_Profile__c, recommendedLearning);
        }

        updateLearnerStatus(new List<Id>(existingRecommendedLearningsByLearnerId.keySet()), status);
        performDml();
    }

    public static void updateLearnerStatus(Id contentId, List<Recommended_Learning__c> recommendedLearnings, String status) {
        for (Recommended_Learning__c recommendedLearning : recommendedLearnings) {
            existingRecommendedLearningsByLearnerId.put(recommendedLearning.Learner_Profile__c, recommendedLearning);
        }

        updateLearnerStatus(new List<Id>(existingRecommendedLearningsByLearnerId.keySet()), status);
        performDml();
    }

    public static void updateLearnerStatus(Id contentId, List<Id> learnerIds, String status) {
        for (Recommended_Learning__c recommendedLearning : getRecommendedLearningsFromContentId(contentId, learnerIds)) {
            existingRecommendedLearningsByLearnerId.put(recommendedLearning.Learner_Profile__c, recommendedLearning);
        }

        updateLearnerStatus(learnerIds, status);
    }

    public static void updateLearnerStatus(List<Id> learnerIds, String status) {
        String statusMessage = '';

        switch on status {
            when 'Active' {
                statusMessage = 'Recommended Learning Created';
            }
            when 'Learning Assigned' {
                statusMessage = 'Recommended Learning Assigned';
            }
            when 'Learning Completed' {
                statusMessage = 'Recommended Learning Completed';
            }
            when 'Inactive' {
                statusMessage = 'Recommended Learning Deactivated';
            }
        }

        for (Id learnerId : learnerIds) {
            if (existingRecommendedLearningsByLearnerId.keyset().contains(learnerId)) {

                Recommended_Learning__c recommendedLearningToUpdate = existingRecommendedLearningsByLearnerId.get(learnerId);

                Boolean alreadyUpdating = false;

                for (Recommended_Learning__c recommendedLearning : recommendedLearningsToUpdate) {
                    if (recommendedLearningToUpdate.Id == recommendedLearning.Id) {
                        recommendedLearningToUpdate = recommendedLearning;
                        alreadyUpdating = true;
                        break;
                    }
                }

                if (status.equals('Inactive') && !recommendedLearningToUpdate.Status__c.equals('Active')) {
                    addActivity(
                        recommendedLearningToUpdate, 
                        statusMessage, 
                        'Not Completed, Current Status is ' + recommendedLearningToUpdate.Status__c + ', Only Active Recommendations can be Deactivated'
                    );

                    continue;
                }

                // Assigned Content is Deleted, Recommendation reactivated
                if (status.equals('Active') && recommendedLearningToUpdate.Status__c.equals('Learning Assigned') || recommendedLearningToUpdate.Status__c.equals('Learning Completed') ) {
                    statusMessage = 'Assigned Learning Deleted';
                }

                recommendedLearningToUpdate.Status__c = status;

                if (!alreadyUpdating) {
                    recommendedLearningsToUpdate.add(recommendedLearningToUpdate);
                }

                addActivity(recommendedLearningToUpdate, statusMessage);
            }
        }
    }

    public static void performDml() {
        if (!recommendedAudiencesToInsert.isEmpty()) {
            Database.insert(recommendedAudiencesToInsert, System.AccessLevel.SYSTEM_MODE);
        }
        
        Set<String> upsertedRecommendations = new Set<String>();

        if (!recommendedLearningsToInsertByLearnerId.isEmpty()) {
            List<Recommended_Learning__c> recommendedLearningsToInsert = new List<Recommended_Learning__c>();

            for (List<Recommended_Learning__c> recommendedLearnings : recommendedLearningsToInsertByLearnerId.values()) {
                recommendedLearningsToInsert.addAll(recommendedLearnings);
            }

            RecommendationListWrapper recommendationList = new RecommendationListWrapper(recommendedLearningsToInsert);
            recommendationResults = Database.upsert(getDefaultStatus(recommendationList), false, System.AccessLevel.SYSTEM_MODE);
            
            // Update Assigned Content Lookups
            recommendationList.updateAssignmentLookups();

            // Store Upserted Recommendations to prevent duplicates
            upsertedRecommendations.addAll(recommendationList.recommendedLearningsByKey.keySet());
        }

        if (!recommendedLearningsToUpdate.isEmpty()) {
            Map<String, Recommended_Learning__c> recommendedLearningsToUpdateByKey = new Map<String, Recommended_Learning__c>();
            
            for (Recommended_Learning__c recommendation : recommendedLearningsToUpdate) {
                if (!upsertedRecommendations.contains(getRecommendationKey(recommendation))) {
                    recommendedLearningsToUpdateByKey.put(getRecommendationKey(recommendation), recommendation);
                }
            }

            Database.update(recommendedLearningsToUpdateByKey.values(), System.AccessLevel.SYSTEM_MODE);
        }

        if (!recommendedActivityToInsert.isEmpty()) {
            for (Recommendation_Activity__c activity : recommendedActivityToInsert) {
                if (activity.Recommended_Learning__r != null) {
                    activity.Recommended_Learning__c = activity.Recommended_Learning__r.Id;
                    activity.Recommended_Learning__r = null;
                }

                if (activity.Recommended_Audience__r != null) {
                    activity.Recommended_Audience__c = activity.Recommended_Audience__r.Id;
                    activity.Recommended_Audience__r = null;
                }
            }

            upsert recommendedActivityToInsert;
        }
    }

    public static List<Recommended_Learning__c> getDefaultStatus(RecommendationListWrapper recommendationList) {
        for (Assigned_Curriculum__c assignedCurriculum : recommendationList.assignedCurriculums) {
            if (assignedCurriculum.Completed__c) {
                recommendationList.recommendedLearningsByKey.get(getRecommendationKey(assignedCurriculum)).Status__c = 'Learning Completed';
            } else {
                recommendationList.recommendedLearningsByKey.get(getRecommendationKey(assignedCurriculum)).Status__c = 'Learning Assigned';
            }
        }

        for (Assigned_Course__c assignedCourse : recommendationList.assignedCourses) {
            if (assignedCourse.Completed__c) {
                recommendationList.recommendedLearningsByKey.get(getRecommendationKey(assignedCourse)).Status__c = 'Learning Completed';
            } else {
                recommendationList.recommendedLearningsByKey.get(getRecommendationKey(assignedCourse)).Status__c = 'Learning Assigned';
            }
        }

        for (Assignment__c assignment : recommendationList.assignments) {
            if (assignment.Completed__c) {
                recommendationList.recommendedLearningsByKey.get(getRecommendationKey(assignment)).Status__c = 'Learning Completed';
            } else {
                recommendationList.recommendedLearningsByKey.get(getRecommendationKey(assignment)).Status__c = 'Learning Assigned';
            }
        }

        for(Assigned_Session__c aSession : recommendationList.assignedSessions){
            if(aSession.Status__c == 'Attended'){
                recommendationList.recommendedLearningsByKey.get(getRecommendationKey(aSession)).Status__c = 'Learning Completed';
            } else {
                recommendationList.recommendedLearningsByKey.get(getRecommendationKey(aSession)).Status__c = 'Learning Assigned';
            }
        }

        return recommendationList.recommendedLearningsByKey.values();
    }

    public static List<Recommended_Learning__c> getRecommendedLearningsFromContentId(Id contentRecordId, List<Id> learnerIds) {
        return  getRecommendedLearningsFromContentId(contentRecordId, learnerIds, new Set<String>{ 'Id', 'Status__c', 'Learner_Profile__c', 'Audience__c', 'Curriculum__c', 'Course__c', 'Asset__c', 'Session__c', 'Expiration_Date__c', 'Content_Distribution_Organization__c' });
    }
 
    public static List<Recommended_Learning__c> getRecommendedLearningsFromContentId(Id contentRecordId, List<Id> learnerIds, Set<String> fieldsToQuery) {
        String contentObjectType = contentRecordId.getSObjectType() + '';

        if (!VALID_CONTENT_RECORD_TYPES.contains(contentObjectType)) {
            throw new RecommendedLearningException('Fetching Recommended Learning from Invalid SObject Record Page: ' + contentObjectType);
        }

        String query = 'SELECT ' + String.join(fieldsToQuery, ',') + ' FROM Recommended_Learning__c WHERE ' + contentObjectType + ' = :contentRecordId';
        query += ' AND Learner_Profile__c IN :learnerIds';

        return Database.query(query, System.AccessLevel.USER_MODE);
    }

    public static List<Recommended_Learning__c> getRecommendedLearningsFromContentIds(List<Id> contentIds, List<Id> learnerIds) {
        return  getRecommendedLearningsFromContentIds(contentIds, learnerIds, new Set<String>{ 'Id', 'Status__c', 'Learner_Profile__c', 'Audience__c', 'Curriculum__c', 'Course__c', 'Asset__c', 'Session__c', 'Expiration_Date__c', 'Content_Distribution_Organization__c' });
    }

    public static List<Recommended_Learning__c> getRecommendedLearningsFromContentIds(List<Id> contentIds, List<Id> learnerIds, Set<String> fieldsToQuery) {
        for (Id contentId : contentIds) {
            String contentObjectType = contentId.getSObjectType() + '';

            if (!VALID_CONTENT_RECORD_TYPES.contains(contentObjectType)) {
                throw new RecommendedLearningException('Fetching Recommended Learning from Invalid SObject Record Page: ' + contentObjectType);
            }
        }

        String query = 'SELECT ' + String.join(fieldsToQuery, ',') + ' FROM Recommended_Learning__c WHERE (Curriculum__c IN :contentIds OR Course__c IN :contentIds OR Asset__c IN :contentIds)';
        query += ' AND Learner_Profile__c IN :learnerIds';

        return Database.query(query, System.AccessLevel.USER_MODE);
    }

    public static List<Recommended_Audience__c> getRecommendedAudiencesFromContentId(Id contentRecordId, List<Id> audienceIds) {
       return  getRecommendedAudiencesFromContentId(contentRecordId, audienceIds, new Set<String>{ 'Id', 'Audience__c', 'Curriculum__c', 'Course__c', 'Asset__c', 'Content_Distribution_Organization__c', 'Enablement_Learning_Program__c', 'Enablement_Learning_Program__r.Name' });
    }

    public static List<Recommended_Audience__c> getRecommendedAudiencesFromContentId(Id contentRecordId, List<Id> audienceIds, Set<String> fieldsToQuery) {
        String query = 'SELECT ' + String.join(fieldsToQuery, ',') + ' FROM Recommended_Audience__c WHERE ' + contentRecordId.getSobjectType() + ' = :contentRecordId';
        query += ' AND Audience__c IN :audienceIds';

        return Database.query(query, System.AccessLevel.USER_MODE);
    }

    public static List<Recommended_Audience__c> getRecommendedAudiencesFromContentIds(List<Id> contentIds, Id audienceId) {
        return  getRecommendedAudiencesFromContentIds(contentIds, audienceId, new Set<String>{ 'Id', 'Audience__c', 'Curriculum__c', 'Course__c', 'Asset__c', 'Content_Distribution_Organization__c', 'Enablement_Learning_Program__c', 'Enablement_Learning_Program__r.Name' });
    }

    public static List<Recommended_Audience__c> getRecommendedAudiencesFromContentIds(List<Id> contentIds, Id audienceId, Set<String> fieldsToQuery) {
        String query = 'SELECT ' + String.join(fieldsToQuery, ',') + ' FROM Recommended_Audience__c WHERE (Curriculum__c IN :contentIds OR Course__c IN :contentIds OR Asset__c IN :contentIds)';
        query += ' AND Audience__c = :audienceId';

        return Database.query(query, System.AccessLevel.USER_MODE);
    }

    public static String getRecommendationKey(Id learnerId, Id contentId) {
        return learnerId.to15() + '-' + contentId.to15();
    }

    public static String getRecommendationKey(SObject record) {
        String key = '';
        String objType = record.getSObjectType() + '';
        
        if (String.isNotEmpty(String.valueOf(record.get('Learner_Profile__c')))) {
            key += ((Id)(record.get('Learner_Profile__c'))).to15();
        }
    
        key += '-';

        switch on objType {
            when 'Assigned_Curriculum__c' {
                key += ((Id)(record.get('Curriculum__c'))).to15();
            }
            when 'Assigned_Course__c' {
                key += ((Id)(record.get('Course__c'))).to15();
            }
            when 'Assignment__c' {
                key += ((Id)(record.get('Asset__c'))).to15();
            }
            when 'Assigned_Session__c'{
                key += ((Id)(record.get('Session__c'))).to15();
            }
            when 'Recommended_Learning__c' {
                if (String.isNotEmpty(String.valueOf(record.get('Curriculum__c')))) {
                    key += ((Id)record.get('Curriculum__c')).to15();
                } else if (String.isNotEmpty(String.valueOf(record.get('Course__c')))) {
                    key += ((Id)record.get('Course__c')).to15();
                } else if (String.isNotEmpty(String.valueOf(record.get('Asset__c')))) {
                    key += ((Id)record.get('Asset__c')).to15();
                } else if (String.isNotEmpty(String.valueOf(record.get('Session__c')))) {
                    key += ((Id)record.get('Session__c')).to15();
                }
            }
        }
        
        return key;
    }

    public static Boolean getIsDupeAllowed(Id contentId) {
        return !getAllowedDupeIds(new List<Id>{ contentId }).isEmpty();
    }

    public static Set<Id> getAllowedDupeIds(List<Id> contentIds) {
        List<String> allowedDuplicates = new List<String>{ 'Event', 'Skills_Assessment' };
        Set<Id> assetIds = new Set<Id>();

        for (Id contentId : contentIds) {
            if (contentId.getSObjectType() == Asset__c.getSObjectType()) {
                assetIds.add(contentId);
            }
        }

        for (Asset__c asset : [SELECT Id FROM Asset__c WHERE Id IN :assetIds AND RecordType.DeveloperName != :allowedDuplicates WITH USER_MODE]) {
            assetIds.remove(asset.Id);
        }

        return assetIds;
    }

    public static Set<String> getOpenAssignmentKeys(Id contentId, List<Id> learnerIds) {
        return getOpenAssignmentKeys(new List<Id>{ contentId }, learnerIds);
    }

    public static Set<String> getOpenAssignmentKeys(List<Id> contentIds, List<Id> learnerIds) {
        Map<String, Assignment__c> existingAssignmentsByKey = new Map<String, Assignment__c>();
        Set<String> openAssignmentKeys = new Set<String>();

        for (Assignment__c assignment : [SELECT Id, Learner_Profile__c, Asset__c, Completed__c FROM Assignment__c 
                                         WHERE Asset__c IN :contentIds 
                                         AND Learner_Profile__c IN :learnerIds
                                         AND Inactive__c = false 
                                         WITH USER_MODE]) {
            existingAssignmentsByKey.put(getRecommendationKey(assignment), assignment);
        }

        for (Id contentId : contentIds) {
            for (Id learnerId : learnerIds) {
                String key = getRecommendationKey(learnerId, contentId);

                if (!existingAssignmentsByKey.containsKey(key) || existingAssignmentsByKey.get(key).Completed__c == false) {
                    openAssignmentKeys.add(key);
                }
            }
        }

        return openAssignmentKeys;
    }

    /**
     * Activity Helpers
     */
    
    public static void addActivity(Recommended_Audience__c recommendedAudience, String activityType) {
        addActivity(recommendedAudience, activityType, '');
    }

    public static void addActivity(Recommended_Audience__c recommendedAudience, String activityType, String detail) {
        addActivity(null, recommendedAudience, activityType, detail);
    }

    public static void addActivity(Recommended_Learning__c recommendedLearning, String activityType) {
        addActivity(recommendedLearning, activityType, '');
    }

    public static void addActivity(Recommended_Learning__c recommendedLearning, String activityType, String detail) {
        if (recommendedAudiencesWithNewLearnersByLearnerId.containsKey(recommendedLearning.Id)) {
            addActivity(recommendedLearning, recommendedAudiencesWithNewLearnersByLearnerId.get(recommendedLearning.Id), activityType, detail);
        } else {
            addActivity(recommendedLearning, null, activityType, detail, null);
        }
    }

    public static void addActivity(Recommended_Learning__c recommendedLearning, String activityType, String detail, String nudgerId) {
        addActivity(recommendedLearning, null, activityType, detail, nudgerId);
    }

    public static void addActivity(Recommended_Learning__c recommendedLearning, Recommended_Audience__c recommendedAudience, String activityType) {
        addActivity(recommendedLearning, recommendedAudience, activityType, '');
    }

    public static void addActivity(Recommended_Learning__c recommendedLearning, Recommended_Audience__c recommendedAudience, String activityType, String detail) {
        addActivity(recommendedLearning, recommendedAudience, activityType, detail, null);
    }

    public static void addActivity(Recommended_Learning__c recommendedLearning, Recommended_Audience__c recommendedAudience, String activityType, String detail, String nudgerId){
        Recommendation_Activity__c newActivity = new Recommendation_Activity__c(
            Recommended_Learning__r = recommendedLearning, 
            Recommended_Audience__r = recommendedAudience, 
            Activity_Type__c = activityType,
            Detail__c = detail
        );

        if(String.isNotEmpty(nudgerId)){
            newActivity.Nudged__c = true;
            newActivity.Nudged_By__c = nudgerId;
        }

        if (String.isNotEmpty(contentOrg) && (activityType.equals('Recommended Audience Created') || activityType.equals('Recommended Learning Created'))) {
            newActivity.put('Content_Distribution_Organization__c', contentOrg);
        }

        recommendedActivityToInsert.add(newActivity);
    }

    public with sharing class RecommendationListWrapper {
        public Map<String, Recommended_Learning__c> recommendedLearningsByKey { get; set; }
        public Set<Id> learnerIds { get; set; }
        public Set<Id> curriculumIds { get; set; }
        public Set<Id> courseIds { get; set; }
        public Set<Id> assetIds { get; set; }
        public Set<Id> sessionIds { get; set; }
        public Boolean hasCurriculum { get; set; }
        public Boolean hasCourse { get; set; }
        public Boolean hasAsset { get; set; }
        public Boolean hasSession { get; set; }
        public List<Assigned_Curriculum__c> assignedCurriculums { get; set; }
        public List<Assigned_Course__c> assignedCourses { get; set; }
        public List<Assigned_Session__c> assignedSessions { get; set; }
        public List<Assignment__c> assignments { get; set; }

        public RecommendationListWrapper() {
            this.recommendedLearningsByKey = new Map<String, Recommended_Learning__c>();
            this.learnerIds = new Set<Id>();
            this.curriculumIds = new Set<Id>();
            this.courseIds = new Set<Id>();
            this.assetIds = new Set<Id>();
            this.sessionIds = new Set<Id>();
            this.hasCurriculum = false;
            this.hasCourse = false;
            this.hasAsset = false;
            this.hasSession = false;
            this.assignedCurriculums = new List<Assigned_Curriculum__c>();
            this.assignedCourses = new List<Assigned_Course__c>();
            this.assignedSessions = new List<Assigned_Session__c>();
            this.assignments = new List<Assignment__c>();
        }

        public RecommendationListWrapper(List<Recommended_Learning__c> recommendedLearnings) {
            this();

            for (Recommended_Learning__c recommendedLearning : recommendedLearnings) {
                this.learnerIds.add(recommendedLearning.Learner_Profile__c);
                this.recommendedLearningsByKey.put(getRecommendationKey(recommendedLearning), recommendedLearning);
    
                if (String.isNotEmpty(recommendedLearning.Curriculum__c)) {
                    this.curriculumIds.add(recommendedLearning.Curriculum__c);
                    this.hasCurriculum = true;
                } else if (String.isNotEmpty(recommendedLearning.Course__c)) {
                    this.courseIds.add(recommendedLearning.Course__c);
                    this.hasCourse = true;
                } else if (String.isNotEmpty(recommendedLearning.Asset__c)) {
                    this.assetIds.add(recommendedLearning.Asset__c);
                    this.hasAsset = true;
                } else if (String.isNotEmpty(recommendedLearning.Session__c)) {
                    this.sessionIds.add(recommendedLearning.Session__c);
                    this.hasSession = true;
                }
            }

            if (this.recommendedLearningsByKey.isEmpty()) {
                return;
            }

            getAssignedCurriculums();
            getAssignedCourses();
            getAssignments();
            getAssignedSessions();
        }

        public void getAssignedCurriculums() {
            if (!this.hasCurriculum) {
                return;
            }

            for (Assigned_Curriculum__c assignedCurriculum : [SELECT Id, Completed__c, Learner_Profile__c, Curriculum__c, Recommended_Learning__c FROM Assigned_Curriculum__c 
                                                              WHERE Curriculum__c IN :this.curriculumIds 
                                                              AND Inactive__c = false
                                                              AND Learner_Profile__c IN :this.learnerIds WITH USER_MODE]) {
                if (!this.recommendedLearningsByKey.containsKey(getRecommendationKey(assignedCurriculum))) {
                    continue;
                }

                this.assignedCurriculums.add(assignedCurriculum);
            }
        }

        public void getAssignedCourses() {
            if (!this.hasCourse) {
                return;
            }

            for (Assigned_Course__c assignedCourse : [SELECT Id, Completed__c, Learner_Profile__c, Course__c, Recommended_Learning__c FROM Assigned_Course__c 
                                                      WHERE Course__c IN :this.courseIds 
                                                      AND Inactive__c = false
                                                      AND Learner_Profile__c IN :this.learnerIds WITH USER_MODE]) {
                if (!this.recommendedLearningsByKey.containsKey(getRecommendationKey(assignedCourse))) {
                    continue;
                }

                if (String.isEmpty(String.valueOf(assignedCourse.Recommended_Learning__c))) {
                    assignedCourse.Recommended_Learning__c = this.recommendedLearningsByKey.get(getRecommendationKey(assignedCourse)).Id;
                }

                this.assignedCourses.add(assignedCourse);
            }
        }

        public void getAssignments() {
            if (!this.hasAsset) {
                return;
            }

            for (Assignment__c assignment : [SELECT Id, Completed__c, Learner_Profile__c, Asset__c, Recommended_Learning__c FROM Assignment__c 
                                              WHERE Asset__c IN :this.assetIds 
                                              AND Inactive__c = false
                                              AND Learner_Profile__c IN :this.learnerIds WITH USER_MODE]) {
                if (!this.recommendedLearningsByKey.containsKey(getRecommendationKey(assignment)) || duplicateRecommendationKeys.contains(getRecommendationKey(assignment))) {
                    continue;
                }

                if (String.isEmpty(String.valueOf(assignment.Recommended_Learning__c))) {
                    assignment.Recommended_Learning__c = this.recommendedLearningsByKey.get(getRecommendationKey(assignment)).Id;
                }

                this.assignments.add(assignment);
            }
        }

        public void getAssignedSessions() {
            if (!this.hasSession) {
                return;
            }

            for (Assigned_Session__c aSession : [SELECT Id, Status__c, Learner_Profile__c, Session__c, Asset__c, Recommended_Learning__c 
                                                 FROM Assigned_Session__c 
                                                 WHERE Session__c IN :this.sessionIds 
                                                 AND Status__c != 'Unregistered'
                                                 AND Learner_Profile__c IN :this.learnerIds WITH USER_MODE]) {
                if (!this.recommendedLearningsByKey.containsKey(getRecommendationKey(aSession)) || duplicateRecommendationKeys.contains(getRecommendationKey(aSession))) {
                    continue;
                }

                if (String.isEmpty(String.valueOf(aSession.Recommended_Learning__c))) {
                    aSession.Recommended_Learning__c = this.recommendedLearningsByKey.get(getRecommendationKey(aSession)).Id;
                }

                this.assignedSessions.add(aSession);
            }
        }

        public void updateAssignmentLookups() {
            List<SObject> assignedRecordsToUpdate = new List<SObject>();

            for (Assigned_Curriculum__c assignedCurriculum : this.assignedCurriculums) {
                if (String.isEmpty(String.valueOf(assignedCurriculum.Recommended_Learning__c))) {
                    assignedCurriculum.Recommended_Learning__c = this.recommendedLearningsByKey.get(getRecommendationKey(assignedCurriculum)).Id;
                    assignedRecordsToUpdate.add(assignedCurriculum);
                }
            }

            for (Assigned_Course__c assignedCourse : this.assignedCourses) {
                if (String.isEmpty(String.valueOf(assignedCourse.Recommended_Learning__c))) {
                    assignedCourse.Recommended_Learning__c = this.recommendedLearningsByKey.get(getRecommendationKey(assignedCourse)).Id;
                    assignedRecordsToUpdate.add(assignedCourse);
                }
            }

            for (Assignment__c assignment : this.assignments) {
                if (String.isEmpty(String.valueOf(assignment.Recommended_Learning__c))) {
                    assignment.Recommended_Learning__c = this.recommendedLearningsByKey.get(getRecommendationKey(assignment)).Id;
                    assignedRecordsToUpdate.add(assignment);
                }
            }

            if (!assignedRecordsToUpdate.isEmpty()) {
                Database.update(assignedRecordsToUpdate, System.AccessLevel.USER_MODE);
            }
        }
    }

    public class RecommendedLearningException extends Exception {}
}