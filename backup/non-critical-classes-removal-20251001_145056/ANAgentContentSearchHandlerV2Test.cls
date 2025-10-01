/**
 * @description Comprehensive unit tests for ANAgentContentSearchHandlerV2 with routing logic
 * @version 1.0
 */
@isTest
public class ANAgentContentSearchHandlerV2Test {

    /**
     * @description Test routing logic for Consensus keywords
     */
    @isTest
    static void testRoutingLogicConsensusKeywords() {
        // Test data
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Data Cloud';
        request.searchMode = 'AUTO';
        request.userUtterance = 'Show me consensus videos for Data Cloud between January 1st and end of June.';
        
        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentContentSearchHandlerV2.ContentSearchResponse response = responses[0];
        
        // Verify routing decision
        System.assert(response.routingDecision.contains('Consensus keywords detected'), 
            'Should detect Consensus keywords: ' + response.routingDecision);
        
        // Verify search source
        System.assertEquals('CONSENSUS', response.searchSource, 'Should route to Consensus source');
    }

    /**
     * @description Test routing logic for ACT keywords
     */
    @isTest
    static void testRoutingLogicACTKeywords() {
        // Test data
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Sales Cloud';
        request.searchMode = 'AUTO';
        request.userUtterance = 'Find training on Sales Cloud from beginning of May to end of July.';
        
        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentContentSearchHandlerV2.ContentSearchResponse response = responses[0];
        
        // Verify routing decision
        System.assert(response.routingDecision.contains('ACT keywords detected'), 
            'Should detect ACT keywords: ' + response.routingDecision);
        
        // Verify search source
        System.assertEquals('ACT', response.searchSource, 'Should route to ACT source');
    }

    /**
     * @description Test routing logic for both keywords
     */
    @isTest
    static void testRoutingLogicBothKeywords() {
        // Test data
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Tableau';
        request.searchMode = 'AUTO';
        request.userUtterance = 'Show me both Tableau demo videos and Tableau training courses.';
        
        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentContentSearchHandlerV2.ContentSearchResponse response = responses[0];
        
        // Verify routing decision
        System.assert(response.routingDecision.contains('Both ACT and Consensus keywords detected'), 
            'Should detect both keywords: ' + response.routingDecision);
        
        // Verify search source
        System.assertEquals('BOTH', response.searchSource, 'Should route to both sources');
    }

    /**
     * @description Test routing logic for no specific keywords (default to ACT)
     */
    @isTest
    static void testRoutingLogicNoKeywords() {
        // Test data
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Marketing Cloud';
        request.searchMode = 'AUTO';
        request.userUtterance = 'Any content on Marketing Cloud after March 15, 2025?';
        
        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentContentSearchHandlerV2.ContentSearchResponse response = responses[0];
        
        // Verify routing decision
        System.assert(response.routingDecision.contains('No specific keywords detected'), 
            'Should default to ACT: ' + response.routingDecision);
        
        // Verify search source
        System.assertEquals('ACT', response.searchSource, 'Should default to ACT source');
    }

    /**
     * @description Test explicit ACT mode
     */
    @isTest
    static void testExplicitACTMode() {
        // Test data
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Data Cloud';
        request.searchMode = 'ACT';
        request.userUtterance = 'Find Data Cloud demo videos'; // Contains demo keyword but should be ignored
        
        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentContentSearchHandlerV2.ContentSearchResponse response = responses[0];
        
        // Verify routing decision
        System.assert(response.routingDecision.contains('Explicit ACT mode requested'), 
            'Should respect explicit ACT mode: ' + response.routingDecision);
        
        // Verify search source
        System.assertEquals('ACT', response.searchSource, 'Should use ACT source despite demo keyword');
    }

    /**
     * @description Test explicit Consensus mode
     */
    @isTest
    static void testExplicitConsensusMode() {
        // Test data
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Sales Cloud';
        request.searchMode = 'CONSENSUS';
        request.userUtterance = 'Find Sales Cloud training courses'; // Contains training keyword but should be ignored
        
        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentContentSearchHandlerV2.ContentSearchResponse response = responses[0];
        
        // Verify routing decision
        System.assert(response.routingDecision.contains('Explicit Consensus mode requested'), 
            'Should respect explicit Consensus mode: ' + response.routingDecision);
        
        // Verify search source
        System.assertEquals('CONSENSUS', response.searchSource, 'Should use Consensus source despite training keyword');
    }

