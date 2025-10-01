/**
 * @description Apex class for targeted knowledge retrieval from explicitly identified articles
 * This class allows the agent to pull knowledge only from articles that are explicitly specified,
 * providing control over what knowledge the agent can access.
 * 
 * AGENTFORCE INTEGRATION GUIDE:
 * 
 * 1. INVOCABLE METHOD:
 *    - Method Name: retrieveKnowledge
 *    - Label: "Retrieve Targeted Knowledge"
 *    - Description: "Retrieve knowledge from explicitly identified articles only"
 * 
 * 2. INPUT PARAMETERS:
 *    - searchQuery (REQUIRED): String - The search term to find in knowledge articles
 *    - searchType (OPTIONAL): String - 'title', 'content', or 'all' (default: 'all')
 *    - maxResults (OPTIONAL): Integer - Maximum results to return (default: 5)
 * 
 * 3. OUTPUT PARAMETERS:
 *    - success: Boolean - Whether the request was processed successfully
 *    - knowledgeContent: String - Formatted knowledge article content
 *    - matchedArticles: String - Comma-separated list of matched article titles
 *    - totalResults: Integer - Number of articles returned
 *    - errorMessage: String - Error details if success = false
 * 
 * 4. SECURITY FEATURES:
 *    - Only articles in ALLOWED_KNOWLEDGE_IDS or ALLOWED_ARTICLE_TITLES are accessible
 *    - Articles must be published and latest version
 *    - All queries are filtered by allowed articles before search
 * 
 * 5. CURRENT ALLOWED ARTICLES:
 *    - AE Academy Table Documentation (ka0D7000000TQUHIA4)
 *    - Subject-Matter-Expert (SME) Finder Topic (ka0D7000000TQUCIA4)
 *    - SME Finder Documentation (ka0D7000000TQU7IAO)
 *    - Agentforce Badge Completion (ka0D7000000TQTsIAO)
 * 
 * 6. USAGE EXAMPLES:
 *    - Search for AE Academy: searchQuery = "AE Academy", searchType = "all"
 *    - Search by title only: searchQuery = "SME Finder", searchType = "title"
 *    - Limit results: searchQuery = "Data Cloud", maxResults = 3
 * 
 * 7. ERROR HANDLING:
 *    - Empty search query returns error
 *    - No matches returns success=true with "No matching articles" message
 *    - Query errors return success=false with error details
 */
