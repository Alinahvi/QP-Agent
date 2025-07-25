/**
 * TEMPLATE SERVICE - Houses business logic and direct object manipulation in our handler/service pattern.
 * Business Requirement: Service methods return both Ids and Names for lookup fields to meet downstream flow requirements.
 * Handlers call into this class to perform CRUD and search operations.
 * Service class for Checklist operations.
 * Handles all business logic, including CRUD, search, and permission enforcement.
 *
 * Key fields referenced:
 *   - `Name`
 *   - `CreatedDate`
 *   - `LastModifiedDate`
 *
 * @version 4.0
 */
public with sharing class FRAGENTChecklistService extends FRAGENTGeneralService {
    
    // A dedicated DTO for search results that includes total count for pagination.
    public class SearchResult extends FRAGENTGeneralService.Result {
        @AuraEnabled public Integer totalCount;

        public SearchResult(Boolean success, List<SObject> records, Integer totalCount, List<String> errors) {
            super(success, records, errors);
            this.totalCount = totalCount;
        }
    }

    /**
     * @description Retrieves a Checklist record by its ID.
     */
    public static Result getById(Id checklistId) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_RETRIEVE);
        
        if (checklistId == null) {
            return new Result(false, null, new List<String>{'Checklist ID cannot be null.'});
        }

        List<Checklist__c> results = [SELECT Id, Name, CreatedDate, LastModifiedDate FROM Checklist__c WHERE Id = :checklistId LIMIT 1];
        
        if (results.isEmpty()) {
            return new Result(false, null, new List<String>{'Checklist not found with ID: ' + checklistId});
        }
        
        return new Result(true, results, new List<String>());
    }

    /**
     * @description Creates new Checklist records in bulk.
     */
    public static Result create(List<Checklist__c> toCreate) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);
        
        List<String> errorMessages = new List<String>();
        List<Id> successIds = new List<Id>();
        
        Database.SaveResult[] srs = Database.insert(toCreate, false);
        for (Database.SaveResult sr : srs) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            } else {
                for (Database.Error err : sr.getErrors()) {
                    errorMessages.add('Error creating checklist: ' + err.getMessage());
                }
            }
        }

        List<SObject> createdRecords = successIds.isEmpty() ? new List<SObject>() :
            [SELECT Id, Name, CreatedDate, LastModifiedDate FROM Checklist__c WHERE Id IN :successIds];
        
        return new Result(errorMessages.isEmpty(), createdRecords, errorMessages);
    }

    /**
     * @description Updates existing Checklist records in bulk.
     * Business Requirement: Queries return updated records with Names so
     *                       flows can confirm changes to users.
     */
    public static Result updateRecords(List<Checklist__c> toUpdate) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);

        List<String> errorMessages = new List<String>();
        List<Id> successIds = new List<Id>();
        
        Database.SaveResult[] srs = Database.update(toUpdate, false);
        for (Database.SaveResult sr : srs) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            } else {
                for (Database.Error err : sr.getErrors()) {
                    errorMessages.add('Error updating checklist ' + sr.getId() + ': ' + err.getMessage());
                }
            }
        }
        
        List<SObject> updatedRecords = successIds.isEmpty() ? new List<SObject>() :
            [SELECT Id, Name, CreatedDate, LastModifiedDate FROM Checklist__c WHERE Id IN :successIds];
        
        return new Result(errorMessages.isEmpty(), updatedRecords, errorMessages);
    }
    
    /**
     * @description Deletes Checklist records in bulk. Prevents deletion if a checklist is assigned to any audience.
     */
    public static Result remove(List<Id> ids) {
        try {
            checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);
        } catch (Exception e) {
            return new Result(false, null, new List<String>{e.getMessage()});
        }

        if (ids == null || ids.isEmpty()) {
            return new Result(true, null, new List<String>());
        }

        // Prevent deletion if checklist is in use
        Set<Id> assignedChecklistIds = new Set<Id>();
        for (AggregateResult ar : [SELECT Checklist__c FROM Audience_Checklist__c WHERE Checklist__c IN :ids GROUP BY Checklist__c]) {
            assignedChecklistIds.add((Id)ar.get('Checklist__c'));
        }

        List<Checklist__c> toDelete = new List<Checklist__c>();
        List<String> errorMessages = new List<String>();
        for (Id checklistId : ids) {
            if (assignedChecklistIds.contains(checklistId)) {
                errorMessages.add('Checklist ' + checklistId + ' is assigned to one or more audiences and cannot be deleted.');
            } else {
                toDelete.add(new Checklist__c(Id = checklistId));
            }
        }

        if (!toDelete.isEmpty()) {
            Database.DeleteResult[] drs = Database.delete(toDelete, false);
            for (Database.DeleteResult dr : drs) {
                if (!dr.isSuccess()) {
                    for (Database.Error err : dr.getErrors()) {
                        errorMessages.add('Error deleting checklist ' + dr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }

        return new Result(errorMessages.isEmpty(), null, errorMessages);
    }

    /**
     * @description Searches for Checklist records by keyword or date filters.
     * Business Requirement: Search results include Name fields so that handlers
     *                       return user-friendly data alongside each ID.
     */
    public static SearchResult search(String searchTerm, String dateFieldToSearch, String dateLiteral, Date startDate, Date endDate, Integer recordLimit, Integer offset) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_RETRIEVE);
        
        String targetDateField = String.isNotBlank(dateFieldToSearch) ? dateFieldToSearch : 'CreatedDate';
        Set<String> validDateFields = new Set<String>{'CreatedDate', 'LastModifiedDate'};
        
        if (!validDateFields.contains(targetDateField)) {
            return new SearchResult(false, null, 0, new List<String>{'Invalid date field specified: ' + targetDateField});
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
            return new SearchResult(false, null, 0, new List<String>{'Search failed due to invalid input: ' + e.getMessage()});
        }
       
        String finalWhereClause = whereClauses.isEmpty() ? '' : 'WHERE ' + String.join(whereClauses, ' AND ');
        
        String countQuery = 'SELECT count() FROM Checklist__c ' + finalWhereClause;
        String mainQuery = 'SELECT Id, Name, CreatedDate, LastModifiedDate FROM Checklist__c ' +
                           finalWhereClause + ' ORDER BY LastModifiedDate DESC';

        if (recordLimit != null) mainQuery += ' LIMIT ' + recordLimit;
        if (offset != null && offset > 0) mainQuery += ' OFFSET ' + offset;

        try {
            Integer totalCount = Database.countQueryWithBinds(countQuery, bindVars, AccessLevel.USER_MODE);
            List<Checklist__c> records = totalCount > 0 ? Database.queryWithBinds(mainQuery, bindVars, AccessLevel.USER_MODE) : new List<Checklist__c>();
            return new SearchResult(true, records, totalCount, new List<String>());
        } catch (Exception e) {
            return new SearchResult(false, null, 0, new List<String>{'Search query failed: ' + e.getMessage()});
        }
    }
}