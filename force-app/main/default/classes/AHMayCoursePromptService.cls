/**
 * Service class for handling course query parsing using Einstein Prompt API
 */
public with sharing class AHMayCoursePromptService {
    
    /**
     * Generate a structured response from a natural language course query
     * @param userInput Natural language input from the user
     * @return JSON string containing parsed query structure
     */
    public static String generatePromptResponse(String userInput) {
        try {
            System.debug('Processing course query: ' + userInput);
            
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
            
            // Use the template API name - would need to create this template in Einstein Prompt builder
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation genResponse = 
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('Assignment_Query', promptGenerationsInput);
            
            // Access the first generation's text
            String response = genResponse.generations[0].text;
            
            // Clean and parse the JSON response
            String cleanedResponse = cleanJsonResponse(response);
            System.debug('Cleaned response: ' + cleanedResponse);
            
            return cleanedResponse;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Einstein LLM API Error: ' + e.getMessage() + ', Stack: ' + e.getStackTraceString());
            throw new AHMayQueryException('Einstein LLM API Error: ' + e.getMessage());
        }
    }
    
    /**
     * Clean the JSON response from the LLM to ensure it's valid JSON
     * @param response Raw response from the LLM
     * @return Cleaned JSON string
     */
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
    
    /**
     * Parse a JSON response string into a Map
     * @param jsonResponse JSON string to parse
     * @return Map of structured data
     */
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