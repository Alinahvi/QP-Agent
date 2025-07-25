/**
 * TEMPLATE SERVICE - Houses business logic and direct object manipulation in our handler/service pattern.
 * Business Requirement: Service methods return both Ids and Names for lookup fields to meet downstream flow requirements.
 * Handlers call into this class to perform CRUD and search operations.
 * @description Service class for Audience Checklist operations.
 * Handles all business logic for the junction object between Audience and Checklist.
 *
 * Key fields referenced:
 *   - `Audience__c`
 *   - `Checklist__c`
 *   - `CreatedDate`
 *   - `LastModifiedDate`
 *
 * @version 4.0
 */
public with sharing class FRAGENTAudienceChecklistService extends FRAGENTGeneralService {

    public class SearchResult extends FRAGENTGeneralService.Result {
        @AuraEnabled public Integer totalCount;

        public SearchResult(Boolean success, List<SObject> records, Integer totalCount, List<String> errors) {
            super(success, records, errors);
            this.totalCount = totalCount;
        }
    }

    /**
     * @description Retrieves a single Audience_Checklist__c record by its ID.
     * Business Requirement: Query includes Name fields for both related records
     *                       so flows can display friendly information.
     */
    public static Result getById(Id audienceChecklistId) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_RETRIEVE);
        List<Audience_Checklist__c> results = [SELECT Id, Name,
                Audience__c, Audience__r.Name,
                Checklist__c, Checklist__r.Name,
                CreatedDate, LastModifiedDate
            FROM Audience_Checklist__c WHERE Id = :audienceChecklistId LIMIT 1];
        return new Result(true, results, new List<String>());
    }

    /**
     * @description Creates new Audience_Checklist__c records.
     * Business Requirement: Return IDs and Names of created records for
     *                       readability by downstream flows.
     */
    public static Result create(List<Audience_Checklist__c> toCreate) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);

        List<String> errorMessages = new List<String>();
        List<Id> successIds = new List<Id>();

        Database.SaveResult[] srs = Database.insert(toCreate, false);
        for (Database.SaveResult sr : srs) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            } else {
                for (Database.Error err : sr.getErrors()) {
                    errorMessages.add('Error creating association: ' + err.getMessage());
                }
            }
        }

        List<SObject> createdRecords = successIds.isEmpty() ? new List<SObject>() :
            [SELECT Id, Name,
                    Audience__c, Audience__r.Name,
                    Checklist__c, Checklist__r.Name,
                    CreatedDate, LastModifiedDate
             FROM Audience_Checklist__c WHERE Id IN :successIds];

        return new Result(errorMessages.isEmpty(), createdRecords, errorMessages);
    }

    /**
     * @description Updates existing Audience_Checklist__c records.
     * Business Requirement: Updated records are queried again including
     *                       the related Names for readability in flows.
     */
    public static Result updateRecords(List<Audience_Checklist__c> toUpdate) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);

        List<String> errorMessages = new List<String>();
        List<Id> successIds = new List<Id>();

        Database.SaveResult[] srs = Database.update(toUpdate, false);
        for (Database.SaveResult sr : srs) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            } else {
                for (Database.Error err : sr.getErrors()) {
                    errorMessages.add('Error updating association ' + sr.getId() + ': ' + err.getMessage());
                }
            }
        }

        List<SObject> updatedRecords = successIds.isEmpty() ? new List<SObject>() :
            [SELECT Id, Name,
                    Audience__c, Audience__r.Name,
                    Checklist__c, Checklist__r.Name,
                    CreatedDate, LastModifiedDate
             FROM Audience_Checklist__c WHERE Id IN :successIds];

        return new Result(errorMessages.isEmpty(), updatedRecords, errorMessages);
    }

    /**
     * @description Deletes Audience_Checklist__c records.
     * Business Requirement: Only authorized users may remove these links.
     */
    public static Result remove(List<Id> idsToRemove) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);
        if (idsToRemove == null || idsToRemove.isEmpty()) {
            return new Result(true, null, new List<String>());
        }

        List<Audience_Checklist__c> toDelete = [SELECT Id FROM Audience_Checklist__c WHERE Id IN :idsToRemove];
        if (toDelete.isEmpty()) {
            return new Result(true, null, new List<String>());
        }

        List<String> errorMessages = new List<String>();
        Database.DeleteResult[] drs = Database.delete(toDelete, false);
        for (Database.DeleteResult dr : drs) {
            if (!dr.isSuccess()) {
                for (Database.Error err : dr.getErrors()) {
                    errorMessages.add('Error deleting association ' + dr.getId() + ': ' + err.getMessage());
                }
            }
        }

        return new Result(errorMessages.isEmpty(), null, errorMessages);
    }
    
    /**
     * @description Searches for Audience_Checklist__c records using keyword or
     *              date filters.
     * Business Requirement: Queries include related Name fields so handlers
     *                       return user-friendly information.
     */
    public static SearchResult search(Id audienceId, Id checklistId, String searchTerm, String dateFieldToSearch, String dateLiteral, Date startDate, Date endDate, Integer recordLimit, Integer offset) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_RETRIEVE);

        String targetDateField = String.isNotBlank(dateFieldToSearch) ? dateFieldToSearch : 'CreatedDate';
        Set<String> validDateFields = new Set<String>{'CreatedDate', 'LastModifiedDate'};
        if (!validDateFields.contains(targetDateField)) {
            return new SearchResult(false, null, 0, new List<String>{'Invalid date field specified: ' + targetDateField});
        }

        List<String> whereClauses = new List<String>();
        Map<String, Object> bindVars = new Map<String, Object>();
        
        if (audienceId != null) {
            whereClauses.add('Audience__c = :audienceId');
            bindVars.put('audienceId', audienceId);
        }
        if (checklistId != null) {
            whereClauses.add('Checklist__c = :checklistId');
            bindVars.put('checklistId', checklistId);
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
            return new SearchResult(false, null, 0, new List<String>{'Search failed due to invalid input: ' + e.getMessage()});
        }
       
        String finalWhereClause = whereClauses.isEmpty() ? '' : 'WHERE ' + String.join(whereClauses, ' AND ');
        
        String countQuery = 'SELECT count() FROM Audience_Checklist__c ' + finalWhereClause;
        String mainQuery = 'SELECT Id, Name, Audience__c, Audience__r.Name, Checklist__c, Checklist__r.Name, CreatedDate, LastModifiedDate ' +
                           'FROM Audience_Checklist__c ' + finalWhereClause + ' ORDER BY LastModifiedDate DESC';

        if (recordLimit != null) mainQuery += ' LIMIT ' + recordLimit;
        if (offset != null && offset > 0) mainQuery += ' OFFSET ' + offset;

        try {
            Integer totalCount = Database.countQueryWithBinds(countQuery, bindVars, AccessLevel.USER_MODE);
            List<Audience_Checklist__c> records = totalCount > 0 ? Database.queryWithBinds(mainQuery, bindVars, AccessLevel.USER_MODE) : new List<Audience_Checklist__c>();
            return new SearchResult(true, records, totalCount, new List<String>());
        } catch (Exception e) {
            return new SearchResult(false, null, 0, new List<String>{'Search query failed: ' + e.getMessage()});
        }
    }
}