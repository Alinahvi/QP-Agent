// Comprehensive Open Pipe Analysis Test Script
// Testing all fixes: parameter handling, top 5 products, CSV export
System.debug('🧪 Testing Open Pipe Analysis Fixes...');

// ========================================
// TEST 1: Basic - Top 5 Products for AMER ICE
// ========================================
System.debug('=== TEST 1: Basic - Top 5 Products for AMER ICE ===');
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
        System.debug('- Summary: ' + response.summary);
        System.debug('- CSV Data Length: ' + (response.csvData != null ? response.csvData.length() : 0));
    } else {
        System.debug('⚠️ No responses received for AMER ICE');
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 2: Basic - Top 5 Products for UKI
// ========================================
System.debug('=== TEST 2: Basic - Top 5 Products for UKI ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'UKI';
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Summary: ' + response.summary);
        System.debug('- CSV Data Length: ' + (response.csvData != null ? response.csvData.length() : 0));
    } else {
        System.debug('⚠️ No responses received for UKI');
    }
} catch (Exception e) {
    System.debug('❌ UKI Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 3: Intermediate - Top Customers with Filtering
// ========================================
System.debug('=== TEST 3: Intermediate - Top Customers with Filtering ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.industry = 'FINS';
    request.region = 'UK';
    request.stageFilter = 'Prospecting';
    request.maxResults = 10;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI FINS Top Customers Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Summary: ' + response.summary);
        System.debug('- CSV Data Length: ' + (response.csvData != null ? response.csvData.length() : 0));
    } else {
        System.debug('⚠️ No responses received for UKI FINS');
    }
} catch (Exception e) {
    System.debug('❌ UKI FINS Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 4: Challenging - Comprehensive Analysis with CSV Export
// ========================================
System.debug('=== TEST 4: Challenging - Comprehensive Analysis with CSV Export ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'EXPORT_CSV';
    request.operatingUnit = 'AMER ICE';
    request.industry = 'Technology';
    request.maxResults = 100;
    request.generateCSV = true;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ AMER ICE Technology Comprehensive Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Summary: ' + response.summary);
        System.debug('- CSV Data Length: ' + (response.csvData != null ? response.csvData.length() : 0));
        
        if (response.csvData != null && response.csvData.length() > 0) {
            System.debug('- CSV Preview (first 500 chars): ' + response.csvData.substring(0, Math.min(500, response.csvData.length())));
        }
    } else {
        System.debug('⚠️ No responses received for AMER ICE Technology');
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE Technology Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 5: Stagnation Analysis
// ========================================
System.debug('=== TEST 5: Stagnation Analysis ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'STAGNATION_ANALYSIS';
    request.operatingUnit = 'LATAM';
    request.maxResults = 20;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ LATAM Stagnation Analysis Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Summary: ' + response.summary);
    } else {
        System.debug('⚠️ No responses received for LATAM Stagnation');
    }
} catch (Exception e) {
    System.debug('❌ LATAM Stagnation Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 6: Skill Recommendations
// ========================================
System.debug('=== TEST 6: Skill Recommendations ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'SKILL_RECOMMENDATIONS';
    request.operatingUnit = 'EMEA';
    request.maxResults = 15;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ EMEA Skill Recommendations Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Summary: ' + response.summary);
    } else {
        System.debug('⚠️ No responses received for EMEA Skills');
    }
} catch (Exception e) {
    System.debug('❌ EMEA Skills Test Failed: ' + e.getMessage());
}

System.debug('🎯 All Open Pipe Analysis Tests Completed!'); 