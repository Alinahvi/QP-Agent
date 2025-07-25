/**
 * @description Manages the context between user queries in a conversation.
 * This service uses the Salesforce Platform Cache (Session Cache) to store and retrieve
 * session-specific data, such as previous query parameters and result summaries.
 * This allows for stateful follow-up questions (e.g., "now filter by...") and pagination.
 * @author Your Name/Team
 * @date Created Date
 */
public with sharing class Employee_SessionContext {

    private static final String CONTEXT_SUFFIX = '.queryContext';
    private static final String SUMMARY_SUFFIX = '.resultSummary';
    private static final String SEGMENT_SUFFIX = '.segmentedEmployees';
    private static final Integer CACHE_TTL_SECONDS = 7200; // 2 hours

    /**
     * @description Stores the structured query map (filters, hierarchy, etc.) in the session cache.
     * @param sessionId The unique ID for the current conversation.
     * @param queryData The map representing the structured query to store.
     */
    public static void storeQueryContext(String sessionId, Map<String, Object> queryData) {
        if (String.isBlank(sessionId)) {
            return;
        }
        Cache.Session.put(sessionId + CONTEXT_SUFFIX, queryData, CACHE_TTL_SECONDS);
    }

    /**
     * @description Retrieves the structured query map from the session cache.
     * @param sessionId The unique ID for the current conversation.
     * @return Map<String, Object> The previously stored query map, or an empty map if not found.
     */
    public static Map<String, Object> getQueryContext(String sessionId) {
        if (String.isBlank(sessionId)) {
            return new Map<String, Object>();
        }

        Map<String, Object> context = (Map<String, Object>) Cache.Session.get(sessionId + CONTEXT_SUFFIX);
        
        return context == null ? new Map<String, Object>() : context;
    }

    /**
     * @description Stores a summary of the last query result (counts, pages, etc.) in the session cache.
     * @param sessionId The unique ID for the current conversation.
     * @param totalRecords The total number of records found by the query.
     * @param pageNumber The current page number being displayed.
     * @param hasMore A boolean indicating if more pages of results are available.
     */
    public static void storeResultSummary(String sessionId, Integer totalRecords, Integer pageNumber, Boolean hasMore) {
        if (String.isBlank(sessionId)) {
            return;
        }

        Map<String, Object> summary = new Map<String, Object>{
            'totalRecords' => totalRecords,
            'pageNumber' => pageNumber,
            'hasMore' => hasMore
        };
        Cache.Session.put(sessionId + SUMMARY_SUFFIX, summary, CACHE_TTL_SECONDS);
    }

    /**
     * @description Retrieves the result summary from the session cache.
     * @param sessionId The unique ID for the current conversation.
     * @return Map<String, Object> The summary map, or null if not found.
     */
    public static Map<String, Object> getResultSummary(String sessionId) {
        if (String.isBlank(sessionId)) {
            return null;
        }
        return (Map<String, Object>) Cache.Session.get(sessionId + SUMMARY_SUFFIX);
    }

    /**
     * @description Merges the context from a previous query with a new query map.
     * This is the core logic for handling follow-up questions.
     * @param sessionId The unique ID for the current conversation.
     * @param newQueryData The structured map from the new user query.
     * @return Map<String, Object> The merged query map.
     */
    public static Map<String, Object> intelligentMergeContext(String sessionId, Map<String, Object> newQueryData) {
        Map<String, Object> previousContext = getQueryContext(sessionId);

        if (previousContext.isEmpty()) {
            return newQueryData;
        }

        // Create a clone to avoid modifying the cached version directly
        Map<String, Object> mergedContext = previousContext.clone();

        // Overwrite previous context with new, explicit filters from the new query
        for (String key : newQueryData.keySet()) {
            // Do not merge context maintenance keys themselves
            if (key != 'MAINTAIN_PREVIOUS_CONTEXT' && key != 'NEXT_PAGE') {
                mergedContext.put(key, newQueryData.get(key));
            }
        }
        return mergedContext;
    }
    
    /**
     * @description An alias for intelligentMergeContext to match the original implementation's naming.
     * @param sessionId The unique ID for the current conversation.
     * @param newQueryData The structured map from the new user query.
     * @return Map<String, Object> The merged query map.
     */
    public static Map<String, Object> applyContextToQuery(String sessionId, Map<String, Object> newQueryData) {
        return intelligentMergeContext(sessionId, newQueryData);
    }

    /**
     * @description Stores a list of employee IDs from a query result for cross-topic context
     * (e.g., find employees, then ask about their training).
     * @param sessionId The unique ID for the current conversation.
     * @param employeeIds The list of Salesforce Record IDs to store.
     */
    public static void storeSegmentedEmployees(String sessionId, List<Id> employeeIds) {
        if (String.isBlank(sessionId) || employeeIds == null) {
            return;
        }
        // Using a Set to automatically handle duplicates before caching
        Cache.Session.put(sessionId + SEGMENT_SUFFIX, new Set<Id>(employeeIds), CACHE_TTL_SECONDS);
    }

    /**
     * @description Retrieves the list of segmented employee IDs from the cache.
     * @param sessionId The unique ID for the current conversation.
     * @return List<Id> A list of Salesforce Record IDs, or an empty list if not found.
     */
    public static List<Id> getSegmentedEmployeeIds(String sessionId) {
        if (String.isBlank(sessionId)) {
            return new List<Id>();
        }

        Set<Id> employeeIdSet = (Set<Id>) Cache.Session.get(sessionId + SEGMENT_SUFFIX);

        return employeeIdSet == null ? new List<Id>() : new List<Id>(employeeIdSet);
    }

    /**
     * @description Checks if there are any segmented employee IDs stored for the session.
     * @param sessionId The unique ID for the current conversation.
     * @return Boolean True if segmented employees are cached for the session.
     */
    public static Boolean hasSegmentedEmployees(String sessionId) {
        if (String.isBlank(sessionId)) {
            return false;
        }
        return Cache.Session.contains(sessionId + SEGMENT_SUFFIX);
    }

    /**
     * @description Clears all cached context for a given session.
     * @param sessionId The unique ID for the current conversation.
     */
    public static void clearAllContext(String sessionId) {
        if (String.isBlank(sessionId)) {
            return;
        }
        Cache.Session.remove(sessionId + CONTEXT_SUFFIX);
        Cache.Session.remove(sessionId + SUMMARY_SUFFIX);
        Cache.Session.remove(sessionId + SEGMENT_SUFFIX);
    }
}