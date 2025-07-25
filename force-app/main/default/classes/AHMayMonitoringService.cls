public class AHMayMonitoringService {
    // Simple method to log basic usage statistics
    public static void logStats() {
        Map<String, Object> stats = AHMaySessionContext.getSessionStats();
        System.debug('Session Statistics: ' + JSON.serialize(stats));
    }
    
    // Call this method periodically if desired
    public static void performMaintenance() {
        Integer cleanedSessions = AHMaySessionContext.cleanupExpiredSessions();
        System.debug('Cleaned up ' + cleanedSessions + ' expired sessions');
    }
}