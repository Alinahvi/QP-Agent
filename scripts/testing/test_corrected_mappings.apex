// Test script to verify the corrected mappings are working
System.debug('🧪 Testing Corrected Mappings...');

// ========================================
// TEST STAGE MAPPING (Should now work correctly)
// ========================================

// Test 1: Stage 2 mapping
System.debug('=== TEST 1: Stage 2 Mapping ===');
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
        System.debug('✅ Stage 2 Results: ' + response.totalRecords + ' records');
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Stage 2 mapping working correctly!');
        }
    }
} catch (Exception e) {
    System.debug('❌ Stage 2 Test Failed: ' + e.getMessage());
}

// ========================================
// TEST SEGMENT MAPPING (Should now work correctly)
// ========================================

// Test 2: SMB mapping
System.debug('=== TEST 2: SMB Mapping ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER REG'; // Use a different OU to test
    request.segment = 'SMB'; // Should map to "SMB - AMER SMB"
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ SMB Results: ' + response.totalRecords + ' records');
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: SMB mapping working correctly!');
        }
    }
} catch (Exception e) {
    System.debug('❌ SMB Test Failed: ' + e.getMessage());
}

// Test 3: Financial mapping
System.debug('=== TEST 3: Financial Mapping ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'UKI';
    request.segment = 'Financial'; // Should map to "Financial Services"
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ Financial Results: ' + response.totalRecords + ' records');
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Financial mapping working correctly!');
        }
    }
} catch (Exception e) {
    System.debug('❌ Financial Test Failed: ' + e.getMessage());
}

// Test 4: Technology mapping
System.debug('=== TEST 4: Technology Mapping ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.segment = 'Technology'; // Should map to "Technology"
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ Technology Results: ' + response.totalRecords + ' records');
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Technology mapping working correctly!');
        }
    }
} catch (Exception e) {
    System.debug('❌ Technology Test Failed: ' + e.getMessage());
}

// ========================================
// TEST COMBINED MAPPING
// ========================================

// Test 5: Combined Stage + Segment
System.debug('=== TEST 5: Combined Stage + Segment ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.stageFilter = 'Stage 3'; // Should map to "03 - Validating Benefits & Value"
    request.segment = 'Technology'; // Should map to "Technology"
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ Combined Results: ' + response.totalRecords + ' records');
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Combined mapping working correctly!');
        }
    }
} catch (Exception e) {
    System.debug('❌ Combined Test Failed: ' + e.getMessage());
}

System.debug('🎯 Corrected Mappings Test Complete!');
System.debug('📊 All mappings should now work based on actual database values!'); 