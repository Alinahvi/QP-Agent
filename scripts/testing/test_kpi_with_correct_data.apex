/**
 * Test KPI Analysis with Correct Data Values
 * Use the actual values that exist in the database
 */

System.debug('=== TESTING KPI ANALYSIS WITH CORRECT DATA ===');

try {
    // Test 1: EMEA Central countries vs Technology industry for pipeline
    System.debug('--- TEST 1: EMEA Central Countries vs Technology Industry for Pipeline ---');
    
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request1 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request1.analysisType = 'PIPELINE';
    request1.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request1.primaryValue = 'EMEA Central'; // Use actual OU name
    request1.comparisonDimension = 'PRIMARY_INDUSTRY';
    request1.comparisonValue = 'Technology'; // Use actual industry name
    request1.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses1 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request1 });
    
    if (!responses1.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response1 = responses1[0];
        System.debug('Test 1 - Success: ' + response1.success);
        System.debug('Test 1 - Message: ' + response1.message);
        System.debug('Test 1 - Total Records: ' + response1.totalRecords);
        System.debug('Test 1 - Total Value: ' + response1.totalValue);
    }
    
    // Test 2: UKI countries vs Financial Services industry for meetings
    System.debug('\n--- TEST 2: UKI Countries vs Financial Services Industry for Meetings ---');
    
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request2 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request2.analysisType = 'MEETINGS';
    request2.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request2.primaryValue = 'UKI'; // Use actual OU name
    request2.comparisonDimension = 'PRIMARY_INDUSTRY';
    request2.comparisonValue = 'Financial Services'; // Use actual industry name
    request2.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses2 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request2 });
    
    if (!responses2.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response2 = responses2[0];
        System.debug('Test 2 - Success: ' + response2.success);
        System.debug('Test 2 - Message: ' + response2.message);
        System.debug('Test 2 - Total Records: ' + response2.totalRecords);
        System.debug('Test 2 - Total Value: ' + response2.totalValue);
    }
    
    // Test 3: AMER ICE vs Technology industry for ACV
    System.debug('\n--- TEST 3: AMER ICE vs Technology Industry for ACV ---');
    
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request3 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request3.analysisType = 'ACV';
    request3.primaryDimension = 'OU_NAME';
    request3.primaryValue = 'AMER ICE'; // Use actual OU name
    request3.comparisonDimension = 'PRIMARY_INDUSTRY';
    request3.comparisonValue = 'Technology'; // Use actual industry name
    request3.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses3 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request3 });
    
    if (!responses3.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response3 = responses3[0];
        System.debug('Test 3 - Success: ' + response3.success);
        System.debug('Test 3 - Message: ' + response3.message);
        System.debug('Test 3 - Total Records: ' + response3.totalRecords);
        System.debug('Test 3 - Total Value: ' + response3.totalValue);
    }
    
    // Test 4: Germany vs Healthcare industry for calls
    System.debug('\n--- TEST 4: Germany vs Healthcare Industry for Calls ---');
    
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request4 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request4.analysisType = 'CALLS';
    request4.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request4.primaryValue = 'Germany'; // Use actual country name
    request4.comparisonDimension = 'PRIMARY_INDUSTRY';
    request4.comparisonValue = 'Healthcare & Life Sciences'; // Use actual industry name
    request4.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses4 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request4 });
    
    if (!responses4.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response4 = responses4[0];
        System.debug('Test 4 - Success: ' + response4.success);
        System.debug('Test 4 - Message: ' + response4.message);
        System.debug('Test 4 - Total Records: ' + response4.totalRecords);
        System.debug('Test 4 - Total Value: ' + response4.totalValue);
    }
    
    // Test 5: AI Mentions across all countries
    System.debug('\n--- TEST 5: AI Mentions Across All Countries ---');
    
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request5 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request5.analysisType = 'AI_MENTIONS';
    request5.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request5.primaryValue = ''; // No filter - all countries
    request5.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses5 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request5 });
    
    if (!responses5.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response5 = responses5[0];
        System.debug('Test 5 - Success: ' + response5.success);
        System.debug('Test 5 - Message: ' + response5.message);
        System.debug('Test 5 - Total Records: ' + response5.totalRecords);
        System.debug('Test 5 - Total Value: ' + response5.totalValue);
    }
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== COMPREHENSIVE TEST COMPLETED ==='); 