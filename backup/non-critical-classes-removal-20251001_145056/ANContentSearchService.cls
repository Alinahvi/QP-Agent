/**
 * TEMPLATE SERVICE - Houses business logic and direct object manipulation in our handler/service pattern.
 * Business Requirement: Service methods return both Ids and Names for lookup fields to meet downstream flow requirements.
 * Handlers call into this class to perform CRUD and search operations.
 * @description Service class for searching across different content objects (Asset, Course, Curriculum).
 * It uses SOSL for keyword search and provides a unified data model for results.
 *
 * Returned `UnifiedContent` records include fields:
 *   - `Id` and `Name`
 *   - `Description__c` and `Status__c`
 *   - `CreatedDate` and `LastModifiedDate`
 *   - `Published_Date__c`, `Last_Maintained__c`, `Archived_Date__c`
 *
 * @version 4.0
 */
public with sharing class ANContentSearchService extends FRAGENTGeneralService {

    public class UnifiedContent {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public Datetime createdDate { get; set; }
        @AuraEnabled public Datetime lastModifiedDate { get; set; }
        @AuraEnabled public Date publishedDate { get; set; }
        @AuraEnabled public Date lastMaintainedDate { get; set; }
        @AuraEnabled public Date archivedDate { get; set; }
        @AuraEnabled public Integer learnerCount { get; set; }
        @AuraEnabled public Integer completionCount { get; set; }
        @AuraEnabled public Decimal completionRate { get; set; }

        public UnifiedContent(SObject record, String recordType) {
            this.id = record.Id;
            this.name = (String)record.get('Name');
            this.description = (String)record.get('Description__c');
            this.status = (String)record.get('Status__c');
            this.createdDate = (Datetime)record.get('CreatedDate');
            this.lastModifiedDate = (Datetime)record.get('LastModifiedDate');
            this.publishedDate = (Date)record.get('Published_Date__c');
            this.lastMaintainedDate = null; // Will be set separately since it's a Datetime field
            this.archivedDate = (Date)record.get('Archived_Date__c');
            this.type = recordType;
            this.learnerCount = 0;
            this.completionCount = 0;
            this.completionRate = 0;
            
            // Handle last_maintained__c as Datetime and convert to Date
            Object lastMaintained = record.get('Last_Maintained__c');
            if (lastMaintained instanceof Datetime) {
                this.lastMaintainedDate = ((Datetime)lastMaintained).date();
            } else if (lastMaintained instanceof Date) {
                this.lastMaintainedDate = (Date)lastMaintained;
            }
        }
    }

    public class SearchResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public List<UnifiedContent> records { get; set; }
        @AuraEnabled public Integer totalCount { get; set; }
        @AuraEnabled public List<String> errors { get; set; }

        public SearchResult(Boolean success, List<UnifiedContent> records, Integer totalCount, List<String> errors) {
            this.success = success;
            this.records = records;
            this.totalCount = totalCount;
            this.errors = errors;
        }
    }

    /**
     * @description Wrapper class for sorting UnifiedContent objects by fuzziness.
     */
    private class RankedContent implements Comparable {
        public UnifiedContent content;
        public Integer distance;

        public RankedContent(UnifiedContent content, Integer distance) {
            this.content = content;
            this.distance = distance;
        }

        public Integer compareTo(Object obj) {
            RankedContent other = (RankedContent)obj;
            if (this.distance == other.distance) {
                return this.content.name.compareTo(other.content.name);
            }
            return this.distance - other.distance;
        }
    }
    
    /**
     * @description Searches content records across Asset, Course, and Curriculum types.
     * Business Requirement: Returned UnifiedContent objects expose both Id and Name
     *                       so handlers can present readable results.
     */
    public static SearchResult search(String searchTerm, String contentType, String dateFieldToSearch, String dateLiteral, Date startDate, Date endDate, Integer recordLimit, Integer offset) {
        checkPermission(FRAGENTGeneralService.PERM_LABEL_RETRIEVE);

        if (String.isBlank(searchTerm) && String.isBlank(dateLiteral) && startDate == null && endDate == null) {
            return new SearchResult(false, null, 0, new List<String>{'A search term or a date criterion is required.'});
        }
        
        List<String> returningFields = new List<String>{
            'Id', 'Name', 'Description__c', 'Status__c', 'CreatedDate', 'LastModifiedDate', 
            'Published_Date__c', 'Last_Maintained__c', 'Archived_Date__c'
        };
        String returningClause = '(' + String.join(returningFields, ',') + ')';

        Map<String, String> validTypes = new Map<String, String>{
            'Asset' => 'Asset__c' + returningClause,
            'Course' => 'Course__c' + returningClause,
            'Curriculum' => 'Curriculum__c' + returningClause
        };

        List<String> typesToSearch = new List<String>();
        if (String.isBlank(contentType) || contentType.equalsIgnoreCase('All')) {
            typesToSearch.addAll(validTypes.keySet());
        } else if (validTypes.containsKey(contentType)) {
            typesToSearch.add(contentType);
        } else {
            return new SearchResult(false, null, 0, new List<String>{'Invalid content type specified.'});
        }

        List<List<SObject>> searchResults;
        if (String.isNotBlank(searchTerm)) {
            List<String> returningQueries = new List<String>();
            for(String type : typesToSearch) returningQueries.add(validTypes.get(type));
            String soslQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING ' + String.join(returningQueries, ', ') + ' LIMIT 2000';
            searchResults = Search.query(soslQuery);

            // Fallback to SOQL when SOSL returns no results (common in tests where search indexes are not populated)
            Boolean hasResults = false;
            for (List<SObject> lst : searchResults) {
                if (!lst.isEmpty()) { hasResults = true; break; }
            }
            if (!hasResults) {
                searchResults = new List<List<SObject>>();
                Map<String, String> objectMap = new Map<String, String>{
                    'Asset' => 'Asset__c',
                    'Course' => 'Course__c',
                    'Curriculum' => 'Curriculum__c'
                };
                String likeTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';
                for (String type : typesToSearch) {
                    String soql = 'SELECT ' + String.join(returningFields, ',') +
                                  ' FROM ' + objectMap.get(type) +
                                  ' WHERE Name LIKE \'' + likeTerm + '\'' +
                                  ' LIMIT 2000';
                    searchResults.add(Database.query(soql));
                }
            }
        } else {
            // If no search term, initialize empty lists to allow date filtering to proceed on all specified types
            searchResults = new List<List<SObject>>();
            for (Integer i = 0; i < typesToSearch.size(); i++) {
                searchResults.add(new List<SObject>());
            }
        }
        
        List<UnifiedContent> unifiedResults = new List<UnifiedContent>();
        for (Integer i = 0; i < searchResults.size(); i++) {
            String type = typesToSearch[i];
            for (SObject record : searchResults[i]) {
                unifiedResults.add(new UnifiedContent(record, type));
            }
        }

        // If no results were found and a search term was provided, perform a
        // fuzzy fallback by retrieving all candidate records for the specified
        // types and filtering them by Levenshtein distance. This is primarily
        // used in tests where search indexes may not be populated.
        if (unifiedResults.isEmpty() && String.isNotBlank(searchTerm)) {
            searchResults = new List<List<SObject>>();
            Map<String, String> objectMap = new Map<String, String>{
                'Asset' => 'Asset__c',
                'Course' => 'Course__c',
                'Curriculum' => 'Curriculum__c'
            };
            for (String type : typesToSearch) {
                String soql = 'SELECT ' + String.join(returningFields, ',') +
                              ' FROM ' + objectMap.get(type) +
                              ' LIMIT 2000';
                searchResults.add(Database.query(soql));
            }

            for (Integer i = 0; i < searchResults.size(); i++) {
                String type = typesToSearch[i];
                for (SObject record : searchResults[i]) {
                    unifiedResults.add(new UnifiedContent(record, type));
                }
            }

            // Filter candidates by a threshold of 40% of the search term's length
            Integer threshold = Math.max(1, (Integer)(searchTerm.length() * 0.4));
            List<UnifiedContent> filtered = new List<UnifiedContent>();
            for (UnifiedContent uc : unifiedResults) {
                if (uc.name.getLevenshteinDistance(searchTerm, threshold) != -1) {
                    filtered.add(uc);
                }
            }
            unifiedResults = filtered;
        }

        // Apply date filtering post-SOSL
        if (String.isNotBlank(dateLiteral) || startDate != null || endDate != null) {
            String targetDateField = String.isNotBlank(dateFieldToSearch) ? dateFieldToSearch : 'CreatedDate';
            unifiedResults = filterByDate(unifiedResults, targetDateField, dateLiteral, startDate, endDate);
        }

        // Apply fuzzy ranking if a search term was provided
        if (String.isNotBlank(searchTerm)) {
            unifiedResults = fuzzyRankAndSortContent(unifiedResults, searchTerm);
        }

        // Apply pagination
        Integer totalCount = unifiedResults.size();
        List<UnifiedContent> paginatedResults = new List<UnifiedContent>();
        Integer maxResults = (recordLimit == null || recordLimit <= 0) ? 50 : recordLimit;
        Integer startOffset = (offset == null || offset < 0) ? 0 : offset;
        for (Integer i = startOffset; i < totalCount && paginatedResults.size() < maxResults; i++) {
            paginatedResults.add(unifiedResults[i]);
        }
        
        // Populate learner count data for courses
        populateLearnerCountData(paginatedResults);
        
        return new SearchResult(true, paginatedResults, totalCount, new List<String>());
    }

    /**
     * @description Populates learner count data for course records
     * @param contentList List of UnifiedContent records to populate
     */
    private static void populateLearnerCountData(List<UnifiedContent> contentList) {
        if (contentList == null || contentList.isEmpty()) {
            return;
        }
        
        // Get course names to query
        Set<String> courseNames = new Set<String>();
        for (UnifiedContent content : contentList) {
            if (content.type == 'Course' && String.isNotBlank(content.name)) {
                courseNames.add(content.name);
            }
        }
        
        if (courseNames.isEmpty()) {
            return;
        }
        
        try {
            // Query for total assigned count per course
            Map<String, Integer> totalAssignedMap = new Map<String, Integer>();
            for (AggregateResult ar : [
                SELECT Course__r.Name courseName, COUNT(Id) totalCount
                FROM Assigned_Course__c 
                WHERE Course__r.Name IN :courseNames 
                AND Inactive__c = false
                GROUP BY Course__r.Name
            ]) {
                String courseName = (String)ar.get('courseName');
                Integer totalCount = (Integer)ar.get('totalCount');
                totalAssignedMap.put(courseName, totalCount);
            }
            
            // Query for completion count per course
            Map<String, Integer> completionCountMap = new Map<String, Integer>();
            for (AggregateResult ar : [
                SELECT Course__r.Name courseName, COUNT_DISTINCT(Learner_Profile__c) completionCount
                FROM Assigned_Course__c 
                WHERE Course__r.Name IN :courseNames 
                AND Completed__c = true 
                AND Inactive__c = false
                AND Learner_Profile__c != null
                GROUP BY Course__r.Name
            ]) {
                String courseName = (String)ar.get('courseName');
                Integer completionCount = (Integer)ar.get('completionCount');
                completionCountMap.put(courseName, completionCount);
            }
            
            // Populate the data
            for (UnifiedContent content : contentList) {
                if (content.type == 'Course' && String.isNotBlank(content.name)) {
                    Integer totalAssigned = totalAssignedMap.get(content.name);
                    Integer completionCount = completionCountMap.get(content.name);
                    
                    content.learnerCount = totalAssigned != null ? totalAssigned : 0;
                    content.completionCount = completionCount != null ? completionCount : 0;
                    
                    // Calculate completion rate
                    if (content.learnerCount > 0) {
                        content.completionRate = (content.completionCount * 100.0 / content.learnerCount).setScale(1);
                    } else {
                        content.completionRate = 0;
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('Error populating learner count data: ' + e.getMessage());
            // Continue without learner count data if there's an error
        }
    }

    private static List<UnifiedContent> filterByDate(List<UnifiedContent> results, String field, String dateLiteral, Date startDate, Date endDate) {
        if (String.isBlank(field)) return results;
        
        Date startDt, endDt;
        if (String.isNotBlank(dateLiteral)) {
            // Handle date literals manually
            String upperLiteral = dateLiteral.toUpperCase();
            if (upperLiteral == 'TODAY') {
                startDt = Date.today();
                endDt = Date.today();
            } else if (upperLiteral == 'YESTERDAY') {
                startDt = Date.today().addDays(-1);
                endDt = Date.today().addDays(-1);
            } else if (upperLiteral == 'LAST_7_DAYS') {
                startDt = Date.today().addDays(-7);
                endDt = Date.today();
            } else if (upperLiteral == 'LAST_30_DAYS') {
                startDt = Date.today().addDays(-30);
                endDt = Date.today();
            } else if (upperLiteral == 'LAST_90_DAYS') {
                startDt = Date.today().addDays(-90);
                endDt = Date.today();
            } else if (upperLiteral == 'THIS_MONTH') {
                startDt = Date.today().toStartOfMonth();
                endDt = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
            } else if (upperLiteral == 'LAST_MONTH') {
                startDt = Date.today().addMonths(-1).toStartOfMonth();
                endDt = Date.today().toStartOfMonth().addDays(-1);
            } else if (upperLiteral.contains(':')) {
                // Handle N_DAYS format like LAST_N_DAYS:30
                List<String> parts = upperLiteral.split(':');
                if (parts.size() == 2 && parts[0] == 'LAST_N_DAYS' && parts[1].isNumeric()) {
                    Integer days = Integer.valueOf(parts[1]);
                    startDt = Date.today().addDays(-days);
                    endDt = Date.today();
                }
            }
        } else {
            startDt = startDate;
            endDt = endDate;
        }

        if (startDt == null && endDt == null) return results;

        List<UnifiedContent> filteredResults = new List<UnifiedContent>();
        for (UnifiedContent content : results) {
            Object fieldValue = getFieldValue(content, field);
            if (fieldValue == null) continue;

            Date recordDate;
            if (fieldValue instanceof Datetime) {
                recordDate = ((Datetime)fieldValue).date();
            } else if (fieldValue instanceof Date) {
                recordDate = (Date)fieldValue;
            } else {
                continue;
            }
            
            Boolean include = true;
            if (startDt != null && recordDate < startDt) include = false;
            if (endDt != null && recordDate > endDt) include = false;
            
            if (include) filteredResults.add(content);
        }
        return filteredResults;
    }

    /**
     * @description Ranks and sorts content records by Levenshtein distance of their names.
     */
    private static List<UnifiedContent> fuzzyRankAndSortContent(List<UnifiedContent> candidates, String searchTerm) {
        if (candidates == null || candidates.isEmpty() || String.isBlank(searchTerm)) {
            return candidates;
        }

        List<RankedContent> ranked = new List<RankedContent>();
        for (UnifiedContent uc : candidates) {
            Integer thresh = Math.max(uc.name.length(), searchTerm.length());
            Integer distance = uc.name.getLevenshteinDistance(searchTerm, thresh);
            if (distance == -1) {
                distance = thresh;
            }
            ranked.add(new RankedContent(uc, distance));
        }

        ranked.sort();
        List<UnifiedContent> sorted = new List<UnifiedContent>();
        for (RankedContent rc : ranked) {
            sorted.add(rc.content);
        }
        return sorted;
    }

    private static Object getFieldValue(UnifiedContent content, String fieldName) {
        if (fieldName.equalsIgnoreCase('CreatedDate')) return content.createdDate;
        if (fieldName.equalsIgnoreCase('LastModifiedDate')) return content.lastModifiedDate;
        if (fieldName.equalsIgnoreCase('Published_Date__c')) return content.publishedDate;
        if (fieldName.equalsIgnoreCase('Last_Maintained__c')) return content.lastMaintainedDate;
        if (fieldName.equalsIgnoreCase('Archived_Date__c')) return content.archivedDate;
        return null;
    }
} 