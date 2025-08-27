/**
 * Test KPI Field Mapping Fix
 * Test the exact query that was failing: EMEA countries vs ENTR segment for pipeline
 */

System.debug('=== TESTING KPI FIELD MAPPING FIX ===');

try {
    // Test the exact query that was failing
    System.debug('--- TEST: EMEA Countries vs ENTR Segment for Pipeline ---');
    
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request.analysisType = 'PIPELINE';
    request.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request.primaryValue = 'EMEA';
    request.comparisonDimension = 'SEGMENT'; // This was causing the SEGMENT__c error
    request.comparisonValue = 'ENTR';
    request.includeDetails = true;
    
    System.debug('Request: ' + request);
    System.debug('Primary Dimension: ' + request.primaryDimension);
    System.debug('Comparison Dimension: ' + request.comparisonDimension);
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request });
    
    if (!responses.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response = responses[0];
        System.debug('✅ SUCCESS: Analysis completed');
        System.debug('Success: ' + response.success);
        System.debug('Message: ' + response.message);
        System.debug('Total Records: ' + response.totalRecords);
        System.debug('Total Value: ' + response.totalValue);
        System.debug('Breakdown Summary: ' + response.breakdownSummary);
        
        if (response.success) {
            System.debug('🎯 Field mapping fix successful!');
        } else {
            System.debug('❌ Still failing: ' + response.message);
        }
    } else {
        System.debug('❌ No response received');
    }
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== TEST COMPLETED ==='); 