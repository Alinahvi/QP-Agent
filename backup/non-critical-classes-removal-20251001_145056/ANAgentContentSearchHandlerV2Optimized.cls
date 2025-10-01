public with sharing class ANAgentContentSearchHandlerV2Optimized {

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
                    response.message = formatSuccessMessage(searchResult.totalCount, 'ACT learning content');
                } else if (searchMode == 'CONSENSUS') {
                    ANAgentContentSearchServiceV2.ContentSearchResult searchResult = 
                        ANAgentContentSearchServiceV2.searchConsensus(request.searchTerm);
                    response.success = searchResult.success;
                    response.totalRecordCount = searchResult.totalCount;
                    response.errors = searchResult.errors;
                    response.results = searchResult.records;
                    response.message = formatSuccessMessage(searchResult.totalCount, 'Consensus demo videos');
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
                    
                    if (isConsensusRequest && !isACTRequest) {
                        ANAgentContentSearchServiceV2.ContentSearchResult searchResult = 
                            ANAgentContentSearchServiceV2.searchConsensus(request.searchTerm);
                        response.success = searchResult.success;
                        response.totalRecordCount = searchResult.totalCount;
                        response.errors = searchResult.errors;
                        response.results = searchResult.records;
                        response.message = formatSuccessMessage(searchResult.totalCount, 'Consensus demo videos');
                    } else if (isACTRequest || (!isConsensusRequest && !isACTRequest)) {
                        ANAgentContentSearchServiceV2.ContentSearchResult searchResult = 
                            ANAgentContentSearchServiceV2.search(request.searchTerm, request.contentType);
                        response.success = searchResult.success;
                        response.totalRecordCount = searchResult.totalCount;
                        response.errors = searchResult.errors;
                        response.results = searchResult.records;
                        response.message = formatSuccessMessage(searchResult.totalCount, 'ACT learning content');
                    } else {
                        // Both keywords detected - search both
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
            
            if (isConsensusRequest && !isACTRequest) {
                return 'Auto-routed to Consensus based on keywords: ' + String.join(new List<String>(consensusKeywords), ', ');
            } else if (isACTRequest || (!isConsensusRequest && !isACTRequest)) {
                return 'Auto-routed to ACT based on keywords: ' + String.join(new List<String>(actKeywords), ', ') + ' or default';
            } else {
                return 'Auto-routed to BOTH sources - both keyword sets detected';
            }
        }
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
}
