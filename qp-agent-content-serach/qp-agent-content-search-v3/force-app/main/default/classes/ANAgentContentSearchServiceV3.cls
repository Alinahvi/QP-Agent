/**
 * @description Agent-safe content search service V3 (FR-style best practices)
 * Returns formatted String message (DTO pattern) for agent consumption.
 * ALL business logic, routing, and formatting lives here.
 * @version 3.0
 */
public with sharing class ANAgentContentSearchServiceV3 {

    // Lifecycle thresholds (configurable)
    private static final Integer LOW_ENROLLMENT_THRESHOLD = 20;
    private static final Double LOW_COMPLETION_THRESHOLD = 10.0;
    private static final Double LOW_CSAT_THRESHOLD = 3.0;
    private static final Integer HIGH_PERFORMING_ENROLLMENT = 50;
    private static final Double HIGH_PERFORMING_COMPLETION = 25.0;
    private static final Integer RESULT_LIMIT = 50;

    /**
     * @description Main search method - returns formatted String message
     * @param searchTerm The search term
     * @param contentType Optional content type filter
     * @param searchMode Search mode (AUTO, ACT, CONSENSUS, BOTH)
     * @param userUtterance Complete user utterance for routing
     * @return Formatted String message with all data
     */
    public static String search(String searchTerm, String contentType, String searchMode, String userUtterance) {
        try {
            // Validate input
            if (String.isBlank(searchTerm)) {
                return buildErrorMessage('Search term is required.');
            }

            // Determine search mode
            String mode = String.isNotBlank(searchMode) ? searchMode.toUpperCase() : 'AUTO';
            String utterance = String.isNotBlank(userUtterance) ? userUtterance : searchTerm;
            
            // Route to appropriate search method
            if (mode == 'ACT') {
                return searchACTContent(searchTerm, contentType);
            } else if (mode == 'CONSENSUS') {
                return searchConsensusContent(searchTerm);
            } else if (mode == 'BOTH') {
                return searchBothSources(searchTerm, contentType);
            } else {
                // AUTO mode - intelligent routing
                return intelligentRouting(searchTerm, contentType, utterance);
            }

        } catch (Exception e) {
            return buildErrorMessage('Search failed: ' + e.getMessage() + '\n\nStack trace: ' + e.getStackTraceString());
        }
    }

    /**
     * @description Intelligent routing based on keywords
     */
    private static String intelligentRouting(String searchTerm, String contentType, String userUtterance) {
        Set<String> consensusKeywords = new Set<String>{
            'consensus', 'demo', 'demo video', 'video', 'demo pack', 'presentation'
        };
        Set<String> actKeywords = new Set<String>{
            'act', 'course', 'training', 'learning', 'curriculum', 'asset'
        };
        
        Boolean isConsensusRequest = false;
        Boolean isACTRequest = false;
        String lowerUtterance = userUtterance.toLowerCase();
        
        for (String keyword : consensusKeywords) {
            if (lowerUtterance.contains(keyword)) {
                isConsensusRequest = true;
                break;
            }
        }
        for (String keyword : actKeywords) {
            if (lowerUtterance.contains(keyword)) {
                isACTRequest = true;
                break;
            }
        }
        
        String routingDecision = '';
        if (isConsensusRequest && isACTRequest) {
            routingDecision = 'Auto-routed to BOTH sources (both keyword sets detected)';
            return searchBothSources(searchTerm, contentType, routingDecision);
        } else if (isConsensusRequest && !isACTRequest) {
            routingDecision = 'Auto-routed to Consensus (keywords: ' + String.join(new List<String>(consensusKeywords), ', ') + ')';
            return searchConsensusContent(searchTerm, routingDecision);
        } else {
            // Default to ACT (whether ACT keywords present or not)
            routingDecision = isACTRequest 
                ? 'Auto-routed to ACT (keywords: ' + String.join(new List<String>(actKeywords), ', ') + ')'
                : 'Auto-routed to ACT (default)';
            return searchACTContent(searchTerm, contentType, routingDecision);
        }
    }

    /**
     * @description Search ACT content and return formatted message
     */
    private static String searchACTContent(String searchTerm, String contentType) {
        return searchACTContent(searchTerm, contentType, 'Explicit ACT mode');
    }

    private static String searchACTContent(String searchTerm, String contentType, String routingDecision) {
        List<UnifiedContent> results = new List<UnifiedContent>();
        Integer totalBeforeLimit = 0;
        
        // Determine which objects to search
        List<String> objectsToSearch = new List<String>();
        if (String.isBlank(contentType)) {
            objectsToSearch.addAll(new List<String>{'Course__c', 'Asset__c', 'Curriculum__c'});
        } else {
            String objectName = getObjectNameForType(contentType);
            if (String.isNotBlank(objectName)) {
                objectsToSearch.add(objectName);
            } else {
                return buildErrorMessage('Invalid content type: ' + contentType + '. Valid types: Course, Asset, Curriculum');
            }
        }

        // Search each object
        for (String objectName : objectsToSearch) {
            List<UnifiedContent> objectResults = searchObject(objectName, searchTerm);
            if (objectResults != null) {
                results.addAll(objectResults);
            }
        }

        // Populate lifecycle data for courses
        populateLearnerCountData(results);
        
        totalBeforeLimit = results.size();

        // Build and return formatted message
        return buildACTMessage(results, searchTerm, totalBeforeLimit, routingDecision);
    }

    /**
     * @description Search Consensus content and return formatted message
     */
    private static String searchConsensusContent(String searchTerm) {
        return searchConsensusContent(searchTerm, 'Explicit Consensus mode');
    }

    private static String searchConsensusContent(String searchTerm, String routingDecision) {
        List<UnifiedContent> results = new List<UnifiedContent>();
        
        try {
            // Search Consensus using existing service
            List<ANAgentConsensusContentSearchService.ConsensusContent> consensusResults = 
                ANAgentConsensusContentSearchService.searchBasic(searchTerm, 25);

            // Convert to UnifiedContent
            for (ANAgentConsensusContentSearchService.ConsensusContent consensusContent : consensusResults) {
                UnifiedContent unified = new UnifiedContent();
                unified.id = consensusContent.id;
                unified.name = consensusContent.title;
                unified.description = consensusContent.description;
                unified.type = 'Consensus';
                unified.status = consensusContent.isPublished ? 'Published' : 'Draft';
                unified.createdDate = consensusContent.createdAt;
                unified.link = consensusContent.previewLink;
                results.add(unified);
            }
        } catch (Exception e) {
            return buildErrorMessage('Consensus search failed: ' + e.getMessage());
        }

        return buildConsensusMessage(results, searchTerm, results.size(), routingDecision);
    }

    /**
     * @description Search both ACT and Consensus sources
     */
    private static String searchBothSources(String searchTerm, String contentType) {
        return searchBothSources(searchTerm, contentType, 'Explicit BOTH mode');
    }

    private static String searchBothSources(String searchTerm, String contentType, String routingDecision) {
        // This returns a simple combined message
        // For production, you might want more sophisticated merging
        String actMessage = searchACTContent(searchTerm, contentType, 'ACT portion');
        String consensusMessage = searchConsensusContent(searchTerm, 'Consensus portion');
        
        return '## COMBINED SEARCH RESULTS\n\n' +
               '**Routing Decision**: ' + routingDecision + '\n' +
               '**Search Term**: ' + searchTerm + '\n\n' +
               '---\n\n' +
               '### ACT LEARNING CONTENT\n\n' + actMessage + '\n\n' +
               '---\n\n' +
               '### CONSENSUS DEMO VIDEOS\n\n' + consensusMessage;
    }

    /**
     * @description Build formatted message for ACT content (FR-style DTO)
     * Structure: HEADER → SUMMARY → INSIGHTS → DETAILS → LIMITS → JSON
     */
    private static String buildACTMessage(List<UnifiedContent> records, String searchTerm, Integer totalCount, String routingDecision) {
        if (records == null || records.isEmpty()) {
            return buildNoResultsMessage('ACT', searchTerm, routingDecision);
        }

        // Calculate lifecycle metrics
        Integer coursesWithData = 0;
        Integer totalEnrollment = 0;
        Integer totalCompletions = 0;
        Integer lowEnrollmentCount = 0;
        Integer lowCompletionCount = 0;
        Integer highPerformingCount = 0;
        Integer coursesWithCSAT = 0;
        Double totalCSATScore = 0.0;
        Integer lowCSATCount = 0;

        for (UnifiedContent record : records) {
            if (record.type == 'Course' && record.learnerCount > 0) {
                coursesWithData++;
                totalEnrollment += record.learnerCount;
                totalCompletions += record.completionCount;
                
                if (record.csatScore > 0) {
                    coursesWithCSAT++;
                    totalCSATScore += record.csatScore;
                    if (record.csatScore < LOW_CSAT_THRESHOLD) {
                        lowCSATCount++;
                    }
                }
                
                if (record.learnerCount < LOW_ENROLLMENT_THRESHOLD) {
                    lowEnrollmentCount++;
                }
                if (record.completionRate < LOW_COMPLETION_THRESHOLD) {
                    lowCompletionCount++;
                }
                if (record.learnerCount >= HIGH_PERFORMING_ENROLLMENT && record.completionRate >= HIGH_PERFORMING_COMPLETION) {
                    highPerformingCount++;
                }
            }
        }

        // Build message following FR-style structure
        String message = '';
        
        // HEADER
        message += '## ACT LEARNING CONTENT SEARCH RESULTS\n\n';
        
        // SUMMARY
        message += '### SUMMARY\n';
        message += '**Search Term**: ' + searchTerm + '\n';
        message += '**Routing Decision**: ' + routingDecision + '\n';
        message += '**Total Records Found**: ' + totalCount + '\n';
        message += '**Showing**: ' + Math.min(totalCount, RESULT_LIMIT) + ' results\n\n';
        
        // INSIGHTS (Lifecycle Analysis)
        if (coursesWithData > 0) {
            message += '### INSIGHTS\n';
            message += '**📊 Course Performance Summary**\n';
            message += '- Total enrollment: ' + totalEnrollment + ' learners\n';
            message += '- Total completions: ' + totalCompletions + ' learners\n';
            Double avgCompletionRate = totalEnrollment > 0 ? (Double.valueOf(totalCompletions) / totalEnrollment) * 100 : 0.0;
            message += '- Average completion rate: ' + String.valueOf(Math.round(avgCompletionRate)) + '%\n';
            
            if (coursesWithCSAT > 0) {
                Double avgCSAT = totalCSATScore / coursesWithCSAT;
                message += '- Average CSAT score: ' + String.valueOf(Math.round(avgCSAT * 10) / 10.0) + '/5.0 (' + coursesWithCSAT + ' courses rated)\n';
            }
            message += '\n';
            
            message += '**🎯 Lifecycle Analysis**\n';
            message += '- High-performing courses (≥' + HIGH_PERFORMING_ENROLLMENT + ' learners, ≥' + HIGH_PERFORMING_COMPLETION + '% completion): ' + highPerformingCount + '\n';
            message += '- Low-enrollment courses (<' + LOW_ENROLLMENT_THRESHOLD + ' learners): ' + lowEnrollmentCount + '\n';
            message += '- Low-completion courses (<' + LOW_COMPLETION_THRESHOLD + '% completion): ' + lowCompletionCount + '\n';
            if (lowCSATCount > 0) {
                message += '- Low-satisfaction courses (<' + LOW_CSAT_THRESHOLD + ' CSAT): ' + lowCSATCount + '\n';
            }
            message += '\n';
            
            // Optimization recommendations
            if (lowEnrollmentCount > 0 || lowCompletionCount > 0 || lowCSATCount > 0) {
                message += '**⚠️ Content Optimization Opportunities**\n';
                if (lowEnrollmentCount > 0) {
                    message += '- Consider promoting or updating ' + lowEnrollmentCount + ' low-enrollment course' + (lowEnrollmentCount == 1 ? '' : 's') + '\n';
                }
                if (lowCompletionCount > 0) {
                    message += '- Review and improve ' + lowCompletionCount + ' course' + (lowCompletionCount == 1 ? '' : 's') + ' with low completion rates\n';
                }
                if (lowCSATCount > 0) {
                    message += '- Redesign ' + lowCSATCount + ' course' + (lowCSATCount == 1 ? '' : 's') + ' with low satisfaction scores\n';
                }
                message += '\n';
            }
            
            if (highPerformingCount > 0) {
                message += '**✅ Strong Content**\n';
                message += '- ' + highPerformingCount + ' course' + (highPerformingCount == 1 ? '' : 's') + ' showing excellent performance - consider expanding similar content\n\n';
            }
        }
        
        // DETAILS (Top 5 results)
        message += '### DETAILS\n';
        message += '**📚 Top Results**\n';
        for (Integer i = 0; i < Math.min(records.size(), 5); i++) {
            UnifiedContent record = records[i];
            message += (i + 1) + '. **' + record.name + '**';
            if (record.type == 'Course' && record.learnerCount > 0) {
                message += ' (' + record.learnerCount + ' learners, ' + Math.round(record.completionRate) + '% completion';
                if (record.csatScore > 0) {
                    message += ', ' + String.valueOf(Math.round(record.csatScore * 10) / 10.0) + '/5.0 CSAT';
                }
                message += ')';
            }
            message += '\n';
        }
        if (records.size() > 5) {
            message += '\n_...and ' + (records.size() - 5) + ' more results_\n';
        }
        message += '\n';
        
        // LIMITS & COUNTS
        message += '### LIMITS & COUNTS\n';
        message += '**Query Limits Applied**\n';
        message += '- Records per object: ' + RESULT_LIMIT + '\n';
        message += '- Total matches before limit: ' + totalCount + '\n';
        message += '- Records returned: ' + records.size() + '\n';
        message += '- Status filter: Active only\n\n';
        
        // JSON (compact - 3-6 keys max)
        message += '### DATA (JSON)\n';
        message += '```json\n';
        message += '{\n';
        message += '  "totalCount": ' + totalCount + ',\n';
        message += '  "coursesWithData": ' + coursesWithData + ',\n';
        message += '  "totalEnrollment": ' + totalEnrollment + ',\n';
        message += '  "avgCompletionRate": ' + (totalEnrollment > 0 ? String.valueOf(Math.round((Double.valueOf(totalCompletions) / totalEnrollment) * 100)) : '0') + ',\n';
        message += '  "highPerforming": ' + highPerformingCount + ',\n';
        message += '  "needsOptimization": ' + (lowEnrollmentCount + lowCompletionCount + lowCSATCount) + '\n';
        message += '}\n';
        message += '```\n';
        
        return message;
    }

    /**
     * @description Build formatted message for Consensus content
     */
    private static String buildConsensusMessage(List<UnifiedContent> records, String searchTerm, Integer totalCount, String routingDecision) {
        if (records == null || records.isEmpty()) {
            return buildNoResultsMessage('Consensus', searchTerm, routingDecision);
        }

        String message = '';
        
        // HEADER
        message += '## CONSENSUS DEMO VIDEOS SEARCH RESULTS\n\n';
        
        // SUMMARY
        message += '### SUMMARY\n';
        message += '**Search Term**: ' + searchTerm + '\n';
        message += '**Routing Decision**: ' + routingDecision + '\n';
        message += '**Total Videos Found**: ' + totalCount + '\n\n';
        
        // DETAILS
        message += '### DETAILS\n';
        message += '**🎥 Demo Videos**\n';
        for (Integer i = 0; i < Math.min(records.size(), 5); i++) {
            UnifiedContent record = records[i];
            message += (i + 1) + '. **' + record.name + '**\n';
            if (String.isNotBlank(record.description)) {
                message += '   ' + record.description + '\n';
            }
            if (String.isNotBlank(record.link)) {
                message += '   🔗 [Watch Demo](' + record.link + ')\n';
            }
            message += '\n';
        }
        if (records.size() > 5) {
            message += '_...and ' + (records.size() - 5) + ' more demo videos_\n\n';
        }
        
        // LIMITS & COUNTS
        message += '### LIMITS & COUNTS\n';
        message += '**Query Limits Applied**\n';
        message += '- Records returned: ' + records.size() + '\n';
        message += '- Status filter: Published only\n\n';
        
        // JSON (compact)
        message += '### DATA (JSON)\n';
        message += '```json\n';
        message += '{\n';
        message += '  "totalCount": ' + totalCount + ',\n';
        message += '  "source": "Consensus",\n';
        message += '  "hasLinks": true\n';
        message += '}\n';
        message += '```\n';
        
        return message;
    }

    /**
     * @description Build no results message
     */
    private static String buildNoResultsMessage(String source, String searchTerm, String routingDecision) {
        String message = '';
        message += '## NO RESULTS FOUND\n\n';
        message += '### SUMMARY\n';
        message += '**Search Term**: ' + searchTerm + '\n';
        message += '**Source**: ' + source + '\n';
        message += '**Routing Decision**: ' + routingDecision + '\n';
        message += '**Total Records Found**: 0\n\n';
        message += 'No ' + source + ' content found matching your search criteria.\n\n';
        message += '### SUGGESTIONS\n';
        message += '- Try different search terms\n';
        message += '- Check spelling\n';
        message += '- Use broader search terms\n';
        return message;
    }

    /**
     * @description Build error message
     */
    private static String buildErrorMessage(String errorMsg) {
        String message = '';
        message += '## ERROR\n\n';
        message += '**Message**: ' + errorMsg + '\n\n';
        message += 'Please check your input and try again.\n';
        return message;
    }

    /**
     * @description Search a specific object
     */
    private static List<UnifiedContent> searchObject(String objectName, String searchTerm) {
        List<UnifiedContent> results = new List<UnifiedContent>();
        
        try {
            if (!Schema.getGlobalDescribe().containsKey(objectName)) {
                return results;
            }

            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            if (!objectType.getDescribe().isAccessible()) {
                return results;
            }

            String query = buildSearchQuery(objectName, searchTerm);
            if (String.isBlank(query)) {
                return results;
            }

            List<SObject> records = Database.query(query);
            
            // Apply stripInaccessible for security
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, records);
            records = decision.getRecords();
            
            String recordType = getTypeForObject(objectName);
            for (SObject record : records) {
                results.add(new UnifiedContent(record, recordType));
            }

        } catch (Exception e) {
            System.debug('Error searching ' + objectName + ': ' + e.getMessage());
        }

        return results;
    }

    /**
     * @description Build SOQL query
     */
    private static String buildSearchQuery(String objectName, String searchTerm) {
        String baseQuery = 'SELECT Id, Name, Description__c, Status__c, CreatedDate, LastModifiedDate, Share_URL__c';
        
        if (objectName == 'Course__c') {
            baseQuery += ', CSAT__c';
        }
        
        baseQuery += ' FROM ' + objectName;
        
        String whereClause = ' WHERE (Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
        
        try {
            Schema.SObjectField descField = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get('Description__c');
            if (descField != null && descField.getDescribe().isAccessible()) {
                whereClause += ' OR Description__c LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
            }
        } catch (Exception e) {
            // Field doesn't exist
        }
        
        whereClause += ')';
        
        try {
            Schema.SObjectField statusField = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get('Status__c');
            if (statusField != null && statusField.getDescribe().isAccessible()) {
                whereClause += ' AND Status__c = \'Active\'';
            }
        } catch (Exception e) {
            // Field doesn't exist
        }
        
        return baseQuery + whereClause + ' ORDER BY Name LIMIT ' + RESULT_LIMIT;
    }

    /**
     * @description Populate learner count data for courses
     */
    private static void populateLearnerCountData(List<UnifiedContent> courseRecords) {
        if (courseRecords == null || courseRecords.isEmpty()) {
            return;
        }
        
        try {
            Set<String> courseIds = new Set<String>();
            for (UnifiedContent content : courseRecords) {
                if (content.type == 'Course' && String.isNotBlank(content.id)) {
                    courseIds.add(content.id);
                }
            }
            
            if (courseIds.isEmpty()) {
                return;
            }
            
            List<AggregateResult> learnerCounts = [
                SELECT Course__c, COUNT(Id) learnerCount
                FROM Assigned_Course__c 
                WHERE Course__c IN :courseIds 
                GROUP BY Course__c
            ];
            
            List<AggregateResult> completionCounts = [
                SELECT Course__c, COUNT(Id) completionCount
                FROM Assigned_Course__c 
                WHERE Course__c IN :courseIds AND Completed__c = true
                GROUP BY Course__c
            ];
            
            Map<String, Map<String, Integer>> courseStats = new Map<String, Map<String, Integer>>();
            
            for (AggregateResult ar : learnerCounts) {
                String courseId = (String)ar.get('Course__c');
                Integer totalLearners = (Integer)ar.get('learnerCount');
                courseStats.put(courseId, new Map<String, Integer>{'total' => totalLearners, 'completed' => 0});
            }
            
            for (AggregateResult ar : completionCounts) {
                String courseId = (String)ar.get('Course__c');
                Integer completions = (Integer)ar.get('completionCount');
                if (courseStats.containsKey(courseId)) {
                    courseStats.get(courseId).put('completed', completions);
                }
            }
            
            for (UnifiedContent content : courseRecords) {
                if (content.type == 'Course' && courseStats.containsKey(content.id)) {
                    Map<String, Integer> stats = courseStats.get(content.id);
                    content.learnerCount = stats.get('total');
                    content.completionCount = stats.get('completed');
                    
                    if (content.learnerCount > 0) {
                        content.completionRate = (Double)content.completionCount / content.learnerCount * 100;
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('Error populating learner count data: ' + e.getMessage());
        }
    }

    private static String getObjectNameForType(String contentType) {
        Map<String, String> typeToObject = new Map<String, String>{
            'Course' => 'Course__c',
            'Asset' => 'Asset__c',
            'Curriculum' => 'Curriculum__c'
        };
        return typeToObject.get(contentType);
    }

    private static String getTypeForObject(String objectName) {
        Map<String, String> objectToType = new Map<String, String>{
            'Course__c' => 'Course',
            'Asset__c' => 'Asset',
            'Curriculum__c' => 'Curriculum'
        };
        return objectToType.get(objectName);
    }

    /**
     * @description Internal data model for unified content
     * Not exposed at invocable boundary - only used internally
     */
    private class UnifiedContent {
        public String id { get; set; }
        public String name { get; set; }
        public String description { get; set; }
        public String type { get; set; }
        public String status { get; set; }
        public Datetime createdDate { get; set; }
        public Datetime lastModifiedDate { get; set; }
        public Integer learnerCount { get; set; }
        public Integer completionCount { get; set; }
        public Double completionRate { get; set; }
        public Double csatScore { get; set; }
        public String link { get; set; }

        public UnifiedContent() {
            this.learnerCount = 0;
            this.completionCount = 0;
            this.completionRate = 0.0;
            this.csatScore = 0.0;
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
            
            if (record.getSObjectType().getDescribe().getName() == 'Course__c' && record.get('CSAT__c') != null) {
                this.csatScore = (Double)record.get('CSAT__c');
            }
        }
    }
}