public with sharing class ANAgentKnowledgeRetriever {
    
    // Configuration for allowed knowledge articles
    private static final Set<String> ALLOWED_KNOWLEDGE_IDS = new Set<String>{
        // Add the specific Knowledge Article Version IDs that the agent should have access to
        // Example: 'ka0D7000000TQUHIA4', 'ka0D7000000TQUCIA4', etc.
        'ka0D7000000TQUHIA4', // AE Academy Table Documentation
        'ka0D7000000TQUCIA4', // Subject-Matter-Expert (SME) Finder Topic
        'ka0D7000000TQU7IAO', // SME Finder Documentation
        'ka0D7000000TQTsIAO'  // Agentforce Badge Completion
    };
    
    // Alternative: Use article titles for easier management
    private static final Set<String> ALLOWED_ARTICLE_TITLES = new Set<String>{
        'AE Academy Table Documentation',
        'Subject-Matter-Expert (SME) Finder Topic',
        'SME Finder Documentation',
        'Agentforce Badge Completion'
    };
    
    /**
     * @description Input class for knowledge retrieval requests
     * 
     * AGENT CONFIGURATION DETAILS:
     * 
     * 1. searchQuery (REQUIRED):
     *    - Type: String
     *    - Description: The search term to find in knowledge articles
     *    - Examples: "AE Academy", "SME Finder", "Data Cloud"
     *    - Note: Only searches within explicitly allowed articles (see ALLOWED_KNOWLEDGE_IDS and ALLOWED_ARTICLE_TITLES)
     * 
     * 2. searchType (OPTIONAL):
     *    - Type: String
     *    - Default: 'all'
     *    - Valid Values:
     *      * 'title' - Search only in article titles
     *      * 'content' - Search in titles, questions, and answers (with post-query filtering)
     *      * 'all' - Search across all fields (same as 'content' due to SOQL limitations)
     *    - Note: Rich text fields (Answer__c, Question__c) cannot be filtered in SOQL, so content search uses Apex filtering
     * 
     * 3. maxResults (OPTIONAL):
     *    - Type: Integer
     *    - Default: 5
     *    - Description: Maximum number of articles to return
     *    - Range: 1-50 (recommended)
     *    - Note: Actual results may be fewer if fewer matching articles exist
     * 
     * SECURITY FEATURES:
     * - Only articles explicitly listed in ALLOWED_KNOWLEDGE_IDS or ALLOWED_ARTICLE_TITLES are accessible
     * - Articles must be published (PublishStatus = 'Online') and latest version (IsLatestVersion = true)
     * - All queries are filtered by allowed articles before any search is performed
     * 
     * CURRENT ALLOWED ARTICLES:
     * - AE Academy Table Documentation (ka0D7000000TQUHIA4)
     * - Subject-Matter-Expert (SME) Finder Topic (ka0D7000000TQUCIA4)
     * - SME Finder Documentation (ka0D7000000TQU7IAO)
     * - Agentforce Badge Completion (ka0D7000000TQTsIAO)
     */
    public class KnowledgeRequest {
        @InvocableVariable(required=true)
        public String searchQuery; // The search term or question from the user
        
        @InvocableVariable
        public String searchType; // 'title', 'content', 'all' - Type of search
        
        @InvocableVariable
        public Integer maxResults; // Maximum number of articles to return (1-10, default: 3)
    }
    
    /**
     * @description Output class for knowledge retrieval responses
     * 
     * AGENT RESPONSE DETAILS:
     * 
     * 1. success (Boolean):
     *    - true: Request processed successfully (even if no results found)
     *    - false: Error occurred during processing
     * 
     * 2. knowledgeContent (String):
     *    - Contains the formatted knowledge article content
     *    - Format: Each article starts with "=== [Title] ===" followed by content
     *    - Includes: Question, Answer, Description, Article ID, URL Name
     *    - HTML tags are stripped for clean text output
     *    - If no results: Contains "No matching knowledge articles found for: [query]"
     * 
     * 3. matchedArticles (String):
     *    - Comma-separated list of article titles that matched the search
     *    - Example: "AE Academy Table Documentation, SME Finder Documentation"
     *    - Empty string if no matches found
     * 
     * 4. totalResults (Integer):
     *    - Number of articles returned
     *    - 0 if no matches found
     *    - May be less than maxResults if fewer articles match
     * 
     * 5. errorMessage (String):
     *    - Contains error details if success = false
     *    - Common errors:
     *      * "Search query is required" - Empty or null search query
     *      * "Query error: [details]" - SOQL or processing errors
     *    - Empty string if success = true
     * 
     * EXAMPLE RESPONSE:
     * {
     *   "success": true,
     *   "knowledgeContent": "=== AE Academy Table Documentation ===\nAnswer: Table Documentation: AE_ACADEMY...",
     *   "matchedArticles": "AE Academy Table Documentation",
     *   "totalResults": 1,
     *   "errorMessage": ""
     * }
     */
    public class KnowledgeResponse {
        @InvocableVariable
        public String knowledgeContent; // Formatted knowledge article content with questions, answers, and metadata
        
        @InvocableVariable
        public String matchedArticles; // Comma-separated list of article titles that matched the search
        
        @InvocableVariable
        public Integer totalResults; // Number of articles found and returned
        
        @InvocableVariable
        public Boolean success; // Whether the knowledge search was successful
        
        @InvocableVariable
        public String errorMessage; // Error details if the search failed
    }
    
    /**
     * @description Main invocable method for knowledge retrieval
     * @param requests List of knowledge requests
     * @return List of knowledge responses
     */
    @InvocableMethod(label='Search Knowledge Articles' 
                     description='Search for information in approved knowledge articles. Only requires a user query - other fields have smart defaults.')
    public static List<KnowledgeResponse> retrieveKnowledge(List<KnowledgeRequest> requests) {
        List<KnowledgeResponse> responses = new List<KnowledgeResponse>();
        
        for (KnowledgeRequest request : requests) {
            try {
                KnowledgeResponse response = processKnowledgeRequest(request);
                responses.add(response);
            } catch (Exception e) {
                KnowledgeResponse errorResponse = new KnowledgeResponse();
                errorResponse.success = false;
                errorResponse.errorMessage = 'Error processing request: ' + e.getMessage();
                errorResponse.knowledgeContent = '';
                errorResponse.matchedArticles = '';
                errorResponse.totalResults = 0;
                responses.add(errorResponse);
            }
        }
        
        return responses;
    }
    
    /**
     * @description Process individual knowledge request
     * @param request The knowledge request to process
     * @return KnowledgeResponse with results
     */
    private static KnowledgeResponse processKnowledgeRequest(KnowledgeRequest request) {
        KnowledgeResponse response = new KnowledgeResponse();
        
        // Validate input
        if (String.isBlank(request.searchQuery)) {
            response.success = false;
            response.errorMessage = 'Search query is required';
            return response;
        }
        
        // Set default values - make it user-friendly
        String searchType = String.isNotBlank(request.searchType) ? request.searchType.toLowerCase() : 'all';
        Integer maxResults = request.maxResults != null ? request.maxResults : 3; // Reduced from 5 to 3 for better UX
        
        try {
            // Build query based on search type
            String soqlQuery = buildKnowledgeQuery(request.searchQuery, searchType, maxResults);
            
            // Execute query
            List<Knowledge__kav> articles = Database.query(soqlQuery);
            
            if (articles.isEmpty()) {
                response.success = true;
                response.knowledgeContent = 'No matching knowledge articles found for: "' + request.searchQuery + '"';
                response.matchedArticles = '';
                response.totalResults = 0;
                return response;
            }
            
            // Filter articles by content if needed (for rich text fields that can't be filtered in SOQL)
            List<Knowledge__kav> filteredArticles = filterArticlesByContent(articles, request.searchQuery, searchType);
            
            // Format response
            String content = formatKnowledgeContent(filteredArticles);
            String matchedTitles = formatMatchedTitles(filteredArticles);
            
            response.success = true;
            response.knowledgeContent = content;
            response.matchedArticles = matchedTitles;
            response.totalResults = articles.size();
            response.errorMessage = '';
            
        } catch (Exception e) {
            response.success = false;
            response.errorMessage = 'Query error: ' + e.getMessage();
            response.knowledgeContent = '';
            response.matchedArticles = '';
            response.totalResults = 0;
        }
        
        return response;
    }
    
    /**
     * @description Build SOQL query based on search type and allowed articles
     * @param searchQuery The search query
     * @param searchType The type of search (title, content, all)
     * @param maxResults Maximum number of results
     * @return SOQL query string
     */
    private static String buildKnowledgeQuery(String searchQuery, String searchType, Integer maxResults) {
        String escapedQuery = String.escapeSingleQuotes(searchQuery);
        
        // Base query with allowed articles filter
        String baseQuery = 'SELECT Id, Title, Answer__c, Question__c, Description__c, UrlName, RecordTypeId ' +
                          'FROM Knowledge__kav ' +
                          'WHERE IsLatestVersion = true ' +
                          'AND PublishStatus = \'Online\' ' +
                          'AND (';
        
        // Add allowed article filters
        List<String> allowedFilters = new List<String>();
        
        // Filter by allowed IDs
        if (!ALLOWED_KNOWLEDGE_IDS.isEmpty()) {
            String idFilter = 'Id IN (' + formatIdList(ALLOWED_KNOWLEDGE_IDS) + ')';
            allowedFilters.add(idFilter);
        }
        
        // Filter by allowed titles
        if (!ALLOWED_ARTICLE_TITLES.isEmpty()) {
            String titleFilter = 'Title IN (' + formatStringList(ALLOWED_ARTICLE_TITLES) + ')';
            allowedFilters.add(titleFilter);
        }
        
        baseQuery += String.join(allowedFilters, ' OR ') + ') ';
        
        // Add search conditions based on search type
        String searchCondition = '';
        switch on searchType {
            when 'title' {
                searchCondition = 'AND Title LIKE \'%' + escapedQuery + '%\' ';
            }
            when 'content' {
                // Rich text fields cannot be filtered in SOQL, so we'll filter by title and search content in Apex
                searchCondition = 'AND Title LIKE \'%' + escapedQuery + '%\' ';
            }
            when else { // 'all'
                searchCondition = 'AND Title LIKE \'%' + escapedQuery + '%\' ';
            }
        }
        
        baseQuery += searchCondition;
        baseQuery += 'ORDER BY Title ASC LIMIT ' + maxResults;
        
        return baseQuery;
    }
    
    /**
     * @description Filter articles by content in Apex (for rich text fields that can't be filtered in SOQL)
     * @param articles List of articles to filter
     * @param searchQuery The search query
     * @param searchType The type of search
     * @return Filtered list of articles
     */
    private static List<Knowledge__kav> filterArticlesByContent(List<Knowledge__kav> articles, String searchQuery, String searchType) {
        if (String.isBlank(searchQuery) || searchType == 'title') {
            return articles; // No content filtering needed
        }
        
        List<Knowledge__kav> filteredArticles = new List<Knowledge__kav>();
        String lowerQuery = searchQuery.toLowerCase();
        
        for (Knowledge__kav article : articles) {
            Boolean matches = false;
            
            // Check title
            if (String.isNotBlank(article.Title) && article.Title.toLowerCase().contains(lowerQuery)) {
                matches = true;
            }
            
            // Check answer content
            if (!matches && String.isNotBlank(article.Answer__c)) {
                String plainAnswer = stripHtml(article.Answer__c).toLowerCase();
                if (plainAnswer.contains(lowerQuery)) {
                    matches = true;
                }
            }
            
            // Check question content
            if (!matches && String.isNotBlank(article.Question__c)) {
                String plainQuestion = stripHtml(article.Question__c).toLowerCase();
                if (plainQuestion.contains(lowerQuery)) {
                    matches = true;
                }
            }
            
            if (matches) {
                filteredArticles.add(article);
            }
        }
        
        return filteredArticles;
    }
    
    /**
     * @description Format knowledge content for response
     * @param articles List of knowledge articles
     * @return Formatted content string
     */
    private static String formatKnowledgeContent(List<Knowledge__kav> articles) {
        List<String> formattedArticles = new List<String>();
        
        for (Knowledge__kav article : articles) {
            String content = '=== ' + article.Title + ' ===\n';
            
            if (String.isNotBlank(article.Question__c)) {
                content += 'Question: ' + stripHtml(article.Question__c) + '\n\n';
            }
            
            if (String.isNotBlank(article.Answer__c)) {
                content += 'Answer: ' + stripHtml(article.Answer__c) + '\n\n';
            }
            
            if (String.isNotBlank(article.Description__c)) {
                content += 'Description: ' + article.Description__c + '\n\n';
            }
            
            content += 'Article ID: ' + article.Id + '\n';
            content += 'URL Name: ' + article.UrlName + '\n';
            content += '---\n';
            
            formattedArticles.add(content);
        }
        
        return String.join(formattedArticles, '\n');
    }
    
    /**
     * @description Format matched article titles for response
     * @param articles List of knowledge articles
     * @return Formatted titles string
     */
    private static String formatMatchedTitles(List<Knowledge__kav> articles) {
        List<String> titles = new List<String>();
        for (Knowledge__kav article : articles) {
            titles.add(article.Title);
        }
        return String.join(titles, ', ');
    }
    
    /**
     * @description Format ID list for SOQL IN clause
     * @param idSet Set of IDs
     * @return Formatted ID list string
     */
    private static String formatIdList(Set<String> idSet) {
        List<String> quotedIds = new List<String>();
        for (String id : idSet) {
            quotedIds.add('\'' + id + '\'');
        }
        return String.join(quotedIds, ',');
    }
    
    /**
     * @description Format string list for SOQL IN clause
     * @param stringSet Set of strings
     * @return Formatted string list
     */
    private static String formatStringList(Set<String> stringSet) {
        List<String> quotedStrings = new List<String>();
        for (String str : stringSet) {
            quotedStrings.add('\'' + String.escapeSingleQuotes(str) + '\'');
        }
        return String.join(quotedStrings, ',');
    }
    
    /**
     * @description Strip HTML tags from text
     * @param htmlText Text containing HTML
     * @return Plain text without HTML tags
     */
    private static String stripHtml(String htmlText) {
        if (String.isBlank(htmlText)) {
            return '';
        }
        
        // Simple HTML tag removal - for production, consider using a more robust solution
        String plainText = htmlText.replaceAll('<[^>]*>', '');
        plainText = plainText.replaceAll('&nbsp;', ' ');
        plainText = plainText.replaceAll('&amp;', '&');
        plainText = plainText.replaceAll('&lt;', '<');
        plainText = plainText.replaceAll('&gt;', '>');
        plainText = plainText.replaceAll('&quot;', '"');
        plainText = plainText.replaceAll('&#39;', '\'');
        
        return plainText.trim();
    }
    
    /**
     * @description Get list of allowed knowledge article IDs (for admin use)
     * @return Set of allowed knowledge article IDs
     */
    public static Set<String> getAllowedKnowledgeIds() {
        return ALLOWED_KNOWLEDGE_IDS.clone();
    }
    
    /**
     * @description Get list of allowed article titles (for admin use)
     * @return Set of allowed article titles
     */
    public static Set<String> getAllowedArticleTitles() {
        return ALLOWED_ARTICLE_TITLES.clone();
    }
    
    /**
     * @description Add a new knowledge article ID to the allowed list (for admin use)
     * @param articleId The knowledge article ID to add
     */
    public static void addAllowedKnowledgeId(String articleId) {
        if (String.isNotBlank(articleId)) {
            ALLOWED_KNOWLEDGE_IDS.add(articleId);
        }
    }
    
    /**
     * @description Add a new article title to the allowed list (for admin use)
     * @param articleTitle The article title to add
     */
    public static void addAllowedArticleTitle(String articleTitle) {
        if (String.isNotBlank(articleTitle)) {
            ALLOWED_ARTICLE_TITLES.add(articleTitle);
        }
    }
} 
 * @description Apex class for targeted knowledge retrieval from explicitly identified articles
 * This class allows the agent to pull knowledge only from articles that are explicitly specified,
 * providing control over what knowledge the agent can access.
 * 
 * AGENTFORCE INTEGRATION GUIDE:
 * 
 * 1. INVOCABLE METHOD:
 *    - Method Name: retrieveKnowledge
 *    - Label: "Retrieve Targeted Knowledge"
 *    - Description: "Retrieve knowledge from explicitly identified articles only"
 * 
 * 2. INPUT PARAMETERS:
 *    - searchQuery (REQUIRED): String - The search term to find in knowledge articles
 *    - searchType (OPTIONAL): String - 'title', 'content', or 'all' (default: 'all')
 *    - maxResults (OPTIONAL): Integer - Maximum results to return (default: 5)
 * 
 * 3. OUTPUT PARAMETERS:
 *    - success: Boolean - Whether the request was processed successfully
 *    - knowledgeContent: String - Formatted knowledge article content
 *    - matchedArticles: String - Comma-separated list of matched article titles
 *    - totalResults: Integer - Number of articles returned
 *    - errorMessage: String - Error details if success = false
 * 
 * 4. SECURITY FEATURES:
 *    - Only articles in ALLOWED_KNOWLEDGE_IDS or ALLOWED_ARTICLE_TITLES are accessible
 *    - Articles must be published and latest version
 *    - All queries are filtered by allowed articles before search
 * 
 * 5. CURRENT ALLOWED ARTICLES:
 *    - AE Academy Table Documentation (ka0D7000000TQUHIA4)
 *    - Subject-Matter-Expert (SME) Finder Topic (ka0D7000000TQUCIA4)
 *    - SME Finder Documentation (ka0D7000000TQU7IAO)
 *    - Agentforce Badge Completion (ka0D7000000TQTsIAO)
 * 
 * 6. USAGE EXAMPLES:
 *    - Search for AE Academy: searchQuery = "AE Academy", searchType = "all"
 *    - Search by title only: searchQuery = "SME Finder", searchType = "title"
 *    - Limit results: searchQuery = "Data Cloud", maxResults = 3
 * 
 * 7. ERROR HANDLING:
 *    - Empty search query returns error
 *    - No matches returns success=true with "No matching articles" message
 *    - Query errors return success=false with error details
 */
