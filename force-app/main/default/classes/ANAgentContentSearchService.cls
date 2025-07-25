public with sharing class ANAgentContentSearchService extends FRAGENTGeneralService {

    /**
     * Unified DTO for content records.
     */
    public class UnifiedContent {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public Datetime createdDate { get; set; }
        @AuraEnabled public Datetime lastModifiedDate { get; set; }
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
            this.type = recordType;
            this.learnerCount = 0;
            this.completionCount = 0;
            this.completionRate = 0.0;
        }
    }

    /**
     * @description A wrapper class to hold the list of content results. This is specific to content search.
     */
    public class ContentSearchResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public List<UnifiedContent> records { get; set; }
        @AuraEnabled public List<String> errors { get; set; }

        public ContentSearchResult(Boolean success, List<UnifiedContent> records, List<String> errors) {
            this.success = success;
            this.records = records;
            this.errors = errors;
        }
    }

    /**
     * Searches across Course, Asset, and Curriculum objects.
     */
    public static ContentSearchResult search(Map<String, Object> params) {
        if (!hasPermission(FRAGENTGeneralService.PERM_LABEL_CRUD)) {
            return new ContentSearchResult(false, null, new List<String>{'Insufficient permission: ' + FRAGENTGeneralService.PERM_LABEL_CRUD});
        }

        String searchTerm = (String)params.get('searchTerm');
        String contentType = (String)params.get('contentType');

        if (String.isBlank(searchTerm)) {
            return new ContentSearchResult(false, null, new List<String>{'Search term is required.'});
        }

        try {
            Map<String, String> validTypes = new Map<String, String>{
                'Course' => 'Course__c (Id, Name, Description__c, Status__c, CreatedDate, LastModifiedDate)',
                'Asset' => 'Asset__c (Id, Name, Description__c, Status__c, CreatedDate, LastModifiedDate)',
                'Curriculum' => 'Curriculum__c (Id, Name, Description__c, Status__c, CreatedDate, LastModifiedDate)'
            };

            List<String> typesToSearch = new List<String>();
            if (String.isBlank(contentType)) {
                typesToSearch.addAll(validTypes.keySet());
            } else if (validTypes.containsKey(contentType)) {
                typesToSearch.add(contentType);
            }

            if (typesToSearch.isEmpty()) {
                return new ContentSearchResult(false, null, new List<String>{'Invalid content type specified.'});
            }

            List<String> returningQueries = new List<String>();
            for(String type : typesToSearch) {
                returningQueries.add(validTypes.get(type));
            }

            String searchQuery = 'FIND :searchTerm IN ALL FIELDS RETURNING ' + String.join(returningQueries, ', ') + ' LIMIT 200';
            List<List<SObject>> results = Search.query(searchQuery);

            List<UnifiedContent> unifiedResults = new List<UnifiedContent>();
            for (Integer i = 0; i < results.size(); i++) {
                String type = typesToSearch[i];
                for (SObject record : results[i]) {
                    unifiedResults.add(new UnifiedContent(record, type));
                }
            }

            // Populate learner count data for courses
            populateLearnerCountData(unifiedResults);

            return new ContentSearchResult(true, unifiedResults, new List<String>());

        } catch (Exception e) {
            return new ContentSearchResult(false, null, new List<String>{e.getMessage()});
        }
    }

    /**
     * @description Populates learner count data for course records
     * @param contentList List of UnifiedContent records to populate
     */
    private static void populateLearnerCountData(List<UnifiedContent> contentList) {
        if (contentList == null || contentList.isEmpty()) return;

        // Filter to only course records
        List<UnifiedContent> courseRecords = new List<UnifiedContent>();
        Set<Id> courseIds = new Set<Id>();
        
        for (UnifiedContent content : contentList) {
            if (content.type == 'Course') {
                courseRecords.add(content);
                courseIds.add(content.id);
            }
        }

        if (courseIds.isEmpty()) return;

        try {
            // Query for learner count data
            Map<Id, Integer> totalLearnersMap = new Map<Id, Integer>();
            Map<Id, Integer> completionCountMap = new Map<Id, Integer>();

            // Get total learners per course
            for (AggregateResult ar : [
                SELECT Course__c courseId, COUNT(Id) totalLearners
                FROM Assigned_Course__c 
                WHERE Course__c IN :courseIds
                GROUP BY Course__c
            ]) {
                Id courseId = (Id)ar.get('courseId');
                Integer totalLearners = (Integer)ar.get('totalLearners');
                totalLearnersMap.put(courseId, totalLearners);
            }

            // Get completion count per course
            for (AggregateResult ar : [
                SELECT Course__c courseId, COUNT(Id) completionCount
                FROM Assigned_Course__c 
                WHERE Course__c IN :courseIds 
                AND Completion_Date__c != null
                GROUP BY Course__c
            ]) {
                Id courseId = (Id)ar.get('courseId');
                Integer completionCount = (Integer)ar.get('completionCount');
                completionCountMap.put(courseId, completionCount);
            }

            // Populate the data
            for (UnifiedContent course : courseRecords) {
                course.learnerCount = totalLearnersMap.get(course.id) != null ? totalLearnersMap.get(course.id) : 0;
                course.completionCount = completionCountMap.get(course.id) != null ? completionCountMap.get(course.id) : 0;
                
                if (course.learnerCount > 0) {
                    course.completionRate = (course.completionCount * 100.0) / course.learnerCount;
                } else {
                    course.completionRate = 0.0;
                }
            }
        } catch (Exception e) {
            System.debug('Error populating learner count data: ' + e.getMessage());
        }
    }
} 