    /**
     * @description Test explicit BOTH mode
     */
    @isTest
    static void testExplicitBothMode() {
        // Test data
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = 'Marketing Cloud';
        request.searchMode = 'BOTH';
        
        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentContentSearchHandlerV2.ContentSearchResponse response = responses[0];
        
        // Verify routing decision
        System.assert(response.routingDecision.contains('Both sources requested'), 
            'Should respect explicit BOTH mode: ' + response.routingDecision);
        
        // Verify search source
        System.assertEquals('BOTH', response.searchSource, 'Should use both sources');
    }

    /**
     * @description Test validation for blank search term
     */
    @isTest
    static void testValidationBlankSearchTerm() {
        // Test data
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request.searchTerm = '';
        request.searchMode = 'AUTO';
        
        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentContentSearchHandlerV2.ContentSearchResponse response = responses[0];
        
        // Verify error handling
        System.assertEquals(false, response.success, 'Should not be successful');
        System.assert(response.message.contains('Search term is required'), 'Should have validation error');
        System.assertEquals(1, response.errors.size(), 'Should have one error');
    }

    /**
     * @description Test validation for null request list
     */
    @isTest
    static void testValidationNullRequestList() {
        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(null);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentContentSearchHandlerV2.ContentSearchResponse response = responses[0];
        
        // Verify error handling
        System.assertEquals(false, response.success, 'Should not be successful');
        System.assert(response.message.contains('No search request provided'), 'Should have validation error');
        System.assertEquals(1, response.errors.size(), 'Should have one error');
    }

    /**
     * @description Test backward compatibility with existing parameters
     */
    @isTest
    static void testBackwardCompatibility() {
        // Test data using old constructor
        ANAgentContentSearchHandlerV2.ContentSearchRequest request = 
            new ANAgentContentSearchHandlerV2.ContentSearchRequest('Sales Cloud', 'Course');
        
        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, responses.size(), 'Should return one response');
        ANAgentContentSearchHandlerV2.ContentSearchResponse response = responses[0];
        
        // Verify default search mode
        System.assertEquals('AUTO', request.searchMode, 'Should default to AUTO mode');
        
        // Verify routing decision
        System.assert(response.routingDecision.contains('No specific keywords detected'), 
            'Should default to ACT: ' + response.routingDecision);
        
