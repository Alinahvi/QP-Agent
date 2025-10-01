/**
 * @description Test script to verify Content Search fixes work correctly
 * Tests the enhanced search logic with fallback mechanisms
 */
System.debug('=== Content Search Fixes Test ===');

// Test 1: Consensus Search with Search Term
System.debug('\n--- Test 1: Consensus Search with Search Term ---');
try {
    ANAgentConsensusContentSearchHandler.ContentSearchRequest consensusRequest = 
        new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    consensusRequest.userUtterance = 'data cloud';
    consensusRequest.limitN = 5;
    
    List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> consensusResponses = 
        ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{consensusRequest});
    
    System.debug('✅ Consensus search successful: ' + consensusResponses.size() + ' responses');
    if (!consensusResponses.isEmpty()) {
        System.debug('  - Message length: ' + consensusResponses[0].message.length() + ' characters');
        System.debug('  - Results count: ' + (consensusResponses[0].results != null ? consensusResponses[0].results.size() : 0));
        if (consensusResponses[0].results != null && !consensusResponses[0].results.isEmpty()) {
            System.debug('  - First result: ' + consensusResponses[0].results[0].title);
            System.debug('  - First result source: ' + consensusResponses[0].results[0].source);
        }
    }
} catch (Exception e) {
    System.debug('❌ Consensus search failed: ' + e.getMessage());
    System.debug('  Stack trace: ' + e.getStackTraceString());
}

// Test 2: ACT Search with Search Term
System.debug('\n--- Test 2: ACT Search with Search Term ---');
try {
    ANAgentConsensusContentSearchHandler.ContentSearchRequest actRequest = 
        new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    actRequest.userUtterance = 'sales cloud training';
    actRequest.limitN = 5;
    
    List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> actResponses = 
        ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{actRequest});
    
    System.debug('✅ ACT search successful: ' + actResponses.size() + ' responses');
    if (!actResponses.isEmpty()) {
        System.debug('  - Message length: ' + actResponses[0].message.length() + ' characters');
        System.debug('  - Results count: ' + (actResponses[0].results != null ? actResponses[0].results.size() : 0));
        if (actResponses[0].results != null && !actResponses[0].results.isEmpty()) {
            System.debug('  - First result: ' + actResponses[0].results[0].title);
            System.debug('  - First result source: ' + actResponses[0].results[0].source);
        }
    }
} catch (Exception e) {
    System.debug('❌ ACT search failed: ' + e.getMessage());
    System.debug('  Stack trace: ' + e.getStackTraceString());
}

// Test 3: Enhanced Search with Intelligence Features
System.debug('\n--- Test 3: Enhanced Search with Intelligence Features ---');
try {
    ANAgentConsensusContentSearchHandler.ContentSearchRequest enhancedRequest = 
        new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    enhancedRequest.userUtterance = 'marketing cloud';
    enhancedRequest.topic = 'Marketing Cloud';
    enhancedRequest.ouName = 'AMER-ACC';
    enhancedRequest.limitN = 10;
    enhancedRequest.includeSemantic = true;
    enhancedRequest.includePersonalization = true;
    enhancedRequest.includeQuality = true;
    enhancedRequest.includeLifecycle = true;
    enhancedRequest.includeAnalytics = true;
    
    List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> enhancedResponses = 
        ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{enhancedRequest});
    
    System.debug('✅ Enhanced search successful: ' + enhancedResponses.size() + ' responses');
    if (!enhancedResponses.isEmpty()) {
        System.debug('  - Message length: ' + enhancedResponses[0].message.length() + ' characters');
        System.debug('  - Results count: ' + (enhancedResponses[0].results != null ? enhancedResponses[0].results.size() : 0));
        if (enhancedResponses[0].results != null && !enhancedResponses[0].results.isEmpty()) {
            System.debug('  - First result: ' + enhancedResponses[0].results[0].title);
            System.debug('  - First result score: ' + enhancedResponses[0].results[0].score);
            System.debug('  - First result why: ' + enhancedResponses[0].results[0].why);
        }
    }
} catch (Exception e) {
    System.debug('❌ Enhanced search failed: ' + e.getMessage());
    System.debug('  Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== Content Search Fixes Test Complete ===');
