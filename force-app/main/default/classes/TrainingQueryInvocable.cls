/**
 * @description Invocable Apex class that serves as the primary entry point for the
 * Training Query System. It is called by Agentforce or Flows.
 * @author (Your Name/Team)
 * @date (Current Date)
 */
public with sharing class TrainingQueryInvocable {

    /**
     * @description Receives raw user input and initiates the query process by calling the service layer.
     * @param userInputs A list containing a single string of the user's query.
     * @return List<String> A list containing a single string with the formatted response.
     */
    @InvocableMethod(
        label='Training - Process Natural Language Query' description='Receives raw user input and processes the query via the TrainingQueryService.' category='Agentforce Training'
        callout=true
    )
    public static List<String> processQuery(List<String> userInputs) {
        if (userInputs == null || userInputs.isEmpty() || String.isBlank(userInputs[0])) {
            return new List<String>{'I received an empty request. Please try again.'};
        }

        String originalRawUserInput = userInputs[0];
        String currentUserName = UserInfo.getName();
        String responseMessage = '';

        try {
            // The Invocable action's only job is to instantiate and call the Query Service.
            // The service layer handles all complex orchestration, including the NLU callout.
            TrainingQueryService queryService = new TrainingQueryService();
            responseMessage = queryService.handleRequest(currentUserName, originalRawUserInput);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'TrainingQueryInvocable Unhandled Exception: ' + e.getMessage() + '. Stacktrace: ' + e.getStackTraceString());
            responseMessage = 'I\'m sorry, an unexpected error occurred while processing your request.';
        }
        
        return new List<String>{ responseMessage };
    }
}