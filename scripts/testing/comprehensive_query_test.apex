// Comprehensive test script to identify all query issues
System.debug('🔍 Comprehensive Query Test - Identifying All Issues...');

// Test 1: UKI Stage 2 Customers (This is failing)
System.debug('=== TEST 1: UKI Stage 2 Customers (Currently Failing) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    request.stageFilter = 'Stage 2'; // This should filter by stage
    
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

// Test 2: UKI All Customers (Check if this works)
System.debug('=== TEST 2: UKI All Customers (Check Current Functionality) ===');
try {
    ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest request = new ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest();
    request.analysisType = 'TOP_CUSTOMERS';
    request.operatingUnit = 'UKI';
    // No stage filter
    
    List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse> responses = 
        ANAgentOpenPipeAnalysisHandler.analyzeOpenPipe(new List<ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentOpenPipeAnalysisHandler.OpenPipeAnalysisResponse response = responses[0];
        System.debug('✅ UKI All Customers Results:');
        System.debug('- Success: ' + response.success);
        System.debug('- Message: ' + response.message);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Detailed Results: ' + response.detailedResults);
        
        // Check if we're getting real data or placeholders
        if (response.detailedResults != null) {
            if (response.detailedResults.contains('$X,XXX,XXX')) {
                System.debug('❌ Found placeholder data - not real amounts!');
            } else if (response.detailedResults.contains('$')) {
                System.debug('✅ Found real amounts in results');
            }
        }
    } else {
        System.debug('⚠️ No responses received for UKI All Customers');
    }
} catch (Exception e) {
    System.debug('❌ UKI All Customers Test Failed: ' + e.getMessage());
}

// Test 3: Check Raw Data for UKI Stage 2
System.debug('=== TEST 3: Raw Data Check for UKI Stage 2 ===');
try {
    String query = 'SELECT Id, OU_NAME__c, ' +
                   'OPEN_PIPE_OPTY_NM_2__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c, ' +
                   'OPEN_PIPE_OPTY_STG_NM_2__c, FULL_NAME__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE OU_NAME__c = \'UKI\' ' +
                   'AND OPEN_PIPE_OPTY_STG_NM_2__c != null ' +
                   'AND OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c > 0 ' +
                   'ORDER BY OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c DESC ' +
                   'LIMIT 10';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' UKI Stage 2 records');
    
    for (Integer i = 0; i < Math.min(5, records.size()); i++) {
        AGENT_OU_PIPELINE_V2__c record = records[i];
        String optyName = record.OPEN_PIPE_OPTY_NM_2__c;
        Decimal amount = record.OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c;
        String stageName = record.OPEN_PIPE_OPTY_STG_NM_2__c;
        String aeName = record.FULL_NAME__c;
        
        System.debug((i+1) + '. ' + optyName + ' - $' + amount + ' (Stage: ' + stageName + ', AE: ' + aeName + ')');
    }
} catch (Exception e) {
    System.debug('❌ Raw Data Check Failed: ' + e.getMessage());
}

// Test 4: Check Raw Data for UKI All Stages
System.debug('=== TEST 4: Raw Data Check for UKI All Stages ===');
try {
    String query = 'SELECT Id, OU_NAME__c, ' +
                   'OPEN_PIPE_OPTY_NM_1__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_1__c, ' +
                   'OPEN_PIPE_OPTY_NM_2__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_2__c, ' +
                   'OPEN_PIPE_OPTY_NM_3__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_3__c, ' +
                   'OPEN_PIPE_OPTY_NM_4__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_4__c, ' +
                   'OPEN_PIPE_OPTY_NM_5__c, OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_5__c, ' +
                   'FULL_NAME__c ' +
                   'FROM AGENT_OU_PIPELINE_V2__c ' +
                   'WHERE OU_NAME__c = \'UKI\' ' +
                   'AND (OPEN_PIPE_OPTY_NM_1__c != null OR OPEN_PIPE_OPTY_NM_2__c != null OR OPEN_PIPE_OPTY_NM_3__c != null OR OPEN_PIPE_OPTY_NM_4__c != null OR OPEN_PIPE_OPTY_NM_5__c != null) ' +
                   'LIMIT 5';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query);
    System.debug('Found ' + records.size() + ' UKI records with opportunities');
    
    for (Integer i = 0; i < Math.min(3, records.size()); i++) {
        AGENT_OU_PIPELINE_V2__c record = records[i];
        System.debug('--- Record ' + (i+1) + ' ---');
        System.debug('AE: ' + record.FULL_NAME__c);
        
        Decimal totalAmount = 0;
        for (Integer stage = 1; stage <= 5; stage++) {
            String optyName = (String)record.get('OPEN_PIPE_OPTY_NM_' + stage + '__c');
            Decimal amount = (Decimal)record.get('OPEN_PIPE_ORIGINAL_OPENPIPE_ALLOC_AMT_' + stage + '__c');
            
            if (String.isNotBlank(optyName) && amount != null && amount > 0) {
                System.debug('Stage ' + stage + ': ' + optyName + ' - $' + amount);
                totalAmount += amount;
            }
        }
        System.debug('  TOTAL: $' + totalAmount);
    }
} catch (Exception e) {
    System.debug('❌ UKI All Stages Check Failed: ' + e.getMessage());
}

System.debug('🔍 Comprehensive Query Test Complete!'); 