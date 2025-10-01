/**
 * @description Test script for Consensus Content Search functionality
 * Tests various search scenarios and validates the routing logic
 */
System.debug('=== Testing Consensus Content Search ===');

// Test 1: Consensus search with explicit mention
System.debug('\n--- Test 1: Consensus search with explicit mention ---');
String consensusResult1 = ANAgentConsensusContentSearchHandler.searchContent('Find Consensus demos for Datorama on media planning').message;
System.debug('Result 1: ' + consensusResult1);

// Test 2: Consensus search with language filter
System.debug('\n--- Test 2: Consensus search with language filter ---');
String consensusResult2 = ANAgentConsensusContentSearchHandler.searchContent('Show me Consensus content in English for Financial Services').message;
System.debug('Result 2: ' + consensusResult2);

// Test 3: Consensus search with published filter
System.debug('\n--- Test 3: Consensus search with published filter ---');
String consensusResult3 = ANAgentConsensusContentSearchHandler.searchContent('I need a Consensus demo for Billing Reconciliation — published only').message;
System.debug('Result 3: ' + consensusResult3);

// Test 4: Consensus search with creator filter
System.debug('\n--- Test 4: Consensus search with creator filter ---');
String consensusResult4 = ANAgentConsensusContentSearchHandler.searchContent('Search Consensus by creator Justin Jones').message;
System.debug('Result 4: ' + consensusResult4);

// Test 5: ACT search (no Consensus mention)
System.debug('\n--- Test 5: ACT search (no Consensus mention) ---');
String actResult1 = ANAgentConsensusContentSearchHandler.searchContent('Search ACT for Sales Cloud onboarding materials').message;
System.debug('Result 5: ' + actResult1);

// Test 6: ACT search with general terms
System.debug('\n--- Test 6: ACT search with general terms ---');
String actResult2 = ANAgentConsensusContentSearchHandler.searchContent('Find onboarding courses for new employees').message;
System.debug('Result 6: ' + actResult2);

// Test 7: Direct service calls for detailed testing
System.debug('\n--- Test 7: Direct service calls ---');

// Test Consensus service directly
try {
    String directConsensusResult = ANAgentConsensusContentSearchService.searchConsensusContent('Consensus microdemo for REIT');
    System.debug('Direct Consensus Result: ' + directConsensusResult);
} catch (Exception e) {
    System.debug('Direct Consensus Error: ' + e.getMessage());
}

// Test ACT service directly
try {
    ANAgentContentSearchServiceV2.ContentSearchResult directACTResult = ANAgentContentSearchServiceV2.search('Sales Cloud', 'Course');
    System.debug('Direct ACT Result Count: ' + directACTResult.totalCount);
} catch (Exception e) {
    System.debug('Direct ACT Error: ' + e.getMessage());
}

// Test 8: Edge cases
System.debug('\n--- Test 8: Edge cases ---');

// Empty utterance
String emptyResult = ANAgentConsensusContentSearchHandler.searchContent('').message;
System.debug('Empty Result: ' + emptyResult);

// Null utterance (should be handled gracefully)
try {
    ANAgentConsensusContentSearchHandler.ContentSearchRequest nullRequest = new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
    nullRequest.userUtterance = null;
    List<ANAgentConsensusContentSearchHandler.ContentSearchRequest> nullRequests = new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>{nullRequest};
    List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> nullResponses = ANAgentConsensusContentSearchHandler.searchContent(nullRequests);
    if (!nullResponses.isEmpty()) {
        System.debug('Null Result: ' + nullResponses[0].message);
    }
} catch (Exception e) {
    System.debug('Null handling: ' + e.getMessage());
}

// Very long utterance
String longUtterance = 'Find Consensus demos for Datorama on media planning with specific requirements for Financial Services customers in the Marketing Cloud folder created by Justin Jones in English language that are published and public with preview links available for billing reconciliation and revenue pacing scenarios';
String longResult = ANAgentConsensusContentSearchHandler.searchContent(longUtterance).message;
System.debug('Long Utterance Result Length: ' + longResult.length());

System.debug('\n=== Consensus Content Search Testing Complete ===');

// Summary of test results
System.debug('\n--- Test Summary ---');
System.debug('✓ Consensus routing: ' + (consensusResult1.contains('Consensus Content Search') ? 'PASS' : 'FAIL'));
System.debug('✓ ACT routing: ' + (actResult1.contains('ACT Content Search') ? 'PASS' : 'FAIL'));
System.debug('✓ Error handling: ' + (emptyResult.contains('Error') ? 'PASS' : 'FAIL'));
System.debug('✓ Message composition: ' + (consensusResult1.contains('**SUMMARY**') && consensusResult1.contains('**INSIGHTS**') ? 'PASS' : 'FAIL'));
