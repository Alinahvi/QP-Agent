// Debug the calculateDateRange method
System.debug('=== DEBUGGING DATE RANGE CALCULATION ===');

// Test the calculateDateRange method directly
System.debug('\n--- Testing calculateDateRange method ---');

// Create a mock request to test calculateDateRange
ANAgentConsensusContentSearchHandler.ContentSearchRequest req = new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
req.startDate = '2025-01-01';
req.endDate = '2025-06-30';

System.debug('Input startDate: ' + req.startDate);
System.debug('Input endDate: ' + req.endDate);

// We can't call calculateDateRange directly since it's private, but let's test the date parsing
try {
    Date startDate = Date.valueOf(req.startDate);
    Date endDate = Date.valueOf(req.endDate);
    System.debug('Parsed startDate: ' + startDate);
    System.debug('Parsed endDate: ' + endDate);
    
    // Test with a Tableau course that should be in this range
    Date testCourseDate = Date.valueOf('2025-05-05'); // Tableau Immersions FY'26
    System.debug('Test course date: ' + testCourseDate);
    System.debug('Is test course >= startDate? ' + (testCourseDate >= startDate));
    System.debug('Is test course <= endDate? ' + (testCourseDate <= endDate));
    
} catch (Exception e) {
    System.debug('Date parsing error: ' + e.getMessage());
}

// Test with a simpler search to see if the issue is with the long utterance
System.debug('\n--- Testing with simpler utterance ---');
List<ANAgentConsensusContentSearchHandler.ContentSearchRequest> requests = new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>();
ANAgentConsensusContentSearchHandler.ContentSearchRequest simpleReq = new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
simpleReq.userUtterance = 'tableau';  // Simple utterance
simpleReq.startDate = '2025-01-01';
simpleReq.endDate = '2025-06-30';
simpleReq.limitN = 10;
requests.add(simpleReq);

List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> responses = 
    ANAgentConsensusContentSearchHandler.searchContent(requests);

System.debug('Simple utterance results: ' + responses[0].results.size());

System.debug('\n=== DEBUG COMPLETE ===');
