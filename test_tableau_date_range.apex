// Test the specific utterance: "show me contente cteated on tableau between jan 1st to end of june 2025"
System.debug('=== TESTING TABLEAU DATE RANGE SEARCH ===');

// Create the search request with date range
List<ANAgentConsensusContentSearchHandler.ContentSearchRequest> requests = new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>();
ANAgentConsensusContentSearchHandler.ContentSearchRequest req = new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
req.userUtterance = 'show me contente cteated on tableau between jan 1st to end of june 2025';
req.startDate = '2025-01-01';
req.endDate = '2025-06-30';
req.limitN = 20;
requests.add(req);

System.debug('Searching for: ' + req.userUtterance);
System.debug('Date range: ' + req.startDate + ' to ' + req.endDate);

// Execute the search
List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> responses = 
    ANAgentConsensusContentSearchHandler.searchContent(requests);

System.debug('\n=== SEARCH RESULTS ===');
System.debug('Results count: ' + responses[0].results.size());
System.debug('Message: ' + responses[0].message);

// Show individual results
System.debug('\n=== INDIVIDUAL RESULTS ===');
for (Integer i = 0; i < responses[0].results.size(); i++) {
    ANAgentConsensusContentSearchHandler.IntelligentContentResult result = responses[0].results[i];
    System.debug('Result ' + (i+1) + ':');
    System.debug('  Title: ' + result.title);
    System.debug('  Source: ' + result.source);
    System.debug('  Score: ' + result.score);
    System.debug('  Description: ' + (String.isNotBlank(result.description) ? result.description.substring(0, Math.min(100, result.description.length())) + '...' : 'No description'));
    System.debug('  Why: ' + result.why);
    System.debug('');
}

System.debug('=== TEST COMPLETE ===');
