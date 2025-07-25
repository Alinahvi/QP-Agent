/**
 * @description Handler class for SME search agent actions
 * @author AI Assistant
 * @version 1.0
 */
public with sharing class ANAgentSMESearchHandler {
    
    /**
     * @description Request wrapper for SME search
     */
    public class SMESearchRequest {
        @InvocableVariable(label='Search Term' description='The search term (product name, AE name, or organizational unit)' required=true)
        public String searchTerm;
        
        @InvocableVariable(label='Search Type' description='Type of search: Product, AE, OU, or All' required=false)
        public String searchType;
        
        @InvocableVariable(label='Max Results' description='Maximum number of results to return (default: 50)' required=false)
        public Integer maxResults;
        
        public SMESearchRequest() {}
        
        public SMESearchRequest(String searchTerm, String searchType, Integer maxResults) {
            this.searchTerm = searchTerm;
            this.searchType = searchType;
            this.maxResults = maxResults;
        }
    }
    
    /**
     * @description Response wrapper for SME search
     */
    public class SMESearchResponse {
        @InvocableVariable(label='Success' description='Whether the search was successful')
        public Boolean success;
        
        @InvocableVariable(label='Message' description='Response message with search summary')
        public String message;
        
        @InvocableVariable(label='SME Records' description='List of SME records found')
        public List<ANAgentSMESearchService.SMEInfo> smeRecords;
        
        @InvocableVariable(label='Total Count' description='Total number of SMEs found')
        public Integer totalCount;
        
        @InvocableVariable(label='Product Summary' description='Summary of SMEs by product')
        public String productSummary;
        
        @InvocableVariable(label='Top Performers' description='Top performing SMEs by ACV')
        public List<ANAgentSMESearchService.SMEInfo> topPerformers;
        
        @InvocableVariable(label='Errors' description='List of any errors encountered')
        public List<String> errors;
        
        public SMESearchResponse() {
            this.success = false;
            this.message = '';
            this.smeRecords = new List<ANAgentSMESearchService.SMEInfo>();
            this.totalCount = 0;
            this.productSummary = '';
            this.topPerformers = new List<ANAgentSMESearchService.SMEInfo>();
            this.errors = new List<String>();
        }
    }
    
    /**
     * @description Main invocable method for SME search
     * @param requests List of search requests
     * @return List of search responses
     */
    @InvocableMethod(
        label='ANAgent Search SMEs'
        description='Searches for Subject Matter Experts (SMEs) by product, AE name, or organizational unit. Returns detailed SME information including rankings, ACV, and product expertise to help identify the best experts for specific products.'
    )
    public static List<SMESearchResponse> searchSMEs(List<SMESearchRequest> requests) {
        List<SMESearchResponse> responses = new List<SMESearchResponse>();

        // Handle null or empty requests
        if (requests == null || requests.isEmpty()) {
            SMESearchResponse errorResponse = new SMESearchResponse();
            errorResponse.message = 'No search request provided.';
            errorResponse.errors.add('Request list is null or empty.');
            responses.add(errorResponse);
            return responses;
        }

        // Process each request
        for (SMESearchRequest request : requests) {
            SMESearchResponse response = new SMESearchResponse();
            
            try {
                // Validate request
                if (String.isBlank(request.searchTerm)) {
                    response.message = 'Search term is required.';
                    response.errors.add('Search term cannot be blank.');
                    responses.add(response);
                    continue;
                }
                
                // Set defaults
                String searchType = String.isNotBlank(request.searchType) ? request.searchType : 'All';
                Integer maxResults = request.maxResults != null && request.maxResults > 0 ? request.maxResults : 50;

                // Perform search
                ANAgentSMESearchService.SMESearchResult searchResult = 
                    ANAgentSMESearchService.searchSMEs(request.searchTerm, searchType, maxResults);

                // Process results
                response.success = searchResult.success;
                response.smeRecords = searchResult.records;
                response.totalCount = searchResult.totalCount;
                response.errors = searchResult.errors;

                // Build message
                if (searchResult.success) {
                    if (searchResult.totalCount > 0) {
                        response.message = 'Found ' + searchResult.totalCount + ' SME(s) matching "' + request.searchTerm + '"';
                        if (String.isNotBlank(searchType) && searchType != 'All') {
                            response.message += ' in ' + searchType + ' search';
                        }
                        response.message += '.';
                        
                        // Add product summary
                        if (searchResult.productCounts != null && !searchResult.productCounts.isEmpty()) {
                            List<String> productSummaries = new List<String>();
                            for (String product : searchResult.productCounts.keySet()) {
                                Integer count = searchResult.productCounts.get(product);
                                productSummaries.add(product + ' (' + count + ' SME' + (count > 1 ? 's' : '') + ')');
                            }
                            response.productSummary = 'Products covered: ' + String.join(productSummaries, ', ');
                            response.message += ' ' + response.productSummary;
                        }
                        
                        // Get top performers (top 5 by ACV)
                        response.topPerformers = getTopPerformers(searchResult.records, 5);
                        
                    } else {
                        response.message = 'No SMEs found matching "' + request.searchTerm + '"';
                        if (String.isNotBlank(searchType) && searchType != 'All') {
                            response.message += ' in ' + searchType + ' search';
                        }
                        response.message += '.';
                    }
                } else {
                    response.message = 'Search failed: ' + String.join(searchResult.errors, '; ');
                }

            } catch (Exception e) {
                response.success = false;
                response.message = 'An unexpected error occurred during SME search.';
                response.errors.add('Exception: ' + e.getMessage());
                System.debug('ANAgentSMESearchHandler error: ' + e.getMessage());
            }

            responses.add(response);
        }

        return responses;
    }
    
    /**
     * @description Get top performing SMEs by ACV
     * @param smeList List of SME records
     * @param limitCount Number of top performers to return
     * @return List<SMEInfo>
     */
    private static List<ANAgentSMESearchService.SMEInfo> getTopPerformers(
        List<ANAgentSMESearchService.SMEInfo> smeList, Integer limitCount) {
        
        if (smeList == null || smeList.isEmpty() || limitCount <= 0) {
            return new List<ANAgentSMESearchService.SMEInfo>();
        }
        
        // Sort by ACV descending and take top performers
        List<ANAgentSMESearchService.SMEInfo> sortedList = new List<ANAgentSMESearchService.SMEInfo>(smeList);
        sortedList.sort(new ACVComparator());
        
        List<ANAgentSMESearchService.SMEInfo> topPerformers = new List<ANAgentSMESearchService.SMEInfo>();
        for (Integer i = 0; i < Math.min(limitCount, sortedList.size()); i++) {
            topPerformers.add(sortedList[i]);
        }
        
        return topPerformers;
    }
    
    /**
     * @description Comparator class for sorting SMEs by ACV
     */
    private class ACVComparator implements Comparator<ANAgentSMESearchService.SMEInfo> {
        public Integer compare(ANAgentSMESearchService.SMEInfo a, ANAgentSMESearchService.SMEInfo b) {
            if (a.totalACV == null && b.totalACV == null) return 0;
            if (a.totalACV == null) return 1;
            if (b.totalACV == null) return -1;
            // Use simple comparison for descending order
            if (a.totalACV < b.totalACV) return 1;
            if (a.totalACV > b.totalACV) return -1;
            return 0;
        }
    }

    /**
     * @description Convenience method for single search request
     * @param searchTerm The search term
     * @param searchType Optional search type
     * @param maxResults Optional max results
     * @return SMESearchResponse
     */
    public static SMESearchResponse searchSMEs(String searchTerm, String searchType, Integer maxResults) {
        SMESearchRequest request = new SMESearchRequest(searchTerm, searchType, maxResults);
        List<SMESearchRequest> requests = new List<SMESearchRequest>{request};
        List<SMESearchResponse> responses = searchSMEs(requests);
        return responses.isEmpty() ? new SMESearchResponse() : responses[0];
    }

    /**
     * @description Convenience method for single search request without optional parameters
     * @param searchTerm The search term
     * @return SMESearchResponse
     */
    public static SMESearchResponse searchSMEs(String searchTerm) {
        return searchSMEs(searchTerm, null, null);
    }
    
    /**
     * @description Get all available products
     * @return List<String>
     */
    public static List<String> getAvailableProducts() {
        return ANAgentSMESearchService.getAllProducts();
    }
    
    /**
     * @description Get top SMEs for a specific product
     * @param productName The product name
     * @param limitCount Number of top SMEs to return
     * @return List<SMEInfo>
     */
    public static List<ANAgentSMESearchService.SMEInfo> getTopSMEsByProduct(String productName, Integer limitCount) {
        return ANAgentSMESearchService.getTopSMEsByProduct(productName, limitCount);
    }
} 