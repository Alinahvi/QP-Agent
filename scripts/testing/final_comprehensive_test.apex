// Final comprehensive test to verify all fixes are working
System.debug('🎯 Final Comprehensive Test - All Fixes Working...');

// ========================================
// STAGE FILTERING TESTS (Should all work now)
// ========================================

// Test 1: UKI Stage 2 Customers
System.debug('=== TEST 1: UKI Stage 2 Customers ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.stageFilter = 'Stage 2';
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI Stage 2 Results: ' + response.totalRecords + ' records');
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Stage 2 filtering working!');
        }
    }
} catch (Exception e) {
    System.debug('❌ UKI Stage 2 Test Failed: ' + e.getMessage());
}

// Test 2: UKI Stage 3 Customers
System.debug('=== TEST 2: UKI Stage 3 Customers ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.stageFilter = 'Stage 3';
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI Stage 3 Results: ' + response.totalRecords + ' records');
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Stage 3 filtering working!');
        }
    }
} catch (Exception e) {
    System.debug('❌ UKI Stage 3 Test Failed: ' + e.getMessage());
}

// ========================================
// SEGMENT FILTERING TESTS (Should all work now)
// ========================================

// Test 3: AMER ICE ENTR Segment Products
System.debug('=== TEST 3: AMER ICE ENTR Segment Products ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.segment = 'ENTR';
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ AMER ICE ENTR Results: ' + response.totalRecords + ' records');
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: ENTR segment filtering working!');
        }
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE ENTR Test Failed: ' + e.getMessage());
}

// Test 4: AMER ICE SMB Segment Products
System.debug('=== TEST 4: AMER ICE SMB Segment Products ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.segment = 'SMB';
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ AMER ICE SMB Results: ' + response.totalRecords + ' records');
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: SMB segment filtering working!');
        }
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE SMB Test Failed: ' + e.getMessage());
}

// Test 5: AMER ICE Technology Segment Products (Direct)
System.debug('=== TEST 5: AMER ICE Technology Segment Products (Direct) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.segment = 'Technology';
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ AMER ICE Technology Results: ' + response.totalRecords + ' records');
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Technology segment filtering working!');
        }
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE Technology Test Failed: ' + e.getMessage());
}

// ========================================
// COMBINED FILTERING TESTS
// ========================================

// Test 6: UKI Technology Stage 2 (Combined filters)
System.debug('=== TEST 6: UKI Technology Stage 2 (Combined) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.stageFilter = 'Stage 2';
    request.segment = 'Technology';
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI Technology Stage 2 Results: ' + response.totalRecords + ' records');
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Combined filtering working!');
        }
    }
} catch (Exception e) {
    System.debug('❌ UKI Technology Stage 2 Test Failed: ' + e.getMessage());
}

System.debug('🎯 Final Comprehensive Test Complete!');
System.debug('📊 SUMMARY: All major filtering issues should now be resolved!'); 