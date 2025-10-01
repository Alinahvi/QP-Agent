/**
 * @description Test enhanced content search with new intelligence features
 */
System.debug('=== Enhanced Content Search Test ===');

// Test 1: Basic content search with topic extraction
System.debug('\n--- Test 1: Data Cloud Content Search ---');
try {
    ANAgentConsensusContentSearchHandler.ContentSearchRequest request1 = 
        new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    request1.userUtterance = 'find data cloud content';
    request1.limitN = 5;
    
    List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> responses1 = 
        ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{request1});
    
    System.debug('✅ Data Cloud search: ' + responses1.size() + ' responses');
    if (!responses1.isEmpty()) {
        System.debug('  - Message length: ' + responses1[0].message.length() + ' characters');
        System.debug('  - Results: ' + (responses1[0].results != null ? String.valueOf(responses1[0].results.size()) : 'null') + ' items');
    }
} catch (Exception e) {
    System.debug('❌ Data Cloud search failed: ' + e.getMessage());
}

// Test 2: Sales Cloud training search
System.debug('\n--- Test 2: Sales Cloud Training Search ---');
try {
    ANAgentConsensusContentSearchHandler.ContentSearchRequest request2 = 
        new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    request2.userUtterance = 'sales cloud training materials';
    request2.limitN = 10;
    
    List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> responses2 = 
        ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{request2});
    
    System.debug('✅ Sales Cloud training: ' + responses2.size() + ' responses');
    if (!responses2.isEmpty()) {
        System.debug('  - Message length: ' + responses2[0].message.length() + ' characters');
        System.debug('  - Results: ' + (responses2[0].results != null ? String.valueOf(responses2[0].results.size()) : 'null') + ' items');
    }
} catch (Exception e) {
    System.debug('❌ Sales Cloud training failed: ' + e.getMessage());
}

// Test 3: Enhanced search with intelligence flags
System.debug('\n--- Test 3: Enhanced Intelligence Search ---');
try {
    ANAgentConsensusContentSearchHandler.ContentSearchRequest request3 = 
        new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    request3.userUtterance = 'marketing cloud content for sales representatives';
    request3.topic = 'Marketing Cloud';
    request3.ouName = 'AMER-ACC';
    request3.limitN = 8;
    request3.includeSemantic = true;
    request3.includePersonalization = true;
    request3.includeQuality = true;
    request3.includeLifecycle = true;
    request3.includeAnalytics = true;
    
    List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> responses3 = 
        ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{request3});
    
    System.debug('✅ Enhanced intelligence search: ' + responses3.size() + ' responses');
    if (!responses3.isEmpty()) {
        System.debug('  - Message length: ' + responses3[0].message.length() + ' characters');
        System.debug('  - Results: ' + (responses3[0].results != null ? String.valueOf(responses3[0].results.size()) : 'null') + ' items');
        if (responses3[0].results != null && !responses3[0].results.isEmpty()) {
            System.debug('  - First result: ' + responses3[0].results[0].title);
            System.debug('  - First result score: ' + responses3[0].results[0].score);
        }
    }
} catch (Exception e) {
    System.debug('❌ Enhanced intelligence search failed: ' + e.getMessage());
}

// Test 4: Role-based content search
System.debug('\n--- Test 4: Role-Based Content Search ---');
try {
    ANAgentConsensusContentSearchHandler.ContentSearchRequest request4 = 
        new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    request4.userUtterance = 'content for solution architects';
    request4.limitN = 6;
    
    List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> responses4 = 
        ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{request4});
    
    System.debug('✅ Role-based search: ' + responses4.size() + ' responses');
    if (!responses4.isEmpty()) {
        System.debug('  - Message length: ' + responses4[0].message.length() + ' characters');
        System.debug('  - Results: ' + (responses4[0].results != null ? String.valueOf(responses4[0].results.size()) : 'null') + ' items');
    }
} catch (Exception e) {
    System.debug('❌ Role-based search failed: ' + e.getMessage());
}

// Test 5: Industry-specific content search
System.debug('\n--- Test 5: Industry-Specific Content Search ---');
try {
    ANAgentConsensusContentSearchHandler.ContentSearchRequest request5 = 
        new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    request5.userUtterance = 'healthcare industry solutions';
    request5.limitN = 7;
    
    List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> responses5 = 
        ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{request5});
    
    System.debug('✅ Industry-specific search: ' + responses5.size() + ' responses');
    if (!responses5.isEmpty()) {
        System.debug('  - Message length: ' + responses5[0].message.length() + ' characters');
        System.debug('  - Results: ' + (responses5[0].results != null ? String.valueOf(responses5[0].results.size()) : 'null') + ' items');
    }
} catch (Exception e) {
    System.debug('❌ Industry-specific search failed: ' + e.getMessage());
}

System.debug('\n=== Enhanced Content Search Test Complete ===');
