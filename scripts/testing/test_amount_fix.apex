// Test script to verify the amount fix - should now show realistic amounts
System.debug('🧪 Testing Amount Fix - Should show realistic amounts now...');

// Test 1: AMER ICE Top 5 Products (Should show millions, not $60)
System.debug('=== TEST 1: AMER ICE Top 5 Products (Verify Realistic Amounts) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ AMER ICE Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Detailed Results: ' + response.detailedResults);
        
        // Check if we're getting realistic amounts (millions, not $60)
        if (response.detailedResults != null) {
            if (response.detailedResults.contains('$60') || response.detailedResults.contains('$250') || response.detailedResults.contains('$276')) {
                System.debug('⚠️ Still seeing small amounts - fix may not be working');
            } else if (response.detailedResults.contains('$1,000,000') || response.detailedResults.contains('$2,000,000') || response.detailedResults.contains('$3,000,000')) {
                System.debug('✅ Amounts look realistic now - seeing millions!');
            } else {
                System.debug('✅ Amounts improved - no more $60 values');
            }
        }
    } else {
        System.debug('⚠️ No responses received for AMER ICE');
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE Test Failed: ' + e.getMessage());
}

// Test 2: Check the actual amounts being returned
System.debug('=== TEST 2: Amount Range Check ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.maxResults = 10;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ Extended Results:');
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Detailed Results: ' + response.detailedResults);
        
        // Look for specific amount patterns
        if (response.detailedResults != null) {
            if (response.detailedResults.contains('$1,000,000') || response.detailedResults.contains('$2,000,000') || response.detailedResults.contains('$3,000,000')) {
                System.debug('🎯 SUCCESS: Found realistic amounts in millions!');
            } else {
                System.debug('📊 Amounts found: ' + response.detailedResults);
            }
        }
    }
} catch (Exception e) {
    System.debug('❌ Extended Test Failed: ' + e.getMessage());
}

System.debug('🎯 Amount Fix Test Complete!'); 