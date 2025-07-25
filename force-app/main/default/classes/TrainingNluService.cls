/**
 * @description Interfaces with the Einstein Prompt API to parse natural language queries
 * into a structured JSON object.
 * @author (Your Name/Team)
 * @date (Current Date)
 */
public with sharing class TrainingNluService {

    private static final String PROMPT_TEMPLATE_API_NAME = 'Training_Status';
    private static final String APPLICATION_NAME = 'PromptBuilderPreview';

    public static String getStructuredJsonFromNlu(String userInput) {
        if (String.isBlank(userInput)) {
            System.debug(LoggingLevel.WARN, 'TrainingNluService: User input is blank.');
            return null;
        }
        try {
            Map<String, ConnectApi.WrappedValue> promptParams = new Map<String, ConnectApi.WrappedValue>();
            ConnectApi.WrappedValue wrappedUserInput = new ConnectApi.WrappedValue();
            wrappedUserInput.value = userInput;
            promptParams.put('Input:User_Input', wrappedUserInput);

            ConnectApi.EinsteinPromptTemplateGenerationsInput promptInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            promptInput.inputParams = promptParams;
            promptInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            promptInput.additionalConfig.applicationName = APPLICATION_NAME;
            promptInput.isPreview = false;

            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation genResponse =
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(PROMPT_TEMPLATE_API_NAME, promptInput);

            if (genResponse?.generations?.isEmpty() == false && genResponse.generations[0].text != null) {
                return cleanJsonResponse(genResponse.generations[0].text);
            } else {
                System.debug(LoggingLevel.WARN, 'TrainingNluService: LLM API Response or generation text is null/empty.');
                return null;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'TrainingNluService: Einstein LLM API Call Exception. Error: ' + e.getMessage());
            return null;
        }
    }

    /**
     * @description Removes common LLM artifacts and invalid whitespace from the response.
     */
    @TestVisible
    private static String cleanJsonResponse(String response) {
        if (String.isBlank(response)) return '';
        
        // CORRECTED: Explicitly replace the non-breaking space (char code 160) with a regular space.
        String cleaned = response.trim().replace('\u00A0', ' ');
        
        if (cleaned.startsWith('```json')) {
            cleaned = cleaned.substring('```json'.length()).trim();
        }
        if (cleaned.endsWith('```')) {
            cleaned = cleaned.substring(0, cleaned.length() - '```'.length()).trim();
        }

        Integer firstBrace = cleaned.indexOf('{');
        Integer lastBrace = cleaned.lastIndexOf('}');

        if (firstBrace != -1 && lastBrace > firstBrace) {
            cleaned = cleaned.substring(firstBrace, lastBrace + 1);
        }
        return cleaned;
    }
}