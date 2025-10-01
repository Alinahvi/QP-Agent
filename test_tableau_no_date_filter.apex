// Test Tableau search without date filter to see what courses exist
System.debug('=== TESTING TABLEAU SEARCH WITHOUT DATE FILTER ===');

// Test 1: Search for Tableau without date filter
List<ANAgentConsensusContentSearchHandler.ContentSearchRequest> requests = new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>();
ANAgentConsensusContentSearchHandler.ContentSearchRequest req = new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
req.userUtterance = 'tableau courses';
req.limitN = 10;
requests.add(req);

System.debug('Searching for: ' + req.userUtterance + ' (no date filter)');

List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> responses = 
    ANAgentConsensusContentSearchHandler.searchContent(requests);

System.debug('\n=== RESULTS WITHOUT DATE FILTER ===');
System.debug('Results count: ' + responses[0].results.size());

// Show first few results
for (Integer i = 0; i < Math.min(5, responses[0].results.size()); i++) {
    ANAgentConsensusContentSearchHandler.IntelligentContentResult result = responses[0].results[i];
    System.debug('Result ' + (i+1) + ': ' + result.title + ' (Source: ' + result.source + ')');
}

// Test 2: Check actual dates of Tableau courses in the database
System.debug('\n=== CHECKING ACTUAL TABLEAU COURSE DATES ===');
try {
    List<SObject> tableauCourses = Database.query('SELECT Id, Name, CreatedDate FROM Course__c WHERE Name LIKE \'%tableau%\' AND Status__c = \'Active\' ORDER BY CreatedDate DESC LIMIT 10');
    System.debug('Found ' + tableauCourses.size() + ' Tableau courses in database');
    
    for (SObject course : tableauCourses) {
        System.debug('Course: ' + course.get('Name') + ' | Created: ' + course.get('CreatedDate'));
    }
} catch (Exception e) {
    System.debug('Error querying courses: ' + e.getMessage());
}

// Test 3: Check date range that would include existing courses
System.debug('\n=== TESTING WITH REALISTIC DATE RANGE ===');
List<ANAgentConsensusContentSearchHandler.ContentSearchRequest> requests2 = new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>();
ANAgentConsensusContentSearchHandler.ContentSearchRequest req2 = new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
req2.userUtterance = 'tableau courses';
req2.startDate = '2020-01-01';  // Start from 2020
req2.endDate = '2025-12-31';    // End in 2025
req2.limitN = 10;
requests2.add(req2);

System.debug('Searching with date range: 2020-01-01 to 2025-12-31');

List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> responses2 = 
    ANAgentConsensusContentSearchHandler.searchContent(requests2);

System.debug('Results with realistic date range: ' + responses2[0].results.size());

System.debug('\n=== TEST COMPLETE ===');
