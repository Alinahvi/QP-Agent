// Debug script to check the Territory Analysis issue
System.debug('🔍 Debugging Territory Analysis Issue...');

// ========================================
// TEST 1: Territory KPIs for UKI
// ========================================

System.debug('=== TEST 1: Territory KPIs for UKI ===');
try {
    ANAgentTerritoryAnalysisHandler.TerritoryAnalysisRequest request = new ANAgentTerritoryAnalysisHandler.TerritoryAnalysisRequest();
    request.analysisType = 'TERRITORY_KPIS';
    request.operatingUnit = 'UKI';
    
    System.debug('🔍 Request Details:');
    System.debug('- Analysis Type: ' + request.analysisType);
    System.debug('- Operating Unit: ' + request.operatingUnit);
    
    List<ANAgentTerritoryAnalysisHandler.TerritoryAnalysisResponse> responses = 
        ANAgentTerritoryAnalysisHandler.analyzeTerritory(new List<ANAgentTerritoryAnalysisHandler.TerritoryAnalysisRequest>{request});
    
    if (!responses.isEmpty()) {
        ANAgentTerritoryAnalysisHandler.TerritoryAnalysisResponse response = responses[0];
        System.debug('✅ Response Details:');
        System.debug('- Success: ' + response.success);
        System.debug('- Total Records: ' + response.totalRecords);
        System.debug('- Message: ' + response.message);
        System.debug('- Detailed Results: ' + response.detailedResults);
        
        if (response.success && response.totalRecords > 0) {
            System.debug('🎉 SUCCESS: Territory Analysis working correctly!');
        } else {
            System.debug('⚠️ Territory Analysis returned no results or failed');
        }
    }
} catch (Exception e) {
    System.debug('❌ Territory Analysis Test Failed: ' + e.getMessage());
    System.debug('🔍 Stack Trace: ' + e.getStackTraceString());
}

// ========================================
// TEST 2: Direct SOQL Query to Verify Data Exists
// ========================================

System.debug('=== TEST 2: Direct SOQL Query Verification ===');
try {
    // Check if UKI data exists with KPI fields
    String query = 'SELECT COUNT() FROM AGENT_OU_PIPELINE_V2__c ' +
                    'WHERE OU_NAME__c = \'UKI\' ' +
                    'AND (CQ_CC_ACV__c != null OR CQ_CC_COVERAGE__c != null OR CQ_CC_ACP__c != null)';
    
    Integer count = Database.countQuery(query);
    System.debug('🔍 UKI Records with KPI Data: ' + count);
    
    // Check specific KPI fields
    String query2 = 'SELECT Id, CQ_CC_ACV__c, CQ_CC_COVERAGE__c, CQ_CC_ACP__c ' +
                     'FROM AGENT_OU_PIPELINE_V2__c ' +
                     'WHERE OU_NAME__c = \'UKI\' ' +
                     'AND (CQ_CC_ACV__c != null OR CQ_CC_COVERAGE__c != null OR CQ_CC_ACP__c != null) ' +
                     'LIMIT 3';
    
    List<AGENT_OU_PIPELINE_V2__c> records = Database.query(query2);
    System.debug('🔍 Sample KPI Records: ' + records.size());
    for (AGENT_OU_PIPELINE_V2__c record : records) {
        System.debug('- Record ID: ' + record.Id + ', ACV: ' + record.CQ_CC_ACV__c + ', Coverage: ' + record.CQ_CC_COVERAGE__c + ', ACP: ' + record.CQ_CC_ACP__c);
    }
    
} catch (Exception e) {
    System.debug('❌ Direct SOQL Test Failed: ' + e.getMessage());
}

System.debug('🎯 Territory Analysis Debug Complete!');
System.debug('📊 This should reveal why the Territory Analysis is failing!'); 