/**
 * @description Comprehensive test script for the Simplified Pipeline Search Handler
 * @author AI Assistant
 * @version 1.0
 */
System.debug('=== STARTING SIMPLIFIED PIPELINE SEARCH TEST ===');

try {
    // Test 1: Basic search functionality
    System.debug('--- Test 1: Basic Search Functionality ---');
    ANAgentPipelineSearchHandlerSimple.PipelineSearchResponse basicResponse = 
        ANAgentPipelineSearchHandlerSimple.searchPipeline('Test');
    
    System.debug('Basic search response: ' + basicResponse);
    System.debug('Success: ' + basicResponse.success);
    System.debug('Message: ' + basicResponse.message);
    System.debug('Total count: ' + basicResponse.totalCount);
    System.debug('OU Summary: ' + basicResponse.ouSummary);
    System.debug('High Performers Count: ' + basicResponse.highPerformersCount);
    System.debug('Errors: ' + basicResponse.errors);
    
    // Test 2: Search by specific type
    System.debug('--- Test 2: Search by Type ---');
    ANAgentPipelineSearchHandlerSimple.PipelineSearchResponse typeResponse = 
        ANAgentPipelineSearchHandlerSimple.searchPipeline('Test', 'OU', 10, false);
    
    System.debug('Type search response: ' + typeResponse);
    System.debug('Success: ' + typeResponse.success);
    System.debug('Message: ' + typeResponse.message);
    
    // Test 3: Test with real data (if available)
    System.debug('--- Test 3: Real Data Test ---');
    ANAgentPipelineSearchHandlerSimple.PipelineSearchResponse realResponse = 
        ANAgentPipelineSearchHandlerSimple.searchPipeline('Technology', 'Industry', 5, false);
    
    System.debug('Real data response: ' + realResponse);
    System.debug('Success: ' + realResponse.success);
    System.debug('Message: ' + realResponse.message);
    System.debug('Total count: ' + realResponse.totalCount);
    
    // Test 4: Test high performers filter
    System.debug('--- Test 4: High Performers Filter ---');
    ANAgentPipelineSearchHandlerSimple.PipelineSearchResponse highPerformerResponse = 
        ANAgentPipelineSearchHandlerSimple.searchPipeline('Test', 'All', 10, true);
    
    System.debug('High performers response: ' + highPerformerResponse);
    System.debug('Success: ' + highPerformerResponse.success);
    System.debug('High performers found: ' + highPerformerResponse.highPerformersCount);
    
    // Test 5: Test convenience methods
    System.debug('--- Test 5: Convenience Methods ---');
    ANAgentPipelineSearchHandlerSimple.PipelineSearchResponse simpleResponse = 
        ANAgentPipelineSearchHandlerSimple.searchPipeline('Test');
    
    System.debug('Simple search response: ' + simpleResponse);
    System.debug('Success: ' + simpleResponse.success);
    
    // Test 6: Test error handling
    System.debug('--- Test 6: Error Handling ---');
    ANAgentPipelineSearchHandlerSimple.PipelineSearchResponse emptyResponse = 
        ANAgentPipelineSearchHandlerSimple.searchPipeline('');
    
    System.debug('Empty search response: ' + emptyResponse);
    System.debug('Success: ' + emptyResponse.success);
    System.debug('Errors: ' + emptyResponse.errors);
    
    // Test 7: Test with different search terms
    System.debug('--- Test 7: Different Search Terms ---');
    List<String> testTerms = new List<String>{'Sales', 'Marketing', 'Engineering', 'Finance'};
    
    for (String term : testTerms) {
        ANAgentPipelineSearchHandlerSimple.PipelineSearchResponse termResponse = 
            ANAgentPipelineSearchHandlerSimple.searchPipeline(term, 'All', 3, false);
        
        System.debug('Search for "' + term + '": ' + termResponse.totalCount + ' results');
        System.debug('Message: ' + termResponse.message);
    }
    
    // Test 8: Test with different search types
    System.debug('--- Test 8: Different Search Types ---');
    List<String> searchTypes = new List<String>{'AE', 'OU', 'Industry', 'All'};
    
    for (String searchType : searchTypes) {
        ANAgentPipelineSearchHandlerSimple.PipelineSearchResponse typeTestResponse = 
            ANAgentPipelineSearchHandlerSimple.searchPipeline('Test', searchType, 5, false);
        
        System.debug('Search type "' + searchType + '": ' + typeTestResponse.totalCount + ' results');
        System.debug('Success: ' + typeTestResponse.success);
    }
    
    System.debug('=== SIMPLIFIED PIPELINE SEARCH TEST COMPLETED SUCCESSFULLY ===');
    
} catch (Exception e) {
    System.debug('=== TEST FAILED WITH EXCEPTION ===');
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
    throw e;
} 