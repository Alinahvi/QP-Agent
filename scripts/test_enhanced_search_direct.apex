/**
 * @description Test direct call to enhanced search method
 */
System.debug('=== Test Enhanced Search Direct ===');

try {
    ANAgentConsensusContentSearchHandler.ContentSearchRequest request = 
        new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    request.userUtterance = 'data cloud';
    request.limitN = 5;
    
    System.debug('Calling searchConsensusContentEnhanced directly...');
    String result = ANAgentConsensusContentSearchService.searchConsensusContentEnhanced(request);
    System.debug('✅ Enhanced search successful: ' + result.length() + ' characters');
    
} catch (Exception e) {
    System.debug('❌ Enhanced search failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== Test Complete ===');