public with sharing class ANAgentKnowledgeRetriever {
    
    // Configuration for allowed knowledge articles
    private static final Set<String> ALLOWED_KNOWLEDGE_IDS = new Set<String>{
        // Add the specific Knowledge Article Version IDs that the agent should have access to
        // Example: 'ka0D7000000TQUHIA4', 'ka0D7000000TQUCIA4', etc.
        'ka0D7000000TQUHIA4', // AE Academy Table Documentation
        'ka0D7000000TQUCIA4', // Subject-Matter-Expert (SME) Finder Topic
        'ka0D7000000TQU7IAO', // SME Finder Documentation
        'ka0D7000000TQTsIAO'  // Agentforce Badge Completion
    };
    
    // Alternative: Use article titles for easier management
    private static final Set<String> ALLOWED_ARTICLE_TITLES = new Set<String>{
        'AE Academy Table Documentation',
        'Subject-Matter-Expert (SME) Finder Topic',
        'SME Finder Documentation',
        'Agentforce Badge Completion'
    };
    
    /**
     * @description Input class for knowledge retrieval requests
     * 
     * AGENT CONFIGURATION DETAILS:
     * 
     * 1. searchQuery (REQUIRED):
     *    - Type: String
     *    - Description: The search term to find in knowledge articles
     *    - Examples: "AE Academy", "SME Finder", "Data Cloud"
     *    - Note: Only searches within explicitly allowed articles (see ALLOWED_KNOWLEDGE_IDS and ALLOWED_ARTICLE_TITLES)
     * 
     * 2. searchType (OPTIONAL):
     *    - Type: String
     *    - Default: 'all'
     *    - Valid Values:
     *      * 'title' - Search only in article titles
     *      * 'content' - Search in titles, questions, and answers (with post-query filtering)
     *      * 'all' - Search across all fields (same as 'content' due to SOQL limitations)
     *    - Note: Rich text fields (Answer__c, Question__c) cannot be filtered in SOQL, so content search uses Apex filtering
     * 
     * 3. maxResults (OPTIONAL):
     *    - Type: Integer
     *    - Default: 5
     *    - Description: Maximum number of articles to return
     *    - Range: 1-50 (recommended)
     *    - Note: Actual results may be fewer if fewer matching articles exist
     * 
     * SECURITY FEATURES:
     * - Only articles explicitly listed in ALLOWED_KNOWLEDGE_IDS or ALLOWED_ARTICLE_TITLES are accessible
     * - Articles must be published (PublishStatus = 'Online') and latest version (IsLatestVersion = true)
     * - All queries are filtered by allowed articles before any search is performed
     * 
     * CURRENT ALLOWED ARTICLES:
     * - AE Academy Table Documentation (ka0D7000000TQUHIA4)
     * - Subject-Matter-Expert (SME) Finder Topic (ka0D7000000TQUCIA4)
     * - SME Finder Documentation (ka0D7000000TQU7IAO)
     * - Agentforce Badge Completion (ka0D7000000TQTsIAO)
     */
    public class KnowledgeRequest {
        @InvocableVariable(required=true)
        public String searchQuery; // The search term or question from the user
        
        @InvocableVariable
        public String searchType; // 'title', 'content', 'all' - Type of search
        
        @InvocableVariable
        public Integer maxResults; // Maximum number of articles to return (1-10, default: 3)
    }
    
    /**
     * @description Output class for knowledge retrieval responses
     * 
     * AGENT RESPONSE DETAILS:
     * 
     * 1. success (Boolean):
     *    - true: Request processed successfully (even if no results found)
     *    - false: Error occurred during processing
     * 
     * 2. knowledgeContent (String):
     *    - Contains the formatted knowledge article content
     *    - Format: Each article starts with "=== [Title] ===" followed by content
     *    - Includes: Question, Answer, Description, Article ID, URL Name
     *    - HTML tags are stripped for clean text output
     *    - If no results: Contains "No matching knowledge articles found for: [query]"
     * 
     * 3. matchedArticles (String):
     *    - Comma-separated list of article titles that matched the search
     *    - Example: "AE Academy Table Documentation, SME Finder Documentation"
     *    - Empty string if no matches found
     * 
     * 4. totalResults (Integer):
     *    - Number of articles returned
     *    - 0 if no matches found
     *    - May be less than maxResults if fewer articles match
     * 
     * 5. errorMessage (String):
     *    - Contains error details if success = false
     *    - Common errors:
     *      * "Search query is required" - Empty or null search query
     *      * "Query error: [details]" - SOQL or processing errors
     *    - Empty string if success = true
     * 
     * EXAMPLE RESPONSE:
     * {
     *   "success": true,
     *   "knowledgeContent": "=== AE Academy Table Documentation ===\nAnswer: Table Documentation: AE_ACADEMY...",
     *   "matchedArticles": "AE Academy Table Documentation",
     *   "totalResults": 1,
     *   "errorMessage": ""
     * }
     */
    public class KnowledgeResponse {
        @InvocableVariable
        public String knowledgeContent; // Formatted knowledge article content with questions, answers, and metadata
        
        @InvocableVariable
        public String matchedArticles; // Comma-separated list of article titles that matched the search
        
        @InvocableVariable
        public Integer totalResults; // Number of articles found and returned
        
        @InvocableVariable
        public Boolean success; // Whether the knowledge search was successful
        
        @InvocableVariable
        public String errorMessage; // Error details if the search failed
    }
    
    /**
     * @description Main invocable method for knowledge retrieval
     * @param requests List of knowledge requests
     * @return List of knowledge responses
     */
    @InvocableMethod(label='Search Knowledge Articles' 
                     description='Search for information in approved knowledge articles. Only requires a user query - other fields have smart defaults.')
    public static List<KnowledgeResponse> retrieveKnowledge(List<KnowledgeRequest> requests) {
        List<KnowledgeResponse> responses = new List<KnowledgeResponse>();
        
        for (KnowledgeRequest request : requests) {
            try {
                KnowledgeResponse response = processKnowledgeRequest(request);
                responses.add(response);
            } catch (Exception e) {
                KnowledgeResponse errorResponse = new KnowledgeResponse();
                errorResponse.success = false;
                errorResponse.errorMessage = 'Error processing request: ' + e.getMessage();
                errorResponse.knowledgeContent = '';
                errorResponse.matchedArticles = '';
                errorResponse.totalResults = 0;
                responses.add(errorResponse);
            }
        }
        
        return responses;
    }
    
    /**
     * @description Process individual knowledge request
     * @param request The knowledge request to process
     * @return KnowledgeResponse with results
     */
    private static KnowledgeResponse processKnowledgeRequest(KnowledgeRequest request) {
        KnowledgeResponse response = new KnowledgeResponse();
        
        // Validate input
        if (String.isBlank(request.searchQuery)) {
            response.success = false;
            response.errorMessage = 'Search query is required';
            return response;
        }
        
        // Set default values - make it user-friendly
        String searchType = String.isNotBlank(request.searchType) ? request.searchType.toLowerCase() : 'all';
        Integer maxResults = request.maxResults != null ? request.maxResults : 3; // Reduced from 5 to 3 for better UX
        
        try {
            // Build query based on search type
            String soqlQuery = buildKnowledgeQuery(request.searchQuery, searchType, maxResults);
            
            // Execute query
            List<Knowledge__kav> articles = Database.query(soqlQuery);
            
            if (articles.isEmpty()) {
                response.success = true;
                response.knowledgeContent = 'No matching knowledge articles found for: "' + request.searchQuery + '"';
                response.matchedArticles = '';
                response.totalResults = 0;
                return response;
            }
            
            // Filter articles by content if needed (for rich text fields that can't be filtered in SOQL)
            List<Knowledge__kav> filteredArticles = filterArticlesByContent(articles, request.searchQuery, searchType);
            
            // Format response
            String content = formatKnowledgeContent(filteredArticles);
            String matchedTitles = formatMatchedTitles(filteredArticles);
            
            response.success = true;
            response.knowledgeContent = content;
            response.matchedArticles = matchedTitles;
            response.totalResults = articles.size();
            response.errorMessage = '';
            
        } catch (Exception e) {
            response.success = false;
            response.errorMessage = 'Query error: ' + e.getMessage();
            response.knowledgeContent = '';
            response.matchedArticles = '';
            response.totalResults = 0;
        }
        
        return response;
    }
    
    /**
     * @description Build SOQL query based on search type and allowed articles
     * @param searchQuery The search query
     * @param searchType The type of search (title, content, all)
     * @param maxResults Maximum number of results
     * @return SOQL query string
     */
    private static String buildKnowledgeQuery(String searchQuery, String searchType, Integer maxResults) {
        String escapedQuery = String.escapeSingleQuotes(searchQuery);
        
        // Base query with allowed articles filter
        String baseQuery = 'SELECT Id, Title, Answer__c, Question__c, Description__c, UrlName, RecordTypeId ' +
                          'FROM Knowledge__kav ' +
                          'WHERE IsLatestVersion = true ' +
                          'AND PublishStatus = \'Online\' ' +
                          'AND (';
        
        // Add allowed article filters
        List<String> allowedFilters = new List<String>();
        
        // Filter by allowed IDs
        if (!ALLOWED_KNOWLEDGE_IDS.isEmpty()) {
            String idFilter = 'Id IN (' + formatIdList(ALLOWED_KNOWLEDGE_IDS) + ')';
            allowedFilters.add(idFilter);
        }
        
        // Filter by allowed titles
        if (!ALLOWED_ARTICLE_TITLES.isEmpty()) {
            String titleFilter = 'Title IN (' + formatStringList(ALLOWED_ARTICLE_TITLES) + ')';
            allowedFilters.add(titleFilter);
        }
        
        baseQuery += String.join(allowedFilters, ' OR ') + ') ';
        
        // Add search conditions based on search type
        String searchCondition = '';
        switch on searchType {
            when 'title' {
                searchCondition = 'AND Title LIKE \'%' + escapedQuery + '%\' ';
            }
            when 'content' {
                // Rich text fields cannot be filtered in SOQL, so we'll filter by title and search content in Apex
                searchCondition = 'AND Title LIKE \'%' + escapedQuery + '%\' ';
            }
            when else { // 'all'
                searchCondition = 'AND Title LIKE \'%' + escapedQuery + '%\' ';
            }
        }
        
        baseQuery += searchCondition;
        baseQuery += 'ORDER BY Title ASC LIMIT ' + maxResults;
        
        return baseQuery;
    }
    
    /**
     * @description Filter articles by content in Apex (for rich text fields that can't be filtered in SOQL)
     * @param articles List of articles to filter
     * @param searchQuery The search query
     * @param searchType The type of search
     * @return Filtered list of articles
     */
    private static List<Knowledge__kav> filterArticlesByContent(List<Knowledge__kav> articles, String searchQuery, String searchType) {
        if (String.isBlank(searchQuery) || searchType == 'title') {
            return articles; // No content filtering needed
        }
        
        List<Knowledge__kav> filteredArticles = new List<Knowledge__kav>();
        String lowerQuery = searchQuery.toLowerCase();
        
        for (Knowledge__kav article : articles) {
            Boolean matches = false;
            
            // Check title
            if (String.isNotBlank(article.Title) && article.Title.toLowerCase().contains(lowerQuery)) {
                matches = true;
            }
            
            // Check answer content
            if (!matches && String.isNotBlank(article.Answer__c)) {
                String plainAnswer = stripHtml(article.Answer__c).toLowerCase();
                if (plainAnswer.contains(lowerQuery)) {
                    matches = true;
                }
            }
            
            // Check question content
            if (!matches && String.isNotBlank(article.Question__c)) {
                String plainQuestion = stripHtml(article.Question__c).toLowerCase();
                if (plainQuestion.contains(lowerQuery)) {
                    matches = true;
                }
            }
            
            if (matches) {
                filteredArticles.add(article);
            }
        }
        
        return filteredArticles;
    }
    
    /**
     * @description Format knowledge content for response
     * @param articles List of knowledge articles
     * @return Formatted content string
     */
    private static String formatKnowledgeContent(List<Knowledge__kav> articles) {
        List<String> formattedArticles = new List<String>();
        
        for (Knowledge__kav article : articles) {
            String content = '=== ' + article.Title + ' ===\n';
            
            if (String.isNotBlank(article.Question__c)) {
                content += 'Question: ' + stripHtml(article.Question__c) + '\n\n';
            }
            
            if (String.isNotBlank(article.Answer__c)) {
                content += 'Answer: ' + stripHtml(article.Answer__c) + '\n\n';
            }
            
            if (String.isNotBlank(article.Description__c)) {
                content += 'Description: ' + article.Description__c + '\n\n';
            }
            
            content += 'Article ID: ' + article.Id + '\n';
            content += 'URL Name: ' + article.UrlName + '\n';
            content += '---\n';
            
            formattedArticles.add(content);
        }
        
        return String.join(formattedArticles, '\n');
    }
    
    /**
     * @description Format matched article titles for response
     * @param articles List of knowledge articles
     * @return Formatted titles string
     */
    private static String formatMatchedTitles(List<Knowledge__kav> articles) {
        List<String> titles = new List<String>();
        for (Knowledge__kav article : articles) {
            titles.add(article.Title);
        }
        return String.join(titles, ', ');
    }
    
    /**
     * @description Format ID list for SOQL IN clause
     * @param idSet Set of IDs
     * @return Formatted ID list string
     */
    private static String formatIdList(Set<String> idSet) {
        List<String> quotedIds = new List<String>();
        for (String id : idSet) {
            quotedIds.add('\'' + id + '\'');
        }
        return String.join(quotedIds, ',');
    }
    
    /**
     * @description Format string list for SOQL IN clause
     * @param stringSet Set of strings
     * @return Formatted string list
     */
    private static String formatStringList(Set<String> stringSet) {
        List<String> quotedStrings = new List<String>();
        for (String str : stringSet) {
            quotedStrings.add('\'' + String.escapeSingleQuotes(str) + '\'');
        }
        return String.join(quotedStrings, ',');
    }
    
    /**
     * @description Strip HTML tags from text
     * @param htmlText Text containing HTML
     * @return Plain text without HTML tags
     */
    private static String stripHtml(String htmlText) {
        if (String.isBlank(htmlText)) {
            return '';
        }
        
        // Simple HTML tag removal - for production, consider using a more robust solution
        String plainText = htmlText.replaceAll('<[^>]*>', '');
        plainText = plainText.replaceAll('&nbsp;', ' ');
        plainText = plainText.replaceAll('&amp;', '&');
        plainText = plainText.replaceAll('&lt;', '<');
        plainText = plainText.replaceAll('&gt;', '>');
        plainText = plainText.replaceAll('&quot;', '"');
        plainText = plainText.replaceAll('&#39;', '\'');
        
        return plainText.trim();
    }
    
    /**
     * @description Get list of allowed knowledge article IDs (for admin use)
     * @return Set of allowed knowledge article IDs
     */
    public static Set<String> getAllowedKnowledgeIds() {
        return ALLOWED_KNOWLEDGE_IDS.clone();
    }
    
    /**
     * @description Get list of allowed article titles (for admin use)
     * @return Set of allowed article titles
     */
    public static Set<String> getAllowedArticleTitles() {
        return ALLOWED_ARTICLE_TITLES.clone();
    }
    
    /**
     * @description Add a new knowledge article ID to the allowed list (for admin use)
     * @param articleId The knowledge article ID to add
     */
    public static void addAllowedKnowledgeId(String articleId) {
        if (String.isNotBlank(articleId)) {
            ALLOWED_KNOWLEDGE_IDS.add(articleId);
        }
    }
    
    /**
     * @description Add a new article title to the allowed list (for admin use)
     * @param articleTitle The article title to add
     */
    public static void addAllowedArticleTitle(String articleTitle) {
        if (String.isNotBlank(articleTitle)) {
            ALLOWED_ARTICLE_TITLES.add(articleTitle);
        }
    }
} 