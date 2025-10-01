/**
 * @description Comprehensive test for content search functionality
 */
System.debug('=== Comprehensive Content Search Test ===');

// Test 1: Basic search without intelligence flags
System.debug('\n--- Test 1: Basic Search ---');
try {
    ANAgentConsensusContentSearchHandler.ContentSearchRequest basicRequest = 
        new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    basicRequest.userUtterance = 'data cloud';
    basicRequest.limitN = 5;
    
    List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> basicResponses = 
        ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{basicRequest});
    
    System.debug('✅ Basic search: ' + basicResponses.size() + ' responses');
    if (!basicResponses.isEmpty()) {
        System.debug('  - Message length: ' + basicResponses[0].message.length() + ' characters');
        System.debug('  - Results: ' + (basicResponses[0].results != null ? String.valueOf(basicResponses[0].results.size()) : 'null') + ' items');
    }
} catch (Exception e) {
    System.debug('❌ Basic search failed: ' + e.getMessage());
}

// Test 2: Enhanced search with intelligence flags
System.debug('\n--- Test 2: Enhanced Search ---');
try {
    ANAgentConsensusContentSearchHandler.ContentSearchRequest enhancedRequest = 
        new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    enhancedRequest.userUtterance = 'sales cloud training';
    enhancedRequest.topic = 'Sales Cloud';
    enhancedRequest.ouName = 'AMER-ACC';
    enhancedRequest.limitN = 10;
    enhancedRequest.includeSemantic = true;
    enhancedRequest.includePersonalization = true;
    enhancedRequest.includeQuality = true;
    enhancedRequest.includeLifecycle = true;
    enhancedRequest.includeAnalytics = true;
    
    List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> enhancedResponses = 
        ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{enhancedRequest});
    
    System.debug('✅ Enhanced search: ' + enhancedResponses.size() + ' responses');
    if (!enhancedResponses.isEmpty()) {
        System.debug('  - Message length: ' + enhancedResponses[0].message.length() + ' characters');
        System.debug('  - Results: ' + (enhancedResponses[0].results != null ? String.valueOf(enhancedResponses[0].results.size()) : 'null') + ' items');
        if (enhancedResponses[0].results != null && !enhancedResponses[0].results.isEmpty()) {
            System.debug('  - First result: ' + enhancedResponses[0].results[0].title);
            System.debug('  - First result score: ' + enhancedResponses[0].results[0].score);
        }
    }
} catch (Exception e) {
    System.debug('❌ Enhanced search failed: ' + e.getMessage());
}

// Test 3: Consensus-specific search
System.debug('\n--- Test 3: Consensus Search ---');
try {
    ANAgentConsensusContentSearchHandler.ContentSearchRequest consensusRequest = 
        new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    consensusRequest.userUtterance = 'consensus marketing cloud';
    consensusRequest.limitN = 5;
    
    List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> consensusResponses = 
        ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{consensusRequest});
    
    System.debug('✅ Consensus search: ' + consensusResponses.size() + ' responses');
    if (!consensusResponses.isEmpty()) {
        System.debug('  - Message length: ' + consensusResponses[0].message.length() + ' characters');
        System.debug('  - Results: ' + (consensusResponses[0].results != null ? String.valueOf(consensusResponses[0].results.size()) : 'null') + ' items');
    }
} catch (Exception e) {
    System.debug('❌ Consensus search failed: ' + e.getMessage());
}

System.debug('\n=== Comprehensive Test Complete ===');
