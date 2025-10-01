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
        
        @InvocableVariable(label='Search Type' description='Type of search: PRODUCT, AE, OU, or ALL' required=false)
        public String searchType;
        
        @InvocableVariable(label='Max Results' description='Maximum number of results to return (default: 25, max: 100)' required=false)
        public Integer maxResults;
        
        @InvocableVariable(label='Academy Members Only' description='Whether to filter for Academy members only' required=false)
        public Boolean academyMembersOnly;
        
        @InvocableVariable(label='OU Name' description='Organizational unit name for context-aware ranking' required=false)
        public String ouName;
        
        @InvocableVariable(label='Use Enhanced Search' description='Whether to use enhanced search with ranking and fuzzy matching' required=false)
        public Boolean useEnhancedSearch;
        
        // Enhanced parameters for MCP integration
        @InvocableVariable(label='Work Location Country' description='Country filter for work location' required=false)
        public String workLocationCountry;
        
        @InvocableVariable(label='Product Level' description='Product level filter: L2, L3, or ANY' required=false)
        public String productLevel;
        
        @InvocableVariable(label='Require Same OU' description='Require results to be from same OU' required=false)
        public Boolean requireSameOU;
        
        @InvocableVariable(label='Include Stale' description='Include stale records (older than 180 days)' required=false)
        public Boolean includeStale;
        
        public SMESearchRequest() {}
        
        public SMESearchRequest(String searchTerm, String searchType, Integer maxResults, Boolean academyMembersOnly) {
            this.searchTerm = searchTerm;
            this.searchType = searchType;
            this.maxResults = maxResults;
            this.academyMembersOnly = academyMembersOnly;
            this.useEnhancedSearch = false;
        }
        
        public SMESearchRequest(String searchTerm, String searchType, Integer maxResults, Boolean academyMembersOnly, String ouName, Boolean useEnhancedSearch) {
            this.searchTerm = searchTerm;
            this.searchType = searchType;
            this.maxResults = maxResults;
            this.academyMembersOnly = academyMembersOnly;
            this.ouName = ouName;
            this.useEnhancedSearch = useEnhancedSearch;
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
        
        @InvocableVariable(label='Academy Members Count' description='Number of Academy members in results')
        public Integer academyMembersCount;
        
        @InvocableVariable(label='Errors' description='List of any errors encountered')
        public List<String> errors;
        
        // Enhanced fields for MCP integration
        @InvocableVariable(label='Search Term' description='The search term used')
        public String searchTerm;
        
        @InvocableVariable(label='Search Type' description='The search type used')
        public String searchType;
        
        @InvocableVariable(label='OU Name' description='The OU name used')
        public String ouName;
        
        @InvocableVariable(label='Country' description='The country filter used')
        public String country;
        
        @InvocableVariable(label='Academy Only' description='Whether Academy filter was applied')
        public Boolean academyOnly;
        
        @InvocableVariable(label='Require Same OU' description='Whether same OU requirement was applied')
        public Boolean requireSameOU;
        
        @InvocableVariable(label='Ranking Explanation' description='Explanation of how results were ranked')
        public String rankingExplanation;
        
        @InvocableVariable(label='Execution Time' description='Execution time in milliseconds')
        public Long executionTime;
        
        public SMESearchResponse() {
            this.success = false;
            this.message = '';
            this.smeRecords = new List<ANAgentSMESearchService.SMEInfo>();
            this.totalCount = 0;
            this.productSummary = '';
            this.topPerformers = new List<ANAgentSMESearchService.SMEInfo>();
            this.academyMembersCount = 0;
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
                String searchType = String.isNotBlank(request.searchType) ? request.searchType : 'ALL';
                Integer maxResults = request.maxResults != null && request.maxResults > 0 ? Math.min(request.maxResults, 100) : 25;
                Boolean academyMembersOnly = request.academyMembersOnly != null ? request.academyMembersOnly : false;
                String ouName = request.ouName;
                Boolean useEnhancedSearch = request.useEnhancedSearch != null ? request.useEnhancedSearch : false;
                
                // Enhanced parameters
                String workLocationCountry = request.workLocationCountry;
                String productLevel = String.isNotBlank(request.productLevel) ? request.productLevel : 'ANY';
                Boolean requireSameOU = request.requireSameOU != null ? request.requireSameOU : true;
                Boolean includeStale = request.includeStale != null ? request.includeStale : false;

                // Perform search
                ANAgentSMESearchService.SMESearchResult searchResult;
                if (useEnhancedSearch) {
                    // Use enhanced search with all parameters
                    ANAgentSMESearchService.EnhancedSearchRequest enhancedRequest = new ANAgentSMESearchService.EnhancedSearchRequest();
                    enhancedRequest.searchTerm = request.searchTerm;
                    enhancedRequest.searchType = searchType;
                    enhancedRequest.maxResults = maxResults;
                    enhancedRequest.academyMembersOnly = academyMembersOnly;
                    enhancedRequest.ouName = ouName;
                    enhancedRequest.workLocationCountry = workLocationCountry;
                    enhancedRequest.productLevel = productLevel;
                    enhancedRequest.requireSameOU = requireSameOU;
                    enhancedRequest.includeStale = includeStale;
                    
                    searchResult = ANAgentSMESearchService.searchSMEsEnhanced(enhancedRequest);
                } else {
                    searchResult = ANAgentSMESearchService.searchSMEs(request.searchTerm, searchType, maxResults, academyMembersOnly);
                }

                // Process results
                response.success = searchResult.success;
                response.smeRecords = searchResult.records;
                response.totalCount = searchResult.totalCount;
                response.errors = searchResult.errors;
                
                // Enhanced response fields
                response.searchTerm = request.searchTerm;
                response.searchType = searchType;
                response.ouName = ouName;
                response.country = workLocationCountry;
                response.academyOnly = academyMembersOnly;
                response.requireSameOU = requireSameOU;
                response.executionTime = System.currentTimeMillis();

                // Build message
                if (searchResult.success) {
                    if (searchResult.totalCount > 0) {
                        response.message = formatSMESearchMessage(searchResult.records, request.searchTerm, searchType, academyMembersOnly);
                        
                        // Add product summary
                        if (searchResult.productCounts != null && !searchResult.productCounts.isEmpty()) {
                            List<String> productSummaries = new List<String>();
                            for (String product : searchResult.productCounts.keySet()) {
                                Integer count = searchResult.productCounts.get(product);
                                productSummaries.add(product + ' (' + count + ' SME' + (count > 1 ? 's' : '') + ')');
                            }
                            response.productSummary = 'Products covered: ' + String.join(productSummaries, ', ');
                        }
                        
                        // Calculate Academy members count
                        response.academyMembersCount = countAcademyMembers(searchResult.records);
                        
                        // Get top performers (top 5 by ACV)
                        response.topPerformers = getTopPerformers(searchResult.records, 5);
                        
                    } else {
                        response.message = 'No SMEs found matching "' + request.searchTerm + '"';
                        if (String.isNotBlank(searchType) && searchType != 'All') {
                            response.message += ' in ' + searchType + ' search';
                        }
                        if (academyMembersOnly) {
                            response.message += ' (Academy members only)';
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

            // SILENT CONVERSATION LOGGING - Add this before returning
            try {
                // Get user context
                String userId = UserInfo.getUserId(); // Current user ID
                String userName = UserInfo.getName(); // Current user name
                String userUtterance = request.searchTerm; // The search term is the user's utterance
                String agentResponse = response.message; // The agent's response message
                
                // Log the conversation silently
                ANAgentConversationLoggingService.logConversation(
                    userId, userName, userUtterance, agentResponse
                );
                
                System.debug(LoggingLevel.INFO, 'Logged conversation for ' + userName);
            } catch (Exception loggingException) {
                // Logging failures should not break the main flow
                System.debug(LoggingLevel.ERROR, 'Conversation logging failed: ' + loggingException.getMessage());
                System.debug(LoggingLevel.ERROR, 'Stack trace: ' + loggingException.getStackTraceString());
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
     * @description Count Academy members in SME list
     * @param smeList List of SME records
     * @return Integer count of Academy members
     */
    private static Integer countAcademyMembers(List<ANAgentSMESearchService.SMEInfo> smeList) {
        if (smeList == null || smeList.isEmpty()) {
            return 0;
        }
        
        Integer academyCount = 0;
        for (ANAgentSMESearchService.SMEInfo sme : smeList) {
            if (sme.isAcademyMember != null && sme.isAcademyMember) {
                academyCount++;
            }
        }
        
        return academyCount;
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
     * @param academyMembersOnly Optional Academy filter
     * @return SMESearchResponse
     */
    public static SMESearchResponse searchSMEs(String searchTerm, String searchType, Integer maxResults, Boolean academyMembersOnly) {
        SMESearchRequest request = new SMESearchRequest(searchTerm, searchType, maxResults, academyMembersOnly);
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
        return searchSMEs(searchTerm, null, null, false);
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
    
    /**
     * @description Get top SMEs for a specific product with Academy filtering
     * @param productName The product name
     * @param limitCount Number of top SMEs to return
     * @param academyMembersOnly Whether to filter for Academy members only
     * @return List<SMEInfo>
     */
    public static List<ANAgentSMESearchService.SMEInfo> getTopSMEsByProductWithAcademy(String productName, Integer limitCount, Boolean academyMembersOnly) {
        return ANAgentSMESearchService.getTopSMEsByProductWithAcademy(productName, limitCount, academyMembersOnly);
    }
    
    /**
     * @description Get top SMEs for a specific product and OU with Academy filtering
     * @param productName The product name
     * @param ouName The organizational unit name
     * @param limitCount Number of top SMEs to return
     * @param academyMembersOnly Whether to filter for Academy members only
     * @return List<SMEInfo>
     */
    public static List<ANAgentSMESearchService.SMEInfo> getTopSMEsByProductAndOU(String productName, String ouName, Integer limitCount, Boolean academyMembersOnly) {
        return ANAgentSMESearchService.getTopSMEsByProductAndOU(productName, ouName, limitCount, academyMembersOnly);
    }
    
    /**
     * @description Format SME search results with contact information
     * @param smeRecords List of SME records
     * @param searchTerm The search term used
     * @param searchType The type of search performed
     * @param academyMembersOnly Whether Academy members only filter was applied
     * @return Formatted message string
     */
    private static String formatSMESearchMessage(List<ANAgentSMESearchService.SMEInfo> smeRecords, String searchTerm, String searchType, Boolean academyMembersOnly) {
        if (smeRecords == null || smeRecords.isEmpty()) {
            return 'No SMEs found matching "' + searchTerm + '"';
        }

        String message = '🏆 Top ' + Math.min(5, smeRecords.size()) + ' ' + searchTerm + ' SMEs\n';
        message += 'Here are the top ' + Math.min(5, smeRecords.size()) + ' Subject Matter Experts for ' + searchTerm + ', ranked by their Annual Contract Value (ACV):\n\n';

        // Sort by ACV descending and take top 5
        List<ANAgentSMESearchService.SMEInfo> sortedSMEs = new List<ANAgentSMESearchService.SMEInfo>(smeRecords);
        sortedSMEs.sort(new ACVComparator());
        
        Integer count = 1;
        for (ANAgentSMESearchService.SMEInfo sme : sortedSMEs) {
            if (count > 5) break;
            
            // Add ranking emoji
            String rankEmoji = '';
            if (count == 1) rankEmoji = '🥇';
            else if (count == 2) rankEmoji = '🥈';
            else if (count == 3) rankEmoji = '🥉';
            else rankEmoji = count + '.';
            
            message += rankEmoji + ' ' + sme.aeName + '\n';
            message += 'AE Rank: #' + (sme.aeRank != null ? String.valueOf(sme.aeRank.intValue()) : 'N/A') + '\n';
            message += 'Total ACV: $' + (sme.totalACV != null ? String.valueOf(Decimal.valueOf(sme.totalACV).setScale(2)) : '0.00') + 'M\n';
            message += 'Product Expertise: ' + (String.isNotBlank(sme.productL3) ? sme.productL3 : sme.productL2) + '\n';
            message += 'Territory: ' + sme.organizationalUnit + '\n';
            message += 'Academy Member: ' + (sme.isAcademyMember ? '✅ Yes' : '❌ No') + '\n';
            message += 'Last Updated: ' + (sme.lastModifiedDate != null ? sme.lastModifiedDate.format('MMMM d, yyyy') : 'N/A') + '\n';
            
            // Add contact information
            if (String.isNotBlank(sme.email)) {
                message += '📧 Email: ' + sme.email + '\n';
            }
            if (String.isNotBlank(sme.phone)) {
                message += '📞 Phone: ' + sme.phone + '\n';
            }
            if (String.isNotBlank(sme.title)) {
                message += '💼 Title: ' + sme.title + '\n';
            }
            if (String.isNotBlank(sme.department)) {
                message += '🏢 Department: ' + sme.department + '\n';
            }
            
            message += '\n';
            count++;
        }

        // Add summary
        message += '📊 Summary\n';
        message += 'Total SMEs Found: ' + smeRecords.size() + '\n';
        
        Integer academyCount = 0;
        for (ANAgentSMESearchService.SMEInfo sme : smeRecords) {
            if (sme.isAcademyMember) academyCount++;
        }
        message += 'All Academy Members: ' + (academyCount * 100 / smeRecords.size()) + '% (' + academyCount + '/' + smeRecords.size() + ')\n';
        
        // Geographic coverage
        Set<String> territories = new Set<String>();
        for (ANAgentSMESearchService.SMEInfo sme : smeRecords) {
            if (String.isNotBlank(sme.organizationalUnit)) {
                territories.add(sme.organizationalUnit);
            }
        }
        message += 'Geographic Coverage: ' + String.join(new List<String>(territories), ', ') + '\n';
        
        // Product coverage
        Set<String> products = new Set<String>();
        for (ANAgentSMESearchService.SMEInfo sme : smeRecords) {
            if (String.isNotBlank(sme.productL3)) {
                products.add(sme.productL3);
            } else if (String.isNotBlank(sme.productL2)) {
                products.add(sme.productL2);
            }
        }
        message += 'Product Coverage: ' + String.join(new List<String>(products), ', ') + '\n';
        
        // Contact information note
        message += 'Note: Contact information is provided when available. ';
        message += 'To get specific contact details, you may need to access your internal directory or contact your administrator for additional information.\n\n';
        
        message += 'Would you like me to search for SMEs in a specific territory or with different ' + searchTerm + ' specializations?';

        return message;
    }
} 