/**
 * @description Simple test to verify routing logic between Consensus and ACT
 */
System.debug('=== Simple Routing Test ===');

// Test 1: Consensus routing
System.debug('\n--- Test 1: Consensus routing ---');
String consensusResult = ANAgentConsensusContentSearchHandler.searchContent('Find Consensus demos for Datorama').message;
System.debug('Consensus Result Header: ' + consensusResult.substring(0, Math.min(50, consensusResult.length())));

// Test 2: ACT routing
System.debug('\n--- Test 2: ACT routing ---');
String actResult = ANAgentConsensusContentSearchHandler.searchContent('Find Sales Cloud courses').message;
System.debug('ACT Result Header: ' + actResult.substring(0, Math.min(50, actResult.length())));

// Test 3: Verify routing logic
System.debug('\n--- Test 3: Routing Verification ---');
Boolean consensusRouted = consensusResult.contains('Consensus Content Search');
Boolean actRouted = actResult.contains('ACT Content Search');

System.debug('Consensus routing: ' + (consensusRouted ? '✅ PASS' : '❌ FAIL'));
System.debug('ACT routing: ' + (actRouted ? '✅ PASS' : '❌ FAIL'));

System.debug('\n=== Routing Test Complete ===');
System.debug('Summary: Consensus=' + consensusRouted + ', ACT=' + actRouted);





