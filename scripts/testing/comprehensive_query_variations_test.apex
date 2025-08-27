// Comprehensive test script for all 10 query variations
System.debug('🧪 Comprehensive Query Variations Test - Testing All Scenarios...');

// ========================================
// CUSTOMER-BASED QUERIES
// ========================================

// Test 1: "What is the customer in UKI with biggest open pipe in stage 2?"
System.debug('=== TEST 1: UKI Stage 2 Customers (Biggest) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.stageFilter = 'Stage 2'; // Should filter by stage
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
    } else {
        System.debug('⚠️ No responses received for UKI Stage 2');
    }
} catch (Exception e) {
    System.debug('❌ UKI Stage 2 Test Failed: ' + e.getMessage());
}

// Test 2: "What are the customers with biggest amount of open pipe in UKI?"
System.debug('=== TEST 2: UKI All Customers (Biggest) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    // No stage filter
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI All Customers Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Detailed Results: ' + response.detailedResults);
    } else {
        System.debug('⚠️ No responses received for UKI All Customers');
    }
} catch (Exception e) {
    System.debug('❌ UKI All Customers Test Failed: ' + e.getMessage());
}

// Test 3: "Show me customers with lowest open pipe in UKI SMB segment"
System.debug('=== TEST 3: UKI SMB Segment Customers (Lowest) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.segment = 'SMB'; // Filter by SMB segment
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI SMB Segment Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Detailed Results: ' + response.detailedResults);
    } else {
        System.debug('⚠️ No responses received for UKI SMB Segment');
    }
} catch (Exception e) {
    System.debug('❌ UKI SMB Segment Test Failed: ' + e.getMessage());
}

// Test 4: "Which customers have the highest open pipe in UKI ENTR segment?"
System.debug('=== TEST 4: UKI ENTR Segment Customers (Highest) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.segment = 'ENTR'; // Filter by ENTR segment
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI ENTR Segment Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Detailed Results: ' + response.detailedResults);
    } else {
        System.debug('⚠️ No responses received for UKI ENTR Segment');
    }
} catch (Exception e) {
    System.debug('❌ UKI ENTR Segment Test Failed: ' + e.getMessage());
}

// Test 5: "List customers with open pipe in stage 3 for UKI"
System.debug('=== TEST 5: UKI Stage 3 Customers ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.stageFilter = 'Stage 3'; // Filter by stage 3
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
    } else {
        System.debug('⚠️ No responses received for UKI Stage 3');
    }
} catch (Exception e) {
    System.debug('❌ UKI Stage 3 Test Failed: ' + e.getMessage());
}

// ========================================
// PRODUCT-BASED QUERIES
// ========================================

// Test 6: "Show me top 5 products for AMER ICE operating unit within ENTR"
System.debug('=== TEST 6: AMER ICE ENTR Segment Products ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.segment = 'ENTR'; // Filter by ENTR segment
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
    } else {
        System.debug('⚠️ No responses received for AMER ICE ENTR Segment');
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE ENTR Segment Test Failed: ' + e.getMessage());
}

// Test 7: "Show me top 5 products for AMER ICE operating unit within SMB"
System.debug('=== TEST 7: AMER ICE SMB Segment Products ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.segment = 'SMB'; // Filter by SMB segment
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
    } else {
        System.debug('⚠️ No responses received for AMER ICE SMB Segment');
    }
} catch (Exception e) {
    System.debug('❌ AMER ICE SMB Segment Test Failed: ' + e.getMessage());
}

// ========================================
// AE-BASED QUERIES (These will need new analysis types)
// ========================================

// Test 8: "What are the AEs with biggest open pipe in stage 3?"
System.debug('=== TEST 8: Stage 3 AEs (Biggest) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS'; // Use customers to get AEs
    request.stageFilter = 'Stage 3'; // Filter by stage 3
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ Stage 3 AEs Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Detailed Results: ' + response.detailedResults);
    } else {
        System.debug('⚠️ No responses received for Stage 3 AEs');
    }
} catch (Exception e) {
    System.debug('❌ Stage 3 AEs Test Failed: ' + e.getMessage());
}

// Test 9: "Show me top 10 AEs with lowest open pipe in UKI within ENTR segment"
System.debug('=== TEST 9: UKI ENTR Segment AEs (Lowest) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS'; // Use customers to get AEs
    request.operatingUnit = 'UKI';
    request.segment = 'ENTR'; // Filter by ENTR segment
    request.maxResults = 10;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI ENTR Segment AEs Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Detailed Results: ' + response.detailedResults);
    } else {
        System.debug('⚠️ No responses received for UKI ENTR Segment AEs');
    }
} catch (Exception e) {
    System.debug('❌ UKI ENTR Segment AEs Test Failed: ' + e.getMessage());
}

// Test 10: "Which AEs have the highest open pipe in UKI?"
System.debug('=== TEST 10: UKI AEs (Highest) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS'; // Use customers to get AEs
    request.operatingUnit = 'UKI';
    // No segment filter
    request.maxResults = 5;
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI AEs Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Detailed Results: ' + response.detailedResults);
    } else {
        System.debug('⚠️ No responses received for UKI AEs');
    }
} catch (Exception e) {
    System.debug('❌ UKI AEs Test Failed: ' + e.getMessage());
}

System.debug('🎯 Comprehensive Query Variations Test Complete!'); 