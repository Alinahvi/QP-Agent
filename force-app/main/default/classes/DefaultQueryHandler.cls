// DefaultQueryHandler.cls
public class DefaultQueryHandler implements ITrainingQueryHandler {

    private TrainingResultFormatter formatter;
    private TrainingQueryRequest request;

    public String process(TrainingQueryRequest queryRequest) {
        this.request = queryRequest;
        // Pass the request to the formatter in case it wants to use any context
        // from the original query in the default message, though it's less likely here.
        this.formatter = new TrainingResultFormatter(this.request);

        String userQuery = this.request.USER_QUERY;
        String agentAction = this.request.AGENT_ACTION;
        String intentType = this.request.INTENT_TYPE;

        String message = 'I\'m sorry, I wasn\'t able to understand or process your request';
        if (String.isNotBlank(userQuery)) {
            message += ' regarding: "' + userQuery + '"';
        } else {
            message += '.';
        }

        if (String.isNotBlank(agentAction)) {
            message += ' (Detected action: ' + agentAction + ')';
        }
        
        System.debug(LoggingLevel.WARN, 'DefaultQueryHandler invoked. Unhandled AGENT_ACTION: ' + agentAction + 
                     ', INTENT_TYPE: ' + intentType + '. User Query: ' + userQuery);

        // Using formatBooleanResult to return a simple statement.
        // The boolean 'false' here signifies the request wasn't successfully processed.
        // The positive statement is blank as it's not applicable.
        return formatter.formatBooleanResult(false, '', message);
    }
}