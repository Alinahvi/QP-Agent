// Test script to verify the industry parameter fix
System.debug('🧪 Testing Industry Parameter Fix...');

// ========================================
// TEST 1: Test with "industry" parameter (Agent UI style)
// ========================================

System.debug('=== TEST 1: Test with "industry" parameter ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.industry = 'ENTR'; // Using "industry" instead of "segment"
    request.maxResults = 5;
    
    System.debug('🔍 Request Details:');
    System.debug('- Analysis Type: ' + request.analysisType);
    System.debug('- Operating Unit: ' + request.operatingUnit);
    System.debug('- Industry: ' + request.industry);
    System.debug('- Max Results: ' + request.maxResults);
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ Response Details:');
        System.debug('- Success: ' + response.success);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Message: ' + response.message);
        System.debug('- Detailed Results: ' + response.detailedResults);
        
        if (response.success && response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Industry parameter now working!');
            System.debug('📊 Should return 4 records for AMER ICE ENTR');
        } else {
            System.debug('⚠️ Still no results - need to investigate further');
        }
    }
} catch (Exception e) {
    System.debug('❌ Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 2: Test with "segment" parameter (original way)
// ========================================

System.debug('=== TEST 2: Test with "segment" parameter ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.segment = 'ENTR'; // Using "segment" parameter
    request.maxResults = 5;
    
    System.debug('🔍 Request Details:');
    System.debug('- Analysis Type: ' + request.analysisType);
    System.debug('- Operating Unit: ' + request.operatingUnit);
    System.debug('- Segment: ' + request.segment);
    System.debug('- Max Results: ' + request.maxResults);
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ Response Details:');
        System.debug('- Success: ' + response.success);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Message: ' + response.message);
        System.debug('- Detailed Results: ' + response.detailedResults);
        
        if (response.success && response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Segment parameter still working!');
        } else {
            System.debug('⚠️ Segment parameter not working - this is unexpected');
        }
    }
} catch (Exception e) {
    System.debug('❌ Test Failed: ' + e.getMessage());
}

System.debug('🎯 Industry Parameter Fix Test Complete!');
System.debug('📊 Both "industry" and "segment" parameters should now work!'); 