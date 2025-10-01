/**
 * @description Simplified Handler class for SME search functionality
 * @author AI Assistant
 * @version 1.0
 */
public with sharing class ANAgentSMESearchHandlerSimple {
    
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
     */
    public class SMESearchResponse {
        @InvocableVariable(label='Success' description='Whether the search was successful')
        public Boolean success;
        
        @InvocableVariable(label='Message' description='Response message')
        public String message;
        
        @InvocableVariable(label='Records' description='List of SME records found')
        public List<ANAgentSMESearchServiceSimple.SMEInfo> records;
        
        @InvocableVariable(label='Total Record Count' description='Total number of records found')
        public Integer totalRecordCount;
        
        @InvocableVariable(label='Errors' description='List of any errors encountered')
        public List<String> errors;
    }
    
    /**
     * @description Invocable method for SME search
     */
    @InvocableMethod(label='Search SMEs' description='Search for Subject Matter Experts by product or name')
    public static List<SMESearchResponse> searchSMEs(List<SMESearchRequest> requests) {
        List<SMESearchResponse> responses = new List<SMESearchResponse>();
        
        for (SMESearchRequest request : requests) {
            SMESearchResponse response = new SMESearchResponse();
            
            try {
                // Set defaults
                String searchType = String.isNotBlank(request.searchType) ? request.searchType : 'Product';
                Integer maxResults = request.maxResults != null ? request.maxResults : 10;
                Boolean academyMembersOnly = request.academyMembersOnly != null ? request.academyMembersOnly : false;
                Boolean useEnhancedSearch = request.useEnhancedSearch != null ? request.useEnhancedSearch : true;
                
                // Perform search
                ANAgentSMESearchServiceSimple.SMESearchResult searchResult;
                if (useEnhancedSearch) {
                    searchResult = ANAgentSMESearchServiceSimple.searchSMEsEnhanced(request.searchTerm, searchType, maxResults, academyMembersOnly, request.ouName);
                } else {
                    // Fallback to basic search if needed
                    searchResult = ANAgentSMESearchServiceSimple.searchSMEsEnhanced(request.searchTerm, searchType, maxResults, academyMembersOnly, request.ouName);
                }
                
                // Populate response
                response.success = searchResult.success;
                response.message = searchResult.message;
                response.records = searchResult.records;
                response.totalRecordCount = searchResult.totalRecordCount;
                response.errors = searchResult.errors;
                
                // Format message for display
                if (response.success && !response.records.isEmpty()) {
                    response.message = formatSMESearchMessage(response.records, searchType);
                }
                
            } catch (Exception e) {
                response.success = false;
                response.message = 'Error in SME search: ' + e.getMessage();
                response.errors = new List<String>{e.getMessage()};
                response.records = new List<ANAgentSMESearchServiceSimple.SMEInfo>();
                response.totalRecordCount = 0;
            }
            
            responses.add(response);
        }
        
        return responses;
    }
    
    /**
     * @description Format SME search results into a readable message
     */
    private static String formatSMESearchMessage(List<ANAgentSMESearchServiceSimple.SMEInfo> records, String searchType) {
        if (records.isEmpty()) {
            return 'No SMEs found for the specified criteria.';
        }
        
        String message = 'Found ' + records.size() + ' SME(s) for ' + searchType + ' search:\n\n';
        
        for (Integer i = 0; i < records.size(); i++) {
            ANAgentSMESearchServiceSimple.SMEInfo sme = records[i];
            message += (i + 1) + '. ' + sme.aeName;
            
            if (String.isNotBlank(sme.organizationalUnit)) {
                message += ' (' + sme.organizationalUnit + ')';
            }
            
            if (String.isNotBlank(sme.productL2)) {
                message += ' - ' + sme.productL2;
            }
            
            if (sme.isAcademyMember == true) {
                message += ' [Excellence Academy]';
            }
            
            if (sme.relevanceScore != null && sme.relevanceScore > 0) {
                message += ' [Score: ' + sme.relevanceScore + ']';
            }
            
            if (String.isNotBlank(sme.scoringRationale)) {
                message += ' [Rationale: ' + sme.scoringRationale + ']';
            }
            
            message += '\n';
        }
        
        return message;
    }
}