        // Verify search source
        System.assertEquals('ACT', response.searchSource, 'Should default to ACT source');
    }

    /**
     * @description Test convenience methods
     */
    @isTest
    static void testConvenienceMethods() {
        Test.startTest();
        
        // Test single search term
        ANAgentContentSearchHandlerV2.ContentSearchResponse response1 = 
            ANAgentContentSearchHandlerV2.searchContent('Sales Cloud');
        
        // Test search term with content type
        ANAgentContentSearchHandlerV2.ContentSearchResponse response2 = 
            ANAgentContentSearchHandlerV2.searchContent('Sales Cloud', 'Course');
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, response1, 'First convenience method should work');
        System.assertNotEquals(null, response2, 'Second convenience method should work');
        
        // Both should default to ACT source
        System.assertEquals('ACT', response1.searchSource, 'First method should default to ACT');
        System.assertEquals('ACT', response2.searchSource, 'Second method should default to ACT');
    }

    /**
     * @description Test keyword detection edge cases
     */
    @isTest
    static void testKeywordDetectionEdgeCases() {
        // Test case-insensitive matching
        ANAgentContentSearchHandlerV2.ContentSearchRequest request1 = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request1.searchTerm = 'Data Cloud';
        request1.searchMode = 'AUTO';
        request1.userUtterance = 'Show me DEMO VIDEOS for Data Cloud'; // Uppercase
        
        // Test partial keyword matching
        ANAgentContentSearchHandlerV2.ContentSearchRequest request2 = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        request2.searchTerm = 'Sales Cloud';
        request2.searchMode = 'AUTO';
        request2.userUtterance = 'Find training courses for Sales Cloud'; // Contains 'training'
        
        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses1 = 
            ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request1});
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses2 = 
            ANAgentContentSearchHandlerV2.searchContent(new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>{request2});
        Test.stopTest();
        
        // Assertions for case-insensitive
        System.assertEquals(1, responses1.size(), 'Should return one response');
        ANAgentContentSearchHandlerV2.ContentSearchResponse response1 = responses1[0];
        System.assert(response1.routingDecision.contains('Consensus keywords detected'), 
            'Should detect uppercase DEMO VIDEOS: ' + response1.routingDecision);
        System.assertEquals('CONSENSUS', response1.searchSource, 'Should route to Consensus');
        
        // Assertions for partial matching
        System.assertEquals(1, responses2.size(), 'Should return one response');
        ANAgentContentSearchHandlerV2.ContentSearchResponse response2 = responses2[0];
        System.assert(response2.routingDecision.contains('ACT keywords detected'), 
            'Should detect training keyword: ' + response2.routingDecision);
        System.assertEquals('ACT', response2.searchSource, 'Should route to ACT');
    }

    /**
     * @description Test all routing scenarios with your example utterances
     */
    @isTest
    static void testExampleUtterancesRouting() {
        // Test data based on your requirements
        List<ANAgentContentSearchHandlerV2.ContentSearchRequest> requests = new List<ANAgentContentSearchHandlerV2.ContentSearchRequest>();
        
        // Example 1: Consensus keywords
        ANAgentContentSearchHandlerV2.ContentSearchRequest req1 = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        req1.searchTerm = 'Data Cloud';
        req1.searchMode = 'AUTO';
        req1.userUtterance = 'Show me consensus videos for Data Cloud between January 1st and end of June.';
        requests.add(req1);
        
        // Example 2: ACT keywords
        ANAgentContentSearchHandlerV2.ContentSearchRequest req2 = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        req2.searchTerm = 'Tableau';
        req2.searchMode = 'AUTO';
        req2.userUtterance = 'Find training on Tableau from beginning of May to end of July.';
        requests.add(req2);
        
        // Example 3: ACT keywords
        ANAgentContentSearchHandlerV2.ContentSearchRequest req3 = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        req3.searchTerm = 'Sales Cloud';
        req3.searchMode = 'AUTO';
        req3.userUtterance = 'Any course on Sales Cloud after March 15, 2025?';
        requests.add(req3);
        
        // Example 4: Consensus keywords
        ANAgentContentSearchHandlerV2.ContentSearchRequest req4 = new ANAgentContentSearchHandlerV2.ContentSearchRequest();
        req4.searchTerm = 'Marketing Cloud';
        req4.searchMode = 'AUTO';
        req4.userUtterance = 'Consensus demo for Marketing Cloud before Aug 1, 2025.';
        requests.add(req4);
        
        Test.startTest();
        List<ANAgentContentSearchHandlerV2.ContentSearchResponse> responses = 
            ANAgentContentSearchHandlerV2.searchContent(requests);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(4, responses.size(), 'Should return 4 responses');
        
        // Response 1: Consensus
        System.assert(responses[0].routingDecision.contains('Consensus keywords detected'), 
            'Should detect consensus keywords in example 1');
        System.assertEquals('CONSENSUS', responses[0].searchSource, 'Should route to Consensus');
        
        // Response 2: ACT
        System.assert(responses[1].routingDecision.contains('ACT keywords detected'), 
            'Should detect training keyword in example 2');
        System.assertEquals('ACT', responses[1].searchSource, 'Should route to ACT');
        
        // Response 3: ACT
        System.assert(responses[2].routingDecision.contains('ACT keywords detected'), 
            'Should detect course keyword in example 3');
        System.assertEquals('ACT', responses[2].searchSource, 'Should route to ACT');
        
        // Response 4: Consensus
        System.assert(responses[3].routingDecision.contains('Consensus keywords detected'), 
            'Should detect consensus and demo keywords in example 4');
        System.assertEquals('CONSENSUS', responses[3].searchSource, 'Should route to Consensus');
    }
}
