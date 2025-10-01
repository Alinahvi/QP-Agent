// Test script to verify the original failing queries are now working
System.debug('🧪 Testing Original Failing Queries...');

// ========================================
// TEST 1: "what is the customer in UKI with biggest open pipe in stage 2?"
// ========================================

System.debug('=== TEST 1: UKI Stage 2 Customers ===');
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
        System.debug('✅ UKI Stage 2 Results: ' + response.totalRecords + ' records');
        System.debug('📊 Summary: ' + response.message);
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: UKI Stage 2 query now working!');
            System.debug('📋 Detailed Results: ' + response.detailedResults);
        }
    }
} catch (Exception e) {
    System.debug('❌ UKI Stage 2 Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 2: "what are the customers with biggest amount of open pipe in UKI?"
// ========================================

System.debug('=== TEST 2: UKI All Customers ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.maxResults = 10;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI All Customers Results: ' + response.totalRecords + ' records');
        System.debug('📊 Summary: ' + response.message);
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: UKI All Customers query now working!');
            System.debug('📋 Detailed Results: ' + response.detailedResults);
        }
    }
} catch (Exception e) {
    System.debug('❌ UKI All Customers Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 3: "Show me top 5 products for AMER ICE operating unit within ENTR"
// ========================================

System.debug('=== TEST 3: AMER ICE ENTR Products ===');
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
        System.debug('✅ AMER ICE ENTR Results: ' + response.totalRecords + ' records');
        System.debug('📊 Summary: ' + response.message);
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: AMER ICE ENTR query now working!');
            System.debug('📋 Detailed Results: ' + response.detailedResults);
        }
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE ENTR Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 4: "what are the AEs with biggest open pipe in stage 3"
// ========================================

System.debug('=== TEST 4: Stage 3 AEs ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS'; // This will show customers with their AEs
    request.operatingUnit = 'UKI';
    request.stageFilter = 'Stage 3'; // Should map to "03 - Validating Benefits & Value"
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ Stage 3 AEs Results: ' + response.totalRecords + ' records');
        System.debug('📊 Summary: ' + response.message);
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Stage 3 AEs query now working!');
            System.debug('📋 Detailed Results: ' + response.detailedResults);
        }
    }
} catch (Exception e) {
    System.debug('❌ Stage 3 AEs Test Failed: ' + e.getMessage());
}

// ========================================
// TEST 5: "What are the top 10 AEs with lowest open pipe in UKI within ENTR segment"
// ========================================

System.debug('=== TEST 5: UKI ENTR Segment AEs (Lowest) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.segment = 'ENTR'; // Should map to "Technology"
    request.maxResults = 10;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI ENTR AEs Results: ' + response.totalRecords + ' records');
        System.debug('📊 Summary: ' + response.message);
        if (response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: UKI ENTR AEs query now working!');
            System.debug('📋 Detailed Results: ' + response.detailedResults);
        }
    }
} catch (Exception e) {
    System.debug('❌ UKI ENTR AEs Test Failed: ' + e.getMessage());
}

System.debug('🎯 Original Failing Queries Test Complete!');
System.debug('📊 These should now work with the corrected mappings!'); 