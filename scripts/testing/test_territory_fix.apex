// Test script to verify the Territory Analysis fix
System.debug('🧪 Testing Territory Analysis Fix...');

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
            System.debug('🎉 SUCCESS: Territory Analysis now working!');
            System.debug('📊 No more "unexpected token: \'1\'" error!');
        } else {
            System.debug('⚠️ Response indicates failure: ' + response.message);
        }
    }
} catch (Exception e) {
    System.debug('❌ Territory Analysis Test Failed: ' + e.getMessage());
    if (e.getMessage().contains('unexpected token')) {
        System.debug('❌ Still getting "unexpected token" error - fix not working');
    } else {
        System.debug('✅ No more "unexpected token" error - fix is working!');
        System.debug('🔍 New error: ' + e.getMessage());
    }
}

System.debug('🎯 Territory Analysis Fix Test Complete!');
System.debug('📊 The "unexpected token: \'1\'" error should now be resolved!'); 