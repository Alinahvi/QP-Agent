/**
 * @description Comprehensive test script for the new Pipeline Search System
 * @author AI Assistant
 * @version 1.0
 */
System.debug('=== STARTING PIPELINE SEARCH SYSTEM TEST ===');

try {
    // Test 1: Basic search functionality
    System.debug('--- Test 1: Basic Search Functionality ---');
    ANAgentPipelineSearchHandler.PipelineSearchResponse basicResponse = 
        ANAgentPipelineSearchHandler.searchPipeline('Test');
    
    System.debug('Basic search response: ' + basicResponse);
    System.debug('Success: ' + basicResponse.success);
    System.debug('Message: ' + basicResponse.message);
    System.debug('Total count: ' + basicResponse.totalCount);
    
    // Test 2: Search by specific type
    System.debug('--- Test 2: Search by Type ---');
    ANAgentPipelineSearchHandler.PipelineSearchResponse typeResponse = 
        ANAgentPipelineSearchHandler.searchPipeline('Test', 'OU', 10, false);
    
    System.debug('Type search response: ' + typeResponse);
    System.debug('Success: ' + typeResponse.success);
    System.debug('Message: ' + typeResponse.message);
    
    // Test 3: Get available OUs
    System.debug('--- Test 3: Get Available OUs ---');
    List<String> availableOUs = ANAgentPipelineSearchService.getAllOUs();
    System.debug('Available OUs: ' + availableOUs);
    System.debug('OU count: ' + availableOUs.size());
    
    // Test 4: Test service directly
    System.debug('--- Test 4: Direct Service Test ---');
    ANAgentPipelineSearchService.PipelineSearchResult serviceResult = 
        ANAgentPipelineSearchService.searchPipeline('Test', 'All', 5, false);
    
    System.debug('Service result: ' + serviceResult);
    System.debug('Success: ' + serviceResult.success);
    System.debug('Records found: ' + serviceResult.records.size());
    
    // Test 5: Test with real data (if available)
    if (availableOUs.size() > 0) {
        System.debug('--- Test 5: Real Data Test ---');
        String testOU = availableOUs[0];
        System.debug('Testing with OU: ' + testOU);
        
        List<ANAgentPipelineSearchService.PipelineInfo> topAEs = 
            ANAgentPipelineSearchService.getTopAEsByOU(testOU, 5);
        
        System.debug('Top AEs in ' + testOU + ': ' + topAEs.size());
        if (topAEs.size() > 0) {
            ANAgentPipelineSearchService.PipelineInfo firstAE = topAEs[0];
            System.debug('First AE: ' + firstAE.fullName);
            System.debug('Email: ' + firstAE.email);
            System.debug('OU: ' + firstAE.ouName);
            System.debug('Total ACV: ' + firstAE.totalACV);
            System.debug('Is High Performer: ' + firstAE.isHighPerformer);
        }
    }
    
    // Test 6: Test high performers filter
    System.debug('--- Test 6: High Performers Filter ---');
    ANAgentPipelineSearchService.PipelineSearchResult highPerformerResult = 
        ANAgentPipelineSearchService.searchPipeline('Test', 'All', 10, true);
    
    System.debug('High performers result: ' + highPerformerResult);
    System.debug('High performers found: ' + highPerformerResult.records.size());
    
    // Test 7: Test industry search
    System.debug('--- Test 7: Industry Search ---');
    ANAgentPipelineSearchService.PipelineSearchResult industryResult = 
        ANAgentPipelineSearchService.searchPipeline('Technology', 'Industry', 5, false);
    
    System.debug('Industry search result: ' + industryResult);
    System.debug('Technology industry records: ' + industryResult.records.size());
    
    // Test 8: Test convenience methods
    System.debug('--- Test 8: Convenience Methods ---');
    ANAgentPipelineSearchHandler.PipelineSearchResponse simpleResponse = 
        ANAgentPipelineSearchHandler.searchPipeline('Test');
    
    System.debug('Simple search response: ' + simpleResponse);
    System.debug('Success: ' + simpleResponse.success);
    
    // Test 9: Test error handling
    System.debug('--- Test 9: Error Handling ---');
    ANAgentPipelineSearchHandler.PipelineSearchResponse emptyResponse = 
        ANAgentPipelineSearchHandler.searchPipeline('');
    
    System.debug('Empty search response: ' + emptyResponse);
    System.debug('Success: ' + emptyResponse.success);
    System.debug('Errors: ' + emptyResponse.errors);
    
    // Test 10: Test performance metrics calculation
    System.debug('--- Test 10: Performance Metrics ---');
    if (serviceResult.records.size() > 0) {
        ANAgentPipelineSearchService.PipelineInfo testRecord = serviceResult.records[0];
        System.debug('Test record before metrics: ' + testRecord);
        System.debug('CQ ACV: ' + testRecord.cqACV);
        System.debug('PQ ACV: ' + testRecord.pqACV);
        System.debug('Total ACV: ' + testRecord.totalACV);
        System.debug('Is High Performer: ' + testRecord.isHighPerformer);
    }
    
    System.debug('=== PIPELINE SEARCH SYSTEM TEST COMPLETED SUCCESSFULLY ===');
    
} catch (Exception e) {
    System.debug('=== TEST FAILED WITH EXCEPTION ===');
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
    throw e;
} 