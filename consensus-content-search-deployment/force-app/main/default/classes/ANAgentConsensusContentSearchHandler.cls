/**
 * @description Consensus content search handler for agent actions.
 * Provides a clean interface for searching Consensus content with intelligent routing.
 * @version 1.0
 */
public with sharing class ANAgentConsensusContentSearchHandler {

    /**
     * @description Enhanced request class for content search with lifecycle maintenance
     */
    public class ContentSearchRequest {
        @InvocableVariable(
            label='User Utterance'
            description='The complete user utterance to analyze and search'
            required=true
        )
        public String userUtterance;

        // Lifecycle Maintenance Filters
        @InvocableVariable(
            label='Time Frame'
            description='Time frame: CURRENT (current fiscal quarter), PREVIOUS (last fiscal quarter), or ISO date range'
            required=false
        )
        public String timeframe;

        @InvocableVariable(
            label='Start Date'
            description='Start date for custom time range (ISO format: YYYY-MM-DD)'
            required=false
        )
        public String startDate;

        @InvocableVariable(
            label='End Date'
            description='End date for custom time range (ISO format: YYYY-MM-DD)'
            required=false
        )
        public String endDate;

        @InvocableVariable(
            label='Active Only'
            description='Filter to only active/published content (default: true)'
            required=false
        )
        public Boolean activeOnly;

        @InvocableVariable(
            label='Min Enrollment'
            description='Minimum enrollment count for ACT content (default: 50)'
            required=false
        )
        public Integer minEnrollment;

        @InvocableVariable(
            label='Min Completion Rate'
            description='Minimum completion rate percentage (default: 25.0)'
            required=false
        )
        public Decimal minCompletionRate;

        @InvocableVariable(
            label='Product Tag'
            description='Filter by product tag (e.g., Tableau, Agentforce, Data Cloud)'
            required=false
        )
        public String productTag;

        @InvocableVariable(
            label='Skill Tag'
            description='Filter by skill/topic tag (e.g., Forecasting, Analytics)'
            required=false
        )
        public String skillTag;

        @InvocableVariable(
            label='Limit N'
            description='Maximum number of results to return (default: 100)'
            required=false
        )
        public Integer limitN;

        // Legacy parameters for backwards compatibility
        @InvocableVariable(
            label='Topic'
            description='Normalized Product L2/L3 or free text topic for search (legacy)'
            required=false
        )
        public String topic;

        @InvocableVariable(
            label='OU Name'
            description='Operating Unit name for personalization (legacy)'
            required=false
        )
        public String ouName;

        public ContentSearchRequest() {
            this.activeOnly = true;
            this.minEnrollment = 50;
            this.minCompletionRate = 25.0;
            this.limitN = 100;
            this.timeframe = 'CURRENT';
        }

        public ContentSearchRequest(String userUtterance) {
            this();
            this.userUtterance = userUtterance;
        }
    }

    /**
     * @description Response class for content search
     */
    public class ContentSearchResponse {
        @InvocableVariable(
            label='Message'
            description='Composed message containing all search results and metadata'
        )
        public String message;

        // Enhanced response fields for Content Intelligence
        @InvocableVariable(
            label='Results'
            description='List of enhanced search results with intelligence data'
        )
        public List<IntelligentContentResult> results;

        @InvocableVariable(
            label='Explain'
            description='Global explanation notes about the search process'
        )
        public List<String> explain;

        @InvocableVariable(
            label='Debug Info'
            description='Debug information (only when debug header is present)'
        )
        public String debugInfo;

        @InvocableVariable(
            label='Next Best Actions'
            description='Recommended next actions based on search results'
        )
        public List<String> nextBestActions;

        public ContentSearchResponse() {
            this.message = '';
            this.results = new List<IntelligentContentResult>();
            this.explain = new List<String>();
            this.nextBestActions = new List<String>();
        }
    }

    /**
     * @description Enhanced unified content item for both ACT and Consensus
     */
    public class ContentItem {
        public String source;            // 'ACT' | 'CONSENSUS'
        public String title;
        public String url;
        public String productTag;        // normalized
        public String topicTag;          // or tags
        public Integer enrollment;       // ACT only, null otherwise
        public Decimal completionRate;   // ACT only
        public Decimal engagementScore;  // Consensus only
        public Date publishedDate;
        public Decimal score;            // composite ranking 0..1
        public String rationale;         // human-readable: why selected
        public String description;
        public String language;
        public String creator;
        public Boolean isActive;
        
        public ContentItem() {
            this.score = 0.0;
            this.isActive = true;
        }
    }

    /**
     * @description Search summary with applied filters and statistics
     */
    public class ContentSearchSummary {
        public String timeframe;          // CURRENT/PREVIOUS or date range
        public Boolean activeOnly;
        public Integer minEnrollment;
        public Decimal minCompletionRate;
        public String productTag;
        public String skillTag;
        public Integer totalScanned;      // before filters
        public Integer totalReturned;     // after filters
        public String selectionPolicy;    // 'LifecycleLowPerformers' | 'BestMatch' | 'Recent'
        public String searchSource;       // 'ACT' | 'CONSENSUS' | 'BOTH'
        
        public ContentSearchSummary() {
            this.totalScanned = 0;
            this.totalReturned = 0;
        }
    }

    /**
     * @description Enhanced content result with intelligence data
     */
    public class IntelligentContentResult {
        @InvocableVariable(label='Source')
        public String source; // 'Consensus' or 'ACT'
        
        @InvocableVariable(label='Title')
        public String title;
        
        @InvocableVariable(label='Description')
        public String description;
        
        @InvocableVariable(label='Preview Link')
        public String previewLink;
        
        @InvocableVariable(label='Score')
        public Decimal score;
        
        @InvocableVariable(label='Why')
        public String why;
        
        @InvocableVariable(label='Lifecycle Flags')
        public List<String> lifecycleFlags;
        
        @InvocableVariable(label='Personalization Reason')
        public String personalizationReason;
        
        @InvocableVariable(label='Product L2')
        public String productL2;
        
        @InvocableVariable(label='Product L3')
        public String productL3;
        
        @InvocableVariable(label='Created Date')
        public DateTime createdDate;
        
        @InvocableVariable(label='Is Published')
        public Boolean isPublished;
        
        @InvocableVariable(label='Is Public')
        public Boolean isPublic;

        public IntelligentContentResult() {
            this.lifecycleFlags = new List<String>();
        }
    }

    /**
     * @description Main invocable method for content search
     * Routes to Consensus or ACT search based on user utterance
     * @param requests List of search requests
     * @return List of search responses with composed messages
     */
    @InvocableMethod(
        label='ANAgent Search Content (Consensus or ACT)'
        description='Intelligently routes content searches to Consensus or ACT based on user utterance. Returns unified results in a single composed message string.'
    )
    public static List<ContentSearchResponse> searchContent(List<ContentSearchRequest> requests) {
        System.debug('=== searchContent method called ===');
        List<ContentSearchResponse> responses = new List<ContentSearchResponse>();

        // Handle null or empty requests
        if (requests == null || requests.isEmpty()) {
            ContentSearchResponse errorResponse = new ContentSearchResponse();
            errorResponse.message = '**Content Search Error**\n\nNo search request provided.';
            responses.add(errorResponse);
            return responses;
        }

        // Process each request
        for (ContentSearchRequest request : requests) {
            ContentSearchResponse response = new ContentSearchResponse();
            
            try {
                // Validate request
                if (String.isBlank(request.userUtterance)) {
                    response.message = '**Content Search Error**\n\nUser utterance is required.';
                    responses.add(response);
                    continue;
                }

                // Route to appropriate service based on utterance content
                String searchResult = routeSearch(request);
                response.message = searchResult;
                
                // Get enhanced search results with lifecycle maintenance
                System.debug('About to call getEnhancedContentItems for: ' + request.userUtterance);
                List<ContentItem> contentItems = getEnhancedContentItems(request);
                System.debug('getEnhancedContentItems returned ' + contentItems.size() + ' items');
                response.results = convertToLegacyResults(contentItems);
                System.debug('convertToLegacyResults returned ' + response.results.size() + ' results');
                
                // Add summary information
                response.explain.add('Applied lifecycle filters: ' + getFilterSummary(request));

            } catch (Exception e) {
                response.message = '**Content Search Error**\n\nAn unexpected error occurred: ' + e.getMessage();
                System.debug('ANAgentConsensusContentSearchHandler error: ' + e.getMessage());
            }

            responses.add(response);
        }

        return responses;
    }

    /**
     * @description Route search to appropriate service based on user utterance
     * @param request The enhanced search request
     * @return Search results as composed message string
     */
    private static String routeSearch(ContentSearchRequest request) {
        String userUtterance = request.userUtterance.toLowerCase();
        
        // Define keywords that indicate user wants Consensus content
        Set<String> consensusKeywords = new Set<String>{
            'consensus', 'demo', 'demo video', 'video', 'demo pack', 
            'presentation', 'overview demo', 'standard demo', 'quick demo'
        };
        
        // Define keywords that indicate user wants ACT content
        Set<String> actKeywords = new Set<String>{
            'act', 'course', 'training', 'learning', 'curriculum', 'asset',
            'lifecycle', 'engagement', 'analytics', 'trends', 'management',
            'best practices', 'certification', 'boot camp'
        };
        
        // Check for explicit Consensus keywords
        Boolean isConsensusRequest = false;
        for (String keyword : consensusKeywords) {
            if (userUtterance.contains(keyword)) {
                isConsensusRequest = true;
                break;
            }
        }
        
        // Check for explicit ACT keywords
        Boolean isACTRequest = false;
        for (String keyword : actKeywords) {
            if (userUtterance.contains(keyword)) {
                isACTRequest = true;
                break;
            }
        }
        
        // Route based on detected intent
        if (isConsensusRequest && !isACTRequest) {
            // Clear consensus intent - route to Consensus content
            return ANAgentConsensusContentSearchService.searchConsensusContent(request.userUtterance);
        } else if (isACTRequest || (!isConsensusRequest && !isACTRequest)) {
            // ACT intent or no clear preference - route to ACT content
            return routeToACTSearch(request.userUtterance);
        } else {
            // Both keywords present - default to ACT for lifecycle/management queries
            return routeToACTSearch(request.userUtterance);
        }
    }

    /**
     * @description Route to existing ACT search service
     * @param userUtterance The user's search request
     * @return ACT search results as composed message string
     */
    private static String routeToACTSearch(String userUtterance) {
        try {
            // Use existing ACT search service
            ANAgentContentSearchServiceV2.ContentSearchResult searchResult = 
                ANAgentContentSearchServiceV2.search(userUtterance, null);

            // Compose message in FR Agent format
            return composeACTMessage(searchResult, userUtterance);

        } catch (Exception e) {
            return '**ACT Content Search Error**\n\nSearch failed: ' + e.getMessage();
        }
    }

    /**
     * @description Compose ACT search results in FR Agent format
     * @param searchResult ACT search results
     * @param userUtterance Original user utterance
     * @return Composed message string
     */
    private static String composeACTMessage(ANAgentContentSearchServiceV2.ContentSearchResult searchResult, String userUtterance) {
        String message = '';
        
        // HEADER
        message += '**ACT Content Search**\n\n';
        
        // SUMMARY
        message += '**SUMMARY**\n';
        message += 'Searched ACT library for: ' + userUtterance + '\n';
        message += 'Total matches: ' + searchResult.totalCount + ' | Showing: ' + searchResult.records.size() + '\n\n';
        
        // INSIGHTS
        message += '**INSIGHTS**\n';
        if (!searchResult.records.isEmpty()) {
            Integer insightCount = Math.min(3, searchResult.records.size());
            for (Integer i = 0; i < insightCount; i++) {
                ANAgentContentSearchServiceV2.UnifiedContent content = searchResult.records[i];
                message += '• **' + content.name + '** - ' + content.type + 
                         (content.status != null ? ' | Status: ' + content.status : '') + '\n';
            }
        } else {
            message += '• No content found matching the search criteria\n';
        }
        message += '\n';
        
        // DETAILS
        message += '**DETAILS**\n';
        if (!searchResult.records.isEmpty()) {
            for (ANAgentContentSearchServiceV2.UnifiedContent content : searchResult.records) {
                message += '• **' + content.name + '**\n';
                message += '  Type: ' + content.type + '\n';
                if (String.isNotBlank(content.description)) {
                    message += '  Description: ' + content.description + '\n';
                }
                if (content.status != null) {
                    message += '  Status: ' + content.status + '\n';
                }
                if (content.learnerCount > 0) {
                    message += '  Learners: ' + content.learnerCount + 
                             ' | Completions: ' + content.completionCount + 
                             ' | Rate: ' + String.valueOf(content.completionRate).substring(0, Math.min(5, String.valueOf(content.completionRate).length())) + '%\n';
                }
                message += '\n';
            }
        }
        
        // LIMITS & COUNTS
        message += '**LIMITS & COUNTS**\n';
        message += 'Total records found: ' + searchResult.totalCount + '\n';
        message += 'Records returned: ' + searchResult.records.size() + '\n';
        message += 'Page size limit: 50 (ACT default)\n\n';
        
        // DATA (JSON)
        message += '**DATA (JSON)**\n';
        message += '```json\n';
        message += '{\n';
        message += '  "searchType": "ACT",\n';
        message += '  "totalFound": ' + searchResult.totalCount + ',\n';
        message += '  "returned": ' + searchResult.records.size() + ',\n';
        message += '  "results": [\n';
        
        for (Integer i = 0; i < searchResult.records.size(); i++) {
            ANAgentContentSearchServiceV2.UnifiedContent content = searchResult.records[i];
            message += '    {\n';
            message += '      "name": "' + escapeJsonString(content.name) + '",\n';
            message += '      "type": "' + escapeJsonString(content.type) + '",\n';
            message += '      "description": "' + escapeJsonString(content.description) + '",\n';
            message += '      "status": "' + escapeJsonString(content.status) + '",\n';
            message += '      "learnerCount": ' + content.learnerCount + ',\n';
            message += '      "completionCount": ' + content.completionCount + ',\n';
            message += '      "completionRate": ' + content.completionRate + '\n';
            message += i < searchResult.records.size() - 1 ? '    },\n' : '    }\n';
        }
        
        message += '  ]\n';
        message += '}\n';
        message += '```\n';
        
        return message;
    }

    /**
     * @description Escape string for JSON output
     * @param input Input string
     * @return Escaped string
     */
    private static String escapeJsonString(String input) {
        if (String.isBlank(input)) return '';
        return input.replace('\\', '\\\\')
                   .replace('"', '\\"')
                   .replace('\n', '\\n')
                   .replace('\r', '\\r')
                   .replace('\t', '\\t');
    }

    /**
     * @description Convenience method for single search request
     * @param userUtterance The user utterance to search
     * @return ContentSearchResponse
     */
    public static ContentSearchResponse searchContent(String userUtterance) {
        ContentSearchRequest request = new ContentSearchRequest(userUtterance);
        List<ContentSearchRequest> requests = new List<ContentSearchRequest>{request};
        List<ContentSearchResponse> responses = searchContent(requests);
        return responses.isEmpty() ? new ContentSearchResponse() : responses[0];
    }
    
    /**
     * @description Get enhanced search results for response
     * @param request The search request
     * @return List of intelligent content results
     */
    private static List<IntelligentContentResult> getEnhancedSearchResults(ContentSearchRequest request) {
        try {
            System.debug('getEnhancedSearchResults called with: ' + request.userUtterance);
            
            // For now, return empty results since the enhanced service is not deployed
            // This method will be enhanced once the service layer is updated
            return new List<IntelligentContentResult>();
            
        } catch (Exception e) {
            System.debug('Error getting enhanced search results: ' + e.getMessage());
            return new List<IntelligentContentResult>();
        }
    }
    
    /**
     * @description Request class for search suggestions
     */
    public class SearchSuggestionsRequest {
        @InvocableVariable(
            label='Partial Search Term'
            description='Partial search term to get suggestions for'
            required=true
        )
        public String partialTerm;
        
        @InvocableVariable(
            label='Max Suggestions'
            description='Maximum number of suggestions to return (default: 10)'
            required=false
        )
        public Integer maxSuggestions;
        
        public SearchSuggestionsRequest() {
            this.maxSuggestions = 10;
        }
    }
    
    /**
     * @description Response class for search suggestions
     */
    public class SearchSuggestionsResponse {
        @InvocableVariable(
            label='Message'
            description='Composed message with search suggestions'
        )
        public String message;
        
        @InvocableVariable(
            label='Suggestions'
            description='List of suggested search terms'
        )
        public List<String> suggestions;
        
        public SearchSuggestionsResponse() {
            this.suggestions = new List<String>();
        }
    }
    
    /**
     * @description Request class for content lifecycle analysis
     */
    public class ContentLifecycleRequest {
        @InvocableVariable(
            label='Topic'
            description='Topic to analyze for content lifecycle (e.g., "Data Cloud", "Sales Cloud")'
            required=true
        )
        public String topic;
        
        @InvocableVariable(
            label='Analysis Type'
            description='Type of analysis: ACT_CONTENT, CONSENSUS_CONTENT, or ALL'
            required=false
        )
        public String analysisType;
        
        public ContentLifecycleRequest() {
            this.analysisType = 'ACT_CONTENT';
        }
    }
    
    /**
     * @description Response class for content lifecycle analysis
     */
    public class ContentLifecycleResponse {
        @InvocableVariable(
            label='Message'
            description='Composed message with lifecycle analysis results'
        )
        public String message;
        
        @InvocableVariable(
            label='Analysis Results'
            description='Detailed analysis results'
        )
        public String analysisResults;
        
        public ContentLifecycleResponse() {}
    }
    
    /**
     * @description Get search suggestions based on existing content
     * @param requests List of suggestion requests
     * @return List of suggestion responses
     */
    public static List<SearchSuggestionsResponse> getSearchSuggestions(List<SearchSuggestionsRequest> requests) {
        List<SearchSuggestionsResponse> responses = new List<SearchSuggestionsResponse>();
        
        for (SearchSuggestionsRequest request : requests) {
            SearchSuggestionsResponse response = new SearchSuggestionsResponse();
            
            try {
                if (String.isBlank(request.partialTerm)) {
                    response.message = '**Search Suggestions Error**\n\nPartial search term is required.';
                    responses.add(response);
                    continue;
                }
                
                // Get suggestions from existing content titles
                List<String> suggestions = getContentSuggestions(request.partialTerm, request.maxSuggestions);
                response.suggestions = suggestions;
                
                if (suggestions.isEmpty()) {
                    response.message = '**Search Suggestions for: "' + request.partialTerm + '"**\n\nNo suggestions found.';
                } else {
                    response.message = '**Search Suggestions for: "' + request.partialTerm + '"**\n\n' + 
                                     String.join(suggestions, '\n• ');
                }
                
            } catch (Exception e) {
                response.message = '**Search Suggestions Error**\n\nError getting suggestions: ' + e.getMessage();
            }
            
            responses.add(response);
        }
        
        return responses;
    }
    
    /**
     * @description Get content suggestions based on partial term
     * @param partialTerm Partial search term
     * @param maxSuggestions Maximum number of suggestions
     * @return List of suggestion strings
     */
    private static List<String> getContentSuggestions(String partialTerm, Integer maxSuggestions) {
        List<String> suggestions = new List<String>();
        Integer limitN = (maxSuggestions == null || maxSuggestions <= 0) ? 10 : Math.min(maxSuggestions, 20);
        
        if (String.isBlank(partialTerm)) {
            return suggestions;
        }
        
        String esc = String.escapeSingleQuotes(partialTerm.toLowerCase());
        
        try {
            // Get suggestions from Consensus content
            String consensusSoql = 'SELECT Title__c, InternalTitle__c FROM Agent_Consensu__c ' +
                                  'WHERE IsPublished__c = TRUE AND ' +
                                  '(Title__c LIKE \'%' + esc + '%\' OR ' +
                                  'InternalTitle__c LIKE \'%' + esc + '%\') ' +
                                  'ORDER BY CreatedDate DESC LIMIT ' + limitN;
            
            Set<String> titleSet = new Set<String>();
            for (SObject s : Database.query(consensusSoql)) {
                String title = (String)s.get('Title__c');
                String internalTitle = (String)s.get('InternalTitle__c');
                
                if (!String.isBlank(title) && title.toLowerCase().contains(esc)) {
                    titleSet.add(title);
                }
                if (!String.isBlank(internalTitle) && internalTitle.toLowerCase().contains(esc)) {
                    titleSet.add(internalTitle);
                }
            }
            
            // Get suggestions from ACT content (Course, Asset, Curriculum)
            List<String> actObjects = new List<String>{'Course__c', 'Asset__c', 'Curriculum__c'};
            for (String objType : actObjects) {
                try {
                String actSoql = 'SELECT Name FROM ' + objType + ' ' +
                                'WHERE Status__c = \'Active\' AND ' +
                                'Name LIKE \'%' + esc + '%\' ' +
                                'ORDER BY CreatedDate DESC LIMIT ' + limitN;
                    
                    for (SObject s : Database.query(actSoql)) {
                        String name = (String)s.get('Name');
                        if (!String.isBlank(name)) {
                            titleSet.add(name);
                        }
                    }
                } catch (Exception e) {
                    System.debug('Error querying ' + objType + ' for suggestions: ' + e.getMessage());
                }
            }
            
            // Convert set to list and sort
            suggestions.addAll(titleSet);
            suggestions.sort();
            
            // Limit results
            if (suggestions.size() > limitN) {
                List<String> limitedSuggestions = new List<String>();
                for (Integer i = 0; i < limitN && i < suggestions.size(); i++) {
                    limitedSuggestions.add(suggestions[i]);
                }
                suggestions = limitedSuggestions;
            }
            
        } catch (Exception e) {
            System.debug('Error getting content suggestions: ' + e.getMessage());
        }
        
        return suggestions;
    }
    
    /**
     * @description Analyze content lifecycle for ACT content
     * @param requests List of lifecycle analysis requests
     * @return List of lifecycle analysis responses
     */
    public static List<ContentLifecycleResponse> analyzeContentLifecycle(List<ContentLifecycleRequest> requests) {
        List<ContentLifecycleResponse> responses = new List<ContentLifecycleResponse>();
        
        for (ContentLifecycleRequest request : requests) {
            ContentLifecycleResponse response = new ContentLifecycleResponse();
            
            try {
                if (String.isBlank(request.topic)) {
                    response.message = '**Content Lifecycle Analysis Error**\n\nTopic is required for analysis.';
                    responses.add(response);
                    continue;
                }
                
                // For now, return basic analysis since enhanced service is not deployed
                String analysisResults = '**Content Lifecycle Analysis for: "' + request.topic + '"**\n\nFeature coming soon.';
                response.analysisResults = analysisResults;
                response.message = analysisResults;
                
            } catch (Exception e) {
                response.message = '**Content Lifecycle Analysis Error**\n\nError analyzing content lifecycle: ' + e.getMessage();
            }
            
            responses.add(response);
        }
        
        return responses;
    }

    /**
     * @description Get enhanced content items with lifecycle maintenance
     * @param request The search request with lifecycle filters
     * @return List of unified content items
     */
    private static List<ContentItem> getEnhancedContentItems(ContentSearchRequest request) {
        List<ContentItem> items = new List<ContentItem>();
        
        try {
            String userUtterance = request.userUtterance.toLowerCase();
            System.debug('getEnhancedContentItems - userUtterance: ' + userUtterance);
            
            // Determine search source based on utterance keywords
            Set<String> consensusKeywords = new Set<String>{
                'consensus', 'demo', 'demo video', 'video', 'demo pack'
            };
            
            Set<String> actKeywords = new Set<String>{
                'act', 'course', 'training', 'learning', 'curriculum', 'asset',
                'lifecycle', 'engagement', 'analytics', 'trends', 'management',
                'tableau', 'salesforce', 'apex', 'lwc', 'flow', 'admin'
            };
            
            Boolean isConsensusRequest = containsAnyKeyword(userUtterance, consensusKeywords);
            Boolean isACTRequest = containsAnyKeyword(userUtterance, actKeywords);
            
            System.debug('getEnhancedContentItems - userUtterance: "' + userUtterance + '"');
            System.debug('getEnhancedContentItems - actKeywords: ' + actKeywords);
            System.debug('getEnhancedContentItems - isConsensusRequest: ' + isConsensusRequest);
            System.debug('getEnhancedContentItems - isACTRequest: ' + isACTRequest);
            
            if (isConsensusRequest && !isACTRequest) {
                // Route to Consensus content with lifecycle filters
                System.debug('getEnhancedContentItems - routing to Consensus');
                items = searchConsensusWithLifecycle(request);
            } else {
                // Route to ACT content with lifecycle filters
                System.debug('getEnhancedContentItems - routing to ACT');
                items = searchACTWithLifecycle(request);
                System.debug('getEnhancedContentItems - ACT search returned ' + items.size() + ' items');
            }
            
        } catch (Exception e) {
            System.debug('Error getting enhanced content items: ' + e.getMessage());
            // Return empty list on error
        }
        
        return items;
    }

    /**
     * @description Search Consensus content with lifecycle maintenance filters
     * @param request The search request
     * @return List of content items
     */
    private static List<ContentItem> searchConsensusWithLifecycle(ContentSearchRequest request) {
        List<ContentItem> items = new List<ContentItem>();
        
        try {
            // Get date range for filtering
            DateRange dateRange = calculateDateRange(request.timeframe, request.startDate, request.endDate);
            
            // Build SOQL query with lifecycle filters
            String soql = buildConsensusSOQL(request, dateRange);
            
            // Execute query
            List<Agent_Consensu__c> consensusRecords = Database.query(soql);
            
            // Convert to ContentItems with scoring
            for (Agent_Consensu__c record : consensusRecords) {
                ContentItem item = convertConsensusToContentItem(record, request);
                if (item != null) {
                    items.add(item);
                }
            }
            
            // Sort by score and apply limit
            items.sort(new ContentItemScoreComparator());
            if (items.size() > request.limitN) {
                List<ContentItem> limitedItems = new List<ContentItem>();
                for (Integer i = 0; i < request.limitN && i < items.size(); i++) {
                    limitedItems.add(items[i]);
                }
                items = limitedItems;
            }
            
        } catch (Exception e) {
            System.debug('Error searching Consensus with lifecycle: ' + e.getMessage());
        }
        
        return items;
    }

    /**
     * @description Search ACT content with lifecycle maintenance filters
     * @param request The search request
     * @return List of content items
     */
    private static List<ContentItem> searchACTWithLifecycle(ContentSearchRequest request) {
        List<ContentItem> items = new List<ContentItem>();
        
        try {
            // Get date range for filtering
            DateRange dateRange = calculateDateRange(request.timeframe, request.startDate, request.endDate);
            
            // Extract key search terms from the utterance for better V2 service compatibility
            String searchTerm = extractSearchTerms(request.userUtterance);
            System.debug('Extracted search term: "' + searchTerm + '" from utterance: "' + request.userUtterance + '"');
            
            // Use the V2 service which works reliably
            ANAgentContentSearchServiceV2.ContentSearchResult searchResult = 
                ANAgentContentSearchServiceV2.search(searchTerm, null);
            
            System.debug('Date range filtering - startDate: ' + dateRange.startDate + ', endDate: ' + dateRange.endDate);
            System.debug('V2 service returned ' + searchResult.records.size() + ' records before filtering');
            
            // Convert UnifiedContent to ContentItem and apply date filtering
            for (ANAgentContentSearchServiceV2.UnifiedContent unifiedContent : searchResult.records) {
                // Apply date range filter
                if (dateRange.startDate != null && unifiedContent.createdDate != null) {
                    Date createdDate = unifiedContent.createdDate.date();
                    if (createdDate < dateRange.startDate) {
                        System.debug('Filtering out: ' + unifiedContent.name + ' (created: ' + createdDate + ' < startDate: ' + dateRange.startDate + ')');
                        continue;
                    }
                }
                if (dateRange.endDate != null && unifiedContent.createdDate != null) {
                    Date createdDate = unifiedContent.createdDate.date();
                    if (createdDate > dateRange.endDate) {
                        System.debug('Filtering out: ' + unifiedContent.name + ' (created: ' + createdDate + ' > endDate: ' + dateRange.endDate + ')');
                        continue;
                    }
                }
                
                System.debug('Including: ' + unifiedContent.name + ' (created: ' + unifiedContent.createdDate + ')');
                
                ContentItem item = new ContentItem();
                item.title = unifiedContent.name;
                item.description = unifiedContent.description;
                item.url = unifiedContent.name; // Use name as URL for now
                item.score = 0.8; // Default score for ACT content
                item.source = 'ACT';
                item.rationale = 'Found in ACT library';
                item.isActive = (unifiedContent.status == 'Active');
                item.publishedDate = unifiedContent.createdDate != null ? unifiedContent.createdDate.date() : null;
                item.enrollment = unifiedContent.learnerCount;
                item.completionRate = unifiedContent.completionRate;
                items.add(item);
            }
            
            // Apply limit
            if (items.size() > request.limitN) {
                List<ContentItem> limitedItems = new List<ContentItem>();
                for (Integer i = 0; i < request.limitN && i < items.size(); i++) {
                    limitedItems.add(items[i]);
                }
                items = limitedItems;
            }
            
        } catch (Exception e) {
            System.debug('Error searching ACT with lifecycle: ' + e.getMessage());
        }
        
        return items;
    }

    /**
     * @description Convert legacy results to new format for backwards compatibility
     * @param items List of content items
     * @return List of legacy intelligent results
     */
    private static List<IntelligentContentResult> convertToLegacyResults(List<ContentItem> items) {
        List<IntelligentContentResult> results = new List<IntelligentContentResult>();
        
        for (ContentItem item : items) {
            IntelligentContentResult result = new IntelligentContentResult();
            result.source = item.source;
            result.title = item.title;
            result.description = item.description;
            result.score = item.score;
            result.why = item.rationale;
            results.add(result);
        }
            
            return results;
    }

    /**
     * @description Get filter summary for explanation
     * @param request The search request
     * @return Filter summary string
     */
    private static String getFilterSummary(ContentSearchRequest request) {
        List<String> filters = new List<String>();
        
        if (request.activeOnly != null && request.activeOnly) {
            filters.add('active-only');
        }
        if (request.timeframe != null) {
            filters.add('timeframe=' + request.timeframe);
        }
        if (request.productTag != null) {
            filters.add('product=' + request.productTag);
        }
        if (request.minEnrollment != null) {
            filters.add('min-enrollment=' + request.minEnrollment);
        }
        if (request.minCompletionRate != null) {
            filters.add('min-completion=' + request.minCompletionRate + '%');
        }
        
        return filters.isEmpty() ? 'none' : String.join(filters, ', ');
    }

    /**
     * @description Date range helper class
     */
    public class DateRange {
        public Date startDate;
        public Date endDate;
        
        public DateRange(Date start, Date endDate) {
            this.startDate = start;
            this.endDate = endDate;
        }
    }

    /**
     * @description Calculate date range from timeframe or custom dates
     * @param timeframe The timeframe string
     * @param startDateStr Custom start date string
     * @param endDateStr Custom end date string
     * @return DateRange object
     */
    private static DateRange calculateDateRange(String timeframe, String startDateStr, String endDateStr) {
        Date startDate;
        Date endDate = Date.today();
        
        if (String.isNotBlank(startDateStr) && String.isNotBlank(endDateStr)) {
            // Custom date range
            startDate = Date.valueOf(startDateStr);
            endDate = Date.valueOf(endDateStr);
        } else if (timeframe == 'CURRENT') {
            // Current fiscal quarter
            startDate = Date.today().toStartOfMonth().addMonths(-3);
        } else if (timeframe == 'PREVIOUS') {
            // Previous fiscal quarter
            startDate = Date.today().toStartOfMonth().addMonths(-6);
            endDate = Date.today().toStartOfMonth().addMonths(-3).addDays(-1);
        } else {
            // Default to last 90 days
            startDate = Date.today().addDays(-90);
        }
        
        return new DateRange(startDate, endDate);
    }

    /**
     * @description Content item score comparator for sorting
     */
    public class ContentItemScoreComparator implements Comparator<ContentItem> {
        public Integer compare(ContentItem item1, ContentItem item2) {
            if (item1.score > item2.score) return -1;
            if (item1.score < item2.score) return 1;
            
            // Tie-break by recency
            if (item1.publishedDate != null && item2.publishedDate != null) {
                return item2.publishedDate.daysBetween(Date.today()) - item1.publishedDate.daysBetween(Date.today());
            }
            
            return 0;
        }
    }

    /**
     * @description Build SOQL query for Consensus content with lifecycle filters
     * @param request The search request
     * @param dateRange The date range for filtering
     * @return SOQL query string
     */
    private static String buildConsensusSOQL(ContentSearchRequest request, DateRange dateRange) {
        String soql = 'SELECT Id, Title__c, Description__c, CreatedDate, LastModifiedDate FROM Agent_Consensu__c WHERE ';
        
        List<String> conditions = new List<String>();
        
        // Basic search condition
        if (String.isNotBlank(request.userUtterance)) {
            String searchTerm = String.escapeSingleQuotes(request.userUtterance);
            conditions.add('(Title__c LIKE \'%' + searchTerm + '%\' OR Description__c LIKE \'%' + searchTerm + '%\')');
        }
        
        // Date range filter (using CreatedDate since PublishedDate__c doesn't exist)
        if (dateRange.startDate != null && dateRange.endDate != null) {
            conditions.add('(CreatedDate >= ' + dateRange.startDate.format() + 
                          ' AND CreatedDate <= ' + dateRange.endDate.format() + ')');
        }
        
        // Combine conditions
        if (!conditions.isEmpty()) {
            soql += String.join(conditions, ' AND ');
        } else {
            soql += 'Id != null';
        }
        
        soql += ' ORDER BY CreatedDate DESC LIMIT ' + (request.limitN != null ? request.limitN : 100);
        
        return soql;
    }

    /**
     * @description Convert Consensus record to ContentItem
     * @param record The database record
     * @param request The search request
     * @return ContentItem object
     */
    private static ContentItem convertConsensusToContentItem(Agent_Consensu__c record, ContentSearchRequest request) {
        ContentItem item = new ContentItem();
        
        item.source = 'CONSENSUS';
        item.title = record.Title__c;
        item.url = null; // Share_URL__c doesn't exist
        item.productTag = null; // ProductTag__c doesn't exist
        item.topicTag = null; // Topic__c doesn't exist
        item.description = record.Description__c;
        item.language = null; // Language__c doesn't exist
        item.creator = null; // Creator_Name__c doesn't exist
        item.isActive = true; // Default to active
        item.publishedDate = record.CreatedDate.date(); // Use CreatedDate since PublishedDate__c doesn't exist
        
        // Calculate score and rationale
        item.score = calculateConsensusScore(record, request);
        item.rationale = buildConsensusRationale(record, request, item.score);
        
        return item;
    }

    /**
     * @description Search Course__c objects with lifecycle filters
     * @param request The search request
     * @param dateRange The date range
     * @return List of content items
     */
    private static List<ContentItem> searchCourseObjects(ContentSearchRequest request, DateRange dateRange) {
        List<ContentItem> items = new List<ContentItem>();
        
        try {
            String soql = 'SELECT Id, Name, Description__c, Status__c, CreatedDate, Share_URL__c, Primary_Category__c ' +
                          'FROM Course__c WHERE Status__c = \'Active\'';
            
            if (!String.isBlank(request.userUtterance)) {
                String esc = String.escapeSingleQuotes(request.userUtterance);
                soql += ' AND (Name LIKE \'%' + esc + '%\' OR Description__c LIKE \'%' + esc + '%\')';
            }
            
            // Apply date range filter
            if (dateRange.startDate != null) {
                soql += ' AND CreatedDate >= ' + DateTime.newInstance(dateRange.startDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            }
            if (dateRange.endDate != null) {
                soql += ' AND CreatedDate <= ' + DateTime.newInstance(dateRange.endDate, Time.newInstance(23,59,59,999)).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            }
            
            Integer limitN = Math.max(1, (request.limitN == null ? 10 : request.limitN) / 3);
            soql += ' ORDER BY CreatedDate DESC LIMIT ' + limitN;
            
            List<SObject> rows = Database.query(soql);
            for (SObject r : rows) {
                ContentItem item = new ContentItem();
                item.source = 'ACT';
                item.title = (String)r.get('Name');
                item.description = (String)r.get('Description__c');
                item.url = (String)r.get('Share_URL__c');
                item.publishedDate = ((DateTime)r.get('CreatedDate')).date();
                item.productTag = (String)r.get('Primary_Category__c');
                
                // Calculate relevance score based on search term
                if (!String.isBlank(request.userUtterance) && !String.isBlank(item.title)) {
                    item.score = calculateFuzzyMatch(request.userUtterance.toLowerCase(), item.title.toLowerCase());
                } else {
                    item.score = 0.7; // Default score for ACT content
                }
                
                item.rationale = 'ACT course match: ' + item.title + ' (score: ' + item.score + ')';
                items.add(item);
            }
            
        } catch (Exception e) {
            System.debug('Error searching Course objects: ' + e.getMessage());
        }
        
        return items;
    }

    /**
     * @description Search Asset__c objects with lifecycle filters
     * @param request The search request
     * @param dateRange The date range
     * @return List of content items
     */
    private static List<ContentItem> searchAssetObjects(ContentSearchRequest request, DateRange dateRange) {
        List<ContentItem> items = new List<ContentItem>();
        
        try {
            String soql = 'SELECT Id, Name, Description__c, Status__c, CreatedDate, Share_URL__c, RecordType.DeveloperName ' +
                          'FROM Asset__c WHERE Status__c = \'Active\'';
            
            if (!String.isBlank(request.userUtterance)) {
                String esc = String.escapeSingleQuotes(request.userUtterance);
                soql += ' AND (Name LIKE \'%' + esc + '%\' OR Description__c LIKE \'%' + esc + '%\')';
            }
            
            // Apply date range filter
            if (dateRange.startDate != null) {
                soql += ' AND CreatedDate >= ' + DateTime.newInstance(dateRange.startDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            }
            if (dateRange.endDate != null) {
                soql += ' AND CreatedDate <= ' + DateTime.newInstance(dateRange.endDate, Time.newInstance(23,59,59,999)).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            }
            
            Integer limitN = Math.max(1, (request.limitN == null ? 10 : request.limitN) / 3);
            soql += ' ORDER BY CreatedDate DESC LIMIT ' + limitN;
            
            List<SObject> rows = Database.query(soql);
            for (SObject r : rows) {
                ContentItem item = new ContentItem();
                item.source = 'ACT';
                item.title = (String)r.get('Name');
                item.description = (String)r.get('Description__c');
                item.url = (String)r.get('Share_URL__c');
                item.publishedDate = ((DateTime)r.get('CreatedDate')).date();
                
                // Check RecordType for product categorization
                SObject rt = r.getSObject('RecordType');
                if (rt != null) {
                    String devName = (String)rt.get('DeveloperName');
                    if (!String.isBlank(devName) && devName.contains('Tableau')) {
                        item.productTag = 'Tableau';
                    }
                }
                
                // Calculate relevance score based on search term
                if (!String.isBlank(request.userUtterance) && !String.isBlank(item.title)) {
                    item.score = calculateFuzzyMatch(request.userUtterance.toLowerCase(), item.title.toLowerCase());
                } else {
                    item.score = 0.7; // Default score for ACT content
                }
                
                item.rationale = 'ACT asset match: ' + item.title + ' (score: ' + item.score + ')';
                items.add(item);
            }
            
        } catch (Exception e) {
            System.debug('Error searching Asset objects: ' + e.getMessage());
        }
        
        return items;
    }

    /**
     * @description Search Curriculum__c objects with lifecycle filters
     * @param request The search request
     * @param dateRange The date range
     * @return List of content items
     */
    private static List<ContentItem> searchCurriculumObjects(ContentSearchRequest request, DateRange dateRange) {
        List<ContentItem> items = new List<ContentItem>();
        
        try {
            String soql = 'SELECT Id, Name, Description__c, Status__c, CreatedDate, Share_URL__c ' +
                          'FROM Curriculum__c WHERE Status__c = \'Active\'';
            
            if (!String.isBlank(request.userUtterance)) {
                String esc = String.escapeSingleQuotes(request.userUtterance);
                soql += ' AND (Name LIKE \'%' + esc + '%\' OR Description__c LIKE \'%' + esc + '%\')';
            }
            
            // Apply date range filter
            if (dateRange.startDate != null) {
                soql += ' AND CreatedDate >= ' + DateTime.newInstance(dateRange.startDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            }
            if (dateRange.endDate != null) {
                soql += ' AND CreatedDate <= ' + DateTime.newInstance(dateRange.endDate, Time.newInstance(23,59,59,999)).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            }
            
            Integer limitN = Math.max(1, (request.limitN == null ? 10 : request.limitN) / 3);
            soql += ' ORDER BY CreatedDate DESC LIMIT ' + limitN;
            
            List<SObject> rows = Database.query(soql);
            for (SObject r : rows) {
                ContentItem item = new ContentItem();
                item.source = 'ACT';
                item.title = (String)r.get('Name');
                item.description = (String)r.get('Description__c');
                item.url = (String)r.get('Share_URL__c');
                item.publishedDate = ((DateTime)r.get('CreatedDate')).date();
                
                // Simple product categorization based on title content
                if (!String.isBlank(item.title) && item.title.contains('Tableau')) {
                    item.productTag = 'Tableau';
                }
                
                // Calculate relevance score based on search term
                if (!String.isBlank(request.userUtterance) && !String.isBlank(item.title)) {
                    item.score = calculateFuzzyMatch(request.userUtterance.toLowerCase(), item.title.toLowerCase());
                } else {
                    item.score = 0.7; // Default score for ACT content
                }
                
                item.rationale = 'ACT curriculum match: ' + item.title + ' (score: ' + item.score + ')';
                items.add(item);
            }
            
        } catch (Exception e) {
            System.debug('Error searching Curriculum objects: ' + e.getMessage());
        }
        
        return items;
    }

    /**
     * @description Check if utterance contains any of the keywords
     * @param utterance The user utterance
     * @param keywords Set of keywords to check
     * @return True if any keyword is found
     */
    private static Boolean containsAnyKeyword(String utterance, Set<String> keywords) {
        for (String keyword : keywords) {
            if (utterance.contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    /**
     * @description Extract key search terms from user utterance for better search compatibility
     * @param utterance The user utterance
     * @return Extracted search terms
     */
    private static String extractSearchTerms(String utterance) {
        if (String.isBlank(utterance)) return '';
        
        // List of important keywords to extract
        Set<String> importantKeywords = new Set<String>{
            'tableau', 'salesforce', 'apex', 'lwc', 'flow', 'admin', 'course', 'training',
            'learning', 'curriculum', 'asset', 'lifecycle', 'engagement', 'analytics',
            'trends', 'management', 'certification', 'boot camp', 'demo', 'video'
        };
        
        List<String> foundKeywords = new List<String>();
        String lowerUtterance = utterance.toLowerCase();
        
        for (String keyword : importantKeywords) {
            if (lowerUtterance.contains(keyword)) {
                foundKeywords.add(keyword);
            }
        }
        
        // If we found keywords, return them joined with spaces
        if (!foundKeywords.isEmpty()) {
            return String.join(foundKeywords, ' ');
        }
        
        // Fallback: return first few words of the utterance
        List<String> words = utterance.split('\\s+');
        if (words.size() <= 3) {
            return utterance;
        } else {
            List<String> firstWords = new List<String>();
            for (Integer i = 0; i < 3 && i < words.size(); i++) {
                firstWords.add(words[i]);
            }
            return String.join(firstWords, ' ');
        }
    }

    /**
     * @description Calculate score for Consensus content
     * @param record The database record
     * @param request The search request
     * @return Score between 0 and 1
     */
    private static Decimal calculateConsensusScore(Agent_Consensu__c record, ContentSearchRequest request) {
        Decimal score = 0.0;
        
        // Title relevance (40%)
        if (String.isNotBlank(record.Title__c) && String.isNotBlank(request.userUtterance)) {
            score += calculateFuzzyMatch(record.Title__c, request.userUtterance) * 0.4;
        }
        
        // Recency (50% - increased since we don't have product tags)
        if (record.CreatedDate != null) {
            Integer daysSince = record.CreatedDate.date().daysBetween(Date.today());
            score += Math.max(0, (90 - daysSince) / 90.0) * 0.5;
        }
        
        // Engagement score (10%)
        score += 0.1; // Base engagement
        
        return Math.min(1.0, score);
    }

    /**
     * @description Build rationale for Consensus content
     * @param record The database record
     * @param request The search request
     * @param score The calculated score
     * @return Human-readable rationale
     */
    private static String buildConsensusRationale(Agent_Consensu__c record, ContentSearchRequest request, Decimal score) {
        List<String> reasons = new List<String>();
        
        if (record.CreatedDate != null) {
            Integer daysSince = record.CreatedDate.date().daysBetween(Date.today());
            reasons.add('recent (' + daysSince + 'd)');
        }
        
        reasons.add('title fuzzy=' + String.valueOf(score.setScale(2)));
        
        return String.join(reasons, ', ');
    }

    /**
     * @description Calculate fuzzy match score between two strings
     * @param str1 First string
     * @param str2 Second string
     * @return Match score (0-1)
     */
    private static Decimal calculateFuzzyMatch(String str1, String str2) {
        if (String.isBlank(str1) || String.isBlank(str2)) {
            return 0.0;
        }
        
        String lower1 = str1.toLowerCase();
        String lower2 = str2.toLowerCase();
        
        // Simple Jaccard similarity on trigrams
        Set<String> trigrams1 = getTrigrams(lower1);
        Set<String> trigrams2 = getTrigrams(lower2);
        
        Set<String> intersection = new Set<String>(trigrams1);
        intersection.retainAll(trigrams2);
        
        Set<String> union = new Set<String>(trigrams1);
        union.addAll(trigrams2);
        
        return union.isEmpty() ? 0.0 : (Decimal)intersection.size() / union.size();
    }

    /**
     * @description Get trigrams from a string
     * @param str Input string
     * @return Set of trigrams
     */
    private static Set<String> getTrigrams(String str) {
        Set<String> trigrams = new Set<String>();
        
        if (String.isBlank(str) || str.length() < 3) {
            return trigrams;
        }
        
        for (Integer i = 0; i <= str.length() - 3; i++) {
            trigrams.add(str.substring(i, i + 3));
        }
        
        return trigrams;
    }
}
