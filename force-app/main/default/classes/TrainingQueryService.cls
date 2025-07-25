/**
 * @description The central orchestrator for processing training data queries. This version
 * contains the full logic for routing, pagination, and contextual fallbacks.
 * @author (Your Name/Team)
 * @date (Current Date)
 */
public with sharing class TrainingQueryService {

    public String handleRequest(String currentUserName, String originalRawUserInput) {
        String jsonRequestString = TrainingNluService.getStructuredJsonFromNlu(originalRawUserInput);
        System.debug(LoggingLevel.ERROR, '### NLU JSON RECEIVED: ' + jsonRequestString);

        if (String.isBlank(jsonRequestString)) {
            return 'I had trouble understanding your request.';
        }

        TrainingQueryRequest requestObject = TrainingQueryRequest.parse(jsonRequestString);
        if (requestObject == null) {
            return 'I had trouble understanding the structure of your request.';
        }

        try {
            requestObject = applyContextualFallbacks(requestObject, currentUserName, originalRawUserInput);
            requestObject = disambiguateNluResponse(requestObject, originalRawUserInput);

            if ('PAGINATE_PREVIOUS_QUERY'.equalsIgnoreCase(requestObject.AGENT_ACTION)) {
                return handlePagination(requestObject, currentUserName);
            }

            String effectiveAgentAction = getEffectiveAgentAction(requestObject);
            ITrainingQueryHandler handler = TrainingQueryHandlerFactory.getHandler(effectiveAgentAction, requestObject);
            
            if (handler == null) {
                return 'I am unable to handle this specific type of request.';
            }
            
            String result = handler.process(requestObject);
            storeContextForPagination(requestObject, effectiveAgentAction);
            return result;

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'TrainingQueryService Unhandled Exception: ' + e.getMessage() + '. Stacktrace: ' + e.getStackTraceString());
            return 'I\'m sorry, an unexpected issue occurred.';
        }
    }
    
    @TestVisible
    private TrainingQueryRequest disambiguateNluResponse(TrainingQueryRequest request, String rawInput) {
        String learnerName = request.LEARNER_CONTEXT?.LEARNER_NAME;
        String anchorName = request.HIERARCHY_CONTEXT?.ANCHOR_NAME;
        String inputLower = String.isNotBlank(rawInput) ? rawInput.toLowerCase() : '';

        if (String.isNotBlank(learnerName) && learnerName.equalsIgnoreCase(anchorName)) {
            List<String> teamKeywords = new List<String>{'team', 'org', 'organization', 'reports', 'directs', 'rolls up'};
            Boolean containsTeamKeyword = false;
            for(String keyword : teamKeywords) {
                if (inputLower.contains(keyword)) {
                    containsTeamKeyword = true;
                    break;
                }
            }
            if (!containsTeamKeyword) {
                request.HIERARCHY_CONTEXT = null;
            }
        }
        return request;
    }

    @TestVisible
    private TrainingQueryRequest applyContextualFallbacks(TrainingQueryRequest request, String userName, String rawInput) {
        String inputLower = String.isNotBlank(rawInput) ? rawInput.toLowerCase() : '';
        if (request.HIERARCHY_CONTEXT != null && (inputLower.contains('my team') || inputLower.contains('my org'))) {
            request.HIERARCHY_CONTEXT.ANCHOR_NAME = userName;
        }
        if (request.LEARNER_CONTEXT != null && (inputLower.contains('my training') || inputLower.contains('i completed') || inputLower.contains('am i assigned'))) {
            request.LEARNER_CONTEXT.LEARNER_NAME = userName;
        }
        return request;
    }

    @TestVisible
    private String getEffectiveAgentAction(TrainingQueryRequest request) {
        if ('GET_TRAINING_PARTICIPANTS'.equalsIgnoreCase(request.AGENT_ACTION) && request.HIERARCHY_CONTEXT != null) {
            return 'GET_HIERARCHICAL_TRAINING_COMPLETION';
        }
        return request.AGENT_ACTION;
    }

    private String handlePagination(TrainingQueryRequest paginationRequest, String userName) {
        TrainingQueryRequest previousRequest = TrainingSessionContext.getLastQueryRequest();
        Integer lastTotal = TrainingSessionContext.getLastTotalRecords();
        String originalAction = TrainingSessionContext.getLastHandlerAction();
        
        if (previousRequest == null) {
             return 'I don\'t have a previous search to show more results for.';
        }
        
        Integer pageSize = previousRequest.FILTERS?.queryLimit != null ? previousRequest.FILTERS.queryLimit : 20;
        Integer currentOffset = previousRequest.FILTERS?.queryOffset != null ? previousRequest.FILTERS.queryOffset : 0;
        Integer newOffset = currentOffset + pageSize;

        if (lastTotal == null || newOffset >= lastTotal) { 
            return 'There are no more results to show.'; 
        }

        TrainingQueryRequest requestToProcess = previousRequest;
        if(requestToProcess.FILTERS == null) requestToProcess.FILTERS = new TrainingQueryRequest.Filters();
        requestToProcess.FILTERS.queryOffset = newOffset;
        
        requestToProcess = applyContextualFallbacks(requestToProcess, userName, requestToProcess.USER_QUERY);
        
        ITrainingQueryHandler handler = TrainingQueryHandlerFactory.getHandler(originalAction, requestToProcess);
        return handler.process(requestToProcess);
    }
    
    private void storeContextForPagination(TrainingQueryRequest request, String effectiveAction) {
        if ('LIST'.equalsIgnoreCase(request.RESPONSE_CRITERIA?.FORMAT) && request.RESPONSE_CRITERIA?.totalRecords != null) {
            TrainingSessionContext.storeLastQuery(request, request.RESPONSE_CRITERIA.totalRecords, effectiveAction);
        } else {
            TrainingSessionContext.clearLastQuery();
        }
    }
}