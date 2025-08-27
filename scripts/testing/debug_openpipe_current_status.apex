// Debug script to check the current status of Open Pipe Analysis
System.debug('🔍 Debugging Open Pipe Analysis Current Status...');

// ========================================
// TEST 1: AMER ICE ENTR Products (The failing query)
// ========================================

System.debug('=== TEST 1: AMER ICE ENTR Products ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_PRODUCTS';
    request.operatingUnit = 'AMER ICE';
    request.segment = 'ENTR'; // Should map to "Technology"
    request.maxResults = 5;
    
    System.debug('🔍 Request Details:');
    System.debug('- Analysis Type: ' + request.analysisType);
    System.debug('- Operating Unit: ' + request.operatingUnit);
    System.debug('- Segment: ' + request.segment);
    System.debug('- Max Results: ' + request.maxResults);
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ Response Details:');
        System.debug('- Success: ' + response.success);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Message: ' + response.message);
        System.debug('- Detailed Results: ' + response.detailedResults);
        
        if (response.success && response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Query working correctly!');
        } else {
            System.debug('⚠️ Query returned no results or failed');
        }
    }
} catch (Exception e) {
    System.debug('❌ Open Pipe Test Failed: ' + e.getMessage());
    System.debug('🔍 Stack Trace: ' + e.getStackTraceString());
}

// ========================================
// TEST 2: UKI Stage 2 Customers (The failing query)
// ========================================

System.debug('=== TEST 2: UKI Stage 2 Customers ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.stageFilter = 'Stage 2'; // Should map to "02 - Determining Problem, Impact, Ideal"
    request.maxResults = 5;
    
    System.debug('🔍 Request Details:');
    System.debug('- Analysis Type: ' + request.analysisType);
    System.debug('- Operating Unit: ' + request.operatingUnit);
    System.debug('- Stage Filter: ' + request.stageFilter);
    System.debug('- Max Results: ' + request.maxResults);
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ Response Details:');
        System.debug('- Success: ' + response.success);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Message: ' + response.message);
        System.debug('- Detailed Results: ' + response.detailedResults);
        
        if (response.success && response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Query working correctly!');
        } else {
            System.debug('⚠️ Query returned no results or failed');
        }
    }
} catch (Exception e) {
    System.debug('❌ Open Pipe Test Failed: ' + e.getMessage());
    System.debug('🔍 Stack Trace: ' + e.getStackTraceString());
}

// ========================================
// TEST 3: Direct SOQL Query to Verify Data Exists
// ========================================

System.debug('=== TEST 3: Direct SOQL Query Verification ===');
try {
    // Test 1: Check if AMER ICE Technology data exists
    String query1 = 'SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c ' +
                    'WHERE OU_NAME__c = \'AMER ICE\' AND PRIMARY_INDUSTRY__c = \'Technology\' ' +
                    'AND (OPEN_PIPE_OPTY_STG_NM_1__c != null OR OPEN_PIPE_OPTY_STG_NM_2__c != null OR OPEN_PIPE_OPTY_STG_NM_3__c != null OR OPEN_PIPE_OPTY_STG_NM_4__c != null OR OPEN_PIPE_OPTY_STG_NM_5__c != null)';
    
    Integer count1 = Database.countQuery(query1);
    System.debug('🔍 AMER ICE Technology Records: ' + count1);
    
    // Test 2: Check if UKI Stage 2 data exists
    String query2 = 'SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c ' +
                    'WHERE OU_NAME__c = \'UKI\' ' +
                    'AND (OPEN_PIPE_OPTY_STG_NM_2__c = \'02 - Determining Problem, Impact, Ideal\')';
    
    Integer count2 = Database.countQuery(query2);
    System.debug('🔍 UKI Stage 2 Records: ' + count2);
    
} catch (Exception e) {
    System.debug('❌ Direct SOQL Test Failed: ' + e.getMessage());
}

System.debug('🎯 Open Pipe Analysis Debug Complete!');
System.debug('📊 This should reveal why the queries are returning no results!'); 