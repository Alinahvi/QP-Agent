/**
 * TEMPLATE SERVICE - Houses business logic and direct object manipulation in our handler/service pattern.
 * Business Requirement: Service methods return both Ids and Names for lookup fields to meet downstream flow requirements.
 * Handlers call into this class to perform CRUD and search operations.
 * @description Service class for Checklist Asset operations.
 * Handles all business logic, including CRUD, search, and permission enforcement.
 *
 * Key fields referenced:
 *   - `Checklist__c`
 *   - `Asset__c`, `Course__c`, `Curriculum__c`
 *   - `Description__c`, `Order__c`, `Week__c`, `Day__c`, `Actions__c`
 *   - `CreatedDate`
 *   - `LastModifiedDate`
 *
 * @version 4.0
 */
public with sharing class FRAGENTChecklistAssetService extends FRAGENTGeneralService {

    public class SearchResult extends FRAGENTGeneralService.Result {
        @AuraEnabled public Integer totalCount;

        public SearchResult(Boolean success, List<SObject> records, Integer totalCount, List<String> errors) {
            super(success, records, errors);
            this.totalCount = totalCount;
        }
    }

    /**
     * @description Retrieves a Checklist_Asset__c record by ID.
     * Business Requirement: Query returns related Names so flows show
     *                       meaningful information.
     */
    public static Result getById(Id checklistAssetId) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_RETRIEVE);
        List<Checklist_Asset__c> results = queryChecklistAssets([SELECT Id FROM Checklist_Asset__c WHERE Id = :checklistAssetId LIMIT 1]);
        return new Result(true, results, new List<String>());
    }

    /**
     * @description Creates Checklist_Asset__c records.
     * Business Requirement: Return IDs and Names of created records so
     *                       the handler can present them back to the agent.
     */
    public static Result create(List<Checklist_Asset__c> toCreate) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);

        List<String> errorMessages = new List<String>();
        List<Id> successIds = new List<Id>();

        Database.SaveResult[] srs = Database.insert(toCreate, false);
        for (Database.SaveResult sr : srs) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            } else {
                for (Database.Error err : sr.getErrors()) {
                    errorMessages.add('Error creating checklist asset: ' + err.getMessage());
                }
            }
        }

        List<Checklist_Asset__c> toQuery = new List<Checklist_Asset__c>();
        for (Id idVal : successIds) toQuery.add(new Checklist_Asset__c(Id = idVal));
        List<SObject> createdRecords = successIds.isEmpty() ? new List<SObject>() : queryChecklistAssets(toQuery);

        return new Result(errorMessages.isEmpty(), createdRecords, errorMessages);
    }

    /**
     * @description Updates Checklist_Asset__c records.
     * Business Requirement: Updated assets are re-queried to include their
     *                       Names for downstream processing.
     */
    public static Result updateRecords(List<Checklist_Asset__c> toUpdate) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);

        List<String> errorMessages = new List<String>();
        List<Id> successIds = new List<Id>();

        Database.SaveResult[] srs = Database.update(toUpdate, false);
        for (Database.SaveResult sr : srs) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            } else {
                for (Database.Error err : sr.getErrors()) {
                    errorMessages.add('Error updating checklist asset ' + sr.getId() + ': ' + err.getMessage());
                }
            }
        }

        List<Checklist_Asset__c> toQuery = new List<Checklist_Asset__c>();
        for (Id idVal : successIds) toQuery.add(new Checklist_Asset__c(Id = idVal));
        List<SObject> updatedRecords = successIds.isEmpty() ? new List<SObject>() : queryChecklistAssets(toQuery);

        return new Result(errorMessages.isEmpty(), updatedRecords, errorMessages);
    }

    /**
     * @description Deletes Checklist_Asset__c records.
     * Business Requirement: Ensure deletion is permitted and report any errors
     *                       with specific messages.
     */
    public static Result remove(List<Id> idsToRemove) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_CRUD);
        if (idsToRemove == null || idsToRemove.isEmpty()) {
            return new Result(true, null, new List<String>());
        }

        List<Checklist_Asset__c> toDelete = [SELECT Id FROM Checklist_Asset__c WHERE Id IN :idsToRemove];
        if (toDelete.isEmpty()) {
            return new Result(true, null, new List<String>());
        }

        List<String> errorMessages = new List<String>();
        Database.DeleteResult[] drs = Database.delete(toDelete, false);
        for (Database.DeleteResult dr : drs) {
            if (!dr.isSuccess()) {
                for (Database.Error err : dr.getErrors()) {
                    errorMessages.add('Error deleting checklist asset ' + dr.getId() + ': ' + err.getMessage());
                }
            }
        }

        return new Result(errorMessages.isEmpty(), null, errorMessages);
    }
    
    /**
     * @description Searches Checklist_Asset__c records by checklist, keyword, or
     *              date criteria.
     * Business Requirement: Results include related Names so flows present
     *                       meaningful asset information.
     */
    public static SearchResult search(Id checklistId, String searchTerm, String dateFieldToSearch, String dateLiteral, Date startDate, Date endDate, Integer recordLimit, Integer offset) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_RETRIEVE);

        String targetDateField = String.isNotBlank(dateFieldToSearch) ? dateFieldToSearch : 'CreatedDate';
        Set<String> validDateFields = new Set<String>{'CreatedDate', 'LastModifiedDate'};
        if (!validDateFields.contains(targetDateField)) {
            return new SearchResult(false, null, 0, new List<String>{'Invalid date field specified: ' + targetDateField});
        }

        List<String> whereClauses = new List<String>();
        Map<String, Object> bindVars = new Map<String, Object>();
        
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
                // Checklist_Asset__c Name is an auto-number, so search on Description instead.
                String queryTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';
                whereClauses.add('Description__c LIKE :queryTerm');
                bindVars.put('queryTerm', queryTerm);
            }
        } catch (Exception e) {
            return new SearchResult(false, null, 0, new List<String>{'Search failed due to invalid input: ' + e.getMessage()});
        }
       
        String finalWhereClause = whereClauses.isEmpty() ? '' : 'WHERE ' + String.join(whereClauses, ' AND ');
        
        String countQuery = 'SELECT count() FROM Checklist_Asset__c ' + finalWhereClause;
        String mainQuery = 'SELECT Id, Name, Checklist__c, Checklist__r.Name, Asset__c, Asset__r.Name, Course__c, Course__r.Name, Curriculum__c, Curriculum__r.Name, Description__c, Order__c, Week__c, Day__c, Actions__c, CreatedDate, LastModifiedDate ' +
                           'FROM Checklist_Asset__c ' + finalWhereClause + ' ORDER BY Order__c ASC';

        if (recordLimit != null) mainQuery += ' LIMIT ' + recordLimit;
        if (offset != null && offset > 0) mainQuery += ' OFFSET ' + offset;

        try {
            Integer totalCount = Database.countQueryWithBinds(countQuery, bindVars, AccessLevel.USER_MODE);
            List<Checklist_Asset__c> records = totalCount > 0 ? Database.queryWithBinds(mainQuery, bindVars, AccessLevel.USER_MODE) : new List<Checklist_Asset__c>();
            return new SearchResult(true, records, totalCount, new List<String>());
        } catch (Exception e) {
            return new SearchResult(false, null, 0, new List<String>{'Search query failed: ' + e.getMessage()});
        }
    }

    private static List<Checklist_Asset__c> queryChecklistAssets(List<Checklist_Asset__c> source) {
        Set<Id> ids = new Set<Id>();
        for (Checklist_Asset__c item : source) ids.add(item.Id);
        return [
            SELECT Id, Name,
                   Checklist__c, Checklist__r.Name,
                   Asset__c, Asset__r.Name,
                   Course__c, Course__r.Name,
                   Curriculum__c, Curriculum__r.Name,
                   Description__c, Order__c, Week__c, Day__c, Actions__c, CreatedDate, LastModifiedDate
            FROM Checklist_Asset__c WHERE Id IN :ids ORDER BY Order__c ASC
        ];
    }
}