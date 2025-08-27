// Test script to verify the updated segment mapping
System.debug('🧪 Testing Updated Segment Mapping...');

// Test 1: AMER ICE ENTR Segment Products (Should now map to "Technology")
System.debug('=== TEST 1: AMER ICE ENTR Segment Products (Updated Mapping) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.segment = 'ENTR'; // Should map to "Technology"
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
            System.debug('🎉 SUCCESS: ENTR segment mapping is now working!');
        } else {
            System.debug('⚠️ Still no records - need to investigate further');
        }
    } else {
        System.debug('⚠️ No responses received for AMER ICE ENTR Segment');
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE ENTR Segment Test Failed: ' + e.getMessage());
}

// Test 2: AMER ICE SMB Segment Products (Should now map to "Retail & CG")
System.debug('=== TEST 2: AMER ICE SMB Segment Products (Updated Mapping) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.segment = 'SMB'; // Should map to "Retail & CG"
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ AMER ICE SMB Segment Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Detailed Results: ' + response.detailedResults);
        
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: SMB segment mapping is now working!');
        } else {
            System.debug('⚠️ Still no records - need to investigate further');
        }
    } else {
        System.debug('⚠️ No responses received for AMER ICE SMB Segment');
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE SMB Segment Test Failed: ' + e.getMessage());
}

// Test 3: AMER ICE Technology Segment Products (Direct match)
System.debug('=== TEST 3: AMER ICE Technology Segment Products (Direct Match) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.segment = 'Technology'; // Direct match to database value
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ AMER ICE Technology Segment Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Detailed Results: ' + response.detailedResults);
        
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Technology segment filtering is working!');
        } else {
            System.debug('⚠️ Still no records - need to investigate further');
        }
    } else {
        System.debug('⚠️ No responses received for AMER ICE Technology Segment');
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE Technology Segment Test Failed: ' + e.getMessage());
}

System.debug('🎯 Updated Segment Mapping Test Complete!'); 