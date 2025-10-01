public with sharing class ANAgentOpenPipeHandler {
    
    public class OpenPipeSearchRequest {
                            @InvocableVariable(label='Search Term' description='Enter the search term to find open pipe opportunities. For combined searches, use multiple terms like "AMER ENTR" or "Tableau Cloud AMER". Examples: "Tableau Cloud" (product), "AMER" (region), "ENTR" (segment), "FINS" (vertical), "United States" (country), "john.smith@salesforce.com" (AE email), "John Smith" (AE name), or "AMER ENTR" (region + segment). When using combined terms, set Search Type to "All" for best results.' required=true)
                    public String searchTerm;
                    
                    @InvocableVariable(label='Search Type' description='Choose the type of search to perform: "Product" (searches PRODUCT_L2__c), "Region" (searches EMPLOYEE_LOCATION_REGION__c and EMPLOYEE_PCC_REGION__c), "Vertical" (searches FORMATTED_VERTICAL__c), "Segment" (searches MACRO_SEGMENT__c and SIMPLE_SEGMENT__c), "Country" (searches EMPLOYEE_LOCATION_COUNTRY__c), "AE" (searches Name, EMPLOYEE_EMAIL__c, and POSITION_WORKER_EMAIL__c), or "All" (searches across all fields). Use "All" for combined searches like "AMER ENTR". Default is "All" if not specified.' required=false)
                    public String searchType;
                    
                    @InvocableVariable(label='Forecast Type' description='CRITICAL: Filter results by specific forecast type. Available types: "OpenPipe_ACV" (open pipeline annual contract value) and "PipeGen" (pipe generation). DO NOT use "PipeGen_ACV" - this does not exist. When users ask for "ACV and PG volume", use "OpenPipe_ACV" for ACV and "PipeGen" for pipe generation. For combined searches, use the Multi-Forecast action instead.' required=false)
                    public String forecastType;
                    
                    @InvocableVariable(label='Max Results' description='Maximum number of records to return in the search results. Recommended values: 5-10 for quick summaries, 20-50 for detailed analysis. Default is 50 if not specified. Higher values may impact performance. For "top 3 products" requests, use 10-20 to ensure you get enough data to aggregate and rank the top 3.' required=false)
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
        @InvocableVariable(label='Success' description='Boolean indicating whether the search operation completed successfully. True if records were found or search executed without errors, False if no records found or errors occurred.')
        public Boolean success;
        
        @InvocableVariable(label='Message' description='Human-readable response message summarizing the search results. Includes total count, search criteria, and key insights like product/region breakdowns. Example: "Found 15 open pipe opportunities for forecast type OpenPipe_ACV matching Tableau Cloud. Product breakdown: Tableau Cloud: $457M, Other: $123M."')
        public String message;
        
        @InvocableVariable(label='Total Count' description='Total number of OpenPipe opportunity records found matching the search criteria. This represents the actual count of individual opportunity records, not aggregated summaries.')
        public Integer totalCount;
        
        @InvocableVariable(label='OpenPipe Records' description='Complete list of OpenPipe opportunity records found. Each record contains detailed information including employee details, product information, values, rankings, segments, regions, and other opportunity metadata. Use this for detailed analysis of individual opportunities.')
        public List<ANAgentOpenPipeService.OpenPipeInfo> openPipeRecords;
        
        @InvocableVariable(label='Top Performers' description='Subset of the highest-value opportunities, automatically sorted by VALUE__c in descending order. Typically contains the top 10 performers from the search results. Use this for quick identification of the most valuable opportunities.')
        public List<ANAgentOpenPipeService.OpenPipeInfo> topPerformers;
        
        @InvocableVariable(label='Product Summary' description='Aggregated summary of opportunity values grouped by PRODUCT_L2__c. Shows total pipeline value for each product category. Format: "Product breakdown: Product1: $Value1, Product2: $Value2". Useful for understanding product performance across opportunities.')
        public String productSummary;
        
        @InvocableVariable(label='Region Summary' description='Aggregated summary of opportunity values grouped by EMPLOYEE_LOCATION_REGION__c. Shows total pipeline value for each region. Format: "Region breakdown: Region1: $Value1, Region2: $Value2". Useful for understanding regional performance and distribution.')
        public String regionSummary;
        
        @InvocableVariable(label='Vertical Summary' description='Aggregated summary of opportunity values grouped by FORMATTED_VERTICAL__c. Shows total pipeline value for each industry vertical. Format: "Vertical breakdown: Vertical1: $Value1, Vertical2: $Value2". Useful for understanding industry-specific opportunity distribution.')
        public String verticalSummary;
        
        @InvocableVariable(label='Segment Summary' description='Aggregated summary of opportunity values grouped by MACRO_SEGMENT__c. Shows total pipeline value for each segment (e.g., ENTR, ESMB). Format: "Segment breakdown: Segment1: $Value1, Segment2: $Value2". Useful for understanding segment performance and opportunity distribution.')
        public String segmentSummary;
        
        @InvocableVariable(label='Country Summary' description='Aggregated summary of opportunity values grouped by EMPLOYEE_LOCATION_COUNTRY__c. Shows total pipeline value for each country. Format: "Country breakdown: Country1: $Value1, Country2: $Value2". Useful for understanding geographic opportunity distribution.')
        public String countrySummary;
        
        public OpenPipeSearchResponse() {
            this.success = false;
            this.message = '';
            this.totalCount = 0;
            this.openPipeRecords = new List<ANAgentOpenPipeService.OpenPipeInfo>();
            this.topPerformers = new List<ANAgentOpenPipeService.OpenPipeInfo>();
            this.productSummary = '';
            this.regionSummary = '';
            this.verticalSummary = '';
            this.segmentSummary = '';
            this.countrySummary = '';
        }
    }
    
                    @InvocableMethod(
                    label='ANAgent Search OpenPipe'
                    description='Searches for high-value open pipe opportunities and pipe generation opportunities across multiple dimensions. This action helps identify the best pipeline opportunities by product, region, vertical, segment, country, or Account Executive. Returns comprehensive data including individual opportunity records, aggregated summaries by dimension, top performers by value, and detailed metadata. Use this to analyze pipeline performance, identify high-value opportunities, understand regional/segment distribution, and support strategic decision-making. The action automatically provides value breakdowns by product, region, vertical, segment, and country, making it easy to understand opportunity distribution and performance across different business dimensions. For combined searches like "AMER ENTR", use searchType "All" and include both terms in searchTerm. For multiple forecast types (ACV and PG), use "OpenPipe_ACV" for ACV opportunities and "PipeGen" for pipe generation opportunities. DO NOT use "PipeGen_ACV" - this forecast type does not exist. For combined ACV and PG searches, use the Multi-Forecast action instead.'
                )
                public static List<OpenPipeSearchResponse> searchOpenPipe(List<OpenPipeSearchRequest> requests) {
        List<OpenPipeSearchResponse> responses = new List<OpenPipeSearchResponse>();
        
        for (OpenPipeSearchRequest request : requests) {
            OpenPipeSearchResponse response = new OpenPipeSearchResponse();
            
            try {
                // Set defaults
                String searchType = String.isNotBlank(request.searchType) ? request.searchType : 'All';
                String forecastType = request.forecastType;
                Integer maxResults = request.maxResults != null ? request.maxResults : 50;
                
                // Validate search term
                if (String.isBlank(request.searchTerm)) {
                    response.message = 'Search term is required';
                    responses.add(response);
                    continue;
                }
                
                // Perform search
                ANAgentOpenPipeService.OpenPipeSearchResult searchResult = 
                    ANAgentOpenPipeService.searchOpenPipe(request.searchTerm, searchType, forecastType, maxResults);
                
                if (searchResult != null && !searchResult.records.isEmpty()) {
                    response.success = true;
                    response.totalCount = searchResult.totalCount;
                    response.openPipeRecords = searchResult.records;
                    response.topPerformers = searchResult.topPerformers;
                    
                    // Format summaries
                    response.productSummary = formatSummary(searchResult.productSummary, 'Product');
                    response.regionSummary = formatSummary(searchResult.regionSummary, 'Region');
                    response.verticalSummary = formatSummary(searchResult.verticalSummary, 'Vertical');
                    response.segmentSummary = formatSummary(searchResult.segmentSummary, 'Segment');
                    response.countrySummary = formatSummary(searchResult.countrySummary, 'Country');
                    
                                    // Build response message
                response.message = 'Found ' + searchResult.totalCount + ' open pipe opportunities';
                if (String.isNotBlank(forecastType)) {
                    // Check if the forecast type was valid
                    List<String> availableForecastTypes = ANAgentOpenPipeService.getAvailableForecastTypes();
                    if (!availableForecastTypes.contains(forecastType)) {
                        response.message += ' for all forecast types (invalid forecast type "' + forecastType + '" was provided, available types: ' + String.join(availableForecastTypes, ', ') + ')';
                    } else {
                        response.message += ' for forecast type "' + forecastType + '"';
                    }
                }
                response.message += ' matching "' + request.searchTerm + '"';
                    
                    // Add summary information
                    if (String.isNotBlank(response.productSummary)) {
                        response.message += '. ' + response.productSummary;
                    }
                    if (String.isNotBlank(response.regionSummary)) {
                        response.message += '. ' + response.regionSummary;
                    }
                    
                } else {
                    response.message = 'No open pipe opportunities found matching "' + request.searchTerm + '"';
                    if (String.isNotBlank(forecastType)) {
                        // Check if the forecast type was valid
                        List<String> availableForecastTypes = ANAgentOpenPipeService.getAvailableForecastTypes();
                        if (!availableForecastTypes.contains(forecastType)) {
                            response.message += ' for all forecast types (invalid forecast type "' + forecastType + '" was provided, available types: ' + String.join(availableForecastTypes, ', ') + ')';
                        } else {
                            response.message += ' for forecast type "' + forecastType + '"';
                        }
                    }
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
    
    private static String formatSummary(Map<String, Double> summary, String type) {
        if (summary == null || summary.isEmpty()) {
            return '';
        }
        
        List<String> formattedItems = new List<String>();
        for (String key : summary.keySet()) {
            Double value = summary.get(key);
            if (value != null && value > 0) {
                formattedItems.add(key + ': $' + String.valueOf(value.intValue()));
            }
        }
        
        if (formattedItems.isEmpty()) {
            return '';
        }
        
        // Sort by value descending
        formattedItems.sort();
        
        return type + ' breakdown: ' + String.join(formattedItems, ', ');
    }
    
    // Helper methods (not invocable)
    public static List<String> getAvailableForecastTypes() {
        return ANAgentOpenPipeService.getAvailableForecastTypes();
    }
    
    public static List<String> getAvailableProducts() {
        return ANAgentOpenPipeService.getAvailableProducts();
    }
    
    public static List<String> getAvailableRegions() {
        return ANAgentOpenPipeService.getAvailableRegions();
    }
    
    public static List<ANAgentOpenPipeService.OpenPipeInfo> getTopPerformersByProduct(String productName, String forecastType, Integer limitCount) {
        ANAgentOpenPipeService.OpenPipeSearchResult result = 
            ANAgentOpenPipeService.searchOpenPipe(productName, 'Product', forecastType, limitCount);
        return result != null ? result.topPerformers : new List<ANAgentOpenPipeService.OpenPipeInfo>();
    }
    
    public static List<ANAgentOpenPipeService.OpenPipeInfo> getTopPerformersByRegion(String regionName, String forecastType, Integer limitCount) {
        ANAgentOpenPipeService.OpenPipeSearchResult result = 
            ANAgentOpenPipeService.searchOpenPipe(regionName, 'Region', forecastType, limitCount);
        return result != null ? result.topPerformers : new List<ANAgentOpenPipeService.OpenPipeInfo>();
    }
} 