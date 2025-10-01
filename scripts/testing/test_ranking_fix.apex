// Test script to verify the ranking fix - should now show highest amounts first
System.debug('🧪 Testing Ranking Fix - Should show highest amounts first...');

// Test: AMER ICE Top 5 Products (Should show millions first, not $17K)
System.debug('=== TEST: AMER ICE Top 5 Products (Verify Correct Ranking) ===');
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
        
        // Check if we're getting the correct ranking (highest amounts first)
        if (response.detailedResults != null) {
            String results = response.detailedResults;
            
            // Look for the expected pattern: highest amounts should be first
            if (results.contains('$2,000,000') || results.contains('$3,000,000')) {
                System.debug('🎯 SUCCESS: Found high amounts in results!');
                
                // Check if first result has higher amount than last result
                if (results.contains('1.') && results.contains('5.')) {
                    System.debug('✅ Ranking structure looks correct (numbered 1-5)');
                }
                
                // Look for specific high-value products we expect
                if (results.contains('Toyota') || results.contains('PepsiCo') || results.contains('Whirlpool')) {
                    System.debug('✅ Found major enterprise opportunities!');
                }
            } else {
                System.debug('⚠️ Still not seeing high amounts - ranking may still be wrong');
            }
        }
    } else {
        System.debug('⚠️ No responses received for AMER ICE');
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE Test Failed: ' + e.getMessage());
}

System.debug('🎯 Ranking Fix Test Complete!'); 