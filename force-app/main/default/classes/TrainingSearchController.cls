global without sharing class TrainingSearchController {

    private static final Integer PAGE_SIZE = 5;
    private static final String EVENT_RECORD_TYPE_DEVELOPER_NAME = 'Event';
    private static final String AI_APPLICATION_NAME = 'PromptBuilderPreview';

    // --- WRAPPER CLASSES (Input/Output for findTraining Invocable Method) ---
    public class TrainingSearchRequest {
        @InvocableVariable(label='User Query Text')
        public String userInput;

        @InvocableVariable(label='Page Number' description='Current page number for pagination, defaults to 1.')
        public Integer pageNumber = 1;

        @InvocableVariable(label='Search Context (JSON)' description='Internal context for pagination. Pass back the value from the previous response.')
        public String searchContext;
    }

    public class TrainingSearchResponse {
        @InvocableVariable(label='Training Results')
        public List<TrainingSearchResult> trainingResults;

        @InvocableVariable(label='Has More Results' description='True if there are more results on subsequent pages.')
        public Boolean hasMoreResults = false;

        @InvocableVariable(label='Search Context (JSON)' description='Context to pass to the next request for pagination.')
        public String searchContext;

        @InvocableVariable(label='Metadata Response Text' description='Used for responses to metadata queries (e.g., list of products).')
        public String metadataResponseText;

        @InvocableVariable(label='Total Results Found' description='Total number of matching records found across all pages.')
        public Integer totalResultsFound = 0;
    }
    
    // --- INTERNAL HELPER CLASSES ---
    public class TrainingSearchException extends Exception {}

    public class TrainingSearchResultComparator implements Comparator<TrainingSearchResult> {
        public Integer compare(TrainingSearchResult a, TrainingSearchResult b) {
            if (a.name == null && b.name == null) return 0;
            if (a.name == null) return -1;
            if (b.name == null) return 1;
            return a.name.compareTo(b.name);
        }
    }
    
    // This class is used to model the expected JSON structure from the LLM.
    private class PromptResponse {
        @AuraEnabled public String SEARCH_TYPE;
        @AuraEnabled public String KEYWORDS;
    }
    
    private class SearchVocabulary {
        Set<String> products = new Set<String>();
        Set<String> industries = new Set<String>();
        Set<String> roles = new Set<String>();
        Set<String> primaryCategories = new Set<String>();
        Set<String> productsLower = new Set<String>();
        Set<String> industriesLower = new Set<String>();
        Set<String> rolesLower = new Set<String>();
        Set<String> primaryCategoriesLower = new Set<String>();
    }

    // --- INVOCABLE METHOD: Find Training ---
    @InvocableMethod(label='Find Training (LLM Enhanced)' description='Searches training catalog using natural language or provides metadata about available filters.')
    public static List<TrainingSearchResponse> findTraining(List<TrainingSearchRequest> requests) {
        TrainingSearchRequest request = requests[0];
        TrainingSearchResponse response = new TrainingSearchResponse();
        Map<Id, String> allMatchingReasonsAndIds; 

        System.debug(LoggingLevel.INFO, 'TrainingSearchController --- INPUTS --- UserInput: ' + request.userInput + 
                     ', PageNumber: ' + request.pageNumber + 
                     ', SearchContext IS BLANK: ' + String.isBlank(request.searchContext));

        try {
            // If searchContext is present, userInput is not strictly required (it's a pagination call)
            // If searchContext is blank (new search), then userInput is required.
            if (String.isBlank(request.searchContext) && String.isBlank(request.userInput)) {
                response.trainingResults = new List<TrainingSearchResult>();
                response.metadataResponseText = 'Please provide a search query to find training.';
                return new List<TrainingSearchResponse>{ response };
            }
            
            PromptResponse parsedPrompt = null;
            // Only call LLM if it's a new search (no searchContext) AND userInput is provided
            if (String.isBlank(request.searchContext) && String.isNotBlank(request.userInput)) { 
                parsedPrompt = getParsedPromptResponse(request.userInput);
                System.debug(LoggingLevel.INFO, 'Parsed Prompt Response from LLM Call: ' + JSON.serialize(parsedPrompt));
            } else if (String.isNotBlank(request.searchContext)) {
                 System.debug(LoggingLevel.INFO, 'Using existing searchContext. Skipping LLM call for intent parsing for pagination/contextual call.');
            }

            // Handle metadata query directly if LLM identified it for a new search
            if (parsedPrompt != null && 'METADATA_QUERY'.equalsIgnoreCase(parsedPrompt.SEARCH_TYPE)) {
                response.metadataResponseText = handleMetadataQuery(parsedPrompt.KEYWORDS);
                response.trainingResults = new List<TrainingSearchResult>(); 
                response.hasMoreResults = false; 
                return new List<TrainingSearchResponse>{ response };
            }

            if (String.isBlank(request.searchContext)) { // This is a New search
                allMatchingReasonsAndIds = findAllMatchingTrainingIds(parsedPrompt, request.userInput);
                
                if (allMatchingReasonsAndIds != null && !allMatchingReasonsAndIds.isEmpty()) {
                    // Create the new compact searchContext
                    Map<String, String> contextMap = new Map<String, String>{
                        'type' => 'newSearchContext', 
                        'llmSearchType' => parsedPrompt?.SEARCH_TYPE,
                        'llmKeywords' => parsedPrompt?.KEYWORDS,
                        'originalUserInput' => request.userInput
                    };
                    response.searchContext = JSON.serialize(contextMap);
                    System.debug(LoggingLevel.INFO, 'New search. Created searchContext: ' + response.searchContext);
                } else {
                    response.searchContext = null; 
                     System.debug(LoggingLevel.INFO, 'New search. No matching IDs found, searchContext is null.');
                }

            } else { // This is a Pagination call (existing searchContext is present)
                System.debug(LoggingLevel.INFO, 'Pagination call. Deserializing searchContext: ' + request.searchContext);
                Map<String, Object> deserializedContext = (Map<String, Object>)JSON.deserializeUntyped(request.searchContext);
                
                if (deserializedContext.containsKey('type') && 'newSearchContext'.equals(deserializedContext.get('type'))) {
                    System.debug(LoggingLevel.INFO, 'Using newSearchContext for pagination.');
                    PromptResponse promptFromContext = new PromptResponse();
                    promptFromContext.SEARCH_TYPE = (String)deserializedContext.get('llmSearchType');
                    promptFromContext.KEYWORDS = (String)deserializedContext.get('llmKeywords');
                    String originalInputFromContext = (String)deserializedContext.get('originalUserInput');

                    // Re-generate allMatchingReasonsAndIds using the parameters from the context
                    allMatchingReasonsAndIds = findAllMatchingTrainingIds(promptFromContext, originalInputFromContext);
                    
                    // Pass the same compact context string back for the next "show more" page
                    response.searchContext = request.searchContext; 
                } else {
                    // Fallback for old context format (Map<Id, String>) or unrecognized format
                    System.debug(LoggingLevel.WARN, 'Attempting to use old searchContext format or unrecognized format for pagination.');
                    try {
                        allMatchingReasonsAndIds = (Map<Id, String>) JSON.deserialize(request.searchContext, Map<Id, String>.class);
                        response.searchContext = request.searchContext; // Pass old context along if it was old format
                    } catch (System.JSONException e) {
                        System.debug(LoggingLevel.ERROR, 'Failed to deserialize searchContext. Invalid format: ' + request.searchContext + '. Error: ' + e.getMessage());
                        allMatchingReasonsAndIds = new Map<Id, String>(); // Ensure it's initialized
                        response.searchContext = null; // Clear bad context
                        response.metadataResponseText = 'There was an issue with your previous search context. Please try a new search.';
                        // Set empty results as context is invalid
                        response.trainingResults = new List<TrainingSearchResult>();
                        response.hasMoreResults = false;
                        response.totalResultsFound = 0;
                        return new List<TrainingSearchResponse>{ response };
                    }
                }
            }
            
            // Common logic for processing results after allMatchingReasonsAndIds is determined
            if (allMatchingReasonsAndIds == null || allMatchingReasonsAndIds.isEmpty()) {
                response.trainingResults = new List<TrainingSearchResult>();
                response.hasMoreResults = false;
                response.totalResultsFound = 0;
                // Provide a message if it was a new search that yielded no results and wasn't a metadata query
                // For pagination, if it yields no results here, it means the re-query also found nothing (should be rare if context was valid)
                // or the original context was bad and led to an empty map earlier.
                if (String.isBlank(request.searchContext) && (parsedPrompt == null || !'METADATA_QUERY'.equalsIgnoreCase(parsedPrompt.SEARCH_TYPE))) {
                    response.metadataResponseText = 'No training found matching your criteria. Try a broader search or ask about available Products or Industries.';
                } else if (parsedPrompt != null && 'METADATA_QUERY'.equalsIgnoreCase(parsedPrompt.SEARCH_TYPE) && String.isBlank(response.metadataResponseText)) {
                     // This case should have been handled earlier, but as a fallback:
                     response.metadataResponseText = 'Could not retrieve the requested metadata. Please try again or check system configuration.';
                }
                // If metadataResponseText is already set (e.g. from bad context during pagination), don't overwrite it
                return new List<TrainingSearchResponse>{ response };
            }

            response.totalResultsFound = allMatchingReasonsAndIds.size();
            queryAndPaginateDetails(allMatchingReasonsAndIds, request.pageNumber, response);
            return new List<TrainingSearchResponse>{ response };

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in findTraining: ' + e.getMessage() + '\nStackTrace: ' + e.getStackTraceString());
            // For Flow, it's often better to return a controlled error message than to let the exception propagate unhandled
            TrainingSearchResponse errorResponse = new TrainingSearchResponse();
            errorResponse.trainingResults = new List<TrainingSearchResult>();
            errorResponse.metadataResponseText = 'An unexpected error occurred while searching for training: ' + e.getMessage();
            return new List<TrainingSearchResponse>{ errorResponse };
            // Or, if you have a specific exception type for critical errors that Flow should handle differently:
            // throw new TrainingSearchException('An error occurred in the Training Search: ' + e.getMessage());
        }
    }
    
    // --- All private helper methods ---
    private static String handleMetadataQuery(String metadataKeywords) {
        String keywordsLower = String.isNotBlank(metadataKeywords) ? metadataKeywords.toLowerCase().trim() : '';
        SearchVocabulary vocab = getSearchVocabulary(); 

        if (keywordsLower.contains('primary categor')) {
            return !vocab.primaryCategories.isEmpty() ? 'Available Primary Categories include: ' + String.join(new List<String>(vocab.primaryCategories), ', ') + '.' : 'I could not retrieve Primary Categories at this time.';
        } else if (keywordsLower.contains('product')) {
            return !vocab.products.isEmpty() ? 'Available training products include: ' + String.join(new List<String>(vocab.products), ', ') + '.' : 'I could not retrieve searchable products at this time.';
        } else if (keywordsLower.contains('industr')) { 
            return !vocab.industries.isEmpty() ? 'Available training industries include: ' + String.join(new List<String>(vocab.industries), ', ') + '.' : 'I could not retrieve searchable industries at this time.';
        } else if (keywordsLower.contains('role')) {
            return !vocab.roles.isEmpty() ? 'Available training roles include: ' + String.join(new List<String>(vocab.roles), ', ') + '.' : 'I could not retrieve searchable roles at this time.';
        } else if (keywordsLower.contains('system capabilities') || keywordsLower.contains('what data do you have') || keywordsLower.contains('what can i search')) {
            return 'I can help you find training by its name, description, or by tags like Product, Industry, Role, or Primary Category. You can also ask me about available filter options for these tags.';
        }
        System.debug(LoggingLevel.WARN, 'Metadata query received with unrecognized keywords: ' + metadataKeywords);
        return 'I can provide information about available training Products, Industries, Roles, or Primary Categories. What specific information are you looking for?';
    }

    private static Map<Id, String> findAllMatchingTrainingIds(PromptResponse parsedResponse, String originalUserInput) {
        Map<Id, String> matchingReasonsAndIds = new Map<Id, String>();
        String keywordsFromPrompt = null;
        String searchTypeFromPrompt = null;

        if(parsedResponse != null){
            keywordsFromPrompt = parsedResponse.KEYWORDS;
            searchTypeFromPrompt = parsedResponse.SEARCH_TYPE;
        }

        // Default to general keyword search if LLM provides no specific search type,
        // unless it's an ALL_TRAINING intent (which might come via keywords or search_type)
        if (String.isBlank(searchTypeFromPrompt) && (keywordsFromPrompt == null || !'ALL_TRAINING'.equalsIgnoreCase(keywordsFromPrompt))) {
             searchTypeFromPrompt = 'GENERAL_KEYWORD_SEARCH'; 
        }
        // If LLM returns no keywords, but it's not an ALL_TRAINING intent, use original user input for keyword search
        if (String.isBlank(keywordsFromPrompt) && !'ALL_TRAINING'.equalsIgnoreCase(searchTypeFromPrompt)) {
            keywordsFromPrompt = originalUserInput; 
        }

        if ('ALL_TRAINING'.equalsIgnoreCase(searchTypeFromPrompt) || 'ALL_TRAINING'.equalsIgnoreCase(keywordsFromPrompt)) {
            Id eventRecordTypeId = getEventAssetRecordTypeId();
            String reason = 'Showing all available training';
            for (Curriculum__c c : [SELECT Id FROM Curriculum__c WHERE Status__c = 'Active']) matchingReasonsAndIds.put(c.Id, reason);
            for (Course__c c : [SELECT Id FROM Course__c WHERE Status__c = 'Active']) matchingReasonsAndIds.put(c.Id, reason);
            if (eventRecordTypeId != null) {
                for (Asset__c a : [SELECT Id FROM Asset__c WHERE RecordTypeId = :eventRecordTypeId AND Status__c = 'Active']) matchingReasonsAndIds.put(a.Id, reason);
            }
            return matchingReasonsAndIds;
        }
        
        // Use keywords from LLM if available, otherwise fallback to original user input
        String effectiveKeywords = String.isNotBlank(keywordsFromPrompt) ? keywordsFromPrompt : originalUserInput;
        if (String.isBlank(effectiveKeywords)) {
            System.debug(LoggingLevel.WARN, 'findAllMatchingTrainingIds: Effective keywords are blank. OriginalInput: ' + originalUserInput + ', KeywordsFromPrompt: ' + keywordsFromPrompt);
            return matchingReasonsAndIds; // Return empty if no keywords to search on
        }

        String normalizedEffectiveKeywords = effectiveKeywords.trim().toLowerCase();
        SearchVocabulary vocab = getSearchVocabulary();
        List<String> searchTerms = new List<String>();
        if (String.isNotBlank(effectiveKeywords)) {
            for (String orPart : effectiveKeywords.split('(?i) or ')) { 
                for (String commaPart : orPart.split(',')) {
                    String trimmedPart = commaPart.trim();
                    if (String.isNotBlank(trimmedPart)) {
                        searchTerms.add(trimmedPart);
                    }
                }
            }
        }
        if (searchTerms.isEmpty() && String.isNotBlank(effectiveKeywords)) { // Ensure single term is also added
             searchTerms.add(effectiveKeywords.trim());
        }
        if (searchTerms.isEmpty()) return matchingReasonsAndIds; // Should not happen if effectiveKeywords is not blank

        // Handle specific search types identified by LLM first
        if ('PRODUCT_SEARCH'.equalsIgnoreCase(searchTypeFromPrompt)) {
            String matchedProduct = findBestMatch(normalizedEffectiveKeywords, vocab.productsLower, vocab.products);
            if (String.isNotBlank(matchedProduct)) {
                findTrainingByTagField('Product__r.Name', matchedProduct, 'Matched Product Tag: "' + matchedProduct + '"', matchingReasonsAndIds);
            }
        } else if ('PRIMARY_CATEGORY_SEARCH'.equalsIgnoreCase(searchTypeFromPrompt)) {
            String matchedPrimaryCategory = findBestMatch(normalizedEffectiveKeywords, vocab.primaryCategoriesLower, vocab.primaryCategories);
            if (String.isNotBlank(matchedPrimaryCategory)) {
                findTrainingByPrimaryCategory(matchedPrimaryCategory, 'Matched Primary Category Tag: "' + matchedPrimaryCategory + '"', matchingReasonsAndIds);
            }
        } else if ('INDUSTRY_SEARCH'.equalsIgnoreCase(searchTypeFromPrompt)) { 
            String matchedIndustry = findBestMatch(normalizedEffectiveKeywords, vocab.industriesLower, vocab.industries);
            if (String.isNotBlank(matchedIndustry)) {
                findTrainingByTagField('Industry__r.Name', matchedIndustry, 'Matched Industry Tag: "' + matchedIndustry + '"', matchingReasonsAndIds);
            }
        } else if ('ROLE_SEARCH'.equalsIgnoreCase(searchTypeFromPrompt)) { 
            String matchedRole = findBestMatch(normalizedEffectiveKeywords, vocab.rolesLower, vocab.roles);
            if (String.isNotBlank(matchedRole)) {
                findTrainingByTagField('Role__r.Name', matchedRole, 'Matched Role Tag: "' + matchedRole + '"', matchingReasonsAndIds);
            }
        }

        // Iterate through individual search terms (parsed from "OR" / "," in keywords)
        // This allows for combined searches like "Salesforce and Marketing Cloud" or "Admin or Developer"
        for (String term : searchTerms) {
            String normalizedTerm = term.toLowerCase();

            // Check for tags within each term, unless it was the primary search type and already handled
            if (!'PRODUCT_SEARCH'.equalsIgnoreCase(searchTypeFromPrompt) || !normalizedTerm.equals(normalizedEffectiveKeywords)) {
                String termAsProduct = findBestMatch(normalizedTerm, vocab.productsLower, vocab.products);
                if (String.isNotBlank(termAsProduct)) {
                    findTrainingByTagField('Product__r.Name', termAsProduct, 'Matched Product Tag: "' + termAsProduct + '" from term "' + term + '"', matchingReasonsAndIds);
                }
            }
             if (!'PRIMARY_CATEGORY_SEARCH'.equalsIgnoreCase(searchTypeFromPrompt) || !normalizedTerm.equals(normalizedEffectiveKeywords)) {
                String termAsPrimaryCategory = findBestMatch(normalizedTerm, vocab.primaryCategoriesLower, vocab.primaryCategories);
                if (String.isNotBlank(termAsPrimaryCategory)) {
                    findTrainingByPrimaryCategory(termAsPrimaryCategory, 'Matched Primary Category Tag: "' + termAsPrimaryCategory + '" from term "' + term + '"', matchingReasonsAndIds);
                }
            }
            if (!'INDUSTRY_SEARCH'.equalsIgnoreCase(searchTypeFromPrompt) || !normalizedTerm.equals(normalizedEffectiveKeywords)) {
                String termAsIndustry = findBestMatch(normalizedTerm, vocab.industriesLower, vocab.industries);
                if (String.isNotBlank(termAsIndustry)) {
                    findTrainingByTagField('Industry__r.Name', termAsIndustry, 'Matched Industry Tag: "' + termAsIndustry + '" from term "' + term + '"', matchingReasonsAndIds);
                }
            }
            if (!'ROLE_SEARCH'.equalsIgnoreCase(searchTypeFromPrompt) || !normalizedTerm.equals(normalizedEffectiveKeywords)) {
                String termAsRole = findBestMatch(normalizedTerm, vocab.rolesLower, vocab.roles);
                if (String.isNotBlank(termAsRole)) {
                    findTrainingByTagField('Role__r.Name', termAsRole, 'Matched Role Tag: "' + termAsRole + '" from term "' + term + '"', matchingReasonsAndIds);
                }
            }
            
            // Always perform keyword match for the term in Name or Description
            addKeywordMatchForTerm(term, 'Matched keyword "' + term + '" in Name or Description', matchingReasonsAndIds);
        }
        
        return matchingReasonsAndIds;
    }
    
    private static void findTrainingByTagField(String fieldApiNameOnTag, String value, String reason, Map<Id, String> matchingReasonsAndIds) {
        Id eventRecordTypeId = getEventAssetRecordTypeId();
        String assetRecordTypeFilterClause = '';
        // Adjust filter based on whether the tag field is directly on Asset or via Content_Tag's Asset lookup
        if (eventRecordTypeId != null) {
             if (fieldApiNameOnTag.toLowerCase().startsWith('asset__r.')) { // Direct Asset relation on Content_Tag
                 assetRecordTypeFilterClause = ' AND Asset__r.RecordTypeId = \'' + String.escapeSingleQuotes(eventRecordTypeId) + '\' ';
             } else if (fieldApiNameOnTag.toLowerCase().startsWith('content_tags__r.asset__r.')) { // Should not happen with current fields, but for robustness
                 assetRecordTypeFilterClause = ' AND Asset__r.RecordTypeId = \'' + String.escapeSingleQuotes(eventRecordTypeId) + '\' ';
             }
             // For Product__r.Name, Industry__r.Name, Role__r.Name, the tag is on Content_Tag__c, which then links to Asset__c
             // So, if Asset__c is involved, we need to ensure the Asset itself is of the Event type.
             else if (fieldApiNameOnTag.equalsIgnoreCase('Product__r.Name') || 
                      fieldApiNameOnTag.equalsIgnoreCase('Industry__r.Name') ||
                      fieldApiNameOnTag.equalsIgnoreCase('Role__r.Name')) {
                 // The SOQL below handles Asset__c != null, so we add the RecordTypeId filter for those cases.
                 // The filter will be applied within the OR condition for Assets.
             }
        }
        
        String soql = 'SELECT Curriculum__c, Course__c, Asset__c FROM Content_Tag__c WHERE ' +
                      fieldApiNameOnTag + ' = :value AND (' +
                      '(Curriculum__c != null AND Curriculum__r.Status__c = \'Active\') OR ' +
                      '(Course__c != null AND Course__r.Status__c = \'Active\') OR ' +
                      '(Asset__c != null AND Asset__r.Status__c = \'Active\'' + 
                       (eventRecordTypeId != null ? ' AND Asset__r.RecordTypeId = \'' + String.escapeSingleQuotes(eventRecordTypeId) + '\'' : '') + 
                       '))';
        try {
            for (Content_Tag__c tag : Database.query(soql)) {
                if (tag.Curriculum__c != null && !matchingReasonsAndIds.containsKey(tag.Curriculum__c)) matchingReasonsAndIds.put(tag.Curriculum__c, reason);
                if (tag.Course__c != null && !matchingReasonsAndIds.containsKey(tag.Course__c)) matchingReasonsAndIds.put(tag.Course__c, reason);
                if (tag.Asset__c != null && !matchingReasonsAndIds.containsKey(tag.Asset__c)) matchingReasonsAndIds.put(tag.Asset__c, reason);
            }
        } catch (Exception e) { 
            System.debug(LoggingLevel.ERROR, 'SOQL Error in findTrainingByTagField for ' + fieldApiNameOnTag + '=' + value + ': ' + e.getMessage() + '. SOQL: ' + soql); 
        }
    }

    private static void findTrainingByPrimaryCategory(String categoryValue, String reason, Map<Id, String> matchingReasonsAndIds) {
        Id eventRecordTypeId = getEventAssetRecordTypeId();
        String assetRecordTypeFilter = (eventRecordTypeId != null) ? ' AND Asset__r.RecordTypeId = \'' + String.escapeSingleQuotes(eventRecordTypeId) + '\'' : '';
        
        String soql = 'SELECT Curriculum__c, Course__c, Asset__c FROM Content_Tag__c WHERE ' +
                      'Primary_Category__c = :categoryValue AND (' + 
                      '(Curriculum__c != null AND Curriculum__r.Status__c = \'Active\') OR ' +
                      '(Course__c != null AND Course__r.Status__c = \'Active\') OR ' +
                      '(Asset__c != null AND Asset__r.Status__c = \'Active\'' + assetRecordTypeFilter + '))';
        try {
            for (Content_Tag__c tag : Database.query(soql)) {
                if (tag.Curriculum__c != null && !matchingReasonsAndIds.containsKey(tag.Curriculum__c)) matchingReasonsAndIds.put(tag.Curriculum__c, reason);
                if (tag.Course__c != null && !matchingReasonsAndIds.containsKey(tag.Course__c)) matchingReasonsAndIds.put(tag.Course__c, reason);
                if (tag.Asset__c != null && !matchingReasonsAndIds.containsKey(tag.Asset__c)) matchingReasonsAndIds.put(tag.Asset__c, reason);
            }
        } catch (Exception e) { 
            System.debug(LoggingLevel.ERROR, 'SOQL Error in findTrainingByPrimaryCategory for ' + categoryValue + ': ' + e.getMessage() + '. SOQL: ' + soql); 
        }
    }
    
    private static void addKeywordMatchForTerm(String termToMatch, String reason, Map<Id, String> matchingReasonsAndIds) {
        if (String.isBlank(termToMatch)) return;
        
        String likeKeyword = '%' + String.escapeSingleQuotes(termToMatch.trim()) + '%';
        Id eventRecordTypeId = getEventAssetRecordTypeId();
        
        for (Curriculum__c curr : [SELECT Id FROM Curriculum__c WHERE Status__c = 'Active' AND (Name LIKE :likeKeyword OR Description__c LIKE :likeKeyword)]) {
            if (!matchingReasonsAndIds.containsKey(curr.Id)) matchingReasonsAndIds.put(curr.Id, reason);
        }
        for (Course__c course : [SELECT Id FROM Course__c WHERE Status__c = 'Active' AND (Name LIKE :likeKeyword OR Description__c LIKE :likeKeyword)]) {
            if (!matchingReasonsAndIds.containsKey(course.Id)) matchingReasonsAndIds.put(course.Id, reason);
        }
        if (eventRecordTypeId != null) {
            for (Asset__c asset : [SELECT Id FROM Asset__c WHERE Status__c = 'Active' AND RecordTypeId = :eventRecordTypeId AND (Name LIKE :likeKeyword OR Description__c LIKE :likeKeyword)]) {
                if (!matchingReasonsAndIds.containsKey(asset.Id)) matchingReasonsAndIds.put(asset.Id, reason);
            }
        }
    }
    
    private static SearchVocabulary cachedVocab;
    private static Boolean vocabLoaded = false;

    private static SearchVocabulary getSearchVocabulary() {
        if (vocabLoaded && cachedVocab != null) {
            return cachedVocab;
        }

        cachedVocab = new SearchVocabulary();
        try {
            Schema.DescribeFieldResult fieldResult = Content_Tag__c.Primary_Category__c.getDescribe();
            for (Schema.PicklistEntry ple : fieldResult.getPicklistValues()) {
                cachedVocab.primaryCategories.add(ple.getLabel()); 
                cachedVocab.primaryCategoriesLower.add(ple.getLabel().toLowerCase());
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Could not retrieve Primary_Category__c picklist values: ' + e.getMessage());
        }

        Set<Id> activeProductIds = new Set<Id>();
        Set<Id> activeIndustryIds = new Set<Id>();
        Set<Id> activeRoleIds = new Set<Id>();
        Id eventRTId = getEventAssetRecordTypeId();
        String assetFilter = (eventRTId == null) ? '' : ' AND Asset__r.RecordTypeId = \'' + String.escapeSingleQuotes(eventRTId) + '\'';

        // Query Content_Tag__c to find active, used tags.
        String tagQuery = 'SELECT Product__c, Industry__c, Role__c FROM Content_Tag__c WHERE (' +
                          '(Curriculum__c != null AND Curriculum__r.Status__c = \'Active\') OR ' +
                          '(Course__c != null AND Course__r.Status__c = \'Active\') OR ' +
                          '(Asset__c != null AND Asset__r.Status__c = \'Active\'' + assetFilter + ')) AND ' +
                          '(Product__c != null OR Industry__c != null OR Role__c != null)';
        try {
            for(Content_Tag__c tag : Database.query(tagQuery)) {
                if(tag.Product__c != null) activeProductIds.add(tag.Product__c);
                if(tag.Industry__c != null) activeIndustryIds.add(tag.Industry__c);
                if(tag.Role__c != null) activeRoleIds.add(tag.Role__c);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error querying Content_Tag__c for vocabulary: ' + e.getMessage());
        }
        
        // Populate vocab from active tags
        if(!activeProductIds.isEmpty()){
            for(Product__c prod : [SELECT Name FROM Product__c WHERE Id IN :activeProductIds AND Name != null]){
                cachedVocab.products.add(prod.Name); cachedVocab.productsLower.add(prod.Name.toLowerCase());
            }
        }
        if(!activeIndustryIds.isEmpty()){
            // Using dynamic SOQL for Industry__c and Role__c if they are custom objects not directly known here
            // or if field names might vary (though 'Name' is standard).
            // It's generally better to use concrete SObject types if known.
            for(SObject ind : Database.query('SELECT Name FROM Industry__c WHERE Id IN :activeIndustryIds AND Name != null')){
                cachedVocab.industries.add((String)ind.get('Name')); cachedVocab.industriesLower.add(((String)ind.get('Name')).toLowerCase());
            }
        }
        if(!activeRoleIds.isEmpty()){
             for(SObject role : Database.query('SELECT Name FROM Role__c WHERE Id IN :activeRoleIds AND Name != null')){ 
                cachedVocab.roles.add((String)role.get('Name')); cachedVocab.rolesLower.add(((String)role.get('Name')).toLowerCase());
            }
        }
        vocabLoaded = true;
        return cachedVocab;
    }
    
    private static String findBestMatch(String normalizedInput, Set<String> vocabularyTermsLower, Set<String> vocabularyTermsOriginal) {
        String bestMatchLower = '';
        if (String.isBlank(normalizedInput) || vocabularyTermsLower == null || vocabularyTermsLower.isEmpty()) {
            return bestMatchLower;
        }
        // Prioritize longer matches if multiple vocabulary terms are found within the input
        for (String termLower : vocabularyTermsLower) {
            if (normalizedInput.contains(termLower)) { // Use .contains() to find vocab terms within a phrase
                if (termLower.length() > bestMatchLower.length()) { // Prefer the longest matching term
                    bestMatchLower = termLower; 
                }
            }
        }
        // Retrieve the original casing of the matched term
        if(String.isNotBlank(bestMatchLower)){
            for(String originalTerm : vocabularyTermsOriginal){
                if(originalTerm.toLowerCase().equals(bestMatchLower)) { 
                    return originalTerm; // Return the original cased term
                }
            }
        }
        return ''; // No match found or bestMatchLower remained empty
    }
    
    private static void queryAndPaginateDetails(Map<Id, String> allMatchingReasonsAndIds, Integer pageNumber, TrainingSearchResponse responseToUpdate) {
        List<Id> allIds = new List<Id>(allMatchingReasonsAndIds.keySet());
        // Note: allIds.sort() sorts by ID string value. This may not be ideal for relevance.
        // Consider a more sophisticated sorting if relevance or type-priority is needed before pagination.
        allIds.sort(); 
        
        responseToUpdate.trainingResults = new List<TrainingSearchResult>(); 
        Integer totalMatches = allMatchingReasonsAndIds.size();
        // Determine if there are more results for subsequent pages
        responseToUpdate.hasMoreResults = totalMatches > (pageNumber * PAGE_SIZE);

        Integer offset = (pageNumber - 1) * PAGE_SIZE;
        // If offset is beyond the total number of matches, there are no results for this page
        if (offset >= totalMatches) { 
             responseToUpdate.hasMoreResults = false; // Should already be false if calculation above is right
             return;
        }
        
        // Determine the IDs for the current page
        Integer endPosition = Math.min(offset + PAGE_SIZE, totalMatches);
        Set<Id> idsForPage = new Set<Id>();
        if (offset < endPosition) { // Ensure start is before end
            for (Integer i = offset; i < endPosition; i++) { idsForPage.add(allIds[i]); }
        }

        if (idsForPage.isEmpty()) {
            // This can happen if calculation leads to an empty set for the page,
            // or if allMatchingReasonsAndIds was empty to begin with (handled earlier in findTraining)
            return; 
        }
        
        System.debug(LoggingLevel.INFO, 'Querying details for ' + idsForPage.size() + ' IDs for page ' + pageNumber + '. Offset: ' + offset + ', EndPosition: ' + endPosition);

        // Fetch details for the IDs on the current page
        List<SObject> recordsToProcess = new List<SObject>();
        if (!idsForPage.isEmpty()) {
            // Commented out Share_Url__c as per user request
            recordsToProcess.addAll([SELECT Id, Name, Description__c, Objective__c, Time_Estimate__c, /* Share_Url__c, */ Status__c, 
                                     (SELECT Primary_Category__c, Product__r.Name, Industry__r.Name, Role__r.Name FROM Content_Tags__r) 
                                     FROM Curriculum__c WHERE Id IN :idsForPage AND Status__c = 'Active']);
            recordsToProcess.addAll([SELECT Id, Name, Description__c, Objective__c, CSAT__c, Time_Estimate__c, /* Share_Url__c, */ Status__c, 
                                     (SELECT Primary_Category__c, Product__r.Name, Industry__r.Name, Role__r.Name FROM Content_Tags__r) 
                                     FROM Course__c WHERE Id IN :idsForPage AND Status__c = 'Active']);
            Id eventRecordTypeId = getEventAssetRecordTypeId();
            if (eventRecordTypeId != null) {
                 recordsToProcess.addAll([SELECT Id, Name, Description__c, Objective__c, CSAT__c, Time_Estimate_Minutes__c, /* Share_Url__c, */ Status__c, 
                                         (SELECT Primary_Category__c, Product__r.Name, Industry__r.Name, Role__r.Name FROM Content_Tags__r) 
                                         FROM Asset__c WHERE Id IN :idsForPage AND RecordTypeId = :eventRecordTypeId AND Status__c = 'Active']);
            }
        }
        
        // Create TrainingSearchResult objects from the fetched records
        List<TrainingSearchResult> pageResultsList = new List<TrainingSearchResult>();
        for(SObject record : recordsToProcess) {
            String reason = allMatchingReasonsAndIds.get(record.Id);
            if (reason == null) reason = 'General match'; 
            pageResultsList.add(createSearchResultFromSObject(record, reason));
        }
        // Sort the results for the current page by name
        pageResultsList.sort(new TrainingSearchResultComparator());
        responseToUpdate.trainingResults = pageResultsList;
        // Re-confirm hasMoreResults based on whether we've reached the end
        responseToUpdate.hasMoreResults = totalMatches > endPosition; 
    }

    private static TrainingSearchResult createSearchResultFromSObject(SObject record, String reason) {
        TrainingSearchResult res = new TrainingSearchResult(); 
        res.recordId = record.Id;
        res.name = (String)record.get('Name');
        res.description = (String)record.get('Description__c'); 
        res.matchReason = reason; 
        // res.shareUrl = (String)record.get('Share_Url__c'); // Commented out as per user request
        
        Schema.SObjectType sObjType = record.getSObjectType();
        if (sObjType == Curriculum__c.SObjectType) {
            res.objectType = 'Curriculum';
        } else if (sObjType == Course__c.SObjectType) {
            res.objectType = 'Course';
        } else if (sObjType == Asset__c.SObjectType) {
            res.objectType = 'Event'; 
        } else {
            res.objectType = 'Training'; // Fallback
        }

        Set<String> productsSet = new Set<String>();
        Set<String> industriesSet = new Set<String>();
        Set<String> rolesSet = new Set<String>();
        Set<String> primaryCategoriesSet = new Set<String>();
        // Use getSObjects for related list, ensure it's not null
        List<Content_Tag__c> tags = record.getSObjects('Content_Tags__r'); 
        if (tags != null) {
            for (Content_Tag__c tag : tags) {
                if (tag.Product__r != null && String.isNotBlank(tag.Product__r.Name)) productsSet.add(tag.Product__r.Name);
                if (tag.Industry__r != null && String.isNotBlank(tag.Industry__r.Name)) industriesSet.add(tag.Industry__r.Name);
                if (tag.Role__r != null && String.isNotBlank(tag.Role__r.Name)) rolesSet.add(tag.Role__r.Name);
                if (String.isNotBlank(tag.Primary_Category__c)) primaryCategoriesSet.add(tag.Primary_Category__c);
            }
        }
        List<String> detailsList = new List<String>();
        if (!primaryCategoriesSet.isEmpty()) detailsList.add('Categories: ' + String.join(new List<String>(primaryCategoriesSet), ', '));
        if (!productsSet.isEmpty()) detailsList.add('Products: ' + String.join(new List<String>(productsSet), ', '));
        if (!industriesSet.isEmpty()) detailsList.add('Industries: ' + String.join(new List<String>(industriesSet), ', '));
        if (!rolesSet.isEmpty()) detailsList.add('Roles: ' + String.join(new List<String>(rolesSet), ', '));
        res.taggedDetails = detailsList.isEmpty() ? 'N/A' : String.join(detailsList, ' | ');

        String timeEstStr = 'N/A'; 
        Decimal timeEstValMinutes = null;

        // Handle different time estimate fields for Asset vs Curriculum/Course
        if (sObjType == Asset__c.SObjectType) { 
            if (record.get('Time_Estimate_Minutes__c') != null) {
                 timeEstValMinutes = (Decimal)record.get('Time_Estimate_Minutes__c');
            }
        } else { // For Curriculum__c and Course__c
             if (record.get('Time_Estimate__c') != null) {
                try {
                    // Time_Estimate__c might be stored as String or Decimal
                    Object rawTimeEst = record.get('Time_Estimate__c');
                    if(rawTimeEst instanceof Decimal) {
                        timeEstValMinutes = (Decimal)rawTimeEst;
                    } else if (rawTimeEst instanceof String && String.isNotBlank((String)rawTimeEst) && ((String)rawTimeEst).isNumeric()) {
                         timeEstValMinutes = Decimal.valueOf((String)rawTimeEst);
                    }
                } catch (Exception e) { 
                    System.debug(LoggingLevel.WARN, 'Could not parse Time_Estimate__c for ' + record.Id + 
                                   '. Value: ' + record.get('Time_Estimate__c') + '. Error: ' + e.getMessage()); 
                }
             }
        }
        if (timeEstValMinutes != null) {
            timeEstStr = String.valueOf(timeEstValMinutes.setScale(0)) + ' minutes';
        }

        List<String> metricsList = new List<String>();
        if (sObjType == Course__c.SObjectType || sObjType == Asset__c.SObjectType) {
            if (record.get('CSAT__c') != null) {
                Decimal csat = (Decimal)record.get('CSAT__c');
                if (csat != null) metricsList.add('CSAT: ' + csat.setScale(1) + '/5');
            }
        }
        metricsList.add('Time: ' + timeEstStr);
        res.metrics = String.join(metricsList, ' | ');
        
        return res;
    }
    
    private static PromptResponse getParsedPromptResponse(String userInput) {
        if(String.isBlank(userInput)) {
            System.debug(LoggingLevel.WARN, 'getParsedPromptResponse: User input is blank. Returning fallback.');
            PromptResponse blankFallback = new PromptResponse();
            blankFallback.SEARCH_TYPE = 'GENERAL_KEYWORD_SEARCH';
            blankFallback.KEYWORDS = ''; // Or consider falling back to originalUserInput if that's desired here
            return blankFallback;
        }

        Map<String, ConnectApi.WrappedValue> promptParams = new Map<String, ConnectApi.WrappedValue>();
        ConnectApi.WrappedValue wrappedUserInput = new ConnectApi.WrappedValue();
        wrappedUserInput.value = userInput; 
        promptParams.put('Input:User_Input', wrappedUserInput); // Make sure 'Input:User_Input' matches your Prompt Template
        
        ConnectApi.EinsteinPromptTemplateGenerationsInput promptGenerationsInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        promptGenerationsInput.inputParams = promptParams;
        promptGenerationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        promptGenerationsInput.additionalConfig.applicationName = AI_APPLICATION_NAME; 
        promptGenerationsInput.isPreview = false; // Set to false for general use
        
        PromptResponse fallbackResponse = new PromptResponse();
        fallbackResponse.SEARCH_TYPE = 'GENERAL_KEYWORD_SEARCH'; // Default search type
        fallbackResponse.KEYWORDS = userInput; // Fallback keywords to the original input

        try {
            // Ensure 'Extract_Training_Keywords' is the correct API name of your Prompt Template
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation genResponse =
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('Extract_Training_Keywords', promptGenerationsInput);

            if (genResponse == null || genResponse.generations == null || genResponse.generations.isEmpty() || 
                genResponse.generations[0] == null || String.isBlank(genResponse.generations[0].text)) {
                System.debug(LoggingLevel.WARN, 'LLM returned empty or invalid generation. Falling back.');
                return fallbackResponse;
            }
            
            String cleanedJson = cleanJsonResponse(genResponse.generations[0].text);
            if (String.isBlank(cleanedJson)) {
                System.debug(LoggingLevel.WARN, 'Cleaned JSON from LLM is blank. Falling back.');
                return fallbackResponse;
            }
            
            PromptResponse parsed = (PromptResponse) JSON.deserialize(cleanedJson, PromptResponse.class);
            // If LLM returns a search type but no keywords (and it's not ALL_TRAINING),
            // it might be better to use original user input as keywords for that search type.
            if(parsed != null && String.isBlank(parsed.KEYWORDS) && 
               !'ALL_TRAINING'.equalsIgnoreCase(parsed.SEARCH_TYPE) && 
               !'METADATA_QUERY'.equalsIgnoreCase(parsed.SEARCH_TYPE) ){ // Don't override keywords for metadata/all
                parsed.KEYWORDS = userInput; 
            }
            return parsed == null ? fallbackResponse : parsed;

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error calling LLM or deserializing: ' + e.getMessage() + 
                         '. Input UserInput: "' + userInput + 
                         '". AI App Name Used: "' + AI_APPLICATION_NAME + 
                         '". Falling back to general keyword search. StackTrace: ' + e.getStackTraceString());
            return fallbackResponse;
        }
    }
    
    private static String cleanJsonResponse(String response) {
        if(String.isBlank(response)) return null;
        String cleaned = response.trim();
        // Remove markdown code block fences if present
        if (cleaned.startsWith('```json')) {
            cleaned = cleaned.substring('```json'.length()).trim();
        }
        if (cleaned.endsWith('```')) {
            cleaned = cleaned.substring(0, cleaned.length() - '```'.length()).trim();
        }

        // Attempt to extract valid JSON object part if there's extra text
        Integer firstBrace = cleaned.indexOf('{');
        Integer lastBrace = cleaned.lastIndexOf('}');
        
        if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
            return cleaned.substring(firstBrace, lastBrace + 1);
        }
        System.debug(LoggingLevel.WARN, 'Could not find valid JSON structure in LLM response: ' + response + '. Cleaned attempt: ' + cleaned);
        return null; // Return null if no valid JSON object could be extracted
    }

    private static Id eventAssetRecordTypeId;
    private static Boolean eventAssetRecordTypeIdLoaded = false;
    private static Id getEventAssetRecordTypeId() {
        if (eventAssetRecordTypeIdLoaded) {
            return eventAssetRecordTypeId;
        }
        try {
            eventAssetRecordTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get(EVENT_RECORD_TYPE_DEVELOPER_NAME)?.getRecordTypeId();
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Could not retrieve RecordTypeId for Asset with developer name ' + EVENT_RECORD_TYPE_DEVELOPER_NAME + ': ' + e.getMessage());
        }
        eventAssetRecordTypeIdLoaded = true;
        return eventAssetRecordTypeId;
    }
}