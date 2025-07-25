/**
 * TEMPLATE SERVICE - Houses business logic and direct object manipulation in our handler/service pattern.
 * Business Requirement: Service methods return both Ids and Names for lookup fields to meet downstream flow requirements.
 * Handlers call into this class to perform CRUD and search operations.
 * Service class for Audience operations.
 * Handles all business logic, including CRUD, search, and permission enforcement.
 *
 * Key fields referenced:
 *   - `Name`
 *   - `CreatedDate`
 *   - `LastModifiedDate`
 *   - `CreatedById`
 *   - `LastModifiedById`
 *
 * @version 2.9
 */
public with sharing class FRAGENTAudienceService extends FRAGENTGeneralService {

    // A dedicated DTO for search results that includes total count for pagination.
    public class SearchResult extends FRAGENTGeneralService.Result {
        @AuraEnabled public Integer totalCount;
        @AuraEnabled public Map<Id, Integer> memberCounts;
        @AuraEnabled public Map<Id, Map<String, Integer>> divisionCounts;
        @AuraEnabled public Map<Id, Map<String, Integer>> aeTypeCounts;
        @AuraEnabled public Map<Id, Map<String, Integer>> roleLevel4Counts;

        public SearchResult(Boolean success, List<SObject> records, Integer totalCount,
                Map<Id, Integer> memberCounts,
                Map<Id, Map<String, Integer>> divisionCounts,
                Map<Id, Map<String, Integer>> aeTypeCounts,
                Map<Id, Map<String, Integer>> roleLevel4Counts,
                List<String> errors) {
            super(success, records, errors);
            this.totalCount = totalCount;
            this.memberCounts = memberCounts;
            this.divisionCounts = divisionCounts;
            this.aeTypeCounts = aeTypeCounts;
            this.roleLevel4Counts = roleLevel4Counts;
        }
    }

    // DTO for single Audience retrieval that also exposes member statistics.
    public class AudienceResult extends FRAGENTGeneralService.Result {
        @AuraEnabled public Integer memberCount;
        @AuraEnabled public Map<String, Integer> divisionCounts;
        @AuraEnabled public Map<String, Integer> aeTypeCounts;
        @AuraEnabled public Map<String, Integer> roleLevel4Counts;
        @AuraEnabled public List<FRAGENTAudienceMemberService.UnifiedAudienceMember> members;

        public AudienceResult(Boolean success, List<SObject> records, List<FRAGENTAudienceMemberService.UnifiedAudienceMember> members, Integer memberCount,
                Map<String, Integer> divisionCounts, Map<String, Integer> aeTypeCounts,
                Map<String, Integer> roleLevel4Counts, List<String> errors) {
            super(success, records, errors);
            this.memberCount = memberCount;
            this.divisionCounts = divisionCounts;
            this.aeTypeCounts = aeTypeCounts;
            this.roleLevel4Counts = roleLevel4Counts;
            this.members = members;
        }
    }

    /**
     * @description Retrieves an Audience record by ID.
     */
    public static AudienceResult getAudienceById(Id audienceId) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_RETRIEVE);
        
        if (audienceId == null) {
            return new AudienceResult(false, null, null, 0, null, null, null,
                new List<String>{'Audience ID cannot be null.'});
        }

        List<Audience__c> audiences = [
            SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById
            FROM Audience__c WHERE Id = :audienceId LIMIT 1
        ];
        
        if (audiences.isEmpty()) {
            return new AudienceResult(false, null, null, 0, null, null, null,
                new List<String>{'Audience not found with ID: ' + audienceId});
        }

        Integer memberCount = [SELECT count() FROM Audience_Member__c WHERE Audience__c = :audienceId];

        Map<String, Integer> divisionCounts = new Map<String, Integer>();
        for (AggregateResult ar : [
            SELECT Learner_Profile__r.Division__c division, COUNT(Id) cnt
            FROM Audience_Member__c
            WHERE Audience__c = :audienceId
            GROUP BY Learner_Profile__r.Division__c
        ]) {
            String key = (String)ar.get('division');
            key = key == null ? 'Unspecified' : key;
            divisionCounts.put(key, (Integer)ar.get('cnt'));
        }

        Map<String, Integer> aeTypeCounts = new Map<String, Integer>();
        for (AggregateResult ar : [
            SELECT Learner_Profile__r.AE_Type__c aeType, COUNT(Id) cnt
            FROM Audience_Member__c
            WHERE Audience__c = :audienceId
            GROUP BY Learner_Profile__r.AE_Type__c
        ]) {
            String key = (String)ar.get('aeType');
            key = key == null ? 'Unspecified' : key;
            aeTypeCounts.put(key, (Integer)ar.get('cnt'));
        }

        Map<String, Integer> roleCounts = new Map<String, Integer>();
        for (AggregateResult ar : [
            SELECT Learner_Profile__r.Role_Level_4__c role4, COUNT(Id) cnt
            FROM Audience_Member__c
            WHERE Audience__c = :audienceId
            GROUP BY Learner_Profile__r.Role_Level_4__c
        ]) {
            String key = (String)ar.get('role4');
            key = key == null ? 'Unspecified' : key;
            roleCounts.put(key, (Integer)ar.get('cnt'));
        }

        FRAGENTAudienceMemberService.SearchResult memberRes = FRAGENTAudienceMemberService.search(
            audienceId, null, null, null, null, null, null, 2000, 0);
        List<FRAGENTAudienceMemberService.UnifiedAudienceMember> members =
            memberRes == null ? new List<FRAGENTAudienceMemberService.UnifiedAudienceMember>() : memberRes.memberDetails;

        return new AudienceResult(true, audiences, members, memberCount,
            divisionCounts, aeTypeCounts, roleCounts, new List<String>());
    }

    /**
     * @description Creates multiple Audience records.
     */
    public static FRAGENTGeneralService.Result createAudiences(List<Audience__c> audiences) {
        try {
            checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);
        } catch (Exception e) {
            return new Result(false, null, new List<String>{e.getMessage()});
        }

        if (audiences == null || audiences.isEmpty()) {
            return new Result(true, new List<SObject>(), new List<String>());
        }

        List<Audience__c> validAudiences = new List<Audience__c>();
        List<String> errorMessages = new List<String>();

        for (Audience__c aud : audiences) {
            if (String.isBlank(aud.Name)) {
                errorMessages.add('Error creating audience: Name is required');
            } else {
                validAudiences.add(aud);
            }
        }

        // Always assign the "Manual" record type when creating audiences.
        // The developer name for this record type is 'Cohort'.
        Id manualRtId;
        try {
            manualRtId = Schema.SObjectType.Audience__c
                .getRecordTypeInfosByDeveloperName()
                .get('Cohort')
                .getRecordTypeId();
        } catch (Exception e) {
            manualRtId = null;
        }

        if (manualRtId != null) {
            for (Audience__c aud : validAudiences) {
                aud.RecordTypeId = manualRtId;
            }
        }

        List<Id> successIds = new List<Id>();

        Database.SaveResult[] srs = Database.insert(validAudiences, false);
        for (Database.SaveResult sr : srs) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            } else {
                for (Database.Error err : sr.getErrors()) {
                    errorMessages.add('Error creating audience: ' + err.getMessage());
                }
            }
        }

        List<Audience__c> createdAudiences = successIds.isEmpty() ? new List<Audience__c>() :
            [SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById FROM Audience__c WHERE Id IN :successIds];
        
        return new Result(errorMessages.isEmpty(), createdAudiences, errorMessages);
    }

    /**
     * @description Updates multiple Audience records.
     */
    public static FRAGENTGeneralService.Result updateAudiences(List<Audience__c> audiences) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);
        
        Database.SaveResult[] srs = Database.update(audiences, false);

        List<Id> successIds = new List<Id>();
        List<String> errorMessages = new List<String>();
        for (Database.SaveResult sr : srs) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            } else {
                for (Database.Error err : sr.getErrors()) {
                    errorMessages.add('Error updating audience ' + sr.getId() + ': ' + err.getMessage());
                }
            }
        }

        List<Audience__c> updatedAudiences = successIds.isEmpty() ? new List<Audience__c>() :
            [SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById FROM Audience__c WHERE Id IN :successIds];

        return new Result(errorMessages.isEmpty(), updatedAudiences, errorMessages);
    }
    
    /**
     * @description Deletes multiple Audience records by their IDs.
     */
    public static FRAGENTGeneralService.Result deleteAudiences(List<Id> ids) {
        try {
            checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);
        } catch (Exception e) {
            return new Result(false, null, new List<String>{e.getMessage()});
        }

        if (ids == null || ids.isEmpty()) {
            return new Result(true, null, new List<String>());
        }

        List<Audience__c> toDelete = [SELECT Id FROM Audience__c WHERE Id IN :ids];
        if (toDelete.isEmpty()) {
            return new Result(true, null, new List<String>{'No matching audiences found to delete.'});
        }
        
        Database.DeleteResult[] drs = Database.delete(toDelete, false);

        List<String> errorMessages = new List<String>();
        for(Database.DeleteResult dr : drs){
            if(!dr.isSuccess()){
                for(Database.Error err : dr.getErrors()){
                    errorMessages.add('Error deleting audience ' + dr.getId() + ': ' + err.getMessage());
                }
            }
        }

        return new Result(errorMessages.isEmpty(), null, errorMessages);
    }

    /**
     * @description Searches for audiences by keyword OR date, with priority given to date searches.
     * @param searchTerm A keyword to search in the Name field.
     * @param dateFieldToSearch The specific date field to search (CreatedDate or LastModifiedDate).
     * @param dateLiteral A date literal string for date filtering.
     * @param startDate The start date for date range filtering.
     * @param endDate The end date for date range filtering.
     * @param recordLimit The maximum number of records to return.
     * @param offset The starting row offset for pagination.
     * @return A SearchResult DTO containing the records page and the total count.
     */
    public static SearchResult search(
        String searchTerm, 
        String dateFieldToSearch, 
        String dateLiteral, 
        Date startDate, 
        Date endDate, 
        Integer recordLimit, 
        Integer offset
    ) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_RETRIEVE);

        // Default the date field if not specified
        String targetDateField = String.isNotBlank(dateFieldToSearch) ? dateFieldToSearch : 'CreatedDate';
        Set<String> validDateFields = new Set<String>{'CreatedDate', 'LastModifiedDate'};
        
        if (!validDateFields.contains(targetDateField)) {
            return new SearchResult(false, null, 0, null, null, null, null,
                new List<String>{'Invalid date field specified: ' + targetDateField});
        }

        List<String> whereClauses = new List<String>();
        Map<String, Object> bindVars = new Map<String, Object>();

        try {
            if (String.isNotBlank(dateLiteral)) {
                String dateClause = FRAGENTUtility.parseDateFilter(targetDateField, dateLiteral);
                whereClauses.add('(' + dateClause + ')');
            } else if (startDate != null || endDate != null) {
                Date queryEndDate = endDate;
                if (startDate != null && endDate != null && startDate == endDate) {
                    queryEndDate = endDate.addDays(1);
                }

                String rangeClause = FRAGENTUtility.buildDateRangeClause(targetDateField, startDate, queryEndDate);
                if (startDate != null) bindVars.put('startDate', startDate);
                if (queryEndDate != null) bindVars.put('endDate', queryEndDate);

                whereClauses.add('(' + rangeClause + ')');
            } else if (String.isNotBlank(searchTerm)) {
                String queryTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';
                whereClauses.add('Name LIKE :queryTerm');
                bindVars.put('queryTerm', queryTerm);
            }
        } catch (Exception e) {
            return new SearchResult(false, null, 0, null, null, null, null,
                new List<String>{'Search failed due to invalid input: ' + e.getMessage()});
        }

        String finalWhereClause = whereClauses.isEmpty() ? '' : 'WHERE ' + String.join(whereClauses, ' AND ');

        String countQuery = 'SELECT count() FROM Audience__c ' + finalWhereClause;
        String mainQuery = 'SELECT Id, Name, CreatedDate, LastModifiedDate, CreatedById, LastModifiedById ' +
                           'FROM Audience__c ' + finalWhereClause + ' ' +
                           'ORDER BY LastModifiedDate DESC';

        if (recordLimit != null) mainQuery += ' LIMIT ' + recordLimit;
        if (offset != null && offset > 0) mainQuery += ' OFFSET ' + offset;

        try {
            Integer totalCount = Database.countQueryWithBinds(countQuery, bindVars, AccessLevel.USER_MODE);
            List<Audience__c> audiences = totalCount > 0 ? Database.queryWithBinds(mainQuery, bindVars, AccessLevel.USER_MODE) : new List<Audience__c>();

            Map<Id, Integer> memberCounts = new Map<Id, Integer>();
            Map<Id, Map<String, Integer>> divisionCounts = new Map<Id, Map<String, Integer>>();
            Map<Id, Map<String, Integer>> aeTypeCounts = new Map<Id, Map<String, Integer>>();
            Map<Id, Map<String, Integer>> roleCounts = new Map<Id, Map<String, Integer>>();
            if (!audiences.isEmpty()) {
                for (AggregateResult ar : [
                    SELECT Audience__c audId, COUNT(Id) cnt
                    FROM Audience_Member__c
                    WHERE Audience__c IN :audiences
                    GROUP BY Audience__c
                ]) {
                    memberCounts.put((Id)ar.get('audId'), (Integer)ar.get('cnt'));
                }

                for (AggregateResult ar : [
                    SELECT Audience__c audId, Learner_Profile__r.Division__c division, COUNT(Id) cnt
                    FROM Audience_Member__c
                    WHERE Audience__c IN :audiences
                    GROUP BY Audience__c, Learner_Profile__r.Division__c
                ]) {
                    Id audId = (Id)ar.get('audId');
                    String key = (String)ar.get('division');
                    key = key == null ? 'Unspecified' : key;
                    if (!divisionCounts.containsKey(audId)) {
                        divisionCounts.put(audId, new Map<String, Integer>());
                    }
                    divisionCounts.get(audId).put(key, (Integer)ar.get('cnt'));
                }

                for (AggregateResult ar : [
                    SELECT Audience__c audId, Learner_Profile__r.AE_Type__c aeType, COUNT(Id) cnt
                    FROM Audience_Member__c
                    WHERE Audience__c IN :audiences
                    GROUP BY Audience__c, Learner_Profile__r.AE_Type__c
                ]) {
                    Id audId = (Id)ar.get('audId');
                    String key = (String)ar.get('aeType');
                    key = key == null ? 'Unspecified' : key;
                    if (!aeTypeCounts.containsKey(audId)) {
                        aeTypeCounts.put(audId, new Map<String, Integer>());
                    }
                    aeTypeCounts.get(audId).put(key, (Integer)ar.get('cnt'));
                }

                for (AggregateResult ar : [
                    SELECT Audience__c audId, Learner_Profile__r.Role_Level_4__c role4, COUNT(Id) cnt
                    FROM Audience_Member__c
                    WHERE Audience__c IN :audiences
                    GROUP BY Audience__c, Learner_Profile__r.Role_Level_4__c
                ]) {
                    Id audId = (Id)ar.get('audId');
                    String key = (String)ar.get('role4');
                    key = key == null ? 'Unspecified' : key;
                    if (!roleCounts.containsKey(audId)) {
                        roleCounts.put(audId, new Map<String, Integer>());
                    }
                    roleCounts.get(audId).put(key, (Integer)ar.get('cnt'));
                }

                for (Audience__c aud : audiences) {
                    if (!memberCounts.containsKey(aud.Id)) {
                        memberCounts.put(aud.Id, 0);
                    }
                    if (!divisionCounts.containsKey(aud.Id)) {
                        divisionCounts.put(aud.Id, new Map<String, Integer>());
                    }
                    if (!aeTypeCounts.containsKey(aud.Id)) {
                        aeTypeCounts.put(aud.Id, new Map<String, Integer>());
                    }
                    if (!roleCounts.containsKey(aud.Id)) {
                        roleCounts.put(aud.Id, new Map<String, Integer>());
                    }
                }
            }

            return new SearchResult(true, audiences, totalCount, memberCounts,
                divisionCounts, aeTypeCounts, roleCounts, new List<String>());
        } catch (Exception e) {
            System.debug('Dynamic SOQL failed. Query: ' + mainQuery + ' | Binds: ' + bindVars);
            return new SearchResult(false, null, 0, null, null, null, null,
                new List<String>{'Search query failed: ' + e.getMessage()});
        }
    }

    /**
     * @description Adds members to a specific audience.
     */
    public static FRAGENTGeneralService.Result addMembers(Id audienceId, List<Id> learnerProfileIds) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);

        List<Audience_Member__c> membersToInsert = new List<Audience_Member__c>();
        Set<Id> allowedLearners = FRAGENTAudienceMemberService.getAuthorizedLearners(new Set<Id>(learnerProfileIds));
        List<String> errors = new List<String>();
        for (Id lpId : learnerProfileIds) {
            if (allowedLearners.contains(lpId)) {
                membersToInsert.add(new Audience_Member__c(
                    Audience__c = audienceId,
                    Learner_Profile__c = lpId,
                    Manually_Added__c = true
                ));
            } else {
                errors.add('Learner ' + lpId + ' lacks ACT Learner permissions');
            }
        }
        
        List<Id> successIds = new List<Id>();
        Database.SaveResult[] srs = Database.insert(membersToInsert, false);
        for (Database.SaveResult sr : srs) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            } else {
                for (Database.Error err : sr.getErrors()) {
                    errors.add('Failed to add member: ' + err.getMessage());
                }
            }
        }
        
        List<SObject> createdMembers = successIds.isEmpty() ? new List<SObject>() : 
            [SELECT Id, Audience__c, Learner_Profile__c FROM Audience_Member__c WHERE Id IN :successIds];
            
        return new Result(errors.isEmpty(), createdMembers, errors);
    }

    /**
     * @description Removes members from a specific audience.
     */
    public static FRAGENTGeneralService.Result removeMembers(Id audienceId, List<Id> learnerProfileIds) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);
        
        List<Audience_Member__c> membersToDelete = [
            SELECT Id FROM Audience_Member__c
            WHERE Audience__c = :audienceId AND Learner_Profile__c IN :learnerProfileIds
        ];

        if (membersToDelete.isEmpty()) {
            return new Result(true, null, new List<String>{'No matching members found to remove.'});
        }

        Database.DeleteResult[] drs = Database.delete(membersToDelete, false);
        List<String> errors = new List<String>();

        for (Database.DeleteResult dr : drs) {
            if (!dr.isSuccess()) {
                for (Database.Error err : dr.getErrors()) {
                    errors.add('Failed to remove member: ' + err.getMessage());
                }
            }
        }
        
        return new Result(errors.isEmpty(), null, errors);
    }
}