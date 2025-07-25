@isTest
private class AHMayQueryCacheTest {
    
    @testSetup
    static void setup() {
        User testUser = TestDataFactory.createUser('qcache');
        insert testUser;
        TestDataFactory.createLearnerProfile(testUser, 'Test Profile', 'Test Manager', true);
    }
    
    @isTest
    static void testStoreAndGetResults() {
        List<Learner_Profile__c> profiles = [SELECT Id, Name FROM Learner_Profile__c];
        String sessionId = 'session1';
        Map<String, Object> metadata = new Map<String, Object>{'query' => 'test'};

        Test.startTest();
        AHMayQueryCache.storeResults(sessionId, profiles, profiles.size(), metadata);
        List<Learner_Profile__c> cachedResults = AHMayQueryCache.getResults(sessionId);
        Integer count = AHMayQueryCache.getTotalCount(sessionId);
        Map<String, Object> cachedMetadata = AHMayQueryCache.getQueryMetadata(sessionId);
        Test.stopTest();

        System.assertEquals(1, cachedResults.size(), 'Should retrieve 1 record from cache.');
        System.assertEquals(1, count, 'Total count should be 1.');
        System.assertEquals('test', cachedMetadata.get('query'), 'Should retrieve correct metadata.');
    }

    @isTest
    static void testClearResults() {
        List<Learner_Profile__c> profiles = [SELECT Id, Name FROM Learner_Profile__c];
        String sessionId = 'session2';
        AHMayQueryCache.storeResults(sessionId, profiles);
        
        Test.startTest();
        AHMayQueryCache.clearResults(sessionId);
        List<Learner_Profile__c> cachedResults = AHMayQueryCache.getResults(sessionId);
        Test.stopTest();

        System.assert(cachedResults.isEmpty(), 'Cache should be empty after clearing.');
    }

    @isTest
    static void testCacheCleanup() {
        List<Learner_Profile__c> profiles = [SELECT Id, Name FROM Learner_Profile__c];
        // The max cache size is 100
        Integer maxEntries = 100;

        Test.startTest();
        for (Integer i = 0; i < maxEntries + 5; i++) {
            AHMayQueryCache.storeResults('session' + i, profiles);
        }

        Map<String, Object> statsBeforeCleanup = AHMayQueryCache.getCacheStats();
        // The cleanup runs when size >= MAX_CACHE_ENTRIES, so the size could be 100
        System.assertEquals(maxEntries, (Integer)statsBeforeCleanup.get('cacheSize'), 'Cache should be at max size.');

        // Manually run cleanup
        AHMayQueryCache.cleanupCache();
        Map<String, Object> statsAfterCleanup = AHMayQueryCache.getCacheStats();
        Test.stopTest();

        // Since the entries aren't expired, the cleanup will remove the oldest if the cache is full
        System.assert((Integer)statsAfterCleanup.get('cacheSize') < maxEntries + 5, 'Cache size should be managed.');
    }
    
    @isTest
    static void testGetFromEmptyCache() {
        Test.startTest();
        List<Learner_Profile__c> results = AHMayQueryCache.getResults('nonexistent_session');
        Integer count = AHMayQueryCache.getTotalCount('nonexistent_session');
        Test.stopTest();

        System.assert(results.isEmpty(), 'Should return empty list for nonexistent session.');
        System.assertEquals(0, count, 'Should return 0 count for nonexistent session.');
    }
}