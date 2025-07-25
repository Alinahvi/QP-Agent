/**
 * @description Interfaces with the Einstein Prompt API to parse natural language into structured JSON.
 * This service calls the 'Employee_Segmentation' prompt template, receives the raw LLM
 * response, and then cleans and post-processes it to correct common LLM ambiguities,
 * ensuring a reliable JSON output for downstream services.
 * @author Your Name/Team
 * @date Created Date
 */
public with sharing class Employee_PromptService {

    /**
     * @description Calls the Einstein LLM with the user's input and returns a cleaned JSON string.
     * @param userInput The raw natural language query from the user.
     * @return String A structured JSON response.
     * @throws Employee_QueryException if the API call fails.
     */
    public static String generatePromptResponse(String userInput) {
        try {
            Map<String, ConnectApi.WrappedValue> promptParams = new Map<String, ConnectApi.WrappedValue>();
            ConnectApi.WrappedValue wrappedValue = new ConnectApi.WrappedValue();
            wrappedValue.value = userInput;
            promptParams.put('Input:User_Input', wrappedValue);

            ConnectApi.EinsteinPromptTemplateGenerationsInput promptInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            promptInput.inputParams = promptParams;
            
            // CORRECTED: Set applicationName to 'PromptBuilderPreview' for testing context compatibility.
            promptInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            promptInput.additionalConfig.applicationName = 'PromptBuilderPreview';
            promptInput.isPreview = false;

            // CORRECTED: Call the LLM with the correct prompt template API name 'Employee_Segmentation'.
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation genResponse =
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('Employee_Segmentation', promptInput);

            String rawResponse = genResponse.generations[0].text;
            System.debug('Raw LLM response: ' + rawResponse);

            String cleanedResponse = cleanJsonResponse(rawResponse);
            System.debug('Cleaned response: ' + cleanedResponse);

            cleanedResponse = postProcessResponse(cleanedResponse, userInput);
            System.debug('Post-processed response: ' + cleanedResponse);

            return cleanedResponse;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Einstein LLM API Error: ' + e.getMessage() + ', Stack: ' + e.getStackTraceString());
            throw new Employee_QueryException('Einstein LLM API Error: ' + e.getMessage());
        }
    }

    /**
     * @description Parses a JSON string response into a generic Map.
     * @param jsonResponse The JSON string to parse.
     * @return Map<String, Object> A map representing the deserialized JSON.
     */
    public static Map<String, Object> parseResponseToMap(String jsonResponse) {
        try {
            return (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error parsing JSON: ' + e.getMessage() + '. Raw JSON: ' + jsonResponse);
            throw e;
        }
    }

    /**
     * @description Performs post-processing on the JSON response to handle ambiguities.
     * @param jsonResponse The cleaned JSON response string.
     * @param userInput The original user input, used for contextual clues.
     * @return String The potentially modified JSON response string.
     */
    @TestVisible
    private static String postProcessResponse(String jsonResponse, String userInput) {
        if (String.isBlank(jsonResponse) || !jsonResponse.startsWith('{')) {
            return jsonResponse;
        }

        Map<String, Object> responseMap;
        try {
            responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
        } catch (Exception e) {
            return jsonResponse;
        }

        if (containsHierarchicalPhrase(userInput) && responseMap.containsKey('DIRECT_REPORTS')) {
            System.debug('Post-processing: Converting direct reports to hierarchical based on phrasing.');
            Object directReportsValue = responseMap.get('DIRECT_REPORTS');
            responseMap.remove('DIRECT_REPORTS');
            responseMap.put('HIERARCHICAL_QUERY', directReportsValue);
        }

        return JSON.serialize(responseMap);
    }

    /**
     * @description Checks if the user's input contains phrases that strongly imply a hierarchical query.
     */
    @TestVisible
    private static Boolean containsHierarchicalPhrase(String input) {
        if (String.isBlank(input)) {
            return false;
        }
        String lowerInput = input.toLowerCase();

        List<String> hierarchicalPhrases = new List<String>{
            'roll up', 'rolls up', 'rolling up', 'roll-up', 'rolls-up',
            'org', 'organization', 'entire org',
            'everyone under', 'all employees under',
            'hierarchy', 'management chain'
        };

        for (String phrase : hierarchicalPhrases) {
            if (lowerInput.contains(phrase)) {
                System.debug('Found hierarchical phrase: "' + phrase + '"');
                return true;
            }
        }
        return false;
    }

    /**
     * @description Removes common LLM artifacts like markdown code fences from the response.
     */
    public static String cleanJsonResponse(String response) {
        if (String.isBlank(response)) {
            return '';
        }
        String cleaned = response.replace('```json', '').replace('```', '').trim();
        
        Integer firstBrace = cleaned.indexOf('{');
        Integer lastBrace = cleaned.lastIndexOf('}');
        
        if (firstBrace > -1 && lastBrace > firstBrace) {
            cleaned = cleaned.substring(firstBrace, lastBrace + 1);
        }

        return cleaned;
    }

    /**
     * @description Custom exception for this service.
     */
    public class Employee_QueryException extends Exception {}
}