// Simple test for KPI V4 classes
// Run this in anonymous apex to verify the classes work

System.debug('=== Testing KPI V4 Basic Functionality ===');

try {
    // Test 1: Basic search
    ANAgentKPIAnalysisHandlerV4.KPISearchRequest req = new ANAgentKPIAnalysisHandlerV4.KPISearchRequest();
    req.searchTerm = 'Test';
    req.recordLimit = 5;
    
    List<ANAgentKPIAnalysisHandlerV4.KPISearchResponse> responses = 
        ANAgentKPIAnalysisHandlerV4.searchKPIs(new List<ANAgentKPIAnalysisHandlerV4.KPISearchRequest>{ req });
    
    System.debug('Response count: ' + responses.size());
    if (!responses.isEmpty()) {
        System.debug('Success: ' + responses[0].success);
        System.debug('Message: ' + responses[0].message);
        System.debug('Total count: ' + responses[0].totalRecordCount);
        System.debug('Results: ' + responses[0].results.size());
    }
    
    // Test 2: Service layer
    ANAgentKPIAnalysisServiceV4.KPIAnalysisResult svcResult = 
        ANAgentKPIAnalysisServiceV4.search('Test', null, null, null, 3);
    
    System.debug('Service success: ' + svcResult.success);
    System.debug('Service records: ' + svcResult.totalCount);
    
    // Test 3: Convenience methods
    ANAgentKPIAnalysisHandlerV4.KPISearchResponse singleResponse = 
        ANAgentKPIAnalysisHandlerV4.searchKPIs('Test');
    System.debug('Single search success: ' + singleResponse.success);
    
    System.debug('=== KPI V4 Test Completed Successfully ===');
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack: ' + e.getStackTraceString());
} 