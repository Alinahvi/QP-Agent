public with sharing class ANAgentContentSearchHandlerV2 {

    public class ContentSearchRequest {
        @InvocableVariable(label='Search Term' description='The term to search for' required=true)
        public String searchTerm;
        @InvocableVariable(label='Content Type' description='Optional filter: Course, Asset, or Curriculum')
        public String contentType;
        @InvocableVariable(label='Search Mode' description='AUTO, ACT, CONSENSUS, BOTH')
        public String searchMode;
        @InvocableVariable(label='User Utterance' description='Complete user utterance for routing')
        public String userUtterance;

        public ContentSearchRequest() {
            this.searchMode = 'AUTO';
        }
        public ContentSearchRequest(String searchTerm, String contentType) {
            this();
            this.searchTerm = searchTerm;
            this.contentType = contentType;
        }
    }

    public class ContentSearchResponse {
        @InvocableVariable(label='Success' description='Search success status')
        public Boolean success;
        @InvocableVariable(label='Message' description='Search result message')
        public String message;
        @InvocableVariable(label='Search Results' description='List of content records')
        public List<ANAgentContentSearchServiceV2.UnifiedContent> results;
        @InvocableVariable(label='Total Record Count' description='Total records found')
        public Integer totalRecordCount;
        @InvocableVariable(label='Errors' description='List of errors')
        public List<String> errors;
        @InvocableVariable(label='Routing Decision' description='Routing decision explanation')
        public String routingDecision;

        public ContentSearchResponse() {
            this.success = false;
            this.results = new List<ANAgentContentSearchServiceV2.UnifiedContent>();
            this.errors = new List<String>();
            this.totalRecordCount = 0;
        }
    }

    @InvocableMethod(
        label='ANAgent Search Content V2'
        description='Intelligently searches ACT learning content and Consensus demo videos with routing.'
    )
    public static List<ContentSearchResponse> searchContent(List<ContentSearchRequest> requests) {
        List<ContentSearchResponse> responses = new List<ContentSearchResponse>();

        for (ContentSearchRequest request : requests) {
            ContentSearchResponse response = new ContentSearchResponse();
            
            try {
                if (String.isBlank(request.searchTerm)) {
                    response.message = 'Search term is required.';
                    response.errors.add('Search term cannot be blank.');
                    responses.add(response);
                    continue;
                }

                String searchMode = String.isNotBlank(request.searchMode) ? request.searchMode.toUpperCase() : 'AUTO';
                String userUtterance = String.isNotBlank(request.userUtterance) ? request.userUtterance : request.searchTerm;
                
                response.routingDecision = determineRoutingDecision(request);
                
                if (searchMode == 'ACT') {
                ANAgentContentSearchServiceV2.ContentSearchResult searchResult = 
                    ANAgentContentSearchServiceV2.search(request.searchTerm, request.contentType);
                    response.success = searchResult.success;
                    response.totalRecordCount = searchResult.totalCount;
                    response.errors = searchResult.errors;
                    response.results = searchResult.records;
                    response.message = formatSuccessMessageWithLifecycle(searchResult.records);
                } else if (searchMode == 'CONSENSUS') {
                    ANAgentContentSearchServiceV2.ContentSearchResult searchResult = 
                        ANAgentContentSearchServiceV2.searchConsensus(request.searchTerm);
                response.success = searchResult.success;
                response.totalRecordCount = searchResult.totalCount;
                response.errors = searchResult.errors;
                response.results = searchResult.records;
                    response.message = formatConsensusMessage(searchResult.records);
                } else if (searchMode == 'BOTH') {
                    ANAgentContentSearchServiceV2.ContentSearchResult consensusResult = 
                        ANAgentContentSearchServiceV2.searchConsensus(request.searchTerm);
                    ANAgentContentSearchServiceV2.ContentSearchResult actResult = 
                        ANAgentContentSearchServiceV2.search(request.searchTerm, request.contentType);
                    
                    List<ANAgentContentSearchServiceV2.UnifiedContent> combinedResults = new List<ANAgentContentSearchServiceV2.UnifiedContent>();
                    combinedResults.addAll(consensusResult.records);
                    combinedResults.addAll(actResult.records);
                    
                    response.success = consensusResult.success || actResult.success;
                    response.totalRecordCount = consensusResult.totalCount + actResult.totalCount;
                    response.results = combinedResults;
                    response.errors.addAll(consensusResult.errors);
                    response.errors.addAll(actResult.errors);
                    response.message = formatSuccessMessage(response.totalRecordCount, 'both Consensus and ACT content');
                } else {
                    // AUTO mode - intelligent routing
                    String routingDecision = determineRoutingDecision(request);
                    response.routingDecision = routingDecision;
                    
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
                    
                    if (isConsensusRequest && isACTRequest) {
                        // Both keywords detected - search both
                        response.routingDecision = 'Auto-routed to BOTH sources - both keyword sets detected';
                        ANAgentContentSearchServiceV2.ContentSearchResult consensusResult = 
                            ANAgentContentSearchServiceV2.searchConsensus(request.searchTerm);
                        ANAgentContentSearchServiceV2.ContentSearchResult actResult = 
                            ANAgentContentSearchServiceV2.search(request.searchTerm, request.contentType);
                        
                        List<ANAgentContentSearchServiceV2.UnifiedContent> combinedResults = new List<ANAgentContentSearchServiceV2.UnifiedContent>();
                        combinedResults.addAll(consensusResult.records);
                        combinedResults.addAll(actResult.records);
                        
                        response.success = consensusResult.success || actResult.success;
                        response.totalRecordCount = consensusResult.totalCount + actResult.totalCount;
                        response.results = combinedResults;
                        response.errors.addAll(consensusResult.errors);
                        response.errors.addAll(actResult.errors);
                        response.message = formatSuccessMessage(response.totalRecordCount, 'both Consensus and ACT content');
                    } else if (isConsensusRequest && !isACTRequest) {
                        response.routingDecision = 'Auto-routed to Consensus based on keywords: ' + String.join(new List<String>(consensusKeywords), ', ');
                        ANAgentContentSearchServiceV2.ContentSearchResult searchResult = 
                            ANAgentContentSearchServiceV2.searchConsensus(request.searchTerm);
                        response.success = searchResult.success;
                        response.totalRecordCount = searchResult.totalCount;
                        response.errors = searchResult.errors;
                        response.results = searchResult.records;
                        response.message = formatConsensusMessage(searchResult.records);
                    } else if (isACTRequest && !isConsensusRequest) {
                        response.routingDecision = 'Auto-routed to ACT based on keywords: ' + String.join(new List<String>(actKeywords), ', ');
                        ANAgentContentSearchServiceV2.ContentSearchResult searchResult = 
                            ANAgentContentSearchServiceV2.search(request.searchTerm, request.contentType);
                        response.success = searchResult.success;
                        response.totalRecordCount = searchResult.totalCount;
                        response.errors = searchResult.errors;
                        response.results = searchResult.records;
                        response.message = formatSuccessMessageWithLifecycle(searchResult.records);
                    } else {
                        // Default to ACT
                        response.routingDecision = 'Auto-routed to ACT based on keywords: ' + String.join(new List<String>(actKeywords), ', ') + ' or default';
                        ANAgentContentSearchServiceV2.ContentSearchResult searchResult = 
                            ANAgentContentSearchServiceV2.search(request.searchTerm, request.contentType);
                        response.success = searchResult.success;
                        response.totalRecordCount = searchResult.totalCount;
                        response.errors = searchResult.errors;
                        response.results = searchResult.records;
                        response.message = formatSuccessMessageWithLifecycle(searchResult.records);
                    }
                }

            } catch (Exception e) {
                response.success = false;
                response.message = 'Error during search: ' + e.getMessage();
                response.errors.add('Exception: ' + e.getMessage());
                System.debug('Search error: ' + e.getMessage());
                System.debug('Stack trace: ' + e.getStackTraceString());
            }

            responses.add(response);
        }

        return responses;
    }

    private static String determineRoutingDecision(ContentSearchRequest request) {
        String searchMode = String.isNotBlank(request.searchMode) ? request.searchMode.toUpperCase() : 'AUTO';
        String userUtterance = String.isNotBlank(request.userUtterance) ? request.userUtterance : request.searchTerm;
        
        // Only extract core search term for AUTO mode, not for explicit ACT/CONSENSUS modes
        if (searchMode == 'AUTO') {
            String coreSearchTerm = extractCoreSearchTerm(userUtterance);
            request.searchTerm = coreSearchTerm; // Update the search term with extracted core term
        }
        
        if (searchMode == 'ACT') {
            return 'Explicit ACT mode - searching learning content only';
        } else if (searchMode == 'CONSENSUS') {
            return 'Explicit Consensus mode - searching demo videos only';
        } else if (searchMode == 'BOTH') {
            return 'Explicit BOTH mode - searching all content sources';
        } else {
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
            
            if (isConsensusRequest && isACTRequest) {
                return 'Auto-routed to BOTH sources - both keyword sets detected';
            } else if (isConsensusRequest && !isACTRequest) {
                return 'Auto-routed to Consensus based on keywords: ' + String.join(new List<String>(consensusKeywords), ', ');
            } else if (isACTRequest && !isConsensusRequest) {
                return 'Auto-routed to ACT based on keywords: ' + String.join(new List<String>(actKeywords), ', ');
                } else {
                return 'Auto-routed to ACT based on keywords: ' + String.join(new List<String>(actKeywords), ', ') + ' or default';
            }
        }
    }

    private static String extractCoreSearchTerm(String userUtterance) {
        if (String.isBlank(userUtterance)) {
            return '';
        }
        
        // Only remove very specific command phrases, preserve product names and content types
        Set<String> removePhrases = new Set<String>{
            'show me', 'find', 'search for', 'get', 'give me', 'i need',
            'from consensus', 'from act', 'in consensus', 'in act'
        };
        
        String coreTerm = userUtterance.toLowerCase();
        
        // Remove only command phrases, preserve product names and content types
        for (String phrase : removePhrases) {
            coreTerm = coreTerm.replace(phrase, '').trim();
        }
        
        // Remove extra whitespace
        coreTerm = coreTerm.replaceAll('\\s+', ' ').trim();
        
        // If we end up with nothing meaningful, return the original utterance (or a cleaned version)
        if (String.isBlank(coreTerm)) {
            return userUtterance.replaceAll('\\s+', ' ').trim();
        }
        
        return coreTerm;
    }

    private static String formatConsensusMessage(List<ANAgentContentSearchServiceV2.UnifiedContent> records) {
        if (records == null || records.isEmpty()) {
            return 'No Consensus demo videos found matching your search criteria.';
        }
        
        String message = 'Found ' + records.size() + ' Consensus demo video' + (records.size() == 1 ? '' : 's') + ':\n\n';
        
        for (Integer i = 0; i < Math.min(records.size(), 5); i++) { // Show top 5 results
            ANAgentContentSearchServiceV2.UnifiedContent record = records[i];
            message += '🎥 **' + record.name + '**\n';
            if (String.isNotBlank(record.description)) {
                message += record.description + '\n';
            }
            if (String.isNotBlank(record.link)) {
                message += '🔗 [Watch Demo](' + record.link + ')\n';
            }
            message += '\n';
        }

        if (records.size() > 5) {
            message += '*... and ' + (records.size() - 5) + ' more demo videos*';
        }

        return message;
    }

    private static String formatSuccessMessage(Integer count, String sourceType) {
        if (count == 0) {
            return 'No ' + sourceType + ' found matching your search criteria.';
        } else if (count == 1) {
            return 'Found 1 ' + sourceType + ' record.';
        } else {
            return 'Found ' + count + ' ' + sourceType + ' records.';
        }
    }

    /**
     * @description Enhanced success message with lifecycle context for ACT content
     * @param records List of UnifiedContent records
     * @return Formatted message with enrollment and completion insights
     */
    private static String formatSuccessMessageWithLifecycle(List<ANAgentContentSearchServiceV2.UnifiedContent> records) {
        if (records == null || records.isEmpty()) {
            return 'No ACT learning content found matching your search criteria.';
        }

        Integer totalRecords = records.size();
        Integer coursesWithData = 0;
        Integer totalEnrollment = 0;
        Integer totalCompletions = 0;
        Integer lowEnrollmentCount = 0;
        Integer lowCompletionCount = 0;
        Integer highPerformingCount = 0;
        Integer coursesWithCSAT = 0;
        Double totalCSATScore = 0.0;
        Integer lowCSATCount = 0;

        // Analyze the data including CSAT scores for comprehensive lifecycle management
        for (ANAgentContentSearchServiceV2.UnifiedContent record : records) {
            if (record.type == 'Course' && record.learnerCount > 0) {
                coursesWithData++;
                totalEnrollment += record.learnerCount;
                totalCompletions += record.completionCount;
                
                // CSAT analysis for content quality assessment
                if (record.csatScore > 0) {
                    coursesWithCSAT++;
                    totalCSATScore += record.csatScore;
                    if (record.csatScore < 3.0) { // Low satisfaction threshold
                        lowCSATCount++;
                    }
                }
                
                // Lifecycle analysis thresholds
                if (record.learnerCount < 20) {
                    lowEnrollmentCount++;
                }
                if (record.completionRate < 10.0) {
                    lowCompletionCount++;
                }
                if (record.learnerCount >= 50 && record.completionRate >= 25.0) {
                    highPerformingCount++;
                }
            }
        }

        String message = 'Found ' + totalRecords + ' ACT learning content record' + (totalRecords == 1 ? '' : 's') + ':\n\n';
        
        if (coursesWithData > 0) {
            message += '📊 **Course Performance Summary:**\n';
            message += '• Total enrollment across all courses: ' + totalEnrollment + ' learners\n';
            message += '• Total completions: ' + totalCompletions + ' learners\n';
            message += '• Average completion rate: ' + (totalEnrollment > 0 ? String.valueOf(Math.round((Double.valueOf(totalCompletions) / totalEnrollment) * 100)) + '%' : '0%') + '\n';
            
            // Add CSAT summary if available
            if (coursesWithCSAT > 0) {
                message += '• Average CSAT score: ' + String.valueOf(Math.round((totalCSATScore / coursesWithCSAT) * 10) / 10) + '/5.0 (' + coursesWithCSAT + ' courses with ratings)\n';
                }
                message += '\n';
            
            message += '🎯 **Lifecycle Analysis:**\n';
            message += '• High-performing courses (≥50 learners, ≥25% completion): ' + highPerformingCount + '\n';
            message += '• Low-enrollment courses (<20 learners): ' + lowEnrollmentCount + '\n';
            message += '• Low-completion courses (<10% completion): ' + lowCompletionCount + '\n';
            if (lowCSATCount > 0) {
                message += '• Low-satisfaction courses (<3.0 CSAT): ' + lowCSATCount + '\n';
            }
            message += '\n';
            
            if (lowEnrollmentCount > 0 || lowCompletionCount > 0 || lowCSATCount > 0) {
                message += '⚠️ **Content Optimization Opportunities:**\n';
                if (lowEnrollmentCount > 0) {
                    message += '• Consider promoting or updating ' + lowEnrollmentCount + ' low-enrollment course' + (lowEnrollmentCount == 1 ? '' : 's') + '\n';
                }
                if (lowCompletionCount > 0) {
                    message += '• Review and improve ' + lowCompletionCount + ' course' + (lowCompletionCount == 1 ? '' : 's') + ' with low completion rates\n';
                }
                if (lowCSATCount > 0) {
                    message += '• Redesign ' + lowCSATCount + ' course' + (lowCSATCount == 1 ? '' : 's') + ' with low satisfaction scores\n';
                }
                message += '\n';
            }
            
            if (highPerformingCount > 0) {
                message += '✅ **Strong Content:**\n';
                message += '• ' + highPerformingCount + ' course' + (highPerformingCount == 1 ? '' : 's') + ' showing excellent performance - consider expanding similar content\n\n';
            }
        }
        
        message += '📚 **Top Results:**\n';
        for (Integer i = 0; i < Math.min(records.size(), 5); i++) {
            ANAgentContentSearchServiceV2.UnifiedContent record = records[i];
            message += '• **' + record.name + '**';
            if (record.type == 'Course' && record.learnerCount > 0) {
                message += ' (' + record.learnerCount + ' learners, ' + Math.round(record.completionRate) + '% completion';
                if (record.csatScore > 0) {
                    message += ', ' + record.csatScore + '/5.0 CSAT';
                }
                message += ')';
            }
            message += '\n';
        }

        if (records.size() > 5) {
            message += '...and ' + (records.size() - 5) + ' more. Would you like to see more results?\n';
        }

        return message;
    }
} 
