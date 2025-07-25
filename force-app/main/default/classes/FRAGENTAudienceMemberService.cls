/**
 * TEMPLATE SERVICE - Houses business logic and direct object manipulation in our handler/service pattern.
 * Business Requirement: Service methods return both Ids and Names for lookup fields to meet downstream flow requirements.
 * Handlers call into this class to perform CRUD and search operations.
 * @description Service class for Audience Member operations.
 * Handles all business logic for the junction object between Audience and Learner Profile.
 *
 * Key fields referenced:
 *   - `Audience__c`
 *   - `Learner_Profile__c`
 *   - `CreatedDate`
 *   - `LastModifiedDate`
 *
 * @version 4.0
 */
public with sharing class FRAGENTAudienceMemberService extends FRAGENTGeneralService {

    public class SearchResult extends FRAGENTGeneralService.Result {
        @AuraEnabled public Integer totalCount;
        @AuraEnabled public Map<String, Integer> divisionCounts;
        @AuraEnabled public Map<String, Integer> aeTypeCounts;
        @AuraEnabled public Map<String, Integer> roleLevel4Counts;
        @AuraEnabled public List<UnifiedAudienceMember> memberDetails;

        public SearchResult(Boolean success, List<SObject> records, List<UnifiedAudienceMember> memberDetails, Integer totalCount,
                Map<String, Integer> divisionCounts,
                Map<String, Integer> aeTypeCounts,
                Map<String, Integer> roleLevel4Counts,
                List<String> errors) {
            super(success, records, errors);
            this.totalCount = totalCount;
            this.divisionCounts = divisionCounts;
            this.aeTypeCounts = aeTypeCounts;
            this.roleLevel4Counts = roleLevel4Counts;
            this.memberDetails = memberDetails;
        }
    }

    /**
     * @description DTO representing an Audience Member along with helpful names.
     */
    public class UnifiedAudienceMember {
        @AuraEnabled public Id id;
        @AuraEnabled public Id audienceId;
        @AuraEnabled public String audienceName;
        @AuraEnabled public Id learnerProfileId;
        @AuraEnabled public String learnerName;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public Datetime lastModifiedDate;

        public UnifiedAudienceMember(Audience_Member__c am) {
            this.id = am.Id;
            this.audienceId = am.Audience__c;
            this.audienceName = am.Audience__r != null ? am.Audience__r.Name : null;
            this.learnerProfileId = am.Learner_Profile__c;
            this.learnerName = am.Learner_Profile__r != null ? am.Learner_Profile__r.Name : null;
            this.createdDate = am.CreatedDate;
            this.lastModifiedDate = am.LastModifiedDate;
        }
    }

    private static List<UnifiedAudienceMember> composeUnified(List<Audience_Member__c> records) {
        List<UnifiedAudienceMember> unified = new List<UnifiedAudienceMember>();
        if (records == null) return unified;
        for (Audience_Member__c am : records) {
            unified.add(new UnifiedAudienceMember(am));
        }
        return unified;
    }

    /**
     * Returns the subset of learner profile IDs whose associated users have the
     * ACT Learner permission set or permission set group assigned.
     */
    public static Set<Id> getAuthorizedLearners(Set<Id> learnerProfileIds) {
        Set<Id> authorized = new Set<Id>();
        if (learnerProfileIds == null || learnerProfileIds.isEmpty()) return authorized;

        Map<Id, Id> lpUserMap = new Map<Id, Id>();
        for (Learner_Profile__c lp : [SELECT Id, User__c FROM Learner_Profile__c WHERE Id IN :learnerProfileIds]) {
            lpUserMap.put(lp.Id, lp.User__c);
        }

        Set<Id> userIds = new Set<Id>();
        for (Id uid : lpUserMap.values()) if (uid != null) userIds.add(uid);

        Set<Id> allowedUsers = getUsersWithActLearnerPerm(userIds);

        for (Id lpId : learnerProfileIds) {
            Id uid = lpUserMap.get(lpId);
            if (uid != null && allowedUsers.contains(uid)) {
                authorized.add(lpId);
            }
        }
        return authorized;
    }

    /**
     * Helper to find users assigned the ACT Learner permission set group or permission set.
     */
    private static Set<Id> getUsersWithActLearnerPerm(Set<Id> userIds) {
        Set<Id> authorized = new Set<Id>();
        if (userIds == null || userIds.isEmpty()) return authorized;

        Id groupId;
        try {
            groupId = [SELECT Id FROM PermissionSetGroup WHERE MasterLabel = 'ACT Learner' LIMIT 1].Id;
        } catch (Exception e) {
            groupId = null;
        }

        if (groupId != null) {
            for (PermissionSetAssignment psa : [SELECT AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN :userIds AND PermissionSetGroupId = :groupId]) {
                authorized.add(psa.AssigneeId);
            }
        } else {
            Id psId;
            try {
                psId = [SELECT Id FROM PermissionSet WHERE Label = 'ACT Learner' LIMIT 1].Id;
            } catch (Exception e) {
                psId = null;
            }

            if (psId != null) {
                for (PermissionSetAssignment psa : [SELECT AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN :userIds AND PermissionSetId = :psId]) {
                    authorized.add(psa.AssigneeId);
                }
            }
        }

        return authorized;
    }

    /**
     * @description Retrieves an Audience_Member__c record by ID.
     * Business Requirement: Query includes the related Learner Profile Name for
     *                       display purposes.
     */
    public static Result getById(Id audienceMemberId) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_RETRIEVE);
        List<Audience_Member__c> results = [SELECT Id, Name, Audience__c, Audience__r.Name, Learner_Profile__c, Learner_Profile__r.Name, CreatedDate, LastModifiedDate FROM Audience_Member__c WHERE Id = :audienceMemberId LIMIT 1];
        return new Result(true, results, new List<String>());
    }

    /**
     * @description Creates new Audience_Member__c records.
     * Business Requirement: Records are returned with IDs and Names so the
     *                       handler can provide clear feedback.
     */
    public static Result create(List<Audience_Member__c> toCreate) {
        try {
            checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);
        } catch (Exception e) {
            return new Result(false, null, new List<String>{e.getMessage()});
        }

        if (toCreate == null || toCreate.isEmpty()) {
            return new Result(true, new List<SObject>(), new List<String>());
        }

        List<Audience_Member__c> validRecords = new List<Audience_Member__c>();
        List<String> errorMessages = new List<String>();
        Set<Id> audienceIds = new Set<Id>();
        Set<Id> learnerIds = new Set<Id>();
        for (Audience_Member__c am : toCreate) {
            if (am.Learner_Profile__c != null) learnerIds.add(am.Learner_Profile__c);
        }
        Set<Id> authorizedLearners = getAuthorizedLearners(learnerIds);

        for (Audience_Member__c am : toCreate) {
            if (am.Audience__c == null || am.Learner_Profile__c == null) {
                errorMessages.add('Error creating audience member: Audience and Learner Profile are required');
            } else if (!authorizedLearners.contains(am.Learner_Profile__c)) {
                errorMessages.add('Error creating audience member: Learner lacks ACT Learner permissions');
            } else {
                am.Manually_Added__c = true;
                validRecords.add(am);
                audienceIds.add(am.Audience__c);
            }
        }

        if (!audienceIds.isEmpty() &&
            [SELECT count() FROM Assigned_Learning__c WHERE Audience__c IN :audienceIds] > 0) {
            return new Result(false, null,
                new List<String>{'Cannot add members to an Audience that already has assigned learning. ' +
                                 'Please contact the support team for assistance.'});
        }

        List<Id> successIds = new List<Id>();
        Database.SaveResult[] srs = validRecords.isEmpty() ?
            new List<Database.SaveResult>() : Database.insert(validRecords, false);
        for (Database.SaveResult sr : srs) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            } else {
                for (Database.Error err : sr.getErrors()) {
                    errorMessages.add('Error creating audience member: ' + err.getMessage());
                }
            }
        }

        List<SObject> createdRecords = successIds.isEmpty() ? new List<SObject>() :
            [SELECT Id, Name, Audience__c, Audience__r.Name, Learner_Profile__c, Learner_Profile__r.Name, CreatedDate, LastModifiedDate FROM Audience_Member__c WHERE Id IN :successIds];

        return new Result(errorMessages.isEmpty(), createdRecords, errorMessages);
    }

    /**
     * @description Updates Audience_Member__c records in bulk.
     * Business Requirement: Return updated IDs and Names for clarity.
     */
    public static Result updateRecords(List<Audience_Member__c> toUpdate) {
        // This is a junction object; updates are rare but allowed.
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);

        List<String> errorMessages = new List<String>();
        List<Id> successIds = new List<Id>();

        Database.SaveResult[] srs = Database.update(toUpdate, false);
        for (Database.SaveResult sr : srs) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            } else {
                for (Database.Error err : sr.getErrors()) {
                    errorMessages.add('Error updating audience member ' + sr.getId() + ': ' + err.getMessage());
                }
            }
        }

        List<SObject> updatedRecords = successIds.isEmpty() ? new List<SObject>() :
            [SELECT Id, Name, Audience__c, Audience__r.Name, Learner_Profile__c, Learner_Profile__r.Name, CreatedDate, LastModifiedDate FROM Audience_Member__c WHERE Id IN :successIds];

        return new Result(errorMessages.isEmpty(), updatedRecords, errorMessages);
    }

    /**
     * @description Deletes Audience_Member__c records by ID.
     * Business Requirement: Prevent deletion if the Audience already has
     *                       Assigned Learning records.
     */
    public static Result remove(List<Id> idsToRemove) {
        try {
            checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);
        } catch (Exception e) {
            return new Result(false, null, new List<String>{e.getMessage()});
        }
        if (idsToRemove == null || idsToRemove.isEmpty()) {
            return new Result(true, null, new List<String>());
        }

        List<Audience_Member__c> toDelete = [SELECT Id, Audience__c FROM Audience_Member__c WHERE Id IN :idsToRemove];
        if (toDelete.isEmpty()) {
            return new Result(true, null, new List<String>());
        }

        Set<Id> audienceIds = new Set<Id>();
        for (Audience_Member__c am : toDelete) {
            if (am.Audience__c != null) audienceIds.add(am.Audience__c);
        }

        if (!audienceIds.isEmpty() &&
            [SELECT count() FROM Assigned_Learning__c WHERE Audience__c IN :audienceIds] > 0) {
            return new Result(false, null,
                new List<String>{'Cannot delete members from an Audience that already has assigned learning. ' +
                                 'Please contact the support team for assistance.'});
        }

        List<String> errorMessages = new List<String>();
        Database.DeleteResult[] drs = Database.delete(toDelete, false);
        for (Database.DeleteResult dr : drs) {
            if (!dr.isSuccess()) {
                for (Database.Error err : dr.getErrors()) {
                    errorMessages.add('Error deleting audience member ' + dr.getId() + ': ' + err.getMessage());
                }
            }
        }

        return new Result(errorMessages.isEmpty(), null, errorMessages);
    }
    
    /**
     * @description Searches Audience_Member__c records by various filters.
     * Business Requirement: Query includes Learner_Profile__r.Name so flows can
     *                       display the learner's name alongside the ID.
     */
    public static SearchResult search(Id audienceId, Id learnerProfileId, String searchTerm, String dateFieldToSearch, String dateLiteral, Date startDate, Date endDate, Integer recordLimit, Integer offset) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_RETRIEVE);

        String targetDateField = String.isNotBlank(dateFieldToSearch) ? dateFieldToSearch : 'CreatedDate';
        Set<String> validDateFields = new Set<String>{'CreatedDate', 'LastModifiedDate'};
        if (!validDateFields.contains(targetDateField)) {
            return new SearchResult(false, null, null, 0, null, null, null,
                new List<String>{'Invalid date field specified: ' + targetDateField});
        }

        List<String> whereClauses = new List<String>();
        Map<String, Object> bindVars = new Map<String, Object>();
        
        if (audienceId != null) {
            whereClauses.add('Audience__c = :audienceId');
            bindVars.put('audienceId', audienceId);
        }
        if (learnerProfileId != null) {
            whereClauses.add('Learner_Profile__c = :learnerProfileId');
            bindVars.put('learnerProfileId', learnerProfileId);
        }

        try {
            if (String.isNotBlank(dateLiteral)) {
                whereClauses.add('(' + FRAGENTUtility.parseDateFilter(targetDateField, dateLiteral) + ')');
            } else if (startDate != null || endDate != null) {
                Date queryEndDate = (startDate != null && startDate == endDate) ? endDate.addDays(1) : endDate;
                whereClauses.add('(' + FRAGENTUtility.buildDateRangeClause(targetDateField, startDate, queryEndDate) + ')');
                if (startDate != null) bindVars.put('startDate', startDate);
                if (queryEndDate != null) bindVars.put('endDate', queryEndDate);
            } else if (String.isNotBlank(searchTerm)) {
                // This object's Name is an auto-number. No text search applicable.
            }
        } catch (Exception e) {
            return new SearchResult(false, null, null, 0, null, null, null,
                new List<String>{'Search failed due to invalid input: ' + e.getMessage()});
        }
       
        String finalWhereClause = whereClauses.isEmpty() ? '' : 'WHERE ' + String.join(whereClauses, ' AND ');
        
        String countQuery = 'SELECT count() FROM Audience_Member__c ' + finalWhereClause;
        String mainQuery = 'SELECT Id, Name, Audience__c, Audience__r.Name, Learner_Profile__c, Learner_Profile__r.Name, CreatedDate, LastModifiedDate ' +
                           'FROM Audience_Member__c ' + finalWhereClause + ' ORDER BY LastModifiedDate DESC';

        if (recordLimit != null) mainQuery += ' LIMIT ' + recordLimit;
        if (offset != null && offset > 0) mainQuery += ' OFFSET ' + offset;

        try {
            Integer totalCount = Database.countQueryWithBinds(countQuery, bindVars, AccessLevel.USER_MODE);
            List<Audience_Member__c> records = totalCount > 0 ? Database.queryWithBinds(mainQuery, bindVars, AccessLevel.USER_MODE) : new List<Audience_Member__c>();

            Map<String, Integer> divisionCounts = new Map<String, Integer>();
            Map<String, Integer> aeTypeCounts = new Map<String, Integer>();
            Map<String, Integer> roleCounts = new Map<String, Integer>();

            if (totalCount > 0) {
                String divQuery = 'SELECT Learner_Profile__r.Division__c division, COUNT(Id) cnt FROM Audience_Member__c ' +
                    finalWhereClause + ' GROUP BY Learner_Profile__r.Division__c';
                for (AggregateResult ar : (List<AggregateResult>)Database.queryWithBinds(divQuery, bindVars, AccessLevel.USER_MODE)) {
                    String key = (String)ar.get('division');
                    key = key == null ? 'Unspecified' : key;
                    divisionCounts.put(key, (Integer)ar.get('cnt'));
                }

                String aeQuery = 'SELECT Learner_Profile__r.AE_Type__c aeType, COUNT(Id) cnt FROM Audience_Member__c ' +
                    finalWhereClause + ' GROUP BY Learner_Profile__r.AE_Type__c';
                for (AggregateResult ar : (List<AggregateResult>)Database.queryWithBinds(aeQuery, bindVars, AccessLevel.USER_MODE)) {
                    String key = (String)ar.get('aeType');
                    key = key == null ? 'Unspecified' : key;
                    aeTypeCounts.put(key, (Integer)ar.get('cnt'));
                }

                String roleQuery = 'SELECT Learner_Profile__r.Role_Level_4__c role4, COUNT(Id) cnt FROM Audience_Member__c ' +
                    finalWhereClause + ' GROUP BY Learner_Profile__r.Role_Level_4__c';
                for (AggregateResult ar : (List<AggregateResult>)Database.queryWithBinds(roleQuery, bindVars, AccessLevel.USER_MODE)) {
                    String key = (String)ar.get('role4');
                    key = key == null ? 'Unspecified' : key;
                    roleCounts.put(key, (Integer)ar.get('cnt'));
                }
            }

            return new SearchResult(true, records, composeUnified(records), totalCount, divisionCounts, aeTypeCounts, roleCounts, new List<String>());
        } catch (Exception e) {
            return new SearchResult(false, null, null, 0, null, null, null, new List<String>{'Search query failed: ' + e.getMessage()});
        }
    }
}