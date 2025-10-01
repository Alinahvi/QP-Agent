@isTest
public class ANAgentContentSearchHandlerV2Test {

    @isTest
    static void testConsensusKeywordRouting() {
        // Test Consensus keywords
        List<ANAgentContentSearchHandlerV2.ContentSearchRequest> requests = new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>();
        
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Data Cloud';
        request.userUtterance = 'Show me consensus videos for Data Cloud';
        request.searchMode = 'AUTO';
        requests.add(request);

        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assert(responses[0].routingDecision.contains('Consensus'), 'Should route to Consensus based on keyword');
    }

    @isTest
    static void testACTKeywordRouting() {
        // Test ACT keywords
        List<ANAgentContentSearchHandlerV2.ContentSearchRequest> requests = new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>();
        
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Sales Cloud';
        request.userUtterance = 'Find training on Sales Cloud';
        request.searchMode = 'AUTO';
        requests.add(request);

        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assert(responses[0].routingDecision.contains('ACT'), 'Should route to ACT based on keyword');
    }

    @isTest
    static void testBothKeywordsRouting() {
        // Test both keywords
        List<ANAgentContentSearchHandlerV2.ContentSearchRequest> requests = new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>();
        
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Marketing Cloud';
        request.userUtterance = 'Show me demo videos and training courses for Marketing Cloud';
        request.searchMode = 'AUTO';
        requests.add(request);

        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assert(responses[0].routingDecision != null, 'Routing decision should not be null: ' + responses[0].routingDecision);
        System.assert(responses[0].routingDecision.contains('both') || responses[0].routingDecision.contains('BOTH'), 'Should route to both sources: ' + responses[0].routingDecision);
    }

    @isTest
    static void testDefaultRouting() {
        // Test no keywords - should default to ACT
        List<ANAgentContentSearchHandlerV2.ContentSearchRequest> requests = new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>();
        
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Tableau';
        request.userUtterance = 'Show me Tableau content';
        request.searchMode = 'AUTO';
        requests.add(request);

        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assert(responses[0].routingDecision.contains('ACT') || responses[0].routingDecision.contains('default'), 'Should default to ACT');
    }

    @isTest
    static void testExplicitACTMode() {
        List<ANAgentContentSearchHandlerV2.ContentSearchRequest> requests = new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>();
        
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Sales Cloud';
        request.searchMode = 'ACT';
        requests.add(request);

        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals('Explicit ACT mode - searching learning content only', responses[0].routingDecision);
    }

    @isTest
    static void testExplicitConsensusMode() {
        List<ANAgentContentSearchHandlerV2.ContentSearchRequest> requests = new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>();
        
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Data Cloud';
        request.searchMode = 'CONSENSUS';
        requests.add(request);

        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals('Explicit Consensus mode - searching demo videos only', responses[0].routingDecision);
    }

    @isTest
    static void testExplicitBothMode() {
        List<ANAgentContentSearchHandlerV2.ContentSearchRequest> requests = new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>();
        
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Marketing Cloud';
        request.searchMode = 'BOTH';
        requests.add(request);

        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals('Explicit BOTH mode - searching all content sources', responses[0].routingDecision);
    }

    @isTest
    static void testEmptySearchTerm() {
        List<ANAgentContentSearchHandlerV2.ContentSearchRequest> requests = new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>();
        
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = '';
        request.searchMode = 'AUTO';
        requests.add(request);

        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals('Search term is required.', responses[0].message);
        System.assert(!responses[0].success, 'Should not be successful');
    }

    @isTest
    static void testNullSearchTerm() {
        List<ANAgentContentSearchHandlerV2.ContentSearchRequest> requests = new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>();
        
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = null;
        request.searchMode = 'AUTO';
        requests.add(request);

        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals('Search term is required.', responses[0].message);
        System.assert(!responses[0].success, 'Should not be successful');
    }

    @isTest
    static void testMultipleRequests() {
        List<ANAgentContentSearchHandlerV2.ContentSearchRequest> requests = new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>();
        
        ANAgentContentSearchHandlerV2.ContentSearchRequest request1 = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request1.searchTerm = 'Sales Cloud';
        request1.userUtterance = 'Find training on Sales Cloud';
        request1.searchMode = 'AUTO';
        requests.add(request1);

        ANAgentContentSearchHandlerV2.ContentSearchRequest request2 = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request2.searchTerm = 'Data Cloud';
        request2.userUtterance = 'Show me consensus videos for Data Cloud';
        request2.searchMode = 'AUTO';
        requests.add(request2);

        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(requests);
        Test.stopTest();

        System.assertEquals(2, responses.size(), 'Should return two responses');
        System.assert(responses[0].routingDecision.contains('ACT'), 'First request should route to ACT');
        System.assert(responses[1].routingDecision.contains('Consensus'), 'Second request should route to Consensus');
    }
}