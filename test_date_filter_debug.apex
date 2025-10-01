// Debug why date filtering isn't working
System.debug('=== DEBUGGING DATE FILTER ISSUE ===');

// Test the V2 service directly with date range
System.debug('\n--- Testing V2 Service with Date Range ---');
ANAgentContentSearchServiceV2.ContentSearchResult v2Result = 
    ANAgentContentSearchServiceV2.search('tableau', null);
System.debug('V2 Service Results (no date filter): ' + v2Result.records.size());

// Test with a simple Tableau search to see if V2 service supports date filtering
System.debug('\n--- Testing Simple Tableau Search ---');
List<ANAgentConsensusContentSearchHandler.ContentSearchRequest> requests = new List<ANAgentConsensusContentSearchHandler.ContentSearchRequest>();
ANAgentConsensusContentSearchHandler.ContentSearchRequest req = new ANAgentConsensusContentSearchHandler.ContentSearchRequest();
req.userUtterance = 'tableau';
req.limitN = 5;
requests.add(req);

List<ANAgentConsensusContentSearchHandler.ContentSearchResponse> responses = 
    ANAgentConsensusContentSearchHandler.searchContent(requests);

System.debug('Simple Tableau search results: ' + responses[0].results.size());

// Test direct SOQL with date range to confirm courses exist in that range
System.debug('\n--- Direct SOQL Test with Date Range ---');
try {
    String soql = 'SELECT Id, Name, CreatedDate FROM Course__c ' +
                  'WHERE Name LIKE \'%tableau%\' AND Status__c = \'Active\' ' +
                  'AND CreatedDate >= 2025-01-01T00:00:00Z AND CreatedDate <= 2025-06-30T23:59:59Z ' +
                  'ORDER BY CreatedDate DESC LIMIT 10';
    
    List<SObject> courses = Database.query(soql);
    System.debug('Direct SOQL with date range found: ' + courses.size() + ' courses');
    
    for (SObject course : courses) {
        System.debug('Course: ' + course.get('Name') + ' | Created: ' + course.get('CreatedDate'));
    }
} catch (Exception e) {
    System.debug('Direct SOQL error: ' + e.getMessage());
}

System.debug('\n=== DEBUG COMPLETE ===');
