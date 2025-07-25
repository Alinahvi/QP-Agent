/**
 * Utility class to maintain context between employee and course queries
 */
public with sharing class AHMayCrossTopicContext {
    private static Map<String, List<Id>> segmentedEmployeesMap = new Map<String, List<Id>>();
    
    /**
     * Store segmented employee IDs for use in subsequent queries
     * @param sessionId The conversation session ID
     * @param employeeIds List of employee IDs from segmentation
     */
    public static void storeSegmentedEmployees(String sessionId, List<Id> employeeIds) {
        if (String.isBlank(sessionId) || employeeIds == null || employeeIds.isEmpty()) {
            return;
        }
        
        // Use a set to ensure unique IDs
        Set<Id> uniqueIds = new Set<Id>(employeeIds);
        segmentedEmployeesMap.put(sessionId, new List<Id>(uniqueIds));
        
        System.debug('Stored ' + uniqueIds.size() + ' unique employee IDs for session ' + sessionId);
    }
    
    /**
     * Get previously segmented employee IDs
     * @param sessionId The conversation session ID
     * @return List of previously segmented employee IDs
     */
    public static List<Id> getSegmentedEmployeeIds(String sessionId) {
        if (String.isBlank(sessionId) || !segmentedEmployeesMap.containsKey(sessionId)) {
            return new List<Id>();
        }
        return segmentedEmployeesMap.get(sessionId);
    }
    
    /**
     * Check if there are segmented employees available
     * @param sessionId The conversation session ID
     * @return True if there are previously segmented employees
     */
    public static Boolean hasSegmentedEmployees(String sessionId) {
        List<Id> ids = getSegmentedEmployeeIds(sessionId);
        return !ids.isEmpty();
    }
    
    /**
     * Clear context for a session
     * @param sessionId The conversation session ID
     */
    public static void clearContext(String sessionId) {
        if (segmentedEmployeesMap.containsKey(sessionId)) {
            segmentedEmployeesMap.remove(sessionId);
            System.debug('Cleared cross-topic context for session ' + sessionId);
        }
    }
    
    /**
     * Get count of stored segmented employees
     * @param sessionId The conversation session ID
     * @return Number of stored employee IDs
     */
    public static Integer getSegmentedEmployeeCount(String sessionId) {
        List<Id> ids = getSegmentedEmployeeIds(sessionId);
        return ids.size();
    }
    
    /**
     * Add more employee IDs to existing segmentation
     * @param sessionId The conversation session ID
     * @param additionalIds Additional employee IDs to add
     */
    public static void addToSegmentedEmployees(String sessionId, List<Id> additionalIds) {
        if (String.isBlank(sessionId) || additionalIds == null || additionalIds.isEmpty()) {
            return;
        }
        
        List<Id> existingIds = getSegmentedEmployeeIds(sessionId);
        Set<Id> combinedIds = new Set<Id>(existingIds);
        combinedIds.addAll(additionalIds);
        
        segmentedEmployeesMap.put(sessionId, new List<Id>(combinedIds));
        System.debug('Updated segmented employees for session ' + sessionId + 
                   ', now contains ' + combinedIds.size() + ' unique IDs');
    }
}