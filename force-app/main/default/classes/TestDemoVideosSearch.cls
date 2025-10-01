@isTest
public class TestDemoVideosSearch {
    @isTest
    static void testShowMeDemoVideosForSalesCloud() {
        // Test the exact utterance that should route to Consensus
        String testUtterance = 'Show me demo videos for Sales Cloud';
        
        List<ANAgentContentSearchHandlerV2.ContentSearchRequest> requests = new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>();
        
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Sales Cloud';
        request.userUtterance = testUtterance;
        request.searchMode = 'AUTO';
        requests.add(request);

        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(requests);
        Test.stopTest();

        System.debug('=== TESTING: "Show me demo videos for Sales Cloud" ===');
        System.debug('Response success: ' + responses[0].success);
        System.debug('Response message: ' + responses[0].message);
        System.debug('Response routing decision: ' + responses[0].routingDecision);
        System.debug('Total records found: ' + responses[0].totalRecordCount);
        System.debug('Number of results: ' + (responses[0].results != null ? responses[0].results.size() : 0));
        
        if (responses[0].results != null && !responses[0].results.isEmpty()) {
            System.debug('First result type: ' + responses[0].results[0].type);
            System.debug('First result name: ' + responses[0].results[0].name);
        }

        // Assertions
        System.assert(responses.size() == 1, 'Should return one response');
        System.assert(responses[0].routingDecision != null, 'Routing decision should not be null');
        
        // The routing should detect "demo videos" and route to Consensus
        System.assert(responses[0].routingDecision.contains('Consensus') || responses[0].routingDecision.contains('BOTH'), 
            'Should route to Consensus or BOTH sources. Actual routing: ' + responses[0].routingDecision);
        
        System.debug('=== TEST COMPLETED ===');
    }
}
