/**
 * @description Simplified content search service for agent actions.
 * Searches across Course, Asset, and Curriculum objects with minimal dependencies.
 * @version 2.0
 */
public with sharing class ANAgentContentSearchServiceV2 {

    /**
     * @description Unified content record for search results
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
        @AuraEnabled public Double completionRate { get; set; }
        @AuraEnabled public String link { get; set; }

        public UnifiedContent() {
            this.learnerCount = 0;
            this.completionCount = 0;
            this.completionRate = 0.0;
        }

        public UnifiedContent(SObject record, String recordType) {
            this();
            this.id = record.Id;
            this.name = (String)record.get('Name');
            this.description = (String)record.get('Description__c');
            this.status = (String)record.get('Status__c');
            this.createdDate = (Datetime)record.get('CreatedDate');
            this.lastModifiedDate = (Datetime)record.get('LastModifiedDate');
            this.type = recordType;
        }
    }

    /**
     * @description Search result wrapper with routing information
     */
    public class ContentSearchResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public List<UnifiedContent> records { get; set; }
        @AuraEnabled public List<String> errors { get; set; }
        @AuraEnabled public Integer totalCount { get; set; }
        @AuraEnabled public String searchSource { get; set; }

        public ContentSearchResult() {
            this.success = false;
            this.records = new List<UnifiedContent>();
            this.errors = new List<String>();
            this.totalCount = 0;
            this.searchSource = 'ACT';
        }

        public ContentSearchResult(Boolean success, List<UnifiedContent> records, List<String> errors) {
            this();
            this.success = success;
            this.records = records != null ? records : new List<UnifiedContent>();
            this.errors = errors != null ? errors : new List<String>();
            this.totalCount = this.records.size();
        }

        public ContentSearchResult(Boolean success, List<UnifiedContent> records, List<String> errors, String searchSource) {
            this(success, records, errors);
            this.searchSource = searchSource;
        }
    }

    /**
     * @description Main search method
     * @param searchTerm The search term to look for
     * @param contentType Optional content type filter (Course, Asset, Curriculum)
     * @return ContentSearchResult with search results
     */
    public static ContentSearchResult search(String searchTerm, String contentType) {
        ContentSearchResult result = new ContentSearchResult();
        
        try {
            // Validate input
            if (String.isBlank(searchTerm)) {
                result.errors.add('Search term is required.');
                return result;
            }

            // Determine which objects to search
            List<String> objectsToSearch = new List<String>();
            if (String.isBlank(contentType)) {
                objectsToSearch.addAll(new List<String>{'Course__c', 'Asset__c', 'Curriculum__c'});
            } else {
                String objectName = getObjectNameForType(contentType);
                if (String.isNotBlank(objectName)) {
                    objectsToSearch.add(objectName);
                } else {
                    result.errors.add('Invalid content type: ' + contentType + '. Valid types: Course, Asset, Curriculum');
                    return result;
                }
            }

            // Perform search
            List<UnifiedContent> allResults = new List<UnifiedContent>();
            
            for (String objectName : objectsToSearch) {
                List<UnifiedContent> objectResults = searchObject(objectName, searchTerm);
                if (objectResults != null) {
                    allResults.addAll(objectResults);
                }
            }

            // Populate enrollment and completion data for courses
            populateLearnerCountData(allResults);
            
            result.success = true;
            result.records = allResults;
            result.totalCount = allResults.size();
            
            if (allResults.isEmpty()) {
                result.errors.add('No content found matching: ' + searchTerm);
            }

        } catch (Exception e) {
            result.success = false;
            result.errors.add('Search failed: ' + e.getMessage());
        }

        return result;
    }

    /**
     * @description Search a specific object
     * @param objectName The API name of the object to search
     * @param searchTerm The search term
     * @return List of UnifiedContent records
     */
    private static List<UnifiedContent> searchObject(String objectName, String searchTerm) {
        List<UnifiedContent> results = new List<UnifiedContent>();
        
        try {
            // Check if object is accessible
            if (!Schema.getGlobalDescribe().containsKey(objectName)) {
                return results;
            }

            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            if (!objectType.getDescribe().isAccessible()) {
                return results;
            }

            // Build query based on object type
            String query = buildSearchQuery(objectName, searchTerm);
            if (String.isBlank(query)) {
                return results;
            }

            // Execute query
            List<SObject> records = Database.query(query);
            
            // Convert to UnifiedContent
            String recordType = getTypeForObject(objectName);
            for (SObject record : records) {
                results.add(new UnifiedContent(record, recordType));
            }
            
            // Populate learner count data for courses
            if (objectName == 'Course__c') {
                populateLearnerCountData(results);
            }

        } catch (Exception e) {
            System.debug('Error searching ' + objectName + ': ' + e.getMessage());
        }

        return results;
    }

    /**
     * @description Build search query for an object
     * @param objectName The API name of the object
     * @param searchTerm The search term
     * @return SOQL query string
     */
    private static String buildSearchQuery(String objectName, String searchTerm) {
        String baseQuery = 'SELECT Id, Name, Description__c, Status__c, CreatedDate, LastModifiedDate, Share_URL__c FROM ' + objectName;
        
        // Add WHERE clause for search
        String whereClause = ' WHERE (Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
        
        // Add Description__c if the field exists
        try {
            Schema.SObjectField descField = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get('Description__c');
            if (descField != null && descField.getDescribe().isAccessible()) {
                whereClause += ' OR Description__c LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
            }
        } catch (Exception e) {
            // Field doesn't exist or not accessible, continue without it
        }
        
        whereClause += ')';
        
        // Add Status__c filter if the field exists
        try {
            Schema.SObjectField statusField = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get('Status__c');
            if (statusField != null && statusField.getDescribe().isAccessible()) {
                whereClause += ' AND Status__c = \'Active\'';
            }
        } catch (Exception e) {
            // Field doesn't exist or not accessible, continue without it
        }
        
        return baseQuery + whereClause + ' ORDER BY Name LIMIT 50';
    }

    /**
     * @description Get object name for content type
     * @param contentType The content type (Course, Asset, Curriculum)
     * @return Object API name
     */
    private static String getObjectNameForType(String contentType) {
        Map<String, String> typeToObject = new Map<String, String>{
            'Course' => 'Course__c',
            'Asset' => 'Asset__c',
            'Curriculum' => 'Curriculum__c'
        };
        return typeToObject.get(contentType);
    }

    /**
     * @description Get content type for object name
     * @param objectName The object API name
     * @return Content type string
     */
    private static String getTypeForObject(String objectName) {
        Map<String, String> objectToType = new Map<String, String>{
            'Course__c' => 'Course',
            'Asset__c' => 'Asset',
            'Curriculum__c' => 'Curriculum'
        };
        return objectToType.get(objectName);
    }
    
    /**
     * @description Populates learner count data for course records
     * @param courseRecords List of UnifiedContent records to populate
     */
    private static void populateLearnerCountData(List<UnifiedContent> courseRecords) {
        if (courseRecords == null || courseRecords.isEmpty()) {
            return;
        }
        
        try {
            // Get course IDs
            Set<String> courseIds = new Set<String>();
            for (UnifiedContent content : courseRecords) {
                if (content.type == 'Course' && String.isNotBlank(content.id)) {
                    courseIds.add(content.id);
                }
            }
            
            if (courseIds.isEmpty()) {
                return;
            }
            
            // Query Assigned_Course__c to get learner counts
            List<AggregateResult> learnerCounts = [
                SELECT Course__c, COUNT(Id) learnerCount
                FROM Assigned_Course__c 
                WHERE Course__c IN :courseIds 
                GROUP BY Course__c
            ];
            
            // Query Assigned_Course__c to get completion counts
            List<AggregateResult> completionCounts = [
                SELECT Course__c, COUNT(Id) completionCount
                FROM Assigned_Course__c 
                WHERE Course__c IN :courseIds AND Completed__c = true
                GROUP BY Course__c
            ];
            
            // Create a map for quick lookup
            Map<String, Map<String, Integer>> courseStats = new Map<String, Map<String, Integer>>();
            
            // Process total learner counts
            for (AggregateResult ar : learnerCounts) {
                String courseId = (String)ar.get('Course__c');
                Integer totalLearners = (Integer)ar.get('learnerCount');
                
                if (!courseStats.containsKey(courseId)) {
                    courseStats.put(courseId, new Map<String, Integer>{
                        'total' => totalLearners,
                        'completed' => 0
                    });
                } else {
                    courseStats.get(courseId).put('total', totalLearners);
                }
            }
            
            // Process completion counts
            for (AggregateResult ar : completionCounts) {
                String courseId = (String)ar.get('Course__c');
                Integer completions = (Integer)ar.get('completionCount');
                
                if (courseStats.containsKey(courseId)) {
                    courseStats.get(courseId).put('completed', completions);
                }
            }
            
            // Update the UnifiedContent records
            for (UnifiedContent content : courseRecords) {
                if (content.type == 'Course' && courseStats.containsKey(content.id)) {
                    Map<String, Integer> stats = courseStats.get(content.id);
                    content.learnerCount = stats.get('total');
                    content.completionCount = stats.get('completed');
                    
                    // Calculate completion rate
                    if (content.learnerCount > 0) {
                        content.completionRate = (Double)content.completionCount / content.learnerCount * 100;
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('Error populating learner count data: ' + e.getMessage());
        }
    }

    /**
     * @description Search Consensus demo videos
     * @param searchTerm The search term to look for
     * @return ContentSearchResult with Consensus content
     */
    public static ContentSearchResult searchConsensus(String searchTerm) {
        ContentSearchResult result = new ContentSearchResult();
        result.searchSource = 'CONSENSUS';
        
        try {
            // Validate input
            if (String.isBlank(searchTerm)) {
                result.errors.add('Search term is required.');
                return result;
            }

            // Search Consensus content using existing Consensus service
            List<ANAgentConsensusContentSearchService.ConsensusContent> consensusResults = 
                ANAgentConsensusContentSearchService.searchBasic(searchTerm, 25);

            // Convert to UnifiedContent format
            List<UnifiedContent> unifiedResults = new List<UnifiedContent>();
            for (ANAgentConsensusContentSearchService.ConsensusContent consensusContent : consensusResults) {
                UnifiedContent unified = new UnifiedContent();
                unified.id = consensusContent.id;
                unified.name = consensusContent.title;
                unified.description = consensusContent.description;
                unified.type = 'Consensus';
                unified.status = consensusContent.isPublished ? 'Published' : 'Draft';
                unified.createdDate = consensusContent.createdAt;
                unified.learnerCount = 0; // Consensus doesn't have learner data
                unified.completionCount = 0;
                unified.completionRate = 0.0;
                unified.link = consensusContent.previewLink; // Add the preview link
                unifiedResults.add(unified);
            }

            result.success = true;
            result.records = unifiedResults;
            result.totalCount = unifiedResults.size();
            
            if (unifiedResults.isEmpty()) {
                result.errors.add('No Consensus demo videos found matching: ' + searchTerm);
            }

        } catch (Exception e) {
            result.success = false;
            result.errors.add('Consensus search failed: ' + e.getMessage());
            System.debug('Consensus search error: ' + e.getMessage());
        }

        return result;
    }

    /**
     * @description Search both ACT and Consensus content
     * @param searchTerm The search term to look for
     * @param contentType Optional content type filter for ACT content
     * @return ContentSearchResult with combined content
     */
    public static ContentSearchResult searchBoth(String searchTerm, String contentType) {
        ContentSearchResult result = new ContentSearchResult();
        result.searchSource = 'BOTH';
        
        try {
            // Validate input
            if (String.isBlank(searchTerm)) {
                result.errors.add('Search term is required.');
                return result;
            }

            List<UnifiedContent> allResults = new List<UnifiedContent>();

            // Search ACT content (preserve existing lifecycle features)
            ContentSearchResult actResult = search(searchTerm, contentType);
            if (actResult.success && actResult.records != null) {
                allResults.addAll(actResult.records);
            }

            // Search Consensus content
            ContentSearchResult consensusResult = searchConsensus(searchTerm);
            if (consensusResult.success && consensusResult.records != null) {
                allResults.addAll(consensusResult.records);
            }

            result.success = true;
            result.records = allResults;
            result.totalCount = allResults.size();
            
            if (allResults.isEmpty()) {
                result.errors.add('No content found matching: ' + searchTerm + ' in either ACT or Consensus sources');
            }

        } catch (Exception e) {
            result.success = false;
            result.errors.add('Combined search failed: ' + e.getMessage());
            System.debug('Combined search error: ' + e.getMessage());
        }

        return result;
    }
} 