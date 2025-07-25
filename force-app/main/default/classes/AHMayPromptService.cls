public with sharing class AHMayPromptService {
    
    public static String generatePromptResponse(String userInput) {
        try {
            System.debug('Processing user input: ' + userInput);
            
            // Create input parameter with exact parameter name from template
            Map<String, ConnectApi.WrappedValue> promptParams = new Map<String, ConnectApi.WrappedValue>();
            
            ConnectApi.WrappedValue wrappedValue = new ConnectApi.WrappedValue();
            wrappedValue.value = userInput;
            
            // Use the correct parameter name with "Input:" prefix
            promptParams.put('Input:User_Input', wrappedValue);
            
            ConnectApi.EinsteinPromptTemplateGenerationsInput promptGenerationsInput = 
                new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            promptGenerationsInput.inputParams = promptParams;
            
            // Add required configuration
            promptGenerationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            promptGenerationsInput.additionalConfig.applicationName = 'PromptBuilderPreview';
            promptGenerationsInput.isPreview = false;
            
            // Use the template API name
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation genResponse = 
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('Employee_Segmentation', promptGenerationsInput);
            
            // Access the first generation's text
            String response = genResponse.generations[0].text;
            
            // Enhanced logging of the raw response
            System.debug('Raw LLM response: ' + response);
            
            // Clean and parse the JSON response
            String cleanedResponse = cleanJsonResponse(response);
            System.debug('Cleaned response: ' + cleanedResponse);
            
            // Post-process response with enhanced pattern detection
            cleanedResponse = postProcessResponse(cleanedResponse, userInput);
            System.debug('Post-processed response: ' + cleanedResponse);
            
            return cleanedResponse;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Einstein LLM API Error: ' + e.getMessage() + ', Stack: ' + e.getStackTraceString());
            throw new AHMayQueryException('Einstein LLM API Error: ' + e.getMessage());
        }
    }
    
    // Enhanced post-processing to handle specific edge cases and pagination requests
    private static String postProcessResponse(String response, String userInput) {
        // Skip processing if empty or not proper JSON
        if (String.isBlank(response) || !response.startsWith('{')) {
            return response;
        }
        
        // Parse the response to a map for easier manipulation
        Map<String, Object> responseMap;
        try {
            responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        } catch (Exception e) {
            System.debug('Error parsing JSON response: ' + e.getMessage());
            return response; // Return original if can't parse
        }
        
        // --- HIERARCHICAL QUERY HANDLING ---
        Boolean containsHierarchicalPhrase = containsHierarchicalPhrase(userInput);
        
        // ENHANCED: Specific handling for "rolls up to" pattern
        if (isRollsUpToQuery(userInput)) {
            System.debug('CRITICAL: Detected "rolls up to" pattern in query');
            containsHierarchicalPhrase = true;
            
            // Force conversion if detected as DIRECT_REPORTS
            if (responseMap.containsKey('DIRECT_REPORTS')) {
                System.debug('CONVERTING: rolls up query from DIRECT_REPORTS to HIERARCHICAL_QUERY');
                Object directReportsValue = responseMap.get('DIRECT_REPORTS');
                responseMap.remove('DIRECT_REPORTS');
                responseMap.put('HIERARCHICAL_QUERY', directReportsValue);
                System.debug('CONVERTED: Now using HIERARCHICAL_QUERY');
            }
        }
        
        // Log diagnosis for complex patterns
        if (userInput.toLowerCase().contains('roll') && userInput.toLowerCase().contains('up')) {
            System.debug('Detected potential roll up pattern in: ' + userInput);
            
            // Analyze the words more carefully
            List<String> words = userInput.toLowerCase().split('\\s+');
            for (Integer i = 0; i < words.size(); i++) {
                if (words[i] == 'roll' || words[i] == 'rolls' || words[i] == 'rolling') {
                    System.debug('Found "roll" at position ' + i);
                    // Check next few words for "up"
                    for (Integer j = i + 1; j < Math.min(i + 4, words.size()); j++) {
                        if (words[j] == 'up') {
                            System.debug('Found "up" at position ' + j + ' - confirming hierarchical pattern');
                            containsHierarchicalPhrase = true;
                        }
                    }
                }
            }
        }
        
        // Additional pattern checks for complex phrases
        if (userInput.toLowerCase().contains('employees') && 
            userInput.toLowerCase().contains('roll') && 
            userInput.toLowerCase().contains('up')) {
            System.debug('Found employees+roll+up pattern in post-processing');
            containsHierarchicalPhrase = true;
        }
        
        if (userInput.toLowerCase().contains('who') && 
            userInput.toLowerCase().contains('roll') && 
            userInput.toLowerCase().contains('up')) {
            System.debug('Found who+roll+up pattern in post-processing');
            containsHierarchicalPhrase = true;
        }
        
        if (containsHierarchicalPhrase && responseMap.containsKey('DIRECT_REPORTS')) {
            System.debug('Post-processing: Converting direct reports to hierarchical query - hierarchical intent detected');
            // Convert DIRECT_REPORTS to HIERARCHICAL_QUERY
            Object directReportsValue = responseMap.get('DIRECT_REPORTS');
            responseMap.remove('DIRECT_REPORTS');
            responseMap.put('HIERARCHICAL_QUERY', directReportsValue);
        }
        
        // --- PAGINATION HANDLING ---
        // Handle pagination requests for field values
        if (isPaginationRequest(userInput) && !responseMap.containsKey('METADATA_REQUEST')) {
            System.debug('Post-processing: Detected pagination request for field values');
            
            // Convert to a field values pagination request
            Map<String, Object> paginationRequest = convertToPaginationRequest(responseMap, userInput);
            
            // Only replace if we successfully created a pagination request
            if (paginationRequest != null && paginationRequest.containsKey('METADATA_REQUEST')) {
                System.debug('Converted to pagination request: ' + JSON.serialize(paginationRequest));
                responseMap = paginationRequest;
            }
        }
        
        // Convert back to JSON string
        return JSON.serialize(responseMap);
    }
    
    // NEW METHOD: Specific check for "rolls up to" pattern
    private static Boolean isRollsUpToQuery(String input) {
        if (String.isBlank(input)) {
            return false;
        }
        
        String lowerInput = input.toLowerCase();
        
        // Direct pattern matches
        List<String> rollsUpPatterns = new List<String>{
            'rolls up to', 'roll up to', 'rolling up to',
            'who rolls up', 'employees who roll up',
            'people who roll up', 'staff who rolls up',
            'employees rolling up', 'people rolling up',
            'roll-up to', 'rolls-up to'
        };
        
        for (String pattern : rollsUpPatterns) {
            if (lowerInput.contains(pattern)) {
                System.debug('Found exact rolls up pattern: "' + pattern + '"');
                return true;
            }
        }
        
        // Check for separated "roll" and "up" words with "to"
        List<String> words = lowerInput.split('\\s+');
        for (Integer i = 0; i < words.size() - 2; i++) {
            if ((words[i] == 'roll' || words[i] == 'rolls' || words[i] == 'rolling') &&
                words[i + 1] == 'up' &&
                words[i + 2] == 'to') {
                System.debug('Found separated "roll up to" pattern');
                return true;
            }
        }
        
        return false;
    }
    
    // Enhanced hierarchical phrase detection
    private static Boolean containsHierarchicalPhrase(String input) {
        if (String.isBlank(input)) {
            return false;
        }
        
        String lowerInput = input.toLowerCase();
        System.debug('Checking for hierarchical phrases in: ' + lowerInput);
        
        List<String> hierarchicalPhrases = new List<String>{
            'roll up', 'rolls up', 'rolling up', 'roll-up',
            'rolls up to', 'roll up to', 'rolling up to',
            'org', 'organization', 'entire org',
            'everyone under', 'all employees under',
            'report up', 'reporting up', 'reports up',
            'management chain', 'chain of command',
            'everyone under', 'everyone who reports',
            'hierarchy', 'subordinates', 'team structure'
        };
        
        for (String phrase : hierarchicalPhrases) {
            if (lowerInput.contains(phrase)) {
                System.debug('Found hierarchical phrase: "' + phrase + '"');
                return true;
            }
        }
        
        // Word-boundary sensitive pattern detection - handle "list employees who roll up to"
        List<String> words = lowerInput.split('\\s+');
        for (Integer i = 0; i < words.size(); i++) {
            // Check for "roll" followed by "up" (with possible words in between)
            if (words[i] == 'roll' || words[i] == 'rolls' || words[i] == 'rolling') {
                // Look for "up" within next 3 words
                for (Integer j = i + 1; j < Math.min(i + 4, words.size()); j++) {
                    if (words[j] == 'up') {
                        System.debug('Found roll/up pattern with words in between');
                        return true;
                    }
                }
            }
        }
        
        // Additional pattern-based checks for longer phrases
        if (lowerInput.contains('employees') && 
            lowerInput.contains('roll') && 
            lowerInput.contains('up')) {
            System.debug('Found employees+roll+up pattern');
            return true;
        }
        
        if (lowerInput.contains('who') && 
            lowerInput.contains('roll') && 
            lowerInput.contains('up')) {
            System.debug('Found who+roll+up pattern');
            return true;
        }
        
        return false;
    }
    
    // NEW PAGINATION DETECTION METHODS
    
    // Check if the input is a pagination request
    private static Boolean isPaginationRequest(String input) {
        if (String.isBlank(input)) {
            return false;
        }
        
        String lowerInput = input.toLowerCase();
        System.debug('Checking for pagination phrases in: ' + lowerInput);
        
        List<String> paginationPhrases = new List<String>{
            'show more', 'next page', 'more values', 'show additional',
            'continue listing', 'page 2', 'page 3', 'page 4', 'page 5',
            'second page', 'third page', 'show the rest', 'continue', 
            'what else', 'what other', 'see more', 'view more'
        };
        
        for (String phrase : paginationPhrases) {
            if (lowerInput.contains(phrase)) {
                System.debug('Found pagination phrase: "' + phrase + '"');
                return true;
            }
        }
        
        return false;
    }
    
    // Convert a request to a field values pagination request
    private static Map<String, Object> convertToPaginationRequest(Map<String, Object> originalRequest, String userInput) {
        // Start with maintaining the basic query structure
        Map<String, Object> paginationRequest = new Map<String, Object>{
            'METADATA_REQUEST' => 'FIELD_VALUES',
            'MAINTAIN_PREVIOUS_CONTEXT' => true
        };
        
        // Try to determine the field name from the input
        String fieldName = extractFieldNameFromPaginationRequest(userInput);
        if (String.isNotBlank(fieldName)) {
            paginationRequest.put('FIELD_NAME', fieldName);
        } else {
            // If no field name in the input, this will rely on the context
            // to determine the last queried field
            paginationRequest.put('FIELD_NAME', 'LAST_QUERIED_FIELD');
        }
        
        // Try to determine page number
        Integer pageNumber = extractPageNumberFromPaginationRequest(userInput);
        if (pageNumber > 0) {
            paginationRequest.put('PAGE_NUMBER', pageNumber);
        } else {
            // Default to requesting the next page
            paginationRequest.put('NEXT_PAGE', true);
        }
        
        System.debug('Generated pagination request: ' + JSON.serialize(paginationRequest));
        return paginationRequest;
    }
    
    // Extract field name from pagination request
    private static String extractFieldNameFromPaginationRequest(String input) {
        if (String.isBlank(input)) {
            return null;
        }
        
        String lowerInput = input.toLowerCase();
        
        // List of potential field names to check for
        List<String> commonFields = new List<String>{
            'division', 'divisions', 
            'job family', 'job families',
            'location', 'locations',
            'business unit', 'business units',
            'region', 'regions',
            'country', 'countries',
            'role', 'roles',
            'manager', 'managers',
            'ae type', 'ae types',
            'account executive',
            'cost center', 'cost centers'
        };
        
        for (String field : commonFields) {
            if (lowerInput.contains(field)) {
                System.debug('Found field name in pagination request: ' + field);
                return field;
            }
        }
        
        return null;
    }
    
    // Extract page number from pagination request
    private static Integer extractPageNumberFromPaginationRequest(String input) {
        if (String.isBlank(input)) {
            return 0;
        }
        
        String lowerInput = input.toLowerCase();
        
        // Check for explicit page numbers
        Pattern pagePattern = Pattern.compile('page (\\d+)');
        Matcher pageMatcher = pagePattern.matcher(lowerInput);
        
        if (pageMatcher.find()) {
            try {
                Integer pageNum = Integer.valueOf(pageMatcher.group(1));
                System.debug('Found explicit page number: ' + pageNum);
                return pageNum;
            } catch (Exception e) {
                return 0;
            }
        }
        
        // Check for text-based page numbers
        Map<String, Integer> textPages = new Map<String, Integer>{
            'second' => 2,
            'third' => 3,
            'fourth' => 4,
            'fifth' => 5
        };
        
        for (String textPage : textPages.keySet()) {
            if (lowerInput.contains(textPage + ' page')) {
                System.debug('Found text-based page number: ' + textPages.get(textPage));
                return textPages.get(textPage);
            }
        }
        
        return 0; // Default, indicates "next page"
    }
    
    public static String cleanJsonResponse(String response) {
        // Clean JSON response by removing code block markers and extra whitespace
        String cleaned = response.replace('```json', '').replace('```', '').trim();
        cleaned = cleaned.replaceAll('\\s+', ' ');
        cleaned = cleaned.replaceAll('[\u00A0\u2007\u202F]', ' ');
        
        if (cleaned.indexOf('{') > 0) {
            cleaned = cleaned.substring(cleaned.indexOf('{'));
        }
        
        // Remove any trailing characters after the last }
        Integer lastBrace = cleaned.lastIndexOf('}');
        if (lastBrace >= 0 && lastBrace < cleaned.length() - 1) {
            cleaned = cleaned.substring(0, lastBrace + 1);
        }
        
        return cleaned;
    }
    
    public static Map<String, Object> parseResponseToMap(String jsonResponse) {
        try {
            return (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error parsing JSON: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Raw JSON: ' + jsonResponse);
            throw e;
        }
    }
}