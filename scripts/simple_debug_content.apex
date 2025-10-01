/**
 * @description Simple debug script for content search
 */
System.debug('=== Simple Debug Content Search ===');

// Test basic search
try {
    ANAgentConsensusContentSearchHandler.ContentSearchRequest request = 
        new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    request.userUtterance = 'data cloud';
    request.limitN = 5;
    
    List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> responses = 
        ANAgentConsensusContentSearchHandler.searchContent(new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{request});
    
    System.debug('✅ Search successful: ' + responses.size() + ' responses');
    if (!responses.isEmpty()) {
        System.debug('  - Message length: ' + responses[0].message.length() + ' characters');
        System.debug('  - Results: ' + (responses[0].results != null ? String.valueOf(responses[0].results.size()) : 'null') + ' items');
        
        if (responses[0].results != null && !responses[0].results.isEmpty()) {
            System.debug('  - First result title: ' + responses[0].results[0].title);
        } else {
            System.debug('  - No results found');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Search failed: ' + e.getMessage());
    System.debug('  Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== Debug Complete ===');
