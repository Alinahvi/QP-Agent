// Test script to verify the updated stage and segment mappings
System.debug('🧪 Testing Updated Mappings with Data Dictionary Values...');

// ========================================
// TEST 1: Test Stage 2 Filtering (Should now work with correct stage names)
// ========================================

System.debug('=== TEST 1: Stage 2 Filtering ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.stageFilter = 'Stage 2'; // Should now map to the correct stage name from data dictionary
    request.maxResults = 5;
    
    System.debug('🔍 Request Details:');
    System.debug('- Analysis Type: ' + request.analysisType);
    System.debug('- Operating Unit: ' + request.operatingUnit);
    System.debug('- Stage Filter: ' + request.stageFilter);
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
            System.debug('🎉 SUCCESS: Stage 2 filtering now working with correct stage names!');
        } else {
            System.debug('⚠️ Still no results - need to investigate further');
        }
    }
} catch (Exception e) {
    System.debug('❌ Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 2: Test ENTR Segment Filtering (Should work with industry parameter)
// ========================================

System.debug('=== TEST 2: ENTR Segment Filtering ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.industry = 'ENTR'; // Using "industry" parameter (Agent UI style)
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
            System.debug('🎉 SUCCESS: ENTR segment filtering working with industry parameter!');
        } else {
            System.debug('⚠️ Still no results - need to investigate further');
        }
    }
} catch (Exception e) {
    System.debug('❌ Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 3: Test Combined Stage + Segment Filtering
// ========================================

System.debug('=== TEST 3: Combined Stage + Segment ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.stageFilter = 'Stage 3'; // Should map to correct stage name
    request.industry = 'Technology'; // Should map to correct industry
    request.maxResults = 5;
    
    System.debug('🔍 Request Details:');
    System.debug('- Analysis Type: ' + request.analysisType);
    System.debug('- Operating Unit: ' + request.operatingUnit);
    System.debug('- Stage Filter: ' + request.stageFilter);
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
            System.debug('🎉 SUCCESS: Combined filtering working!');
        } else {
            System.debug('⚠️ Combined filtering returned no results');
        }
    }
} catch (Exception e) {
    System.debug('❌ Test Failed: ' + e.getMessage());
}

System.debug('🎯 Updated Mappings Test Complete!');
System.debug('📊 All mappings should now work with the correct field names from the data dictionary!'); 