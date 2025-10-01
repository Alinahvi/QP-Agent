/**
 * Comprehensive Test of Updated KPI Analysis Service
 * Tests all analysis types, dimensions, and statistical functions
 */

System.debug('=== COMPREHENSIVE KPI SERVICE TEST ===');

try {
    // Test 1: Brazil Calls Analysis (Specific country)
    System.debug('\n--- TEST 1: BRAZIL CALLS ANALYSIS (Specific Country) ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request1 = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request1.analysisType = 'CALLS';
    request1.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request1.primaryValue = 'Brazil';
    request1.includeStatistics = true;
    
    System.debug('Request 1: ' + request1);
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response1 = ANAgentKPIAnalysisService.analyzeKPIs(request1);
    
    System.debug('Response 1 Success: ' + response1.success);
    System.debug('Response 1 Total Records: ' + response1.totalRecords);
    System.debug('Response 1 Total Value: ' + response1.totalValue);
    System.debug('Response 1 Average Value: ' + response1.averageValue);
    System.debug('Response 1 Max Value: ' + response1.maxValue);
    System.debug('Response 1 Min Value: ' + response1.minValue);
    System.debug('Response 1 Median Value: ' + response1.medianValue);
    System.debug('Response 1 Message: ' + response1.message);
    
    if (response1.detailedResults != null && !response1.detailedResults.isEmpty()) {
        System.debug('Response 1 Detailed Results Count: ' + response1.detailedResults.size());
        for (ANAgentKPIAnalysisService.KPIResult result : response1.detailedResults) {
            System.debug('  Dimension: ' + result.dimensionValue + ', Value: ' + result.value + ', Records: ' + result.recordCount + ', Avg: ' + result.averageValue);
        }
    }
    
    // Test 2: All Countries Calls Analysis (Empty primaryValue = get all)
    System.debug('\n--- TEST 2: ALL COUNTRIES CALLS ANALYSIS (Get All) ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request2 = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request2.analysisType = 'CALLS';
    request2.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request2.primaryValue = ''; // Empty to get all countries
    request2.includeStatistics = true;
    
    System.debug('Request 2: ' + request2);
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response2 = ANAgentKPIAnalysisService.analyzeKPIs(request2);
    
    System.debug('Response 2 Success: ' + response2.success);
    System.debug('Response 2 Total Records: ' + response2.totalRecords);
    System.debug('Response 2 Total Value: ' + response2.totalValue);
    System.debug('Response 2 Average Value: ' + response2.averageValue);
    System.debug('Response 2 Max Value: ' + response2.maxValue);
    System.debug('Response 2 Min Value: ' + response2.minValue);
    System.debug('Response 2 Median Value: ' + response2.medianValue);
    System.debug('Response 2 Message: ' + response2.message);
    
    if (response2.detailedResults != null && !response2.detailedResults.isEmpty()) {
        System.debug('Response 2 Detailed Results Count: ' + response2.detailedResults.size());
        System.debug('Top 5 Countries by Calls:');
        for (Integer i = 0; i < Math.min(5, response2.detailedResults.size()); i++) {
            ANAgentKPIAnalysisService.KPIResult result = response2.detailedResults[i];
            System.debug('  ' + (i+1) + '. ' + result.dimensionValue + ': ' + result.value + ' calls (' + result.recordCount + ' records, avg: ' + result.averageValue + ')');
        }
    }
    
    // Test 3: Technology Industry Meetings Analysis
    System.debug('\n--- TEST 3: TECHNOLOGY INDUSTRY MEETINGS ANALYSIS ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request3 = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request3.analysisType = 'MEETINGS';
    request3.primaryDimension = 'PRIMARY_INDUSTRY';
    request3.primaryValue = 'Technology';
    request3.includeStatistics = true;
    
    System.debug('Request 3: ' + request3);
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response3 = ANAgentKPIAnalysisService.analyzeKPIs(request3);
    
    System.debug('Response 3 Success: ' + response3.success);
    System.debug('Response 3 Total Records: ' + response3.totalRecords);
    System.debug('Response 3 Total Value: ' + response3.totalValue);
    System.debug('Response 3 Average Value: ' + response3.averageValue);
    System.debug('Response 3 Message: ' + response3.message);
    
    // Test 4: All Industries Pipeline Analysis (Get all industries)
    System.debug('\n--- TEST 4: ALL INDUSTRIES PIPELINE ANALYSIS (Get All) ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request4 = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request4.analysisType = 'PIPELINE';
    request4.primaryDimension = 'PRIMARY_INDUSTRY';
    request4.primaryValue = ''; // Empty to get all industries
    request4.includeStatistics = true;
    
    System.debug('Request 4: ' + request4);
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response4 = ANAgentKPIAnalysisService.analyzeKPIs(request4);
    
    System.debug('Response 4 Success: ' + response4.success);
    System.debug('Response 4 Total Records: ' + response4.totalRecords);
    System.debug('Response 4 Total Value: ' + response4.totalValue);
    System.debug('Response 4 Average Value: ' + response4.averageValue);
    System.debug('Response 4 Message: ' + response4.message);
    
    if (response4.detailedResults != null && !response4.detailedResults.isEmpty()) {
        System.debug('Response 4 Detailed Results Count: ' + response4.detailedResults.size());
        System.debug('Top 5 Industries by Pipeline:');
        for (Integer i = 0; i < Math.min(5, response4.detailedResults.size()); i++) {
            ANAgentKPIAnalysisService.KPIResult result = response4.detailedResults[i];
            System.debug('  ' + (i+1) + '. ' + result.dimensionValue + ': ' + result.value + ' pipeline (' + result.recordCount + ' records, avg: ' + result.averageValue + ')');
        }
    }
    
    // Test 5: ACV Analysis by OU
    System.debug('\n--- TEST 5: ACV ANALYSIS BY OU ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request5 = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request5.analysisType = 'ACV';
    request5.primaryDimension = 'OU_NAME';
    request5.primaryValue = ''; // Empty to get all OUs
    request5.includeStatistics = true;
    
    System.debug('Request 5: ' + request5);
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response5 = ANAgentKPIAnalysisService.analyzeKPIs(request5);
    
    System.debug('Response 5 Success: ' + response5.success);
    System.debug('Response 5 Total Records: ' + response5.totalRecords);
    System.debug('Response 5 Total Value: ' + response5.totalValue);
    System.debug('Response 5 Average Value: ' + response5.averageValue);
    System.debug('Response 5 Message: ' + response5.message);
    
    // Test 6: AI Mentions Analysis
    System.debug('\n--- TEST 6: AI MENTIONS ANALYSIS ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request6 = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request6.analysisType = 'AI_MENTIONS';
    request6.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request6.primaryValue = ''; // Empty to get all countries
    request6.includeStatistics = true;
    
    System.debug('Request 6: ' + request6);
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response6 = ANAgentKPIAnalysisService.analyzeKPIs(request6);
    
    System.debug('Response 6 Success: ' + response6.success);
    System.debug('Response 6 Total Records: ' + response6.totalRecords);
    System.debug('Response 6 Total Value: ' + response6.totalValue);
    System.debug('Response 6 Average Value: ' + response6.averageValue);
    System.debug('Response 6 Message: ' + response6.message);
    
    // Test 7: Comparison Analysis (Brazil vs Technology)
    System.debug('\n--- TEST 7: COMPARISON ANALYSIS (Brazil vs Technology) ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisRequest request7 = new ANAgentKPIAnalysisService.KPIAnalysisRequest();
    request7.analysisType = 'CALLS';
    request7.primaryDimension = 'WORK_LOCATION_COUNTRY';
    request7.primaryValue = 'Brazil';
    request7.comparisonDimension = 'PRIMARY_INDUSTRY';
    request7.comparisonValue = 'Technology';
    request7.includeStatistics = true;
    
    System.debug('Request 7: ' + request7);
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse response7 = ANAgentKPIAnalysisService.analyzeKPIs(request7);
    
    System.debug('Response 7 Success: ' + response7.success);
    System.debug('Response 7 Total Records: ' + response7.totalRecords);
    System.debug('Response 7 Total Value: ' + response7.totalValue);
    System.debug('Response 7 Message: ' + response7.message);
    
    // Test 8: Convenience Methods
    System.debug('\n--- TEST 8: CONVENIENCE METHODS ---');
    
    ANAgentKPIAnalysisService.KPIAnalysisResponse convenienceResponse = ANAgentKPIAnalysisService.analyzeCalls('WORK_LOCATION_COUNTRY', 'US');
    
    System.debug('Convenience Method Success: ' + convenienceResponse.success);
    System.debug('Convenience Method Total Records: ' + convenienceResponse.totalRecords);
    System.debug('Convenience Method Total Value: ' + convenienceResponse.totalValue);
    
} catch (Exception e) {
    System.debug('❌ EXCEPTION: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('\n=== COMPREHENSIVE KPI SERVICE TEST COMPLETED ==='); 