/**
 * @description Debug script to understand why content search results are empty
 */
System.debug('=== Debug Content Search Results ===');

// Test direct call to getRealIntelligentResults
try {
    ANAgentConsensusContentSearchService.EnhancedSearchParams params = 
        new ANAgentConsensusContentSearchService.EnhancedSearchParams();
    params.searchTerm = 'data cloud';
    params.limitN = 5;
    params.publishedOnly = true;
    params.publicOnly = true;
    
    ANAgentConsensusContentSearchService.ContentIntelligenceConfig config = 
        ANAgentConsensusContentSearchService.getIntelligenceConfig();
    
    List<ANAgentConsensusContentSearchService.IntelligentContentResult> results = 
        ANAgentConsensusContentSearchService.getRealIntelligentResults(params, config);
    
    System.debug('✅ Direct call successful: ' + results.size() + ' results');
    for (ANAgentConsensusContentSearchService.IntelligentContentResult result : results) {
        System.debug('  - Result: ' + result.title + ' | Source: ' + result.source + ' | Score: ' + result.score);
    }
    
} catch (Exception e) {
    System.debug('❌ Direct call failed: ' + e.getMessage());
    System.debug('  Stack trace: ' + e.getStackTraceString());
}

// Test individual search methods
System.debug('\n--- Testing Individual Search Methods ---');

// Test Consensus search
try {
    ANAgentConsensusContentSearchService.EnhancedSearchParams consensusParams = 
        new ANAgentConsensusContentSearchService.EnhancedSearchParams();
    consensusParams.searchTerm = 'data cloud';
    consensusParams.limitN = 5;
    consensusParams.publishedOnly = true;
    consensusParams.publicOnly = true;
    
    List<ANAgentConsensusContentSearchService.IntelligentContentResult> consensusResults = 
        ANAgentConsensusContentSearchService.searchConsensusContentReal(consensusParams);
    
    System.debug('✅ Consensus search: ' + consensusResults.size() + ' results');
    for (ANAgentConsensusContentSearchService.IntelligentContentResult result : consensusResults) {
        System.debug('  - Consensus: ' + result.title + ' | Source: ' + result.source);
    }
    
} catch (Exception e) {
    System.debug('❌ Consensus search failed: ' + e.getMessage());
}

// Test ACT search
try {
    ANAgentConsensusContentSearchService.EnhancedSearchParams actParams = 
        new ANAgentConsensusContentSearchService.EnhancedSearchParams();
    actParams.searchTerm = 'sales cloud';
    actParams.limitN = 5;
    actParams.publishedOnly = true;
    actParams.publicOnly = true;
    
    List<ANAgentConsensusContentSearchService.IntelligentContentResult> actResults = 
        ANAgentConsensusContentSearchService.searchACTContentReal(actParams);
    
    System.debug('✅ ACT search: ' + actResults.size() + ' results');
    for (ANAgentConsensusContentSearchService.IntelligentContentResult result : actResults) {
        System.debug('  - ACT: ' + result.title + ' | Source: ' + result.source);
    }
    
} catch (Exception e) {
    System.debug('❌ ACT search failed: ' + e.getMessage());
}

System.debug('\n=== Debug Complete ===');
