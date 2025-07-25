public class AHMayQueryCache {
    // Cache structure with metadata and TTL
    private static Map<String, CacheEntry> sessionCache = new Map<String, CacheEntry>();
    
    // Configuration settings
    private static final Integer DEFAULT_CACHE_EXPIRY_MINUTES = 30;
    private static final Integer MAX_CACHE_ENTRIES = 100;
    
    // Inner class for cache entries with timestamp and metadata
    private class CacheEntry {
        public List<Learner_Profile__c> records;
        public Long timestamp;
        public Integer totalCount;
        public Map<String, Object> queryMetadata;
        
        public CacheEntry(List<Learner_Profile__c> recs, Integer total, Map<String, Object> metadata) {
            this.records = recs;
            this.totalCount = total;
            this.timestamp = System.currentTimeMillis();
            this.queryMetadata = metadata;
        }
        
        public Boolean isExpired() {
            Long currentTime = System.currentTimeMillis();
            Long expiryTimeMs = DEFAULT_CACHE_EXPIRY_MINUTES * 60 * 1000;
            return (currentTime - timestamp) > expiryTimeMs;
        }
    }
    
    // Store results with TTL and metadata
    public static void storeResults(String sessionId, List<Learner_Profile__c> records, 
                                 Integer totalCount, Map<String, Object> queryData) {
        if (String.isBlank(sessionId) || records == null) {
            return;
        }
        
        // Check cache size and clean if needed
        if (sessionCache.size() >= MAX_CACHE_ENTRIES) {
            cleanupCache();
        }
        
        // Store the entry
        sessionCache.put(sessionId, new CacheEntry(records, totalCount, queryData));
        System.debug('Stored ' + records.size() + ' records in cache for session ' + sessionId);
    }
    
    // Legacy method for backward compatibility
    public static void storeResults(String sessionId, List<Learner_Profile__c> records) {
        storeResults(sessionId, records, records.size(), new Map<String, Object>());
    }
    
    // Get results with TTL check
    public static List<Learner_Profile__c> getResults(String sessionId) {
        if (String.isBlank(sessionId) || !sessionCache.containsKey(sessionId)) {
            return new List<Learner_Profile__c>();
        }
        
        CacheEntry entry = sessionCache.get(sessionId);
        
        // Check if cache is expired
        if (entry.isExpired()) {
            sessionCache.remove(sessionId);
            System.debug('Cache expired for session ' + sessionId);
            return new List<Learner_Profile__c>();
        }
        
        return entry.records;
    }
    
    // Get total count for session
    public static Integer getTotalCount(String sessionId) {
        if (String.isBlank(sessionId) || !sessionCache.containsKey(sessionId)) {
            return 0;
        }
        
        CacheEntry entry = sessionCache.get(sessionId);
        
        // Check if cache is expired
        if (entry.isExpired()) {
            sessionCache.remove(sessionId);
            return 0;
        }
        
        return entry.totalCount;
    }
    
    // Get query metadata for session
    public static Map<String, Object> getQueryMetadata(String sessionId) {
        if (String.isBlank(sessionId) || !sessionCache.containsKey(sessionId)) {
            return new Map<String, Object>();
        }
        
        CacheEntry entry = sessionCache.get(sessionId);
        
        // Check if cache is expired
        if (entry.isExpired()) {
            sessionCache.remove(sessionId);
            return new Map<String, Object>();
        }
        
        return entry.queryMetadata;
    }
    
    // Clear specific session results
    public static void clearResults(String sessionId) {
        if (String.isBlank(sessionId)) {
            return;
        }
        
        if (sessionCache.containsKey(sessionId)) {
            sessionCache.remove(sessionId);
            System.debug('Cleared cache for session ' + sessionId);
        }
    }
    
    // Clean up expired entries
    public static void cleanupCache() {
        List<String> keysToRemove = new List<String>();
        Long oldestTimestamp = 9223372036854775807L; // Max long value in Apex
        String oldestKey = null;
        
        // Find expired entries
        for (String key : sessionCache.keySet()) {
            CacheEntry entry = sessionCache.get(key);
            
            // Check if entry is expired
            if (entry.isExpired()) {
                keysToRemove.add(key);
            }
            
            // Track oldest entry for potential removal
            if (entry.timestamp < oldestTimestamp) {
                oldestTimestamp = entry.timestamp;
                oldestKey = key;
            }
        }
        
        // Remove expired entries
        for (String key : keysToRemove) {
            sessionCache.remove(key);
        }
        
        // If we still need to clean up more, remove oldest entry
        if (sessionCache.size() >= MAX_CACHE_ENTRIES && oldestKey != null) {
            sessionCache.remove(oldestKey);
        }
        
        System.debug('Cache cleanup: Removed ' + keysToRemove.size() + ' expired entries');
    }
    
    // Get cache statistics for monitoring
    public static Map<String, Object> getCacheStats() {
        Map<String, Object> stats = new Map<String, Object>();
        stats.put('cacheSize', sessionCache.size());
        stats.put('maxCacheSize', MAX_CACHE_ENTRIES);
        
        Integer activeEntries = 0;
        Integer expiredEntries = 0;
        Integer totalRecords = 0;
        
        for (String key : sessionCache.keySet()) {
            CacheEntry entry = sessionCache.get(key);
            if (entry.isExpired()) {
                expiredEntries++;
            } else {
                activeEntries++;
                totalRecords += entry.records.size();
            }
        }
        
        stats.put('activeEntries', activeEntries);
        stats.put('expiredEntries', expiredEntries);
        stats.put('totalCachedRecords', totalRecords);
        
        return stats;
    }
}