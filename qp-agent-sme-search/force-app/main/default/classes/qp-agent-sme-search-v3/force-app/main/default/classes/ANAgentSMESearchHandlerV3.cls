/**
 * @description SME Search Handler V3 - FR-style dumb router implementation
 * @author AI Assistant
 * @version 3.0
 * Follows FR agent best practices: dumb router with single message output
 */
public with sharing class ANAgentSMESearchHandlerV3 {
    
    /**
     * @description Request wrapper for SME search
     */
    public class SMESearchRequest {
        @InvocableVariable(label='Search Term' description='Product or SME name to search for' required=true)
        public String searchTerm;
        
        @InvocableVariable(label='Search Type' description='Type of search: Product, Name, or All' required=false)
        public String searchType;
        
        @InvocableVariable(label='Max Results' description='Maximum number of results to return' required=false)
        public Integer maxResults;
        
        @InvocableVariable(label='Academy Members Only' description='Filter to only Excellence Academy members' required=false)
        public Boolean academyMembersOnly;
        
        @InvocableVariable(label='OU Name' description='Organizational unit name for context-aware ranking' required=false)
        public String ouName;
        
        @InvocableVariable(label='Use Enhanced Search' description='Whether to use enhanced search with ranking and fuzzy matching' required=false)
        public Boolean useEnhancedSearch;
    }
    
    /**
     * @description Response wrapper for SME search
     * Follows FR agent best practices: ONLY message field exposed to agent
     */
    public class SMESearchResponse {
        @InvocableVariable(
            label='SME Search Message'
            description='Complete SME search results formatted as a human-readable message with detailed SME information, insights, and rankings.'
            required=true
        )
        public String message;
        
        public SMESearchResponse() {
            this.message = '';
        }
    }
    
    /**
     * @description Dumb router - exactly one invocable method, no business logic
     * Maps input → calls service → maps service result to message string → returns
     */
    @InvocableMethod(
        label='Search SMEs V3'
        description='Search for Subject Matter Experts by product or name with enhanced ranking. Returns complete formatted results with SME details, insights, and rankings in a single message.'
    )
    public static List<SMESearchResponse> searchSMEs(List<SMESearchRequest> requests) {
        List<SMESearchResponse> responses = new List<SMESearchResponse>();
        
        if (requests == null || requests.isEmpty()) {
            SMESearchResponse errRes = new SMESearchResponse();
            errRes.message = '# SME Search Error\n\n**Error**: No request provided.';
            responses.add(errRes);
            return responses;
        }
        
        for (SMESearchRequest request : requests) {
            SMESearchResponse response = new SMESearchResponse();
            
            // Validate required fields
            if (String.isBlank(request.searchTerm)) {
                response.message = '# SME Search Error\n\n**Error**: Search term is required for SME search.';
                responses.add(response);
                continue;
            }
            
            // Set defaults
            String searchType = String.isNotBlank(request.searchType) ? request.searchType : 'product';
            Integer maxResults = request.maxResults != null ? request.maxResults : 10;
            Boolean academyMembersOnly = request.academyMembersOnly != null ? request.academyMembersOnly : false;
            
            // Call service - service handles ALL business logic and returns complete message
            try {
                response.message = ANAgentSMESearchServiceV3.searchSMEsEnhanced(
                    request.searchTerm, 
                    searchType, 
                    maxResults, 
                    academyMembersOnly, 
                    request.ouName
                );
            } catch (Exception e) {
                response.message = '# SME Search Error\n\n**Error**: An error occurred during SME search: ' + e.getMessage();
                System.debug(
                    LoggingLevel.ERROR,
                    'SME Search Handler Error: ' + e.getStackTraceString()
                );
            }
            
            responses.add(response);
        }
        
        return responses;
    }
}
