public with sharing class ANAgentOpenPipeHandlerV2 {
    
    public class OpenPipeSearchRequest {
        @InvocableVariable(label='Search Term' description='Enter the search term to find open pipe opportunities. Examples: "AMER ENTR" (region + segment), "Tableau Cloud" (product), "AMER" (region), "ENTR" (segment).' required=true)
        public String searchTerm;
        
        @InvocableVariable(label='Search Type' description='Choose the type of search: "Product", "Region", "Vertical", "Segment", "Country", "AE", or "All". Use "All" for combined searches like "AMER ENTR".' required=false)
        public String searchType;
        
        @InvocableVariable(label='Forecast Type' description='Filter by forecast type: "OpenPipe_ACV" (open pipeline annual contract value) or "PipeGen" (pipe generation). Leave blank to search all types.' required=false)
        public String forecastType;
        
        @InvocableVariable(label='Max Results' description='Maximum number of records to return. Recommended: 20-50 for good aggregation results.' required=false)
        public Integer maxResults;
        
        public OpenPipeSearchRequest() {}
        public OpenPipeSearchRequest(String searchTerm, String searchType, String forecastType, Integer maxResults) {
            this.searchTerm = searchTerm;
            this.searchType = searchType;
            this.forecastType = forecastType;
            this.maxResults = maxResults;
        }
    }
    
    public class OpenPipeSearchResponse {
        @InvocableVariable(label='Success' description='Boolean indicating whether the search was successful.')
        public Boolean success;
        
        @InvocableVariable(label='Message' description='Response message describing the search results.')
        public String message;
        
        @InvocableVariable(label='Validation Message' description='Validation message with guidance for improving the search.')
        public String validationMessage;
        
        @InvocableVariable(label='Total Count' description='Total number of records found.')
        public Integer totalCount;
        
        @InvocableVariable(label='OpenPipe Records' description='List of open pipe opportunity records.')
        public List<ANAgentOpenPipeServiceV2.OpenPipeInfo> openPipeRecords;
        
        @InvocableVariable(label='Product Summary' description='Summary of values by product.')
        public String productSummary;
        
        @InvocableVariable(label='Region Summary' description='Summary of values by region.')
        public String regionSummary;
        
        @InvocableVariable(label='Vertical Summary' description='Summary of values by vertical.')
        public String verticalSummary;
        
        @InvocableVariable(label='Segment Summary' description='Summary of values by segment.')
        public String segmentSummary;
        
        @InvocableVariable(label='Country Summary' description='Summary of values by country.')
        public String countrySummary;
        
        @InvocableVariable(label='Top Performers' description='Top performing opportunities by value.')
        public List<ANAgentOpenPipeServiceV2.OpenPipeInfo> topPerformers;
        
        public OpenPipeSearchResponse() {}
    }
    
    @InvocableMethod(
        label='ANAgent Search OpenPipe V2'
        description='Searches for open pipe opportunities and pipe generation opportunities. Use this action to find high-value opportunities by product, region, vertical, segment, country, or Account Executive. Returns comprehensive data including individual records, aggregated summaries, and top performers. For combined searches like "AMER ENTR", use searchType "All". For single forecast type searches, specify forecastType as "OpenPipe_ACV" or "PipeGen".'
    )
    public static List<OpenPipeSearchResponse> searchOpenPipe(List<OpenPipeSearchRequest> requests) {
        List<OpenPipeSearchResponse> responses = new List<OpenPipeSearchResponse>();
        
        for (OpenPipeSearchRequest request : requests) {
            OpenPipeSearchResponse response = new OpenPipeSearchResponse();
            
            try {
                // Set defaults
                String searchTerm = request.searchTerm != null ? request.searchTerm.trim() : '';
                String searchType = request.searchType != null ? request.searchType : 'All';
                String forecastType = request.forecastType;
                Integer maxResults = request.maxResults != null ? request.maxResults : 20;
                
                // Validate inputs
                if (String.isBlank(searchTerm)) {
                    response.success = false;
                    response.message = 'Search term is required.';
                    responses.add(response);
                    continue;
                }
                
                // Search for opportunities
                ANAgentOpenPipeServiceV2.OpenPipeSearchResult searchResult = 
                    ANAgentOpenPipeServiceV2.searchOpenPipe(searchTerm, searchType, forecastType, maxResults);
                
                // Check for validation messages first
                if (String.isNotBlank(searchResult.validationMessage)) {
                    response.success = false;
                    response.message = 'Search validation failed. Please refine your search.';
                    response.validationMessage = searchResult.validationMessage;
                    responses.add(response);
                    continue;
                }
                
                // Build response
                response.success = searchResult.totalCount > 0;
                response.totalCount = searchResult.totalCount;
                response.openPipeRecords = searchResult.records;
                response.topPerformers = searchResult.topPerformers;
                
                // Format summaries
                response.productSummary = formatSummary(searchResult.productSummary, 'Product');
                response.regionSummary = formatSummary(searchResult.regionSummary, 'Region');
                response.verticalSummary = formatSummary(searchResult.verticalSummary, 'Vertical');
                response.segmentSummary = formatSummary(searchResult.segmentSummary, 'Segment');
                response.countrySummary = formatSummary(searchResult.countrySummary, 'Country');
                
                // Build message
                if (response.success) {
                    response.message = 'Found ' + searchResult.totalCount + ' open pipe opportunities';
                    if (String.isNotBlank(forecastType)) {
                        response.message += ' for forecast type "' + forecastType + '"';
                    }
                    response.message += ' matching "' + searchTerm + '". ' + response.productSummary;
                } else {
                    response.message = 'No open pipe opportunities found matching "' + searchTerm + '"';
                    if (String.isNotBlank(forecastType)) {
                        response.message += ' for forecast type "' + forecastType + '"';
                    }
                    response.message += '. Try refining your search with more specific terms or different forecast types.';
                }
                
            } catch (Exception e) {
                response.success = false;
                response.message = 'Error searching open pipe opportunities: ' + e.getMessage();
                System.debug('Error in searchOpenPipe: ' + e.getMessage());
            }
            
            responses.add(response);
        }
        
        return responses;
    }
    
    private static String formatSummary(Map<String, Double> summary, String label) {
        if (summary == null || summary.isEmpty()) {
            return label + ' breakdown: No data available';
        }
        
        List<String> formattedItems = new List<String>();
        for (String key : summary.keySet()) {
            Double value = summary.get(key);
            if (value != null) {
                formattedItems.add(key + ': $' + value.intValue());
            }
        }
        
        return label + ' breakdown: ' + String.join(formattedItems, ', ');
    }
} 
    
    public class OpenPipeSearchRequest {
        @InvocableVariable(label='Search Term' description='Enter the search term to find open pipe opportunities. Examples: "AMER ENTR" (region + segment), "Tableau Cloud" (product), "AMER" (region), "ENTR" (segment).' required=true)
        public String searchTerm;
        
        @InvocableVariable(label='Search Type' description='Choose the type of search: "Product", "Region", "Vertical", "Segment", "Country", "AE", or "All". Use "All" for combined searches like "AMER ENTR".' required=false)
        public String searchType;
        
        @InvocableVariable(label='Forecast Type' description='Filter by forecast type: "OpenPipe_ACV" (open pipeline annual contract value) or "PipeGen" (pipe generation). Leave blank to search all types.' required=false)
        public String forecastType;
        
        @InvocableVariable(label='Max Results' description='Maximum number of records to return. Recommended: 20-50 for good aggregation results.' required=false)
        public Integer maxResults;
        
        public OpenPipeSearchRequest() {}
        public OpenPipeSearchRequest(String searchTerm, String searchType, String forecastType, Integer maxResults) {
            this.searchTerm = searchTerm;
            this.searchType = searchType;
            this.forecastType = forecastType;
            this.maxResults = maxResults;
        }
    }
    
    public class OpenPipeSearchResponse {
        @InvocableVariable(label='Success' description='Boolean indicating whether the search was successful.')
        public Boolean success;
        
        @InvocableVariable(label='Message' description='Response message describing the search results.')
        public String message;
        
        @InvocableVariable(label='Validation Message' description='Validation message with guidance for improving the search.')
        public String validationMessage;
        
        @InvocableVariable(label='Total Count' description='Total number of records found.')
        public Integer totalCount;
        
        @InvocableVariable(label='OpenPipe Records' description='List of open pipe opportunity records.')
        public List<ANAgentOpenPipeServiceV2.OpenPipeInfo> openPipeRecords;
        
        @InvocableVariable(label='Product Summary' description='Summary of values by product.')
        public String productSummary;
        
        @InvocableVariable(label='Region Summary' description='Summary of values by region.')
        public String regionSummary;
        
        @InvocableVariable(label='Vertical Summary' description='Summary of values by vertical.')
        public String verticalSummary;
        
        @InvocableVariable(label='Segment Summary' description='Summary of values by segment.')
        public String segmentSummary;
        
        @InvocableVariable(label='Country Summary' description='Summary of values by country.')
        public String countrySummary;
        
        @InvocableVariable(label='Top Performers' description='Top performing opportunities by value.')
        public List<ANAgentOpenPipeServiceV2.OpenPipeInfo> topPerformers;
        
        public OpenPipeSearchResponse() {}
    }
    
    @InvocableMethod(
        label='ANAgent Search OpenPipe V2'
        description='Searches for open pipe opportunities and pipe generation opportunities. Use this action to find high-value opportunities by product, region, vertical, segment, country, or Account Executive. Returns comprehensive data including individual records, aggregated summaries, and top performers. For combined searches like "AMER ENTR", use searchType "All". For single forecast type searches, specify forecastType as "OpenPipe_ACV" or "PipeGen".'
    )
    public static List<OpenPipeSearchResponse> searchOpenPipe(List<OpenPipeSearchRequest> requests) {
        List<OpenPipeSearchResponse> responses = new List<OpenPipeSearchResponse>();
        
        for (OpenPipeSearchRequest request : requests) {
            OpenPipeSearchResponse response = new OpenPipeSearchResponse();
            
            try {
                // Set defaults
                String searchTerm = request.searchTerm != null ? request.searchTerm.trim() : '';
                String searchType = request.searchType != null ? request.searchType : 'All';
                String forecastType = request.forecastType;
                Integer maxResults = request.maxResults != null ? request.maxResults : 20;
                
                // Validate inputs
                if (String.isBlank(searchTerm)) {
                    response.success = false;
                    response.message = 'Search term is required.';
                    responses.add(response);
                    continue;
                }
                
                // Search for opportunities
                ANAgentOpenPipeServiceV2.OpenPipeSearchResult searchResult = 
                    ANAgentOpenPipeServiceV2.searchOpenPipe(searchTerm, searchType, forecastType, maxResults);
                
                // Check for validation messages first
                if (String.isNotBlank(searchResult.validationMessage)) {
                    response.success = false;
                    response.message = 'Search validation failed. Please refine your search.';
                    response.validationMessage = searchResult.validationMessage;
                    responses.add(response);
                    continue;
                }
                
                // Build response
                response.success = searchResult.totalCount > 0;
                response.totalCount = searchResult.totalCount;
                response.openPipeRecords = searchResult.records;
                response.topPerformers = searchResult.topPerformers;
                
                // Format summaries
                response.productSummary = formatSummary(searchResult.productSummary, 'Product');
                response.regionSummary = formatSummary(searchResult.regionSummary, 'Region');
                response.verticalSummary = formatSummary(searchResult.verticalSummary, 'Vertical');
                response.segmentSummary = formatSummary(searchResult.segmentSummary, 'Segment');
                response.countrySummary = formatSummary(searchResult.countrySummary, 'Country');
                
                // Build message
                if (response.success) {
                    response.message = 'Found ' + searchResult.totalCount + ' open pipe opportunities';
                    if (String.isNotBlank(forecastType)) {
                        response.message += ' for forecast type "' + forecastType + '"';
                    }
                    response.message += ' matching "' + searchTerm + '". ' + response.productSummary;
                } else {
                    response.message = 'No open pipe opportunities found matching "' + searchTerm + '"';
                    if (String.isNotBlank(forecastType)) {
                        response.message += ' for forecast type "' + forecastType + '"';
                    }
                    response.message += '. Try refining your search with more specific terms or different forecast types.';
                }
                
            } catch (Exception e) {
                response.success = false;
                response.message = 'Error searching open pipe opportunities: ' + e.getMessage();
                System.debug('Error in searchOpenPipe: ' + e.getMessage());
            }
            
            responses.add(response);
        }
        
        return responses;
    }
    
    private static String formatSummary(Map<String, Double> summary, String label) {
        if (summary == null || summary.isEmpty()) {
            return label + ' breakdown: No data available';
        }
        
        List<String> formattedItems = new List<String>();
        for (String key : summary.keySet()) {
            Double value = summary.get(key);
            if (value != null) {
                formattedItems.add(key + ': $' + value.intValue());
            }
        }
        
        return label + ' breakdown: ' + String.join(formattedItems, ', ');
    }
} 