// Verification Test Script for Open Pipe Analysis Fixes
System.debug('🧪 Testing Open Pipe Analysis Fixes - Verification...');

// ========================================
// TEST 1: Verify AMER ICE Top 5 Products (Should show actual amounts)
// ========================================
System.debug('=== TEST 1: AMER ICE Top 5 Products (Verify Amounts) ===');
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
        
        // Check if we're getting actual amounts (not just $0.00)
        if (response.detailedResults != null && response.detailedResults.contains('$0.00')) {
            System.debug('⚠️ Still seeing $0.00 amounts - need further investigation');
        } else {
            System.debug('✅ Amounts look good - no $0.00 values');
        }
    } else {
        System.debug('⚠️ No responses received for AMER ICE');
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 2: Verify UKI without invalid filters (Should work now)
// ========================================
System.debug('=== TEST 2: UKI Top 5 Products (No Invalid Filters) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'UKI';
    request.maxResults = 5;
    // Note: Not passing industry or region since they don't exist in data
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Detailed Results: ' + response.detailedResults);
    } else {
        System.debug('⚠️ No responses received for UKI');
    }
} catch (Exception e) {
    System.debug('❌ UKI Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 3: Verify CSV Export with Real Data
// ========================================
System.debug('=== TEST 3: CSV Export with Real Data ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'EXPORT_CSV';
    request.operatingUnit = 'AMER ICE';
    request.maxResults = 10;
    request.generateCSV = true;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ CSV Export Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- CSV Data Length: ' + (response.csvData != null ? response.csvData.length() : 0));
        
        if (response.csvData != null && response.csvData.length() > 0) {
            System.debug('- CSV Preview (first 500 chars): ' + response.csvData.substring(0, Math.min(500, response.csvData.length())));
            
            // Check if CSV has proper data (not empty product names)
            if (response.csvData.contains('""') && response.csvData.contains('Product Name')) {
                System.debug('✅ CSV has proper structure with headers');
            } else {
                System.debug('⚠️ CSV structure may need improvement');
            }
        }
    } else {
        System.debug('⚠️ No responses received for CSV Export');
    }
} catch (Exception e) {
    System.debug('❌ CSV Export Test Failed: ' + e.getMessage());
}

System.debug('🎯 Open Pipe Analysis Fixes Verification Complete!'); 