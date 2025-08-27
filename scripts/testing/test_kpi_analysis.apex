/**
 * Test script for KPI Analysis functionality
 * Tests the new ANAgentKPIAnalysisHandler and ANAgentKPIAnalysisService
 */

System.debug('=== KPI ANALYSIS TESTING STARTED ===');

// Test 1: Basic Meetings Analysis for AMER ICE
System.debug('\n--- TEST 1: Meetings Analysis for AMER ICE ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request1 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request1.analysisType = 'MEETINGS';
    request1.primaryDimension = 'OU_NAME';
    request1.primaryValue = 'AMER ICE';
    request1.timeFrame = 'CURRENT';
    request1.maxResults = 100;
    request1.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses1 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request1 });
    
    if (!responses1.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response1 = responses1[0];
        System.debug('Success: ' + response1.success);
        System.debug('Message: ' + response1.message);
        System.debug('Total Records: ' + response1.totalRecords);
        System.debug('Total Value: ' + response1.totalValue);
        System.debug('Average Value: ' + response1.averageValue);
        System.debug('Insights: ' + response1.insights);
        System.debug('Breakdown Summary: ' + response1.breakdownSummary);
        System.debug('Detailed Results: ' + response1.detailedResults);
    }
} catch (Exception e) {
    System.debug('Test 1 Error: ' + e.getMessage());
}

// Test 2: Pipeline Analysis for UKI
System.debug('\n--- TEST 2: Pipeline Analysis for UKI ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request2 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request2.analysisType = 'PIPELINE';
    request2.primaryDimension = 'OU_NAME';
    request2.primaryValue = 'UKI';
    request2.timeFrame = 'CURRENT';
    request2.maxResults = 100;
    request2.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses2 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request2 });
    
    if (!responses2.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response2 = responses2[0];
        System.debug('Success: ' + response2.success);
        System.debug('Message: ' + response2.message);
        System.debug('Total Records: ' + response2.totalRecords);
        System.debug('Total Value: ' + response2.totalValue);
        System.debug('Average Value: ' + response2.averageValue);
        System.debug('Insights: ' + response2.insights);
        System.debug('Breakdown Summary: ' + response2.breakdownSummary);
    }
} catch (Exception e) {
    System.debug('Test 2 Error: ' + e.getMessage());
}

// Test 3: ACV Analysis for Technology Industry
System.debug('\n--- TEST 3: ACV Analysis for Technology Industry ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request3 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request3.analysisType = 'ACV';
    request3.primaryDimension = 'PRIMARY_INDUSTRY';
    request3.primaryValue = 'Technology';
    request3.timeFrame = 'CURRENT';
    request3.maxResults = 100;
    request3.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses3 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request3 });
    
    if (!responses3.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response3 = responses3[0];
        System.debug('Success: ' + response3.success);
        System.debug('Message: ' + response3.message);
        System.debug('Total Records: ' + response3.totalRecords);
        System.debug('Total Value: ' + response3.totalValue);
        System.debug('Average Value: ' + response3.averageValue);
        System.debug('Insights: ' + response3.insights);
    }
} catch (Exception e) {
    System.debug('Test 3 Error: ' + e.getMessage());
}

// Test 4: Calls Analysis for US Country
System.debug('\n--- TEST 4: Calls Analysis for US Country ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request4 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request4.analysisType = 'CALLS';
    request4.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request4.primaryValue = 'US';
    request4.timeFrame = 'CURRENT';
    request4.maxResults = 100;
    request4.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses4 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request4 });
    
    if (!responses4.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response4 = responses4[0];
        System.debug('Success: ' + response4.success);
        System.debug('Message: ' + response4.message);
        System.debug('Total Records: ' + response4.totalRecords);
        System.debug('Total Value: ' + response4.totalValue);
        System.debug('Average Value: ' + response4.averageValue);
        System.debug('Insights: ' + response4.insights);
    }
} catch (Exception e) {
    System.debug('Test 4 Error: ' + e.getMessage());
}

// Test 5: AI Mentions Analysis for AMER ACC
System.debug('\n--- TEST 5: AI Mentions Analysis for AMER ACC ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request5 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request5.analysisType = 'AI_MENTIONS';
    request5.primaryDimension = 'OU_NAME';
    request5.primaryValue = 'AMER ACC';
    request5.timeFrame = 'CURRENT';
    request5.maxResults = 100;
    request5.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses5 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request5 });
    
    if (!responses5.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response5 = responses5[0];
        System.debug('Success: ' + response5.success);
        System.debug('Message: ' + response5.message);
        System.debug('Total Records: ' + response5.totalRecords);
        System.debug('Total Value: ' + response5.totalValue);
        System.debug('Average Value: ' + response5.averageValue);
        System.debug('Insights: ' + response5.insights);
    }
} catch (Exception e) {
    System.debug('Test 5 Error: ' + e.getMessage());
}

