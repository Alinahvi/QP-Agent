public with sharing class AudienceMember {
    /**
     * Fetches Audience Members for the given Audience & Filters
     */
    @AuraEnabled(cacheable=true)
    public static ResponseData getAudienceMembers(Utilities.DataTablePayload payload) {
        ResponseData rd = new ResponseData();
        
        try {
            String sObjectType = payload.recordId.getSObjectType() + '';

            if (sObjectType != Audience__c.getSObjectType() + '') {
                throw new AudienceMemberException('Getting Audience Members from Invalid SObject Record Page: ' + sObjectType);
            }

            List<String> fields = new List<String> {
                'Id', 'Manually_Added__c', 'Learner_Profile__c', 'Learner_Profile__r.User__r.SmallPhotoUrl', 'Learner_Profile__r.Name', 'Learner_Profile__r.Primary_Email__c'
            };

            String queryFilters = buildQueryFilters(payload);
            String query = '';
            List<Id> currentIds = payload.currentlyDisplayedIds;

            if (payload.currentlyDisplayedIds != null && !payload.currentlyDisplayedIds.isEmpty()) {
                query = 'SELECT ' + String.join(fields, ',') + ' FROM Audience_Member__c' + queryFilters + ' AND Id NOT IN :currentIds ORDER BY Learner_Profile__r.Name ASC LIMIT 30';
            } else {
                query = 'SELECT ' + String.join(fields, ',') + ' FROM Audience_Member__c' + queryFilters + ' ORDER BY Learner_Profile__r.Name ASC LIMIT 30';
            }

            List<Map<String, Object>> audienceMembers = new List<Map<String, Object>>();

            for (Audience_Member__c audienceMember : Database.query(query, System.AccessLevel.USER_MODE)) {
                Map<String, Object> formattedAudienceMember = audienceMember.getPopulatedFieldsAsMap().clone();

                Boolean manual = (Boolean) formattedAudienceMember.get('Manually_Added__c');

                formattedAudienceMember.put('avatar', audienceMember.Learner_Profile__r.User__r.SmallPhotoUrl);
                formattedAudienceMember.put('name', audienceMember.Learner_Profile__r.Name);
                formattedAudienceMember.put('email', audienceMember.Learner_Profile__r.Primary_Email__c);
                formattedAudienceMember.put('type', (manual ? 'Manual' : 'Criteria'));

                audienceMembers.add(formattedAudienceMember);
            }

            String totalCountQuery = 'SELECT COUNT() FROM Audience_Member__c WHERE ' + sObjectType + ' = \'' + payload.recordId + '\'';
            
            rd.put('audienceMembers', audienceMembers);
            rd.put('totalAudienceMembers', Database.countQuery(totalCountQuery, System.AccessLevel.USER_MODE));
            rd.put('totalFilteredAudienceMembers', Database.countQuery('SELECT COUNT() FROM Audience_Member__c' + queryFilters, System.AccessLevel.USER_MODE));
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static String searchForLearners(String searchTerm, String audienceId){
        ResponseData rd = new ResponseData();
        
        try {
            String wildSearchTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';

            String soqlQuery = 'SELECT Id, Name, Primary_Email__c, User__r.SmallPhotoUrl ' +
                               ' FROM Learner_Profile__c';
            
            String whereClause = ' WHERE Name LIKE :wildSearchTerm' +
                                 ' AND User__r.IsActive = true';

            if(String.isNotEmpty(audienceId)){
                whereClause += ' AND Id NOT IN (SELECT Learner_Profile__c ' +
                                              ' FROM Audience_Member__c ' +
                                              ' WHERE Audience__c =: audienceId)';
            }

            soqlQuery += whereClause;
            soqlQuery += ' WITH USER_MODE' +
                         ' ORDER BY Name ASC' +
                         ' LIMIT 5';


            List<Learner_Profile__c> lps = Database.query(soqlQuery);

            rd.put('foundLearners', lps);
            rd.put('searchTerm', searchTerm);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd.getJsonString();
    }

    @AuraEnabled
    public static String createAudienceMembers(String jsonString){
        ResponseData rd = new ResponseData();
        
        try {
            Map<String, Object> parsedRes = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            String audienceId = (String) parsedRes.get('audienceId');
            List<Object> lps = (List<Object>) parsedRes.get('lps');
            List<Audience_Member__c> newAudMems = new List<Audience_Member__c>();

            for (Object lp : lps){
                Map<String, Object> lpMap = (Map<String, Object>)lp;

                newAudMems.add(new Audience_Member__c(
                    Audience__c = audienceId    ,
                    Learner_Profile__c = (String) lpMap.get('Id'),
                    Manually_Added__c = true
                ));
            }

            insert as user newAudMems;
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd.getJsonString();
    }

    @AuraEnabled
    public static ResponseData removeAudienceMembers(Utilities.DataTablePayload payload){
        ResponseData rd = new ResponseData();
        
        try {
            String sObjectType = payload.recordId.getSObjectType() + '';

            if (sObjectType != Audience__c.getSObjectType() + '') {
                throw new AudienceMemberException('Remoing Audience Members from Invalid SObject Record Page: ' + sObjectType);
            }

            String queryFilters = buildQueryFilters(payload);
            List<Id> selectedIds = payload.idsToProcess;

            if (payload.selectAll) {                
                if (Database.countQuery('SELECT COUNT() FROM Audience_Member__c' + queryFilters, System.AccessLevel.USER_MODE) > Utilities.BATCH_THRESHOLD) {
                    rd.put('jobId', Database.executeBatch(new AudienceMemberDeletionBatch(payload)));
                } else {
                    String query = 'SELECT Id FROM Audience_Member__c' + queryFilters + ' ORDER BY Learner_Profile__r.Name ASC';

                    delete as user Database.query(query, System.AccessLevel.USER_MODE);
                }
            } else if (!selectedIds.isEmpty()) {
                queryFilters += ' AND Id IN :selectedIds';

                String query = 'SELECT Id FROM Audience_Member__c' + queryFilters + ' ORDER BY Learner_Profile__r.Name ASC';

                delete as user Database.query(query, System.AccessLevel.USER_MODE);
            }
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    @AuraEnabled
    public static ResponseData getMembersToDownload(String audienceId, String lastMemberId){
        ResponseData rd = new ResponseData();
        
        try {
            List<Audience_Member__c> audMembers = [SELECT Id, Name, Learner_Profile__r.Name, Learner_Profile__r.Primary_Email__c,
                                                          Learner_Profile__r.Manager__c, Learner_Profile__r.Manager_Email__c
                                                   FROM Audience_Member__c
                                                   WHERE Audience__c =: audienceId
                                                   AND Id >: lastMemberId
                                                   ORDER BY Id ASC
                                                   LIMIT 5001];

            rd.put('hasMore', audMembers.size() > 5000);
            rd.put('audMembers', audMembers);
        } catch (Exception e) {
            rd.addError(e);
        }
    
        return rd;
    }

    public static String buildQueryFilters(Utilities.DataTablePayload payload) {
        String queryFilters = ' WHERE ' + (payload.recordId).getSObjectType() + ' = \'' + payload.recordId + '\'';

        if (String.isNotEmpty(payload.searchTerm)) {
            queryFilters += ' AND Learner_Profile__r.Name LIKE \'%' + String.escapeSingleQuotes(payload.searchTerm) + '%\'';
        }   

        return queryFilters;
    }

    public class AudienceMemberException extends Exception {}
}