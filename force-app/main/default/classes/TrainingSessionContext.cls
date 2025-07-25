/**
 * @description Manages the context of a user's conversation for stateful interactions
 * like pagination by leveraging Agentforce's built-in session state for static variables.
 */
public with sharing class TrainingSessionContext {

    // These static variables are persisted by the Agentforce platform during a conversation.
    private static TrainingQueryRequest lastQueryRequest;
    private static Integer lastTotalRecords;
    private static String lastHandlerAction;

    public static void storeLastQuery(TrainingQueryRequest request, Integer totalRecords, String handlerAction) {
        lastQueryRequest = request;
        lastTotalRecords = totalRecords;
        lastHandlerAction = handlerAction;
    }

    public static TrainingQueryRequest getLastQueryRequest() {
        return lastQueryRequest;
    }

    public static Integer getLastTotalRecords() {
        return lastTotalRecords;
    }

    public static String getLastHandlerAction() {
        return lastHandlerAction;
    }

    public static void clearLastQuery() {
        lastQueryRequest = null;
        lastTotalRecords = null;
        lastHandlerAction = null;
    }
}