// Test 6: Quarter over Quarter Analysis for AMER ICE
System.debug('\n--- TEST 6: Quarter over Quarter Analysis for AMER ICE ---');
try {
    ANAgentKPIAnalysisHandler.KPIAnalysisRequest request6 = new ANAgentKPIAnalysisHandler.KPIAnalysisRequest();
    request6.analysisType = 'MEETINGS';
    request6.primaryDimension = 'OU_NAME';
    request6.primaryValue = 'AMER ICE';
    request6.timeFrame = 'QOQ';
    request6.maxResults = 100;
    request6.includeDetails = true;
    
    List<ANAgentKPIAnalysisHandler.KPIAnalysisResponse> responses6 = 
        ANAgentKPIAnalysisHandler.analyzeKPIs(new List<ANAgentKPIAnalysisHandler.KPIAnalysisRequest>{ request6 });
    
    if (!responses6.isEmpty()) {
        ANAgentKPIAnalysisHandler.KPIAnalysisResponse response6 = responses6[0];
        System.debug('Success: ' + response6.success);
        System.debug('Message: ' + response6.message);
        System.debug('Total Records: ' + response6.totalRecords);
        System.debug('Total Value: ' + response6.totalValue);
        System.debug('Average Value: ' + response6.averageValue);
        System.debug('Insights: ' + response6.insights);
    }
} catch (Exception e) {
    System.debug('Test 6 Error: ' + e.getMessage());
}

// Test 7: Convenience Methods
System.debug('\n--- TEST 7: Convenience Methods ---');
try {
    // Test convenience method for meetings
    ANAgentKPIAnalysisHandler.KPIAnalysisResponse meetingsResponse = 
        ANAgentKPIAnalysisHandler.analyzeMeetings('OU_NAME', 'LATAM');
    System.debug('Convenience Meetings - Success: ' + meetingsResponse.success);
    System.debug('Convenience Meetings - Total: ' + meetingsResponse.totalValue);
    
    // Test convenience method for pipeline
    ANAgentKPIAnalysisHandler.KPIAnalysisResponse pipelineResponse = 
        ANAgentKPIAnalysisHandler.analyzePipeline('WORK_LOCATION_COUNTRY', 'Canada');
    System.debug('Convenience Pipeline - Success: ' + pipelineResponse.success);
    System.debug('Convenience Pipeline - Total: ' + pipelineResponse.totalValue);
    
    // Test convenience method for ACV
    ANAgentKPIAnalysisHandler.KPIAnalysisResponse acvResponse = 
        ANAgentKPIAnalysisHandler.analyzeACV('PRIMARY_INDUSTRY', 'Financial Services');
    System.debug('Convenience ACV - Success: ' + acvResponse.success);
    System.debug('Convenience ACV - Total: ' + acvResponse.totalValue);
    
} catch (Exception e) {
    System.debug('Test 7 Error: ' + e.getMessage());
}

// Test 8: Direct Service Call
System.debug('\n--- TEST 8: Direct Service Call ---');
try {
    ANAgentKPIAnalysisService.KPIAnalysisRequest serviceRequest = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    serviceRequest.analysisType = 'MEETINGS';
    serviceRequest.primaryDimension = 'OU_NAME';
    serviceRequest.primaryValue = 'UKI';
    serviceRequest.timeFrame = 'CURRENT';
    serviceRequest.maxResults = 50;
    serviceRequest.includeDetails = true;
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse serviceResponse = 
        ANAgentKPIAnalysisService.analyzeKPIs(serviceRequest);
    
    System.debug('Direct Service - Success: ' + serviceResponse.success);
    System.debug('Direct Service - Message: ' + serviceResponse.message);
    System.debug('Direct Service - Total Records: ' + serviceResponse.totalRecords);
    System.debug('Direct Service - Total Value: ' + serviceResponse.totalValue);
    System.debug('Direct Service - Average Value: ' + serviceResponse.averageValue);
    
} catch (Exception e) {
    System.debug('Test 8 Error: ' + e.getMessage());
}

System.debug('\n=== KPI ANALYSIS TESTING COMPLETED ==='); 