// Test script to verify the stage and segment filtering fixes
System.debug('🧪 Testing Stage and Segment Filtering Fixes...');

// Test 1: UKI Stage 2 Customers (Should now work with mapping)
System.debug('=== TEST 1: UKI Stage 2 Customers (Fixed) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.stageFilter = 'Stage 2'; // Should map to "02 - Determining Problem, Impact, Ideal"
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI Stage 2 Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Detailed Results: ' + response.detailedResults);
        
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Stage filtering is now working!');
        } else {
            System.debug('⚠️ Still no records - need to investigate further');
        }
    } else {
        System.debug('⚠️ No responses received for UKI Stage 2');
    }
} catch (Exception e) {
    System.debug('❌ UKI Stage 2 Test Failed: ' + e.getMessage());
}

// Test 2: AMER ICE ENTR Segment Products (Should now work with mapping)
System.debug('=== TEST 2: AMER ICE ENTR Segment Products (Fixed) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.segment = 'ENTR'; // Should map to "Enterprise" and use LIKE search
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ AMER ICE ENTR Segment Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Detailed Results: ' + response.detailedResults);
        
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Segment filtering is now working!');
        } else {
            System.debug('⚠️ Still no records - need to investigate further');
        }
    } else {
        System.debug('⚠️ No responses received for AMER ICE ENTR Segment');
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE ENTR Segment Test Failed: ' + e.getMessage());
}

// Test 3: UKI Stage 3 Customers (Should now work with mapping)
System.debug('=== TEST 3: UKI Stage 3 Customers (Fixed) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.stageFilter = 'Stage 3'; // Should map to "03 - Validating Benefits & Value"
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI Stage 3 Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Detailed Results: ' + response.detailedResults);
        
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Stage 3 filtering is now working!');
        } else {
            System.debug('⚠️ Still no records - need to investigate further');
        }
    } else {
        System.debug('⚠️ No responses received for UKI Stage 3');
    }
} catch (Exception e) {
    System.debug('❌ UKI Stage 3 Test Failed: ' + e.getMessage());
}

System.debug('🎯 Stage and Segment Filtering Fixes Test Complete!'); 